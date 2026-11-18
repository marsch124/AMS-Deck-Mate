import Foundation

// The 0.4 rules: moving, copying and checking keys, pages and profiles, and the words for what a key did.

extension Deck {
    /// Moves the key at `from` to `to` (both a page of the same profile and a place 0–14); a key
    /// already at `to` takes the old place, so nothing is lost. A folder key that moves to another
    /// page takes its folder along (the folder then opens from that page). A folder key cannot go
    /// into its own folder.
    public mutating func moveKey(in profileID: UUID, from: (page: UUID, slot: Int), to: (page: UUID, slot: Int)) {
        guard let p = profiles.firstIndex(where: { $0.id == profileID }),
              let a = profiles[p].pages.firstIndex(where: { $0.id == from.page }),
              let b = profiles[p].pages.firstIndex(where: { $0.id == to.page }),
              (0..<StreamDeckProtocol.keyCount).contains(from.slot),
              (0..<StreamDeckProtocol.keyCount).contains(to.slot),
              !(a == b && from.slot == to.slot) else { return }
        let moving = profiles[p].pages[a].keys[from.slot]
        let other = profiles[p].pages[b].keys[to.slot]
        func opensFolder(_ key: DeckKey?) -> UUID? {
            guard let key, key.action.type == .folder else { return nil }
            return UUID(uuidString: key.action.target)
        }
        // A folder may not end up inside itself (or inside one of its own folders).
        func inside(_ page: UUID, _ folder: UUID) -> Bool {
            var at: UUID? = page
            var steps = 0
            while let id = at, steps < 50 {
                if id == folder { return true }
                at = profiles[p].pages.first { $0.id == id }?.parent
                steps += 1
            }
            return false
        }
        if a != b {
            if let folder = opensFolder(moving), inside(to.page, folder) { return }
            if let folder = opensFolder(other), inside(from.page, folder) { return }
        }
        profiles[p].pages[a].keys[from.slot] = other
        profiles[p].pages[b].keys[to.slot] = moving
        guard a != b else { return }
        for (key, page) in [(moving, to.page), (other, from.page)] {
            if let folder = opensFolder(key), let f = profiles[p].pages.firstIndex(where: { $0.id == folder }) {
                profiles[p].pages[f].parent = page
            }
        }
    }

    /// Lets `app` (a bundle identifier) show `profileID` by itself: it is added there and taken away
    /// from any other profile that listed it. nil = the app gets no profile of its own (the default shows).
    public mutating func assign(app: String, to profileID: UUID?) {
        guard !app.isEmpty else { return }
        for index in profiles.indices {
            profiles[index].apps.removeAll { $0 == app }
            if profiles[index].id == profileID { profiles[index].apps.append(app) }
        }
    }

    /// The profile that names this app, if any.
    public func profileNaming(app: String?) -> DeckProfile? {
        guard let app, !app.isEmpty else { return nil }
        return profiles.first { $0.apps.contains(app) }
    }
}

extension DeckProfile {
    /// A full copy with new ids everywhere; folder keys open the copied folders, profile keys stay.
    /// The copy belongs to no app (two profiles for one app would fight).
    public func duplicated(name: String) -> DeckProfile {
        var map: [UUID: UUID] = [:]
        for page in pages { map[page.id] = UUID() }
        let copied = pages.map { page in
            DeckPage(id: map[page.id]!, name: page.name, parent: page.parent.flatMap { map[$0] },
                     keys: page.keys.mapValues { $0.copied(folders: map) })
        }
        return DeckProfile(name: name, apps: [], pages: copied)
    }

