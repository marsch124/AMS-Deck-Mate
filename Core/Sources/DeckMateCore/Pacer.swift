import Foundation

// The 0.16 live-lane rules: the breathing pacer, the progress bar across keys, and when the
// keys that change by themselves need to be drawn again.

/// The breathing pacer key: a soft bar rises while he breathes in and falls while he breathes out.
/// Calm: no numbers, no score. The run lives in the app's memory only.
public enum BreathKeys {
    public struct Setting: Equatable, Sendable {
        public var inSeconds: Int
        public var outSeconds: Int
        public var breaths: Int
        public init(inSeconds: Int, outSeconds: Int, breaths: Int) {
            self.inSeconds = inSeconds
            self.outSeconds = outSeconds
            self.breaths = breaths
        }
        /// One whole breath, in and out.
        public var cycle: Int { inSeconds + outSeconds }
        /// The whole round.
        public var seconds: Int { cycle * breaths }
    }

    /// The rhythms offered: seconds in, seconds out. The first is the default.
    public static let rhythms: [(inSeconds: Int, outSeconds: Int)] = [(4, 6), (4, 4), (5, 5), (4, 8)]
    /// How many breaths a round has. The first is the default.
    public static let counts = [6, 10, 20]
    public static let standard = Setting(inSeconds: 4, outSeconds: 6, breaths: 6)

    public static let idleWords = "Breathe"
    public static let inWords = "Breathe in"
    public static let outWords = "Breathe out"

    /// The rhythm and the breaths from a key's target "<in>-<out>-<breaths>"; anything odd = the default.
    public static func setting(_ target: String) -> Setting {
        let parts = target.split(separator: "-", omittingEmptySubsequences: false).compactMap { Int($0) }
        guard parts.count == 3, target.split(separator: "-", omittingEmptySubsequences: false).count == 3,
              rhythms.contains(where: { $0.inSeconds == parts[0] && $0.outSeconds == parts[1] }),
              counts.contains(parts[2]) else { return standard }
        return Setting(inSeconds: parts[0], outSeconds: parts[1], breaths: parts[2])
    }

    public static func target(_ setting: Setting) -> String {
        "\(setting.inSeconds)-\(setting.outSeconds)-\(setting.breaths)"
    }

    /// "4 in · 6 out".
    public static func rhythmWords(inSeconds: Int, outSeconds: Int) -> String { "\(inSeconds) in · \(outSeconds) out" }

    /// How a key as it shows right now names the bar it draws: "bar:<0–100>". Never saved.
    public static let barPrefix = "bar:"

    /// The level (0–100) of a key that shows the breathing bar; nil when it shows a drawing.
    public static func level(_ icon: String) -> Int? {
        guard icon.hasPrefix(barPrefix), let value = Int(icon.dropFirst(barPrefix.count)) else { return nil }
        return min(100, max(0, value))
    }

    /// The round that was started: which key, since when, and its rhythm.
    public struct Run: Equatable, Sendable {
        public var key: UUID
        public var began: Date
        public var setting: Setting
        public init(key: UUID, began: Date, setting: Setting) {
            self.key = key
            self.began = began
            self.setting = setting
        }
        public var end: Date { began.addingTimeInterval(Double(setting.seconds)) }
    }

    /// What the running key shows: breathing in or out, and how high the bar stands (0–100).
    public struct Showing: Equatable, Sendable {
        public var key: UUID
        public var breathingIn: Bool
        public var level: Int
        public init(key: UUID, breathingIn: Bool, level: Int) {
            self.key = key
            self.breathingIn = breathingIn
            self.level = level
        }
    }

    /// A soft rise and fall: slow at both ends.
    static func ease(_ t: Double) -> Double { (1 - cos(Double.pi * min(1, max(0, t)))) / 2 }

    /// Where a round stands now; nil = it is over (or there is none).
    public static func showing(_ run: Run?, now: Date) -> Showing? {
        guard let run, run.setting.cycle > 0 else { return nil }
        let passed = max(0, now.timeIntervalSince(run.began))
        guard passed < Double(run.setting.seconds) else { return nil }
        let into = passed.truncatingRemainder(dividingBy: Double(run.setting.cycle))
        if into < Double(run.setting.inSeconds) {
            return Showing(key: run.key, breathingIn: true, level: Int((ease(into / Double(run.setting.inSeconds)) * 100).rounded()))
        }
        let out = (into - Double(run.setting.inSeconds)) / Double(run.setting.outSeconds)
        return Showing(key: run.key, breathingIn: false, level: Int((ease(1 - out) * 100).rounded()))
    }

    /// A press: a round that goes on is stopped by a press on its own key; any other press starts a round on that key.
    public static func pressed(_ run: Run?, key: UUID, target: String, now: Date) -> Run? {
        if let run, run.key == key, showing(run, now: now) != nil { return nil }
        return Run(key: key, began: now, setting: setting(target))
    }
}

/// A progress bar made of several keys side by side: each key is one part ("<place>/<how many>").
public enum BarKeys {
    /// How a key as it shows right now names the part it fills: "fill:<0–100>". Never saved.
    public static let fillPrefix = "fill:"

    /// A key's place and the number of parts, from its target "2/5"; anything odd = 1/1.
    public static func parse(_ target: String) -> (place: Int, count: Int) {
        let parts = target.split(separator: "/", omittingEmptySubsequences: false).compactMap { Int($0) }
        guard parts.count == 2, (1...StreamDeckProtocol.keyCount).contains(parts[1]), (1...parts[1]).contains(parts[0]) else { return (1, 1) }
        return (parts[0], parts[1])
    }

