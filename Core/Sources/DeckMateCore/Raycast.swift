import Foundation

/// One Raycast command a key can run.
public struct RaycastCommand: Equatable, Identifiable, Sendable {
    public var owner: String
    public var extensionName: String
    public var command: String
    /// "Clipboard History"
    public var title: String
    /// "Raycast" or the extension's name, for the heading in the list.
    public var group: String

    public init(owner: String, extensionName: String, command: String, title: String, group: String) {
        self.owner = owner
        self.extensionName = extensionName
        self.command = command
        self.title = title
        self.group = group
    }

    public var id: String { "\(owner)/\(extensionName)/\(command)" }
    public var link: String { RaycastLink.command(owner: owner, extensionName: extensionName, command: command) }
}

/// Raycast links (raycast://…), the way Raycast's manual writes them.
public enum RaycastLink {
    public static func command(owner: String, extensionName: String, command: String) -> String {
        "raycast://extensions/\(owner)/\(extensionName)/\(command)"
    }

    /// A script command, by the name of its file: "Color Conversion.sh" → raycast://script-commands/color-conversion
    public static func script(named name: String) -> String {
        let file = (name as NSString).lastPathComponent
        let bare = file.contains(".") ? (file as NSString).deletingPathExtension : file
        return "raycast://script-commands/\(slug(bare))"
    }

    /// An AI command, by its name: "Fix Spelling and Grammar" → raycast://ai-commands/fix-spelling-and-grammar
    public static func aiCommand(named name: String) -> String {
        "raycast://ai-commands/\(slug(name))"
    }

    /// Lower-case words joined by hyphens.
    public static func slug(_ text: String) -> String {
        let lowered = text.lowercased().folding(options: .diacriticInsensitive, locale: nil)
        let pieces = lowered.split { !($0.isLetter || $0.isNumber) }
        return pieces.joined(separator: "-")
    }

    /// Tidy what he pasted; nil when it is not a Raycast link.
    public static func cleaned(_ pasted: String) -> String? {
        let text = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.lowercased().hasPrefix("raycast://"), text.count > "raycast://".count,
              !text.contains(" ") else { return nil }
        return text
    }

    /// The link to open: "run quietly" adds launchType=background unless the link already says how to launch.
    public static func toOpen(_ link: String, quiet: Bool) -> String {
        guard quiet, link.hasPrefix("raycast://extensions/"), !link.contains("launchType=") else { return link }
        return link + (link.contains("?") ? "&" : "?") + "launchType=background"
    }

    /// The drawing a Raycast key gets by itself, from what its link says.
    public static func icon(forLink link: String) -> String {
        let text = link.lowercased()
        if text.contains("clipboard") { return "deck-clipboard" }
        if text.contains("left-half") { return "deck-window-left" }
        if text.contains("right-half") { return "deck-window-right" }
        if text.contains("window-management") { return "deck-window-full" }
        if text.contains("ai-commands") || text.contains("raycast-ai") || text.contains("/raycast/ai/") { return "deck-ai" }
        if text.contains("script-commands") { return "deck-script" }
        if text.contains("snippets") { return "app-snippets" }
        if text.contains("search") { return "app-search" }
        return "deck-raycast"
    }

    /// The commands of one installed extension, read from its package.json.
    public static func commands(fromPackage data: Data) -> [RaycastCommand] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["name"] as? String, !name.isEmpty else { return [] }
        let owner = (json["owner"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? (json["author"] as? String) ?? ""
        guard !owner.isEmpty else { return [] }
        let group = (json["title"] as? String) ?? name
        let list = (json["commands"] as? [[String: Any]]) ?? []
        return list.compactMap { entry in
            guard let command = entry["name"] as? String, !command.isEmpty else { return nil }
            let title = (entry["title"] as? String) ?? command
            return RaycastCommand(owner: owner, extensionName: name, command: command, title: title, group: group)
        }
    }

    /// Raycast's own commands people put on keys most. Raycast publishes no full list, so anything
    /// else comes in through "Copy Deeplink" in Raycast.
    public static let builtIn: [RaycastCommand] = [
        own("clipboard-history", "clipboard-history", "Clipboard History"),
        own("snippets", "search-snippets", "Search Snippets"),
        own("quicklinks", "search-quicklinks", "Search Quicklinks"),
        own("ai", "ai-chat", "AI Chat"),
        own("raycast-notes", "raycast-notes", "Raycast Notes"),
        own("file-search", "search-files", "Search Files"),
        own("emoji-symbols", "search-emoji-symbols", "Search Emoji and Symbols"),
        own("calendar", "my-schedule", "My Schedule"),
        own("window-management", "left-half", "Window: Left Half"),
        own("window-management", "right-half", "Window: Right Half"),
        own("window-management", "maximize", "Window: Maximize"),
        own("window-management", "center", "Window: Center"),
        own("window-management", "next-display", "Window: Next Display"),
        own("system", "lock-screen", "Lock Screen"),
        own("system", "toggle-system-appearance", "Switch Day and Night"),
        own("system", "show-desktop", "Show Desktop"),
    ]

    private static func own(_ ext: String, _ command: String, _ title: String) -> RaycastCommand {
        RaycastCommand(owner: "raycast", extensionName: ext, command: command, title: title, group: "Raycast")
    }
}
