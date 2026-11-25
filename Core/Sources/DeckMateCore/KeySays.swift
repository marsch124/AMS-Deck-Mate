import Foundation

/// What a key WILL do, in a few plain words, for someone who asks before pressing (0.20): the plate of
/// "Explain" on the iPhone and iPad, and the note under the pointer on the Mac's keys on screen.
public enum KeySays {
    /// The lines for one key: a tap, a hold (nil = holding does the same as a tap), a double press (nil = it has none).
    public struct Lines: Equatable, Sendable {
        public var tap: String
        public var hold: String?
        public var twice: String?
        public init(tap: String, hold: String? = nil, twice: String? = nil) {
            self.tap = tap
            self.hold = hold
            self.twice = twice
        }
    }

    public static func lines(_ key: DeckKey, in deck: Deck, profile: UUID?, appName: (String) -> String) -> Lines {
        Lines(tap: does(key.action, in: deck, profile: profile, appName: appName),
              hold: key.actsOnHold ? does(key.action(long: true), in: deck, profile: profile, appName: appName) : nil,
              twice: key.hasTwice ? key.twice.map { does($0, in: deck, profile: profile, appName: appName) } : nil)
    }

    /// One action, said as what it will do: "Opens Safari", "Presses ⌘N", "Fans: Cool for 10 minutes".
    public static func does(_ action: DeckAction, in deck: Deck, profile: UUID?, appName: (String) -> String) -> String {
        say(action, in: deck, profile: profile, appName: appName, depth: 0)
    }

    // MARK: - The words

    private static func say(_ action: DeckAction, in deck: Deck, profile: UUID?,
                            appName: (String) -> String, depth: Int) -> String {
        let target = action.target
        switch action.type {
        case .none:
            return "Does nothing"
        case .app:
            if target.isEmpty { return "No app picked" }
            let name = appName(target)
            return name.isEmpty ? "Opens an app" : "Opens \(name)"
        case .link:
            return linkWords(target)
        case .raycast:
            return raycastWords(target)
        case .shortcut:
            return "Presses \(action.combo?.label ?? "a shortcut")"
        case .text:
            let line = target.split(whereSeparator: \.isNewline).joined(separator: " ")
            if line.isEmpty { return "Types nothing yet" }
            return line.count > 24 ? "Types “\(line.prefix(24))…”" : "Types “\(line)”"
        case .media:
            return (MediaKey(rawValue: target) ?? .playPause).title
        case .folder:
            if let page = page(target, in: deck, profile: profile) {
                return page.parent == nil ? "Goes to the page “\(page.name)”" : "Opens the folder “\(page.name)”"
            }
            return "Opens a folder that is gone"
        case .back:
            return "Back"
        case .nextPage:
            return "Next page"
        case .previousPage:
            return "Previous page"
        case .profile:
            if let id = UUID(uuidString: target), let group = deck.profile(id) {
                return "Shows the page group “\(group.name)”"
            }
            return "Shows a page group that is gone"
        case .multi:
            let steps = action.steps.filter { $0.type != .wait && $0.type != .none }
            guard let first = steps.first else { return "Does nothing" }
            let words = depth >= 3 ? "Does something"
                : say(first, in: deck, profile: profile, appName: appName, depth: depth + 1)
            return steps.count > 1 ? "\(words) and \(steps.count - 1) more" : words
        case .recent:
            return "Opens recent app no. \(OftenKeys.number(target))"
        case .askAI:
            return "Asks Raycast AI about the copied text"
        case .copied:
            return target == CopiedTexts.list ? "Lets you pick a copied text" : "Pastes the text copied before (no. \(OftenKeys.number(target)))"
        case .recentFile:
            return "Opens recent file no. \(OftenKeys.number(target))"
        case .timer:
            return "Timer: \(TimerKeys.minutes(target)) min, start or stop"
        case .toggle:
            if ChipKey.isChip(target) { return ChipKey.says }
            if FanSpeedKey.isFans(target) { return FanSpeedKey.says }
            if let choice = FanKeys.choice(of: target) { return "Fans: \(FanKeys.longWords(choice))" }
            if target == SwitchKeys.dark { return "Switches dark mode" }
            if target == SwitchKeys.mute { return "Switches the sound on or off" }
            if target == SwitchKeys.awake { return "Keeps the Mac awake, on or off" }
            if SwitchKeys.isOwn(target) { return "Switch of your own, on or off" }
            return "Switches on or off"
        case .appleShortcut:
            return target.isEmpty ? "No Shortcut picked" : "Runs the Shortcut “\(target)”"
        case .list:
            let count = action.steps.filter { $0.type != .none }.count
            return count == 0 ? "Shows a list to pick from" : count == 1 ? "Shows a list of 1 entry to pick from"
                : "Shows a list of \(count) entries to pick from"
        case .running:
            return "Opens open app no. \(OftenKeys.number(target))"
        case .micLight:
            return "Shows whether the microphone is in use"
        case .wait:
            let seconds = Int(target) ?? 1
            return seconds == 1 ? "Waits 1 second" : "Waits \(seconds) seconds"
        case .nextEvent:
            return "Shows the next event; opens \(appOrDefault(target, "Calendar", appName))"
        case .weather:
            return target.isEmpty ? "Asks for a town first" : "Shows the weather in \(town(target)); opens Weather"
        case .weatherTown:
            return "Asks for another town"
        case .dueToday:
            return "Shows the tasks due today; opens PARAGON"
        case .cover:
            return "Shows the album cover; plays or pauses"
        case .bodyBattery:
            return "Shows your Body Battery; opens the Garmin board"
        case .desk:
            let count = DeskKeys.spots(of: action).count
            return count == 0 ? "Sets up the desk: no windows taken yet"
                : count == 1 ? "Sets up the desk: 1 app" : "Sets up the desk: \(count) apps"
        case .garmin:
            return "Shows \(GarminKeys.number(target).title.lowercased()); opens the Garmin board"
        case .macNow:
            switch MacNowKeys.number(target) {
            case .battery: return "Shows the Mac battery; opens Battery settings"
            case .space: return "Shows the free space; opens Storage settings"
            case .busy: return "Shows how busy the Mac is; opens Activity Monitor"
            }
        case .worldClock:
            return target.isEmpty ? "Asks for a town first" : "Shows the time in \(town(target)); opens Clock"
        case .sunTimes:
            return target.isEmpty ? "Asks for a town first" : "Shows the next sunrise or sunset in \(town(target))"
        case .freeUntil:
            return "Shows how long you are free; opens \(appOrDefault(target, "Calendar", appName))"
        case .macDo:
            let asks = MacDoKeys.asks(action) ? " (asks first)" : ""
            switch MacDoKeys.what(target) {
            case .lock: return "Locks the Mac"
            case .desktop: return "Shows the desktop"
            case .quitAll: return "Quits all apps" + asks
            case .emptyBin: return "Empties the bin" + asks
            case .ejectAll: return "Ejects all disks" + asks
            case .pastePlain: return "Pastes as plain text"
            }
        case .joinMeeting:
            return "Opens the video link of the next meeting"
        case .playlist:
            return "Plays a playlist on Spotify"
        case .searchCopied:
            return "Searches \(SearchKeys.engine(target).title) for the copied text"
        case .counter:
            return "Counts one up"
        case .stopwatch:
            return "Starts or pauses the stopwatch"
        case .zero:
            return "Back to 0"
        case .paragon:
            switch ParagonKeys.what(target) {
            case .inbox: return "Shows the PARAGON Inbox; opens it"
            case .next: return "Shows your next task; opens PARAGON"
            case .copiedTask: return "Adds the copied text as a PARAGON task"
            case .note: return "Starts a quick note in PARAGON"
            case .plan: return "Shows what is now on your plan; opens PARAGON"
            }
        case .focus:
            return target.isEmpty ? "Starts focus rounds" : "Starts the focus rounds “\(target)”"
        case .breath:
            let setting = BreathKeys.setting(target)
            return "Breathing pacer: \(setting.inSeconds) in, \(setting.outSeconds) out, \(setting.breaths) breaths"
        case .bar:
            let part = BarKeys.parse(target)
            return "Part \(part.place) of \(part.count) of a progress bar"
        case .often:
            return "Does what your no. \(OftenKeys.number(target)) most pressed key does"
        }
    }