    public static func target(place: Int, count: Int) -> String { "\(place)/\(count)" }

    /// How full part `place` of `count` is (0–100) when the whole bar is at `progress` (0–1).
    /// Only a part that is really full says 100.
    public static func share(place: Int, of count: Int, progress: Double) -> Int {
        guard count > 0 else { return 0 }
        let each = min(1, max(0, progress * Double(count) - Double(place - 1)))
        return min(100, max(0, Int((each * 100 + 1e-6).rounded(.down))))
    }

    /// The part's fill (0–100) of a key as it shows now; nil when it shows something else.
    public static func percent(_ icon: String) -> Int? {
        guard icon.hasPrefix(fillPrefix), let value = Int(icon.dropFirst(fillPrefix.count)) else { return nil }
        return min(100, max(0, value))
    }

    /// What the bar follows right now: how far, and the colour of what it follows.
    public struct Now: Equatable, Sendable {
        public var progress: Double
        public var tone: KeyKind
        /// The seconds the whole thing takes, for knowing how often to look again.
        public var total: Double
        public init(progress: Double, tone: KeyKind, total: Double) {
            self.progress = progress
            self.tone = tone
            self.total = total
        }
    }

    /// The focus round that is running (the whole round), else the timer that will end last; nil = nothing runs.
    public static func now(focus: FocusKeys.Run?, timers: TimerKeys.State, at now: Date) -> Now? {
        if let run = focus, let showing = FocusKeys.showing(run, now: now), !showing.done {
            let total = Double(run.plan.seconds)
            guard total > 0 else { return nil }
            return Now(progress: min(1, max(0, now.timeIntervalSince(run.began) / total)), tone: .shortcut, total: total)
        }
        guard let last = timers.ends.max(by: { $0.value < $1.value }) else { return nil }
        let total = Double(TimerKeys.minutes(last.key)) * 60
        return Now(progress: min(1, max(0, 1 - last.value.timeIntervalSince(now) / total)), tone: .text, total: total)
    }

    /// The row's keys after "Fill this row with the bar": empty places of the row become bar keys, and
    /// all the bar keys of the row are numbered left to right. A place that holds a key is never replaced.
    public static func filledRow(_ keys: [Int: DeckKey], row: Int) -> [Int: DeckKey] {
        var out = keys
        let places = (0..<5).map { row * 5 + $0 }
        for place in places where place < StreamDeckProtocol.keyCount {
            if let key = out[place], !(key.action.type == .none && key.title.isEmpty && key.icon.isEmpty) { continue }
            out[place] = DeckKey(action: DeckAction(type: .bar))
        }
        let bars = places.filter { out[$0]?.action.type == .bar }
        for (index, place) in bars.enumerated() {
            out[place]?.action.target = target(place: index + 1, count: bars.count)
        }
        return out
    }
}

/// When the keys that change by themselves must be drawn again: as seldom as they can be.
public enum LiveTick {
    /// Keys that count seconds or fill a bar: they need the clock while they are seen.
    public static func showsSeconds(_ type: ActionType) -> Bool {
        [.timer, .focus, .stopwatch, .breath, .bar].contains(type)
    }

    /// The shortest wait, so a clock that is a hair early does not spin.
    public static let shortest = 0.05
    /// A key that counts seconds nobody sees is drawn once a minute.
    public static let unseen = 60.0

    /// Seconds until a timer-like key (whole minutes, seconds in the last minute) with `remaining`
    /// seconds left must be drawn again, and in any case when it ends. `seconds` = the seconds are seen.
    public static func wake(remaining: Double, seconds: Bool) -> Double {
        guard remaining > 0 else { return shortest }
        let left = Int(remaining.rounded(.up))
        let next: Double
        if left > 60 {
            next = remaining - Double((left + 59) / 60 - 1) * 60
        } else if seconds {
            next = remaining - Double(left - 1)
        } else {
            next = remaining
        }
        return max(shortest, next <= 0 ? 1 : next)
    }

    /// The wait until the timers need a look: the minute changes, the last seconds (only when seen),
    /// every end, and when "Done" stops being said. nil = no timer is going.
    public static func wake(timers: TimerKeys.State, now: Date, seconds: Bool) -> Double? {
        var waits = timers.ends.values.map { wake(remaining: $0.timeIntervalSince(now), seconds: seconds) }
        waits += timers.done.values.map { max(shortest, $0.timeIntervalSince(now)) }
        return waits.min()
    }

    /// The same for a focus round: the minute or second of the step, the step's end, and the end of "Done".
    public static func wake(focus run: FocusKeys.Run?, now: Date, seconds: Bool) -> Double? {
        guard let run, !run.plan.steps.isEmpty else { return nil }
        var passed = max(0, now.timeIntervalSince(run.began))
        for step in run.plan.steps {
            if passed < Double(step.seconds) { return wake(remaining: Double(step.seconds) - passed, seconds: seconds) }
            passed -= Double(step.seconds)
        }
        let rest = Double(FocusKeys.doneSeconds) - passed
        return rest > 0 ? max(shortest, rest) : nil
    }

    /// How often a bar's parts need a look: a whole percent of a part, for a bar of `parts` parts.
    public static func wake(bar: BarKeys.Now?, parts: Int) -> Double? {
        bar.map { max(1, $0.total / Double(100 * max(1, parts))) }
    }
}
