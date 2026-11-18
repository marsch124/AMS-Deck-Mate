import Foundation

// The 0.11 rules: keys that show something at a glance (the next event, the weather, what is due
// today, the album cover, the Body Battery) and the desk key that puts windows back in place.

/// What a glance key shows: large words in place of its drawing, small words under them.
public struct Glance: Equatable, Sendable {
    /// The large words ("14:30", "3°", "27"). Empty = the key keeps its drawing.
    public var big: String
    /// The small words under them, when the key has no title of its own.
    public var words: String
    /// The key's colour while it shows this (green, amber, red …); nil = the colour of its kind.
    public var tone: KeyKind?

    public init(big: String = "", words: String = "", tone: KeyKind? = nil) {
        self.big = big
        self.words = words
        self.tone = tone
    }
}

public enum GlanceKeys {
    /// How a key as it shows right now names large words in place of its drawing: "text:<words>". Never saved.
    public static let textPrefix = "text:"
    /// How a key as it shows right now names the album cover it shows: "cover:<track>". Never saved.
    public static let coverPrefix = "cover:"

    /// The names the glances go by in `LiveKeys.glances`.
    public static let event = "event"
    public static let due = "due"
    public static let battery = "battery"
    public static func weather(_ town: String) -> String { "weather:" + WeatherKeys.name(town) }

    /// The large words of a key as it shows now; nil when it shows a drawing.
    public static func bigWords(_ icon: String) -> String? {
        guard icon.hasPrefix(textPrefix) else { return nil }
        let words = String(icon.dropFirst(textPrefix.count))
        return words.isEmpty ? nil : words
    }

    /// The track whose cover a key shows right now; nil when it shows a drawing.
    public static func coverTrack(_ icon: String) -> String? {
        guard icon.hasPrefix(coverPrefix) else { return nil }
        let track = String(icon.dropFirst(coverPrefix.count))
        return track.isEmpty ? nil : track
    }
}

/// "Next event" keys: the next event of the calendar that has a time.
public enum EventKeys {
    public struct Event: Equatable, Sendable {
        public var title: String
        public var start: Date
        public var end: Date
        public var allDay: Bool
        public init(title: String, start: Date, end: Date, allDay: Bool = false) {
            self.title = title
            self.start = start
            self.end = end
            self.allDay = allDay
        }
    }

    /// The app a press opens when none is picked: the Mac's Calendar.
    public static let calendarApp = "com.apple.iCal"
    /// How far ahead the key looks, in days.
    public static let daysAhead = 7
    /// The words while the Mac has not been asked yet, and when it said no.
    public static let askWords = "Press to allow"
    public static let refusedWords = "Calendar not allowed"

    /// The event to show: the one that starts first among those with a time that have not ended
    /// yet. All-day events are left out. An event going on right now counts until it ends.
    public static func next(_ events: [Event], now: Date) -> Event? {
        events.filter { !$0.allDay && $0.end > now }.min { $0.start < $1.start }
    }

    private static let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private static func two(_ n: Int) -> String { n < 10 ? "0\(n)" : "\(n)" }

    /// A time of day as "09:05".
    public static func clock(_ date: Date, calendar: Calendar) -> String {
        two(calendar.component(.hour, from: date)) + ":" + two(calendar.component(.minute, from: date))
    }

    /// What the key shows: "Now" while the event goes on, "12 min" in its last hour before the
    /// start, its time ("14:30") later today, its weekday ("Wed") with the time before the title on
    /// another day. No event in the next seven days = a dash and "No events".
    public static func glance(_ event: Event?, now: Date, calendar: Calendar) -> Glance {
        guard let event else { return Glance(big: "–", words: "No events") }
        let title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = title.isEmpty ? "Event" : title
        if event.start <= now { return Glance(big: "Now", words: words) }
        let minutes = Int((event.start.timeIntervalSince(now) / 60).rounded(.up))
        if minutes < 60 { return Glance(big: "\(minutes) min", words: words) }
        if calendar.isDate(event.start, inSameDayAs: now) {
            return Glance(big: clock(event.start, calendar: calendar), words: words)
        }
        let day = days[(calendar.component(.weekday, from: event.start) - 1) % 7]
        return Glance(big: day, words: clock(event.start, calendar: calendar) + " " + words)
    }
}

