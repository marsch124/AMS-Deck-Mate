import AppKit
import DeckMateCore
import SwiftUI
import UniformTypeIdentifiers

extension ActionType {
    /// What a key does, in the words of the "What it does" list.
    var title: String {
        switch self {
        case .none: return "Nothing"
        case .app: return "Open an app"
        case .link: return "Open a link or a file"
        case .raycast: return "Raycast"
        case .shortcut: return "Keyboard shortcut"
        case .text: return "Type text"
        case .media: return "Music and sound"
        case .folder: return "Folder of keys"
        case .back: return "Back"
        case .nextPage: return "Next page"
        case .previousPage: return "Previous page"
        case .profile: return "Switch page group"
        case .multi: return "Several things in a row"
        case .recent: return "Recent app"
        case .askAI: return "Ask AI (copied text)"
        case .copied: return "Last copied text"
        case .recentFile: return "Recent file"
        case .timer: return "Timer"
        case .toggle: return "Switch (on or off)"
        case .appleShortcut: return "Run an Apple Shortcut"
        case .list: return "List to pick from"
        case .running: return "Open app"
        case .micLight: return "Microphone light"
        case .wait: return "Wait"
        }
    }

    static let forKeys: [ActionType] = [.app, .running, .recent, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut, .text, .copied,
                                        .media, .timer, .toggle, .micLight, .list, .multi,
                                        .folder, .back, .nextPage, .previousPage, .profile, .none]
    /// A long press can do anything a key does, except open a new folder or only show something.
    static let forLongPress: [ActionType] = [.none, .app, .running, .recent, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut,
                                             .text, .copied, .media, .timer, .toggle, .list, .multi,
                                             .back, .nextPage, .previousPage, .profile]
    static let forSteps: [ActionType] = [.app, .recent, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut, .text, .copied, .media,
                                         .timer, .toggle, .wait]
    /// What an entry of a list to pick from, or one side of a switch of his own, can do.
    static let forEntries: [ActionType] = [.app, .link, .raycast, .shortcut, .appleShortcut, .text, .media]
}

extension KeyCombo {
    /// The shortcut he just pressed.
    init(event: NSEvent) {
        let flags = event.modifierFlags
        self.init(keyCode: Int(event.keyCode), command: flags.contains(.command), control: flags.contains(.control),
                  option: flags.contains(.option), shift: flags.contains(.shift),
                  keyName: KeyCombo.name(keyCode: Int(event.keyCode), characters: event.charactersIgnoringModifiers))
    }

    static func name(keyCode: Int, characters: String?) -> String {
        let named: [Int: String] = [49: "Space", 36: "Return", 48: "Tab", 51: "Delete", 53: "Esc", 117: "Forward Delete",
                                    123: "←", 124: "→", 125: "↓", 126: "↑", 115: "Home", 119: "End", 116: "Page Up", 121: "Page Down",
                                    122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7", 100: "F8",
                                    101: "F9", 109: "F10", 103: "F11", 111: "F12"]
        if let name = named[keyCode] { return name }
        let text = (characters ?? "").uppercased()
        return text.isEmpty ? "Key \(keyCode)" : text
    }
}

/// The Mac's own "choose a file" window, for apps and for files.
enum Chooser {
    /// An app, as its bundle identifier (or its path when it has none).
    static func app() -> String? {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.application]
        panel.canChooseDirectories = false
        panel.prompt = "Choose"
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return Bundle(url: url)?.bundleIdentifier ?? url.path
    }

    /// A file or a folder, written with "~" for the home folder.
    static func file() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.prompt = "Choose"
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return (url.path as NSString).abbreviatingWithTildeInPath
    }
}

/// A small grey label above a field.
struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.caption).foregroundStyle(.secondary)
    }
}

