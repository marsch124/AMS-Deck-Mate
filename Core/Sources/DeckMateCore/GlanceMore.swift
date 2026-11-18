import Foundation

// The 0.12 rules: more keys that show something at a glance. Five Garmin numbers from the board
// on this Mac, three numbers of the Mac itself, the time in another town, sunrise and sunset, and
// how long he is free until the next event.

extension GlanceKeys {
    public static let free = "free"
    public static func garmin(_ number: GarminKeys.Number) -> String { "garmin:" + number.rawValue }
    public static func mac(_ number: MacNowKeys.Number) -> String { "mac:" + number.rawValue }
    public static func clock(_ town: String) -> String { "clock:" + WeatherKeys.name(town) }
    public static func sun(_ town: String) -> String { "sun:" + WeatherKeys.name(town) }
}

extension ActionType {
    /// Keys that belong to a town (their target): a long press asks for another one.
    public var hasTown: Bool { self == .weather || self == .worldClock || self == .sunTimes }
}

/// "Garmin number" keys: one number each from the AMS Garmin Bridge Board on this Mac.
public enum GarminKeys {
    public enum Number: String, CaseIterable, Sendable {
        case steps, sleep, pulse, stress, workouts

        public var title: String {
            switch self {
            case .steps: return "Steps today"
            case .sleep: return "Sleep last night"
            case .pulse: return "Resting pulse"
            case .stress: return "Stress today"
            case .workouts: return "Workouts, 7 days"
            }
        }

        public var icon: String {
            switch self {
            case .steps: return "shoes"
            case .sleep: return "sleep"
            case .pulse: return "heart"
            case .stress: return "pulse"
            case .workouts: return "run"
            }
        }
    }

    /// The number a key shows, from its target; anything odd counts as steps.
    public static func number(_ target: String) -> Number { Number(rawValue: target) ?? .steps }

    /// A count with a space between the thousands: "12 345".
    public static func count(_ value: Int) -> String {
        let digits = String(abs(value))
        var out = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index) % 3 == 0 { out += " " }
            out.append(digit)
        }
        return (value < 0 ? "-" : "") + out
    }

    /// Hours and minutes as "7:24".
    public static func hours(seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        return "\(minutes / 60):" + (minutes % 60 < 10 ? "0" : "") + "\(minutes % 60)"
    }

    /// Garmin's own steps of stress: resting to 25, low to 50, medium to 75, high above.
    public static func stress(_ level: Int) -> (words: String, tone: KeyKind) {
        switch level {
        case ...25: return ("Resting", .media)
        case 26...50: return ("Low stress", .web)
        case 51...75: return ("Medium stress", .text)
        default: return ("High stress", .raycast)
        }
    }

    private static func whole(_ value: Any?) -> Int? { (value as? NSNumber).map { Int($0.doubleValue.rounded()) } }

    /// What each Garmin key shows, from the board's answer. A number the board does not have is left out.
    public static func glances(fromBoard data: Data) -> [Number: Glance] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        let today = json["today"] as? [String: Any] ?? [:]
        var all: [Number: Glance] = [:]
        if let steps = whole(today["steps"]) {
            // Green once the day's goal is reached.
            let goal = whole(today["stepGoal"]) ?? 0
            all[.steps] = Glance(big: count(steps), words: Number.steps.title, tone: goal > 0 && steps >= goal ? .media : nil)
        }
        if let sleep = json["sleep"] as? [String: Any] {
            if sleep["recorded"] as? Bool == true, let seconds = whole(sleep["seconds"]) {
                let word = (sleep["qualifier"] as? String ?? "").trimmingCharacters(in: .whitespaces)
                all[.sleep] = Glance(big: hours(seconds: seconds), words: word.isEmpty ? "Sleep" : word.prefix(1).uppercased() + word.dropFirst().lowercased())
            } else {
                all[.sleep] = Glance(big: "–", words: "No sleep recorded")
            }
        }
        if let pulse = whole(today["restingHr"]), pulse > 0 {
            // Against the average of the last seven days: amber from 5 beats over it, red from 8.
            let week = ((json["restingTrend"] as? [String: Any])?["avg7"] as? [[String: Any]])?.last.flatMap { whole($0["bpm"]) }
            let over = week.map { pulse - $0 } ?? 0
            all[.pulse] = Glance(big: String(pulse), words: over >= 5 ? "+\(over) over usual" : Number.pulse.title,
                                 tone: over >= 8 ? .raycast : over >= 5 ? .text : nil)
        }
        if let level = whole(today["stressAvg"]), level >= 0 {
            let now = stress(level)
            all[.stress] = Glance(big: String(level), words: now.words, tone: now.tone)
        }
        if let week = (json["recentWorkouts"] as? [String: Any])?["last7"] as? [String: Any], let done = whole(week["count"]) {
            let hours = (whole(week["seconds"]) ?? 0) / 3600
            all[.workouts] = Glance(big: String(done), words: hours > 0 ? "7 days · \(hours) h" : Number.workouts.title)
        }
        return all
    }
}

