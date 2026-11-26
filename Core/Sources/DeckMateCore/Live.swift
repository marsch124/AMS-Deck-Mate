import Foundation

/// What the keys that change by themselves stand for right now.
public struct LiveKeys: Equatable, Sendable {
    /// The apps used last, newest first (the app in front first).
    public var apps: [String]
    /// The texts copied last, newest first (the current one first).
    public var copied: [String]
    /// The files opened last, newest first, as full paths.
    public var files: [String]
    /// The apps open now, in the order of the "Open app" keys.
    public var running: [String]
    /// The timers going, by their minutes: the seconds left; 0 = finished and still saying "Done".
    public var timers: [String: Int]
    /// The switches that are on, by their target ("dark", "mute", "own:…").
    public var on: Set<String>
    /// An app is listening to the microphone right now.
    public var micInUse: Bool
    /// What the glance keys show, by their names in `GlanceKeys` ("event", "weather:<town>", "due", "battery").
    public var glances: [String: Glance]
    /// The latest Body Battery, for the key's colour.
    public var battery: Int?
    /// What Spotify plays, and whether its cover's picture is here already.
    public var cover: CoverKeys.Now?
    public var coverReady: Bool
    /// The counters, by their names: how far each has counted.
    public var counts: [String: Int]
    /// The stopwatches that were started, by their names: the seconds each shows now.
    public var watches: [String: Int]
    /// The stopwatches that run right now.
    public var watchesRunning: Set<String>
    /// The focus run going on (or just over), for the key of its template.
    public var focus: FocusKeys.Showing?
    /// The playlist covers that are here, by their names (`PlaylistKeys.coverName`).
    public var covers: Set<String>
    /// The breathing round going on (which key, in or out, how high the bar stands).
    public var breath: BreathKeys.Showing?
    /// What the progress bar keys follow right now; nil = nothing runs.
    public var bar: BarKeys.Now?
    /// The minutes left of the fan choice that is on (AMS Fan Menu's timed choice); nil = it has no end.
    public var fanLeft: Int?
    /// The chip temperature in whole degrees, from AMS Fan Menu's now.json; nil = no fresh reading.
    public var chip: Int?
    /// The speed of the faster fan in turns per minute (0 = stopped), from now.json; nil = no fresh reading.
    public var fans: Int?

    public init(apps: [String] = [], copied: [String] = [], files: [String] = [], running: [String] = [],
                timers: [String: Int] = [:], on: Set<String> = [], micInUse: Bool = false,
                glances: [String: Glance] = [:], battery: Int? = nil, cover: CoverKeys.Now? = nil,
                coverReady: Bool = false, counts: [String: Int] = [:], watches: [String: Int] = [:],
                watchesRunning: Set<String> = [], focus: FocusKeys.Showing? = nil, covers: Set<String> = [],
                breath: BreathKeys.Showing? = nil, bar: BarKeys.Now? = nil,
                fanLeft: Int? = nil, chip: Int? = nil, fans: Int? = nil) {
        self.fanLeft = fanLeft
        self.chip = chip
        self.fans = fans
        self.breath = breath
        self.bar = bar
        self.covers = covers
        self.focus = focus
        self.counts = counts
        self.watches = watches
        self.watchesRunning = watchesRunning
        self.glances = glances
        self.battery = battery
        self.cover = cover
        self.coverReady = coverReady
        self.apps = apps
        self.copied = copied
        self.files = files
        self.running = running
        self.timers = timers
        self.on = on
        self.micInUse = micInUse
    }
}

/// The texts copied last, for the "Last copied text" keys. Kept in memory only.
public enum CopiedTexts {
    /// How many are kept: the current one plus three before it.
    public static let kept = 4
    /// A longer text is not kept.
    public static let longest = 100_000