/// "Weather" keys: the temperature and the sky of a town, from the free service Open-Meteo.
public enum WeatherKeys {
    public struct Now: Equatable, Sendable {
        /// Degrees Celsius.
        public var temperature: Double
        /// The weather's number, as the weather services of the world write it (WMO code).
        public var code: Int
        public init(temperature: Double, code: Int) {
            self.temperature = temperature
            self.code = code
        }
    }

    public struct Place: Equatable, Sendable {
        public var latitude: Double
        public var longitude: Double
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        /// "59.33,18.07", for keeping.
        public var text: String { "\(latitude),\(longitude)" }
        public init?(text: String) {
            let parts = text.split(separator: ",").compactMap { Double($0) }
            guard parts.count == 2, (-90...90).contains(parts[0]), (-180...180).contains(parts[1]) else { return nil }
            self.init(latitude: parts[0], longitude: parts[1])
        }
    }

    /// The app a press opens: the Mac's Weather.
    public static let weatherApp = "com.apple.weather"
    /// The weather is asked for again after this many minutes.
    public static let everyMinutes = 20
    public static let noTownWords = "Set a town"

    /// A town as the lists know it: without spaces around it, in small letters.
    public static func name(_ town: String) -> String {
        town.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// How many towns typed before are offered again.
    public static let remembers = 6

    /// The towns typed before, after `town` was used: newest first, each once (whatever its capitals), at most six.
    public static func remembered(_ list: [String], adding town: String) -> [String] {
        let new = town.trimmingCharacters(in: .whitespacesAndNewlines)
        var seen = Set<String>()
        return Array(([new] + list).filter { !name($0).isEmpty && seen.insert(name($0)).inserted }.prefix(remembers))
    }

    /// The sky in a word or two.
    public static func sky(_ code: Int) -> String {
        switch code {
        case 0: return "Clear"
        case 1: return "Mostly clear"
        case 2: return "Partly cloudy"
        case 3: return "Cloudy"
        case 45, 48: return "Fog"
        case 51...57: return "Drizzle"
        case 61...67: return "Rain"
        case 71...77: return "Snow"
        case 80...82: return "Showers"
        case 85, 86: return "Snow showers"
        case 95...99: return "Thunder"
        default: return "Weather"
        }
    }

    /// "3°", "-4°"; never "-0°".
    public static func degrees(_ temperature: Double) -> String {
        let whole = Int(temperature.rounded())
        return "\(whole)°"
    }

    public static func glance(_ now: Now?) -> Glance? {
        now.map { Glance(big: degrees($0.temperature), words: sky($0.code)) }
    }

    /// A temperature older than this turns the key grey-blue and says when it is from.
    public static let staleAfter: TimeInterval = 2 * 3600

    /// The glance with its age: older than two hours = grey-blue, with "As of 14:20" in the small words.
    public static func glance(_ now: Now?, fetched: Date?, at current: Date, calendar: Calendar = .current) -> Glance? {
        guard var glance = glance(now) else { return nil }
        if let fetched, current.timeIntervalSince(fetched) > staleAfter {
            let parts = calendar.dateComponents([.hour, .minute], from: fetched)
            glance.words = String(format: "As of %02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
            glance.tone = .move
        }
        return glance
    }

    /// Where the service is asked for a town's place. Only the town's name goes out.
    public static func searchURL(_ town: String) -> URL? {
        var parts = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        parts?.queryItems = [URLQueryItem(name: "name", value: town.trimmingCharacters(in: .whitespacesAndNewlines)),
                             URLQueryItem(name: "count", value: "1")]
        return parts?.url
    }

    /// Where the service is asked for the weather at a place. Only the place goes out.
    public static func weatherURL(_ place: Place) -> URL? {
        var parts = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        parts?.queryItems = [URLQueryItem(name: "latitude", value: String(place.latitude)),
                             URLQueryItem(name: "longitude", value: String(place.longitude)),
                             URLQueryItem(name: "current", value: "temperature_2m,weather_code")]
        return parts?.url
    }

    /// The first place in the service's answer to a search; nil when it found no such town.
    public static func place(fromSearch data: Data) -> Place? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let first = (json["results"] as? [[String: Any]])?.first,
              let latitude = (first["latitude"] as? NSNumber)?.doubleValue,
              let longitude = (first["longitude"] as? NSNumber)?.doubleValue else { return nil }
        return Place(latitude: latitude, longitude: longitude)
    }

    /// The weather right now in the service's answer.
    public static func now(fromWeather data: Data) -> Now? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let current = json["current"] as? [String: Any],
              let temperature = (current["temperature_2m"] as? NSNumber)?.doubleValue,
              let code = (current["weather_code"] as? NSNumber)?.intValue else { return nil }
        return Now(temperature: temperature, code: code)
    }
}

