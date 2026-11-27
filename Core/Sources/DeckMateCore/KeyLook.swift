import Foundation

/// How keys that show an app's own picture look (0.27): in the app's own colour, or the icon filling the whole key.
public enum AppKeyLook: String, CaseIterable, Codable, Sendable {
    case colour, icon

    public var title: String {
        switch self {
        case .colour: return "App colour"
        case .icon: return "Whole icon"
        }
    }
}

/// The tile colour of a key that shows an app's icon, read from the icon itself (0.27): the main colour
/// among its coloured parts, made deep enough for white words, never teal; graphite for an icon without colour.
public enum AppColour {
    public struct RGB: Equatable, Sendable {
        public var red: Double, green: Double, blue: Double
        public init(_ red: Double, _ green: Double, _ blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    }

    /// The key for an icon with (almost) no colour of its own, such as a black and white one.
    public static let graphite = RGB(0.23, 0.24, 0.26)
    /// The deepest and the lightest a tile may be (HSL lightness), so white words read on every one.
    static let lightness = 0.24...0.36
    static let saturation = 0.40...0.62

    /// The tile for an icon, from its pixels (red, green, blue, alpha, each 0…1).
    public static func tile(fromPixels pixels: [(Double, Double, Double, Double)]) -> RGB {
        var buckets: [Int: (Double, Double, Double, Int)] = [:]
        var opaque = 0
        for (r, g, b, a) in pixels where a > 0.6 {
            opaque += 1
            let (h, s, v) = hsv(r, g, b)
            guard s >= 0.30, v >= 0.30 else { continue }
            let slot = Int(h / 20) % 18
            let was = buckets[slot] ?? (0, 0, 0, 0)
            buckets[slot] = (was.0 + r, was.1 + g, was.2 + b, was.3 + 1)
        }
        // Too few coloured parts: the icon is black and white (or nearly).
        guard let best = buckets.max(by: { $0.value.3 < $1.value.3 }), opaque > 0,
              Double(best.value.3) >= Double(opaque) * 0.06 else { return graphite }
        let n = Double(best.value.3)
        return tile(from: RGB(best.value.0 / n, best.value.1 / n, best.value.2 / n))
    }

    /// The main colour of an icon made into a tile: deep enough, not too loud, and never teal.
    public static func tile(from colour: RGB) -> RGB {
        var (h, s, l) = hsl(colour)
        // His rule (27 Nov 2026): no teal. A green-blue goes to a true green or a clear blue.
        // (Sea greens from 150° count too: they read as teal on a key.)
        if (150..<200).contains(h) { h = h < 175 ? 138 : 212 }
        s = min(max(s, saturation.lowerBound), saturation.upperBound)
        l = min(max(l, lightness.lowerBound), lightness.upperBound)
        // White words reach at least 4.5:1, as on the other tiles since 0.16 (greens and yellows get deeper).
        while whiteContrast(rgb(h, s, l)) < 4.5, l > 0.18 { l -= 0.01 }
        return rgb(h, s, l)
    }

    static func hsv(_ r: Double, _ g: Double, _ b: Double) -> (Double, Double, Double) {
        let high = max(r, g, b), low = min(r, g, b), span = high - low
        var h = 0.0
        if span > 0 {
            if high == r { h = 60 * ((g - b) / span).truncatingRemainder(dividingBy: 6) }
            else if high == g { h = 60 * ((b - r) / span + 2) }
            else { h = 60 * ((r - g) / span + 4) }
        }
        if h < 0 { h += 360 }
        return (h, high == 0 ? 0 : span / high, high)
    }

    public static func hsl(_ c: RGB) -> (Double, Double, Double) {
        let high = max(c.red, c.green, c.blue), low = min(c.red, c.green, c.blue)
        let l = (high + low) / 2
        let span = high - low
        let s = span == 0 ? 0 : span / (1 - abs(2 * l - 1))
        return (hsv(c.red, c.green, c.blue).0, s, l)
    }

    static func rgb(_ h: Double, _ s: Double, _ l: Double) -> RGB {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2
        let (r, g, b): (Double, Double, Double)
        switch h {
        case ..<60: (r, g, b) = (c, x, 0)
        case ..<120: (r, g, b) = (x, c, 0)
        case ..<180: (r, g, b) = (0, c, x)
        case ..<240: (r, g, b) = (0, x, c)
        case ..<300: (r, g, b) = (x, 0, c)
        default: (r, g, b) = (c, 0, x)
        }
        return RGB(r + m, g + m, b + m)
    }

