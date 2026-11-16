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
        case let .welcome(token, _):
            tokens[talkingTo] = token
            remembered = talkingTo
            state = .connected(talkingTo)
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
        case .hello, .press, .page, .profile:
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
    func pickProfile(_ id: String?) {
        guard case .connected = state, !isSample else { return }
        send(.profile(id: id))
    }

    func press(_ index: Int) {
        guard case .connected = state, !isSample else { return }
        send(.press(index: index))
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
