import Foundation

extension ActionType {
    /// The kinds to pick for a key in "Set up keys", in the order of the old flat list.
    public static let forKeys: [ActionType] = [.app, .running, .recent, .often, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut, .text, .copied,
                                               .macDo, .searchCopied, .media, .playlist, .timer, .focus, .stopwatch, .counter, .breath, .bar, .toggle, .micLight,
                                               .joinMeeting, .paragon, .training,
                                               .nextEvent, .freeUntil, .weather, .worldClock, .sunTimes, .bodyBattery, .garmin, .macNow,
                                               .dueToday, .cover, .desk, .list, .multi,
                                               .folder, .back, .nextPage, .previousPage, .profile, .none]
}

/// A heading of the "What it does" chooser with the kinds under it; every pickable kind is in exactly one group.
public struct KindGroup: Sendable {
    public let title: String
    /// The colour part of the app used for the heading (see Palette.part).
    public let part: String
    public let kinds: [ActionType]

    public static let all: [KindGroup] = [
        KindGroup(title: "Open", part: "screen", kinds: [.app, .running, .recent, .often, .link, .recentFile, .desk]),
        KindGroup(title: "Type and press", part: "raycast",
                  kinds: [.shortcut, .text, .copied, .searchCopied, .askAI, .raycast, .appleShortcut, .multi, .list]),
        KindGroup(title: "Music and sound", part: "settings", kinds: [.media, .playlist, .cover, .micLight]),
        KindGroup(title: "Time", part: "profiles",
                  kinds: [.timer, .stopwatch, .counter, .focus, .breath, .bar, .worldClock, .sunTimes, .nextEvent, .freeUntil, .joinMeeting]),
        KindGroup(title: "At a glance", part: "box", kinds: [.weather, .bodyBattery, .garmin, .macNow, .dueToday, .paragon, .training]),
        KindGroup(title: "On the Mac", part: "keys", kinds: [.macDo, .toggle]),
        KindGroup(title: "Moving around", part: "iphone", kinds: [.folder, .back, .nextPage, .previousPage, .profile]),
        KindGroup(title: "Nothing", part: "keys", kinds: [.none]),
    ]

    /// Extra words a kind is also found by, besides its shown name.
    public static func searchWords(_ kind: ActionType) -> String {
        switch kind {
        case .app: return "application launch program"
        case .running: return "open apps running switch"
        case .recent: return "last used previous app"
        case .link: return "url website web file folder document"
        case .recentFile: return "last opened document"
        case .desk: return "windows layout workspace arrange"
        case .shortcut: return "keys hotkey keystroke press"
        case .text: return "type snippet write paste"
        case .copied: return "clipboard paste history"
        case .searchCopied: return "google web find clipboard"
        case .askAI: return "chatgpt assistant ai"
        case .raycast: return "command extension"
        case .appleShortcut: return "shortcuts siri automation"
        case .multi: return "sequence macro steps chain"
        case .list: return "menu choose pick"
        case .media: return "music play pause volume mute next track sound"
        case .playlist: return "spotify music"
        case .cover: return "spotify album artwork now playing"
        case .micLight: return "microphone mic call"
        case .timer: return "countdown minutes alarm"
        case .stopwatch: return "clock lap"
        case .counter: return "count tally"
        case .focus: return "pomodoro pomotimer rounds"
        case .breath: return "breathing breathe calm pacer relax"
        case .bar: return "progress timer focus row"
        case .often: return "most used favourite frequent"
        case .worldClock: return "time zone town city"
        case .sunTimes: return "sunrise sunset"
        case .nextEvent: return "calendar meeting appointment"
        case .freeUntil: return "calendar busy free"
        case .joinMeeting: return "zoom teams video call calendar"
        case .weather: return "temperature rain forecast"
        case .bodyBattery: return "garmin energy"
        case .garmin: return "watch steps heart sleep stress"
        case .macNow: return "battery disk space cpu memory"
        case .dueToday: return "tasks todo paragon"
        case .paragon: return "tasks notes"
        case .training: return "triathlon workout session sport run bike swim done"
        case .macDo: return "lock screen desktop quit apps bin trash eject disks paste plain text"
        case .toggle: return "on off keep awake caffeinate switch"
        case .folder: return "box group keys"
        case .back: return "return"
        case .nextPage: return "forward"
        case .previousPage: return "back"
        case .profile: return "page group"
        case .none: return "empty blank"
        default: return ""
        }
    }

    /// The groups with the kinds that fit the words (every word must be found in the kind's shown name or its
    /// extra words). Empty words give all groups; groups without a match are left out. `allowed` filters kinds.
    public static func search(_ words: String, names: (ActionType) -> String,
                              allowed: (ActionType) -> Bool = { _ in true }) -> [(group: KindGroup, kinds: [ActionType])] {
        let parts = words.lowercased().split(whereSeparator: { $0 == " " }).map(String.init)
        return all.compactMap { group in
            let found = group.kinds.filter { kind in
                guard allowed(kind) else { return false }
                let haystack = (names(kind) + " " + searchWords(kind)).lowercased()
                return parts.allSatisfy { haystack.contains($0) }
            }
            return found.isEmpty ? nil : (group, found)
        }
    }
}
