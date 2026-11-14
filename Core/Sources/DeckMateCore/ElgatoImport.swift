import Foundation

// Reads the Stream Deck profiles of Elgato's own app (the "ProfilesV3" folder) and turns them
// into Deck Mate's model. It only reads; it never changes anything in that folder.
// Odd or unknown data is skipped and written down in `notes`, never a crash.

public enum ElgatoImport {
    /// What one Elgato key turns into.
    private enum Mapped { case action(DeckAction), folder(String), dropProfile, skip(String) }

    public struct Result {
        public var profiles: [DeckProfile]
        public var defaultProfile: UUID?
        public var keyCount: Int
        public var notes: [String]
    }

    public static func read(folder: URL, deviceModel: String = "20GBA9901",
                            skippingProfiles: [String] = ["Zoom", "Final Cut Pro", "FCP Pro SFX Labelled MK 2023"]) -> Result {
        let fm = FileManager.default
        let skipNames = Set(skippingProfiles.map { $0.lowercased() })
        var notes: [String] = []
        var skippedKinds: [String: Int] = [:]   // key kind -> how many keys were left out
        var droppedProfileLinks = 0

        // Which profile folders to bring over, with the id each gets (first pass, so links resolve).
        struct Source { var dir: URL; var manifest: [String: Any]; var name: String; var id: UUID }
        var sources: [Source] = []
        var idByElgatoId: [String: UUID] = [:]
        let dirs = ((try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? [])
            .filter { $0.pathExtension == "sdProfile" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        for dir in dirs {
            guard let m = json(dir.appendingPathComponent("manifest.json")) else {
                notes.append("Could not read the profile folder \(dir.lastPathComponent); it was skipped.")
                continue
            }
            let model = ((m["Device"] as? [String: Any])?["Model"] as? String) ?? ""
            guard model == deviceModel else { continue }
            let name = (m["Name"] as? String) ?? ""
            if skipNames.contains(name.lowercased()) { continue }
            let elgatoId = dir.deletingPathExtension().lastPathComponent.lowercased()
            let id = UUID(uuidString: elgatoId) ?? UUID()
            idByElgatoId[elgatoId] = id
            sources.append(Source(dir: dir, manifest: m, name: name, id: id))
        }
        sources.sort { ($0.name.lowercased(), $0.dir.lastPathComponent) < ($1.name.lowercased(), $1.dir.lastPathComponent) }

        var profiles: [DeckProfile] = []
        var keyCount = 0

        for src in sources {
            var profile = DeckProfile(id: src.id, name: src.name)

            // The app of a smart profile.
            if let app = src.manifest["AppIdentifier"] as? String, !app.isEmpty {
                if let bundleId = bundleIdentifier(of: app) {
                    profile.apps = [bundleId]
                } else {
                    notes.append("The app of the profile \"\(src.name)\" (\(app)) is not on this Mac, so it has no app to follow.")
                }
            }

            let pagesInfo = src.manifest["Pages"] as? [String: Any]
            let topIds = (pagesInfo?["Pages"] as? [String]) ?? []
            var topPages: [DeckPage] = []
            var done = Set<String>()   // page folders already turned into pages

            func pageManifest(_ elgatoId: String) -> [String: Any]? {
                // The folder names are upper case on disk, the manifests list them lower case.
                let profilesDir = src.dir.appendingPathComponent("Profiles")
                for candidate in [elgatoId, elgatoId.uppercased(), elgatoId.lowercased()] {
                    if let m = json(profilesDir.appendingPathComponent(candidate).appendingPathComponent("manifest.json")) { return m }
                }
                return nil
            }

            // Builds one page (and, below it, the pages of its folders).
            func build(_ elgatoId: String, name: String, parent: UUID?, into out: inout [DeckPage]) -> UUID? {
                let key = elgatoId.lowercased()
                guard !done.contains(key) else { return UUID(uuidString: key) }
                guard let pm = pageManifest(elgatoId) else {
                    notes.append("A page of the profile \"\(src.name)\" could not be read; it was skipped.")
                    return nil
                }
                done.insert(key)
                let pageId = UUID(uuidString: key) ?? UUID()
                var page = DeckPage(id: pageId, name: name, parent: parent)
                var children: [DeckPage] = []
                for controller in (pm["Controllers"] as? [[String: Any]]) ?? [] {
                    if let type = controller["Type"] as? String, type != "Keypad" { continue }
                    let actions = (controller["Actions"] as? [String: Any]) ?? [:]
                    for (position, raw) in actions {
                        let parts = position.split(separator: ",").compactMap { Int($0) }
                        guard parts.count == 2, (0..<5).contains(parts[0]), (0..<3).contains(parts[1]),
                              let a = raw as? [String: Any] else {
                            notes.append("A key at an odd place (\(position)) in \"\(src.name)\" was skipped.")
                            continue
                        }
                        let index = parts[1] * 5 + parts[0]
                        let title = keyTitle(a)
                        let result = map(a)
                        switch result {
                        case .action(let action):
                            page.keys[index] = DeckKey(id: UUID(uuidString: (a["ActionID"] as? String) ?? "") ?? UUID(),
                                                       title: title, action: action)
                        case .folder(let childId):
                            let childName = title.isEmpty ? "Folder" : title
                            if let childUUID = build(childId, name: childName, parent: pageId, into: &children) {
                                page.keys[index] = DeckKey(id: UUID(uuidString: (a["ActionID"] as? String) ?? "") ?? UUID(),
                                                           title: title,
                                                           action: DeckAction(type: .folder, target: childUUID.uuidString))
                            } else {
                                notes.append("The folder \"\(childName)\" in \"\(src.name)\" could not be read; its key was skipped.")
                            }
                        case .dropProfile:
                            droppedProfileLinks += 1
                        case .skip(let kind):
                            skippedKinds[kind, default: 0] += 1
                        }
                    }
                }
                keyCount += page.keys.count
                out.append(page)
                out.append(contentsOf: children)
                return pageId
            }

            // The mapping of one Elgato action, decided from its action id.
            func map(_ a: [String: Any]) -> Mapped {
                let uuid = (a["UUID"] as? String) ?? ""
                let settings = (a["Settings"] as? [String: Any]) ?? [:]
                var label = (a["Name"] as? String) ?? ((a["Plugin"] as? [String: Any])?["Name"] as? String) ?? uuid
                if uuid.hasPrefix("com.elgato.tutorial.") { label = "Elgato tutorial keys" }
                switch uuid {
                case "com.elgato.streamdeck.system.open":
                    let path = unquote((settings["path"] as? String) ?? "")
                    if path.isEmpty { return .skip("empty:" + label) }
                    return .action(DeckAction(type: path.hasSuffix(".app") ? .app : .link, target: path))
                case "com.elgato.streamdeck.system.website":
                    let url = (settings["path"] as? String) ?? ""
                    return url.isEmpty ? .skip("empty:" + label) : .action(DeckAction(type: .link, target: url))
                case "com.elgato.streamdeck.system.openapp":
                    for k in ["bundle_id", "bundle_path", "source", "exec"] {
                        if let v = settings[k] as? String, !v.isEmpty { return .action(DeckAction(type: .app, target: v)) }
                    }
                    return .skip(label)
                case "com.elgato.streamdeck.system.hotkey":
                    // Several hotkeys can be stored (press, release …); the first one that is set is the shortcut.
                    for h in (settings["Hotkeys"] as? [[String: Any]]) ?? [] {
                        let code = (h["NativeCode"] as? Int) ?? -1
                        if code < 0 { continue }
                        let combo = KeyCombo(keyCode: code,
                                             command: (h["KeyCmd"] as? Bool) ?? false,
                                             control: (h["KeyCtrl"] as? Bool) ?? false,
                                             option: (h["KeyOption"] as? Bool) ?? false,
                                             shift: (h["KeyShift"] as? Bool) ?? false,
                                             keyName: keyName(code))
                        return .action(DeckAction(type: .shortcut, combo: combo))
                    }
                    return .skip("Hotkey without a key")
                case "com.elgato.streamdeck.system.text":
                    let text = (settings["pastedText"] as? String) ?? (settings["text"] as? String) ?? (settings["Text"] as? String) ?? ""
                    return text.isEmpty ? .skip(label) : .action(DeckAction(type: .text, target: text))
                case "com.elgato.streamdeck.profile.openchild":
                    if let child = settings["ProfileUUID"] as? String, !child.isEmpty { return .folder(child) }
                    return .skip(label)
                case "com.elgato.streamdeck.profile.backtoparent":
                    return .action(DeckAction(type: .back))
                case "com.elgato.streamdeck.page.next":
                    return .action(DeckAction(type: .nextPage))
                case "com.elgato.streamdeck.page.previous":
                    return .action(DeckAction(type: .previousPage))
                case "com.elgato.streamdeck.profile.rotate":
                    let target = ((settings["ProfileUUID"] as? String) ?? "").lowercased()
                    if let id = idByElgatoId[target] { return .action(DeckAction(type: .profile, target: id.uuidString)) }
                    return .dropProfile
                case "com.elgato.streamdeck.multiactions.routine":
                    // The first group of steps is the key's routine; a second group is only the other state.
                    var steps: [DeckAction] = []
                    let groups = (a["Actions"] as? [[String: Any]]) ?? []
                    var stepList: [[String: Any]] = []
                    if let first = groups.first {
                        if first["UUID"] != nil { stepList = groups } else { stepList = (first["Actions"] as? [[String: Any]]) ?? [] }
                    }
                    for s in stepList {
                        if case .action(let act) = map(s), act.type != .folder { steps.append(act) }
                    }
                    return steps.isEmpty ? .skip(label) : .action(DeckAction(type: .multi, steps: steps))
                default:
                    if uuid.lowercased().contains("multimedia") || uuid.lowercased().contains("mediakey") {
                        let words = settings.values.compactMap { $0 as? String }.joined(separator: " ").lowercased()
                        let media: MediaKey?
                        if words.contains("play") { media = .playPause }
                        else if words.contains("next") { media = .next }
                        else if words.contains("prev") { media = .previous }
                        else if words.contains("up") { media = .volumeUp }
                        else if words.contains("down") { media = .volumeDown }
                        else if words.contains("mute") { media = .mute }
                        else { media = nil }
                        if let media { return .action(DeckAction(type: .media, target: media.rawValue)) }
                    }
                    return .skip(label)
                }
            }

            for (n, elgatoId) in topIds.enumerated() {
                let stored = ((pageManifest(elgatoId)?["Name"]) as? String) ?? ""
                _ = build(elgatoId, name: stored.isEmpty ? "Page \(n + 1)" : stored, parent: nil, into: &topPages)
            }
            // Folder pages come after the real pages, so the top pages keep Elgato's order.
            let tops = topPages.filter { $0.parent == nil }
            let others = topPages.filter { $0.parent != nil }
            profile.pages = tops + others
            if profile.pages.isEmpty {
                notes.append("The profile \"\(src.name)\" has no pages; it was brought over with one empty page.")
                profile.pages = [DeckPage(name: "Page 1")]
            }
            profiles.append(profile)
        }

        for (kind, n) in skippedKinds.sorted(by: { $0.key < $1.key }) {
            if kind.hasPrefix("empty:") {
                notes.append("Skipped \(n) \(kind.dropFirst(6)) key\(n == 1 ? "" : "s") that had nothing set.")
            } else {
                notes.append("Skipped \(n) key\(n == 1 ? "" : "s") of a kind Deck Mate does not have: \(kind)")
            }
        }
        if droppedProfileLinks > 0 {
            notes.append("Skipped \(droppedProfileLinks) \"Switch Profile\" key\(droppedProfileLinks == 1 ? "" : "s") because the profile it pointed to was not brought over.")
        }

        let def = profiles.first(where: { $0.name.lowercased() == "default profile" }) ?? profiles.first
        return Result(profiles: profiles, defaultProfile: def?.id, keyCount: keyCount, notes: notes)
    }

    // MARK: Helpers

    private static func json(_ url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    /// The title of the key's current state: lines joined to one, spaces tidied.
    private static func keyTitle(_ a: [String: Any]) -> String {
        let states = (a["States"] as? [[String: Any]]) ?? []
        let current = (a["State"] as? Int) ?? 0
        let state = states.indices.contains(current) ? states[current] : states.first
        let raw = (state?["Title"] as? String) ?? ""
        let flat = raw.components(separatedBy: .newlines).joined(separator: " ")
        return flat.split(separator: " ", omittingEmptySubsequences: true).joined(separator: " ")
    }

    private static func unquote(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count >= 2, t.hasPrefix("\""), t.hasSuffix("\"") { t = String(t.dropFirst().dropLast()) }
        return t
    }

    /// The bundle identifier of an app given by its path (or already as an identifier); nil when it is not there.
    private static func bundleIdentifier(of app: String) -> String? {
        guard app.hasPrefix("/") else { return app }
        let plist = URL(fileURLWithPath: app).appendingPathComponent("Contents/Info.plist")
        guard let data = try? Data(contentsOf: plist),
              let dict = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: Any],
              let id = dict["CFBundleIdentifier"] as? String else { return nil }
        return id
    }

    /// A readable name for a Mac virtual key code.
    static func keyName(_ code: Int) -> String {
        let names: [Int: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V", 10: "§", 11: "B",
            12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 30: "]", 31: "O", 32: "U", 33: "[",
            34: "I", 35: "P", 36: "Return", 37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",",
            44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space", 50: "`", 51: "Delete", 53: "Esc",
            65: "Pad .", 67: "Pad *", 69: "Pad +", 71: "Clear", 75: "Pad /", 76: "Enter", 78: "Pad -", 81: "Pad =",
            82: "Pad 0", 83: "Pad 1", 84: "Pad 2", 85: "Pad 3", 86: "Pad 4", 87: "Pad 5", 88: "Pad 6",
            89: "Pad 7", 91: "Pad 8", 92: "Pad 9",
            96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9", 103: "F11", 105: "F13", 107: "F14",
            109: "F10", 111: "F12", 113: "F15", 114: "Help", 115: "Home", 116: "Page Up", 117: "Forward Delete",
            118: "F4", 119: "End", 120: "F2", 121: "Page Down", 122: "F1",
            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        return names[code] ?? "Key \(code)"
    }
}
