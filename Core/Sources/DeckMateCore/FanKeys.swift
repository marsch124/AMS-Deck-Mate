import Foundation

/// Fan keys (0.18): switch keys that ask AMS Fan Menu, his other Mac app, for one of its choices and
/// show which choice is on. Deck Mate never touches the fans itself.
///
/// A fan key is a switch key whose target is "fan:<choice>", the choice in Fan Menu's own word.
/// Unlike the other switches a press never switches it off: it asks for its choice, every time.
public enum FanKeys {
    public static let prefix = "fan:"
    /// The choices offered in "Set up keys", in Fan Menu's own words.
    public static let choices = ["automatic", "cool", "full"]

    /// AMS Fan Menu: its bundle identifier, the notification it hears a wish on (the choice word is
    /// the notification's object), the one it sends after every change, and the file it writes then
    /// (inside the home folder).
    public static let app = "com.schabbauer.AMSFanMenu"
    public static let ask = "com.schabbauer.AMSFanMenu.choose"
    public static let changed = "com.schabbauer.AMSFanMenu.changed"
    public static let stateFile = "Library/Application Support/AMS Fan Menu/state.json"

    public static func target(_ choice: String) -> String { prefix + choice }
    public static func isFan(_ target: String) -> Bool { choice(of: target) != nil }

    /// The choice a fan key asks for; nil for any other switch (and for "fan:" with nothing behind it).
    public static func choice(of target: String) -> String? {
        guard target.hasPrefix(prefix) else { return nil }
        let word = String(target.dropFirst(prefix.count))
        return word.isEmpty || word.contains(where: { !$0.isLetter }) ? nil : word
    }

    /// The words for a choice: "Automatic", "Cool", "Full" (Fan Menu's "mySpeed" becomes "My speed").
    public static func words(_ choice: String) -> String {
        switch choice {
        case "mySpeed": return "My speed"
        case "follow": return "Follow"
        default: return choice.prefix(1).uppercased() + choice.dropFirst()
        }
    }

    /// The switch that is on, from the bytes of Fan Menu's state file: "fan:cool". nil when the file
    /// is missing or cannot be read, so no fan key is lit.
    public static func on(state data: Data?) -> String? {
        struct State: Decodable { var choice: String }
        guard let data, let state = try? JSONDecoder().decode(State.self, from: data),
              choice(of: target(state.choice)) != nil else { return nil }
        return target(state.choice)
    }
}
