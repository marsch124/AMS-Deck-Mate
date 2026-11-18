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
        case .nextEvent: return "Next event"
        case .weather: return "Weather"
        case .dueToday: return "Due today (PARAGON)"
        case .cover: return "Album cover (Spotify)"
        case .bodyBattery: return "Body Battery"
        case .desk: return "Desk (windows in place)"
        case .weatherTown: return "Change the town"
        case .garmin: return "Garmin number"
        case .macNow: return "Mac at a glance"
        case .worldClock: return "World clock"
        case .sunTimes: return "Sunrise and sunset"
        case .freeUntil: return "Free until (calendar)"
        case .macDo: return "On the Mac"
        case .joinMeeting: return "Join the meeting"
        case .playlist: return "Spotify playlist"
        case .searchCopied: return "Search for the copied text"
        case .counter: return "Counter"
        case .stopwatch: return "Stopwatch"
        case .zero: return "Back to 0"
        case .paragon: return "PARAGON"
        case .focus: return "Focus rounds (PomoTimer)"
        case .breath: return "Breathing pacer"
        case .bar: return "Progress bar (part of a row)"
        case .often: return "Often used key"
        }
    }

    /// A long press can do anything a key does, except open a new folder or only show something.
    static let forLongPress: [ActionType] = [.none, .app, .running, .recent, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut,
                                             .text, .copied, .macDo, .searchCopied, .media, .playlist, .timer, .stopwatch, .counter,
                                             .toggle, .joinMeeting, .paragon, .focus, .desk, .list, .multi,
                                             .back, .nextPage, .previousPage, .profile]
    static let forSteps: [ActionType] = [.app, .recent, .link, .recentFile, .raycast, .askAI, .shortcut, .appleShortcut, .text, .copied,
                                         .macDo, .searchCopied, .media, .playlist, .timer, .toggle, .joinMeeting, .paragon, .focus, .desk, .wait]
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
            case .garmin:
                Picker("", selection: $action.target) {
                    ForEach(GarminKeys.Number.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
                }
                .labelsHidden()
                .accessibilityIdentifier("garminPicker")
                note("Shows one number from the AMS Garmin Bridge Board on this Mac, asked again every 10 minutes. Steps turn green at your goal; the resting pulse says so in words from 5 beats over your usual and turns amber from 8; stress follows Garmin’s own steps, amber only when high. The two gym numbers come from your gym app’s sessions. Numbers the watch has not renewed for 3 hours turn grey-blue and say the time they are from. A press opens the board. Nothing leaves the Mac.")
            case .macNow:
                Picker("", selection: $action.target) {
                    ForEach(MacNowKeys.Number.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
                }
                .labelsHidden()
                .accessibilityIdentifier("macNowPicker")
                note("Shows the Mac’s battery, the free space on its disk, or how hard it is working, and changes colour when it needs a look: amber, then red. A press opens Battery or Storage in System Settings, or Activity Monitor.")
            case .worldClock, .sunTimes:
                TownField(text: $action.target, identifier: "townField")
                note(action.type == .worldClock
                     ? "Shows the time in this town, and “tomorrow” or “yesterday” when it is another day there. A press opens the Mac’s Clock. The free service Open-Meteo gets the town’s name once, to find its time zone. Hold the key down to give it another town."
                     : "Shows the next sunrise or sunset in this town, on the town’s own clock. A press opens the Mac’s Weather. The free service Open-Meteo gets the town’s name once, and after that only its place. Hold the key down to give it another town.")
            case .freeUntil:
                HStack(spacing: 8) {
                    Text("A press opens " + (action.target.isEmpty ? "Calendar" : KeyArt.appName(action.target))).lineLimit(1)
                    Spacer(minLength: 4)
                    if !action.target.isEmpty {
                        Button("Calendar") { action.target = "" }.buttonStyle(PlainButton())
                    }
                    Button("Choose app…") { if let picked = Chooser.app() { action.target = picked } }
                        .buttonStyle(PlainButton())
                }
                note("Shows how long you are free until your next event of today: green with the time left, red with “Busy” while an event goes on. All-day events are left out. It uses the same calendar permission as the Next event key.")
            case .nextEvent:
                HStack(spacing: 8) {
                    Text("A press opens " + (action.target.isEmpty ? "Calendar" : KeyArt.appName(action.target))).lineLimit(1)
                    Spacer(minLength: 4)
                    if !action.target.isEmpty {
                        Button("Calendar") { action.target = "" }.buttonStyle(PlainButton())
                    }
                    Button("Choose app…") { if let picked = Chooser.app() { action.target = picked } }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("eventApp")
                }
                note("Shows your next event that has a time: “Now” while it goes on, the minutes in its last hour before the start, its time later today, or its weekday. It looks seven days ahead and leaves out all-day events. The first press makes the Mac ask once whether AMS Deck Mate may see your calendar: choose “Allow Full Access”. It only reads, and never changes an event.")
            case .weather:
                TownField(text: $action.target, identifier: "weatherTown")
                note("Shows the temperature and the sky of this town, asked again every 20 minutes. A press opens the Mac’s Weather. The free weather service Open-Meteo gets the town’s name once, to find its place, and after that only the place. With more than one weather key, give each its town as the title. Hold the key down (a long press) to give it another town without opening this window.")
            case .dueToday:
                note("Shows how many PARAGON tasks are due today; overdue ones are named in small words and turn the key red. A press opens Today in PARAGON. The numbers come from the small file PARAGON on this Mac writes for its own widget, read every minute: they are as fresh as PARAGON’s last look at your notes here. A file from an earlier day shows “–” and “Open PARAGON”.")
            case .paragon: ParagonFields(action: $action)
            case .focus: FocusFields(action: $action)
            case .breath: BreathFields(action: $action)
            case .bar: BarFields(action: $action)
            case .often: OftenFields(action: $action)
            case .cover:
                note("Shows the cover of the song Spotify plays, with the song’s name. A press plays or pauses. The cover appears with the next song change after AMS Deck Mate starts. The picture comes from Spotify’s own open look-up, by the track only.")
            case .bodyBattery:
                note("Shows your latest Body Battery from the AMS Garmin Bridge Board on this Mac, asked again every 10 minutes: green from 50, teal from 25, amber below. A press opens the board (while the key says “Board off”, it starts the board). Nothing leaves the Mac.")
            case .desk: DeskFields(action: $action)
            case .weatherTown: note("Asks for another town for a weather key.")
            case .macDo: MacDoFields(action: $action)
            case .joinMeeting:
                note("Opens the video link of your meeting: the one that starts within ten minutes, else the one going on now, else the next one within a day. It finds links of Zoom, Microsoft Teams, Google Meet, Webex, FaceTime, Whereby, Jitsi and GoTo in the event’s link, place or notes, and says so when there is none. It uses the same calendar permission as the Next event key, and only reads.")
            case .playlist:
                TextField("Spotify link", text: $action.target)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("playlistLink")
                if !action.target.trimmingCharacters(in: .whitespaces).isEmpty, PlaylistKeys.kind(action.target) == nil {
                    Text("This is not a Spotify link. In Spotify choose Share › Copy link, then paste it here.")
                        .font(.caption).foregroundStyle(Color(red: 0.86, green: 0.16, blue: 0.14)).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("playlistNotSpotify")
                } else {
                    note(action.target.trimmingCharacters(in: .whitespaces).isEmpty
                         ? "Paste a Spotify link: in Spotify choose Share › Copy link on a playlist, an album, an artist, a song or a podcast."
                         : PlaylistKeys.kind(action.target).map { "The key shows this \($0)’s own cover, unless you chose a drawing or a picture for it. A press starts it playing in Spotify. The first press makes the Mac ask once whether AMS Deck Mate may control Spotify: choose Allow." } ?? "")
                }
            case .searchCopied:
                Picker("", selection: $action.target) {
                    ForEach(SearchKeys.Engine.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
                }
                .labelsHidden()
                .accessibilityIdentifier("searchPicker")
                note("Opens your browser with a search for the text you copied last. A copied web address opens as it is. Of a long text only the first 300 letters are searched. The text goes only to the search site you pick here.")
            case .counter:
                note("Every press counts one more, shown as a large number on the key. Hold the key down (a long press) to set it back to 0. The number is kept when the Mac restarts, and every counter key has its own.")
            case .stopwatch:
                note("A press starts it and the key shows the time running. Another press pauses it, the next one goes on. Hold the key down (a long press) to set it back to 0. It keeps running when AMS Deck Mate restarts, and every stopwatch key has its own time.")
            case .zero: note("Sets a counter or a stopwatch back to 0.")
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
                Text("Keep the Mac awake").tag(SwitchKeys.awake)
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
            } else if action.target == SwitchKeys.awake {
                note("While it is on, the Mac and its screen do not go to sleep by themselves. Press again to switch it off. It is off again after AMS Deck Mate quits or the Mac restarts.")
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
            switch LinkText.kind(action.target) {
            case .bad:
                Text("This is not a web address or a file. Check it for spaces, or choose a file with the button.")
                    .font(.caption).foregroundStyle(Color(red: 0.86, green: 0.16, blue: 0.14)).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("linkBad")
            case let .bare(address):
                note("“\(action.target.trimmingCharacters(in: .whitespacesAndNewlines))” opens as \(address) when the key is pressed.")
                    .accessibilityIdentifier("linkBare")
            default:
                EmptyView()
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

/// A desk key: the apps it opens, each with the size of its window, and the button that takes the desk as it is now.
struct DeskFields: View {
    @Binding var action: DeckAction
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let spots = DeskKeys.spots(of: action)
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(spots.enumerated()), id: \.offset) { index, spot in
                HStack(spacing: 6) {
                    Text(KeyArt.appName(spot.app)).lineLimit(1)
                    Text(spot.size).foregroundStyle(.secondary).monospacedDigit()
                    Spacer(minLength: 4)
                    Button("Take out") { action.steps = spots.enumerated().filter { $0.offset != index }.map { DeskKeys.step($0.element) } }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("deskRemove-\(index)")
                }
                .font(.callout)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
            HStack {
                Button(spots.isEmpty ? "Take the desk as it is now" : "Take the desk again, as it is now") {
                    action.steps = Desk.now().map(DeskKeys.step)
                }
                .buttonStyle(MainButton(part: "keys"))
                .accessibilityIdentifier("deskTake")
                Spacer()
            }
            Text("Remembers the apps that have a window on screen right now (up to eight), with the place and size of each one’s front window. A press opens them and puts every window back. Moving windows needs the Mac’s Accessibility yes, the same one the shortcut keys use.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// An "On the Mac" key: what it does, whether it asks first, and for "Quit all apps" the apps that stay open.
struct MacDoFields: View {
    @Binding var action: DeckAction

    var body: some View {
        let what = MacDoKeys.what(action.target)
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: Binding(get: { what.rawValue }, set: { new in
                // Another thing to do: its own start, asking first.
                // "Quit all apps" starts with the apps open right now under "Stays open".
                if new != action.target {
                    action = DeckAction(type: .macDo, target: new,
                                        steps: new == MacDo.quitAll.rawValue ? MacDoer.openNow().map { DeckAction(type: .app, target: $0) } : [])
                }
            })) {
                ForEach(MacDo.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
            }
            .labelsHidden()
            .accessibilityIdentifier("macDoPicker")
            if what.canAsk {
                Toggle("Ask first", isOn: Binding(get: { !action.quiet }, set: { action.quiet = !$0 }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("macDoAsk")
            }
            if what == .quitAll {
                FieldLabel("Stays open")
                let spared = QuitKeys.spared(action)
                ForEach(Array(spared.enumerated()), id: \.offset) { index, app in
                    HStack(spacing: 6) {
                        Text(KeyArt.appName(app)).lineLimit(1)
                        Spacer(minLength: 4)
                        Button("Take out") {
                            action.steps = spared.enumerated().filter { $0.offset != index }.map { DeckAction(type: .app, target: $0.element) }
                        }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("spareRemove-\(index)")
                    }
                    .font(.callout)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                HStack {
                    Button("Add app…") {
                        guard let picked = Chooser.app(), !spared.contains(picked) else { return }
                        action.steps = (spared + [picked]).map { DeckAction(type: .app, target: $0) }
                    }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("spareAdd")
                    Button("Take the apps open now") {
                        action.steps = MacDoer.openNow().map { DeckAction(type: .app, target: $0) }
                    }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("spareNow")
                    Spacer()
                }
            }
            Text(words(what)).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func words(_ what: MacDo) -> String {
        switch what {
        case .lock:
            return "Locks the screen at once. You need your password or Touch ID to get back in."
        case .desktop:
            return "Moves all windows aside so the desktop shows. A second press brings them back."
        case .quitAll:
            return "Quits every open app except the Finder, AMS Deck Mate and the apps listed under “Stays open”. That list starts with the apps open when you chose this; take out what should quit. It asks first and names the apps; an app with unsaved work still asks you itself. From the iPhone or iPad the question opens on the Mac."
        case .emptyBin:
            return "Empties the bin for good. It asks first and says how many things are in it. If your Finder is set to warn before emptying, the Finder asks once more; take the tick off here to see only the Finder’s question. The first press makes the Mac ask once whether AMS Deck Mate may control the Finder: choose Allow."
        case .ejectAll:
            return "Ejects every plugged-in disk, card, stick and disk picture, never the Mac’s own disk and never a share on another computer. It asks first and names the disks, and tells you when one is still in use."
        case .pastePlain:
            return "Pastes the text you copied without its font, size and colour. It needs the Mac’s Accessibility yes, the same one the shortcut keys use."
        }
    }
}

/// A PARAGON key: which of the four.
struct ParagonFields: View {
    @Binding var action: DeckAction

    var body: some View {
        let what = ParagonKeys.what(action.target)
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: $action.target) {
                ForEach(ParagonKeys.What.allCases, id: \.rawValue) { Text($0.title).tag($0.rawValue) }
            }
            .labelsHidden()
            .accessibilityIdentifier("paragonPicker")
            Text(words(what)).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func words(_ what: ParagonKeys.What) -> String {
        let file = " The numbers come from the small file PARAGON on this Mac writes for its own widget, read every minute: they are as fresh as PARAGON’s last look at your notes here. A file from an earlier day shows “–” and “Open PARAGON”."
        switch what {
        case .inbox:
            return "Shows how many lines wait in PARAGON’s Inbox. A press opens the Inbox." + file
        case .next:
            return "Shows the first task on PARAGON’s list, the one its widget shows first, with when it is due. A press opens its note in PARAGON." + file
        case .copiedTask:
            return "Puts the text you copied last into PARAGON’s Inbox as a task. PARAGON stays in the background. With nothing copied the Mac beeps."
        case .note:
            return "Opens a small window on the Mac for a few words, with Cancel and Save. Save puts them into PARAGON’s Inbox as a note. From the iPhone or iPad the window opens on the Mac."
        case .plan:
            return "Shows the block of today’s plan that goes on now: when it ends, and its name. Between blocks it shows the next one’s start and name, and with nothing more planned it says “Free”. A press opens Today in PARAGON." + file
        }
    }
}

/// A focus rounds key: which PomoTimer template it starts.
struct FocusFields: View {
    @Binding var action: DeckAction
    @State private var own = FocusPlans.own
    @State private var said = ""

    var body: some View {
        let plans = FocusKeys.choices(own: own)
        let plan = FocusKeys.plan(of: action)
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: Binding(get: { action.target }, set: { name in
                if let picked = plans.first(where: { $0.name == name }) { action = FocusKeys.action(for: picked) }
            })) {
                // A template that is no longer in the list stays on the key as it is.
                if !plans.contains(where: { $0.name == action.target }) { Text(action.target).tag(action.target) }
                ForEach(plans, id: \.name) { Text($0.name).tag($0.name) }
            }
            .labelsHidden()
            .accessibilityIdentifier("focusPicker")
            HStack {
                Button("Read my templates from a PomoTimer backup file…") {
                    guard let found = FocusPlans.readBackup() else { return }
                    own = FocusPlans.own
                    said = found == 0 ? "No templates in that file." : found == 1 ? "1 template read." : "\(found) templates read."
                    // The key takes the template's latest steps along.
                    if let same = FocusKeys.choices(own: own).first(where: { $0.name == action.target }) { action = FocusKeys.action(for: same) }
                }
                .buttonStyle(PlainButton())
                .accessibilityIdentifier("focusRead")
                Text(said).font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            Text(FocusPlans.words(plan) + " A press opens AMS PomoTimer in your browser and starts this template there, and the key counts along: the step’s name and its time left, purple while you focus, green in a pause. While it counts, a press brings PomoTimer back; hold the key down to stop the count on the key. The key counts by itself: when you pause or skip in PomoTimer, it does not know.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The PomoTimer templates read from a backup file, kept by Deck Mate.
enum FocusPlans {
    private static let key = "pomoPlans"

    static var own: [FocusKeys.Plan] {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode([FocusKeys.Plan].self, from: $0) } ?? []
    }

    /// Keeps the templates of a backup file; how many it held. PomoTimer's ready-made ones are in it too.
    @discardableResult
    static func keep(fromBackup file: URL) -> Int {
        let plans = (try? Data(contentsOf: file)).map(FocusKeys.plans(fromBackup:)) ?? []
        guard !plans.isEmpty, let data = try? JSONEncoder().encode(plans) else { return 0 }
        UserDefaults.standard.set(data, forKey: key)
        return plans.count
    }

    /// Asks for the backup file; nil = cancelled.
    static func readBackup() -> Int? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseDirectories = false
        panel.prompt = "Read"
        panel.message = "Choose a backup file AMS PomoTimer saved."
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return keep(fromBackup: url)
    }

    /// "6 steps, 65 min: 2 + 3 + 25 + 5 + 25 + 5."
    static func words(_ plan: FocusKeys.Plan) -> String {
        guard !plan.steps.isEmpty else { return "No template chosen yet." }
        let minutes = plan.steps.map { String(($0.seconds + 59) / 60) }.joined(separator: " + ")
        return "\(plan.steps.count) steps, \((plan.seconds + 59) / 60) min: \(minutes)."
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