/// The fields for what a key does; they change with the kind picked.
struct ActionFields: View {
    @Binding var action: DeckAction
    let deck: Deck
    let profile: DeckProfile
    /// Offers a title for a key that has none yet (the app's name, the command's name).
    var suggestTitle: (String) -> Void = { _ in }
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch action.type {
            case .app: appFields
            case .link: linkFields
            case .raycast: RaycastFields(action: $action, suggestTitle: suggestTitle)
            case .shortcut:
                ShortcutRecorder(combo: $action.combo)
                note("The key presses this shortcut in the app that is in front.")
            case .text:
                TextEditor(text: $action.target)
                    .font(.body)
                    .frame(height: 64)
                    .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary.opacity(0.15)))
                    .accessibilityIdentifier("textToType")
                note("The key types this text where the cursor is. This is also how a Raycast snippet goes on a key.")
            case .media:
                Picker("", selection: $action.target) {
                    ForEach(MediaKey.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
                }
                .labelsHidden()
                .accessibilityIdentifier("mediaPicker")
            case .recent:
                Picker("", selection: $action.target) {
                    Text("1st – the app used just before").tag("1")
                    Text("2nd").tag("2")
                    Text("3rd").tag("3")
                }
                .labelsHidden()
                .accessibilityIdentifier("recentPicker")
                note("Shows and opens an app used before the one in front. Three keys (1st, 2nd, 3rd) = your last three apps. Deck Mate's own windows never count.")
            case .copied:
                Picker("", selection: $action.target) {
                    Text("1st – the text copied just before the current one").tag("1")
                    Text("2nd").tag("2")
                    Text("3rd").tag("3")
                    Text("A list to pick from").tag(CopiedTexts.list)
                }
                .labelsHidden()
                .accessibilityIdentifier("copiedPicker")
                note("Shows the first words of a text you copied earlier and pastes it where the cursor is. Deck Mate remembers your last four copied texts in memory only, never in a file, and skips what a password manager marks as secret. “A list to pick from” shows the earlier texts at the mouse pointer; click one to paste it.")
            case .recentFile:
                Picker("", selection: $action.target) {
                    Text("1st – the file opened last").tag("1")
                    Text("2nd").tag("2")
                    Text("3rd").tag("3")
                }
                .labelsHidden()
                .accessibilityIdentifier("recentFilePicker")
                note("Shows and opens a file you opened lately, by its name. The list is the Mac’s own record of opened files in your home folder, from the last seven days.")
            case .askAI:
                note("Opens Raycast AI Chat with the text you copied last already filled in. Nothing copied = AI Chat just opens.")
            case .timer:
                Picker("", selection: $action.target) {
                    ForEach(TimerKeys.choices, id: \.self) { Text($0 == 1 ? "1 minute" : "\($0) minutes").tag(String($0)) }
                }
                .labelsHidden()
                .accessibilityIdentifier("timerPicker")
                note("A press starts the timer and the key counts down. Another press stops it. When the time is up the Mac plays a sound twice and the key says “Done” for a minute, or until you press it.")
            case .toggle: switchFields
            case .appleShortcut: AppleShortcutFields(action: $action, suggestTitle: suggestTitle)
            case .list:
                StepsEditor(action: $action, deck: deck, profile: profile, isList: true)
            case .running:
                Picker("", selection: $action.target) {
                    ForEach(1...15, id: \.self) { Text($0 == 1 ? "1st of the apps open now" : "\($0).").tag(String($0)) }
                }
                .labelsHidden()
                .accessibilityIdentifier("runningPicker")
                note("Shows one of the apps that are open right now, with its own icon and name, and brings it forward. An app keeps its place while it stays open; a newly opened app goes to the end. “Add an “Open apps” folder” under the keys makes a whole folder of them.")
            case .micLight:
                note("Shows whether an app is listening to the Mac’s microphone right now: red with “Mic in use”, or grey-blue with “Mic free”. It follows within about two seconds. A press does nothing, and the key never changes the microphone.")
            case .wait:
                Picker("", selection: $action.target) {
                    ForEach(StepTiming.waits, id: \.self) { Text($0 == "0.5" ? "Half a second" : $0 == "1" ? "1 second" : "\($0) seconds").tag($0) }
                }
                .labelsHidden()
                note("Waits before the next step, for an app that needs a moment to open.")
            case .folder: folderFields
            case .profile: profileFields
            case .multi: StepsEditor(action: $action, deck: deck, profile: profile)
            case .back: note("Goes back to the page the folder was opened from.")
            case .nextPage: note("Shows the next page of this page group. After the last page comes the first.")
            case .previousPage: note("Shows the page before this one.")
            case .none: note("The key does nothing. A key with no title and no icon stays empty.")
            }
        }
    }

    private func note(_ text: String) -> some View {
        Text(text).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
    }

    /// A switch key: dark mode, mute, or two things of his own in turn.
    private var switchFields: some View {
        let own = SwitchKeys.isOwn(action.target)
        return VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: Binding(get: { own ? "own" : action.target }, set: { new in
                if new == "own" {
                    if !own { action = DeckAction(type: .toggle, target: SwitchKeys.newOwn(), steps: [DeckAction(type: .app), DeckAction(type: .app)]) }
                } else {
                    action = DeckAction(type: .toggle, target: new)
                }
            })) {
                Text("Dark mode").tag(SwitchKeys.dark)
                Text("Mute the sound").tag(SwitchKeys.mute)
                Text("Two things in turn").tag("own")
            }
            .labelsHidden()
            .accessibilityIdentifier("switchPicker")
            if own, action.steps.count >= 2 {
                ForEach(0..<2, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(index == 0 ? "When it goes on" : "When it goes off")
                                .font(.callout.weight(.semibold)).foregroundStyle(Palette.part("keys", scheme))
                            Picker("", selection: Binding(get: { action.steps[index].type },
                                                          set: { if $0 != action.steps[index].type { action.steps[index] = DeckAction.fresh($0) } })) {
                                ForEach(ActionType.forEntries + [.none], id: \.self) { Text($0.title).tag($0) }
                            }
                            .labelsHidden()
                        }
                        ActionFields(action: $action.steps[index], deck: deck, profile: profile)
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                note("The key remembers whether it is on or off, also after a restart.")
            } else if action.target == SwitchKeys.dark {
                note("Switches the Mac between its light and its dark look. The first time, the Mac asks once whether AMS Deck Mate may control “System Events”: choose Allow.")
            } else {
                note("Mutes the Mac’s sound, and brings it back.")
            }
            note("The key shows a small switch mark in its top left corner: filled when on, an outline when off.")
        }
    }

    private var appFields: some View {
        HStack(spacing: 8) {
            Text(action.target.isEmpty ? "No app picked" : KeyArt.appName(action.target))
                .lineLimit(1)
                .foregroundStyle(action.target.isEmpty ? .secondary : .primary)
            Spacer(minLength: 4)
            Button("Choose app…") {
                guard let picked = Chooser.app() else { return }
                action.target = picked
                suggestTitle(KeyArt.appName(picked))
            }
            .buttonStyle(PlainButton())
            .accessibilityIdentifier("chooseApp")
        }
    }

    private var linkFields: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Web address or file", text: $action.target)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("linkField")
            HStack {
                Button("Choose a file or folder…") {
                    if let picked = Chooser.file() { action.target = picked }
                }
                .buttonStyle(PlainButton())
                Spacer()
            }
            note("A web page, a folder or a file. This is also how a Raycast quicklink goes on a key.")
        }
    }

    private var folderFields: some View {
        let folders = profile.pages.filter { $0.parent != nil }
        return VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: $action.target) {
                Text("A new folder").tag("")
                ForEach(folders) { Text($0.name.isEmpty ? "Folder" : $0.name).tag($0.id.uuidString) }
            }
            .labelsHidden()
            .accessibilityIdentifier("folderPicker")
            note("Opens another page of keys. A new folder starts with a Back key and takes the key's title as its name.")
        }
    }

    private var profileFields: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: $action.target) {
                Text("Pick a page group").tag("")
                ForEach(deck.profiles) { Text($0.name).tag($0.id.uuidString) }
            }
            .labelsHidden()
            .accessibilityIdentifier("profilePicker")
            note("Shows another page group. It stays until you go to an app that has a page group of its own.")
        }
    }
}

