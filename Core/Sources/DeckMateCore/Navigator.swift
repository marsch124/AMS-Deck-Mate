import Foundation

/// Where the deck is right now: which profile, which page, and the pages to go back through.
public struct DeckPosition: Equatable, Sendable {
    public var profile: UUID
    public var page: UUID
    public var trail: [UUID]

    public init(profile: UUID, page: UUID, trail: [UUID] = []) {
        self.profile = profile
        self.page = page
        self.trail = trail
    }
}

/// The rules for moving around the deck. No hardware, no screen: only the setup in, the answer out.
public enum Navigator {
    public struct Outcome: Equatable, Sendable {
        public var position: DeckPosition
        /// The things to do on the Mac, in order (open an app, run a Raycast command ...).
        public var run: [DeckAction]
    }

    /// The first page of a profile; the default profile when `id` is nil or gone.
    public static func start(in deck: Deck, profile id: UUID? = nil) -> DeckPosition? {
        guard let profile = id.flatMap({ deck.profile($0) }) ?? deck.fallbackProfile,
              let first = profile.topPages.first ?? profile.pages.first else { return nil }
        return DeckPosition(profile: profile.id, page: first.id)
    }

    /// A position that still exists after the setup changed; otherwise the nearest one that does.
    public static func repair(_ position: DeckPosition?, in deck: Deck) -> DeckPosition? {
        guard let position, let profile = deck.profile(position.profile) else { return start(in: deck) }
        guard profile.page(position.page) != nil else { return start(in: deck, profile: profile.id) }
        var fixed = position
        fixed.trail = position.trail.filter { profile.page($0) != nil }
        return fixed
    }

    /// "Several pages at once" (an iPhone or iPad used without the box): the page at `position`
    /// first, then the next top pages of its page group in their order, going round to the start,
    /// then its folders, until `count` pages show. A folder counts from the top page it sits in
    /// (that top page itself is then not shown again).
    public static func spread(at position: DeckPosition, count: Int, in deck: Deck) -> [DeckPosition] {
        guard count > 1, let profile = deck.profile(position.profile), profile.page(position.page) != nil else {
            return [position]
        }
        var top = position.page
        var seen: Set<UUID> = [top]
        while let parent = profile.page(top)?.parent, profile.page(parent) != nil, !seen.contains(parent) {
            seen.insert(parent)
            top = parent
        }
        let tops = profile.topPages
        guard let at = tops.firstIndex(where: { $0.id == top }) else { return [position] }
        var shown = [position]
        for step in 1..<tops.count where shown.count < count {
            shown.append(DeckPosition(profile: profile.id, page: tops[(at + step) % tops.count].id))
        }
        // Fewer top pages than places (his pick, 0.19.1): the page group's folders fill the rest, in
        // their order. A folder shown this way remembers its page, so its Back key goes there.
        for page in profile.pages where shown.count < count {
            guard let parent = page.parent, !shown.contains(where: { $0.page == page.id }) else { continue }
            shown.append(DeckPosition(profile: profile.id, page: page.id, trail: [parent]))
        }
        return shown
    }

    /// The keys showing at a position, by place.
    public static func keys(at position: DeckPosition, in deck: Deck) -> [Int: DeckKey] {
        deck.profile(position.profile)?.page(position.page)?.keys ?? [:]
    }

    /// A key was pressed: where the deck is afterwards, and what to do on the Mac.
    /// `long` = held for half a second: the key's long-press action, when it has one.
    public static func press(_ index: Int, at position: DeckPosition, in deck: Deck, long: Bool = false) -> Outcome {
        var outcome = Outcome(position: position, run: [])
        guard let key = keys(at: position, in: deck)[index] else { return outcome }
        apply(key.action(long: long), to: &outcome, in: deck, depth: 0)
        return outcome
    }

    /// A key of the favourites row was pressed. It acts from wherever the deck is.
    public static func pressFavourite(_ index: Int, at position: DeckPosition, in deck: Deck, long: Bool = false) -> Outcome {
        var outcome = Outcome(position: position, run: [])
        guard let key = deck.favourites[index] else { return outcome }
        let action = key.action(long: long)
        guard action.type.fitsFavourite else { return outcome }
        apply(action, to: &outcome, in: deck, depth: 0)
        return outcome
    }

