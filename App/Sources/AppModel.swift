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
    /// The last time a key on the box was pressed (for "First time with the box").
    @Published private(set) var lastBoxPress: Date?
    /// The setup as it was before each of the last changes (Undo), and the ones taken back (Redo).
    @Published private(set) var undoStack: [Deck] = []
    @Published private(set) var redoStack: [Deck] = []
    /// A key copied in "Set up keys" (Copy), ready to paste.
    @Published var copiedKey: DeckKey?
    /// The keys on screen take the keyboard right now: they show their letters.
    @Published var keyboardOn = false

    /// Every press, wherever it came from (the iPhone lights the key up).
    let pressedEvents = PassthroughSubject<Int, Never>()
    /// What a press did on the Mac, in a few words; false = it could not be done.
    let ranEvents = PassthroughSubject<(String, Bool), Never>()
    /// Copy, paste, undo and redo from the Edit keys go to the window in front.
    let edit = EditCommands()

    let store: Store
    let device = DeckDevice()
    /// True for the made-up setup used for pictures: nothing is saved, no box, no watching.
    let isSample: Bool

    /// A click on screen did something on the Mac and the keys are set to hide after that.
    var onScreenKeyActed: (() -> Void)?

    private(set) var frontApp: String?
    /// The apps used last, newest first, for the "Recent app" keys (kept when the Mac restarts).
    @Published private(set) var recentApps: [String] = [] {
        didSet {
            ActionRunner.recentApps = recentApps
            if !isSample { UserDefaults.standard.set(recentApps, forKey: "recentApps") }
        }
    }
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
            recentApps = ["com.apple.Safari", "com.apple.Notes"]
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
        recentApps = RecentApps.after(UserDefaults.standard.stringArray(forKey: "recentApps") ?? [], front: frontApp,
                                      skip: AppInfo.bundleID)

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
    var keys: [Int: DeckKey] { live(position.map { Navigator.keys(at: $0, in: deck) } ?? [:]) }

    /// Keys as they show now: a "Recent app" key turns into the app it stands for.
    func live(_ keys: [Int: DeckKey]) -> [Int: DeckKey] { keys.mapValues { $0.resolvingRecent(recentApps) } }
    func live(_ key: DeckKey?) -> DeckKey? { key?.resolvingRecent(recentApps) }

    /// "OmniFocus · Page 2", for the top line of the keys on screen.
    var placeLine: String { placeLine(at: position) }

    /// The same line for any place (an iPhone with its own keys has its own place).
    func placeLine(at position: DeckPosition?) -> String {
        guard let position, let profile = deck.profile(position.profile),
              let page = profile.page(position.page) else { return "No keys yet" }
        let showsPage = profile.pages.count > 1 && !page.name.isEmpty
        return showsPage ? "\(profile.name) · \(page.name)" : profile.name
    }

    private func appCameForward(_ id: String?) {
        guard id != AppInfo.bundleID else { return }       // our own windows never change the profile
        let before = frontApp
        frontApp = id
        let recent = RecentApps.after(recentApps, front: id, skip: AppInfo.bundleID)
        if recent != recentApps { recentApps = recent; refreshBox() }
        guard pinned == nil else { return }
        move(to: Navigator.follow(app: id, previousApp: before, at: position, in: deck))
    }

    private func move(to new: DeckPosition?) {
        guard new != position else { return }
        position = new
        refreshBox()
    }

    /// Hold one profile by hand, or (nil) let the profile follow the app in front again.
    /// A swipe on the iPhone, or an arrow key on the keys on screen: the next (+1) or previous (-1) page.
    func stepPage(_ step: Int) {
        guard let position else { return }
        move(to: Navigator.step(step, at: position, in: deck))
    }

    func pin(_ id: UUID?) {
        pinned = id
        UserDefaults.standard.set(id?.uuidString, forKey: AppModel.pinnedKey)
        move(to: Navigator.start(in: deck, profile: id ?? Navigator.profile(forApp: frontApp, in: deck)))
    }

    // MARK: Pressing

    /// A key was pressed, on screen or on the box. Says what came of it.
    /// `long` = held for half a second; `favourite` = a key of the favourites row instead of the page.
    @discardableResult
    func press(_ index: Int, long: Bool = false, favourite: Bool = false) -> Navigator.Outcome? {
        guard let position else { return nil }
        if !favourite { pressedEvents.send(index) }
        let outcome = act(index, at: position, long: long, favourite: favourite)
        move(to: outcome.position)
        return outcome
    }

    /// Does on the Mac what a key says, seen from any place, and moves nothing: an iPhone with its
    /// own keys has its own place, and the Mac's keys and the box stay where they are.
    func act(_ index: Int, at position: DeckPosition, long: Bool = false, favourite: Bool = false) -> Navigator.Outcome {
        let outcome = favourite ? Navigator.pressFavourite(index, at: position, in: deck, long: long)
                                : Navigator.press(index, at: position, in: deck, long: long)
        let run = outcome.run.map { $0.resolvingRecent(recentApps) }
        tell(run, in: deck.profile(position.profile))
        ActionRunner.run(run)
        if outcome.run.contains(where: ActionRunner.needsKeys) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.refreshStatus() }
        }
        return outcome
    }

    /// A button of the iPhone's music strip: play or pause, next track.
    func music(_ key: MediaKey) {
        let action = DeckAction(type: .media, target: key.rawValue)
        tell([action], in: profile)
        ActionRunner.run([action])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.refreshStatus() }
    }

    // MARK: Short and long presses (box and mouse)

    private var holds: [Int: UUID] = [:]

    /// A key went down. A key with a long-press action waits: let go before half a second = the
    /// usual action, still down after half a second = the long-press action. Every other key acts at once.
    private func keyDown(_ index: Int, done: @escaping (Navigator.Outcome?) -> Void = { _ in }) {
        guard keys[index]?.hasHeld == true else { done(press(index)); return }
        let mark = UUID()
        holds[index] = mark
        DispatchQueue.main.asyncAfter(deadline: .now() + Navigator.longPress) { [weak self] in
            guard let self, self.holds[index] == mark else { return }
            self.holds[index] = nil
            done(self.press(index, long: true))
        }
    }

    private func keyUp(_ index: Int, done: @escaping (Navigator.Outcome?) -> Void = { _ in }) {
        guard holds.removeValue(forKey: index) != nil else { return }
        done(press(index))
    }

    /// Says what a press did, or why it could not be done.
    private func tell(_ run: [DeckAction], in profile: DeckProfile?) {
        guard !run.isEmpty, let profile else { return }
        for action in run {
            if let why = KeyCheck.problem(DeckKey(action: action), in: profile, deck: deck, world: KeyWorldOnMac.world) {
                ranEvents.send((why, false))
                return
            }
        }
        if run.contains(where: ActionRunner.needsKeys), !ActionRunner.mayPressKeys {
            ranEvents.send(("The Mac has not allowed key presses yet", false))
            return
        }
        if let words = ActionWords.done(run, appName: { KeyArt.appName($0) }) { ranEvents.send((words, true)) }
    }

    /// The broken keys of a page, with the reason.
    func problems(on page: DeckPage?, of profile: DeckProfile?) -> [Int: String] {
        guard let page, let profile else { return [:] }
        var found: [Int: String] = [:]
        for (slot, key) in page.keys {
            if let why = KeyCheck.problem(key, in: profile, deck: deck, world: KeyWorldOnMac.world) { found[slot] = why }
        }
        return found
    }

    /// A key pressed on the keyboard while the keys on screen hold it. `release` first gives the
    /// keyboard back to the app in front, so a shortcut or typed text lands there.
    func pressFromKeyboard(_ index: Int, release: @escaping () -> Void) {
        guard let position else { return }
        let outcome = Navigator.press(index, at: position, in: deck)
        pressed.insert(index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in self?.pressed.remove(index) }
        guard !outcome.run.isEmpty else { press(index); return }
        release()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self else { return }
            self.press(index)
            if ScreenDeckRules.hides(after: outcome, setting: self.deck.screenHidesAfterKey) { self.onScreenKeyActed?() }
        }
    }

    /// A click on screen: the key looks pressed for a moment, then acts. With "hide after a key is
    /// pressed" on, the keys then step away (only after a key that did something on the Mac).
    /// A key with a long-press action stays pressed until the mouse button comes up (`release`).
    func click(_ index: Int) {
        pressed.insert(index)
        if keys[index]?.hasHeld != true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in self?.pressed.remove(index) }
        }
        keyDown(index) { [weak self] outcome in self?.hideAfter(outcome) }
    }

    /// The mouse button came up over the keys on screen.
    func release(_ index: Int) {
        pressed.remove(index)
        keyUp(index) { [weak self] outcome in self?.hideAfter(outcome) }
    }

    private func hideAfter(_ outcome: Navigator.Outcome?) {
        guard let outcome, ScreenDeckRules.hides(after: outcome, setting: deck.screenHidesAfterKey) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in self?.onScreenKeyActed?() }
    }

    /// A tap on the iPhone: like a press on the box (the keys on screen show it, and never hide for it).
    func pressFromPhone(_ index: Int, long: Bool = false, favourite: Bool = false) {
        if !favourite { pressed.insert(index) }
        press(index, long: long, favourite: favourite)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in self?.pressed.remove(index) }
    }

    private func boxKey(_ index: Int, _ isDown: Bool) {
        if isDown {
            lastBoxPress = Date()
            pressed.insert(index)
            keyDown(index)
        } else {
            pressed.remove(index)
            keyUp(index)
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
        undoStack.append(deck)
        if undoStack.count > 30 { undoStack.removeFirst() }
        redoStack = []
        deck = copy
        settle()
    }

    /// Takes the last change back.
    func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(deck)
        deck = last
        settle()
    }

    /// Does the change that was taken back again.
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(deck)
        deck = next
        settle()
    }

    private func settle() {
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

    /// Shows a place as it is (a tap on the iPad's navigation picture).
    func show(_ place: DeckPosition) {
        guard deck.profile(place.profile)?.page(place.page) != nil else { return }
        move(to: place)
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
            0: DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"),
                       held: DeckAction(type: .app, target: "com.apple.iCal")),
            1: key("Calendar", DeckAction(type: .app, target: "com.apple.iCal")),
            2: key("Safari", DeckAction(type: .app, target: "com.apple.Safari")),
            3: key("Notes", DeckAction(type: .app, target: "com.apple.Notes"), icon: "notebook"),
            4: key("News", DeckAction(type: .link, target: "https://example.com")),
            5: key("Clipboard", DeckAction(type: .raycast, target: RaycastLink.builtIn[0].link)),
            6: key("Left half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/left-half", quiet: true)),
            7: key("Right half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/right-half", quiet: true)),
            8: key("Ask AI", DeckAction(type: .askAI)),
            9: key("Copy", DeckAction(type: .shortcut, combo: KeyCombo(keyCode: 8, command: true, keyName: "C"))),
            10: DeckKey(action: DeckAction(type: .recent, target: "1")),
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
        return Deck(profiles: [main, writing], defaultProfile: main.id, favourites: [
            0: key("Play", DeckAction(type: .media, target: MediaKey.playPause.rawValue)),
            1: key("Safari", DeckAction(type: .app, target: "com.apple.Safari")),
            2: key("Writing", DeckAction(type: .profile, target: writing.id.uuidString)),
            4: key("Mute", DeckAction(type: .media, target: MediaKey.mute.rawValue)),
        ])
    }
}

/// Copy, paste, undo and redo, as the window in front wants them (set by "Set up keys").
final class EditCommands {
    var copy: (() -> Void)?
    var paste: (() -> Void)?
}

/// What this Mac has, for checking keys.
enum KeyWorldOnMac {
    static let world = KeyWorld(
        appExists: { target in
            guard let url = KeyArt.appURL(target) else { return false }
            return FileManager.default.fileExists(atPath: url.path)
        },
        fileExists: { FileManager.default.fileExists(atPath: $0) },
        raycastExtension: { owner, name in RaycastIcons.installed(owner: owner, extensionName: name) })
}