/// Records a keyboard shortcut: click, then press the keys.
struct ShortcutRecorder: View {
    @Binding var combo: KeyCombo?
    @State private var recording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 8) {
            Button(recording ? "Press the keys now…" : (combo?.label ?? "Record shortcut")) {
                recording ? stop() : start()
            }
            .buttonStyle(PlainButton())
            .accessibilityIdentifier("recordShortcut")
            if recording {
                Text("Esc stops").font(.caption).foregroundStyle(.secondary)
            } else if combo != nil {
                Text("Click to change").font(.caption).foregroundStyle(.secondary)
            }
        }
        .onDisappear(perform: stop)
    }

    private func start() {
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let held = event.modifierFlags.intersection([.command, .control, .option, .shift])
            if event.keyCode == 53, held.isEmpty {
                stop()
                return nil
            }
            combo = KeyCombo(event: event)
            stop()
            return nil
        }
    }

    private func stop() {
        recording = false
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}

/// A Raycast key: pick a command from the list, paste a link, or name a script or an AI command.
struct RaycastFields: View {
    @Binding var action: DeckAction
    var suggestTitle: (String) -> Void
    @State private var picking = false
    @State private var name = ""
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button("Pick a command…") { picking = true }
                    .buttonStyle(MainButton(part: "raycast"))
                    .accessibilityIdentifier("pickRaycast")
                    .popover(isPresented: $picking, arrowEdge: .leading) {
                        RaycastPicker { command in
                            action.target = command.link
                            suggestTitle(command.title)
                            picking = false
                        }
                    }
                Spacer()
            }
            FieldLabel("Raycast link")
            TextField("raycast://…", text: $action.target)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("raycastLink")
            if !action.target.isEmpty, RaycastLink.cleaned(action.target) == nil {
                Text("This is not a Raycast link. It starts with raycast://")
                    .font(.caption)
                    .foregroundStyle(Palette.part("raycast", scheme))
            }
            Text("Any command: in Raycast select it, press ⌘K, choose Copy Deeplink, and paste it here.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            FieldLabel("Or by its name")
            HStack(spacing: 6) {
                TextField("Name of a script or AI command", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("raycastName")
                Menu("Use") {
                    Button("As a script command") { use(RaycastLink.script(named: name)) }
                    Button("As an AI command") { use(RaycastLink.aiCommand(named: name)) }
                }
                .fixedSize()
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Toggle("Run quietly, without bringing Raycast forward", isOn: $action.quiet)
                .toggleStyle(.checkbox)
                .font(.callout)
                .accessibilityIdentifier("raycastQuiet")
        }
    }

    private func use(_ link: String) {
        action.target = link
        suggestTitle(name.trimmingCharacters(in: .whitespaces))
    }
}