    /// The list after `text` was copied. Nothing, only spaces, or far too long = unchanged.
    public static func after(_ list: [String], copied text: String?) -> [String] {
        guard let text, text.count <= longest,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return list }
        return Array(([text] + list.filter { $0 != text }).prefix(kept))
    }

    /// The text a key with this number pastes (1 = the one copied just before the current one); nil = none yet.
    public static func text(number: Int, in list: [String]) -> String? {
        let before = Array(list.dropFirst())
        guard number >= 1, number <= before.count else { return nil }
        return before[number - 1]
    }

    /// A key set to this shows a list of the earlier texts instead of pasting one.
    public static let list = "list"

    /// The texts the list offers: the ones copied before the current one, newest first.
    public static func choices(in list: [String]) -> [String] { Array(list.dropFirst().prefix(kept - 1)) }

    /// A text as one line of the list: at most 60 letters.
    public static func line(_ text: String) -> String {
        let line = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return line.count > 60 ? line.prefix(59).trimmingCharacters(in: .whitespaces) + "…" : line
    }

    /// The first words of a text, for the key: one line, at most 18 letters.
    public static func preview(_ text: String) -> String {
        let line = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return line.count > 18 ? line.prefix(17).trimmingCharacters(in: .whitespaces) + "…" : line
    }
}

/// The files opened last, for the "Recent file" keys.
public enum RecentFiles {
    public static let kept = 3

    /// The files to offer, from the Mac's list of files used last (newest first): only files inside
    /// the home folder, none from its Library, no hidden ones, no apps, each once.
    public static func pick(_ paths: [String], home: String) -> [String] {
        let root = home.hasSuffix("/") ? home : home + "/"
        var seen = Set<String>()
        var found: [String] = []
        for path in paths where path.hasPrefix(root) {
            let parts = path.dropFirst(root.count).split(separator: "/")
            guard let name = parts.last, parts.first != "Library",
                  !parts.contains(where: { $0.hasPrefix(".") || $0.hasSuffix(".app") }),
                  !name.isEmpty, seen.insert(path).inserted else { continue }
            found.append(path)
            if found.count == kept { break }
        }
        return found
    }

    /// The file a key with this number opens (1 = the one opened last); nil = none yet.
    public static func file(number: Int, in list: [String]) -> String? {
        guard number >= 1, number <= list.count else { return nil }
        return list[number - 1]
    }
}

extension DeckAction {
    /// The action as it stands right now: a "Recent app" action becomes its app, a "Recent file"
    /// action becomes its file. Everything else stays as it is.
    public func resolving(_ live: LiveKeys) -> DeckAction {
        switch type {
        case .recent:
            return resolvingRecent(live.apps)
        case .recentFile:
            guard let file = RecentFiles.file(number: RecentApps.number(target), in: live.files) else { return self }
            return DeckAction(type: .link, target: file)
        case .running:
            guard let app = RunningApps.app(number: RunningApps.number(target), in: live.running) else { return self }
            return DeckAction(type: .app, target: app)
        case .cover:
            return DeckAction(type: .media, target: MediaKey.playPause.rawValue)
        case .bodyBattery, .garmin:
            return DeckAction(type: .link, target: BatteryKeys.board)
        default:
            return self
        }
    }
}