    /// A copy of one of the pages (with the folders opened from it), put right after it.
    /// Answers the new page's id; nil when the page is not one of the profile's top pages.
    @discardableResult
    public mutating func duplicatePage(_ id: UUID) -> UUID? {
        guard let at = pages.firstIndex(where: { $0.id == id }), pages[at].parent == nil else { return nil }
        var family: Set<UUID> = [id]
        var grew = true
        while grew {
            let more = pages.filter { $0.parent.map(family.contains) == true && !family.contains($0.id) }.map(\.id)
            grew = !more.isEmpty
            family.formUnion(more)
        }
        var map: [UUID: UUID] = [:]
        for page in family { map[page] = UUID() }
        let copies = pages.filter { family.contains($0.id) }.map { page in
            DeckPage(id: map[page.id]!, name: page.id == id ? page.name + " copy" : page.name,
                     parent: page.parent.flatMap { map[$0] ?? $0 },
                     keys: page.keys.mapValues { $0.copied(folders: map) })
        }
        let top = copies.filter { $0.id == map[id] }
        let rest = copies.filter { $0.id != map[id] }
        pages.insert(contentsOf: top, at: at + 1)
        pages.append(contentsOf: rest)
        return map[id]
    }
}

extension DeckKey {
    /// The same key with a new id; folder keys point at the copied folders in `folders` (old id → new id).
    public func copied(folders: [UUID: UUID] = [:]) -> DeckKey {
        var key = self
        key.id = UUID()
        key.action = key.action.copied(folders: folders)
        return key
    }
}

extension DeckAction {
    func copied(folders: [UUID: UUID]) -> DeckAction {
        var action = self
        if type == .folder, let old = UUID(uuidString: target), let new = folders[old] { action.target = new.uuidString }
        action.steps = steps.map { $0.copied(folders: folders) }
        return action
    }
}

/// What the Mac knows about itself, for checking keys: asked through closures so the rules need no Mac.
public struct KeyWorld {
    public var appExists: (String) -> Bool
    public var fileExists: (String) -> Bool
    /// Is an extension installed in Raycast: (owner, extension name).
    public var raycastExtension: (String, String) -> Bool

    public init(appExists: @escaping (String) -> Bool, fileExists: @escaping (String) -> Bool,
                raycastExtension: @escaping (String, String) -> Bool) {
        self.appExists = appExists
        self.fileExists = fileExists
        self.raycastExtension = raycastExtension
    }
}

/// Finds keys that cannot work any more: an app, file, folder, profile or Raycast extension that is gone.
public enum KeyCheck {
    /// One line on what is wrong with the key, or nil when it is fine.
    public static func problem(_ key: DeckKey?, in profile: DeckProfile, deck: Deck, world: KeyWorld) -> String? {
        guard let key else { return nil }
        if let why = problem(key.action, in: profile, deck: deck, world: world) { return why }
        guard key.hasHeld, let held = key.held,
              let why = problem(held, in: profile, deck: deck, world: world) else { return nil }
        return "Long press: " + why
    }

    static func problem(_ action: DeckAction, in profile: DeckProfile, deck: Deck, world: KeyWorld) -> String? {
        let target = action.target.trimmingCharacters(in: .whitespacesAndNewlines)
        switch action.type {
        case .app:
            if target.isEmpty { return "No app picked" }
            return world.appExists(target) ? nil : "The app is not on this Mac"
        case .link:
            if target.isEmpty { return "No link" }
            if target.hasPrefix("/") || target.hasPrefix("~") {
                return world.fileExists((target as NSString).expandingTildeInPath) ? nil : "The file or folder is gone"
            }
            return nil
        case .raycast:
            if target.isEmpty { return "No Raycast command" }
            guard let parts = RaycastLink.parts(target), parts.owner != "raycast" else { return nil }
            return world.raycastExtension(parts.owner, parts.extensionName) ? nil : "The Raycast extension is not installed"
        case .folder:
            guard let id = UUID(uuidString: target), profile.page(id) != nil else { return "Its folder is gone" }
            return nil
        case .profile:
            guard let id = UUID(uuidString: target), deck.profile(id) != nil else { return "Its page group is gone" }
            return nil
        case .shortcut:
            return action.combo == nil ? "No shortcut recorded" : nil
        case .text:
            return target.isEmpty ? "No text to type" : nil
        case .multi:
            for step in action.steps {
                if let found = problem(step, in: profile, deck: deck, world: world) { return found }
            }
            return action.steps.isEmpty ? "No steps" : nil
        case .appleShortcut:
            return target.isEmpty ? "No Shortcut picked" : nil
        case .list:
            for entry in action.steps {
                if let found = problem(entry, in: profile, deck: deck, world: world) { return found }
            }
            return action.steps.isEmpty ? "The list is empty" : nil
        case .toggle:
            guard SwitchKeys.isOwn(target) else { return nil }
            for step in action.steps where step.type != .none {
                if let found = problem(step, in: profile, deck: deck, world: world) { return found }
            }
            return SwitchKeys.step(of: action, isOn: false) == nil && SwitchKeys.step(of: action, isOn: true) == nil
                ? "Nothing to switch yet" : nil
        case .weather, .worldClock, .sunTimes:
            return target.isEmpty ? "No town yet" : nil
        case .desk:
            for spot in DeskKeys.spots(of: action) where !world.appExists(spot.app) { return "An app of the desk is not on this Mac" }
            return DeskKeys.spots(of: action).isEmpty ? "No windows taken yet" : nil
        case .none, .back, .nextPage, .previousPage, .media, .recent, .askAI, .copied, .recentFile,
             .timer, .running, .micLight, .wait, .nextEvent, .dueToday, .cover, .bodyBattery, .weatherTown,
             .garmin, .macNow, .freeUntil, .macDo, .joinMeeting, .searchCopied, .counter, .stopwatch, .zero:
            return nil
        case .playlist:
            return PlaylistKeys.uri(target) == nil ? "No Spotify link yet" : nil
        }
    }

