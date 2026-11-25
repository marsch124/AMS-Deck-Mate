import AppKit
import DeckMateCore

/// Keys pressed from outside by a link ("amsdeckmate://…"), and the small commands Raycast lists for
/// them. Every link carries this Mac's own pass, so a web page or another program cannot press keys.
enum Outside {
    static let offKey = "linksOff"
    static var isOn: Bool { !UserDefaults.standard.bool(forKey: offKey) }

    /// This Mac's own pass: a random word made once.
    static var pass: String {
        if let known = UserDefaults.standard.string(forKey: "linkPass"), known.count >= 32 { return known }
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let made = bytes.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(made, forKey: "linkPass")
        return made
    }

    /// The folder Raycast is shown once: beside the keys file.
    static func folder(_ store: Store) -> URL { store.folder.appendingPathComponent("Raycast", isDirectory: true) }

    /// A key's words for Raycast's list: its own, the app's name, or what it does.
    static func name(_ key: DeckKey) -> String {
        let own = key.shownTitle(appName: { KeyArt.appURL($0) == nil ? "" : KeyArt.appName($0) })
        if !own.isEmpty { return own }
        switch key.action.type {
        case .macDo: return MacDoKeys.what(key.action.target).title
        case .media: return (MediaKey(rawValue: key.action.target) ?? .playPause).title
        case .garmin: return GarminKeys.number(key.action.target).title
        case .macNow: return MacNowKeys.number(key.action.target).title
        case .timer: return "Timer, \(TimerKeys.minutes(key.action.target)) min"
        case .toggle where ChipKey.isChip(key.action.target): return ChipKey.longWords
        case .toggle where FanKeys.isFan(key.action.target):
            return "Fans: \(FanKeys.longWords(FanKeys.choice(of: key.action.target) ?? ""))"
        default: return key.action.type.title
        }
    }

    private static var written: Deck?

    /// Writes the commands again when the keys changed: one small file a key, old ones removed.
    /// Switched off = the folder goes. Returns how many keys are listed.
    @discardableResult
    static func write(_ deck: Deck, store: Store) -> Int {
        let files = FileManager.default
        let folder = folder(store)
        guard isOn else {
            written = nil
            try? files.removeItem(at: folder)
            return 0
        }
        let wanted = DeckLinks.scripts(for: deck, pass: pass, name: name)
        guard written != deck || !files.fileExists(atPath: folder.path) else { return wanted.count }
        written = deck
        try? files.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        for old in (try? files.contentsOfDirectory(atPath: folder.path)) ?? []
        where old.hasPrefix("deck-") && old.hasSuffix(".sh") && wanted[old] == nil {
            try? files.removeItem(at: folder.appendingPathComponent(old))
        }
        for (name, text) in wanted {
            let url = folder.appendingPathComponent(name)
            if (try? String(contentsOf: url, encoding: .utf8)) == text { continue }
            try? text.write(to: url, atomically: true, encoding: .utf8)
            try? files.setAttributes([.posixPermissions: 0o700], ofItemAtPath: url.path)
        }
        let icon = folder.appendingPathComponent("deck-mate.png")
        if !files.fileExists(atPath: icon.path), let tiff = NSApp?.applicationIconImage.tiffRepresentation,
           let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) {
            try? png.write(to: icon)
        }
        return wanted.count
    }
}

extension AppModel {
    /// A link was opened ("amsdeckmate://press?key=…&pass=…"). True when it asks for the keys on
    /// screen to show or hide (the windows are not the model's).
    func open(link url: URL) -> Bool {
        guard Outside.isOn, let command = DeckLinks.command(from: url, pass: Outside.pass) else {
            BoxLog.note("a link was not followed (pressing keys by link is off, or the link has no pass)")
            return false
        }
        switch command {
        case let .press(wanted, long, twice):
            guard let found = DeckLinks.find(wanted, in: deck, first: position?.profile, name: Outside.name) else {
                NSSound.beep()
                return false
            }
            let outcome = act(found.index, at: found.position, long: long, careful: true, twice: twice)
            // A key that changes the page group does so on the Mac's own keys.
            if found.key.action(long: long, twice: twice).type == .profile { show(outcome.position) }
        case let .show(wanted):
            if let group = DeckLinks.group(wanted, in: deck) { visit(group.id) }
        case .toggleKeys:
            return true
        }
        return false
    }

    /// Writes Raycast's commands again (after the keys changed, or the switch in Settings).
    @discardableResult
    func writeOutside() -> Int {
        guard !isSample, store.cloud != nil else { return 0 }
        return Outside.write(deck, store: store)
    }
}
