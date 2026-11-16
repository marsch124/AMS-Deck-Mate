import DeckMateCore
import Foundation

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
