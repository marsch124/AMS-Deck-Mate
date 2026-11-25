import Foundation

/// Fan keys (0.18): switch keys that ask AMS Fan Menu, his other Mac app, for one of its choices and
/// show which choice is on. Deck Mate never touches the fans itself.
///
/// A fan key is a switch key whose target is "fan:<choice>", the choice in Fan Menu's own word.
/// Unlike the other switches a press never switches it off: it asks for its choice, every time.
/// Cool and Full are asked for ten minutes (0.19); Fan Menu then goes back to Automatic by itself.
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

    /// Cool and Full last ten minutes, then AMS Fan Menu gives the fans back to the Mac and its choice
    /// goes to Automatic (his ask, 0.19). Automatic has no time.
    public static let minutes = 10
    public static func seconds(for choice: String) -> Int? {
        choice == "cool" || choice == "full" ? minutes * 60 : nil
    }

    /// What a press asks AMS Fan Menu for: the choice word, with its time in seconds behind a colon
    /// when it has one ("automatic", "cool:600"). Fan Menu 0.3.1 or later understands the time.
    public static func wish(_ choice: String) -> String {
        seconds(for: choice).map { "\(choice):\($0)" } ?? choice
    }

    /// The words on the key: "Automatic", "Cool 10 min", "Full 10 min" — the key itself says how long.
    public static func keyWords(_ choice: String) -> String {
        seconds(for: choice) == nil ? words(choice) : "\(words(choice)) \(minutes) min"
    }

    /// What is left of the timed choice that is on, from the bytes of Fan Menu's state file (`endsAt`,
    /// seconds since 1970): whole minutes, rounded up, as Fan Menu itself says them; 0 = under a minute.
    /// nil = no end (set in Fan Menu with "Until I change"), no file, or an end that passed a while ago.
    public static func minutesLeft(state data: Data?, now: Double) -> Int? {
        struct State: Decodable { var choice: String; var endsAt: Double? }
        guard let data, let state = try? JSONDecoder().decode(State.self, from: data),
              let endsAt = state.endsAt else { return nil }
        let left = endsAt - now
        if left <= -5 { return nil }
        return left <= 60 ? 0 : Int((left / 60).rounded(.up))
    }

    /// The words on a fan key. Off: what a press gives ("Cool 10 min"). On with an end: what is left
    /// ("Cool · 8 min", "Cool · <1 min"). On without an end: the choice alone ("Cool").
    public static func keyWords(_ choice: String, isOn: Bool, left: Int?) -> String {
        guard isOn, seconds(for: choice) != nil || left != nil else { return keyWords(choice) }
        guard let left else { return words(choice) }
        return left == 0 ? "\(words(choice)) · <1 min" : "\(words(choice)) · \(left) min"
    }

    /// In lists and notes: "Automatic", "Cool for 10 minutes".
    public static func longWords(_ choice: String) -> String {
        seconds(for: choice) == nil ? words(choice) : "\(words(choice)) for \(minutes) minutes"
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
