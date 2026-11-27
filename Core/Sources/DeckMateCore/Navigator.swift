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
    ///
    /// His own places (0.19): a page he put into a place in "Set up keys" always shows there. Going to
    /// one of them moves nothing. The places he left empty are filled as above, starting with the page
    /// at `position`. When every place is taken and `position` is none of them, it shows in place 1
    /// for the moment.
    public static func spread(at position: DeckPosition, count: Int, in deck: Deck) -> [DeckPosition] {
        guard count > 1, let profile = deck.profile(position.profile), profile.page(position.page) != nil else {
            return [position]
        }
        // Hubs (0.26): once his keys have a start screen, every other page group is an app's page and
        // shows one page at a time, with the biggest keys.
        if !profile.hub, !deck.hubs.isEmpty { return [position] }
        let free = freeSpread(at: position, count: count + DeckProfile.placeCount, in: profile)
        guard profile.hasPlaces else { return Array(free.prefix(count)) }
        var shown: [DeckPosition?] = (0..<count).map { place in
            guard place < profile.places.count, let id = profile.places[place], let page = profile.page(id) else { return nil }
            return id == position.page ? position : self.position(of: page, in: profile)
        }
        let here = shown.contains { $0?.page == position.page }
        if !here, !shown.contains(where: { $0 == nil }) { shown[0] = position }
        for place in shown.indices where shown[place] == nil {
            let taken = Set(shown.compactMap { $0?.page })
            shown[place] = free.first { !taken.contains($0.page) }
        }
        return shown.compactMap { $0 }
    }

    /// A page with the way back out of it: a folder is entered from the page it opens from.
    static func position(of page: DeckPage, in profile: DeckProfile) -> DeckPosition {
        var trail: [UUID] = []
        var at = page.parent
        var steps = 0
        while let id = at, let parent = profile.page(id), steps < 50 { trail.insert(parent.id, at: 0); at = parent.parent; steps += 1 }
        return DeckPosition(profile: profile.id, page: page.id, trail: trail)
    }

    /// Which of the pages shown is the page the device is on (for its blue name); nil when it is none.
    public static func spot(of position: DeckPosition, in shown: [DeckPosition]) -> Int? {
        shown.firstIndex { $0.page == position.page && $0.profile == position.profile }
    }

    /// The pages the app picks by itself: the page at `position`, the next top pages going round, the folders.
    private static func freeSpread(at position: DeckPosition, count: Int, in profile: DeckProfile) -> [DeckPosition] {
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
    /// `twice` = pressed twice within a third of a second: the key's double-press action, when it has one.
    public static func press(_ index: Int, at position: DeckPosition, in deck: Deck, long: Bool = false,
                             twice: Bool = false) -> Outcome {
        var outcome = Outcome(position: position, run: [])
        guard let key = keys(at: position, in: deck)[index] else { return outcome }
        apply(key.action(long: long, twice: twice), to: &outcome, in: deck, depth: 0)
        return outcome
    }

    /// A key of the favourites row was pressed. It acts from wherever the deck is.
    public static func pressFavourite(_ index: Int, at position: DeckPosition, in deck: Deck, long: Bool = false,
                                      twice: Bool = false) -> Outcome {
        var outcome = Outcome(position: position, run: [])
        guard let key = deck.favourites[index] else { return outcome }
        let action = key.action(long: long, twice: twice)
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
             .macDo, .joinMeeting, .playlist, .searchCopied, .counter, .stopwatch, .zero, .paragon, .focus, .breath, .often, .training, .steward:
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

/// "Set up keys" (0.19): dragging pages into the four places of "Several pages at once".
public enum PagePlaces {
    /// What a dragged page of the row of pages carries (then its id), and a dragged place (then 0…3).
    public static let pageDrag = "deckpage:"
    public static let placeDrag = "deckplace:"

    /// The page a drop brings: a page of this group from the row of pages, or the page standing in
    /// another place (the two then swap, see `DeckProfile.put`). nil = nothing to put here.
    public static func page(dropped item: String, in profile: DeckProfile) -> UUID? {
        if item.hasPrefix(pageDrag) {
            return UUID(uuidString: String(item.dropFirst(pageDrag.count))).flatMap { profile.page($0)?.id }
        }
        if item.hasPrefix(placeDrag), let from = Int(item.dropFirst(placeDrag.count)),
           profile.places.indices.contains(from) {
            return profile.places[from].flatMap { profile.page($0)?.id }
        }
        return nil
    }

    /// The height of the "Set up keys" window: 840 points, less on a screen that is not that tall
    /// (32 points stay free for the title bar), never under 560.
    public static func windowHeight(screen: Double?) -> Double {
        guard let screen else { return 840 }
        return max(560, min(840, screen - 32))
    }
}

/// The double press (0.20): a key that has a double-press action waits a third of a second after one
/// press, to see whether a second follows. A second press within that time is the double press; no
/// second press = the usual action, once, when the wait is over. Keys without a double press never
/// wait. One place per key that waits (the Mac's own keys, and each iPhone or iPad apart).
public struct TwicePress: Equatable, Sendable {
    /// A third of a second.
    public static let wait = 0.33

    public enum Verdict: Equatable, Sendable {
        /// The first press: wait, and ask `over` when the time is up.
        case wait
        /// The second press came in time: the double press.
        case twice
    }

    /// The presses that wait, by the name of their place: the moment each came.
    public private(set) var waiting: [String: Double] = [:]

    public init() {}

    /// True while a first press waits at this place.
    public func waits(_ place: String) -> Bool { waiting[place] != nil }

    /// A key that has a double press was pressed at `now` (seconds). A press that finds one waiting
    /// is the double press; the clock that calls `over` after `wait` keeps the time.
    public mutating func press(_ place: String, at now: Double) -> Verdict {
        if waiting[place] != nil {
            waiting[place] = nil
            return .twice
        }
        waiting[place] = now
        return .wait
    }

    /// The wait of the press that came at `first` is over: true = no second press came, so the key
    /// does its usual thing now, once. False = a double press took it, or a later press waits in its place.
    public mutating func over(_ place: String, first: Double) -> Bool {
        guard waiting[place] == first else { return false }
        waiting[place] = nil
        return true
    }
}
