import Foundation

// The 0.10 rules: timer keys, switch keys, open-app keys, the wait step, finding a key by its
// words, and counting which keys are pressed.

extension DeckAction {
    /// A new action of this kind, with the choice it starts on.
    public static func fresh(_ type: ActionType) -> DeckAction {
        switch type {
        case .media: return DeckAction(type: type, target: MediaKey.playPause.rawValue)
        case .recent, .copied, .recentFile, .running, .wait: return DeckAction(type: type, target: "1")
        case .timer: return DeckAction(type: type, target: "5")
        case .toggle: return DeckAction(type: type, target: SwitchKeys.dark)
        case .garmin: return DeckAction(type: type, target: GarminKeys.Number.steps.rawValue)
        case .macNow: return DeckAction(type: type, target: MacNowKeys.Number.battery.rawValue)
        case .macDo: return DeckAction(type: type, target: MacDo.desktop.rawValue)
        case .searchCopied: return DeckAction(type: type, target: SearchKeys.Engine.google.rawValue)
        case .counter: return DeckAction(type: type, target: CounterKeys.newID())
        case .stopwatch: return DeckAction(type: type, target: StopwatchKeys.newID())
        case .paragon: return DeckAction(type: type, target: ParagonKeys.What.inbox.rawValue)
        case .focus: return FocusKeys.action(for: FocusKeys.builtIn[0])
        default: return DeckAction(type: type)
        }
    }
}

/// Timer keys: a key counts down its minutes; a press starts it, another press stops it.
public enum TimerKeys {
    /// The lengths offered in "Set up keys", in minutes.
    public static let choices = [1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60]
    /// How long a finished timer says "Done" when nobody presses it.
    public static let doneStays = 60.0

    /// The minutes of a timer key, from its target; anything odd counts as 5.
    public static func minutes(_ target: String) -> Int { min(600, max(1, Int(target) ?? 5)) }

    /// Seconds as a clock: "4:59", "1:05:00".
    public static func clock(_ seconds: Int) -> String {
        let s = max(0, seconds)
        let two = { (n: Int) in n < 10 ? "0\(n)" : "\(n)" }
        return s >= 3600 ? "\(s / 3600):\(two(s % 3600 / 60)):\(two(s % 60))" : "\(s / 60):\(two(s % 60))"
    }

    /// What a timer or a focus round shows: whole minutes while more than a minute is left ("12 min"),
    /// seconds only in the last minute ("0:59"). A stopwatch keeps `clock`.
    public static func shown(_ seconds: Int) -> String {
        seconds > 60 ? "\((seconds + 59) / 60) min" : clock(seconds)
    }

    /// The timers running (by their minutes, the moment each ends) and the ones just finished
    /// (the moment each stops saying "Done").
    public struct State: Equatable, Sendable {
        public var ends: [String: Date]
        public var done: [String: Date]
        public init(ends: [String: Date] = [:], done: [String: Date] = [:]) {
            self.ends = ends
            self.done = done
        }
        public var isIdle: Bool { ends.isEmpty && done.isEmpty }
    }

    /// A timer key was pressed: a finished one is put away, a running one stops, an idle one starts.
    public static func pressed(_ state: State, target: String, now: Date) -> State {
        let name = String(minutes(target))
        var next = state
        if next.done.removeValue(forKey: name) != nil { return next }
        if next.ends.removeValue(forKey: name) != nil { return next }
        next.ends[name] = now.addingTimeInterval(Double(minutes(target)) * 60)
        return next
    }

    /// Time went on: timers whose end has come are finished (named in `finished`, once), and
    /// finished ones stop saying "Done" after a minute.
    public static func tick(_ state: State, now: Date) -> (state: State, finished: [String]) {
        var next = state
        var finished: [String] = []
        for (name, end) in state.ends where end <= now {
            next.ends[name] = nil
            next.done[name] = now.addingTimeInterval(doneStays)
            finished.append(name)
        }
        next.done = next.done.filter { $0.value > now }
        return (next, finished.sorted())
    }

    /// Seconds left for each timer; 0 = finished and still saying "Done".
    public static func left(_ state: State, now: Date) -> [String: Int] {
        var left = state.done.mapValues { _ in 0 }
        for (name, end) in state.ends { left[name] = max(1, Int(end.timeIntervalSince(now).rounded(.up))) }
        return left
    }
}

