import AppKit
import DeckMateCore
import EventKit
import IOKit.pwr_mgt

/// What the 0.13 keys do on the Mac: lock it, show the desktop, quit all apps, empty the bin, eject
/// all disks, paste as plain text, join a meeting, play a Spotify link, search for the copied text.
enum MacDoer {
    private static let work = DispatchQueue(label: "mac actions")

    static func run(_ action: DeckAction) {
        switch MacDoKeys.what(action.target) {
        case .lock: lock()
        case .desktop: showDesktop()
        case .quitAll: quitAll(action)
        case .emptyBin: emptyBin(asks: MacDoKeys.asks(action))
        case .ejectAll: ejectAll(asks: MacDoKeys.asks(action))
        case .pastePlain: pastePlain()
        }
    }

    // MARK: Questions and notes

    /// A question on the Mac before something that is not taken back with a press. Return does it, Escape cancels.
    static func ask(_ title: String, _ words: String, button: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = words
        alert.addButton(withTitle: button)
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal() == .alertFirstButtonReturn
    }

    /// A short note when a key had nothing to do, or could not do it.
    static func tell(_ title: String, _ words: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = words
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    // MARK: Lock the Mac

    private typealias LockNow = @convention(c) () -> Int32

    /// The Mac's own "lock the screen now", the one behind ⌃⌘Q.
    private static var lockNow: LockNow? {
        guard let handle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY),
              let symbol = dlsym(handle, "SACLockScreenImmediate") else { return nil }
        return unsafeBitCast(symbol, to: LockNow.self)
    }

    /// True when the Mac's own lock can be reached (else the key presses ⌃⌘Q).
    static var lockReady: Bool { lockNow != nil }

    static func lock() {
        if let lockNow {
            _ = lockNow()
            return
        }
        guard ActionRunner.mayPressKeys else { ActionRunner.askToPressKeys(); return }
        ActionRunner.press(KeyCombo(keyCode: 12, command: true, control: true, keyName: "Q"))
    }

    // MARK: Show the desktop

    static let missionControl = URL(fileURLWithPath: "/System/Applications/Mission Control.app/Contents/MacOS/Mission Control")

    /// Moves all windows aside; again brings them back. Mission Control's own little command, told "1".
    static func showDesktop() {
        let process = Process()
        process.executableURL = missionControl
        process.arguments = ["1"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        do { try process.run() } catch { BoxLog.note("show the desktop could not be started") }
    }

    // MARK: Quit all apps

    /// An app as the Mac names it, from a key's target (a bundle identifier, or a path).
    private static func bundleID(_ target: String) -> String {
        target.hasPrefix("/") ? (Bundle(url: URL(fileURLWithPath: target))?.bundleIdentifier ?? target) : target
    }

    /// The apps a "Quit all apps" key would quit right now, and the open ones it leaves.
    static func quitPlan(_ action: DeckAction) -> (going: [NSRunningApplication], stays: [String]) {
        let own = Bundle.main.bundleIdentifier ?? ""
        let apps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
        let spared = QuitKeys.spared(action).map(bundleID)
        let ids = Set(QuitKeys.toQuit(open: apps.compactMap(\.bundleIdentifier), spared: spared, own: own).map { $0.lowercased() })
        let going = apps.filter { ids.contains(($0.bundleIdentifier ?? "").lowercased()) }
        let kept = Set(spared.map { $0.lowercased() })
        let stays = apps.filter { kept.contains(($0.bundleIdentifier ?? "").lowercased()) }.map { $0.localizedName ?? "an app" }
        return (going, stays)
    }

    /// The apps open right now, without the Finder and Deck Mate: what "Stays open" starts with.
    static func openNow() -> [String] {
        let open = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }.compactMap(\.bundleIdentifier)
        return QuitKeys.toQuit(open: open, spared: [], own: Bundle.main.bundleIdentifier ?? "")
    }

    static func quitAll(_ action: DeckAction) {
        let plan = quitPlan(action)
        let names = plan.going.map { $0.localizedName ?? "an app" }
        guard let question = QuitKeys.question(names: names, stays: plan.stays) else {
            if MacDoKeys.asks(action) { tell("No app to quit", "Only the apps that stay open are running.") }
            return
        }
        if MacDoKeys.asks(action), !ask(question.title, question.words, button: "Quit") { return }
        // The polite way: an app with unsaved work asks him first.
        plan.going.forEach { $0.terminate() }
    }

    // MARK: Empty the bin

