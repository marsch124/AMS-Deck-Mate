import AppKit
import Combine
import DeckMateCore

/// The living state of the app: the setup, where the deck is right now, and the box.
final class AppModel: ObservableObject {
    @Published private(set) var deck: Deck
    @Published private(set) var position: DeckPosition?
    @Published private(set) var box: DeckDevice.State = .absent
    /// Keys held down right now (for the pressed look on screen).
    @Published private(set) var pressed: Set<Int> = []
    /// A profile held by hand; nil = the profile follows the app in front.
    @Published private(set) var pinned: UUID?
    @Published private(set) var mayPressKeys = ActionRunner.mayPressKeys
    @Published private(set) var elgatoRunning = false
    /// What the last take-over from Elgato left out, in plain words.
    @Published private(set) var importNotes: [String] = []
    @Published private(set) var importedKeys: Int?

    let store: Store
    let device = DeckDevice()
    /// True for the made-up setup used for pictures: nothing is saved, no box, no watching.
    let isSample: Bool

    private var frontApp: String?
    private var shown: [DeckKey?] = []
    private var saveTimer: Timer?
    private var statusTimer: Timer?
    private var watcher: NSObjectProtocol?

    static let elgatoID = "com.elgato.StreamDeck"
    static let elgatoProfiles = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("com.elgato.StreamDeck/ProfilesV3", isDirectory: true)
    private static let pinnedKey = "pinnedProfile"

