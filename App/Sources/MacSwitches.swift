import AppKit
import CoreAudio
import DeckMateCore

/// What the switch keys and the microphone light read from the Mac, and what they change on it.
enum MacSwitches {
    /// The Mac shows its dark look right now.
    static var isDark: Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    private static let scripts = DispatchQueue(label: "mac switches")

    /// Dark mode on or off. The first time, the Mac asks whether Deck Mate may control "System Events";
    /// the question must not hold up the keys, so this runs beside the main work.
    static func setDark(_ on: Bool) {
        scripts.async {
            var error: NSDictionary?
            NSAppleScript(source: "tell application \"System Events\" to tell appearance preferences to set dark mode to \(on)")?
                .executeAndReturnError(&error)
            if let error { BoxLog.note("dark mode switch: \(error[NSAppleScript.errorMessage] ?? "could not be done")") }
        }
    }

    private static func device(_ selector: AudioObjectPropertySelector) -> AudioDeviceID? {
        var id = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id) == noErr,
              id != 0 else { return nil }
        return id
    }

    private static func flag(_ device: AudioDeviceID, _ selector: AudioObjectPropertySelector,
                             _ scope: AudioObjectPropertyScope) -> Bool? {
        var value: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        var address = AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
        guard AudioObjectHasProperty(device, &address),
              AudioObjectGetPropertyData(device, &address, 0, nil, &size, &value) == noErr else { return nil }
        return value != 0
    }

    /// The Mac's sound is muted. A sound output without a mute of its own counts as not muted.
    static var isMuted: Bool {
        guard let output = device(kAudioHardwarePropertyDefaultOutputDevice) else { return false }
        return flag(output, kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput) ?? false
    }

    static func setMuted(_ on: Bool) {
        scripts.async {
            var error: NSDictionary?
            NSAppleScript(source: "set volume output muted \(on)")?.executeAndReturnError(&error)
        }
    }

    /// An app is listening to the Mac's microphone (the one picked as its sound input) right now.
    /// It only looks; it never opens or changes the microphone.
    static var micInUse: Bool {
        guard let input = device(kAudioHardwarePropertyDefaultInputDevice) else { return false }
        return flag(input, kAudioDevicePropertyDeviceIsRunningSomewhere, kAudioObjectPropertyScopeGlobal) ?? false
    }

    /// The sound of a timer that is up: twice, so it is not missed.
    static func timerSound() {
        NSSound(named: "Glass")?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { NSSound(named: "Glass")?.play() }
    }
}

/// The Shortcuts of the Mac's Shortcuts app, through its own small command.
enum AppleShortcuts {
    private static let tool = URL(fileURLWithPath: "/usr/bin/shortcuts")

    /// The names of all Shortcuts, in the order of the Shortcuts app. Asked beside the main work.
    static func names(_ done: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            let pipe = Pipe()
            process.executableURL = tool
            process.arguments = ["list"]
            process.standardOutput = pipe
            process.standardError = Pipe()
            var names: [String] = []
            if (try? process.run()) != nil {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                names = String(decoding: data, as: UTF8.self).split(separator: "\n").map(String.init).filter { !$0.isEmpty }
            }
            DispatchQueue.main.async { done(names) }
        }
    }

    static func run(_ name: String) {
        let wanted = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !wanted.isEmpty else { return }
        let process = Process()
        process.executableURL = tool
        process.arguments = ["run", wanted]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        do { try process.run() } catch { BoxLog.note("Apple Shortcut “\(wanted)” could not be started") }
    }
}

/// The words of the entries of a "List to pick from" key.
enum PickList {
    static func words(_ entry: DeckAction) -> String {
        let name = entry.name.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { return name }
        switch entry.type {
        case .app:
            let app = KeyArt.appName(entry.target)
            return app.isEmpty ? "Open an app" : app
        case .link:
            let text = entry.target
            if text.hasPrefix("/") || text.hasPrefix("~") { return (text as NSString).lastPathComponent }
            return text.isEmpty ? "Open a link" : text.replacingOccurrences(of: "https://", with: "")
        case .text: return CopiedTexts.line(entry.target)
        case .shortcut: return entry.combo?.label ?? "Keyboard shortcut"
        case .appleShortcut: return entry.target.isEmpty ? "Apple Shortcut" : entry.target
        case .media: return (MediaKey(rawValue: entry.target) ?? .playPause).title
        default: return ActionWords.done([entry], appName: { KeyArt.appName($0) }) ?? entry.type.title
        }
    }
}