/// "Mac at a glance" keys: the battery, the free space, and how busy the Mac is.
public enum MacNowKeys {
    public enum Number: String, CaseIterable, Sendable {
        case battery, space, busy

        public var title: String {
            switch self {
            case .battery: return "Mac battery"
            case .space: return "Free space"
            case .busy: return "Mac busy light"
            }
        }

        public var icon: String {
            switch self {
            case .battery: return "battery"
            case .space: return "deck-folder"
            case .busy: return "deck-multi"
            }
        }

        /// What a press opens: a part of System Settings, or (busy) the Activity Monitor app.
        public var opens: String {
            switch self {
            case .battery: return "x-apple.systempreferences:com.apple.Battery-Settings.extension"
            case .space: return "x-apple.systempreferences:com.apple.settings.Storage"
            case .busy: return "com.apple.ActivityMonitor"
            }
        }
    }

    public static func number(_ target: String) -> Number { Number(rawValue: target) ?? .battery }

    /// Green from 40 %, amber from 20 %, red below. A Mac without a battery says so.
    public static func battery(percent: Int?, charging: Bool) -> Glance {
        guard let percent else { return Glance(words: "No battery") }
        return Glance(big: "\(percent)%", words: charging ? "Charging" : Number.battery.title,
                      tone: percent >= 40 ? .media : percent >= 20 ? .text : .raycast)
    }

    /// Room as "212 GB", "8.4 GB" (under ten) or "1.2 TB".
    public static func room(_ bytes: Int64) -> String {
        let gigabytes = Double(max(0, bytes)) / 1_000_000_000
        if gigabytes >= 1000 { return String(format: "%.1f TB", gigabytes / 1000) }
        if gigabytes < 10 { return String(format: "%.1f GB", gigabytes) }
        return "\(Int(gigabytes.rounded())) GB"
    }

    /// Red when less than 10 GB or a twentieth is free, amber under 25 GB or a tenth.
    public static func space(free: Int64?, total: Int64?) -> Glance {
        guard let free, let total, total > 0 else { return Glance(words: Number.space.title) }
        let part = Double(free) / Double(total)
        let tone: KeyKind? = free < 10_000_000_000 || part < 0.05 ? .raycast : free < 25_000_000_000 || part < 0.10 ? .text : nil
        return Glance(big: room(free), words: Number.space.title, tone: tone)
    }

    /// The share of the Mac's processors at work between two readings of their clocks (0 to 1).
    public static func load(before: (busy: UInt64, all: UInt64), after: (busy: UInt64, all: UInt64)) -> Double? {
        guard after.all > before.all, after.busy >= before.busy else { return nil }
        return min(1, Double(after.busy - before.busy) / Double(after.all - before.all))
    }

    /// In steps of five, so the key does not flicker: amber from 60 %, red from 85 %.
    public static func busy(_ load: Double?) -> Glance {
        guard let load else { return Glance(words: Number.busy.title) }
        let percent = Int((min(1, max(0, load)) * 20).rounded()) * 5
        return Glance(big: "\(percent)%", words: percent >= 85 ? "Mac very busy" : percent >= 60 ? "Mac busy" : "Mac calm",
                      tone: percent >= 85 ? .raycast : percent >= 60 ? .text : nil)
    }
}

/// "World clock" keys: the time in another town.
public enum ClockKeys {
    /// The app a press opens: the Mac's Clock.
    public static let clockApp = "com.apple.clock"

    /// The time there, and under it the town (the key's own words) — or, when it is another day
    /// there than here, "tomorrow" or "yesterday".
    public static func glance(zone: TimeZone, now: Date, here: TimeZone) -> Glance {
        var there = Calendar(identifier: .gregorian)
        there.timeZone = zone
        var home = Calendar(identifier: .gregorian)
        home.timeZone = here
        let day = { (calendar: Calendar) -> Int in
            let parts = calendar.dateComponents([.year, .month, .day], from: now)
            return (parts.year ?? 0) * 10_000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
        }
        let words = day(there) > day(home) ? "tomorrow" : day(there) < day(home) ? "yesterday" : ""
        return Glance(big: EventKeys.clock(now, calendar: there), words: words)
    }

    /// The time zone's name in the service's answer to a search ("Europe/Stockholm").
    public static func zone(fromSearch data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let first = (json["results"] as? [[String: Any]])?.first,
              let name = first["timezone"] as? String, TimeZone(identifier: name) != nil else { return nil }
        return name
    }
}

/// "Sunrise and sunset" keys: whichever comes next in a town.
public enum SunKeys {
    public struct Times: Equatable, Sendable {
        /// The town's own clock times, as the service writes them: "2026-11-18T08:07".
        public var sunrise: [String]
        public var sunset: [String]
        /// How far the town's clock is ahead of the world's (UTC), in seconds.
        public var offset: Int
        public init(sunrise: [String], sunset: [String], offset: Int) {
            self.sunrise = sunrise
            self.sunset = sunset
            self.offset = offset
        }
    }

