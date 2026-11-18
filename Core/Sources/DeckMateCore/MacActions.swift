import Foundation

// The 0.13 rules: things a key does on the Mac (lock it, show the desktop, quit all apps, empty the
// bin, eject all disks, paste as plain text), joining a meeting, a Spotify playlist, searching for
// the copied text, counters and stopwatches.

/// What an "On the Mac" key does (its target).
public enum MacDo: String, CaseIterable, Sendable {
    case lock, desktop, quitAll, emptyBin, ejectAll, pastePlain

    /// In the list of "Set up keys".
    public var title: String {
        switch self {
        case .lock: return "Lock the Mac"
        case .desktop: return "Show the desktop"
        case .quitAll: return "Quit all apps"
        case .emptyBin: return "Empty the bin"
        case .ejectAll: return "Eject all disks"
        case .pastePlain: return "Paste as plain text"
        }
    }

    /// The words on a key without a title.
    public var short: String {
        switch self {
        case .lock: return "Lock"
        case .desktop: return "Desktop"
        case .quitAll: return "Quit all"
        case .emptyBin: return "Empty bin"
        case .ejectAll: return "Eject"
        case .pastePlain: return "Paste plain"
        }
    }

    public var icon: String {
        switch self {
        case .lock: return "app-lock"
        case .desktop: return "laptop"
        case .quitAll: return "control-closeCircle"
        case .emptyBin: return "app-bin"
        case .ejectAll: return "deck-eject"
        case .pastePlain: return "deck-clipboard"
        }
    }

    /// It can ask before it does its thing: what it does is not taken back with a press.
    public var canAsk: Bool { self == .quitAll || self == .emptyBin || self == .ejectAll }
}

public enum MacDoKeys {
    /// What the key does, from its target; anything odd counts as the harmless one.
    public static func what(_ target: String) -> MacDo { MacDo(rawValue: target) ?? .desktop }

    /// True when the key asks on the Mac before it acts. On such a key `quiet` means "without asking".
    public static func asks(_ action: DeckAction) -> Bool { what(action.target).canAsk && !action.quiet }

    /// A few words on what a press did, for the iPhone.
    public static func done(_ action: DeckAction) -> String {
        let what = what(action.target)
        if asks(action) { return "Asks on the Mac: \(what.title.prefix(1).lowercased() + what.title.dropFirst())" }
        switch what {
        case .lock: return "Locked the Mac"
        case .desktop: return "Showed the desktop"
        case .quitAll: return "Quit all apps"
        case .emptyBin: return "Emptied the bin"
        case .ejectAll: return "Ejected the disks"
        case .pastePlain: return "Pasted as plain text"
        }
    }
}

/// Names in a row, the way a sentence lists them: "A", "A and B", "A, B and C", "A, B, C and 4 more".
public enum Listing {
    public static func words(_ names: [String], limit: Int = 6) -> String {
        let shown = Array(names.prefix(limit))
        let more = names.count - shown.count
        if more > 0 { return shown.joined(separator: ", ") + " and \(more) more" }
        guard let last = shown.last else { return "" }
        return shown.count == 1 ? last : shown.dropLast().joined(separator: ", ") + " and " + last
    }
}

/// "Quit all apps": which apps quit, and the question before.
public enum QuitKeys {
    /// The Mac needs its Finder: it is never quit.
    public static let finder = "com.apple.finder"

    /// The apps the key leaves open: its steps, each an app.
    public static func spared(_ action: DeckAction) -> [String] {
        action.steps.filter { $0.type == .app && !$0.target.isEmpty }.map(\.target)
    }

    /// The open apps that quit: all but the Finder, Deck Mate itself (`own`) and the spared ones. Each once.
    public static func toQuit(open: [String], spared: [String], own: String) -> [String] {
        let keep = Set((spared + [finder, own]).map { $0.lowercased() })
        var seen = Set<String>()
        return open.filter { !$0.isEmpty && !keep.contains($0.lowercased()) && seen.insert($0.lowercased()).inserted }
    }

    /// The question before the apps quit; nil = nothing to quit. `stays` = the names of the open apps that stay.
    public static func question(names: [String], stays: [String]) -> (title: String, words: String)? {
        guard !names.isEmpty else { return nil }
        let title = names.count == 1 ? "Quit \(names[0])?" : "Quit \(names.count) apps?"
        var words = Listing.words(names) + " will quit. An app with unsaved work asks you first."
        if !stays.isEmpty { words += " Stays open: " + Listing.words(stays) + "." }
        return (title, words)
    }
}

/// "Empty the bin": the question before.
public enum BinKeys {
    public static func question(count: Int) -> (title: String, words: String)? {
        guard count > 0 else { return nil }
        let things = count == 1 ? "1 thing" : "\(count) things"
        return ("Empty the bin?", "\(things) will be gone for good. This cannot be undone.")
    }
}

/// "Eject all disks": which disks, and the question before.
public enum EjectKeys {
    public struct Volume: Equatable, Sendable {
        public var name: String
        /// Where the Mac shows it: "/Volumes/T7".
        public var path: String
        /// Built into the Mac.
        public var isInternal: Bool
        /// The Mac says it can be ejected (a disk picture, a card, a stick).
        public var isEjectable: Bool
        /// False for a share on another computer.
        public var isLocal: Bool

