import DeckMateCore
import Network
import SwiftUI
import UIKit

/// Finds the Mac close by (on the same Wi-Fi, or directly like AirDrop where the Mac allows it), shows its keys and
/// sends it the keys that are tapped.
@MainActor
final class LinkClient: ObservableObject {
    enum State: Equatable {
        case looking, connecting(String), waiting(String), connected(String), refused(String)
    }

    @Published private(set) var state: State = .looking {
        didSet {
            if state == .looking { if lookingSince == nil { lookingSince = Date() } } else { lookingSince = nil }
            if case .waiting = state { if waitingSince == nil { waitingSince = Date() } } else { waitingSince = nil }
        }
    }
    @Published private(set) var place = ""
    /// "Several pages at once": the names of the pages shown side by side; empty = one page, as ever.
    @Published private(set) var tiles: [String] = []
    /// Which of those pages is the page this device is on (Mac 0.19 on; nil = not told).
    @Published private(set) var tileHere: Int?
    @Published private(set) var keys: [Int: PhoneLink.Key] = [:]
    /// The profiles and pages (from a Mac at 0.4 or later).
    @Published private(set) var status: PhoneLink.Status?
    /// Keys pressed a moment ago, anywhere (box, Mac screen or here): they light up.
    @Published private(set) var lit: Set<Int> = []
    /// What the last tap did, for a moment; ok false = the Mac could not do it.
    @Published private(set) var note: (text: String, ok: Bool)?
    /// Since when it has been looking for the Mac (for the hotspot hint).
    @Published private(set) var lookingSince: Date? = Date()
    /// Since when it has been waiting for the Mac's Allow (for the hint after 30 seconds).
    @Published private(set) var waitingSince: Date?
    /// A tap on the dark screen showed the keys while the Mac sleeps (the screen stays awake meanwhile).
    @Published var asleepKeysShown = false
    private var noteID = 0
    /// Failed tries in a row to reach the Mac (for the waiting time before the next one).
    private var failedTries = 0
    private var lookWork: DispatchWorkItem?
    private var asleepWork: DispatchWorkItem?
    /// What the Mac app understands: 3 = own keys, long press, favourites, the Mac at a glance, music
    /// (AMS Deck Mate 0.5 or later on the Mac).
    @Published private(set) var macVersion = 0
    /// The favourites row, five places.
    @Published private(set) var favourites: [Int: PhoneLink.Key] = [:]
    /// The Mac at a glance and what is playing.
    @Published private(set) var mac: PhoneLink.MacNow?
    /// Favourites pressed a moment ago.
    @Published private(set) var litFavourites: Set<Int> = []

    /// True while connected over the sealed line (always, since 0.11): the key screen shows a small lock.
    var isPrivate: Bool {
        guard case .connected = state else { return false }
        return isSample || session != nil
    }

    /// True with a Mac that knows the new parts.
    var newMac: Bool { macVersion >= 3 }
    /// The navigation picture: every page group with its pages (from a Mac at 0.6 or later).
    @Published private(set) var map: [PhoneLink.MapGroup] = []
    /// The Mac said its screen went to sleep (Mac 0.7 or later); a welcome or its wake clears it.
    @Published private(set) var macAsleep = false

    /// A page of the navigation picture was tapped. With "My own keys" its page group is remembered.
    func go(group: String, page: String) {
        if ownOn { ownProfile = group }
        guard case .connected = state, macVersion >= 4, !isSample else { return }
        send(.go(profile: group, page: page))
    }
    var hasFavourites: Bool { favourites.values.contains { $0.picture != nil } }

    /// "Several pages at once" (for using the iPhone or iPad without the box): on in Settings › Showing.
    var wideOn: Bool { UserDefaults.standard.bool(forKey: "widePages") }
    /// The Mac knows several pages at once (Mac 0.17 on).
    var wideMac: Bool { macVersion >= 9 }
    /// The Mac sends the words for what each key does (Mac 0.20 on): the Explain button shows.
    var explains: Bool { macVersion >= 10 }