    /// The times are asked for again after this many hours.
    public static let everyHours = 6

    /// Where the service is asked for today's and tomorrow's sunrise and sunset. Only the place goes out.
    public static func url(_ place: WeatherKeys.Place) -> URL? {
        var parts = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        parts?.queryItems = [URLQueryItem(name: "latitude", value: String(place.latitude)),
                             URLQueryItem(name: "longitude", value: String(place.longitude)),
                             URLQueryItem(name: "daily", value: "sunrise,sunset"),
                             URLQueryItem(name: "timezone", value: "auto"),
                             URLQueryItem(name: "forecast_days", value: "2")]
        return parts?.url
    }

    public static func times(fromAnswer data: Data) -> Times? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let daily = json["daily"] as? [String: Any],
              let sunrise = daily["sunrise"] as? [String], let sunset = daily["sunset"] as? [String],
              let offset = (json["utc_offset_seconds"] as? NSNumber)?.intValue else { return nil }
        return Times(sunrise: sunrise, sunset: sunset, offset: offset)
    }

    /// The moment a town's clock time stands for; nil when it is not written as expected.
    static func moment(_ text: String, offset: Int) -> Date? {
        let numbers = text.split(whereSeparator: { "-T:".contains($0) }).compactMap { Int($0) }
        guard numbers.count >= 5 else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let parts = DateComponents(year: numbers[0], month: numbers[1], day: numbers[2], hour: numbers[3], minute: numbers[4])
        return calendar.date(from: parts)?.addingTimeInterval(-Double(offset))
    }

    /// The next sunrise or sunset: its time on the town's clock, with "Sunrise" or "Sunset" under it.
    public static func glance(_ times: Times?, now: Date) -> Glance? {
        guard let times else { return nil }
        let all = times.sunrise.map { ($0, "Sunrise") } + times.sunset.map { ($0, "Sunset") }
        let next = all.compactMap { text, words in moment(text, offset: times.offset).map { (at: $0, text: text, words: words) } }
            .filter { $0.at > now }.min { $0.at < $1.at }
        guard let next, let clock = next.text.split(separator: "T").last else { return nil }
        return Glance(big: String(clock.prefix(5)), words: next.words)
    }
}

extension EventKeys {
    /// A length of time as "45 min" or "1 h 20".
    public static func length(minutes: Int) -> String {
        let m = max(0, minutes)
        return m < 60 ? "\(m) min" : "\(m / 60) h " + (m % 60 < 10 ? "0" : "") + "\(m % 60)"
    }

    /// "Free until": "Busy" (red) with the end while an event goes on; else how long he is free
    /// until the next event of today that has a time (green); else "Free" for the rest of the day.
    public static func freeGlance(_ events: [Event], now: Date, calendar: Calendar) -> Glance {
        let timed = events.filter { !$0.allDay && $0.end > now }
        if let end = timed.filter({ $0.start <= now }).map(\.end).max() {
            return Glance(big: "Busy", words: "until " + clock(end, calendar: calendar), tone: .raycast)
        }
        if let next = timed.filter({ calendar.isDate($0.start, inSameDayAs: now) }).min(by: { $0.start < $1.start }) {
            let minutes = Int((next.start.timeIntervalSince(now) / 60).rounded(.down))
            return Glance(big: length(minutes: minutes), words: "Free until " + clock(next.start, calendar: calendar), tone: .media)
        }
        return Glance(big: "Free", words: "Rest of the day", tone: .media)
    }
}

extension Deck {
    /// The towns of the keys of one kind (weather, world clock, sunrise and sunset), each once, as he wrote them.
    public func towns(of type: ActionType) -> [String] {
        var seen = Set<String>()
        return allActions.filter { $0.type == type }
            .map { $0.target.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert(WeatherKeys.name($0)).inserted }
    }

    /// The Spotify links of the playlist keys, each once.
    public var playlistLinks: [String] {
        var seen = Set<String>()
        return allActions.filter { $0.type == .playlist }.map(\.target)
            .filter { link in PlaylistKeys.coverName(link).map { seen.insert($0).inserted } ?? false }
    }

    /// Every town on a key of any kind, each once.
    public var allTowns: [String] {
        var seen = Set<String>()
        return (towns(of: .weather) + towns(of: .worldClock) + towns(of: .sunTimes)).filter { seen.insert(WeatherKeys.name($0)).inserted }
    }

    /// The numbers the "Garmin number" and "Mac at a glance" keys of the setup show.
    public var macNumbers: Set<MacNowKeys.Number> {
        Set(allActions.filter { $0.type == .macNow }.map { MacNowKeys.number($0.target) })
    }
}