        public init(name: String, path: String, isInternal: Bool, isEjectable: Bool, isLocal: Bool = true) {
            self.name = name
            self.path = path
            self.isInternal = isInternal
            self.isEjectable = isEjectable
            self.isLocal = isLocal
        }
    }

    /// The disks to eject: every disk that is plugged in or can be ejected. Never the Mac's own
    /// disk, never anything outside /Volumes, never a share on another computer.
    public static func toEject(_ volumes: [Volume]) -> [Volume] {
        volumes.filter { $0.isLocal && $0.path.hasPrefix("/Volumes/") && ($0.isEjectable || !$0.isInternal) }
    }

    /// The question before; nil = no disk to eject.
    public static func question(names: [String]) -> (title: String, words: String)? {
        guard !names.isEmpty else { return nil }
        let title = names.count == 1 ? "Eject \(names[0])?" : "Eject \(names.count) disks?"
        let words = names.count == 1 ? "The disk will be ejected. After that it is safe to unplug."
                                     : Listing.words(names) + " will be ejected. After that they are safe to unplug."
        return (title, words)
    }

    /// What to say when disks stayed; nil = all are gone.
    public static func stayed(_ names: [String]) -> String? {
        guard !names.isEmpty else { return nil }
        return Listing.words(names) + (names.count == 1 ? " is" : " are") + " still in use and could not be ejected. Close what uses it, then press the key again."
    }
}

/// "Join the meeting": the video link of the meeting that is about to start, going on, or next.
public enum MeetingKeys {
    /// Where video meetings live.
    static let hosts = ["zoom.us", "zoom.com", "teams.microsoft.com", "teams.live.com", "meet.google.com", "webex.com",
                        "facetime.apple.com", "whereby.com", "meet.jit.si", "gotomeeting.com", "gotomeet.me", "goto.com",
                        "bluejeans.com", "chime.aws"]
    /// A meeting that starts this soon wins over the one still going on.
    public static let soon = 600.0
    /// How far ahead it looks.
    public static let ahead = 86_400.0

    public struct Event: Equatable, Sendable {
        public var title: String
        public var start: Date
        public var end: Date
        /// Where a link can be: the event's own link, its place, its notes.
        public var texts: [String]

        public init(title: String, start: Date, end: Date, texts: [String]) {
            self.title = title
            self.start = start
            self.end = end
            self.texts = texts
        }
    }

    /// The first video-meeting link in these texts, in their order; nil = none.
    public static func link(in texts: [String]) -> String? {
        for text in texts {
            for piece in text.split(whereSeparator: { $0.isWhitespace || "<>\"'()[]".contains($0) }) {
                var found = String(piece)
                guard let range = found.range(of: "https://", options: .caseInsensitive) else { continue }
                found = String(found[range.lowerBound...])
                while let last = found.last, ".,;:!".contains(last) { found.removeLast() }
                guard let host = URL(string: found)?.host?.lowercased() else { continue }
                if hosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) { return found }
            }
        }
        return nil
    }

    /// The meeting to join, of the events that have a video link: the one that starts within ten
    /// minutes, else the one going on (the one that began last), else the next one within a day.
    public static func pick(_ events: [Event], now: Date) -> (title: String, link: String)? {
        let linked = events.compactMap { event -> (event: Event, link: String)? in
            guard event.end > now, event.start < now.addingTimeInterval(ahead), let link = link(in: event.texts) else { return nil }
            return (event, link)
        }.sorted { $0.event.start < $1.event.start }
        let ahead = linked.filter { $0.event.start > now }
        let chosen = ahead.first(where: { $0.event.start <= now.addingTimeInterval(soon) })
            ?? linked.last(where: { $0.event.start <= now })
            ?? ahead.first
        return chosen.map { ($0.event.title, $0.link) }
    }
}

/// "Spotify playlist": what Spotify is told to play, from the link he pasted.
public enum PlaylistKeys {
    static let kinds = ["playlist", "album", "artist", "track", "show", "episode"]