extension DeckKey {
    /// The key as it shows now: a "Recent app" key shows its app, a "Recent file" key its file's
    /// name, a "Last copied text" key the first words of its text.
    public func resolving(_ live: LiveKeys) -> DeckKey {
        var key = resolvingRecent(live.apps)
        switch key.action.type {
        case .recentFile:
            let now = key.action.resolving(live)
            if key.title.isEmpty {
                key.title = now.type == .link ? (now.target as NSString).lastPathComponent : "Recent file"
            }
            key.action = now
        case .copied:
            if key.title.isEmpty, key.action.target == CopiedTexts.list {
                key.title = "Copied texts"
            } else if key.title.isEmpty {
                let text = CopiedTexts.text(number: RecentApps.number(key.action.target), in: live.copied)
                key.title = text.map(CopiedTexts.preview) ?? "Nothing copied"
            }
        case .running:
            // Like a "Recent app" key: it shows the app it stands for, with the app's own icon and name.
            let now = key.action.resolving(live)
            if now.type == .app { key.title = ""; key.icon = "" } else if key.title.isEmpty { key.title = "No app" }
            key.action = now
        case .timer:
            let minutes = TimerKeys.minutes(key.action.target)
            if let left = live.timers[String(minutes)] {
                key.title = left == 0 ? "Done" : TimerKeys.shown(left)
                key.action.quiet = true
            } else if key.title.isEmpty {
                key.title = "\(minutes) min"
            }
        case .toggle:
            if ChipKey.isChip(key.action.target) {
                // A figure, not a state: never lit.
                key.action.quiet = false
                if key.title.isEmpty { key.title = ChipKey.keyWords(live.chip) }
                break
            }
            if FanSpeedKey.isFans(key.action.target) {
                key.action.quiet = false
                if key.title.isEmpty { key.title = FanSpeedKey.keyWords(live.fans) }
                break
            }
            let isOn = live.on.contains(key.action.target)
            key.action.quiet = isOn
            if key.title.isEmpty { key.title = SwitchKeys.words(key.action.target, isOn: isOn, fanLeft: live.fanLeft) }
        case .micLight:
            key.action.quiet = live.micInUse
            if key.title.isEmpty { key.title = live.micInUse ? "Mic in use" : "Mic free" }
        case .nextEvent:
            key.showing(live.glances[GlanceKeys.event], else: "Next event")
        case .weather:
            let town = key.action.target.trimmingCharacters(in: .whitespacesAndNewlines)
            if town.isEmpty {
                if key.title.isEmpty { key.title = WeatherKeys.noTownWords }
            } else {
                key.showing(live.glances[GlanceKeys.weather(town)], else: town)
            }
        case .dueToday:
            key.showing(live.glances[GlanceKeys.due], else: ParagonKeys.dueWords)
        case .bodyBattery:
            key.action.target = live.battery.map(String.init) ?? ""
            key.showing(live.glances[GlanceKeys.battery], else: BatteryKeys.words)
        case .cover:
            if let now = live.cover {
                key.action.quiet = now.playing
                if live.coverReady { key.icon = GlanceKeys.coverPrefix + now.track }
                if key.title.isEmpty { key.title = now.song.isEmpty ? "Spotify" : now.song }
            } else if key.title.isEmpty {
                key.title = CoverKeys.idleWords
            }
        case .desk:
            if key.title.isEmpty { key.title = "Desk" }
        case .garmin:
            let number = GarminKeys.number(key.action.target)
            key.showing(live.glances[GlanceKeys.garmin(number)], else: number.title)
        case .macNow:
            let number = MacNowKeys.number(key.action.target)
            key.showing(live.glances[GlanceKeys.mac(number)], else: number.title)
        case .worldClock, .sunTimes:
            let town = key.action.target.trimmingCharacters(in: .whitespacesAndNewlines)
            if town.isEmpty {
                if key.title.isEmpty { key.title = WeatherKeys.noTownWords }
            } else {
                let name = key.action.type == .worldClock ? GlanceKeys.clock(town) : GlanceKeys.sun(town)
                key.showing(live.glances[name], else: town)
            }
        case .freeUntil:
            key.showing(live.glances[GlanceKeys.free], else: "Free until")
        case .macDo:
            if key.title.isEmpty { key.title = MacDoKeys.what(key.action.target).short }
        case .joinMeeting:
            if key.title.isEmpty { key.title = "Join" }
        case .playlist:
            // The link's own cover, unless the key has a drawing or a picture he chose.
            if key.icon.isEmpty, let name = PlaylistKeys.coverName(key.action.target), live.covers.contains(name) {
                key.icon = GlanceKeys.coverPrefix + name
                key.action.quiet = true
            } else if key.title.isEmpty {
                key.title = "Playlist"
            }
        case .searchCopied:
            if key.title.isEmpty { key.title = "Search" }
        case .counter:
            // The number takes the drawing's place.
            if key.icon.isEmpty || !key.icon.hasPrefix(DeckKey.picturePrefix) {
                key.icon = GlanceKeys.textPrefix + String(CounterKeys.count(live.counts, id: key.action.target))
            }
            if key.title.isEmpty { key.title = "Count" }
        case .stopwatch:
            let running = live.watchesRunning.contains(key.action.target)
            if let seconds = live.watches[key.action.target] {
                key.icon = GlanceKeys.textPrefix + TimerKeys.clock(seconds)
                key.action.quiet = running
                if key.title.isEmpty { key.title = running ? "Running" : "Paused" }
            } else if key.title.isEmpty {
                key.title = "Stopwatch"
            }
        case .paragon:
            let what = ParagonKeys.what(key.action.target)
            if what.shows {
                key.showing(live.glances[ParagonKeys.glanceName(what)], else: what.short)
            } else if key.title.isEmpty {
                key.title = what.short
            }
        case .training:
            key.showing(live.glances[TrainingKeys.glanceName], else: TrainingKeys.title)
        case .focus:
            if let now = live.focus, now.name == key.action.target {
                // While it runs the key says the step and its time, whatever the key is called.
                if !now.done { key.icon = GlanceKeys.textPrefix + TimerKeys.shown(now.left) }
                key.title = now.label
                key.action.quiet = true
                key.action.name = FocusKeys.tone(now.kind).rawValue
            } else if key.title.isEmpty {
                key.title = key.action.target.isEmpty ? "Focus" : key.action.target
            }
        case .breath:
            if let now = live.breath, now.key == key.id {
                key.icon = BreathKeys.barPrefix + String(now.level)
                key.title = now.breathingIn ? BreathKeys.inWords : BreathKeys.outWords
                key.action.quiet = true
            } else if key.title.isEmpty {
                key.title = BreathKeys.idleWords
            }
        case .bar:
            let part = BarKeys.parse(key.action.target)
            let progress = live.bar?.progress ?? 0
            key.icon = BarKeys.fillPrefix + String(BarKeys.share(place: part.place, of: part.count, progress: progress))
            key.action.name = (live.bar?.tone ?? .move).rawValue
        default:
            break
        }
        if let held = key.held, held.type == .recentFile || held.type == .running { key.held = held.resolving(live) }
        if let twice = key.twice, twice.type == .recentFile || twice.type == .running { key.twice = twice.resolving(live) }
        return key
    }
}