    // MARK: - Small helpers

    /// A page by its id: first in the page group the key is in, then in all of them.
    private static func page(_ target: String, in deck: Deck, profile: UUID?) -> DeckPage? {
        guard let id = UUID(uuidString: target) else { return nil }
        if let profile, let found = deck.profile(profile)?.page(id) { return found }
        return deck.profiles.lazy.compactMap { $0.page(id) }.first
    }

    /// A town the way a person writes it: "torremolinos" → "Torremolinos".
    private static func town(_ target: String) -> String {
        target.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }

    private static func appOrDefault(_ target: String, _ fallback: String, _ appName: (String) -> String) -> String {
        if target.isEmpty { return fallback }
        let name = appName(target)
        return name.isEmpty ? "the app" : name
    }

    private static func linkWords(_ target: String) -> String {
        let text = target.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "No link picked" }
        if text.hasPrefix("/") || text.hasPrefix("~") {
            let last = (text as NSString).lastPathComponent
            return last.isEmpty ? "Opens a file" : "Opens \(last)"
        }
        if let host = URL(string: text)?.host, !host.isEmpty {
            let bare = host.lowercased().hasPrefix("www.") ? String(host.dropFirst(4)) : host
            return "Opens the link \(bare)"
        }
        return "Opens the link"
    }

    private static func raycastWords(_ target: String) -> String {
        func nice(_ command: String) -> String {
            let words = command.split(separator: "-").joined(separator: " ")
            return words.prefix(1).uppercased() + words.dropFirst()
        }
        if let parts = RaycastLink.parts(target) { return "Raycast: " + nice(parts.command) }
        let lower = target.lowercased()
        if lower.hasPrefix("raycast://script-commands/") || lower.hasPrefix("raycast://ai-commands/"),
           let last = target.split(separator: "?").first?.split(separator: "/").last, !last.isEmpty {
            return "Raycast: " + nice(String(last))
        }
        return "Runs in Raycast"
    }
}