    private static func finder(_ lines: String) -> (result: NSAppleEventDescriptor?, error: Int?) {
        var error: NSDictionary?
        let result = NSAppleScript(source: "tell application \"Finder\"\n\(lines)\nend tell")?.executeAndReturnError(&error)
        return (result, error.map { ($0[NSAppleScript.errorNumber] as? Int) ?? -1 })
    }

    /// The bin is the Finder's: it counts and empties it. The first time, the Mac asks once whether
    /// Deck Mate may control the Finder.
    static func emptyBin(asks: Bool) {
        work.async {
            let look = finder("return {count of items of trash, warns before emptying of trash}")
            let count = Int(look.result?.atIndex(1)?.int32Value ?? 0)
            let warns = look.result?.atIndex(2)?.booleanValue ?? false
            DispatchQueue.main.async {
                if look.error != nil {
                    tell("The bin could not be looked at", "The Mac has not allowed AMS Deck Mate to control the Finder. Allow it in System Settings › Privacy & Security › Automation.")
                    return
                }
                guard let question = BinKeys.question(count: count) else {
                    if asks { tell("The bin is empty", "There is nothing to throw away.") }
                    return
                }
                if asks, !ask(question.title, question.words, button: "Empty") { return }
                work.async {
                    // The Finder comes forward only when it will ask its own question, so that one is seen.
                    let done = finder((warns ? "activate\n" : "") + "empty trash")
                    // -128 = he said no to the Finder's question; -1712 = the question stood there too long.
                    if let error = done.error, error != -128, error != -1712 { BoxLog.note("empty the bin: error \(error)") }
                }
            }
        }
    }

    // MARK: Eject all disks

