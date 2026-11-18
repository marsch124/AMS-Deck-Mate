import Foundation

// The 0.16 rules for making keys easier: saying wrong input at once, a key from what he has in front
// of him, and the deck suggesting a key for an app he uses a lot.

/// What the text of an "Open a link or a file" key is.
public enum LinkText {
    public enum Kind: Equatable, Sendable {
        case empty
        /// A file or a folder (starts with / or ~).
        case file
        /// A link that says where it goes (https://…, mailto:…).
        case link
        /// A bare name like "example.com": it becomes this address when pressed.
        case bare(String)
        /// Neither a file nor usable as an address.
        case bad
    }

    public static func kind(_ text: String) -> Kind {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return .empty }
        if t.hasPrefix("/") || t.hasPrefix("~") { return .file }
        if t.rangeOfCharacter(from: .whitespacesAndNewlines) != nil { return .bad }
        if t.contains("://") {
            guard let url = URL(string: t), let scheme = url.scheme, !scheme.isEmpty,
                  !t.hasSuffix("://") else { return .bad }
            return .link
        }
        if t.lowercased().hasPrefix("mailto:") { return t.count > 7 ? .link : .bad }
        // A bare name needs a dot with letters or numbers on both sides ("example.com"), or "localhost".
        let host = t.split(separator: "/", maxSplits: 1).first.map(String.init) ?? t
        let ok = host.lowercased() == "localhost" || {
            let bits = host.split(separator: ".", omittingEmptySubsequences: false)
            return bits.count >= 2 && bits.allSatisfy { !$0.isEmpty && $0.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" || $0 == ":" } }
                && (bits.last?.count ?? 0) >= 2
        }()
        return ok && URL(string: "https://" + t) != nil ? .bare("https://" + t) : .bad
    }

    /// The red line for a link key whose text is neither a file nor an address.
    public static let badWords = "This is not a web address or a file. It has a space or is not an address."
}

/// The days each app came to the front, for the last 14 days ("apps.json").
public struct AppDays: Codable, Equatable, Sendable {
    public static let window = 14
    public static let atLeast = 5

    /// By app (bundle identifier): the days, as "2026-11-18".
    public var days: [String: [String]]
    /// Apps he said "Not this one" to.
    public var declined: [String]

    public init(days: [String: [String]] = [:], declined: [String] = []) {
        self.days = days
        self.declined = declined
    }

    public static func day(_ date: Date, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// An app came to the front. Days older than 14 are forgotten.
    public mutating func record(_ app: String, now: Date, calendar: Calendar = .current) {
        guard !app.isEmpty else { return }
        let today = AppDays.day(now, calendar: calendar)
        var list = days[app] ?? []
        if !list.contains(today) { list.append(today) }
        days[app] = list
        prune(now: now, calendar: calendar)
    }

    public mutating func prune(now: Date, calendar: Calendar = .current) {
        let keep = Set(recentDays(now: now, calendar: calendar))
        for (app, list) in days {
            let kept = list.filter(keep.contains)
            days[app] = kept.isEmpty ? nil : kept
        }
    }

    /// Today and the 13 days before, as text.
    func recentDays(now: Date, calendar: Calendar) -> [String] {
        (0..<AppDays.window).compactMap { calendar.date(byAdding: .day, value: -$0, to: now) }.map { AppDays.day($0, calendar: calendar) }
    }

    /// On how many of the last 14 days the app came to the front.
    public func count(_ app: String, now: Date, calendar: Calendar = .current) -> Int {
        let recent = Set(recentDays(now: now, calendar: calendar))
        return (days[app] ?? []).filter(recent.contains).count
    }

    public struct Suggestion: Equatable, Sendable {
        public var app: String
        public var days: Int
    }

    /// The one app to suggest: used on the most days (at least 5 of 14), with no key anywhere, not
    /// Deck Mate or the Finder, not turned down. Ties go to the app whose name sorts first.
    public func suggestion(in deck: Deck, now: Date, never: [String] = ["com.apple.finder"], calendar: Calendar = .current) -> Suggestion? {
        let has = AppDays.appsWithKeys(in: deck)
        let skip = Set(never + declined + ["com.schabbauer.AMSDeckMate"])
        let counted = days.keys.filter { !has.contains($0) && !skip.contains($0) }
            .map { Suggestion(app: $0, days: count($0, now: now, calendar: calendar)) }
            .filter { $0.days >= AppDays.atLeast }
        return counted.sorted { ($0.days, $1.app) > ($1.days, $0.app) }.first
    }

    /// Every app that has a key: an app key (also inside steps, lists and long presses), a favourite,
    /// or a page group that belongs to it.
    public static func appsWithKeys(in deck: Deck) -> Set<String> {
        var found = Set<String>()
        func look(_ action: DeckAction) {
            if action.type == .app, !action.target.isEmpty { found.insert(action.target) }
            for step in action.steps { look(step) }
        }
        func look(_ key: DeckKey) {
            look(key.action)
            if let held = key.held { look(held) }
        }
        for profile in deck.profiles {
            found.formUnion(profile.apps)
            for page in profile.pages { page.keys.values.forEach { look($0) } }
        }
        deck.favourites.values.forEach { look($0) }
        return found
    }
}

extension Deck {
    /// Puts a key on the first empty place of a page. Answers the place; nil (and nothing changes)
    /// when the page is full or is not there. A key already on the page never moves.
    @discardableResult
    public mutating func addKey(_ key: DeckKey, to page: UUID, in profile: UUID) -> Int? {
        guard let p = profiles.firstIndex(where: { $0.id == profile }),
              let g = profiles[p].pages.firstIndex(where: { $0.id == page }),
              let place = profiles[p].pages[g].firstFreePlace else { return nil }
        profiles[p].pages[g].keys[place] = key
        return place
    }
}

/// What the menu "New key from…" offers.
public enum KeyFrom {
    /// A web address copied as text; nil when the text is no web address (or is long or has spaces).
    public static func copiedLink(_ text: String?) -> DeckKey? {
        guard let text else { return nil }
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.lowercased().hasPrefix("http://") || t.lowercased().hasPrefix("https://") else { return nil }
        return Drops.key(forLink: t)
    }
}