    /// Tells the Mac how many pages to send (after connecting, and when the setting changes).
    func sendWide() {
        if isSample { sampleWide(wideOn); return }
        guard case .connected = state, wideMac else { return }
        send(.wide(count: wideOn ? PhoneLink.tiles(pad: UIDevice.current.userInterfaceIdiom == .pad) : 1))
        if !wideOn { tiles = []; tileHere = nil }
    }

    /// How many pages this device shows with "Several pages at once": 4 on an iPad, 2 on an iPhone.
    var wideCount: Int { PhoneLink.tiles(pad: UIDevice.current.userInterfaceIdiom == .pad) }

    /// The switch on top of the navigation picture (0.31), and the one in Settings: several pages or one.
    func setWide(_ on: Bool) {
        guard on != wideOn else { return }
        UserDefaults.standard.set(on, forKey: "widePages")
        objectWillChange.send()
        sendWide()
    }

    /// The made-up keys of the `-sample` launch follow the switch, so it can be tried without a Mac.
    private func sampleWide(_ on: Bool) {
        guard macVersion >= 9 else { return }
        tiles = on ? Array(SampleLink.wideNames.prefix(wideCount)) : []
        tileHere = on ? 0 : nil
        keys = on ? SampleLink.wideKeys(wideCount) : SampleLink.keys()
    }

    /// "My own keys": this device moves through one page group on its own place.
    var ownOn: Bool { UserDefaults.standard.bool(forKey: "ownKeys") }
    private var ownProfile: String? {
        get { UserDefaults.standard.string(forKey: "ownProfile") }
        set { UserDefaults.standard.set(newValue, forKey: "ownProfile") }
    }

    /// Tells the Mac whether this device follows it or has its own keys (after connecting, and when
    /// the setting changes). A Mac before 0.5 is never told: it would close the line.
    func sendOwn() {
        guard case .connected = state, newMac, !isSample else { return }
        send(.own(profile: ownOn ? (ownProfile ?? status?.current ?? "") : nil))
    }

    /// The Mac it is connected to, or the one it remembers.
    var macName: String? {
        switch state {
        case let .connecting(mac), let .waiting(mac), let .connected(mac), let .refused(mac): return mac
        case .looking: return remembered
        }
    }

    /// The four digits to compare with the Mac while it asks whether to allow this device.
    @Published private(set) var pairCode: String?
    /// The Mac did not answer the start of a private line: its AMS Deck Mate is older than 0.8.
    @Published private(set) var macTooOld = false

    private var browsers: [NWBrowser] = []
    private var connection: NWConnection?
    private var reader = PhoneLink.Reader()
    /// This line's one-time keys and, once the Mac's key is known, the sealed line.
    private var lineKeys = SecureLine.Keys()
    private var session: SecureLine.Session?
    /// Lines in a row that ended before the Mac answered the start.
    private var unanswered = 0
    /// True once this line reached the Mac at all (a Mac that is asleep or away never gets this far).
    private var reached = false
    /// When the Mac last said anything on this line, and the clock that asks "are you there?".
    private var lastHeard = Date()
    private var pingTimer: Timer?
    private var talkingTo = ""
    private var isSample = false
    private var wake: NSObjectProtocol?