/// Switch keys: a key that is on or off and shows which.
public enum SwitchKeys {
    public static let dark = "dark"
    public static let mute = "mute"
    /// Keeps the Mac and its screen from going to sleep by themselves while it is on.
    public static let awake = "awake"
    /// A switch of his own: "own:<a name of its own>"; its first step runs when it goes on, its second when it goes off.
    public static let ownPrefix = "own:"

    public static func newOwn() -> String { ownPrefix + UUID().uuidString }
    public static func isOwn(_ target: String) -> Bool { target.hasPrefix(ownPrefix) }

    /// What a press of a switch of his own runs: the first step when it is off, the second when it is on.
    public static func step(of action: DeckAction, isOn: Bool) -> DeckAction? {
        let index = isOn ? 1 : 0
        guard action.steps.indices.contains(index), action.steps[index].type != .none else { return nil }
        return action.steps[index]
    }

    /// The words on a switch key without a title.
    public static func words(_ target: String, isOn: Bool) -> String {
        switch target {
        case dark: return isOn ? "Dark" : "Light"
        case mute: return isOn ? "Muted" : "Sound on"
        case awake: return isOn ? "Awake" : "May sleep"
        default:
            // A fan key says its choice whether it is on or not: the switch mark says which is on.
            if let choice = FanKeys.choice(of: target) { return FanKeys.keyWords(choice) }
            return isOn ? "On" : "Off"
        }
    }
}

/// "Open app" keys: the apps running now, each in a place that stays put while it runs.
public enum RunningApps {
    /// A folder of open apps: Back and fourteen apps.
    public static let folderKeys = 14

    /// 1–15 from a key's target; anything else counts as 1.
    public static func number(_ target: String) -> Int { min(15, max(1, Int(target) ?? 1)) }

    /// The app an "Open app" key with this number stands for; nil = fewer apps are open.
    public static func app(number: Int, in list: [String]) -> String? {
        guard number >= 1, number <= list.count else { return nil }
        return list[number - 1]
    }

    /// The list after apps opened or quit: the ones still open keep their order, new ones go to the end.
    public static func order(was: [String], now: [String]) -> [String] {
        var seen = Set<String>()
        let open = now.filter { !$0.isEmpty && seen.insert($0).inserted }
        let kept = was.filter { open.contains($0) }
        return kept + open.filter { !kept.contains($0) }
    }

    /// A folder that shows the open apps: a Back key, then "Open app" 1 to 14.
    public static func folder(parent: UUID) -> DeckPage {
        var page = DeckPage(name: "Open apps", parent: parent)
        page.keys[0] = DeckKey(title: "Back", action: DeckAction(type: .back))
        for number in 1...folderKeys {
            page.keys[number] = DeckKey(action: DeckAction(type: .running, target: String(number)))
        }
        return page
    }
}

extension DeckPage {
    /// The first empty place on the page; nil when all 15 are taken.
    public var firstFreePlace: Int? { (0..<StreamDeckProtocol.keyCount).first { keys[$0] == nil } }
}

/// The "Wait" step of a "several things in a row" key, and when each step starts.
public enum StepTiming {
    /// The pause between two steps.
    public static let pause = 0.33
    /// The waits offered, in seconds.
    public static let waits = ["0.5", "1", "2", "3", "5", "10"]

    /// The seconds a "Wait" step waits: half a second to a minute; anything odd counts as 1.
    public static func seconds(_ target: String) -> Double { min(60, max(0.5, Double(target) ?? 1)) }

    /// The steps that do something, each with the seconds after the press at which it starts.
    /// A "Wait" step does nothing itself: it pushes everything after it back.
    public static func starts(_ actions: [DeckAction]) -> [(action: DeckAction, after: Double)] {
        var at = 0.0
        var found: [(DeckAction, Double)] = []
        for action in actions {
            if action.type == .wait {
                at += seconds(action.target)
            } else {
                found.append((action, at))
                at += pause
            }
        }
        return found
    }
}

/// Finds keys by their words, across every page group and page.
public enum KeyFinder {
    public struct Hit: Equatable, Identifiable, Sendable {
        public var profile: UUID
        public var page: UUID
        public var slot: Int
        public var title: String
        /// "Page group · Page".
        public var place: String
        public var id: String { "\(page.uuidString):\(slot)" }
    }

    /// Keys that only move around are not offered.
    static func counts(_ key: DeckKey) -> Bool {
        ![ActionType.none, .back, .nextPage, .previousPage].contains(key.action.type)
    }

