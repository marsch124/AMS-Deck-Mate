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
        }
    }
    @Published private(set) var place = ""
    @Published private(set) var keys: [Int: PhoneLink.Key] = [:]
    /// The profiles and pages (from a Mac at 0.4 or later).
    @Published private(set) var status: PhoneLink.Status?
    /// Keys pressed a moment ago, anywhere (box, Mac screen or here): they light up.
    @Published private(set) var lit: Set<Int> = []
    /// What the last tap did, for a moment; ok false = the Mac could not do it.
    @Published private(set) var note: (text: String, ok: Bool)?
    /// Since when it has been looking for the Mac (for the hotspot hint).
    @Published private(set) var lookingSince: Date? = Date()
    private var noteID = 0
    /// What the Mac app understands: 3 = own keys, long press, favourites, the Mac at a glance, music
    /// (AMS Deck Mate 0.5 or later on the Mac).
    @Published private(set) var macVersion = 0
    /// The favourites row, five places.
    @Published private(set) var favourites: [Int: PhoneLink.Key] = [:]
    /// The Mac at a glance and what is playing.
    @Published private(set) var mac: PhoneLink.MacNow?
    /// Favourites pressed a moment ago.
    @Published private(set) var litFavourites: Set<Int> = []

    /// True with a Mac that knows the new parts.
    var newMac: Bool { macVersion >= 3 }
    /// The navigation picture: every page group with its pages (from a Mac at 0.6 or later).
    @Published private(set) var map: [PhoneLink.MapGroup] = []

    /// A page of the navigation picture was tapped. With "My own keys" its page group is remembered.
    func go(group: String, page: String) {
        if ownOn { ownProfile = group }
        guard case .connected = state, macVersion >= 4, !isSample else { return }
        send(.go(profile: group, page: page))
    }
    var hasFavourites: Bool { favourites.values.contains { $0.picture != nil } }

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

    private var browsers: [NWBrowser] = []
    private var connection: NWConnection?
    private var reader = PhoneLink.Reader()
    private var talkingTo = ""
    private var isSample = false
    private var wake: NSObjectProtocol?

    /// Tokens the Macs gave: Mac's name → token.
    private var tokens: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "macTokens") as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: "macTokens") }
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
            }
            client.lookingSince = nil
            if CommandLine.arguments.contains("-looking") {
                client.state = .looking
                client.lookingSince = .distantPast
            }
        }
        return client
    }

    func start() {
        guard !isSample, browsers.isEmpty else { return }
        // The Mac offers its keys on the shared network and, where it can, directly (like AirDrop).
        for type in [PhoneLink.service, PhoneLink.directService] {
            let parameters = NWParameters()
            parameters.includePeerToPeer = true
            let browser = NWBrowser(for: .bonjour(type: type, domain: nil), using: parameters)
            browser.browseResultsChangedHandler = { [weak self] _, _ in
                MainActor.assumeIsolated { self?.lookAgain() }
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
        state = .looking
        lookAgain()
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
        talkingTo = mac
        state = .connecting(mac)
        line.stateUpdateHandler = { [weak self, weak line] state in
            MainActor.assumeIsolated {
                guard let self, let line, self.connection === line else { return }
                switch state {
                case .ready:
                    self.send(.hello(phone: UIDevice.current.name, token: self.tokens[mac], version: PhoneLink.currentVersion))
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
                    for message in self.reader.add(data) { self.handle(message) }
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
        if case .refused = state { return }
        state = .looking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.lookAgain() }
    }

    private func handle(_ message: PhoneLink.Message) {
        switch message {
        case .waiting:
            state = .waiting(talkingTo)
        case let .welcome(token, _, version):
            tokens[talkingTo] = token
            remembered = talkingTo
            macVersion = version ?? 2
            if !newMac { favourites = [:]; mac = nil }
            if macVersion < 4 { map = [] }
            state = .connected(talkingTo)
            if ownOn { sendOwn() }
        case .refused:
            state = .refused(talkingTo)
            connection?.cancel()
            connection = nil
        case let .keys(place, list):
            self.place = place
            keys = Dictionary(list.map { ($0.index, $0) }, uniquingKeysWith: { $1 })
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
        case .hello, .press, .page, .profile, .own, .hold, .favourite, .music, .go:
            break
        }
    }

    private func send(_ message: PhoneLink.Message) {
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

    func press(_ index: Int) {
        guard case .connected = state, !isSample else { return }
        send(.press(index: index))
    }

    /// A key held for half a second: its long-press action (only a Mac at 0.5 or later knows it).
    func hold(_ index: Int) {
        guard case .connected = state, !isSample else { return }
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
        state = .looking
        lookAgain()
    }

    /// "Forget this Mac": its permission is dropped here; next time it asks again.
    func forget() {
        if let mac = macName { tokens[mac] = nil }
        remembered = nil
        connection?.cancel()
        connection = nil
        keys = [:]
        place = ""
        state = .looking
        lookAgain()
    }
}