    /// What the Macs gave when they allowed this device: Mac's name → "id:secret". The secret never
    /// travels again: it only proves this device to the Mac, and the Mac to this device.
    private var legacyTokens: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "macKeys") as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: "macKeys") }
    }
    private func token(for mac: String) -> String? { MacKeyStore.read(mac) ?? legacyTokens[mac] }
    private func keep(token: String, for mac: String) {
        if MacKeyStore.write(token, for: mac) {
            var old = legacyTokens
            if old[mac] != nil { old[mac] = nil; legacyTokens = old }
        } else {
            var old = legacyTokens
            old[mac] = token
            legacyTokens = old
        }
    }
    /// Moves what the old place holds into the Keychain; an entry leaves the old place only after it
    /// was read back from the Keychain. Anything that does not work stays where it is.
    private func moveKeysToKeychain() {
        var old = legacyTokens
        for (mac, value) in old where MacKeyStore.write(value, for: mac) { old[mac] = nil }
        if old.count != legacyTokens.count { legacyTokens = old }
    }
    private func idAndSecret(for mac: String) -> (id: String, secret: String)? {
        guard let parts = token(for: mac)?.split(separator: ":", maxSplits: 1), parts.count == 2 else { return nil }
        return (String(parts[0]), String(parts[1]))
    }
    /// The Mac it talked to last: it is picked first when several are close by.
    private var remembered: String? {
        get { UserDefaults.standard.string(forKey: "lastMac") }
        set { UserDefaults.standard.set(newValue, forKey: "lastMac") }
    }

    /// The real link, or made-up keys when started with "-sample" (pictures and checks).
    static func make() -> LinkClient {
        let client = LinkClient()
        if CommandLine.arguments.contains("-sample") {
            client.isSample = true
            client.state = .connected("Sample Mac")
            client.place = SampleLink.place
            client.keys = SampleLink.keys()
            client.status = SampleLink.status
            if !CommandLine.arguments.contains("-oldMac") {
                client.macVersion = PhoneLink.currentVersion
                client.favourites = SampleLink.favourites()
                client.mac = SampleLink.mac
                client.map = SampleLink.map()
                client.macAsleep = CommandLine.arguments.contains("-macAsleep")
                if client.wideOn || CommandLine.arguments.contains("-wide") {
                    // "-widePages 2" shows fewer pages, for checking the layout.
                    let asked = CommandLine.arguments.firstIndex(of: "-widePages").flatMap {
                        $0 + 1 < CommandLine.arguments.count ? Int(CommandLine.arguments[$0 + 1]) : nil }
                    let count = asked ?? PhoneLink.tiles(pad: UIDevice.current.userInterfaceIdiom == .pad)
                    client.tiles = Array(SampleLink.wideNames.prefix(count))
                    client.tileHere = 0
                    client.keys = SampleLink.wideKeys(count)
                }
            }
            client.lookingSince = nil
            if CommandLine.arguments.contains("-looking") {
                client.state = .looking
                client.lookingSince = .distantPast
            }
            if CommandLine.arguments.contains("-waiting") {
                client.state = .waiting("Sample Mac")
                client.pairCode = "4821"
            }
            if CommandLine.arguments.contains("-macTooOld") {
                client.state = .looking
                client.macTooOld = true
            }
        }
        return client
    }

    func start() {
        guard !isSample, browsers.isEmpty else { return }
        moveKeysToKeychain()
        UserDefaults.standard.removeObject(forKey: "macTokens")      // permissions from before 0.11 travelled readable
        // The Mac offers its keys on the shared network and, where it can, directly (like AirDrop).
        for type in [PhoneLink.service, PhoneLink.directService] {
            let parameters = NWParameters()
            parameters.includePeerToPeer = true
            let browser = NWBrowser(for: .bonjour(type: type, domain: nil), using: parameters)
            browser.browseResultsChangedHandler = { [weak self] _, changes in
                MainActor.assumeIsolated {
                    // A Mac's offer that newly appears: no more waiting, try at once.
                    let appeared = changes.contains { if case .added = $0 { return true } else { return false } }
                    if appeared { self?.lookNow() }
                }
            }
            browser.stateUpdateHandler = { [weak self] state in
                guard case .failed = state else { return }
                MainActor.assumeIsolated {
                    self?.browsers.forEach { $0.cancel() }
                    self?.browsers = []
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self?.start() }
                }
            }
            browser.start(queue: .main)
            browsers.append(browser)
        }
        // Back from the background: the old line is usually dead, so start a fresh one.
        wake = wake ?? NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.freshStart() }
        }
    }

    private func freshStart() {
        if case .refused = state { return }
        connection?.cancel()
        connection = nil
        stopPinging()
        unanswered = 0
        macTooOld = false
        state = .looking
        lookNow()
    }

    /// No waiting: forget the failed tries and look at once.
    private func lookNow() {
        failedTries = 0
        lookWork?.cancel()
        lookWork = nil
        lookAgain()
    }

    /// Asks the Mac "are you there?" every few seconds (a Mac from 0.15 on answers). A Mac that
    /// stays quiet is gone, however connected the line looks: back to looking for it.
    private func startPinging() {
        stopPinging()
        guard macVersion >= 8, !isSample else { return }
        lastHeard = Date()
        let timer = Timer(timeInterval: PhoneLink.pingEvery, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.ping() }
        }
        timer.tolerance = 0.5
        RunLoop.main.add(timer, forMode: .common)
        pingTimer = timer
    }

    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func ping() {
        guard case .connected = state else { return stopPinging() }
        // A sleeping Mac is quiet on purpose: it is only asked, never given up on.
        if !macAsleep, PhoneLink.isDead(lastHeard: lastHeard, now: Date()) { return dropLine() }
        send(.ping)
    }

    private func lookAgain() {
        found(browsers.reduce(into: Set<NWBrowser.Result>()) { $0.formUnion($1.browseResults) })
    }

    private func found(_ results: Set<NWBrowser.Result>) {
        guard connection == nil, state == .looking else { return }
        let macs = results.compactMap { result -> (String, NWEndpoint)? in
            if case let .service(name, _, _, _) = result.endpoint { return (name, result.endpoint) }
            return nil
        }.sorted { ($0.0, $0.1.debugDescription) < ($1.0, $1.1.debugDescription) }
        guard let pick = macs.first(where: { $0.0 == remembered }) ?? macs.first else { return }
        connect(to: pick.0, at: pick.1)
    }

    private func connect(to mac: String, at endpoint: NWEndpoint) {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        let line = NWConnection(to: endpoint, using: parameters)
        connection = line
        reader = PhoneLink.Reader()
        lineKeys = SecureLine.Keys()
        session = nil
        pairCode = nil
        reached = false
        talkingTo = mac
        state = .connecting(mac)
        line.stateUpdateHandler = { [weak self, weak line] state in
            MainActor.assumeIsolated {
                guard let self, let line, self.connection === line else { return }
                switch state {
                case .ready:
                    self.reached = true
                    // The start of a private line: first only a promise of this line's key.
                    self.sendReadable(.secure(promise: self.lineKeys.promise.base64EncodedString(), key: nil))
                case .failed, .cancelled:
                    self.lost(line)
                default:
                    break
                }
            }
        }
        line.start(queue: .main)
        receive(line)
        // A Mac that went away can leave its name behind for a while: give up after 6 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self, weak line] in
            guard let self, let line, self.connection === line, case .connecting = self.state else { return }
            line.cancel()
            self.lost(line)
        }
    }

    private func receive(_ line: NWConnection) {
        line.receive(minimumIncompleteLength: 1, maximumLength: 1_048_576) { [weak self] data, _, done, error in
            MainActor.assumeIsolated {
                guard let self, self.connection === line else { return }
                if let data, !data.isEmpty {
                    self.reader.feed(data)
                    while self.connection === line, let message = self.reader.next(&self.session) {
                        self.handle(message)
                    }
                }
                if self.reader.broken || done || error != nil {
                    line.cancel()
                    self.lost(line)
                    return
                }
                self.receive(line)
            }
        }
    }

    private func lost(_ line: NWConnection) {
        guard connection === line else { return }
        connection = nil
        pairCode = nil
        stopPinging()
        if session == nil, reached {
            // The line reached the Mac, but the Mac never answered the start: after two such tries in
            // a row, say that it needs an update. A Mac that is asleep, away or switched off is never
            // reached at all, so it does not count.
            unanswered += 1
            if unanswered >= 2 { macTooOld = true }
        }
        session = nil
        if case .refused = state { return }
        // A line that worked: look again after 1 second. Tries that fail in a row wait longer and longer.
        if case .connected = state { failedTries = 0 } else { failedTries += 1 }
        // The Mac slept, then the line was lost for good (switched off?): after 10 minutes say it is being looked for.
        if macAsleep, asleepWork == nil {
            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.asleepWork = nil
                if case .connected = self.state { return }
                self.macAsleep = false
            }
            asleepWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 600, execute: work)
        }
        state = .looking
        lookWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.lookAgain() }
        lookWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + PhoneBackoff.wait(afterFailures: max(failedTries, 1)), execute: work)
    }

    /// The Mac's key arrived: from here on the line is sealed. This device shows its own key
    /// (the Mac checks it against the promise), then says hello and proves who it is.
    private func turnPrivate(with macKey: String?) {
        guard session == nil, let macKey, let key = Data(base64Encoded: macKey),
              let made = SecureLine.session(lineKeys, role: .phone, other: key) else { return dropLine() }
        sendReadable(.secure(promise: nil, key: lineKeys.publicKey.base64EncodedString()))
        session = made
        unanswered = 0
        macTooOld = false
        let known = idAndSecret(for: talkingTo)
        send(.hello(phone: UIDevice.current.name, token: known?.id, version: PhoneLink.currentVersion,
                    proof: known.map { made.proof(secret: $0.secret, by: .phone) }))
    }

    private func dropLine() {
        guard let line = connection else { return }
        line.cancel()
        lost(line)
    }

    private func handle(_ message: PhoneLink.Message) {
        lastHeard = Date()
        // Before the line is sealed only the Mac's key is listened to; after that it never comes again.
        if case let .secure(_, key) = message { return turnPrivate(with: key) }
        guard let session else { return dropLine() }
        switch message {
        case .secure:
            break
        case .waiting:
            pairCode = session.code
            state = .waiting(talkingTo)
        case let .welcome(token, _, version, proof):
            if token.contains(":") {
                // Allowed just now: the Mac's id and secret for this device, to keep.
                guard case .waiting = state else { return dropLine() }
                keep(token: token, for: talkingTo)
            } else {
                // Known already: the Mac must prove that it knows the secret too.
                guard let known = idAndSecret(for: talkingTo), known.id == token,
                      session.checks(proof, secret: known.secret, by: .mac) else {
                    state = .refused(talkingTo)
                    connection?.cancel()
                    connection = nil
                    return
                }
            }
            pairCode = nil
            remembered = talkingTo
            macVersion = version ?? 2
            macAsleep = false
            failedTries = 0
            asleepWork?.cancel()
            asleepWork = nil
            if !newMac { favourites = [:]; mac = nil }
            if macVersion < 4 { map = [] }
            state = .connected(talkingTo)
            startPinging()
            if ownOn { sendOwn() }
            tiles = []
            if wideOn { sendWide() }
        case .refused:
            state = .refused(talkingTo)
            connection?.cancel()
            connection = nil
        case let .keys(place, list):
            self.place = place
            keys = Dictionary(list.map { ($0.index, $0) }, uniquingKeysWith: { $1 })
        case let .some(place, list):
            // Only the keys that look different: the others stay as they are.
            self.place = place
            for key in list { keys[key.index] = key }
        case let .tiles(names, at):
            tiles = wideOn ? names : []
            tileHere = wideOn ? at : nil
        case let .status(status):
            self.status = status
        case let .pressed(index):
            lit.insert(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in self?.lit.remove(index) }
        case let .ran(text, ok):
            show(text, ok: ok)
        case let .favourites(list):
            favourites = Dictionary(list.map { ($0.index, $0) }, uniquingKeysWith: { $1 })
        case let .mac(now):
            mac = now
        case let .map(groups):
            map = groups
        case let .asleep(asleep):
            if let words = PhoneLink.wakeNote(wasAsleep: macAsleep, asleep: asleep) { show(words, ok: true) }
            macAsleep = asleep
        case .hello, .press, .page, .profile, .own, .hold, .favourite, .music, .go, .visit, .ping, .pong, .wide:
            break
        }
    }

    /// Everything goes out sealed; without a private line nothing goes out at all.
    private func send(_ message: PhoneLink.Message) {
        guard let sealed = PhoneLink.sealed(PhoneLink.frame(message), by: &session) else { return }
        connection?.send(content: sealed, completion: .contentProcessed { _ in })
    }

    /// Only the two steps that start a private line go out readable.
    private func sendReadable(_ message: PhoneLink.Message) {
        connection?.send(content: PhoneLink.frame(message), completion: .contentProcessed { _ in })
    }

    // MARK: What the screens ask for

    private func show(_ text: String, ok: Bool) {
        noteID += 1
        let id = noteID
        note = (text, ok)
        DispatchQueue.main.asyncAfter(deadline: .now() + (ok ? 2 : 4)) { [weak self] in
            if self?.noteID == id { self?.note = nil }
        }
    }

    /// A swipe: +1 = next page, -1 = page before.
    func page(_ step: Int) {
        guard case .connected = state, !isSample else { return }
        send(.page(step: step))
    }

    /// Hold a profile (its id), or nil = Automatic.
    /// With "My own keys" it changes this device's own group instead, and remembers it.
    func pickProfile(_ id: String?) {
        if ownOn, newMac {
            guard let id else { return }
            ownProfile = id
            sendOwn()
            return
        }
        guard case .connected = state, !isSample else { return }
        send(.profile(id: id))
    }

    /// A swipe up or down: the next page group, not locked (a Mac before 0.7.1 can only lock it).
    func swipeProfile(_ id: String) {
        if ownOn, newMac { pickProfile(id); return }
        guard case .connected = state, !isSample else { return }
        send(macVersion >= 6 ? .visit(profile: id) : .profile(id: id))
    }

    func press(_ index: Int) {
        guard !isSample else { return }
        guard case .connected = state else { return show("Looking for your Mac", ok: false) }
        send(.press(index: index))
    }

    /// A key held for half a second: its long-press action (only a Mac at 0.5 or later knows it).
    func hold(_ index: Int) {
        guard !isSample else { return }
        guard case .connected = state else { return show("Looking for your Mac", ok: false) }
        send(newMac ? .hold(index: index) : .press(index: index))
    }

    /// A key of the favourites row, tapped or held.
    func favourite(_ index: Int, long: Bool) {
        litFavourites.insert(index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in self?.litFavourites.remove(index) }
        guard case .connected = state, newMac, !isSample else { return }
        send(.favourite(index: index, long: long))
    }

    /// A button of the music strip.
    func music(_ command: PhoneLink.MusicCommand) {
        guard case .connected = state, newMac, !isSample else { return }
        send(.music(command: command))
    }

    /// "Ask again" after the Mac said no.
    func retry() {
        connection?.cancel()
        connection = nil
        stopPinging()
        unanswered = 0
        macTooOld = false
        state = .looking
        lookNow()
    }

    /// "Forget this Mac": its permission is dropped here; next time it asks again.
    func forget() {
        if let mac = macName {
            MacKeyStore.delete(mac)
            var old = legacyTokens
            old[mac] = nil
            legacyTokens = old
        }
        remembered = nil
        connection?.cancel()
        connection = nil
        keys = [:]
        place = ""
        state = .looking
        lookNow()
    }
}