/// "Body Battery" keys: the latest Body Battery from the AMS Garmin Bridge Board on this Mac.
public enum BatteryKeys {
    /// The board's page on this Mac: what a press opens.
    public static let board = "http://127.0.0.1:7788/"
    /// Where the board hands out its numbers.
    public static let boardData = "http://127.0.0.1:7788/api/board"
    /// The board is asked again after this many minutes.
    public static let everyMinutes = 10
    public static let words = "Body Battery"

    /// The latest Body Battery (0–100) in the board's answer; nil when it has none.
    public static func level(fromBoard data: Data) -> Int? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let today = json["today"] as? [String: Any],
              let battery = today["bodyBattery"] as? [String: Any],
              let latest = (battery["latest"] as? NSNumber)?.intValue, (0...100).contains(latest) else { return nil }
        return latest
    }

    /// The key's colour: green from 50, teal from 25, amber below (the body's numbers never turn a key
    /// red); grey-blue while there is no number, or while the number is hours old.
    public static func kind(_ level: Int?) -> KeyKind {
        guard let level else { return .move }
        return level >= 50 ? .media : level >= 25 ? .web : .text
    }

    /// `old` = when the watch last sent its numbers, when that is hours ago: the small words say so.
    public static func glance(_ level: Int?, old: Date? = nil, zone: TimeZone = .current) -> Glance? {
        level.map { Glance(big: String($0), words: old.map { GarminKeys.oldWords($0, zone: zone) } ?? words) }
    }
}

/// "Album cover" keys: the cover of what Spotify plays.
public enum CoverKeys {
    public struct Now: Equatable, Sendable {
        /// Spotify's own name for the track (letters and digits only).
        public var track: String
        public var song: String
        public var artist: String
        public var playing: Bool
        public init(track: String, song: String = "", artist: String = "", playing: Bool = false) {
            self.track = track
            self.song = song
            self.artist = artist
            self.playing = playing
        }
    }

    public static let idleWords = "Nothing playing"

    /// The track's name from what Spotify says ("spotify:track:4uLU6hMCjMI75M1A2tKUQC"); nil for
    /// anything that is not a track (a podcast episode, an advert, a local file).
    public static func track(_ said: String?) -> String? {
        let head = "spotify:track:"
        guard let said, said.hasPrefix(head) else { return nil }
        let name = String(said.dropFirst(head.count))
        let letters = name.unicodeScalars.allSatisfy { $0.isASCII && CharacterSet.alphanumerics.contains($0) }
        guard !name.isEmpty, name.count <= 40, letters else { return nil }
        return name
    }

    /// Where Spotify's open lookup says which picture belongs to a track.
    public static func lookupURL(_ track: String) -> URL? {
        URL(string: "https://open.spotify.com/oembed?url=https://open.spotify.com/track/" + track)
    }