    /// "spotify:playlist:<id>" from a link of open.spotify.com or from Spotify's own short form; nil = not one.
    public static func uri(_ text: String) -> String? {
        let link = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String]
        if link.lowercased().hasPrefix("spotify:") {
            parts = link.split(separator: ":").map(String.init)
        } else if let url = URL(string: link), let host = url.host?.lowercased(), host == "open.spotify.com" {
            parts = url.path.split(separator: "/").map(String.init)
        } else {
            return nil
        }
        // The kind and its id are the last pair that fits: "user/x/playlist/ID", "intl-de/album/ID".
        guard let at = parts.lastIndex(where: { kinds.contains($0.lowercased()) }), at + 1 < parts.count else { return nil }
        let id = parts[at + 1]
        guard !id.isEmpty, id.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber) }) else { return nil }
        return "spotify:\(parts[at].lowercased()):\(id)"
    }

    /// The name the link's cover goes by ("list-playlist-<id>"); nil = not a Spotify link.
    public static func coverName(_ text: String) -> String? {
        uri(text).map { "list-" + $0.split(separator: ":").dropFirst().joined(separator: "-") }
    }

    /// Where Spotify's open lookup says which picture belongs to the link.
    public static func lookupURL(_ text: String) -> URL? {
        guard let parts = uri(text)?.split(separator: ":"), parts.count == 3 else { return nil }
        return URL(string: "https://open.spotify.com/oembed?url=https://open.spotify.com/\(parts[1])/\(parts[2])")
    }

    /// What the link is, in a word, for the note under the field: "playlist", "album", "song"…
    public static func kind(_ text: String) -> String? {
        guard let uri = uri(text) else { return nil }
        switch uri.split(separator: ":")[1] {
        case "track": return "song"
        case "show": return "podcast"
        case "episode": return "podcast episode"
        case let other: return String(other)
        }
    }
}

/// "Search for the copied text": the address the browser opens.
public enum SearchKeys {
    public enum Engine: String, CaseIterable, Sendable {
        case google, duckduckgo, bing, wikipedia, youtube

        public var title: String {
            switch self {
            case .google: return "Google"
            case .duckduckgo: return "DuckDuckGo"
            case .bing: return "Bing"
            case .wikipedia: return "Wikipedia"
            case .youtube: return "YouTube"
            }
        }

        var start: String {
            switch self {
            case .google: return "https://www.google.com/search?q="
            case .duckduckgo: return "https://duckduckgo.com/?q="
            case .bing: return "https://www.bing.com/search?q="
            case .wikipedia: return "https://en.wikipedia.org/w/index.php?search="
            case .youtube: return "https://www.youtube.com/results?search_query="
            }
        }
    }

    /// Only this much of a long copied text is searched for.
    public static let longest = 300

    public static func engine(_ target: String) -> Engine { Engine(rawValue: target) ?? .google }

    /// The address to open; nil = nothing copied. A copied web address opens as it is.
    public static func address(_ engine: Engine, text: String?) -> String? {
        let line = (text ?? "").split(whereSeparator: \.isWhitespace).joined(separator: " ")
        guard !line.isEmpty else { return nil }
        let lower = line.lowercased()
        if !line.contains(" "), lower.hasPrefix("https://") || lower.hasPrefix("http://"), URL(string: line) != nil { return line }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let asked = String(line.prefix(longest)).trimmingCharacters(in: .whitespaces)
        guard let coded = asked.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
        return engine.start + coded
    }
}

/// Counter keys: every press counts one more; holding the key down sets it back to 0.
public enum CounterKeys {
    public static let most = 99_999

    /// A counter's own name (the key's target), so two counters never share a number.
    public static func newID() -> String { UUID().uuidString }

    public static func count(_ counts: [String: Int], id: String) -> Int { min(most, max(0, counts[id] ?? 0)) }

    /// One more; it stops at 99,999.
    public static func pressed(_ counts: [String: Int], id: String) -> [String: Int] {
        guard !id.isEmpty else { return counts }
        var next = counts
        next[id] = min(most, count(counts, id: id) + 1)
        return next
    }

    public static func reset(_ counts: [String: Int], id: String) -> [String: Int] {
        var next = counts
        next[id] = nil
        return next
    }
}

/// Stopwatch keys: a press starts it, another press pauses it, the next one goes on; holding the
/// key down sets it back to 0.
public enum StopwatchKeys {
    public struct State: Codable, Equatable, Sendable {
        /// The seconds gathered before the last pause, by stopwatch.
        public var banked: [String: Double]
        /// The moment each running stopwatch was started (or went on).
        public var since: [String: Date]

        public init(banked: [String: Double] = [:], since: [String: Date] = [:]) {
            self.banked = banked
            self.since = since
        }

        public var isRunning: Bool { !since.isEmpty }
    }

    public static func newID() -> String { UUID().uuidString }

    /// A press: a running one pauses and keeps its time, a paused or new one runs.
    public static func pressed(_ state: State, id: String, now: Date) -> State {
        guard !id.isEmpty else { return state }
        var next = state
        if let began = next.since.removeValue(forKey: id) {
            next.banked[id] = (next.banked[id] ?? 0) + max(0, now.timeIntervalSince(began))
        } else {
            next.since[id] = now
        }
        return next
    }

    public static func reset(_ state: State, id: String) -> State {
        var next = state
        next.banked[id] = nil
        next.since[id] = nil
        return next
    }

    /// The whole seconds each stopwatch shows now; one that was never started (or was set back) is not in it.
    public static func seconds(_ state: State, now: Date) -> [String: Int] {
        var shown = state.banked.mapValues { Int($0) }
        for (id, began) in state.since {
            shown[id] = Int((state.banked[id] ?? 0) + max(0, now.timeIntervalSince(began)))
        }
        return shown
    }
}

extension ActionType {
    /// A counter or a stopwatch: holding the key down sets it back to 0.
    public var countsUp: Bool { self == .counter || self == .stopwatch || self == .focus }
}