    /// The keys whose title, page or page group holds every typed word, best first: titles that
    /// start with the words, then the rest, each in the order of the pages. `name` gives a key's
    /// words as it shows them (an app key without a title shows its app's name).
    public static func hits(_ words: String, in deck: Deck, limit: Int = 6, name: (DeckKey) -> String) -> [Hit] {
        let wanted = words.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !wanted.isEmpty else { return [] }
        var first: [Hit] = []
        var rest: [Hit] = []
        for profile in deck.profiles {
            for page in profile.pages {
                for slot in page.keys.keys.sorted() {
                    guard let key = page.keys[slot], counts(key) else { continue }
                    let title = name(key)
                    let place = "\(profile.name) · \(page.name)"
                    let all = (title + " " + place).lowercased()
                    guard !title.isEmpty, wanted.allSatisfy({ all.contains($0) }) else { continue }
                    let hit = Hit(profile: profile.id, page: page.id, slot: slot, title: title, place: place)
                    if title.lowercased().hasPrefix(wanted[0]) { first.append(hit) } else { rest.append(hit) }
                }
            }
        }
        return Array((first + rest).prefix(limit))
    }
}

/// Which keys are pressed, and when last: for the "Key use" list in Settings.
public struct KeyUse: Codable, Equatable, Sendable {
    public struct Entry: Codable, Equatable, Sendable {
        public var count: Int
        public var last: Date
        public init(count: Int, last: Date) {
            self.count = count
            self.last = last
        }
    }

    public struct Line: Equatable, Identifiable, Sendable {
        public var id: String
        /// "Page group · Page · “Title”".
        public var words: String
        public var count: Int
    }

    /// A key not pressed for this many days counts as unused.
    public static let quietDays = 30

    /// The day the counting began.
    public var since: Date
    /// By key (its id as text).
    public var presses: [String: Entry]

    public init(since: Date, presses: [String: Entry] = [:]) {
        self.since = since
        self.presses = presses
    }

    public mutating func record(_ id: UUID, now: Date) {
        let name = id.uuidString
        presses[name] = Entry(count: (presses[name]?.count ?? 0) + 1, last: now)
    }

    /// Whole days counted so far.
    public func days(now: Date) -> Int { max(0, Int(now.timeIntervalSince(since) / 86_400)) }

    /// Keys that do something on the Mac: the ones that only move around or only show something are left out.
    private static func counted(in deck: Deck, name: (DeckKey) -> String) -> [(key: DeckKey, words: String)] {
        let skip: Set<ActionType> = [.none, .folder, .back, .nextPage, .previousPage, .profile, .micLight, .often]
        func label(_ key: DeckKey, _ slot: Int) -> String {
            let title = name(key)
            return title.isEmpty ? "key \(slot + 1)" : "“\(title)”"
        }
        var found: [(DeckKey, String)] = []
        for profile in deck.profiles {
            for page in profile.pages {
                for slot in page.keys.keys.sorted() {
                    guard let key = page.keys[slot], !skip.contains(key.action.type) else { continue }
                    found.append((key, "\(profile.name) · \(page.name) · \(label(key, slot))"))
                }
            }
        }
        for slot in deck.favourites.keys.sorted() {
            guard let key = deck.favourites[slot], !skip.contains(key.action.type) else { continue }
            found.append((key, "Favourites · \(label(key, slot))"))
        }
        return found
    }

    /// The keys not pressed in the last 30 days (or, in the first 30 days, not since the counting began).
    public func quiet(in deck: Deck, now: Date, name: (DeckKey) -> String) -> [Line] {
        let edge = max(since, now.addingTimeInterval(-Double(KeyUse.quietDays) * 86_400))
        return KeyUse.counted(in: deck, name: name).compactMap { key, words in
            if let entry = presses[key.id.uuidString], entry.last >= edge { return nil }
            return Line(id: key.id.uuidString, words: words, count: presses[key.id.uuidString]?.count ?? 0)
        }
    }

    /// The keys pressed most, most first.
    public func most(in deck: Deck, limit: Int = 5, name: (DeckKey) -> String) -> [Line] {
        let lines = KeyUse.counted(in: deck, name: name).compactMap { key, words -> Line? in
            guard let entry = presses[key.id.uuidString], entry.count > 0 else { return nil }
            return Line(id: key.id.uuidString, words: words, count: entry.count)
        }
        return Array(lines.sorted { $0.count > $1.count }.prefix(limit))
    }
}