    /// Every broken key of the whole setup: "Profile · Page · key 3: reason".
    public static func all(in deck: Deck, world: KeyWorld) -> [String] {
        var found: [String] = []
        for profile in deck.profiles {
            for page in profile.pages {
                for slot in page.keys.keys.sorted() {
                    if let why = problem(page.keys[slot], in: profile, deck: deck, world: world) {
                        let name = page.keys[slot]?.title.isEmpty == false ? "“\(page.keys[slot]!.title)”" : "key \(slot + 1)"
                        found.append("\(profile.name) · \(page.name) · \(name): \(why)")
                    }
                }
            }
        }
        return found
    }
}

extension RaycastLink {
    /// owner, extension and command of a raycast://extensions/… link; nil for other links.
    public static func parts(_ link: String) -> (owner: String, extensionName: String, command: String)? {
        let head = "raycast://extensions/"
        guard link.lowercased().hasPrefix(head) else { return nil }
        let rest = link.dropFirst(head.count).split(separator: "?").first.map(String.init) ?? ""
        let bits = rest.split(separator: "/").map(String.init)
        guard bits.count >= 3 else { return nil }
        return (bits[0], bits[1], bits[2])
    }
}

/// A few words on what a key did, for the iPhone ("Opened OmniFocus").
public enum ActionWords {
    public static func done(_ all: [DeckAction], appName: (String) -> String) -> String? {
        let actions = all.filter { $0.type != .wait }       // a pause is not something done
        guard let first = actions.first else { return nil }
        let words = done(first, appName: appName)
        return actions.count > 1 ? "\(words) and \(actions.count - 1) more" : words
    }

