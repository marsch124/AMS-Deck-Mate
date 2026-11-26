import AppKit
import Combine
import DeckMateCore
import Network

/// Offers the keys to an iPhone close by (on the same Wi-Fi, and directly like AirDrop where the Mac allows it) and runs
/// the keys it taps. An iPhone may only press keys once he allowed it on the Mac.
final class PhoneServer: ObservableObject {
    /// The iPhone connected right now, by its name.
    @Published private(set) var connected: String? { didSet { model.phoneConnected = connected != nil } }
    /// The iPhones he allowed: the id the Mac gave it → the iPhone's name.
    @Published private(set) var allowed: [String: String]
    /// The secret each allowed iPhone proves itself with (it never travels again after the first time).
    private var secrets: [String: String]
    @Published private(set) var isOn: Bool

    private let model: AppModel
    private var listeners: [NWListener] = []
    private var phones: [ObjectIdentifier: Phone] = [:]
    private var waitingToAsk: [Phone] = []
    private var asking = false
    private var watch: AnyCancellable?
    private var events: [AnyCancellable] = []
    private var restart: DispatchWorkItem?
    private let watch2 = MacWatch()
    /// The navigation picture as last drawn, and the setup it was drawn from.
    private var mapFrame: Data?
    private var mapDeck: Deck?
    private var sleepWatch: [NSObjectProtocol] = []
    private var macAsleep = false
    /// The iPhone the "wants to use your keys" window is about right now.
    private weak var askingPhone: Phone?
    /// True while that window is on screen.
    private var alertUp = false
    /// When he said "Don't Allow" lately: after three in ten minutes nobody new is asked about for a while.
    private var refusals: [Date] = []
    private var sweepTimer: Timer?

    /// Before 0.8 (permissions that travelled readable): dropped, each iPhone is allowed once more.
    private static let oldAllowedKey = "allowedPhones"
    private static let pairedKey = "pairedPhones"
    /// No more lines than this at once, and a line must turn private within this many seconds.
    private static let mostLines = 8
    private static let startTime = 10.0
    /// Devices he has not allowed: no more than this many lines at once, none longer than `strangerTime`
    /// seconds unless he is being asked about it, and no more than `mostWaiting` wait to be asked about.
    private static let mostStrangers = 3
    private static let strangerTime = 30.0
    private static let mostWaiting = 2
    private static let offKey = "phoneOff"
    static var macName: String { Host.current().localizedName ?? "Mac" }

    private final class Phone {
        let connection: NWConnection
        var reader = PhoneLink.Reader()
        /// This line's one-time keys, the iPhone's promise, and the sealed line once both keys are known.
        let keys = SecureLine.Keys()
        var promise: Data?
        var session: SecureLine.Session?
        var name = "iPhone"
        var token: String?
        var trusted = false
        /// The note AMS Triathlon Training keeps on this device, as the device handed it over (0.23);
        /// nil = it handed over none (no Triathlon Training there, or a Deck Mate before 0.33).
        var training: TrainingKeys.Note?
        /// The keys this iPhone shows now, and the line above them.
        var lastKeys: [PhoneLink.Key]?
        var lastPlace: String?
        var lastStatus: Data?
        /// True once this line asked to be allowed: it is asked about once, not again and again.
        var asked = false
        let began = Date()
        /// When this line last said anything.
        var heard = Date()
        /// 2 = it understands status, pressed, ran, page and profile.
        var version = 1
        /// "My own keys": this iPhone's own place; nil = it follows the Mac.
        var own: DeckPosition?
        var lastFavourites: Data?
        var lastMac: Data?
        var lastMap: Data?
        /// "Several pages at once": how many pages this iPhone or iPad shows (1 = one, as ever).
        var wide = 1
        var lastTiles: [String]?
        var lastSpot: Int?
        init(_ connection: NWConnection) { self.connection = connection }
    }

    init(model: AppModel) {
        self.model = model
        UserDefaults.standard.removeObject(forKey: PhoneServer.oldAllowedKey)
        let paired = PairedStore.load(PhoneServer.pairedKey)
        allowed = paired.names
        secrets = paired.secrets
        isOn = !UserDefaults.standard.bool(forKey: PhoneServer.offKey)
    }