extension DeckKey {
    /// A glance key as it shows now: the large words take the drawing's place, and the small words
    /// become the title of a key that has none. No glance yet = the drawing stays, with `words`.
    mutating func showing(_ glance: Glance?, else words: String) {
        if let glance, !glance.big.isEmpty { icon = GlanceKeys.textPrefix + glance.big }
        if let tone = glance?.tone, action.type != .bodyBattery { action.name = tone.rawValue }
        if title.isEmpty { title = glance.map { $0.words.isEmpty ? words : $0.words } ?? words }
    }
}

extension DeckKey {
    /// A training key as it shows for one device (0.23): an iPhone that would log the session on a press
    /// gets its own words ("Run · press for done"). `self` is the key as it is set up, not as it shows.
    public func showingTraining(_ glance: Glance) -> DeckKey {
        var key = self
        key.showing(glance, else: TrainingKeys.title)
        return key
    }
}

extension Deck {
    /// True when any key (also a long press, a step, or a favourite) does this kind of thing.
    public func uses(_ type: ActionType) -> Bool {
        func has(_ action: DeckAction?) -> Bool {
            guard let action else { return false }
            return action.type == type || action.steps.contains { has($0) }
        }
        let keys = profiles.flatMap { $0.pages.flatMap { $0.keys.values } } + Array(favourites.values)
        return keys.contains { has($0.action) || has($0.held) || has($0.twice) }
    }
}

extension PhoneLink {
    /// The note the iPhone shows when the Mac's screen wakes: only when it was asleep before.
    public static func wakeNote(wasAsleep: Bool, asleep: Bool) -> String? {
        wasAsleep && !asleep ? "Mac is back" : nil
    }
}
