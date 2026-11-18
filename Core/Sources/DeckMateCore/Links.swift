import Foundation

// The 0.15 rules for reaching the keys from outside: links that press a key ("amsdeckmate://…"),
// the small commands Raycast lists for them, and what a thing dropped on an empty key becomes.

/// Links other apps can open to press a key. Every link carries this Mac's own pass (a random word
/// made at the first start): a link without it, from a web page or another program, does nothing.
public enum DeckLinks {
    public static let scheme = "amsdeckmate"

    public enum Command: Equatable, Sendable {
        /// Press a key, found by its id or by its words; `long` = hold it.
        case press(key: String, long: Bool)
        /// Show a page group, found by its id or its name.
        case show(group: String)
        /// Show or hide the keys on screen.
        case toggleKeys
    }

    /// What a link asks for; nil when it is not a Deck Mate link, says something unknown, or
    /// does not carry the right pass.
    public static func command(from url: URL, pass: String) -> Command? {
        guard url.scheme?.lowercased() == scheme, !pass.isEmpty,
              let parts = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        var said: [String: String] = [:]
        for item in parts.queryItems ?? [] where said[item.name] == nil { said[item.name] = item.value ?? "" }
        guard said["pass"] == pass else { return nil }
        switch (parts.host ?? "").lowercased() {
        case "press":
            guard let key = said["key"], !key.isEmpty else { return nil }
            return .press(key: key, long: said["hold"] == "1")
        case "show":
            guard let group = said["group"], !group.isEmpty else { return nil }
            return .show(group: group)
        case "keys":
            return .toggleKeys
        default:
            return nil
        }
    }

    /// "amsdeckmate://press?key=<id>&pass=<pass>"
    public static func pressLink(id: UUID, pass: String) -> String {
        "\(scheme)://press?key=\(id.uuidString)&pass=\(pass)"
    }

    public struct Found: Equatable, Sendable {
        public var position: DeckPosition
        public var index: Int
        public var key: DeckKey
    }

    /// The key a link means: by its id, or by its words (large and small letters count the same).
    /// The page group `first` is looked through before the others, then the pages in their order.
    public static func find(_ wanted: String, in deck: Deck, first: UUID? = nil, name: (DeckKey) -> String) -> Found? {
        let id = UUID(uuidString: wanted)
        let words = wanted.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let groups = deck.profiles.filter { $0.id == first } + deck.profiles.filter { $0.id != first }
        for group in groups {
            for page in group.pages {
                for index in page.keys.keys.sorted() {
                    guard let key = page.keys[index], key.action.type != .none else { continue }
                    let hit = id.map { $0 == key.id } ?? (name(key).lowercased() == words)
                    guard hit, let position = Navigator.go(profile: group.id.uuidString, page: page.id.uuidString, in: deck) else { continue }
                    return Found(position: position, index: index, key: key)
                }
            }
        }
        return nil
    }

    /// The page group a link means, by its id or its name.
    public static func group(_ wanted: String, in deck: Deck) -> DeckProfile? {
        if let id = UUID(uuidString: wanted), let group = deck.profile(id) { return group }
        let words = wanted.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return deck.profiles.first { $0.name.lowercased() == words }
    }

    /// Kinds of key that make no sense from outside: they only move around the keys, or are not keys at all.
    public static let notFromOutside: Set<ActionType> = [.none, .folder, .back, .nextPage, .previousPage, .wait, .weatherTown, .zero]

    /// The commands Raycast lists: one small script for every key that does something and has words,
    /// by file name. `name` gives a key's words (its own, the app's name, or what it does); a key
    /// without any is left out.
    public static func scripts(for deck: Deck, pass: String, name: (DeckKey) -> String) -> [String: String] {
        var all: [String: String] = [:]
        for group in deck.profiles {
            for page in group.pages {
                for index in page.keys.keys.sorted() {
                    guard let key = page.keys[index], !notFromOutside.contains(key.action.type) else { continue }
                    let title = oneLine(name(key))
                    guard !title.isEmpty else { continue }
                    let place = [group.name, page.name].map(oneLine).filter { !$0.isEmpty }.joined(separator: " › ")
                    all["deck-\(key.id.uuidString.lowercased()).sh"] = """
                    #!/bin/bash

                    # Made by AMS Deck Mate, and written again whenever your keys change.
                    # @raycast.schemaVersion 1
                    # @raycast.title \(title)
                    # @raycast.mode silent
                    # @raycast.packageName Deck Mate\(place.isEmpty ? "" : " · " + place)
                    # @raycast.icon deck-mate.png

                    open -g "\(pressLink(id: key.id, pass: pass))"

                    """
                }
            }
        }
        return all
    }

    /// Words on one line, without anything a script's comment line could trip over.
    static func oneLine(_ text: String) -> String {
        text.split(whereSeparator: \.isNewline).joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }

    /// True for a key that asks before it acts when the press comes from a link, also when the key
    /// itself is set to "without asking": quit all apps, empty the bin, eject all disks.
    public static func asksFirst(_ action: DeckAction) -> Bool {
        guard action.type == .macDo else { return action.steps.contains(where: asksFirst) && action.type == .multi }
        switch MacDoKeys.what(action.target) {
        case .quitAll, .emptyBin, .ejectAll: return true
        default: return false
        }
    }
}

/// What a thing dropped on an empty key becomes: an app key, a file or folder key, or a link key.
public enum Drops {
    /// A file, a folder or an app dragged in from the Finder. `bundleID` = the app's own name for
    /// itself, when it is an app.
    public static func key(forFile path: String, bundleID: String?) -> DeckKey {
        if path.hasSuffix(".app") {
            // An app key shows the app's icon and name by itself.
            return DeckKey(action: DeckAction(type: .app, target: bundleID ?? path))
        }
        let name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension
        return DeckKey(title: name, action: DeckAction(type: .link, target: path))
    }

    /// A web address (or another link) dragged in from a browser or as text; nil when the text is no link.
    public static func key(forLink text: String) -> DeckKey? {
        let link = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !link.isEmpty, !link.contains(" "), !link.contains("\n"), link.contains("://"),
              let url = URL(string: link), let scheme = url.scheme, !scheme.isEmpty else { return nil }
        var name = url.host ?? ""
        if name.hasPrefix("www.") { name.removeFirst(4) }
        return DeckKey(title: name, action: DeckAction(type: .link, target: link))
    }
}

extension DeckAction {
    /// The same action, but one that asks first even when the key says "without asking" (a press
    /// that came in by a link).
    public var askingFirst: DeckAction {
        var action = self
        if action.type == .macDo { action.quiet = false }
        if action.type == .multi { action.steps = action.steps.map(\.askingFirst) }
        return action
    }
}
