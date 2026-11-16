import Foundation

/// The apps used last, newest first, for the "Recent app" keys. The first one is the app in front.
public enum RecentApps {
    /// How many are kept: the one in front plus three before it.
    public static let kept = 4

    /// The list after `app` came to the front. Deck Mate's own windows (`skip`) never count.
    public static func after(_ list: [String], front app: String?, skip: String) -> [String] {
        guard let app, !app.isEmpty, app != skip else { return list }
        return Array(([app] + list.filter { $0 != app }).prefix(kept))
    }

    /// The app a "Recent app" key with this number (1 = the one just before the app in front) opens; nil = none yet.
    public static func app(number: Int, in list: [String]) -> String? {
        let before = Array(list.dropFirst())
        guard number >= 1, number <= before.count else { return nil }
        return before[number - 1]
    }

    /// "1"–"3" from a key's target; anything else counts as 1.
    public static func number(_ target: String) -> Int { min(3, max(1, Int(target) ?? 1)) }
}

extension DeckAction {
    /// A "Recent app" action becomes an app action for the app it stands for now (unchanged while
    /// there is none yet). Every other action stays as it is.
    public func resolvingRecent(_ list: [String]) -> DeckAction {
        guard type == .recent, let app = RecentApps.app(number: RecentApps.number(target), in: list) else { return self }
        return DeckAction(type: .app, target: app)
    }
}

extension DeckKey {
    /// The key as it shows now: a "Recent app" key turns into the app it stands for, with the app's
    /// own icon and name. Before there is one it shows its clock drawing and "Recent".
    public func resolvingRecent(_ list: [String]) -> DeckKey {
        guard action.type == .recent || held?.type == .recent else { return self }
        var key = self
        let now = action.resolvingRecent(list)
        if action.type == .recent {
            if now.type == .app { key.title = ""; key.icon = "" } else if key.title.isEmpty { key.title = "Recent" }
        }
        key.action = now
        key.held = held?.resolvingRecent(list)
        return key
    }
}

extension RaycastLink {
    /// Raycast's AI Chat, the link an "Ask AI" key opens when no other is set.
    public static let aiChat = "raycast://extensions/raycast/ai/ai-chat"
    /// The longest copied text an "Ask AI" key hands over.
    public static let longestAsk = 4000

    /// The link that opens AI Chat (or `link`) with the copied text filled in. Nothing copied = the bare link.
    public static func ask(_ copied: String?, link: String = "") -> String {
        let base = link.trimmingCharacters(in: .whitespaces).isEmpty ? aiChat : link
        let text = (copied ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return base }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+?#")
        let encoded = String(text.prefix(longestAsk)).addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        return base + (base.contains("?") ? "&" : "?") + "fallbackText=" + encoded
    }
}
