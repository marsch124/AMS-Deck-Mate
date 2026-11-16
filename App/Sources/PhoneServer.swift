import AppKit
import Combine
import DeckMateCore
import Network

/// Offers the keys to an iPhone close by (on the same Wi-Fi, and directly like AirDrop where the Mac allows it) and runs
/// the keys it taps. An iPhone may only press keys once he allowed it on the Mac.
final class PhoneServer: ObservableObject {
    /// The iPhone connected right now, by its name.
    @Published private(set) var connected: String?
    /// The iPhones he allowed: token → the iPhone's name.
    @Published private(set) var allowed: [String: String]
    @Published private(set) var isOn: Bool

    private let model: AppModel
    private var listeners: [NWListener] = []
    private var phones: [ObjectIdentifier: Phone] = [:]
    private var waitingToAsk: [Phone] = []
    private var asking = false
    private var watch: AnyCancellable?
    private var events: [AnyCancellable] = []
    private var restart: DispatchWorkItem?

    private static let allowedKey = "allowedPhones"
    private static let offKey = "phoneOff"
    static var macName: String { Host.current().localizedName ?? "Mac" }

    private final class Phone {
        let connection: NWConnection
        var reader = PhoneLink.Reader()
        var name = "iPhone"
        var token: String?
        var trusted = false
        var lastSent: Data?
        var lastStatus: Data?
        /// 2 = it understands status, pressed, ran, page and profile.
        var version = 1
        init(_ connection: NWConnection) { self.connection = connection }
    }

    init(model: AppModel) {
        self.model = model
        allowed = UserDefaults.standard.dictionary(forKey: PhoneServer.allowedKey) as? [String: String] ?? [:]
        isOn = !UserDefaults.standard.bool(forKey: PhoneServer.offKey)
    }

    /// Made up, for pictures: never his own iPhones.
    init(sampleFor model: AppModel) {
        self.model = model
        allowed = ["sample": "Sample iPhone"]
        connected = "Sample iPhone"
        isOn = true
    }

    func start() {
        guard isOn, listeners.isEmpty else { return }
        // The keys go out again whenever the deck moves or the setup changes.
        watch = model.$position.combineLatest(model.$deck, model.$pinned)
            .debounce(for: .milliseconds(60), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.sendKeysToAll() }
        events = [
            model.pressedEvents.sink { [weak self] index in self?.toNewPhones(.pressed(index: index)) },
            model.ranEvents.sink { [weak self] text, ok in self?.toNewPhones(.ran(text: text, ok: ok)) },
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
        listeners.forEach { $0.cancel() }
        listeners = []
        watch = nil
        events = []
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
        UserDefaults.standard.set(allowed, forKey: PhoneServer.allowedKey)
        for (id, phone) in phones where phone.token == token {
            phone.connection.cancel()
            drop(id)
        }
    }

    // MARK: One iPhone

    private func accept(_ connection: NWConnection) {
        let phone = Phone(connection)
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
    }

    private func receive(_ phone: Phone, _ id: ObjectIdentifier) {
        phone.connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] data, _, done, error in
            guard let self, self.phones[id] != nil else { return }
            if let data, !data.isEmpty {
                for message in phone.reader.add(data) { self.handle(message, from: phone) }
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
        connected = phones.values.first(where: \.trusted)?.name
    }

    private func handle(_ message: PhoneLink.Message, from phone: Phone) {
        switch message {
        case let .hello(name, token, version):
            phone.version = version ?? 1
            phone.name = name.isEmpty ? "iPhone" : name
            if let token, allowed[token] != nil {
                welcome(phone, token: token)
            } else {
                send(.waiting, to: phone)
                waitingToAsk.append(phone)
                askNext()
            }
        case let .press(index):
            guard phone.trusted, (0..<StreamDeckProtocol.keyCount).contains(index) else { return }
            model.pressFromPhone(index)
        case let .page(step):
            guard phone.trusted, step == 1 || step == -1 else { return }
            model.stepPage(step)
        case let .profile(id):
            guard phone.trusted else { return }
            model.pin(id.flatMap { UUID(uuidString: $0) })
        default:
            break
        }
    }

    /// Asks him on the Mac, one iPhone at a time.
    private func askNext() {
        guard !asking, let phone = waitingToAsk.first else { return }
        waitingToAsk.removeFirst()
        guard phones[ObjectIdentifier(phone)] != nil else { return askNext() }
        asking = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "“\(phone.name)” wants to use your keys"
            alert.informativeText = "It shows the same keys as your Stream Deck, and this Mac does what you tap there. Allow it only for your own iPhone."
            alert.addButton(withTitle: "Allow")
            alert.addButton(withTitle: "Don’t Allow")
            let yes = alert.runModal() == .alertFirstButtonReturn
            self.asking = false
            if self.phones[ObjectIdentifier(phone)] != nil {
                if yes {
                    let token = UUID().uuidString + UUID().uuidString
                    self.welcome(phone, token: token)
                } else {
                    self.send(.refused, to: phone)
                }
            }
            self.askNext()
        }
    }

    private func welcome(_ phone: Phone, token: String) {
        phone.token = token
        phone.trusted = true
        allowed[token] = phone.name
        UserDefaults.standard.set(allowed, forKey: PhoneServer.allowedKey)
        connected = phone.name
        send(.welcome(token: token, mac: PhoneServer.macName), to: phone)
        sendKeys(to: phone)
    }

    // MARK: Sending

    private func send(_ message: PhoneLink.Message, to phone: Phone) {
        phone.connection.send(content: PhoneLink.frame(message), completion: .contentProcessed { _ in })
    }

    private func sendKeysToAll() {
        for phone in phones.values where phone.trusted { sendKeys(to: phone) }
    }

    private func sendKeys(to phone: Phone) {
        let keys = model.keys
        let list = (0..<StreamDeckProtocol.keyCount).map { index in
            PhoneLink.Key(index: index, title: KeyArt.title(keys[index]), picture: KeyArt.pngForPhone(keys[index]))
        }
        let data = PhoneLink.frame(.keys(place: model.placeLine, keys: list))
        if data != phone.lastSent {
            phone.lastSent = data
            phone.connection.send(content: data, completion: .contentProcessed { _ in })
        }
        guard phone.version >= 2, let position = model.position else { return }
        let numbers = Navigator.pageNumber(at: position, in: model.deck)
        let status = PhoneLink.Status(
            profiles: model.deck.profiles.map { .init(id: $0.id.uuidString, name: $0.name.isEmpty ? "No name" : $0.name) },
            current: position.profile.uuidString, held: model.pinned != nil, page: numbers.page, pages: numbers.pages)
        let frame = PhoneLink.frame(.status(status))
        guard frame != phone.lastStatus else { return }
        phone.lastStatus = frame
        phone.connection.send(content: frame, completion: .contentProcessed { _ in })
    }

    /// Only iPhone apps that know the message get it (the first iPhone app would close the line).
    private func toNewPhones(_ message: PhoneLink.Message) {
        for phone in phones.values where phone.trusted && phone.version >= 2 { send(message, to: phone) }
    }
}
