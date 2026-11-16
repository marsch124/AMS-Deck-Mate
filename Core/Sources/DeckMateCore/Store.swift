import Foundation

/// Where the setup lives: one file on this Mac. Every save first keeps the file that was there
/// as a safety copy, so a bad save can always be taken back.
public struct Store {
    public let folder: URL
    public static let keptCopies = 20

    public init(folder: URL? = nil) {
        self.folder = folder ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AMS Deck Mate", isDirectory: true)
    }

    public var file: URL { folder.appendingPathComponent("deck.json") }
    public var backups: URL { folder.appendingPathComponent("Backups", isDirectory: true) }

    /// nil when there is no setup yet (first start), or the file cannot be read at all.
    public func load() -> Deck? {
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder().decode(Deck.self, from: data)
    }

    public var hasFile: Bool { FileManager.default.fileExists(atPath: file.path) }

    @discardableResult
    public func save(_ deck: Deck) -> Bool {
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
    public func keepCopy(of data: Data) {
        let files = FileManager.default
        try? data.write(to: backups.appendingPathComponent("deck \(Store.stamp()).json"), options: .atomic)
        let copies = ((try? files.contentsOfDirectory(atPath: backups.path)) ?? [])
            .filter { $0.hasPrefix("deck ") && $0.hasSuffix(".json") }
            .sorted()
        for name in copies.dropLast(Store.keptCopies) {
            try? files.removeItem(at: backups.appendingPathComponent(name))
        }
    }

    private static func stamp() -> String {
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyy-MM-dd HH.mm.ss.SSS"
        stamp.locale = Locale(identifier: "en_US_POSIX")
        return stamp.string(from: Date())
    }

    // MARK: Safety copies

    /// One safety copy that can be read.
    public struct Copy: Identifiable, Equatable, Sendable {
        /// The file's name in the Backups folder.
        public var name: String
        /// When it was written.
        public var date: Date
        public var groups: Int
        public var keys: Int
        public var id: String { name }

        public init(name: String, date: Date, groups: Int, keys: Int) {
            self.name = name
            self.date = date
            self.groups = groups
            self.keys = keys
        }

        /// "3 page groups · 47 keys"
        public var words: String {
            "\(groups) page \(groups == 1 ? "group" : "groups") · \(keys) \(keys == 1 ? "key" : "keys")"
        }
    }

    /// The safety copies that can be read, newest first.
    public func copies() -> [Copy] {
        let files = FileManager.default
        let names = ((try? files.contentsOfDirectory(atPath: backups.path)) ?? [])
            .filter { $0.hasPrefix("deck ") && $0.hasSuffix(".json") }
        var found: [Copy] = []
        for name in names {
            let url = backups.appendingPathComponent(name)
            guard let deck = Store.read(url) else { continue }
            let date = ((try? files.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date) ?? .distantPast
            let keys = deck.profiles.reduce(0) { $0 + $1.pages.reduce(0) { $0 + $1.keys.count } }
            found.append(Copy(name: name, date: date, groups: deck.profiles.count, keys: keys))
        }
        return found.sorted { ($0.date, $0.name) > ($1.date, $1.name) }
    }

    public func deck(of copy: Copy) -> Deck? { Store.read(backups.appendingPathComponent(copy.name)) }

    /// A file as a setup; nil when it cannot be read or holds no page group at all.
    private static func read(_ url: URL) -> Deck? {
        guard let data = try? Data(contentsOf: url),
              let deck = try? JSONDecoder().decode(Deck.self, from: data), !deck.profiles.isEmpty else { return nil }
        return deck
    }

    // MARK: Starting

    public enum Start: Equatable, Sendable {
        /// No file yet: the very first start.
        case first
        /// The file was read as usual.
        case loaded
        /// The file was damaged: the safety copy written at this time took its place.
        case recovered(Date)
        /// The file was damaged and no safety copy could be read.
        case lost
    }

    /// Reads the setup at start. A damaged file is never thrown away: it is kept in Backups as
    /// "damaged <time>.json", and the newest safety copy that can be read takes its place.
    public func start() -> (deck: Deck?, how: Start) {
        guard hasFile else { return (nil, .first) }
        if let deck = load() { return (deck, .loaded) }
        let files = FileManager.default
        try? files.createDirectory(at: backups, withIntermediateDirectories: true)
        try? files.moveItem(at: file, to: backups.appendingPathComponent("damaged \(Store.stamp()).json"))
        for copy in copies() {
            guard let deck = deck(of: copy),
                  let data = try? Data(contentsOf: backups.appendingPathComponent(copy.name)) else { continue }
            try? data.write(to: file, options: .atomic)
            return (deck, .recovered(copy.date))
        }
        return (nil, .lost)
    }
}

/// The box diary must not grow without end.
public enum Diary {
    /// The diary cut down to its last `keep` lines once it has more than `over`; nil = leave it as it is.
    public static func trimmed(_ text: String, over: Int = 1000, keep: Int = 500) -> String? {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        guard lines.count > over else { return nil }
        return lines.suffix(keep).joined(separator: "\n") + "\n"
    }
}