    static func done(_ action: DeckAction, appName: (String) -> String) -> String {
        switch action.type {
        case .app:
            let name = appName(action.target)
            return name.isEmpty ? "Opened the app" : "Opened \(name)"
        case .link:
            let text = action.target
            return text.hasPrefix("/") || text.hasPrefix("~") ? "Opened \((text as NSString).lastPathComponent)" : "Opened the link"
        case .raycast:
            if let parts = RaycastLink.parts(action.target) {
                let words = parts.command.split(separator: "-").joined(separator: " ")
                return "Raycast: " + words.prefix(1).uppercased() + words.dropFirst()
            }
            return "Ran in Raycast"
        case .shortcut: return "Pressed \(action.combo?.label ?? "the shortcut")"
        case .text: return "Typed the text"
        case .media: return (MediaKey(rawValue: action.target) ?? .playPause).title
        case .recent: return "No recent app yet"
        case .askAI: return "Raycast: Ask AI"
        case .copied: return action.target == CopiedTexts.list ? "Pick a copied text on the Mac" : "Pasted the copied text"
        case .recentFile: return "No recent file yet"
        case .timer: return "Timer: \(TimerKeys.minutes(action.target)) min"
        case .toggle:
            return action.target == SwitchKeys.dark ? "Switched dark mode" : action.target == SwitchKeys.mute ? "Switched the sound"
                : action.target == SwitchKeys.awake ? "Switched keep awake" : "Switched"
        case .appleShortcut: return action.target.isEmpty ? "No Shortcut picked" : "Ran the Shortcut “\(action.target)”"
        case .list: return "Pick from the list on the Mac"
        case .running: return "No app in that place"
        case .nextEvent: return "Opened the calendar"
        case .weather: return "Opened Weather"
        case .weatherTown: return "Type the town on the Mac"
        case .garmin: return "Opened the Garmin board"
        case .macNow:
            switch MacNowKeys.number(action.target) {
            case .battery: return "Opened Battery settings"
            case .space: return "Opened Storage settings"
            case .busy: return "Opened Activity Monitor"
            }
        case .worldClock: return "Opened Clock"
        case .sunTimes: return "Opened Weather"
        case .freeUntil: return "Opened the calendar"
        case .dueToday: return "Opened OmniFocus"
        case .cover: return MediaKey.playPause.title
        case .bodyBattery: return "Opened the Garmin board"
        case .desk:
            let count = DeskKeys.spots(of: action).count
            return count == 0 ? "No windows taken yet" : count == 1 ? "Set up the desk: 1 app" : "Set up the desk: \(count) apps"
        case .macDo: return MacDoKeys.done(action)
        case .joinMeeting: return "Join the meeting"
        case .playlist: return "Played on Spotify"
        case .searchCopied: return "Searched for the copied text"
        case .counter: return "Counted one more"
        case .stopwatch: return "Stopwatch"
        case .zero: return "Back to 0"
        case .none, .folder, .back, .nextPage, .previousPage, .profile, .multi, .micLight, .wait: return "Done"
        }
    }
}

extension Navigator {
    /// Next (+1) or previous (-1) page of the profile, round the end like the page keys. Inside a
    /// folder it goes to the page after (or before) the folder's own page.
    public static func step(_ step: Int, at position: DeckPosition, in deck: Deck) -> DeckPosition {
        guard let profile = deck.profile(position.profile) else { return position }
        let tops = profile.topPages
        guard tops.count > 1 else { return position }
        var home = position.page
        var guardSteps = 0
        while let parent = profile.page(home)?.parent, guardSteps < 50 { home = parent; guardSteps += 1 }
        guard let at = tops.firstIndex(where: { $0.id == home }) else { return position }
        let next = tops[((at + step) % tops.count + tops.count) % tops.count]
        return DeckPosition(profile: profile.id, page: next.id)
    }

    /// The page number (0 = first) and the number of pages; the number is nil inside a folder.
    public static func pageNumber(at position: DeckPosition, in deck: Deck) -> (page: Int?, pages: Int) {
        let tops = deck.profile(position.profile)?.topPages ?? []
        return (tops.firstIndex { $0.id == position.page }, tops.count)
    }
}

extension ScreenDeckRules {
    /// The key a keyboard key presses on the keys on screen, by the Mac's key number (the same
    /// place on every keyboard layout): the row 1–5 = keys 1–5, Q–T = 6–10, A–G = 11–15.
    public static func keyIndex(forKeyCode code: Int) -> Int? {
        let rows: [Int] = [18, 19, 20, 21, 23, 12, 13, 14, 15, 17, 0, 1, 2, 3, 5]
        return rows.firstIndex(of: code)
    }

    /// The keyboard letter shown on a key on screen while the keys take the keyboard.
    public static func keyLetter(_ index: Int) -> String? {
        let letters = ["1", "2", "3", "4", "5", "Q", "W", "E", "R", "T", "A", "S", "D", "F", "G"]
        return letters.indices.contains(index) ? letters[index] : nil
    }
}
