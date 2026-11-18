import AppKit
import Combine
import DeckMateCore

/// The smart lane of 0.16: the box dims in the evening, page groups with hours, "Often used" keys.
/// Its state lives here (static) so the model's own list of fields stays as it was.
extension AppModel {
    struct SmartState {
        /// The page group the app in front got at the last look (with the hours of that minute).
        var wanted: UUID?
        /// The brightness last sent to the box by the evening rule.
        var brightness: Int?
        var timer: Timer?
        var watchers: [NSObjectProtocol] = []
        var deckWatch: AnyCancellable?
    }
    static var smart = SmartState()

    /// The model the Shortcuts actions reach (set once the real model starts).
    static weak var shared: AppModel?

    /// The brightness the box should have right now: the usual one, or the evening one.
    var boxBrightness: Int { BoxEvening.brightness(for: deck, minute: DayMinutes.of(Date())) }

    /// Called once at the end of the model's start.
    func startSmartLane() {
        guard !isSample else { return }
        AppModel.shared = self
        let minute = DayMinutes.of(Date())
        AppModel.smart.wanted = Navigator.profile(forApp: frontApp, in: deck, now: minute)
        AppModel.smart.brightness = boxBrightness
        // Once a minute, at wake, and when a setting of the evening changes.
        let timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in self?.lookAtTime() }
        RunLoop.main.add(timer, forMode: .common)
        AppModel.smart.timer = timer
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            AppModel.smart.watchers.append(NSWorkspace.shared.notificationCenter.addObserver(
                forName: name, object: nil, queue: .main) { [weak self] _ in
                AppModel.smart.brightness = nil
                self?.lookAtTime()
            })
        }
        // `$deck` tells before the new setup is in, so the new one is what is looked at.
        AppModel.smart.deckWatch = $deck.dropFirst().sink { [weak self] new in self?.dimInEvening(with: new) }
    }

    /// A minute went by, or the Mac woke.
    func lookAtTime() {
        dimInEvening(with: deck)
        let wanted = Navigator.profile(forApp: frontApp, in: deck, now: DayMinutes.of(Date()))
        guard wanted != AppModel.smart.wanted else { return }
        AppModel.smart.wanted = wanted
        // A page group locked by hand stays; so does the choice of "Automatic" being off.
        guard pinned == nil, deck.autoSwitch, let wanted, wanted != position?.profile,
              let start = Navigator.start(in: deck, profile: wanted) else { return }
        show(start)
    }

    /// The box gets the brightness of this minute; only a change is sent.
    private func dimInEvening(with deck: Deck) {
        let level = BoxEvening.brightness(for: deck, minute: DayMinutes.of(Date()))
        guard level != AppModel.smart.brightness else { return }
        AppModel.smart.brightness = level
        if device.isConnected { device.setBrightness(level) }
    }

    /// The page group the app in front is shown with at this minute (for the app-change look).
    func noteHours(for app: String?) {
        AppModel.smart.wanted = Navigator.profile(forApp: app, in: deck, now: DayMinutes.of(Date()))
    }

    // MARK: Often used

    /// The key an "Often used" key stands for now, as it shows.
    func oftenShown(_ key: DeckKey, live now: LiveKeys) -> DeckKey {
        guard key.action.type == .often else { return key.resolving(now) }
        let real = OftenKeys.key(number: key.action.target, in: deck, use: use, now: sampleDate)
        return OftenKeys.showing(key, stands: real?.resolving(now))
    }

    /// An "Often used" action turns into the action of the key it stands for (none yet = nothing to do).
    func oftenAction(_ action: DeckAction) -> DeckAction {
        guard action.type == .often else { return action }
        return OftenKeys.key(number: action.target, in: deck, use: use, now: sampleDate)?.action ?? action
    }

    private var sampleDate: Date { sampleNow ?? Date() }

    // MARK: Pressing from Shortcuts

    /// Why a Shortcuts action cannot run, in plain words; nil = it may.
    static var outsideProblem: String? {
        Outside.isOn ? nil : "Pressing keys from outside is switched off. Switch it on in AMS Deck Mate: Settings › Raycast and links › “Keys can be pressed from Raycast and by link”."
    }

    /// The same careful path as a link: find the key, press it, ask first before quitting all apps,
    /// emptying the bin or ejecting; a key that switches the page group moves the Mac's keys.
    @discardableResult
    func pressFromShortcuts(keyID: String) -> Bool {
        guard let found = DeckLinks.find(keyID, in: deck, first: position?.profile, name: Outside.name) else { return false }
        let outcome = act(found.index, at: found.position, careful: true)
        if found.key.action.type == .profile { show(outcome.position) }
        return true
    }
}
