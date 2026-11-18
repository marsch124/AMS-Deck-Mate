import Foundation

// The 0.14 rules: PARAGON keys (Inbox, next task, task from the copied text, quick note, due today)
// and focus rounds that start AMS PomoTimer and count along on the key.

/// PARAGON keys. The numbers come from the small file PARAGON writes for its own widget; Deck Mate
/// only reads it. Adding a task or a note goes through PARAGON's own capture link.
public enum ParagonKeys {
    public enum What: String, CaseIterable, Sendable {
        case inbox, next, copiedTask, note

        public var title: String {
            switch self {
            case .inbox: return "Inbox"
            case .next: return "Next task"
            case .copiedTask: return "Task from the copied text"
            case .note: return "Quick note"
            }
        }

        /// The words on a key without a title of its own.
        public var short: String {
            switch self {
            case .inbox: return "Inbox"
            case .next: return "Next task"
            case .copiedTask: return "Add task"
            case .note: return "Quick note"
            }
        }

        public var icon: String {
            switch self {
            case .inbox: return "app-inbox"
            case .next: return "control-check"
            case .copiedTask: return "control-addCircle"
            case .note: return "notebook"
            }
        }

        /// Shows something from PARAGON's file (the others only do something).
        public var shows: Bool { self == .inbox || self == .next }
    }

    public static func what(_ target: String) -> What { What(rawValue: target) ?? .inbox }

    /// Where PARAGON on the Mac keeps the file for its widget, from the home folder.
    public static let file = "Library/Group Containers/D24ENP83QQ.group.com.schabbauer.amspara/widget-snapshot.json"
    /// The file is read again after this many seconds.
    public static let everySeconds = 60.0
    public static let inboxLink = "amspara:///list/inbox"
    public static let todayLink = "amspara:///list/today"
    /// Any link of PARAGON's: used to see whether PARAGON is on this Mac.
    public static let anyLink = "amspara:///list/today"
    public static let dueWords = "Due today"
    public static let oldWords = "Open PARAGON"
    public static let missingWords = "No PARAGON"
    public static let nothingNextWords = "Nothing next"

    /// The names the glances go by in `LiveKeys.glances`.
    public static func glanceName(_ what: What) -> String { "paragon:" + what.rawValue }

    public struct Day: Equatable, Sendable {
        public var year: Int
        public var month: Int
        public var day: Int
        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
    }

    /// What Deck Mate takes from PARAGON's file.
    public struct Snapshot: Equatable, Sendable {
        public var day: Day
        public var dueToday: Int
        public var overdue: Int
        public var inbox: Int
        /// The first task on PARAGON's list: its words, when it is due ("today", "2 days over"), its link.
        public var nextTitle: String?
        public var nextDue: String?
        public var nextOverdue: Bool
        public var nextLink: String?

        public init(day: Day, dueToday: Int = 0, overdue: Int = 0, inbox: Int = 0, nextTitle: String? = nil,
                    nextDue: String? = nil, nextOverdue: Bool = false, nextLink: String? = nil) {
            self.day = day
            self.dueToday = dueToday
            self.overdue = overdue
            self.inbox = inbox
            self.nextTitle = nextTitle
            self.nextDue = nextDue
            self.nextOverdue = nextOverdue
            self.nextLink = nextLink
        }
    }

