import AppKit
import ApplicationServices
import DeckMateCore

/// Does what a key says on the Mac: opens apps and links, runs Raycast commands, presses shortcuts,
/// types text, controls music.
enum ActionRunner {
    /// Pressing shortcuts, typing and the music keys need the Mac's Accessibility permission.
    static var mayPressKeys: Bool { AXIsProcessTrusted() }

    /// Asks the Mac to show its Accessibility question (once; after that it only opens System Settings).
    static func askToPressKeys() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func needsKeys(_ action: DeckAction) -> Bool {
        switch action.type {
        case .shortcut, .text, .media, .copied, .cover, .desk: return true
        case .multi, .list, .toggle: return action.steps.contains(where: needsKeys)
        default: return false
        }
    }

    static func run(_ actions: [DeckAction]) {
        // A third of a second apart; a "Wait" step pushes everything after it back.
        for step in StepTiming.starts(actions) {
            DispatchQueue.main.asyncAfter(deadline: .now() + step.after) { run(step.action) }
        }
    }

    /// What the keys that change by themselves stand for right now (set by the app at start).
    static var live: () -> LiveKeys = { LiveKeys() }
    /// A timer key was pressed: its minutes (set by the app at start).
    static var timerPressed: ((String) -> Void)?
    /// A switch key was pressed (set by the app at start).
    static var switchPressed: ((DeckAction) -> Void)?
    /// Shows the entries of a "List to pick from" key at the mouse pointer (set by the app at start).
    static var showPickList: ((DeckAction) -> Void)?

    /// A glance key or a desk key was pressed (set by the app at start).
    static var glancePressed: ((DeckAction) -> Void)?

    /// A weather key was held down: ask for its town (the key's id; set by the app at start).
    static var townAsked: ((String) -> Void)?

    /// The apps used last, newest first (the app in front first); kept up to date by AppModel.
    static var recentApps: [String] = []

    /// The texts copied last, newest first (the current one first); kept up to date by AppModel.
    static var copiedTexts: [String] = []

    /// Shows the list of earlier copied texts at the mouse pointer (set by the app at start).
    static var showCopiedList: (([String]) -> Void)?

    /// The text becomes the copied text again and is pasted where the cursor is.
    static func paste(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            press(KeyCombo(keyCode: 9, command: true, keyName: "V"))
        }
    }

    static func run(_ action: DeckAction) {
        switch action.type {
        case .copied:
            guard mayPressKeys else { askToPressKeys(); return }
            if action.target == CopiedTexts.list {
                showCopiedList?(CopiedTexts.choices(in: copiedTexts))
            } else if let text = CopiedTexts.text(number: RecentApps.number(action.target), in: copiedTexts) {
                paste(text)
            }
        case .recentFile:
            break       // AppModel turns it into "open this file" before it gets here; none yet = nothing
        case .recent:
            let now = action.resolvingRecent(recentApps)
            if now.type == .app { run(now) }
        case .askAI:
            let copied = NSPasteboard.general.string(forType: .string)
            guard let url = URL(string: RaycastLink.ask(copied, link: action.target)) else { return }
            NSWorkspace.shared.open(url)
        case .app:
            guard let url = KeyArt.appURL(action.target) else { return }
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        case .link:
            guard let url = linkURL(action.target) else { return }
            NSWorkspace.shared.open(url)
        case .raycast:
            guard let url = URL(string: RaycastLink.toOpen(action.target, quiet: action.quiet)) else { return }
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = !action.quiet
            NSWorkspace.shared.open(url, configuration: configuration)
        case .shortcut:
            guard let combo = action.combo else { return }
            guard mayPressKeys else { askToPressKeys(); return }
            press(combo)
        case .text:
            guard mayPressKeys else { askToPressKeys(); return }
            type(action.target)
        case .media:
            guard mayPressKeys else { askToPressKeys(); return }
            pressMedia(MediaKey(rawValue: action.target) ?? .playPause)
        case .timer:
            timerPressed?(action.target)
        case .toggle:
            switchPressed?(action)
        case .appleShortcut:
            AppleShortcuts.run(action.target)
        case .list:
            showPickList?(action)
        case .running:
            let now = action.resolving(live())
            if now.type == .app { run(now) }
        case .nextEvent, .weather, .dueToday, .desk, .macNow, .worldClock, .sunTimes, .freeUntil:
            glancePressed?(action)
        case .weatherTown:
            townAsked?(action.target)
        case .cover:
            guard mayPressKeys else { askToPressKeys(); return }
            pressMedia(.playPause)
        case .bodyBattery, .garmin:
            if let url = URL(string: BatteryKeys.board) { NSWorkspace.shared.open(url) }
        case .none, .folder, .back, .nextPage, .previousPage, .profile, .multi, .micLight, .wait:
            break       // moving around is the Navigator's work; a light only shows; a wait only waits
        }
    }

    /// A web address, or a file or folder on this Mac ("/…" or "~/…").
    static func linkURL(_ target: String) -> URL? {
        let text = target.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        if text.hasPrefix("/") || text.hasPrefix("~") {
            return URL(fileURLWithPath: (text as NSString).expandingTildeInPath)
        }
        if text.contains("://") || text.hasPrefix("mailto:") { return URL(string: text) }
        return URL(string: "https://" + text)
    }

    private static func press(_ combo: KeyCombo) {
        var flags: CGEventFlags = []
        if combo.command { flags.insert(.maskCommand) }
        if combo.control { flags.insert(.maskControl) }
        if combo.option { flags.insert(.maskAlternate) }
        if combo.shift { flags.insert(.maskShift) }
        let source = CGEventSource(stateID: .hidSystemState)
        for isDown in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(combo.keyCode), keyDown: isDown) else { continue }
            event.flags = flags
            event.post(tap: .cghidEventTap)
        }
    }

    private static func type(_ text: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        let units = Array(text.utf16)
        var start = 0
        while start < units.count {
            let chunk = Array(units[start..<min(start + 16, units.count)])
            for isDown in [true, false] {
                guard let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: isDown) else { continue }
                event.flags = []
                event.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: chunk)
                event.post(tap: .cghidEventTap)
            }
            start += chunk.count
        }
    }

    /// The music and sound keys of an Apple keyboard.
    private static func pressMedia(_ key: MediaKey) {
        let code: Int
        switch key {
        case .volumeUp: code = 0
        case .volumeDown: code = 1
        case .mute: code = 7
        case .playPause: code = 16
        case .next: code = 17
        case .previous: code = 18
        }
        for isDown in [true, false] {
            let flags = NSEvent.ModifierFlags(rawValue: isDown ? 0xA00 : 0xB00)
            let data = (code << 16) | ((isDown ? 0xA : 0xB) << 8)
            let event = NSEvent.otherEvent(with: .systemDefined, location: .zero, modifierFlags: flags, timestamp: 0,
                                           windowNumber: 0, context: nil, subtype: 8, data1: data, data2: -1)
            event?.cgEvent?.post(tap: .cghidEventTap)
        }
    }
}