    /// The cover's address in the lookup's answer; only a safe (https) address counts.
    public static func pictureURL(fromLookup data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = json["thumbnail_url"] as? String, text.lowercased().hasPrefix("https://") else { return nil }
        return URL(string: text)
    }
}

/// "Desk" keys: a set of apps, each with the place and size of its window.
public enum DeskKeys {
    /// One app's window: its top left corner and its size, in the Mac's own points (0, 0 = top left of the main screen).
    public struct Spot: Equatable, Sendable {
        public var app: String
        public var x: Int
        public var y: Int
        public var width: Int
        public var height: Int
        public init(app: String, x: Int, y: Int, width: Int, height: Int) {
            self.app = app
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
        /// "1200 × 800".
        public var size: String { "\(width) × \(height)" }
    }

    /// A desk holds at most this many apps.
    public static let most = 8
    /// A window smaller than this is not a window to put in place (a palette, a small panel).
    public static let smallest = (width: 200, height: 150)

    /// A spot as one step of the key: "open this app", with the window's place in its name.
    public static func step(_ spot: Spot) -> DeckAction {
        DeckAction(type: .app, target: spot.app, name: "\(spot.x),\(spot.y),\(spot.width),\(spot.height)")
    }

    public static func spot(_ step: DeckAction) -> Spot? {
        let parts = step.name.split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard step.type == .app, !step.target.isEmpty, parts.count == 4,
              let x = parts[0], let y = parts[1], let width = parts[2], let height = parts[3],
              width > 0, height > 0 else { return nil }
        return Spot(app: step.target, x: x, y: y, width: width, height: height)
    }

    public static func spots(of action: DeckAction) -> [Spot] { action.steps.compactMap(spot) }

    /// The desk as it is now, from the windows on screen (front to back): the front window of each
    /// app, without Deck Mate's own (`skip`) and without small panels, at most eight apps.
    public static func capture(_ windows: [Spot], skip: String) -> [Spot] {
        var seen = Set<String>()
        var found: [Spot] = []
        for window in windows where !window.app.isEmpty && window.app != skip
            && window.width >= smallest.width && window.height >= smallest.height {
            guard seen.insert(window.app).inserted else { continue }
            found.append(window)
            if found.count == most { break }
        }
        return found
    }
}

extension Deck {
    /// The town of the weather key with this id; nil when there is no such weather key.
    public func town(ofKey id: UUID) -> String? {
        let keys = profiles.flatMap { $0.pages.flatMap { $0.keys.values } } + Array(favourites.values)
        return keys.first { $0.id == id && $0.action.type.hasTown }?.action.target
    }

    /// Gives the weather key with this id another town. Nothing else changes.
    public mutating func setTown(_ town: String, forKey id: UUID) {
        let new = town.trimmingCharacters(in: .whitespacesAndNewlines)
        for group in profiles.indices {
            for page in profiles[group].pages.indices {
                for (slot, key) in profiles[group].pages[page].keys where key.id == id && key.action.type.hasTown {
                    profiles[group].pages[page].keys[slot]?.action.target = new
                }
            }
        }
        for (slot, key) in favourites where key.id == id && key.action.type.hasTown {
            favourites[slot]?.action.target = new
        }
    }

    /// Every action of the setup: keys, long presses, favourites, and the steps inside them.
    public var allActions: [DeckAction] {
        func with(_ action: DeckAction?) -> [DeckAction] {
            guard let action else { return [] }
            return [action] + action.steps.flatMap { with($0) }
        }
        let keys = profiles.flatMap { $0.pages.flatMap { $0.keys.values } } + Array(favourites.values)
        return keys.flatMap { with($0.action) + with($0.held) }
    }

    /// The towns of the weather keys, each once, as he wrote them.
    public var weatherTowns: [String] {
        var seen = Set<String>()
        return allActions.filter { $0.type == .weather }
            .map { $0.target.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert(WeatherKeys.name($0)).inserted }
    }
}