    /// The disks an "Eject all disks" key would eject right now.
    static func disksToEject() -> [EjectKeys.Volume] {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsInternalKey, .volumeIsEjectableKey, .volumeIsLocalKey]
        let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes]) ?? []
        return EjectKeys.toEject(urls.map { url in
            let values = try? url.resourceValues(forKeys: Set(keys))
            return EjectKeys.Volume(name: values?.volumeName ?? url.lastPathComponent, path: url.path,
                                    isInternal: values?.volumeIsInternal ?? true,
                                    isEjectable: values?.volumeIsEjectable ?? false,
                                    isLocal: values?.volumeIsLocal ?? true)
        })
    }

    static func ejectAll(asks: Bool) {
        let disks = disksToEject()
        guard let question = EjectKeys.question(names: disks.map(\.name)) else {
            if asks { tell("No disk to eject", "No disk, card or stick is plugged in.") }
            return
        }
        if asks, !ask(question.title, question.words, button: "Eject") { return }
        work.async {
            var stayed: [String] = []
            for disk in disks {
                do { try NSWorkspace.shared.unmountAndEjectDevice(at: URL(fileURLWithPath: disk.path)) } catch { stayed.append(disk.name) }
            }
            guard let words = EjectKeys.stayed(stayed) else { return }
            DispatchQueue.main.async { tell(stayed.count == 1 ? "One disk is still there" : "\(stayed.count) disks are still there", words) }
        }
    }

    // MARK: Paste as plain text

    static func pastePlain() {
        guard ActionRunner.mayPressKeys else { ActionRunner.askToPressKeys(); return }
        guard let text = NSPasteboard.general.string(forType: .string), !text.isEmpty else { return }
        ActionRunner.paste(text)
    }

    // MARK: Join the meeting

    private static var store = EKEventStore()
    /// The calendar was just allowed from here: the glance keys read it again (set by the app at start).
    static var calendarAllowed: (() -> Void)?

    /// The events a "Join the meeting" key looks at; all-day events are left out.
    static func meetings(now: Date, _ done: @escaping ([MeetingKeys.Event]) -> Void) {
        let store = store
        work.async {
            let found = store.events(matching: store.predicateForEvents(withStart: now.addingTimeInterval(-86_400),
                                                                        end: now.addingTimeInterval(MeetingKeys.ahead), calendars: nil))
                .filter { !$0.isAllDay }
                .map { MeetingKeys.Event(title: $0.title ?? "", start: $0.startDate, end: $0.endDate,
                                         texts: [$0.url?.absoluteString ?? "", $0.location ?? "", $0.notes ?? ""]) }
            DispatchQueue.main.async { done(found) }
        }
    }

    static func joinMeeting() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            store.requestFullAccessToEvents { allowed, _ in
                DispatchQueue.main.async {
                    store = EKEventStore()
                    calendarAllowed?()
                    if allowed { joinMeeting() }
                }
            }
        case .fullAccess:
            let now = Date()
            meetings(now: now) { events in
                if let pick = MeetingKeys.pick(events, now: now), let url = URL(string: pick.link) {
                    NSWorkspace.shared.open(url)
                } else {
                    tell("No meeting link found", "None of your events of the next 24 hours has a video link in its link, place or notes.")
                }
            }
        default:
            tell("The calendar is not allowed", "Allow AMS Deck Mate in System Settings › Privacy & Security › Calendars, then press the key again.")
        }
    }

    // MARK: Spotify playlist

    static let spotify = "com.spotify.client"

    /// Tells Spotify to play the link. The first time, the Mac asks once whether Deck Mate may control Spotify.
    static func play(_ target: String) {
        guard let uri = PlaylistKeys.uri(target) else { return }
        guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: spotify) != nil else {
            tell("Spotify is not on this Mac", "The key plays its link in the Spotify app.")
            return
        }
        work.async {
            var error: NSDictionary?
            // The link holds only letters, numbers and colons (see `PlaylistKeys.uri`).
            NSAppleScript(source: "tell application id \"\(spotify)\" to play track \"\(uri)\"")?.executeAndReturnError(&error)
            guard error != nil, let url = URL(string: uri) else { return }
            // Spotify would not be told (not allowed, or still starting): at least open the link in it.
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }

    // MARK: Search for the copied text

    static func search(_ target: String) {
        guard let address = SearchKeys.address(SearchKeys.engine(target), text: NSPasteboard.general.string(forType: .string)),
              let url = URL(string: address) else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: A check that does nothing

    /// For checks ("--actions"): what the 0.13 keys would do right now, in words. Nothing is locked,
    /// quit, emptied, ejected, opened or played, and the Mac is asked nothing.
    static func dryRun(_ done: @escaping (String) -> Void) {
        var lines: [String] = []
        lines.append("Lock the Mac: " + (lockReady ? "the Mac's own lock is found" : "not found, would press ⌃⌘Q"))
        lines.append("Show the desktop: " + (FileManager.default.isExecutableFile(atPath: missionControl.path) ? "Mission Control's command is there" : "Mission Control's command is MISSING"))
        let plan = quitPlan(DeckAction(type: .macDo, target: MacDo.quitAll.rawValue))
        lines.append("Quit all apps: would quit \(plan.going.count): " + Listing.words(plan.going.map { $0.localizedName ?? "?" }, limit: 30))
        let disks = disksToEject()
        lines.append("Eject all disks: " + (disks.isEmpty ? "no disk to eject" : "would eject " + Listing.words(disks.map(\.name), limit: 30)))
        KeepAwake.set(true)
        let pmset = Process()
        let pipe = Pipe()
        pmset.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        pmset.arguments = ["-g", "assertions"]
        pmset.standardOutput = pipe
        try? pmset.run()
        let said = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        pmset.waitUntilExit()
        lines.append("Keep the Mac awake: " + (said.contains(KeepAwake.name) ? "the Mac lists it while on" : "NOT listed by the Mac"))
        KeepAwake.set(false)
        lines.append("Search: " + (SearchKeys.address(.google, text: "deck mate & more") ?? "no address"))
        lines.append("Spotify: " + (NSWorkspace.shared.urlForApplication(withBundleIdentifier: spotify) != nil ? "is on this Mac" : "is not on this Mac"))
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            let now = Date()
            meetings(now: now) { events in
                let pick = MeetingKeys.pick(events, now: now)
                // Only whether there is one, never its name or link.
                lines.append("Join the meeting: \(events.count) events with a time in 24 hours, " + (pick == nil ? "none with a video link" : "one with a video link found"))
                done(lines.joined(separator: "\n"))
            }
        case .notDetermined:
            lines.append("Join the meeting: the calendar was not asked for yet")
            done(lines.joined(separator: "\n"))
        default:
            lines.append("Join the meeting: the calendar is not allowed")
            done(lines.joined(separator: "\n"))
        }
    }
}

/// The "Keep the Mac awake" switch: while it is on, the Mac and its screen do not go to sleep by
/// themselves. It ends with the app.
enum KeepAwake {
    static let name = "AMS Deck Mate: Keep the Mac awake"
    private static var held: IOPMAssertionID = 0

    static var isOn: Bool { held != 0 }

    static func set(_ on: Bool) {
        if on, held == 0 {
            var new: IOPMAssertionID = 0
            let made = IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                                                   IOPMAssertionLevel(kIOPMAssertionLevelOn), name as CFString, &new)
            if made == kIOReturnSuccess { held = new } else { BoxLog.note("keep awake could not be switched on") }
        } else if !on, held != 0 {
            IOPMAssertionRelease(held)
            held = 0
        }
    }
}
