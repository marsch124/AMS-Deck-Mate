import AppKit
import Combine
import DeckMateCore
import IOKit.ps

/// The Mac at a glance for the iPhone and iPad: battery, the app in front, what is playing, the volume.
/// It only looks while an iPhone that shows these is connected (`isWatching`).
final class MacWatch: ObservableObject {
    @Published private(set) var now = PhoneLink.MacNow()

    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var song = ""
    private var artist = ""
    private var playing = false
    private var app = ""

    /// Spotify and Apple Music both say so, to every app that listens, whenever the song changes or
    /// playing starts or stops. No permission is needed to hear it.
    private static let players = ["com.spotify.client.PlaybackStateChanged", "com.apple.Music.playerInfo"]

    init() {
        let front = NSWorkspace.shared.frontmostApplication
        if front?.bundleIdentifier != AppInfo.bundleID { app = front?.localizedName ?? "" }
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] note in
            let front = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            guard let self, front?.bundleIdentifier != AppInfo.bundleID else { return }
            self.app = front?.localizedName ?? ""
            self.refresh(slow: false)
        })
        for name in MacWatch.players {
            observers.append(DistributedNotificationCenter.default().addObserver(
                forName: Notification.Name(name), object: nil, queue: .main) { [weak self] note in
                guard let self else { return }
                let state = note.userInfo?["Player State"] as? String ?? ""
                if state == "Stopped" {
                    self.playing = false
                } else {
                    self.song = note.userInfo?["Name"] as? String ?? self.song
                    self.artist = note.userInfo?["Artist"] as? String ?? self.artist
                    self.playing = state == "Playing"
                }
                self.refresh(slow: false)
            })
        }
    }

    /// Battery and volume are looked at every 5 seconds, only while an iPhone shows them.
    var isWatching = false {
        didSet {
            guard isWatching != oldValue else { return }
            timer?.invalidate()
            timer = nil
            guard isWatching else { return }
            refresh(slow: true)
            let tick = Timer(timeInterval: 5, repeats: true) { [weak self] _ in self?.refresh(slow: true) }
            RunLoop.main.add(tick, forMode: .common)
            timer = tick
        }
    }

    private func refresh(slow: Bool) {
        var new = now
        new.app = app
        new.song = song
        new.artist = artist
        new.playing = playing
        if slow {
            let power = MacWatch.battery()
            new.battery = power?.percent
            new.charging = power?.charging ?? false
            new.volume = MacWatch.volume()
        }
        if new != now { now = new }
    }

    /// Louder (+1) or quieter (-1), 6 points a step.
    func stepVolume(_ step: Int) {
        guard let level = MacWatch.volume() else { return }
        let new = PhoneLink.MacNow.volume(level, step: step)
        MacWatch.script("set volume output volume \(new)")
        var copy = now
        copy.volume = new
        now = copy
    }

    private static func battery() -> (percent: Int, charging: Bool)? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else { return nil }
        for source in list {
            guard let about = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
                  about[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
                  let level = about[kIOPSCurrentCapacityKey] as? Int,
                  let full = about[kIOPSMaxCapacityKey] as? Int, full > 0 else { continue }
            let charging = about[kIOPSIsChargingKey] as? Bool ?? false
            return (min(100, max(0, Int((Double(level) / Double(full) * 100).rounded()))), charging)
        }
        return nil
    }

    /// The Mac's own sound volume, 0–100; nil when the sound output has none (some screens and boxes).
    private static func volume() -> Int? {
        guard let text = script("output volume of (get volume settings)"), let level = Int(text) else { return nil }
        return level
    }

    @discardableResult
    private static func script(_ source: String) -> String? {
        var error: NSDictionary?
        let answer = NSAppleScript(source: source)?.executeAndReturnError(&error)
        return error == nil ? answer?.stringValue : nil
    }

    deinit {
        timer?.invalidate()
        observers.forEach {
            NSWorkspace.shared.notificationCenter.removeObserver($0)
            DistributedNotificationCenter.default().removeObserver($0)
        }
    }
}
