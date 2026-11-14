import DeckMateCore
import Foundation

/// Where the setup lives: one file on this Mac. Every save first keeps the file that was there
/// as a safety copy, so a bad save can always be taken back.
struct Store {
    let folder: URL
    static let keptCopies = 20

    init(folder: URL? = nil) {
        self.folder = folder ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AMS Deck Mate", isDirectory: true)
    }

    var file: URL { folder.appendingPathComponent("deck.json") }
    var backups: URL { folder.appendingPathComponent("Backups", isDirectory: true) }

    /// nil when there is no setup yet (first start), or the file cannot be read at all.
    func load() -> Deck? {
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder().decode(Deck.self, from: data)
    }

    var hasFile: Bool { FileManager.default.fileExists(atPath: file.path) }

    @discardableResult
    func save(_ deck: Deck) -> Bool {
        let files = FileManager.default
        try? files.createDirectory(at: backups, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(deck) else { return false }
        if let old = try? Data(contentsOf: file) {
            if old == data { return true }
            keepCopy(of: old)
        }
        do {
            try data.write(to: file, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    /// Puts the file as it is now among the safety copies and keeps the newest ones.
    func keepCopy(of data: Data) {
        let files = FileManager.default
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyy-MM-dd HH.mm.ss.SSS"
        stamp.locale = Locale(identifier: "en_US_POSIX")
        try? data.write(to: backups.appendingPathComponent("deck \(stamp.string(from: Date())).json"), options: .atomic)
        let copies = ((try? files.contentsOfDirectory(atPath: backups.path)) ?? [])
            .filter { $0.hasPrefix("deck ") && $0.hasSuffix(".json") }
            .sorted()
        for name in copies.dropLast(Store.keptCopies) {
            try? files.removeItem(at: backups.appendingPathComponent(name))
        }
    }
}

/// The Raycast commands on this Mac: Raycast's own, then each installed extension.
enum RaycastCatalog {
    static let extensionsFolder = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".config/raycast/extensions")

    static func load() -> [RaycastCommand] {
        let files = FileManager.default
        var found: [RaycastCommand] = []
        for folder in (try? files.contentsOfDirectory(atPath: extensionsFolder.path)) ?? [] {
            let package = extensionsFolder.appendingPathComponent(folder).appendingPathComponent("package.json")
            guard let data = try? Data(contentsOf: package) else { continue }
            found += RaycastLink.commands(fromPackage: data)
        }
        var seen = Set<String>()
        let installed = found.filter { seen.insert($0.id).inserted }
            .sorted { ($0.group.lowercased(), $0.title.lowercased()) < ($1.group.lowercased(), $1.title.lowercased()) }
        return RaycastLink.builtIn + installed
    }
}