    /// How well white words read on a tile (the usual contrast ratio, 1 to 21).
    public static func whiteContrast(_ c: RGB) -> Double {
        func part(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        let lum = 0.2126 * part(c.red) + 0.7152 * part(c.green) + 0.0722 * part(c.blue)
        return 1.05 / (lum + 0.05)
    }
}

/// Keys that ask first (0.27, his ask): the first press turns the key red ("Sure? Press again") for
/// three seconds; a second press in that time does the job, otherwise nothing happens.
public enum AskFirst {
    /// How long a key waits for the second press.
    public static let window: TimeInterval = 3
    /// The drawing a waiting key shows instead of its own (the Mac draws "Sure?" for it).
    public static let waitingIcon = "ask:again"

    /// Things that are hard to undo and so ask by themselves: quit all apps, empty the bin, eject all disks,
    /// lock the Mac, the switch that lets the Mac sleep or keeps it awake, and Raycast's "Hide all apps".
    public static func risky(_ action: DeckAction) -> Bool {
        switch action.type {
        case .macDo:
            guard let what = MacDo(rawValue: action.target) else { return false }
            return [.quitAll, .emptyBin, .ejectAll, .lock].contains(what)
        case .toggle: return action.target == SwitchKeys.awake
        case .raycast: return action.target.lowercased().contains("/hide-all-apps/")
        case .multi: return action.steps.contains(where: risky)
        default: return false
        }
    }

    /// Whether the key asks first by itself, without a setting of its own: one of its presses is risky.
    public static func automatic(_ key: DeckKey) -> Bool {
        risky(key.action) || (key.hasHeld && key.held.map(risky) == true) || (key.hasTwice && key.twice.map(risky) == true)
    }

    /// Whether the key shows the ring (bottom left): it asks first on at least one of its presses.
    public static func marked(_ key: DeckKey) -> Bool { key.askFirst ?? automatic(key) }

    /// Whether this press of the key asks first. A key set to ask asks for every press that does something;
    /// a key set not to ask never asks; otherwise only a risky action asks.
    public static func asks(_ key: DeckKey, long: Bool, twice: Bool) -> Bool {
        let action = key.action(long: long, twice: twice)
        guard action.type != .none else { return false }
        return key.askFirst ?? risky(action)
    }

    /// The key as it shows while it waits for the second press: same key, "Sure?" drawn instead.
    public static func waiting(_ key: DeckKey) -> DeckKey {
        var shown = key
        shown.icon = waitingIcon
        shown.title = "Sure?"
        shown.colour = ""
        return shown
    }
}

/// The waiting key of "ask first": which key, which press, and until when (seconds since the Mac started).
public struct PressAgain: Equatable, Sendable {
    public struct Waiting: Equatable, Sendable {
        public var key: UUID
        public var long: Bool
        public var twice: Bool
        public var until: TimeInterval
    }

    public enum Step: Equatable, Sendable {
        /// The key asks first: it now waits for the second press. Nothing runs.
        case wait
        /// The second press came in time: run the press that was waiting (long / twice as it was).
        case run(long: Bool, twice: Bool)
        /// A key that does not ask: run as usual.
        case usual
    }

    public private(set) var waiting: Waiting?
    public init() {}

    /// A press of a key. Any press of another key ends a wait (nothing runs for the waiting key).
    public mutating func press(_ key: UUID, asks: Bool, long: Bool, twice: Bool, at now: TimeInterval) -> Step {
        if let waiting, waiting.key == key, now <= waiting.until {
            self.waiting = nil
            return .run(long: waiting.long, twice: waiting.twice)
        }
        waiting = nil
        guard asks else { return .usual }
        waiting = Waiting(key: key, long: long, twice: twice, until: now + AskFirst.window)
        return .wait
    }

    /// The wait is over (time ran out): true when a key stopped waiting, so it must be drawn again.
    public mutating func expire(at now: TimeInterval) -> Bool {
        guard let waiting, now > waiting.until else { return false }
        self.waiting = nil
        return true
    }

    /// The key that waits for its second press right now, if any.
    public func waitingKey(at now: TimeInterval) -> UUID? {
        guard let waiting, now <= waiting.until else { return nil }
        return waiting.key
    }
}

extension DeckAction {
    /// The same action without the Mac's own question (0.27): after "press again" the key has asked already.
    public var withoutAsking: DeckAction {
        var action = self
        if action.type == .macDo { action.quiet = true }
        if action.type == .multi { action.steps = action.steps.map(\.withoutAsking) }
        return action
    }
}