    /// PARAGON's file, read; nil when it is not one.
    public static func snapshot(from data: Data) -> Snapshot? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let day = json["day"] as? [String: Any],
              let year = (day["year"] as? NSNumber)?.intValue, let month = (day["month"] as? NSNumber)?.intValue,
              let number = (day["day"] as? NSNumber)?.intValue else { return nil }
        func count(_ name: String) -> Int { max(0, (json[name] as? NSNumber)?.intValue ?? 0) }
        var shot = Snapshot(day: Day(year: year, month: month, day: number), dueToday: count("dueToday"),
                            overdue: count("overdue"), inbox: count("inboxCount"))
        if let first = (json["items"] as? [[String: Any]])?.first,
           let title = (first["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
            shot.nextTitle = title
            shot.nextDue = (first["dueText"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            shot.nextOverdue = first["isOverdue"] as? Bool ?? false
            // Only a link of PARAGON's own is ever opened.
            shot.nextLink = (first["url"] as? String).flatMap { $0.lowercased().hasPrefix("amspara://") ? $0 : nil }
        }
        return shot
    }

    /// The words when the numbers cannot be shown; nil = they can.
    static func trouble(_ shot: Snapshot?, today: Day, installed: Bool) -> Glance? {
        guard installed else { return Glance(words: missingWords) }
        guard let shot, shot.day == today else { return Glance(big: "–", words: oldWords) }
        return nil
    }

    /// What an Inbox or a Next task key shows. A file from an earlier day counts for nothing.
    public static func glance(_ what: What, snapshot: Snapshot?, today: Day, installed: Bool) -> Glance? {
        guard what.shows else { return nil }
        if let trouble = trouble(snapshot, today: today, installed: installed) { return trouble }
        guard let shot = snapshot else { return nil }
        switch what {
        case .inbox:
            return Glance(big: String(shot.inbox), words: "Inbox", tone: shot.inbox > 0 ? .text : nil)
        default:
            guard let title = shot.nextTitle else { return Glance(words: nothingNextWords) }
            return Glance(big: shot.nextDue ?? "", words: title, tone: shot.nextOverdue ? .raycast : nil)
        }
    }

    /// What a Due today key shows: the number due today; overdue ones in words, and in red.
    public static func dueGlance(snapshot: Snapshot?, today: Day, installed: Bool) -> Glance {
        if let trouble = trouble(snapshot, today: today, installed: installed) { return trouble }
        guard let shot = snapshot else { return Glance(words: dueWords) }
        if shot.overdue > 0 { return Glance(big: String(shot.dueToday), words: "\(shot.overdue) overdue", tone: .raycast) }
        return Glance(big: String(shot.dueToday), words: dueWords)
    }

    /// What a press of an Inbox or a Next task key opens.
    public static func openLink(_ what: What, snapshot: Snapshot?, today: Day) -> String {
        if what == .next, let shot = snapshot, shot.day == today, let link = shot.nextLink { return link }
        return what == .next ? todayLink : inboxLink
    }

    /// A longer text is not sent to PARAGON.
    public static let longest = 2_000

    /// PARAGON's own capture link for a task (or a note) in its Inbox; nil = nothing to add.
    public static func captureLink(text: String?, note: Bool) -> URL? {
        let words = (text ?? "").split(whereSeparator: \.isNewline).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty else { return nil }
        var parts = URLComponents()
        parts.scheme = "amspara"
        parts.host = "capture"
        parts.queryItems = [URLQueryItem(name: "text", value: String(words.prefix(longest))),
                            URLQueryItem(name: "target", value: "inbox")]
        if note { parts.queryItems?.append(URLQueryItem(name: "note", value: "1")) }
        return parts.url
    }
}

/// Focus rounds: a press starts a template in AMS PomoTimer, and the key counts along.
public enum FocusKeys {
    public struct Step: Codable, Equatable, Sendable {
        /// PomoTimer's own word: startup, prep, focus, pause, longbreak, cooldown.
        public var kind: String
        public var label: String
        public var seconds: Int
        public init(kind: String, label: String, seconds: Int) {
            self.kind = kind
            self.label = label
            self.seconds = seconds
        }
    }

    public struct Plan: Codable, Equatable, Sendable {
        public var name: String
        public var steps: [Step]
        public init(name: String, steps: [Step]) {
            self.name = name
            self.steps = steps
        }
        public var seconds: Int { steps.reduce(0) { $0 + $1.seconds } }
    }

    static func step(_ kind: String, _ minutes: Int) -> Step {
        let label: String
        switch kind {
        case "startup": label = "Start-up"
        case "prep": label = "Preparation"
        case "focus": label = "Pomodoro"
        case "pause": label = "Pause"
        case "longbreak": label = "Long break"
        default: label = "Cool-down"
        }
        return Step(kind: kind, label: label, seconds: minutes * 60)
    }

    /// PomoTimer's five ready-made templates, as it ships them.
    public static let builtIn: [Plan] = [
        Plan(name: "Classic Pomodoro", steps: [step("startup", 2), step("prep", 3), step("focus", 25), step("pause", 5),
                                               step("focus", 25), step("cooldown", 5)]),
        Plan(name: "Four Pomodoros", steps: [step("startup", 2), step("prep", 3), step("focus", 25), step("pause", 5),
                                             step("focus", 25), step("pause", 5), step("focus", 25), step("longbreak", 15),
                                             step("focus", 25), step("cooldown", 5)]),
        Plan(name: "Deep Work 50/10", steps: [step("startup", 2), step("prep", 5), step("focus", 50), step("pause", 10),
                                              step("focus", 50), step("cooldown", 10)]),
        Plan(name: "Short Burst", steps: [step("prep", 1), step("focus", 15), step("pause", 3), step("focus", 15),
                                          step("cooldown", 2)]),
        Plan(name: "Single Pomodoro", steps: [step("prep", 1), step("focus", 25), step("cooldown", 2)]),
    ]

    /// The templates in a backup file PomoTimer saved; none when it is not one.
    public static func plans(fromBackup data: Data) -> [Plan] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let templates = json["templates"] as? [[String: Any]] else { return [] }
        return templates.compactMap { template in
            guard let name = (template["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
                  name.count <= 80, let steps = template["steps"] as? [[String: Any]] else { return nil }
            let read: [Step] = steps.compactMap { step in
                guard let seconds = (step["seconds"] as? NSNumber)?.intValue, seconds > 0, seconds <= 36_000 else { return nil }
                let kind = step["type"] as? String ?? "focus"
                let label = (step["label"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return Step(kind: kind, label: label.isEmpty ? self.step(kind, 0).label : String(label.prefix(40)), seconds: seconds)
            }
            return read.isEmpty ? nil : Plan(name: name, steps: Array(read.prefix(40)))
        }
    }

    /// The plans to pick from: the ready-made ones, then his own (one of his with a ready-made name takes its place).
    public static func choices(own: [Plan]) -> [Plan] {
        let names = Set(own.map { $0.name.lowercased() })
        return builtIn.filter { !names.contains($0.name.lowercased()) } + own
    }

    /// A key for this plan: the plan rides in the key's steps ("<kind>:<seconds>", named by its label).
    public static func action(for plan: Plan) -> DeckAction {
        DeckAction(type: .focus, target: plan.name,
                   steps: plan.steps.map { DeckAction(type: .wait, target: "\($0.kind):\($0.seconds)", name: $0.label) })
    }

    /// The plan a key carries.
    public static func plan(of action: DeckAction) -> Plan {
        let steps: [Step] = action.steps.compactMap { step in
            let parts = step.target.split(separator: ":")
            guard parts.count == 2, let seconds = Int(parts[1]), seconds > 0 else { return nil }
            return Step(kind: String(parts[0]), label: step.name, seconds: seconds)
        }
        return Plan(name: action.target, steps: steps)
    }

    /// AMS PomoTimer's address.
    public static let app = "https://marsch124.github.io/AMS-PomoTimer/"

    /// PomoTimer's own link that starts a template by its name.
    public static func startLink(_ name: String) -> URL? {
        var parts = URLComponents(string: app)
        parts?.queryItems = [URLQueryItem(name: "action", value: "start"), URLQueryItem(name: "template", value: name)]
        return parts?.url
    }

    /// A run that was started: its plan and the moment of the press.
    public struct Run: Codable, Equatable, Sendable {
        public var plan: Plan
        public var began: Date
        public init(plan: Plan, began: Date) {
            self.plan = plan
            self.began = began
        }
    }

    /// What the key of a running plan shows.
    public struct Showing: Equatable, Sendable {
        public var name: String
        public var label: String
        /// Seconds left of this step; 0 with `done` = over, still saying "Done".
        public var left: Int
        public var kind: String
        public var done: Bool
        public init(name: String, label: String, left: Int, kind: String, done: Bool = false) {
            self.name = name
            self.label = label
            self.left = left
            self.kind = kind
            self.done = done
        }
    }

    /// "Done" stays on the key this long.
    public static let doneSeconds = 60

    /// Where a run stands now; nil = over (and "Done" has had its time), or it has no steps.
    public static func showing(_ run: Run?, now: Date) -> Showing? {
        guard let run, !run.plan.steps.isEmpty else { return nil }
        var passed = Int(max(0, now.timeIntervalSince(run.began)))
        for step in run.plan.steps {
            if passed < step.seconds {
                return Showing(name: run.plan.name, label: step.label, left: step.seconds - passed, kind: step.kind)
            }
            passed -= step.seconds
        }
        guard passed < doneSeconds else { return nil }
        return Showing(name: run.plan.name, label: "Done", left: 0, kind: "done", done: true)
    }

    /// The key's colour during a step: red while focusing, green in a pause, amber around them.
    public static func tone(_ kind: String) -> KeyKind {
        switch kind {
        case "focus": return .raycast
        case "pause", "longbreak", "done": return .media
        default: return .text
        }
    }
}