    init(store: Store = Store(), sample: Deck? = nil) {
        self.store = store
        isSample = sample != nil
        if let sample {
            deck = sample
            position = Navigator.start(in: sample)
            return
        }
        var firstStart = false
        if let saved = store.load() {
            deck = saved
        } else {
            firstStart = !store.hasFile
            deck = Deck.starter()
        }
        if firstStart {
            // First start: bring over the keys from Elgato's app, when it has any for the 15-key box.
            let found = ElgatoImport.read(folder: AppModel.elgatoProfiles)
            if !found.profiles.isEmpty {
                deck.profiles = found.profiles
                deck.defaultProfile = found.defaultProfile
                deck = deck.droppingEmptyFolders()
                importNotes = found.notes
                importedKeys = found.keyCount
            }
            store.save(deck)
        }
        pinned = UserDefaults.standard.string(forKey: AppModel.pinnedKey).flatMap { UUID(uuidString: $0) }
        if let pinned, deck.profile(pinned) == nil { self.pinned = nil }
        let front = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        frontApp = front == AppInfo.bundleID ? nil : front
        position = Navigator.start(in: deck, profile: pinned ?? Navigator.profile(forApp: frontApp, in: deck))

        watcher = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            self?.appCameForward(app?.bundleIdentifier)
        }
        device.onState = { [weak self] state in self?.boxChanged(state) }
        device.onKey = { [weak self] index, isDown in self?.boxKey(index, isDown) }
        device.start()
        refreshStatus()
        let timer = Timer(timeInterval: 4, repeats: true) { [weak self] _ in self?.refreshStatus() }
        RunLoop.main.add(timer, forMode: .common)
        statusTimer = timer
    }

    // MARK: Where the deck is

    var profile: DeckProfile? { position.flatMap { deck.profile($0.profile) } }
    var page: DeckPage? { position.flatMap { profile?.page($0.page) } }
    var keys: [Int: DeckKey] { position.map { Navigator.keys(at: $0, in: deck) } ?? [:] }

    /// "OmniFocus · Page 2", for the top line of the keys on screen.
    var placeLine: String {
        guard let profile, let page else { return "No keys yet" }
        let showsPage = profile.pages.count > 1 && !page.name.isEmpty
        return showsPage ? "\(profile.name) · \(page.name)" : profile.name
    }

    private func appCameForward(_ id: String?) {
        guard id != AppInfo.bundleID else { return }       // our own windows never change the profile
        let before = frontApp
        frontApp = id
        guard pinned == nil else { return }
        move(to: Navigator.follow(app: id, previousApp: before, at: position, in: deck))
    }

    private func move(to new: DeckPosition?) {
        guard new != position else { return }
        position = new
        refreshBox()
    }

    /// Hold one profile by hand, or (nil) let the profile follow the app in front again.
    func pin(_ id: UUID?) {
        pinned = id
        UserDefaults.standard.set(id?.uuidString, forKey: AppModel.pinnedKey)
        move(to: Navigator.start(in: deck, profile: id ?? Navigator.profile(forApp: frontApp, in: deck)))
    }

    // MARK: Pressing

    /// A key was pressed, on screen or on the box.
    func press(_ index: Int) {
        guard let position else { return }
        let outcome = Navigator.press(index, at: position, in: deck)
        move(to: outcome.position)
        ActionRunner.run(outcome.run)
        if outcome.run.contains(where: ActionRunner.needsKeys) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.refreshStatus() }
        }
    }

    /// A click on screen: the key looks pressed for a moment, then acts.
    func click(_ index: Int) {
        pressed.insert(index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in self?.pressed.remove(index) }
        press(index)
    }

    private func boxKey(_ index: Int, _ isDown: Bool) {
        if isDown {
            pressed.insert(index)
            press(index)
        } else {
            pressed.remove(index)
        }
    }

    // MARK: The box

    private func boxChanged(_ state: DeckDevice.State) {
        box = state
        shown = []
        if case .connected = state {
            device.setBrightness(deck.brightness)
            refreshBox()
        }
        refreshStatus()
    }

    /// Sends the box the keys that changed since the last time.
    private func refreshBox() {
        guard device.isConnected else { return }
        let now = keys
        let all = shown.count != StreamDeckProtocol.keyCount
        if all { shown = Array(repeating: nil, count: StreamDeckProtocol.keyCount) }
        for index in 0..<StreamDeckProtocol.keyCount where all || shown[index] != now[index] {
            shown[index] = now[index]
            if let jpeg = KeyArt.jpegForBox(now[index]) { device.show(jpeg, on: index) }
        }
    }

    func setBrightness(_ percent: Int) {
        guard percent != deck.brightness else { return }
        deck.brightness = min(100, max(0, percent))
        device.setBrightness(deck.brightness)
        saveSoon()
    }

    func quitElgato() {
        NSRunningApplication.runningApplications(withBundleIdentifier: AppModel.elgatoID).forEach { $0.terminate() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.refreshStatus() }
    }

    func refreshStatus() {
        let trusted = ActionRunner.mayPressKeys
        if trusted != mayPressKeys { mayPressKeys = trusted }
        let running = !NSRunningApplication.runningApplications(withBundleIdentifier: AppModel.elgatoID).isEmpty
        if running != elgatoRunning { elgatoRunning = running }
    }

    // MARK: Changing the setup

    /// Every change to the setup goes through here: it is kept, the deck is put right, the box follows.
    func change(_ edit: (inout Deck) -> Void) {
        var copy = deck
        edit(&copy)
        guard copy != deck else { return }
        deck = copy
        if let pinned, deck.profile(pinned) == nil { pin(nil) }
        let fixed = Navigator.repair(position, in: deck)
        if fixed != position { position = fixed }
        refreshBox()
        saveSoon()
    }

    /// Shows a page of a profile on the deck (the setup window does this, so the box shows what is being edited).
    func show(profile: UUID, page: UUID) {
        guard deck.profile(profile)?.page(page) != nil else { return }
        move(to: DeckPosition(profile: profile, page: page))
    }

    private func saveSoon() {
        guard !isSample else { return }
        saveTimer?.invalidate()
        let timer = Timer(timeInterval: 1.5, repeats: false) { [weak self] _ in self?.saveNow() }
        RunLoop.main.add(timer, forMode: .common)
        saveTimer = timer
    }

    func saveNow() {
        guard !isSample else { return }
        saveTimer?.invalidate()
        saveTimer = nil
        store.save(deck)
    }

    /// Reads Elgato's keys again and puts them in place of the current profiles. The setup as it was
    /// stays among the safety copies. False when Elgato has no keys for the 15-key box.
    @discardableResult
    func bringOverFromElgato() -> Bool {
        let found = ElgatoImport.read(folder: AppModel.elgatoProfiles)
        guard !found.profiles.isEmpty else { return false }
        saveNow()
        change { deck in
            deck.profiles = found.profiles
            deck.defaultProfile = found.defaultProfile
            deck = deck.droppingEmptyFolders()
        }
        importNotes = found.notes
        importedKeys = found.keyCount
        pin(nil)
        saveNow()
        return true
    }

    func willQuit() {
        saveNow()
        device.giveBack()
    }
}

