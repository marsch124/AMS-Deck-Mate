import AppKit
import Combine
import DeckMateCore

/// The living state of the app: the setup, where the deck is right now, and the box.
final class AppModel: ObservableObject {
    @Published private(set) var deck: Deck {
        didSet {
            // "App keys" changed (0.27): every key is drawn again, also on the box.
            if deck.appKeys != oldValue.appKeys {
                KeyArt.appLook = deck.appKeys
                shown = []
            }
        }
    }
    @Published private(set) var position: DeckPosition? { didSet { if position != oldValue { scheduleTick() } } }
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
    /// The texts copied last, newest first, for the "Last copied text" keys. In memory only.
    @Published private(set) var copiedTexts: [String] = [] {
        didSet { ActionRunner.copiedTexts = copiedTexts }
    }
    /// The files opened last, newest first, for the "Recent file" keys.
    @Published private(set) var recentFiles: [String] = []
    /// The apps open now, in the order of the "Open app" keys.
    @Published private(set) var runningApps: [String] = []
    /// The timers going, and the ones just finished.
    @Published private(set) var timers = TimerKeys.State()
    /// The switches that are on: dark mode and mute as the Mac has them, and his own.
    @Published private(set) var switchedOn: Set<String> = []
    /// The minutes left of the fan choice that is on; nil = no end.
    @Published private(set) var fanLeft: Int?
    /// The chip temperature in whole degrees from AMS Fan Menu's now.json; nil = no fresh reading ("Chip –").
    @Published private(set) var chipDegrees: Int?
    /// The speed of the faster fan from now.json (0 = stopped); nil = no fresh reading ("Fans –").
    @Published private(set) var fanSpeed: Int?
    /// An app is listening to the microphone (looked at only while a key shows it).
    @Published private(set) var micInUse = false
    /// The counters, by their names: how far each has counted. Kept across restarts.
    @Published private(set) var counts: [String: Int] = [:]
    /// The stopwatches that were started. Kept across restarts, so a running one goes on.
    @Published private(set) var watches = StopwatchKeys.State()
    /// The one clock for everything that changes by itself: it wakes only when a key needs a new picture.
    private var liveTick: Timer?
    /// The breathing round going on. In memory only.
    @Published private(set) var breathRun: BreathKeys.Run?
    /// The key just pressed (for the breathing key, which must know which one it is).
    private var pressedKeyID: UUID?
    /// An iPhone or iPad is connected: it may show any page, so seconds are counted for it too.
    var phoneConnected = false { didSet { if phoneConnected != oldValue { scheduleTick() } } }
    private static let countsKey = "counters"
    private static let watchesKey = "stopwatches"
    /// The focus run going on. Kept across restarts.
    @Published private(set) var focusRun: FocusKeys.Run?
    private static let focusKey = "focusRun"
    /// Goes up whenever a key that changes by itself looks different: each second of a timer, a
    /// switch, an app opened or quit. The iPhone link sends the keys again then.
    @Published private(set) var liveStamp = 0
    /// Which keys are pressed, for Settings › Key use.
    @Published private(set) var use = KeyUse(since: Date())
    /// Finding a key by its words, on the keys on screen.
    @Published var finding = false
    @Published var findWords = ""
    @Published var findPick = 0
    private var lookTimer: Timer?
    private var useTimer: Timer?
    private var liveWatchers: [NSObjectProtocol] = []
    /// What happened to the keys file at start, when it was damaged (for one message); nil = all well.
    private(set) var startNote: String?
    /// The weekly copy of the keys file in iCloud Drive.
    let cloudCopy: CloudCopy
    /// What the glance keys read: calendar, weather, OmniFocus, Spotify's cover, the Garmin board.
    private let glance = GlanceWatch()
    private let clipboard = ClipboardWatch()
    private let filesWatch = RecentFilesWatch()
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
        KeyArt.picturesFolder = store.pictures
        cloudCopy = CloudCopy(store: store)
        isSample = sample != nil
        if let sample {
            deck = sample
            KeyArt.appLook = sample.appKeys
            position = Navigator.start(in: sample)
            recentApps = ["com.apple.Safari", "com.apple.Notes"]
            copiedTexts = ["current", "Meeting notes for Monday"]
            recentFiles = ["/Users/sample/Documents/Plan.pdf"]
            runningApps = ["com.apple.Safari", "com.apple.mail", "com.apple.Notes"]
            switchedOn = [SwitchKeys.dark, FanKeys.target("cool")]
            fanLeft = 8
            chipDegrees = 56
            fanSpeed = 1650
            micInUse = true
            let day = Date(timeIntervalSince1970: 1_794_800_000)
            timers = TimerKeys.State(ends: ["25": day.addingTimeInterval(1259), "5": day.addingTimeInterval(45)])
            if let breathing = sample.profiles.flatMap(\.pages).flatMap({ $0.keys.values }).first(where: { $0.action.type == .breath && $0.action.target == "5-5-10" }) {
                breathRun = BreathKeys.Run(key: breathing.id, began: day.addingTimeInterval(-3), setting: BreathKeys.setting("5-5-10"))
            }
            sampleNow = day
            counts = ["sampleCount": 12]
            watches = StopwatchKeys.State(banked: ["sampleWatch": 154], since: ["sampleWatch": day.addingTimeInterval(-600)])
            GlanceWatch.keepSampleCover()
            // Twelve minutes into the first Pomodoro of the classic plan.
            focusRun = FocusKeys.Run(plan: FocusKeys.builtIn[0], began: day.addingTimeInterval(-1020))
            var counted = KeyUse(since: day.addingTimeInterval(-41 * 86_400))
            for (slot, presses) in [(0, 212), (1, 97), (2, 64), (9, 31), (13, 12), (5, 3)] {
                guard let key = sample.profiles.first?.pages.first?.keys[slot] else { continue }
                counted.presses[key.id.uuidString] = KeyUse.Entry(count: presses, last: day.addingTimeInterval(slot == 5 ? -35 * 86_400 : -3600))
            }
            use = counted
            return
        }
        let start = store.start()
        let firstStart = start.how == .first
        let loaded = start.deck ?? Deck.starter()
        deck = loaded
        KeyArt.appLook = loaded.appKeys
        switch start.how {
        case let .recovered(date):
            let when = date.formatted(date: .abbreviated, time: .shortened)
            startNote = "The file with your keys was damaged. Deck Mate brought back the safety copy from \(when). The damaged file is kept in the Backups folder."
            BoxLog.note("keys file damaged: brought back the copy from \(when)")
        case .lost:
            startNote = "The file with your keys was damaged and no safety copy could be read. Deck Mate starts with empty keys. The damaged file is kept in the Backups folder; “Bring over again” in Settings reads the keys from Elgato’s app."
            BoxLog.note("keys file damaged: no safety copy could be read")
        case let .fromCloud(date):
            let when = date.formatted(date: .abbreviated, time: .omitted)
            startNote = "This Mac had no keys yet. Deck Mate took the weekly copy from iCloud Drive of \(when). Settings › Where your setup is kept › “Bring back an earlier state” lists the others."
            BoxLog.note("no keys file: took the iCloud copy of \(when)")
        case .first, .loaded:
            break
        }
        if deck.version > Deck.currentVersion {
            let more = "These keys were last saved by a newer AMS Deck Mate. Keys of a kind this version does not know show as empty here and are kept as they are. Update AMS Deck Mate on this Mac to use them."
            startNote = startNote.map { $0 + "\n\n" + more } ?? more
            BoxLog.note("keys file is from a newer Deck Mate (format \(deck.version), this app writes \(Deck.currentVersion))")
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
        position = Navigator.start(in: deck, profile: pinned ?? Navigator.profile(forApp: frontApp, in: deck, now: DayMinutes.of(Date())))
        recentApps = RecentApps.after(UserDefaults.standard.stringArray(forKey: "recentApps") ?? [], front: frontApp,
                                      skip: AppInfo.bundleID)

        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.boxWoke()
            }
        }
        watcher = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            self?.appCameForward(app?.bundleIdentifier)
        }
        clipboard.onChange = { [weak self] texts in
            guard let self, texts != self.copiedTexts else { return }
            self.copiedTexts = texts
            self.refreshBox()
        }
        filesWatch.onChange = { [weak self] files in
            guard let self, files != self.recentFiles else { return }
            self.recentFiles = files
            self.refreshBox()
        }
        if let data = try? Data(contentsOf: useFile), let kept = try? JSONDecoder().decode(KeyUse.self, from: data) {
            use = kept
        } else {
            saveUse()       // the counting begins today
        }
        switchedOn = Set((UserDefaults.standard.stringArray(forKey: AppModel.switchesKey) ?? []).filter(SwitchKeys.isOwn))
        ActionRunner.live = { [weak self] in self?.liveNow ?? LiveKeys() }
        ActionRunner.timerPressed = { [weak self] in self?.timerPressed($0) }
        ActionRunner.breathPressed = { [weak self] in self?.breathPressed($0) }
        ActionRunner.switchPressed = { [weak self] in self?.switchPressed($0) }
        ActionRunner.glancePressed = { [weak self] in self?.glance.pressed($0) }
        ActionRunner.boardPressed = { [weak self] in self?.glance.openBoard() }
        counts = (UserDefaults.standard.dictionary(forKey: AppModel.countsKey) as? [String: Int]) ?? [:]
        if let data = UserDefaults.standard.data(forKey: AppModel.watchesKey),
           let kept = try? JSONDecoder().decode(StopwatchKeys.State.self, from: data) {
            watches = kept
        }
        ActionRunner.counterPressed = { [weak self] in self?.counterPressed($0) }
        ActionRunner.stopwatchPressed = { [weak self] in self?.stopwatchPressed($0) }
        ActionRunner.zeroPressed = { [weak self] in self?.zeroPressed($0) }
        ActionRunner.focusPressed = { [weak self] in self?.focusPressed($0) }
        ActionRunner.shortcutFailed = { [weak self] in self?.ranEvents.send(($0, false)) }
        if let data = UserDefaults.standard.data(forKey: AppModel.focusKey),
           let kept = try? JSONDecoder().decode(FocusKeys.Run.self, from: data), FocusKeys.showing(kept, now: Date()) != nil {
            focusRun = kept
        }
        MacDoer.calendarAllowed = { [weak self] in self?.glance.calendarAllowed() }
        runWatches()
        glance.onChange = { [weak self] in self?.bump() }
        for name in [NSWorkspace.didLaunchApplicationNotification, NSWorkspace.didTerminateApplicationNotification] {
            liveWatchers.append(NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refreshRunning()
            })
        }
        // The Mac went dark or light, from a key or from anywhere else.
        liveWatchers.append(DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self?.lookAtMac() }
        })
        // AMS Fan Menu changed its choice, from a fan key or from anywhere else.
        liveWatchers.append(DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(FanKeys.changed), object: nil, queue: .main) { [weak self] _ in
            self?.lookAtMac()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self?.lookAtMac() }
        })
        refreshRunning()
        lookAtMac()
        watchLive()
        // Raycast's commands for the keys, as they are at the start.
        DispatchQueue.main.async { [weak self] in self?.writeOutside() }
        cloudCopy.save = { [weak self] in self?.saveNow() }
        cloudCopy.start()
        device.onState = { [weak self] state in self?.boxChanged(state) }
        device.onKey = { [weak self] index, isDown in self?.boxKey(index, isDown) }
        device.start()
        refreshStatus()
        startStatusTimer()
        // While the screen sleeps nobody looks: the status check rests, and runs once at wake.
        for (name, asleep) in [(NSWorkspace.screensDidSleepNotification, true), (NSWorkspace.willSleepNotification, true),
                               (NSWorkspace.screensDidWakeNotification, false), (NSWorkspace.didWakeNotification, false)] {
            NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                if asleep {
                    self.statusTimer?.invalidate()
                    self.statusTimer = nil
                } else if self.statusTimer == nil {
                    self.refreshStatus()
                    self.startStatusTimer()
                }
            }
        }
    }

    private func startStatusTimer() {
        statusTimer?.invalidate()
        let timer = Timer(timeInterval: 4, repeats: true) { [weak self] _ in self?.refreshStatus() }
        RunLoop.main.add(timer, forMode: .common)
        statusTimer = timer
        startSmartLane()
    }

    // MARK: Where the deck is

    var profile: DeckProfile? { position.flatMap { deck.profile($0.profile) } }
    var page: DeckPage? { position.flatMap { profile?.page($0.page) } }
    var keys: [Int: DeckKey] { live(position.map { Navigator.keys(at: $0, in: deck) } ?? [:]) }

    /// What the keys that change by themselves stand for right now.
    var liveNow: LiveKeys {
        LiveKeys(apps: recentApps, copied: copiedTexts, files: recentFiles, running: runningApps,
                 timers: TimerKeys.left(timers, now: sampleNow ?? Date()), on: switchedOn, micInUse: micInUse,
                 glances: isSample ? GlanceWatch.sampleGlances : glance.glances,
                 battery: isSample ? 62 : glance.battery,
                 cover: isSample ? GlanceWatch.sampleCover : glance.cover,
                 coverReady: isSample || glance.coverReady,
                 counts: counts, watches: StopwatchKeys.seconds(watches, now: sampleNow ?? Date()),
                 watchesRunning: Set(watches.since.keys),
                 focus: FocusKeys.showing(focusRun, now: sampleNow ?? Date()),
                 covers: glance.coversReady,
                 breath: BreathKeys.showing(breathRun, now: sampleNow ?? Date()),
                 bar: BarKeys.now(focus: focusRun, timers: timers, at: sampleNow ?? Date()),
                 fanLeft: fanLeft, chip: chipDegrees, fans: fanSpeed)
    }
    /// Pictures with made-up keys stand still at this moment.
    var sampleNow: Date?
    private static let switchesKey = "switchedOn"
    private var useFile: URL { store.folder.appendingPathComponent("use.json") }

    /// Keys as they show now: a "Recent app" key turns into its app, a "Recent file" key into its
    /// file, a "Last copied text" key shows the first words of its text.
    func live(_ keys: [Int: DeckKey]) -> [Int: DeckKey] {
        let now = liveNow, waiting = waitingKey
        return keys.mapValues { $0.id == waiting ? AskFirst.waiting($0) : oftenShown($0, live: now) }
    }
    func live(_ key: DeckKey?) -> DeckKey? {
        key.map { $0.id == waitingKey ? AskFirst.waiting($0) : oftenShown($0, live: liveNow) }
    }

    // MARK: Ask first, press again (0.27)

    private var pressAgain = PressAgain()
    /// The key that waits for its second press (it shows "Sure?"), if any.
    var waitingKey: UUID? { pressAgain.waitingKey(at: ProcessInfo.processInfo.systemUptime) }

    /// A press of a key that may ask first. Returns the press to run (long / twice as they were at the
    /// first press, and whether it was confirmed), or nil when the key now waits for the second press.
    private func askFirst(_ key: DeckKey, long: Bool, twice: Bool) -> (long: Bool, twice: Bool, confirmed: Bool)? {
        let now = ProcessInfo.processInfo.systemUptime
        let before = pressAgain.waitingKey(at: now)
        let step = pressAgain.press(key.id, asks: AskFirst.asks(key, long: long, twice: twice), long: long, twice: twice, at: now)
        switch step {
        case .wait:
            bump()
            DispatchQueue.main.asyncAfter(deadline: .now() + AskFirst.window + 0.05) { [weak self] in
                guard let self, self.pressAgain.expire(at: ProcessInfo.processInfo.systemUptime) else { return }
                self.bump()
            }
            return nil
        case let .run(long, twice):
            bump()
            return (long, twice, true)
        case .usual:
            // Another key ended a wait: the waiting key shows itself again.
            if before != nil { bump() }
            return (long, twice, false)
        }
    }

    /// The clipboard and the list of opened files are only looked at while a key needs them.
    private func watchLive() {
        scheduleTick()
        guard !isSample else { return }
        glance.watch(deck)
        clipboard.isOn = deck.uses(.copied)
        filesWatch.isOn = deck.uses(.recentFile)
        if !clipboard.isOn, !copiedTexts.isEmpty { copiedTexts = [] }
        if !filesWatch.isOn, !recentFiles.isEmpty { recentFiles = [] }
        // Mute and the microphone are looked at every two seconds, and only while a key shows them.
        let looks = deck.uses(.toggle) || deck.uses(.micLight)
        if looks, lookTimer == nil {
            let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in self?.lookAtMac() }
            RunLoop.main.add(timer, forMode: .common)
            lookTimer = timer
            lookAtMac()
        } else if !looks, lookTimer != nil {
            lookTimer?.invalidate()
            lookTimer = nil
            lookAtMac()
        }
    }

    // MARK: Keys that change by themselves (0.10)

    /// A key that changes by itself looks different now: the box and the iPhone get it.
    private func bump() {
        liveStamp &+= 1
        refreshBox()
    }

    private func refreshRunning() {
        let open = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }.compactMap(\.bundleIdentifier)
        let next = RunningApps.order(was: runningApps, now: open)
        guard next != runningApps else { return }
        runningApps = next
        bump()
    }

    /// Dark mode and mute as the Mac has them now, his own switches as they were left, and the microphone.
    private func lookAtMac() {
        guard !isSample else { return }
        var on = switchedOn.filter(SwitchKeys.isOwn)
        if MacSwitches.isDark { on.insert(SwitchKeys.dark) }
        if MacSwitches.isMuted { on.insert(SwitchKeys.mute) }
        if KeepAwake.isOn { on.insert(SwitchKeys.awake) }
        // The fan choice that is on, as AMS Fan Menu wrote it down.
        let fanFile = try? Data(contentsOf: AppModel.fanState)
        if let fan = FanKeys.on(state: fanFile) { on.insert(fan) }
        // This runs every 2 seconds, so the fan key is redrawn only when its minute changes.
        let left = FanKeys.minutesLeft(state: fanFile, now: Date().timeIntervalSince1970)
        // The chip temperature, from Fan Menu's now.json; redrawn only when the whole degree shown changes.
        // The fan speed (0.22) comes from the same file: it is read once when either key is on the deck.
        let wantsChip = deck.allActions.contains(where: { $0.type == .toggle && ChipKey.isChip($0.target) })
        let wantsFans = deck.allActions.contains(where: { $0.type == .toggle && FanSpeedKey.isFans($0.target) })
        let nowFile = wantsChip || wantsFans ? try? Data(contentsOf: AppModel.chipFile) : nil
        let clock = Date().timeIntervalSince1970
        let chip = wantsChip ? ChipKey.degrees(file: nowFile, now: clock) : nil
        let fans = wantsFans ? FanSpeedKey.speed(file: nowFile, now: clock) : nil
        let mic = deck.uses(.micLight) && MacSwitches.micInUse
        guard on != switchedOn || mic != micInUse || left != fanLeft || chip != chipDegrees || fans != fanSpeed else { return }
        switchedOn = on
        fanLeft = left
        chipDegrees = chip
        fanSpeed = fans
        micInUse = mic
        bump()
    }

    /// A timer key was pressed: it starts, or stops, or (finished) is put away.
    func timerPressed(_ target: String) {
        timers = TimerKeys.pressed(timers, target: target, now: Date())
        runTimers()
        bump()
    }

    /// The timers need a look again (one was pressed).
    private func runTimers() { scheduleTick() }

    /// The one clock woke: timers that ended are finished (sound, "Done"), a focus round or a breathing round
    /// that is over is put away, the keys are drawn, and the clock is set for the next time one needs it.
    private func tickFired() {
        liveTick = nil
        let next = TimerKeys.tick(timers, now: Date())
        timers = next.state
        for name in next.finished {
            ranEvents.send(("Timer done: \(name) min", true))
            MacSwitches.timerSound()
        }
        if focusRun != nil, FocusKeys.showing(focusRun, now: Date()) == nil { setFocusOver() }
        if breathRun != nil, BreathKeys.showing(breathRun, now: Date()) == nil { breathRun = nil }
        bump()
        scheduleTick()
    }

    /// A breathing key was pressed: it starts a round, or stops the one that goes on.
    func breathPressed(_ action: DeckAction) {
        guard let key = pressedKeyID else { return }
        breathRun = BreathKeys.pressed(breathRun, key: key, target: action.target, now: Date())
        scheduleTick()
        bump()
    }

    /// True when a key on the page the Mac shows counts seconds or fills a bar, or an iPhone or iPad is connected.
    private var secondsSeen: Bool {
        if phoneConnected { return true }
        guard let position else { return false }
        return Navigator.keys(at: position, in: deck).values.contains { LiveTick.showsSeconds($0.action.type) }
    }

    /// The most parts of a progress bar in the setup; nil = there is none.
    private var barParts: Int? {
        let bars = deck.profiles.flatMap(\.pages).flatMap { $0.keys.values }.filter { $0.action.type == .bar }
        return bars.map { BarKeys.parse($0.action.target).count }.max()
    }

    /// Sets the one clock for the next moment a key needs a new picture: the minute of a timer, its last
    /// seconds (only when they are seen), its end, a stopwatch, a breath, a bar. Nothing going = no clock.
    private func scheduleTick() {
        liveTick?.invalidate()
        liveTick = nil
        guard !isSample else { return }
        let now = Date()
        let seen = secondsSeen
        var waits: [Double] = []
        if let wait = LiveTick.wake(timers: timers, now: now, seconds: seen) { waits.append(wait) }
        if let wait = LiveTick.wake(focus: focusRun, now: now, seconds: seen) { waits.append(wait) }
        if watches.isRunning { waits.append(seen ? 1 : LiveTick.unseen) }
        if let run = breathRun { waits.append(seen ? 1 : max(LiveTick.shortest, run.end.timeIntervalSince(now))) }
        if seen, let parts = barParts,
           let wait = LiveTick.wake(bar: BarKeys.now(focus: focusRun, timers: timers, at: now), parts: parts) { waits.append(wait) }
        guard let delay = waits.min() else { return }
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in self?.tickFired() }
        RunLoop.main.add(timer, forMode: .common)
        liveTick = timer
    }

    // MARK: Counters and stopwatches (0.13)

    /// A counter key was pressed: one more.
    func counterPressed(_ id: String) {
        counts = CounterKeys.pressed(counts, id: id)
        UserDefaults.standard.set(counts, forKey: AppModel.countsKey)
        bump()
    }

    /// A stopwatch key was pressed: it runs, or pauses and keeps its time.
    func stopwatchPressed(_ id: String) {
        watches = StopwatchKeys.pressed(watches, id: id, now: Date())
        saveWatches()
    }

    /// A counter or a stopwatch was held down: back to 0.
    func zeroPressed(_ id: String) {
        counts = CounterKeys.reset(counts, id: id)
        UserDefaults.standard.set(counts, forKey: AppModel.countsKey)
        watches = StopwatchKeys.reset(watches, id: id)
        if focusRun?.plan.name == id { setFocus(nil) }
        saveWatches()
    }

    // MARK: Focus rounds (0.14)

    /// A focus key was pressed: PomoTimer starts its template and the key counts along. While it
    /// counts, a press only brings PomoTimer back.
    func focusPressed(_ action: DeckAction) {
        let plan = FocusKeys.plan(of: action)
        if let now = FocusKeys.showing(focusRun, now: Date()), now.name == plan.name, !now.done {
            if let url = URL(string: FocusKeys.app) { NSWorkspace.shared.open(url) }
            return
        }
        guard !plan.steps.isEmpty, let url = FocusKeys.startLink(plan.name) else { return }
        NSWorkspace.shared.open(url)
        setFocus(FocusKeys.Run(plan: plan, began: Date()))
    }

    private func setFocus(_ run: FocusKeys.Run?) {
        focusRun = run
        if let run, let data = try? JSONEncoder().encode(run) {
            UserDefaults.standard.set(data, forKey: AppModel.focusKey)
        } else {
            UserDefaults.standard.removeObject(forKey: AppModel.focusKey)
        }
        runWatches()
        bump()
    }

    private func saveWatches() {
        if let data = try? JSONEncoder().encode(watches) { UserDefaults.standard.set(data, forKey: AppModel.watchesKey) }
        runWatches()
        bump()
    }

    /// A focus round that is over is put away.
    private func setFocusOver() {
        focusRun = nil
        UserDefaults.standard.removeObject(forKey: AppModel.focusKey)
    }

    /// The keys are drawn again each second only while a stopwatch runs and is seen (see `scheduleTick`).
    private func runWatches() {
        if focusRun != nil, FocusKeys.showing(focusRun, now: Date()) == nil { setFocusOver() }
        scheduleTick()
    }

    private static let chipFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(ChipKey.nowFile)
    private static let fanState = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(FanKeys.stateFile)

    /// A fan key was pressed: AMS Fan Menu is asked for the choice. When it is not open it is opened
    /// first and asked a moment later; when it is not on this Mac the note says so.
    private func askFans(_ choice: String) {
        let ask = {
            DistributedNotificationCenter.default().postNotificationName(
                Notification.Name(FanKeys.ask), object: FanKeys.wish(choice), userInfo: nil, deliverImmediately: true)
        }
        if !NSRunningApplication.runningApplications(withBundleIdentifier: FanKeys.app).isEmpty {
            ask()
        } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: FanKeys.app) {
            let quietly = NSWorkspace.OpenConfiguration()
            quietly.activates = false
            NSWorkspace.shared.openApplication(at: url, configuration: quietly) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { ask() }
            }
            for wait in [2.5, 4.0] { DispatchQueue.main.asyncAfter(deadline: .now() + wait) { [weak self] in self?.lookAtMac() } }
        } else {
            ranEvents.send(("AMS Fan Menu is not on this Mac", false))
        }
    }

    /// The chip temperature key or the fan speed key was pressed: AMS Fan Menu opens its large graph window. When Fan Menu is not
    /// open it is opened first and asked a moment later; when it is not on this Mac the note says so.
    private func askChipGraph() {
        let ask = {
            DistributedNotificationCenter.default().postNotificationName(
                Notification.Name(ChipKey.openGraph), object: nil, userInfo: nil, deliverImmediately: true)
        }
        if !NSRunningApplication.runningApplications(withBundleIdentifier: FanKeys.app).isEmpty {
            ask()
        } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: FanKeys.app) {
            let quietly = NSWorkspace.OpenConfiguration()
            quietly.activates = false
            NSWorkspace.shared.openApplication(at: url, configuration: quietly) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { ask() }
            }
        } else {
            ranEvents.send(("AMS Fan Menu is not on this Mac", false))
        }
    }

    /// A switch key was pressed.
    func switchPressed(_ action: DeckAction) {
        switch action.target {
        case SwitchKeys.dark:
            MacSwitches.setDark(!MacSwitches.isDark)
        case SwitchKeys.mute:
            MacSwitches.setMuted(!MacSwitches.isMuted)
        case SwitchKeys.awake:
            KeepAwake.set(!KeepAwake.isOn)
            lookAtMac()
            return
        case ChipKey.target, FanSpeedKey.target:
            askChipGraph()
            return
        case let target where FanKeys.isFan(target):
            askFans(FanKeys.choice(of: target) ?? "")
        default:
            let isOn = switchedOn.contains(action.target)
            if let step = SwitchKeys.step(of: action, isOn: isOn) { ActionRunner.run(step) }
            if isOn { switchedOn.remove(action.target) } else { switchedOn.insert(action.target) }
            UserDefaults.standard.set(switchedOn.filter(SwitchKeys.isOwn).sorted(), forKey: AppModel.switchesKey)
            bump()
            return
        }
        for wait in [0.5, 1.5] { DispatchQueue.main.asyncAfter(deadline: .now() + wait) { [weak self] in self?.lookAtMac() } }
    }

    // MARK: The town of a weather key

    private static let townsKey = "weatherTownsUsed"

    /// The towns to offer when a weather key asks for its town: the ones typed before and the ones on the keys now.
    var townsUsed: [String] {
        let kept = UserDefaults.standard.stringArray(forKey: AppModel.townsKey) ?? []
        return deck.allTowns.reversed().reduce(kept) { list, town in
            list.contains { WeatherKeys.name($0) == WeatherKeys.name(town) } ? list : list + [town]
        }
    }

    /// Gives a weather key another town (Undo takes it back), and remembers the town for next time.
    func setTown(_ town: String, forKey id: UUID) {
        let before = townsUsed
        change { $0.setTown(town, forKey: id) }
        UserDefaults.standard.set(WeatherKeys.remembered(before, adding: town), forKey: AppModel.townsKey)
    }

    // MARK: Key use

    private func saveUseSoon() {
        useTimer?.invalidate()
        let timer = Timer(timeInterval: 3, repeats: false) { [weak self] _ in self?.saveUse() }
        RunLoop.main.add(timer, forMode: .common)
        useTimer = timer
    }

    private func saveUse() {
        guard !isSample else { return }
        useTimer?.invalidate()
        useTimer = nil
        if let data = try? JSONEncoder().encode(use) { try? data.write(to: useFile, options: .atomic) }
    }

    /// The moment the lists of Settings › Key use are counted from (pictures stand still).
    var useNow: Date { sampleNow ?? Date() }

    // MARK: Finding a key

    /// The keys that fit the typed words, from every page group and page.
    var findHits: [KeyFinder.Hit] {
        KeyFinder.hits(findWords, in: deck) { [self] in KeyArt.title(live($0)) }
    }

    func startFinding() {
        findWords = ""
        findPick = 0
        finding = true
    }

    func stopFinding() {
        guard finding else { return }
        finding = false
        findWords = ""
        findPick = 0
    }

    /// A found key was picked: its page shows, and the key is pressed.
    func runFound(_ hit: KeyFinder.Hit, release: @escaping () -> Void) {
        stopFinding()
        guard let place = Navigator.go(profile: hit.profile.uuidString, page: hit.page.uuidString, in: deck) else { return }
        show(place)
        pressFromKeyboard(hit.slot, release: release)
    }

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
        AppDaysKeeper.shared.came(id, model: self)
        let recent = RecentApps.after(recentApps, front: id, skip: AppInfo.bundleID)
        if recent != recentApps { recentApps = recent; refreshBox() }
        noteHours(for: id)
        guard pinned == nil else { return }
        move(to: Navigator.follow(app: id, previousApp: before, at: position, in: deck, now: DayMinutes.of(Date())))
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

    /// A swipe on the iPhone: show this page group without locking it; Automatic stays on,
    /// so the next app that comes forward on the Mac takes over again.
    func visit(_ id: UUID) {
        guard deck.profile(id) != nil else { return }
        if pinned != nil {
            pinned = nil
            UserDefaults.standard.removeObject(forKey: AppModel.pinnedKey)
        }
        move(to: Navigator.start(in: deck, profile: id))
    }

    func pin(_ id: UUID?) {
        pinned = id
        UserDefaults.standard.set(id?.uuidString, forKey: AppModel.pinnedKey)
        move(to: Navigator.start(in: deck, profile: id ?? Navigator.profile(forApp: frontApp, in: deck, now: DayMinutes.of(Date()))))
    }

    // MARK: Pressing

    /// A key was pressed, on screen or on the box. Says what came of it.
    /// `long` = held for half a second; `favourite` = a key of the favourites row instead of the page.
    @discardableResult
    func press(_ index: Int, long: Bool = false, favourite: Bool = false, twice: Bool = false) -> Navigator.Outcome? {
        guard let position else { return nil }
        if !favourite { pressedEvents.send(index) }
        let outcome = act(index, at: position, long: long, favourite: favourite, twice: twice)
        move(to: outcome.position)
        return outcome
    }

    /// Does on the Mac what a key says, seen from any place, and moves nothing: an iPhone with its
    /// own keys has its own place, and the Mac's keys and the box stay where they are.
    /// `careful` = a press that came in by a link: quit all apps, empty the bin and eject then ask
    /// first, also on a key set to "without asking".
    @discardableResult
    func act(_ index: Int, at position: DeckPosition, long: Bool = false, favourite: Bool = false,
             careful: Bool = false, twice: Bool = false) -> Navigator.Outcome {
        var long = long, twice = twice, confirmed = false
        // Ask first (0.27): a key that asks waits for a second press; a press by link asks on the Mac instead.
        if !careful, let key = favourite ? deck.favourites[index] : Navigator.keys(at: position, in: deck)[index] {
            guard let press = askFirst(key, long: long, twice: twice) else {
                BoxLog.note("asks first: key \(index) waits for a second press")
                return Navigator.Outcome(position: position, run: [])
            }
            (long, twice, confirmed) = press
        }
        let outcome = favourite ? Navigator.pressFavourite(index, at: position, in: deck, long: long, twice: twice)
                                : Navigator.press(index, at: position, in: deck, long: long, twice: twice)
        let now = liveNow
        // After "press again" the Mac's own question is not asked a second time.
        let run = outcome.run.map { oftenAction($0).resolving(now) }.map { careful ? $0.askingFirst : confirmed ? $0.withoutAsking : $0 }
        // Count the press, for Settings › Key use (only keys that do something on the Mac).
        if !outcome.run.isEmpty, !isSample,
           let key = favourite ? deck.favourites[index] : Navigator.keys(at: position, in: deck)[index] {
            // An "Often used" key counts the press for the key it stands for (none yet = nothing).
            if let counted = OftenKeys.counted(key, long: long, in: deck, use: use, now: Date()) {
                use.record(counted.id, now: Date())
                saveUseSoon()
            }
        }
        // For checks ("--checks" only): the diary says what each press ran, so a check can read it instead of guessing from a picture.
        if CommandLine.arguments.contains("--checks") {
            BoxLog.note("check: key \(index)\(long ? " held" : "")\(twice ? " twice" : "") → \(ActionWords.done(run, appName: { $0 }) ?? "nothing")")
        }
        tell(run, in: deck.profile(position.profile))
        pressedKeyID = (favourite ? deck.favourites[index] : Navigator.keys(at: position, in: deck)[index])?.id
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

    // MARK: What a key does, in words (0.20)

    /// The lines for a key as it is set up (not as it shows right now): a tap, a hold, a double press.
    func says(_ key: DeckKey?, in profile: UUID?) -> KeySays.Lines? {
        key.map { key in
            var lines = KeySays.lines(key, in: deck, profile: profile, appName: { KeyArt.appName($0) })
            // A training key says the session it shows right now (0.23).
            if key.action.type == .training, !isSample { lines.tap = TrainingKeys.says(trainingBest, logs: false) }
            // A Steward key says the count it shows right now (0.25).
            if key.action.type == .steward, !isSample { lines.tap = StewardKeys.says(glance.stewardFile, now: Date()) }
            return lines
        }
    }

    // MARK: Training today (0.23)

    /// The newest fresh note from AMS Triathlon Training the Mac has: its own file or a phone's.
    var trainingBest: TrainingKeys.Note? { glance.trainingBest }
    /// An iPhone or iPad handed over the note it has (nil = none).
    func phoneTraining(_ note: TrainingKeys.Note?, from device: String) { glance.setPhoneTraining(note, from: device) }

    /// The lines for a key of the page the Mac shows.
    func says(_ index: Int) -> KeySays.Lines? {
        guard let position else { return nil }
        return says(Navigator.keys(at: position, in: deck)[index], in: position.profile)
    }

    // MARK: Short and long presses (box and mouse)

    private var holds: [Int: UUID] = [:]
    private var twicePresses = TwicePress()

    /// A press of a key that has a double press (0.20), at a place of its own ("mac:3", one per iPhone
    /// or iPad and key): the first press waits a third of a second and then runs `once`, unless a
    /// second press came in that time; the second press runs `twice` at once.
    func pressOrTwice(_ place: String, once: @escaping () -> Void, twice: @escaping () -> Void) {
        let now = ProcessInfo.processInfo.systemUptime
        switch twicePresses.press(place, at: now) {
        case .twice:
            twice()
        case .wait:
            DispatchQueue.main.asyncAfter(deadline: .now() + TwicePress.wait) { [weak self] in
                guard let self, self.twicePresses.over(place, first: now) else { return }
                once()
            }
        }
    }

    /// A key went down. A key with a long-press action waits: let go before half a second = the
    /// usual action, still down after half a second = the long-press action. A key with a double
    /// press waits a third of a second after it was let go; a second press in that time is the double
    /// press, and acts as soon as the key goes down. Every other key acts at once.
    private func keyDown(_ index: Int, done: @escaping (Navigator.Outcome?) -> Void = { _ in }) {
        let key = keys[index]
        let place = "mac:\(index)"
        if key?.hasTwice == true, twicePresses.waits(place) {
            _ = twicePresses.press(place, at: ProcessInfo.processInfo.systemUptime)
            done(press(index, twice: true))
            return
        }
        guard key?.actsOnHold == true || key?.hasTwice == true else { done(press(index)); return }
        let mark = UUID()
        holds[index] = mark
        // A key with a double press and nothing of its own on a long press only waits for the key to come up.
        guard key?.actsOnHold == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + Navigator.longPress) { [weak self] in
            guard let self, self.holds[index] == mark else { return }
            self.holds[index] = nil
            done(self.press(index, long: true))
        }
    }

    private func keyUp(_ index: Int, done: @escaping (Navigator.Outcome?) -> Void = { _ in }) {
        guard holds.removeValue(forKey: index) != nil else { return }
        guard let key = keys[index], key.hasTwice else { done(press(index)); return }
        // The usual action waits a third of a second: a second press may follow (it is caught in `keyDown`).
        pressOrTwice("mac:\(index)", once: { [weak self] in
            // The same key must still be there: another page may show by now.
            guard let self, self.keys[index]?.id == key.id else { return }
            done(self.press(index))
        }, twice: {})
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
        pressed.insert(index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in self?.pressed.remove(index) }
        // A key with a double press waits a third of a second for the same letter again.
        guard let key = keys[index], key.hasTwice else { keyboardPress(index, twice: false, release: release); return }
        pressOrTwice("mac:\(index)", once: { [weak self] in
            guard let self, self.keys[index]?.id == key.id else { return }
            self.keyboardPress(index, twice: false, release: release)
        }, twice: { [weak self] in self?.keyboardPress(index, twice: true, release: release) })
    }

    private func keyboardPress(_ index: Int, twice: Bool, release: @escaping () -> Void) {
        guard let position else { return }
        let outcome = Navigator.press(index, at: position, in: deck, twice: twice)
        guard !outcome.run.isEmpty else { press(index, twice: twice); return }
        release()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self else { return }
            self.press(index, twice: twice)
            if ScreenDeckRules.hides(after: outcome, setting: self.deck.screenHidesAfterKey) { self.onScreenKeyActed?() }
        }
    }

    /// A click on screen: the key looks pressed for a moment, then acts. With "hide after a key is
    /// pressed" on, the keys then step away (only after a key that did something on the Mac).
    /// A key with a long-press action stays pressed until the mouse button comes up (`release`).
    func click(_ index: Int) {
        pressed.insert(index)
        if keys[index]?.actsOnHold != true, keys[index]?.hasTwice != true {
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
    func pressFromPhone(_ index: Int, long: Bool = false, favourite: Bool = false, twice: Bool = false) {
        if !favourite { pressed.insert(index) }
        press(index, long: long, favourite: favourite, twice: twice)
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
            device.setBrightness(boxBrightness)
            refreshBox()
        }
        refreshStatus()
    }

    /// The Mac (or its screen) woke up: a box that went dark shows nothing until it gets its pictures
    /// again, so all of them are sent afresh, with the brightness.
    func boxWoke() {
        guard device.isConnected else { return }
        BoxLog.note("the Mac woke: brightness and all pictures sent again")
        shown = []
        device.setBrightness(boxBrightness)
        refreshBox()
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
        device.setBrightness(boxBrightness)
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
        watchLive()
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
        let ok = store.save(deck)
        if saveWatch.saved(ok) {
            BoxLog.note("the keys file could not be saved")
            if !quitting {
                DispatchQueue.main.async {
                    MacDoer.tell("The last change could not be saved",
                                 "The last change to your keys could not be saved. Your keys keep working, and Deck Mate tries again with every change.")
                }
            }
        }
        writeOutside()
    }

    private var saveWatch = SaveWatch()
    private var quitting = false

    /// Saves, then keeps the setup as it is now as a copy that ordinary saving never pushes out
    /// (before a delete, before Elgato's keys are brought over, before an earlier state is put back).
    func keepState(_ why: String) {
        guard !isSample else { return }
        saveNow()
        store.keepNow(why)
    }

    /// Reads Elgato's keys again and puts them in place of the current profiles. The setup as it was
    /// stays among the safety copies. False when Elgato has no keys for the 15-key box.
    @discardableResult
    func bringOverFromElgato() -> Bool {
        let found = ElgatoImport.read(folder: AppModel.elgatoProfiles)
        guard !found.profiles.isEmpty else { return false }
        keepState("before Elgato keys were brought over")
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

    /// Puts a safety copy in place of the setup. The setup as it is now is first kept as a safety
    /// copy, and Undo takes it back too. False when the copy cannot be read any more.
    @discardableResult
    func restore(_ copy: Store.Copy) -> Bool {
        guard let old = store.deck(of: copy) else { return false }
        keepState("before an earlier state was put back")
        if copy.inCloud { store.bringBackPictures() }
        change { $0 = old }
        pin(nil)
        saveNow()
        return true
    }

    func willQuit() {
        quitting = true
        saveNow()
        saveUse()
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
                       held: DeckAction(type: .app, target: "com.apple.iCal"),
                       twice: DeckAction(type: .app, target: "com.apple.Notes")),
            1: key("Calendar", DeckAction(type: .app, target: "com.apple.iCal")),
            2: DeckKey(title: "Safari", action: DeckAction(type: .app, target: "com.apple.Safari"),
                       twice: DeckAction(type: .link, target: "https://example.com")),
            3: key("Notes", DeckAction(type: .app, target: "com.apple.Notes"), icon: "notebook"),
            4: key("News", DeckAction(type: .link, target: "https://example.com")),
            5: key("Clipboard", DeckAction(type: .raycast, target: RaycastLink.builtIn[0].link)),
            6: key("Left half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/left-half", quiet: true)),
            7: key("Right half", DeckAction(type: .raycast, target: "raycast://extensions/raycast/window-management/right-half", quiet: true)),
            8: key("Ask AI", DeckAction(type: .askAI)),
            9: key("Copy", DeckAction(type: .shortcut, combo: KeyCombo(keyCode: 8, command: true, keyName: "C"))),
            10: DeckKey(action: DeckAction(type: .recent, target: "1")),
            11: DeckKey(action: DeckAction(type: .copied, target: "1")),
            12: key("Sound", DeckAction(type: .folder, target: folder.id.uuidString)),
            13: key("Morning", DeckAction(type: .multi, steps: [DeckAction(type: .app, target: "com.apple.mail"),
                                                                 DeckAction(type: .app, target: "com.apple.iCal")])),
            14: key("Next page", DeckAction(type: .nextPage)),
        ]
        var second = more
        second.name = "Page 2"
        second.keys = [0: key("Projects", DeckAction(type: .link, target: "~/Documents")),
                       1: DeckKey(action: DeckAction(type: .recentFile, target: "1")),
                       2: DeckKey(action: DeckAction(type: .timer, target: "25")),
                       3: DeckKey(action: DeckAction(type: .timer, target: "5")),
                       4: DeckKey(action: DeckAction(type: .toggle, target: SwitchKeys.dark)),
                       5: DeckKey(action: DeckAction(type: .toggle, target: SwitchKeys.mute)),
                       6: DeckKey(action: DeckAction(type: .micLight)),
                       7: key("Morning", DeckAction(type: .appleShortcut, target: "Morning routine")),
                       8: key("Places", DeckAction(type: .list, steps: [
                           DeckAction(type: .link, target: "~/Documents", name: "Documents"),
                           DeckAction(type: .link, target: "https://example.com/news", name: "News"),
                           DeckAction(type: .app, target: "com.apple.Notes"),
                           DeckAction(type: .text, target: "Kind regards, Sam", name: "Sign-off")])),
                       10: DeckKey(action: DeckAction(type: .running, target: "1")),
                       11: DeckKey(action: DeckAction(type: .running, target: "2")),
                       12: DeckKey(action: DeckAction(type: .running, target: "3")),
                       14: key("Back a page", DeckAction(type: .previousPage))]
        var third = DeckPage(name: "Page 3")
        third.keys = [0: DeckKey(action: DeckAction(type: .nextEvent)),
                      1: DeckKey(action: DeckAction(type: .weather, target: "Lisbon")),
                      2: DeckKey(action: DeckAction(type: .dueToday)),
                      3: DeckKey(action: DeckAction(type: .cover)),
                      4: DeckKey(action: DeckAction(type: .bodyBattery)),
                      5: key("Writing desk", DeckAction(type: .desk, steps: [
                          DeskKeys.step(DeskKeys.Spot(app: "com.apple.Safari", x: 0, y: 25, width: 1200, height: 800)),
                          DeskKeys.step(DeskKeys.Spot(app: "com.apple.Notes", x: 1200, y: 25, width: 528, height: 800)),
                          DeskKeys.step(DeskKeys.Spot(app: "com.apple.mail", x: 200, y: 120, width: 980, height: 640))])),
                      6: DeckKey(action: DeckAction(type: .garmin, target: "steps")),
                      7: DeckKey(action: DeckAction(type: .garmin, target: "sleep")),
                      8: DeckKey(action: DeckAction(type: .garmin, target: "pulse")),
                      9: DeckKey(action: DeckAction(type: .garmin, target: "stress")),
                      10: DeckKey(action: DeckAction(type: .garmin, target: "workouts")),
                      11: DeckKey(action: DeckAction(type: .macNow, target: "battery")),
                      12: DeckKey(action: DeckAction(type: .macNow, target: "space")),
                      13: DeckKey(action: DeckAction(type: .macNow, target: "busy")),
                      14: key("Next page", DeckAction(type: .nextPage))]
        var fourth = DeckPage(name: "Page 4")
        fourth.keys = [0: DeckKey(action: DeckAction(type: .worldClock, target: "Tokyo")),
                       1: DeckKey(action: DeckAction(type: .sunTimes, target: "Lisbon")),
                       2: DeckKey(action: DeckAction(type: .freeUntil)),
                       // 0.18: the fan keys; "Cool" is the one that is on.
                       5: DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target("automatic"))),
                       6: DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target("cool"))),
                       7: DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target("full"))),
                       8: DeckKey(action: DeckAction(type: .toggle, target: ChipKey.target)),
                       9: DeckKey(action: DeckAction(type: .toggle, target: FanSpeedKey.target)),
                       14: key("Next page", DeckAction(type: .nextPage))]
        var fifth = DeckPage(name: "Page 5")
        fifth.keys = [0: DeckKey(action: DeckAction(type: .macDo, target: MacDo.lock.rawValue)),
                      1: DeckKey(action: DeckAction(type: .macDo, target: MacDo.desktop.rawValue)),
                      2: DeckKey(action: DeckAction(type: .macDo, target: MacDo.quitAll.rawValue,
                                                    steps: [DeckAction(type: .app, target: "com.apple.Safari")])),
                      3: DeckKey(action: DeckAction(type: .macDo, target: MacDo.emptyBin.rawValue)),
                      4: DeckKey(action: DeckAction(type: .macDo, target: MacDo.ejectAll.rawValue)),
                      5: DeckKey(action: DeckAction(type: .macDo, target: MacDo.pastePlain.rawValue)),
                      6: DeckKey(action: DeckAction(type: .joinMeeting)),
                      7: key("Focus mix", DeckAction(type: .playlist, target: "spotify:playlist:37i9dQZF1DX8NTLI2TtZa6")),
                      8: DeckKey(action: DeckAction(type: .searchCopied, target: SearchKeys.Engine.google.rawValue)),
                      9: key("Glasses of water", DeckAction(type: .counter, target: "sampleCount")),
                      10: DeckKey(action: DeckAction(type: .stopwatch, target: "sampleWatch")),
                      11: DeckKey(action: DeckAction(type: .stopwatch, target: "sampleIdle")),
                      12: DeckKey(action: DeckAction(type: .toggle, target: SwitchKeys.awake)),
                      13: key("Next page", DeckAction(type: .nextPage)),
                      14: key("Back a page", DeckAction(type: .previousPage))]
        var sixth = DeckPage(name: "Page 6")
        sixth.keys = [0: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.inbox.rawValue)),
                      1: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.next.rawValue)),
                      2: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.copiedTask.rawValue)),
                      3: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.note.rawValue)),
                      4: DeckKey(action: DeckAction(type: .dueToday)),
                      5: DeckKey(action: FocusKeys.action(for: FocusKeys.builtIn[0])),
                      6: DeckKey(action: FocusKeys.action(for: FocusKeys.builtIn[4])),
                      7: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.plan.rawValue)),
                      8: DeckKey(action: DeckAction(type: .training, target: TrainingKeys.target)),
                      13: key("Next page", DeckAction(type: .nextPage)),
                      14: key("Back a page", DeckAction(type: .previousPage))]
        // 0.16: live keys: plan, breathing, an old temperature, whole minutes, a bar across a row.
        var seventh = DeckPage(name: "Page 7")
        seventh.keys = [0: DeckKey(action: DeckAction(type: .paragon, target: ParagonKeys.What.plan.rawValue)),
                        1: DeckKey(action: DeckAction(type: .breath)),
                        2: DeckKey(action: DeckAction(type: .breath, target: "5-5-10")),
                        3: DeckKey(action: DeckAction(type: .weather, target: "Oslo")),
                        4: DeckKey(action: DeckAction(type: .timer, target: "25")),
                        5: DeckKey(action: DeckAction(type: .bar, target: "1/5")),
                        6: DeckKey(action: DeckAction(type: .bar, target: "2/5")),
                        7: DeckKey(action: DeckAction(type: .bar, target: "3/5")),
                        8: DeckKey(action: DeckAction(type: .bar, target: "4/5")),
                        9: DeckKey(action: DeckAction(type: .bar, target: "5/5")),
                        10: DeckKey(action: FocusKeys.action(for: FocusKeys.builtIn[0])),
                        11: DeckKey(action: DeckAction(type: .timer, target: "5")),
                        14: key("Back a page", DeckAction(type: .previousPage))]
        let main = DeckProfile(name: "Default", pages: [first, second, third, fourth, fifth, sixth, seventh, folder])
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
        raycastExtension: { owner, name in RaycastIcons.installed(owner: owner, extensionName: name) },
        raycastCommand: { RaycastInstalled.has($0, $1, $2) })
}