    /// Made up, for pictures: never his own iPhones.
    init(sampleFor model: AppModel) {
        self.model = model
        allowed = ["sample": "Sample iPhone"]
        secrets = [:]
        connected = "Sample iPhone"
        isOn = true
    }

    func start() {
        guard isOn, listeners.isEmpty else { return }
        // The keys go out again whenever the deck moves or the setup changes.
        watch = model.$position.combineLatest(model.$deck, model.$pinned, model.$recentApps)
            .debounce(for: .milliseconds(60), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.sendKeysToAll() }
        // The Mac's screen sleeping or waking: a v5 iPhone or iPad can go dark with it.
        let center = NSWorkspace.shared.notificationCenter
        for (name, asleep) in [(NSWorkspace.screensDidSleepNotification, true), (NSWorkspace.willSleepNotification, true),
                               (NSWorkspace.screensDidWakeNotification, false), (NSWorkspace.didWakeNotification, false)] {
            sleepWatch.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.macAsleep = asleep
                // The Mac heard nothing while it slept: that says nothing about the lines.
                if !asleep { self?.phones.values.forEach { $0.heard = Date() } }
                self?.toPhones(since: 5, .asleep(asleep))
            })
        }
        events = [
            model.$copiedTexts.dropFirst().debounce(for: .milliseconds(60), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.sendKeysToAll() },
            model.$recentFiles.dropFirst().debounce(for: .milliseconds(60), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.sendKeysToAll() },
            // A timer's second, a switch, an app opened or quit: the keys look different.
            model.$liveStamp.dropFirst().debounce(for: .milliseconds(40), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.sendKeysToAll() },
            model.pressedEvents.sink { [weak self] index in
                // An iPhone with its own keys shows other keys: it lights only its own taps.
                guard let self else { return }
                for phone in self.phones.values where phone.trusted && phone.version >= 2 && phone.own == nil {
                    self.send(.pressed(index: index), to: phone)
                }
            },
            model.ranEvents.sink { [weak self] text, ok in self?.toNewPhones(.ran(text: text, ok: ok)) },
            watch2.$now.dropFirst().sink { [weak self] now in
                DispatchQueue.main.async { self?.sendMac(now) }
            },
        ]
        // Two offers: on the shared network, and directly (like AirDrop) where the Mac allows it.
        for (type, direct) in [(PhoneLink.service, false), (PhoneLink.directService, true)] {
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = direct
            guard let listener = try? NWListener(using: parameters) else { continue }
            listener.service = NWListener.Service(name: PhoneServer.macName, type: type)
            listener.stateUpdateHandler = { [weak self] state in
                BoxLog.note("iPhone link \(type): \(state)")
                if case .failed = state, !direct { self?.stop(keepOn: true); self?.retryLater() }
            }
            listener.serviceRegistrationUpdateHandler = { change in BoxLog.note("iPhone link offered: \(change)") }
            listener.newConnectionHandler = { [weak self] connection in self?.accept(connection) }
            listener.start(queue: .main)
            listeners.append(listener)
        }
        askForLocalNetwork()
        let sweep = Timer(timeInterval: 10, repeats: true) { [weak self] _ in self?.sweep() }
        sweep.tolerance = 2
        RunLoop.main.add(sweep, forMode: .common)
        sweepTimer = sweep
    }

    /// Closes the lines nobody needs: a device he has not allowed that just sits there, and an
    /// allowed iPhone that has gone quiet (it asks "are you there?" every few seconds).
    private func sweep() {
        let now = Date()
        for (id, phone) in phones {
            let stranger = !phone.trusted && phone !== askingPhone && !waitingToAsk.contains { $0 === phone }
                && now.timeIntervalSince(phone.began) > PhoneServer.strangerTime
            let quiet = phone.trusted && phone.version >= 8
                && PhoneLink.isDead(lastHeard: phone.heard, now: now, limit: PhoneLink.macQuietLimit)
            guard stranger || quiet else { continue }
            if quiet { BoxLog.note("iPhone link: “\(phone.name)” went quiet, line closed") }
            phone.connection.cancel()
            drop(id)
        }
    }

    /// The Mac only offers the keys nearby once he allowed "find devices on local networks", and it
    /// asks him only when the app looks around itself: a short look for other Macs does that.
    private func askForLocalNetwork() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let look = NWBrowser(for: .bonjour(type: PhoneLink.service, domain: nil), using: parameters)
        look.stateUpdateHandler = { state in BoxLog.note("Local network look: \(state)") }
        look.start(queue: .main)
        // A word to the local network's Bonjour address is what makes the Mac ask for sure.
        let hello = NWConnection(host: "224.0.0.251", port: 5353, using: .udp)
        hello.stateUpdateHandler = { state in
            BoxLog.note("Local network hello: \(state)")
            if case .ready = state { hello.send(content: Data([0]), completion: .contentProcessed { _ in }) }
        }
        hello.start(queue: .main)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            look.cancel()
            hello.cancel()
        }
    }

    private func retryLater() {
        restart?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.start() }
        restart = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: work)
    }

    private func stop(keepOn: Bool) {
        restart?.cancel()
        sweepTimer?.invalidate()
        sweepTimer = nil
        listeners.forEach { $0.cancel() }
        listeners = []
        watch = nil
        events = [
            model.$copiedTexts.dropFirst().debounce(for: .milliseconds(60), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.sendKeysToAll() },
            model.$recentFiles.dropFirst().debounce(for: .milliseconds(60), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.sendKeysToAll() },]
        phones.values.forEach { $0.connection.cancel() }
        phones = [:]
        waitingToAsk = []
        connected = nil
    }

    /// "Let an iPhone use these keys" in Settings.
    func setOn(_ on: Bool) {
        isOn = on
        UserDefaults.standard.set(!on, forKey: PhoneServer.offKey)
        if on { start() } else { stop(keepOn: false) }
    }

    /// Takes the permission back: the iPhone has to be allowed again.
    func forget(_ token: String) {
        allowed[token] = nil
        secrets[token] = nil
        PairedKeychain.delete(token)
        keepPaired()
        for (id, phone) in phones where phone.token == token {
            phone.connection.cancel()
            drop(id)
        }
    }

    // MARK: One iPhone

    private func keepPaired() {
        PairedStore.save(PhoneServer.pairedKey, names: allowed, secrets: secrets)
    }

    private func accept(_ connection: NWConnection) {
        // A few lines at most, and only some of them for devices he has not allowed: his own iPhone
        // and iPad always find room.
        guard phones.count < PhoneServer.mostLines,
              phones.values.filter({ !$0.trusted }).count < PhoneServer.mostStrangers else { connection.cancel(); return }
        let phone = Phone(connection)
        phone.reader.limit = PhoneLink.largestFromPhone
        let id = ObjectIdentifier(phone)
        phones[id] = phone
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed, .cancelled: self?.drop(id)
            default: break
            }
        }
        connection.start(queue: .main)
        receive(phone, id)
        // A line that has not turned private in time is closed.
        DispatchQueue.main.asyncAfter(deadline: .now() + PhoneServer.startTime) { [weak self, weak phone] in
            guard let self, let phone, phone.session == nil, self.phones[id] != nil else { return }
            phone.connection.cancel()
            self.drop(id)
        }
    }

    private func receive(_ phone: Phone, _ id: ObjectIdentifier) {
        phone.connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] data, _, done, error in
            guard let self, self.phones[id] != nil else { return }
            var open = true
            if let data, !data.isEmpty {
                phone.reader.feed(data)
                while open, let message = phone.reader.next(&phone.session) {
                    open = self.begin(message, from: phone)
                }
            }
            if !open {
                // Let the last word ("not allowed") go out before the line closes.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    phone.connection.cancel()
                    self?.drop(id)
                }
                return
            }
            if phone.reader.broken || done || error != nil {
                phone.connection.cancel()
                self.drop(id)
                return
            }
            self.receive(phone, id)
        }
    }

    private func drop(_ id: ObjectIdentifier) {
        guard let phone = phones.removeValue(forKey: id) else { return }
        waitingToAsk.removeAll { $0 === phone }
        // The device he is being asked about is gone: the question goes with it.
        if phone === askingPhone, alertUp { NSApp.abortModal() }
        connected = phones.values.first(where: \.trusted)?.name
        lookAtMacIfAsked()
    }

    /// The battery and volume are only looked at while an iPhone that shows them is connected.
    private func lookAtMacIfAsked() {
        watch2.isWatching = phones.values.contains { $0.trusted && $0.version >= 3 }
    }

    private func sendMac(_ now: PhoneLink.MacNow) {
        let frame = PhoneLink.frame(.mac(now))
        for phone in phones.values where phone.trusted && phone.version >= 3 && phone.lastMac != frame {
            phone.lastMac = frame
            post(frame, to: phone)
        }
    }

    /// The start of a line: nothing but the three steps that make it private is ever answered
    /// readable. False = close the line.
    private func begin(_ message: PhoneLink.Message, from phone: Phone) -> Bool {
        if phone.session != nil {
            if case .secure = message { return false }
            phone.heard = Date()
            handle(message, from: phone)
            return true
        }
        switch message {
        case let .secure(promise?, nil) where phone.promise == nil:
            guard let promise = Data(base64Encoded: promise), promise.count == 32 else { return false }
            phone.promise = promise
            let reply = PhoneLink.frame(.secure(promise: nil, key: phone.keys.publicKey.base64EncodedString()))
            phone.connection.send(content: reply, completion: .contentProcessed { _ in })
            return true
        case let .secure(nil, key?):
            guard let promise = phone.promise, let key = Data(base64Encoded: key),
                  SecureLine.promise(for: key) == promise,
                  let session = SecureLine.session(phone.keys, role: .mac, other: key) else { return false }
            phone.session = session
            return true
        case .hello:
            // An iPhone app from before 0.11: it cannot keep the line private, so it is not answered.
            BoxLog.note("iPhone link: an older Deck Mate app asked (needs 0.11 or later)")
            phone.connection.send(content: PhoneLink.frame(.refused), completion: .contentProcessed { _ in })
            return false
        default:
            return false
        }
    }

    private func handle(_ message: PhoneLink.Message, from phone: Phone) {
        switch message {
        case let .hello(name, token, version, proof):
            // One hello a line: a device cannot ask to be allowed again and again.
            guard !phone.trusted, !phone.asked else { return }
            phone.version = version ?? 1
            phone.name = name.isEmpty ? "iPhone" : String(name.prefix(60))
            if let token, allowed[token] != nil, let secret = secrets[token],
               phone.session?.checks(proof, secret: secret, by: .phone) == true {
                welcome(phone, token: token, secret: secret, first: false)
            } else {
                phone.asked = true
                let now = Date()
                refusals.removeAll { now.timeIntervalSince($0) > 600 }
                guard refusals.count < 3, waitingToAsk.count < PhoneServer.mostWaiting else {
                    // He said no three times in ten minutes, or others wait already: not asked about.
                    BoxLog.note("iPhone link: “\(phone.name)” was not asked about (too many requests)")
                    send(.refused, to: phone)
                    closeSoon(phone)
                    return
                }
                send(.waiting, to: phone)
                waitingToAsk.append(phone)
                askNext()
            }
        case .ping:
            guard phone.trusted else { return }
            send(.pong, to: phone)
        case let .press(index):
            guard phone.trusted, (0..<StreamDeckProtocol.keyCount * phone.wide).contains(index) else { return }
            press(index, long: false, favourite: false, from: phone)
        case let .hold(index):
            guard phone.trusted, (0..<StreamDeckProtocol.keyCount * phone.wide).contains(index) else { return }
            press(index, long: true, favourite: false, from: phone)
        case let .training(note):
            // The device's own note from AMS Triathlon Training (0.23). Read as far as it makes sense; too large = none.
            guard phone.trusted else { return }
            let read = TrainingKeys.note(from: note.map { Data($0.utf8) })
            guard read != phone.training else { return }
            phone.training = read
            model.phoneTraining(read, from: phone.token ?? phone.name)
            sendKeys(to: phone)
        case let .wide(count):
            guard phone.trusted else { return }
            phone.wide = min(max(count, 1), PhoneLink.mostTiles)
            phone.lastKeys = nil
            phone.lastTiles = nil
            sendKeys(to: phone)
        case let .favourite(index, long):
            guard phone.trusted, (0..<PhoneLink.favouriteCount).contains(index) else { return }
            press(index, long: long, favourite: true, from: phone)
        case let .page(step):
            guard phone.trusted, step == 1 || step == -1 else { return }
            if let own = ownPlace(of: phone) {
                phone.own = Navigator.step(step, at: own, in: model.deck)
                sendKeys(to: phone)
            } else {
                model.stepPage(step)
            }
        case let .profile(id):
            // An iPhone with its own keys changes its profile with `own`; it never holds the Mac's.
            guard phone.trusted, phone.own == nil else { return }
            model.pin(id.flatMap { UUID(uuidString: $0) })
        case let .visit(profile):
            // A swipe: show that page group, but keep following the app in front (no lock).
            guard phone.trusted, phone.own == nil, let id = UUID(uuidString: profile) else { return }
            model.visit(id)
        case let .own(profile):
            guard phone.trusted else { return }
            phone.own = Navigator.own(profile: profile, was: phone.own, in: model.deck)
            sendKeys(to: phone)
        case let .go(profile, page):
            guard phone.trusted, let place = Navigator.go(profile: profile, page: page, in: model.deck) else { return }
            if phone.own != nil {
                phone.own = place
                sendKeys(to: phone)
            } else {
                // Like picking the page group by hand: it is locked, then the page shows.
                if model.position?.profile != place.profile || model.pinned == nil { model.pin(place.profile) }
                model.show(place)
            }
        case let .music(command):
            guard phone.trusted else { return }
            switch command {
            case .playPause: model.music(.playPause)
            case .next: model.music(.next)
            case .volumeUp: watch2.stepVolume(1)
            case .volumeDown: watch2.stepVolume(-1)
            }
        default:
            break
        }
    }

    /// This iPhone's own place, put right after the setup changed; nil = it follows the Mac.
    private func ownPlace(of phone: Phone) -> DeckPosition? {
        guard phone.own != nil else { return nil }
        phone.own = Navigator.repair(phone.own, in: model.deck)
        return phone.own
    }

    /// A tap or long press from an iPhone. With its own keys only its own place moves: the Mac's
    /// keys on screen and the box stay where they are, and the Mac still does what the key says.
    private func press(_ index: Int, long: Bool, favourite: Bool, from phone: Phone) {
        // A key that has a double press waits a third of a second for a second tap (0.20). The Mac
        // keeps the time, so every version of the iPhone and iPad app has the double press.
        if !long, let key = key(index, favourite: favourite, of: phone), key.hasTwice {
            let place = "phone:\(ObjectIdentifier(phone).hashValue):\(favourite ? "f" : "k")\(index)"
            model.pressOrTwice(place, once: { [weak self, weak phone] in
                // The same key must still be there: another page may show by now.
                guard let self, let phone, self.key(index, favourite: favourite, of: phone)?.id == key.id else { return }
                self.act(index, long: false, favourite: favourite, twice: false, from: phone)
            }, twice: { [weak self, weak phone] in
                guard let self, let phone else { return }
                self.act(index, long: false, favourite: favourite, twice: true, from: phone)
            })
            return
        }
        act(index, long: long, favourite: favourite, twice: false, from: phone)
    }

    /// The key a tap from this device means, as it is set up: a favourite, a key of one of the pages
    /// shown at once, a key of the device's own place, or a key of the page the Mac shows.
    private func key(_ index: Int, favourite: Bool, of phone: Phone) -> DeckKey? {
        if favourite { return model.deck.favourites[index] }
        let (tile, place) = PhoneLink.tile(of: index)
        guard let first = ownPlace(of: phone) ?? model.position else { return nil }
        if phone.wide > 1, phone.version >= 9 {
            let pages = Navigator.spread(at: first, count: phone.wide, in: model.deck)
            return tile < pages.count ? Navigator.keys(at: pages[tile], in: model.deck)[place] : nil
        }
        return Navigator.keys(at: first, in: model.deck)[index]
    }

    /// A "Training today" key tapped on a device that has Triathlon Training's note (0.23): that device opens
    /// the link, because only there can the session be logged (or opened on the device in his hand). The Mac
    /// answers with the link; the device checks it against its own note. True = taken care of.
    private func trainingOnPhone(_ index: Int, favourite: Bool, from phone: Phone) -> Bool {
        guard phone.version >= 11, phone.training != nil,
              let key = key(index, favourite: favourite, of: phone), key.action.type == .training else { return false }
        let now = Date()
        let press = TrainingKeys.press(phone: phone.training, best: model.trainingBest, today: TrainingKeys.day(now), now: now)
        guard press.onPhone else { return false }
        if !favourite { send(.pressed(index: index), to: phone) }
        send(.open(link: press.link), to: phone)
        if CommandLine.arguments.contains("--checks") {
            BoxLog.note("check: training key from “\(phone.name)” → the device opens \(press.link)\(press.logs ? " (logs it)" : "")")
        }
        return true
    }

    /// A key as this device shows it: a training key is drawn from the device's own note while that is from
    /// today, with "press for done" where a press there logs the session. Every other key as the Mac shows it.
    private func shown(_ plain: DeckKey?, live: DeckKey?, to phone: Phone) -> DeckKey? {
        guard let plain, plain.action.type == .training, let note = ownTraining(of: phone) else { return live }
        return plain.showingTraining(TrainingKeys.glance(note, installed: true, logs: true))
    }

    /// What a key does, in words, for this device ("Explain").
    private func says(_ plain: DeckKey?, in profile: UUID?, to phone: Phone) -> KeySays.Lines? {
        guard phone.version >= 10, var lines = model.says(plain, in: profile) else { return nil }
        if plain?.action.type == .training, let note = ownTraining(of: phone) { lines.tap = TrainingKeys.says(note, logs: true) }
        return lines
    }

    /// The device's own note, while it is from today.
    private func ownTraining(of phone: Phone) -> TrainingKeys.Note? {
        let now = Date()
        guard phone.version >= 11, let note = phone.training,
              TrainingKeys.isFresh(note, today: TrainingKeys.day(now), now: now) else { return nil }
        return note
    }

    private func act(_ index: Int, long: Bool, favourite: Bool, twice: Bool, from phone: Phone) {
        if !long, !twice, trainingOnPhone(index, favourite: favourite, from: phone) { return }
        let (tile, place) = PhoneLink.tile(of: index)
        // Several pages at once: with his own places (0.19) the first page shown need not be the page
        // the device is on, so every key acts from the page it is drawn on.
        if !favourite, phone.wide > 1, phone.version >= 9, tile > 0 || !firstTileIsHere(phone) {
            pressOnTile(tile, place: place, index: index, long: long, twice: twice, from: phone)
            return
        }
        guard let own = ownPlace(of: phone) else {
            model.pressFromPhone(index, long: long, favourite: favourite, twice: twice)
            return
        }
        if !favourite, phone.version >= 2 { send(.pressed(index: index), to: phone) }
        phone.own = model.act(index, at: own, long: long, favourite: favourite, twice: twice).position
        sendKeys(to: phone)
    }

    /// Whether the first of the pages shown is the page this device is on (always so without places of his own).
    private func firstTileIsHere(_ phone: Phone) -> Bool {
        guard let here = ownPlace(of: phone) ?? model.position else { return true }
        return Navigator.spot(of: here, in: Navigator.spread(at: here, count: phone.wide, in: model.deck)) == 0
    }

    /// "Several pages at once": a key of the second, third or fourth page. It acts from its own page;
    /// a key that opens a folder or another page moves the view there (that page becomes the first).
    private func pressOnTile(_ tile: Int, place: Int, index: Int, long: Bool, twice: Bool, from phone: Phone) {
        guard let first = ownPlace(of: phone) ?? model.position else { return }
        let pages = Navigator.spread(at: first, count: phone.wide, in: model.deck)
        guard tile < pages.count else { return }
        send(.pressed(index: index), to: phone)
        let at = pages[tile]
        let moved = model.act(place, at: at, long: long, twice: twice).position
        if moved != at {
            if phone.own != nil { phone.own = moved } else { model.show(moved) }
        }
        sendKeys(to: phone)
    }

    /// Asks him on the Mac, one iPhone at a time.
    private func askNext() {
        guard !asking, let phone = waitingToAsk.first else { return }
        waitingToAsk.removeFirst()
        guard phones[ObjectIdentifier(phone)] != nil else { return askNext() }
        asking = true
        askingPhone = phone
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.phones[ObjectIdentifier(phone)] != nil else {
                // Gone before the question came up.
                self.asking = false
                self.askingPhone = nil
                return self.askNext()
            }
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "“\(phone.name)” wants to use your keys"
            alert.informativeText = "It shows the number \(phone.session?.code ?? "")\n\nAllow it only if your own iPhone or iPad shows the same number. It then shows the same keys as your Stream Deck, and this Mac does what you tap there."
            // Return and Escape both say no: Allow takes a click, so a key pressed while typing
            // in another app can never let a stranger in.
            alert.addButton(withTitle: "Don’t Allow")
            alert.addButton(withTitle: "Allow")
            alert.buttons[1].keyEquivalent = ""
            self.alertUp = true
            let answer = alert.runModal()
            self.alertUp = false
            let yes = answer == .alertSecondButtonReturn
            self.asking = false
            self.askingPhone = nil
            if self.phones[ObjectIdentifier(phone)] != nil {
                if yes {
                    self.welcome(phone, token: UUID().uuidString, secret: SecureLine.newSecret(), first: true)
                } else {
                    if answer == .alertFirstButtonReturn { self.refusals.append(Date()) }
                    self.send(.refused, to: phone)
                    self.closeSoon(phone)
                }
            }
            self.askNext()
        }
    }

    /// Allowed. The first time the iPhone gets its id and its secret ("id:secret", over the private
    /// line); later only the id, and the Mac proves that it knows the secret too.
    private func welcome(_ phone: Phone, token: String, secret: String, first: Bool) {
        phone.token = token
        phone.trusted = true
        allowed[token] = phone.name
        secrets[token] = secret
        keepPaired()
        connected = phone.name
        send(.welcome(token: first ? token + ":" + secret : token, mac: PhoneServer.macName,
                      version: PhoneLink.currentVersion,
                      proof: phone.session?.proof(secret: secret, by: .mac)), to: phone)
        sendKeys(to: phone)
        lookAtMacIfAsked()
        if phone.version >= 3 {
            let frame = PhoneLink.frame(.mac(watch2.now))
            phone.lastMac = frame
            post(frame, to: phone)
        }
    }

    /// Closes a line once its last word ("not allowed") has gone out.
    private func closeSoon(_ phone: Phone) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak phone] in
            guard let self, let phone else { return }
            phone.connection.cancel()
            self.drop(ObjectIdentifier(phone))
        }
    }

    // MARK: Sending

    private func send(_ message: PhoneLink.Message, to phone: Phone) {
        post(PhoneLink.frame(message), to: phone)
    }

    /// Everything goes out sealed; without a private line nothing goes out at all.
    private func post(_ frame: Data, to phone: Phone) {
        guard let sealed = PhoneLink.sealed(frame, by: &phone.session) else { return }
        phone.connection.send(content: sealed, completion: .contentProcessed { _ in })
    }

    private func sendKeysToAll() {
        for phone in phones.values where phone.trusted { sendKeys(to: phone) }
    }

    private func sendKeys(to phone: Phone) {
        let place = ownPlace(of: phone) ?? model.position
        // Several pages at once (an iPhone or iPad from 0.19 on): 15 keys per page, one long list.
        let pages: [DeckPosition?] = phone.wide > 1 && phone.version >= 9
            ? (place.map { Navigator.spread(at: $0, count: phone.wide, in: model.deck) } ?? [nil])
            : [place]
        var list: [PhoneLink.Key] = []
        for (tile, page) in pages.enumerated() {
            let plain = page.map { Navigator.keys(at: $0, in: model.deck) } ?? [:]
            let keys = model.live(plain)
            list += (0..<StreamDeckProtocol.keyCount).map { index in
                // The words for what the key does ride along, for "Explain" (an app from 0.32 on).
                let says = says(plain[index], in: page?.profile, to: phone)
                let key = shown(plain[index], live: keys[index], to: phone)
                return PhoneLink.Key(index: tile * StreamDeckProtocol.keyCount + index, title: KeyArt.title(key),
                                     picture: KeyArt.pngForPhone(key),
                                     tap: says?.tap, hold: says?.hold, twice: says?.twice)
            }
        }
        if phone.version >= 9 {
            let names = phone.wide > 1 ? pages.map { pageName(at: $0) } : []
            // Which of them is the page the device is on (its name is blue there, from 0.31 on).
            let at = phone.wide > 1 ? place.flatMap { Navigator.spot(of: $0, in: pages.compactMap { $0 }) } : nil
            if names != phone.lastTiles || at != phone.lastSpot {
                phone.lastTiles = names
                phone.lastSpot = at
                send(.tiles(names: names, at: at), to: phone)
            }
        }
        let line = model.placeLine(at: place)
        // An iPhone app from 0.17 on gets only the keys that look different (a timer's second = one
        // small picture); an older one gets all fifteen whenever anything changed.
        let changed = PhoneLink.changed(from: phone.lastKeys, to: list)
        if let changed, line == phone.lastPlace, changed.isEmpty {
            // Nothing to say.
        } else if let changed, phone.version >= 8, changed.count < list.count {
            send(.some(place: line, keys: changed), to: phone)
        } else {
            send(.keys(place: line, keys: list), to: phone)
        }
        phone.lastKeys = list
        phone.lastPlace = line
        if phone.version >= 3 {
            let row = (0..<PhoneLink.favouriteCount).map { index in
                let says = says(model.deck.favourites[index], in: place?.profile, to: phone)
                let key = shown(model.deck.favourites[index], live: model.live(model.deck.favourites[index]), to: phone)
                return PhoneLink.Key(index: index, title: KeyArt.title(key), picture: KeyArt.pngForPhone(key),
                                     tap: says?.tap, hold: says?.hold, twice: says?.twice)
            }
            let frame = PhoneLink.frame(.favourites(keys: row))
            if frame != phone.lastFavourites {
                phone.lastFavourites = frame
                post(frame, to: phone)
            }
        }
        if phone.version >= 4 {
            if mapDeck != model.deck || mapFrame == nil {
                mapDeck = model.deck
                mapFrame = PhoneLink.frame(.map(groups: model.deck.profiles.map { group in
                    PhoneLink.MapGroup(id: group.id.uuidString, name: group.name.isEmpty ? "No name" : group.name,
                                       pages: group.pages.map {
                        .init(id: $0.id.uuidString, name: $0.name.isEmpty ? "Page" : $0.name, folder: $0.parent != nil,
                              picture: KeyArt.pngForMap($0))
                    })
                }))
            }
            if let mapFrame, mapFrame != phone.lastMap {
                phone.lastMap = mapFrame
                post(mapFrame, to: phone)
            }
        }
        guard phone.version >= 2, let position = place else { return }
        let numbers = Navigator.pageNumber(at: position, in: model.deck)
        let status = PhoneLink.Status(
            profiles: model.deck.profiles.map { .init(id: $0.id.uuidString, name: $0.name.isEmpty ? "No name" : $0.name) },
            current: position.profile.uuidString, held: phone.own == nil && model.pinned != nil, page: numbers.page, pages: numbers.pages,
            pageID: phone.version >= 4 ? position.page.uuidString : nil)
        let frame = PhoneLink.frame(.status(status))
        guard frame != phone.lastStatus else { return }
        phone.lastStatus = frame
        post(frame, to: phone)
    }

    /// A page's own name for "Several pages at once" ("Page 2" when it has none).
    private func pageName(at position: DeckPosition?) -> String {
        guard let position, let group = model.deck.profile(position.profile),
              let page = group.page(position.page) else { return "" }
        if !page.name.isEmpty { return page.name }
        let tops = group.topPages
        return tops.firstIndex(where: { $0.id == page.id }).map { "Page \($0 + 1)" } ?? "Folder"
    }

    private func toPhones(since version: Int, _ message: PhoneLink.Message) {
        for phone in phones.values where phone.trusted && phone.version >= version { send(message, to: phone) }
    }

    /// Only iPhone apps that know the message get it (the first iPhone app would close the line).
    private func toNewPhones(_ message: PhoneLink.Message) {
        for phone in phones.values where phone.trusted && phone.version >= 2 { send(message, to: phone) }
    }
}