/// A made-up setup for pictures and checks: none of his own keys.
enum Sample {
    static func deck() -> Deck {
        func key(_ title: String, _ action: DeckAction, icon: String = "") -> DeckKey {
            DeckKey(title: title, icon: icon, action: action)
        }
        let more = DeckPage(name: "More", parent: nil, keys: [:])
        var folder = DeckPage(name: "Sound")
        var first = DeckPage(name: "Page 1")
        folder.parent = first.id
        folder.keys = [
            0: key("Back", DeckAction(type: .back)),
            1: key("Play", DeckAction(type: .media, target: MediaKey.playPause.rawValue)),
            2: key("Next", DeckAction(type: .media, target: MediaKey.next.rawValue)),
            3: key("Louder", DeckAction(type: .media, target: MediaKey.volumeUp.rawValue)),
            4: key("Mute", DeckAction(type: .media, target: MediaKey.mute.rawValue)),
        ]
        first.keys = [
            0: key("Mail", DeckAction(type: .app, target: "com.apple.mail")),
            1: key("Calendar", DeckAction(type: .app, target: "com.apple.iCal")),
            2: key("Safari", DeckAction(type: .app, target: "com.apple.Safari")),
            3: key("Notes", DeckAction(type: .app, target: "com.apple.Notes"), icon: "notebook"),
            4: key("News", DeckAction(type: .link, target: "https://example.com")),
            5: key("Clipboard", DeckAction(type: .raycast, target: RaycastLink.builtIn[0].link)),
            6: key("Left half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/left-half", quiet: true)),
            7: key("Right half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/right-half", quiet: true)),
            8: key("AI Chat", DeckAction(type: .raycast, target: "raycast://extensions/raycast/raycast-ai/ai-chat")),
            9: key("Copy", DeckAction(type: .shortcut, combo: KeyCombo(keyCode: 8, command: true, keyName: "C"))),
            10: key("Greeting", DeckAction(type: .text, target: "Kind regards")),
            11: key("Play", DeckAction(type: .media, target: MediaKey.playPause.rawValue)),
            12: key("Sound", DeckAction(type: .folder, target: folder.id.uuidString)),
            13: key("Morning", DeckAction(type: .multi, steps: [DeckAction(type: .app, target: "com.apple.mail"),
                                                                 DeckAction(type: .app, target: "com.apple.iCal")])),
            14: key("Next page", DeckAction(type: .nextPage)),
        ]
        var second = more
        second.name = "Page 2"
        second.keys = [0: key("Projects", DeckAction(type: .link, target: "~/Documents")),
                       14: key("Back a page", DeckAction(type: .previousPage))]
        let main = DeckProfile(name: "Default", pages: [first, second, folder])
        var writing = DeckProfile(name: "Writing", apps: ["com.apple.Notes"], pages: [DeckPage(name: "Page 1")])
        writing.pages[0].keys = [0: key("Bold", DeckAction(type: .shortcut, combo: KeyCombo(keyCode: 11, command: true, keyName: "B"))),
                                 1: key("Default", DeckAction(type: .profile, target: main.id.uuidString))]
        return Deck(profiles: [main, writing], defaultProfile: main.id)
    }
}
