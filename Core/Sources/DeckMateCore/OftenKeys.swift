import Foundation

/// "Often used" keys: the n-th most pressed key of the last 30 days (target "1" to "5").
public enum OftenKeys {
    public static let count = 5
    public static let notYet = "Not yet"

    /// Keys that move around, only show something, or are an often key themselves never count.
    static let skip: Set<ActionType> = [.none, .folder, .back, .nextPage, .previousPage, .profile, .micLight,
                                        .bar, .often, .wait, .weatherTown, .zero]

    /// The place of an often key in the list: 1 to 5; anything odd counts as 1.
    public static func number(_ target: String) -> Int {
        min(count, max(1, Int(target.trimmingCharacters(in: .whitespaces)) ?? 1))
    }

    /// The keys that do something on the Mac, pressed in the last 30 days, most pressed first (a tie:
    /// the one pressed last first). Looks at every page of every page group and at the favourites.
    public static func ranked(in deck: Deck, use: KeyUse, now: Date) -> [DeckKey] {
        let edge = now.addingTimeInterval(-Double(KeyUse.quietDays) * 86_400)
        var all: [DeckKey] = []
        for profile in deck.profiles { for page in profile.pages { all += page.keys.keys.sorted().compactMap { page.keys[$0] } } }
        all += deck.favourites.keys.sorted().compactMap { deck.favourites[$0] }
        let found = all.compactMap { key -> (DeckKey, KeyUse.Entry)? in
            guard !skip.contains(key.action.type), let entry = use.presses[key.id.uuidString],
                  entry.count > 0, entry.last >= edge else { return nil }
            return (key, entry)
        }
        return found.sorted { ($0.1.count, $0.1.last) > ($1.1.count, $1.1.last) }.map(\.0)
    }

    /// The key an often key with this target stands for right now; nil = not enough presses yet.
    public static func key(number target: String, in deck: Deck, use: KeyUse, now: Date) -> DeckKey? {
        let list = ranked(in: deck, use: use, now: now)
        let at = number(target) - 1
        return at < list.count ? list[at] : nil
    }

    /// The key as it shows: an often key takes the picture and the words of the key it stands for;
    /// without one it keeps its drawing and says "Not yet". Every other key stays as it is.
    /// `stands` = the key it stands for, already as it shows (its own live words).
    public static func showing(_ key: DeckKey, stands: DeckKey?) -> DeckKey {
        guard key.action.type == .often else { return key }
        guard var real = stands else {
            var idle = key
            if idle.title.isEmpty { idle.title = notYet }
            return idle
        }
        real.id = key.id
        real.held = nil
        real.twice = nil
        return real
    }

    /// The key a press should be counted for: the key itself, or for an often key the key it stands
    /// for (nil = it stands for none yet, so nothing is counted).
    public static func counted(_ key: DeckKey, long: Bool, in deck: Deck, use: KeyUse, now: Date) -> DeckKey? {
        guard key.action(long: long).type == .often else { return key }
        return Self.key(number: key.action.target, in: deck, use: use, now: now)
    }

    /// A folder that shows the keys pressed most: a Back key, then "Often used" 1 to 5.
    public static func folder(parent: UUID) -> DeckPage {
        var page = DeckPage(name: "Often used", parent: parent)
        page.keys[0] = DeckKey(title: "Back", action: DeckAction(type: .back))
        for number in 1...count {
            page.keys[number] = DeckKey(action: DeckAction(type: .often, target: String(number)))
        }
        return page
    }
}