    /// A page of the navigation picture was tapped: that page of that page group. An unknown page
    /// group or page changes nothing (nil).
    public static func go(profile: String, page: String, in deck: Deck) -> DeckPosition? {
        guard let group = UUID(uuidString: profile).flatMap({ deck.profile($0) }),
              let target = UUID(uuidString: page).flatMap({ group.page($0) }) else { return nil }
        // A folder is entered from the page it opens from, so Back leads there.
        var trail: [UUID] = []
        var at = target.parent
        var steps = 0
        while let id = at, let parent = group.page(id), steps < 50 { trail.insert(parent.id, at: 0); at = parent.parent; steps += 1 }
        return DeckPosition(profile: group.id, page: target.id, trail: trail)
    }

    /// Half a second: from then on a press is a long press.
    public static let longPress = 0.5

    public static func isLong(_ seconds: Double) -> Bool { seconds >= longPress }

    /// "My own keys" on an iPhone: its own place in the profile it picked. It keeps its place while
    /// it stays in that profile; a profile that is gone gives the default profile. nil = follow the Mac.
    public static func own(profile id: String?, was: DeckPosition?, in deck: Deck) -> DeckPosition? {
        guard let id else { return nil }
        let wanted = UUID(uuidString: id).flatMap { deck.profile($0) } ?? deck.fallbackProfile
        guard let wanted else { return nil }
        if let was, was.profile == wanted.id, let kept = repair(was, in: deck), kept.profile == wanted.id { return kept }
        return start(in: deck, profile: wanted.id)
    }

    private static func apply(_ action: DeckAction, to outcome: inout Outcome, in deck: Deck, depth: Int) {
        guard let profile = deck.profile(outcome.position.profile) else { return }
        switch action.type {
        case .none:
            break
        case .folder:
            guard let id = UUID(uuidString: action.target), profile.page(id) != nil,
                  id != outcome.position.page else { return }
            outcome.position.trail.append(outcome.position.page)
            outcome.position.page = id
        case .back:
            if let last = outcome.position.trail.popLast(), profile.page(last) != nil {
                outcome.position.page = last
            } else if let home = profile.topPages.first {
                outcome.position.page = home.id
                outcome.position.trail = []
            }
        case .nextPage, .previousPage:
            let tops = profile.topPages
            guard tops.count > 1, let at = tops.firstIndex(where: { $0.id == outcome.position.page }) else { return }
            let step = action.type == .nextPage ? 1 : tops.count - 1
            outcome.position.page = tops[(at + step) % tops.count].id
            outcome.position.trail = []
        case .profile:
            if let id = UUID(uuidString: action.target), deck.profile(id) != nil,
               let start = start(in: deck, profile: id) {
                outcome.position = start
            }
        case .multi:
            guard depth < 4 else { return }
            for step in action.steps { apply(step, to: &outcome, in: deck, depth: depth + 1) }
        case .micLight, .bar:
            break       // it only shows something
        case .app, .link, .raycast, .shortcut, .text, .media, .recent, .askAI, .copied, .recentFile,
             .timer, .toggle, .appleShortcut, .list, .running, .wait,
             .nextEvent, .weather, .dueToday, .cover, .bodyBattery, .desk, .weatherTown,
             .garmin, .macNow, .worldClock, .sunTimes, .freeUntil,
             .macDo, .joinMeeting, .playlist, .searchCopied, .counter, .stopwatch, .zero, .paragon, .focus, .breath, .often:
            outcome.run.append(action)
        }
    }

    /// The profile that belongs to an app: the first one that lists it, else the default profile.
    /// With `now` (minutes since midnight), an app without a profile of its own gets the first profile
    /// whose hours include `now` instead of the default one; without `now`, or with no such profile,
    /// nothing changes.
    public static func profile(forApp bundleID: String?, in deck: Deck, now: Int? = nil) -> UUID? {
        if let bundleID, !bundleID.isEmpty,
           let own = deck.profiles.first(where: { $0.apps.contains(bundleID) }) {
            return own.id
        }
        if let now, let timed = deck.profiles.first(where: { $0.hoursOn && DayMinutes.within(now, from: $0.hoursFrom, to: $0.hoursTo) }) {
            return timed.id
        }
        return deck.fallbackProfile?.id
    }

    /// Another app came to the front. The deck changes profile only when the new app belongs to a
    /// different profile than the app before it, so a profile picked by hand stays while he moves
    /// between apps that share one.
    public static func follow(app: String?, previousApp: String?, at position: DeckPosition?,
                              in deck: Deck, now: Int? = nil) -> DeckPosition? {
        guard let position = repair(position, in: deck) else { return start(in: deck) }
        guard deck.autoSwitch else { return position }
        let wanted = profile(forApp: app, in: deck, now: now)
        let before = profile(forApp: previousApp, in: deck, now: now)
        guard let wanted, wanted != before, wanted != position.profile else { return position }
        return start(in: deck, profile: wanted) ?? position
    }
}