/// The list of Raycast commands: Raycast's own first, then every installed extension.
struct RaycastPicker: View {
    var pick: (RaycastCommand) -> Void
    @State private var search = ""
    @State private var commands: [RaycastCommand] = []
    @Environment(\.colorScheme) private var scheme

    private var groups: [(name: String, commands: [RaycastCommand])] {
        let wanted = search.trimmingCharacters(in: .whitespaces).lowercased()
        let hits = wanted.isEmpty ? commands : commands.filter {
            $0.title.lowercased().contains(wanted) || $0.group.lowercased().contains(wanted)
        }
        var order: [String] = []
        var byGroup: [String: [RaycastCommand]] = [:]
        for command in hits {
            if byGroup[command.group] == nil { order.append(command.group) }
            byGroup[command.group, default: []].append(command)
        }
        return order.map { ($0, byGroup[$0] ?? []) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search commands", text: $search)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("raycastSearch")
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(groups, id: \.name) { group in
                        Text(group.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Palette.part("raycast", scheme))
                            .padding(.top, 6)
                        ForEach(group.commands) { command in
                            Button { pick(command) } label: {
                                Text(command.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 2)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if groups.isEmpty {
                        Text("No command with these words.").foregroundStyle(.secondary).padding(.top, 8)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 300, height: 380)
        .onAppear { commands = RaycastCatalog.load() }
    }
}

/// A key that runs a Shortcut of the Mac's Shortcuts app: pick it from the list, or type its name.
struct AppleShortcutFields: View {
    @Binding var action: DeckAction
    var suggestTitle: (String) -> Void
    @State private var names: [String]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                TextField("Name of the Shortcut", text: $action.target)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("appleShortcutName")
                Menu("Pick a Shortcut…") {
                    if let names {
                        if names.isEmpty { Text("No Shortcuts found") }
                        ForEach(names, id: \.self) { name in
                            Button(name) {
                                action.target = name
                                suggestTitle(name)
                            }
                        }
                    } else {
                        Text("Reading your Shortcuts…")
                    }
                }
                .fixedSize()
                .accessibilityIdentifier("pickAppleShortcut")
            }
            Text("Runs this Shortcut from the Shortcuts app. The name must be exactly as it is there.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .onAppear { AppleShortcuts.names { names = $0 } }
    }
}

/// The steps of a "several things in a row" key, or the entries of a "list to pick from" key.
struct StepsEditor: View {
    @Binding var action: DeckAction
    let deck: Deck
    let profile: DeckProfile
    /// The entries of a list: each has a name, and nothing runs by itself.
    var isList = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(action.steps.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("\(index + 1)").font(.callout.weight(.semibold)).foregroundStyle(Palette.part("keys", scheme))
                        Picker("", selection: stepType(index)) {
                            ForEach(isList ? ActionType.forEntries : ActionType.forSteps, id: \.self) { Text($0.title).tag($0) }
                        }
                        .labelsHidden()
                        Spacer(minLength: 0)
                        Button { action.steps.remove(at: index) } label: { Mark(name: "control-close", size: 13) }
                            .buttonStyle(.plain)
                            .help(isList ? "Remove this entry" : "Remove this step")
                    }
                    if isList {
                        TextField("Name in the list (empty = what it does)", text: $action.steps[index].name)
                            .textFieldStyle(.roundedBorder)
                    }
                    ActionFields(action: $action.steps[index], deck: deck, profile: profile)
                }
                .padding(8)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            Button(isList ? "Add an entry" : "Add a step") { action.steps.append(DeckAction(type: .app)) }
                .buttonStyle(PlainButton())
                .accessibilityIdentifier("addStep")
            Text(isList ? "A press shows these at the mouse pointer. Click one to run it; a click elsewhere, a second press or ten seconds put the list away."
                        : "The steps run one after another, a third of a second apart. A “Wait” step gives an app time to open.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func stepType(_ index: Int) -> Binding<ActionType> {
        Binding(get: { action.steps[index].type },
                set: { if $0 != action.steps[index].type { action.steps[index] = DeckAction.fresh($0) } })
    }
}

/// All the hand-drawn icons, with a search box.
struct IconPicker: View {
    var current: String
    var pick: (String) -> Void
    @State private var search = ""

    private var names: [String] {
        let wanted = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !wanted.isEmpty else { return IconStore.names }
        return IconStore.names.filter { $0.lowercased().contains(wanted) || IconStore.title($0).lowercased().contains(wanted) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Search \(IconStore.names.count) icons", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("iconSearch")
                Button("Automatic") { pick("") }
                    .buttonStyle(PlainButton())
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 34), spacing: 4)], spacing: 4) {
                    ForEach(names, id: \.self) { name in
                        Button { pick(name) } label: {
                            Mark(name: name, size: 22)
                                .frame(width: 34, height: 34)
                                .background(Color.primary.opacity(name == current ? 0.18 : 0.05),
                                            in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .help(IconStore.title(name))
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 330, height: 360)
    }
}
