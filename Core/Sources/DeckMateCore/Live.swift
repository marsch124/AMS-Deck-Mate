import Foundation

/// What the keys that change by themselves stand for right now.
public struct LiveKeys: Equatable, Sendable {
    /// The apps used last, newest first (the app in front first).
    public var apps: [String]
    /// The texts copied last, newest first (the current one first).
    public var copied: [String]
    /// The files opened last, newest first, as full paths.
    public var files: [String]

    public init(apps: [String] = [], copied: [String] = [], files: [String] = []) {
        self.apps = apps
        self.copied = copied
        self.files = files
    }
}

/// The texts copied last, for the "Last copied text" keys. Kept in memory only.
public enum CopiedTexts {
    /// How many are kept: the current one plus three before it.
    public static let kept = 4
    /// A longer text is not kept.
    public static let longest = 100_000

    /// The list after `text` was copied. Nothing, only spaces, or far too long = unchanged.
    public static func after(_ list: [String], copied text: String?) -> [String] {
        guard let text, text.count <= longest,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return list }
        return Array(([text] + list.filter { $0 != text }).prefix(kept))
    }

    /// The text a key with this number pastes (1 = the one copied just before the current one); nil = none yet.
    public static func text(number: Int, in list: [String]) -> String? {
        let before = Array(list.dropFirst())
        guard number >= 1, number <= before.count else { return nil }
        return before[number - 1]
    }

    /// The first words of a text, for the key: one line, at most 18 letters.
    public static func preview(_ text: String) -> String {
        let line = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return line.count > 18 ? line.prefix(17).trimmingCharacters(in: .whitespaces) + "…" : line
    }
}

/// The files opened last, for the "Recent file" keys.
public enum RecentFiles {
    public static let kept = 3

    /// The files to offer, from the Mac's list of files used last (newest first): only files inside
    /// the home folder, none from its Library, no hidden ones, no apps, each once.
    public static func pick(_ paths: [String], home: String) -> [String] {
        let root = home.hasSuffix("/") ? home : home + "/"
        var seen = Set<String>()
        var found: [String] = []
        for path in paths where path.hasPrefix(root) {
            let parts = path.dropFirst(root.count).split(separator: "/")
            guard let name = parts.last, parts.first != "Library",
                  !parts.contains(where: { $0.hasPrefix(".") || $0.hasSuffix(".app") }),
                  !name.isEmpty, seen.insert(path).inserted else { continue }
            found.append(path)
            if found.count == kept { break }
        }
        return found
    }

    /// The file a key with this number opens (1 = the one opened last); nil = none yet.
    public static func file(number: Int, in list: [String]) -> String? {
        guard number >= 1, number <= list.count else { return nil }
        return list[number - 1]
    }
}

extension DeckAction {
    /// The action as it stands right now: a "Recent app" action becomes its app, a "Recent file"
    /// action becomes its file. Everything else stays as it is.
    public func resolving(_ live: LiveKeys) -> DeckAction {
        switch type {
        case .recent:
            return resolvingRecent(live.apps)
        case .recentFile:
            guard let file = RecentFiles.file(number: RecentApps.number(target), in: live.files) else { return self }
            return DeckAction(type: .link, target: file)
        default:
            return self
        }
    }
}

extension DeckKey {
    /// The key as it shows now: a "Recent app" key shows its app, a "Recent file" key its file's
    /// name, a "Last copied text" key the first words of its text.
    public func resolving(_ live: LiveKeys) -> DeckKey {
        var key = resolvingRecent(live.apps)
        switch key.action.type {
        case .recentFile:
            let now = key.action.resolving(live)
            if key.title.isEmpty {
                key.title = now.type == .link ? (now.target as NSString).lastPathComponent : "Recent file"
            }
            key.action = now
        case .copied:
            if key.title.isEmpty {
                let text = CopiedTexts.text(number: RecentApps.number(key.action.target), in: live.copied)
                key.title = text.map(CopiedTexts.preview) ?? "Nothing copied"
            }
        default:
            break
        }
        if let held = key.held, held.type == .recentFile { key.held = held.resolving(live) }
        return key
    }
}

extension Deck {
    /// True when any key (also a long press, a step, or a favourite) does this kind of thing.
    public func uses(_ type: ActionType) -> Bool {
        func has(_ action: DeckAction?) -> Bool {
            guard let action else { return false }
            return action.type == type || action.steps.contains { has($0) }
        }
        let keys = profiles.flatMap { $0.pages.flatMap { $0.keys.values } } + Array(favourites.values)
        return keys.contains { has($0.action) || has($0.held) }
    }
}

extension PhoneLink {
    /// The note the iPhone shows when the Mac's screen wakes: only when it was asleep before.
    public static func wakeNote(wasAsleep: Bool, asleep: Bool) -> String? {
        wasAsleep && !asleep ? "Mac is back" : nil
    }
}
