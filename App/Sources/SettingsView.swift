import AppKit
import DeckMateCore
import ServiceManagement
import SwiftUI

/// Settings in three tabs: the settings themselves, How it works, What's new.
struct SettingsView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case settings = "Settings", guide = "How it works", news = "What’s new"
        var id: String { rawValue }
        var part: String {
            switch self {
            case .settings: return "settings"
            case .guide: return "screen"
            case .news: return "raycast"
            }
        }
    }

    @ObservedObject var model: AppModel
    @ObservedObject var phone: PhoneServer
    var close: () -> Void = {}
    var startTab: Tab = .settings
    @State private var picked: Tab?
    @State private var openAtLogin = SMAppService.mainApp.status == .enabled
    @State private var brightness = 70.0
    @State private var pickedPart: Part?
    var startPart: Part = .box
    private var part: Part { pickedPart ?? startPart }
    @State private var checked: [String]?
    @State private var restoring = false
    @State private var linksOn = Outside.isOn
    @State private var listedKeys = 0
    @State private var copies: [Store.Copy] = []
    @State private var restoredNote: String?
    @Environment(\.colorScheme) private var scheme

    private var tab: Tab { picked ?? startTab }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                AppTile(size: 26)
                Text("AMS Deck Mate").font(.title3.weight(.semibold))
                Text(AppInfo.version).font(.callout).foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                ForEach(Tab.allCases) { item in
                    Button { picked = item } label: {
                        Text(item.rawValue)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(item == tab ? Color.white : Palette.part(item.part, scheme))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 4)
                            .background(item == tab ? Palette.fill(item.part) : Palette.part(item.part, scheme).opacity(0.12),
                                        in: Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("tab-\(item.rawValue)")
                }
            }
            ScrollView {
                Group {
                    switch tab {
                    case .settings: settingsPage
                    case .guide: guidePage
                    case .news: newsPage
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            HStack {
                Text("Version \(AppInfo.version) (\(AppInfo.build))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("settingsVersion")
                Spacer()
                Button("Quit AMS Deck Mate") { NSApp.terminate(nil) }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("quitButton")
                Button("Done", action: close)
                    .buttonStyle(MainButton(part: "settings"))
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("doneButton")
            }
        }
        .padding(14)
        .frame(width: 660, height: 600)
        .onAppear {
            brightness = Double(model.deck.brightness)
            model.refreshStatus()
        }
        .accessibilityIdentifier("settings")
    }

    // MARK: Settings

    private func card<Content: View>(_ title: String, _ part: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(Palette.part(part, scheme))
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    /// One of a few choices in a row: the picked one is full colour, also when the window is not in front.
    private func choice(_ title: String, _ picked: Bool, _ id: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundStyle(picked ? Color.white : Palette.part("screen", scheme))
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(picked ? Palette.fill("screen") : Palette.part("screen", scheme).opacity(0.12), in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .accessibilityAddTraits(picked ? .isSelected : [])
    }

    private func note(_ text: String) -> some View {
        Text(text).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
    }

    private var boxLine: String {
        switch model.box {
        case .absent: return "Not plugged in"
        case let .connected(name, serial): return serial.isEmpty ? "Connected: \(name)" : "Connected: \(name), serial number \(serial)"
        case let .blocked(why): return why
        case let .unsupported(name): return "\(name) is plugged in. This first model is not driven yet."
        }
    }

    enum Part: String, CaseIterable, Identifiable {
        case box = "The box", firstTime = "First time with the box", screen = "Keys on screen", phone = "iPhone",
             links = "Raycast and links", profiles = "Page groups", check = "Check keys", use = "Key use", mac = "This Mac", elgato = "From Elgato", kept = "Where it is kept"
        var id: String { rawValue }
        var colour: String {
            switch self {
            case .box, .firstTime: return "box"
            case .screen, .kept: return "screen"
            case .phone, .links: return "raycast"
            case .profiles: return "profiles"
            case .check, .use, .elgato: return "keys"
            case .mac: return "settings"
            }
        }
    }

    /// A list of the parts on the left, one part at a time on the right.
    private var settingsPage: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Part.allCases) { item in
                    Button { pickedPart = item } label: {
                        Text(item.rawValue)
                            .font(.callout.weight(item == part ? .semibold : .regular))
                            .foregroundStyle(item == part ? Color.white : Palette.part(item.colour, scheme))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(item == part ? Palette.fill(item.colour) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("part-\(item.rawValue)")
                }
            }
            .frame(width: 175)
            partView
        }
    }

    @ViewBuilder
    private var partView: some View {
        switch part {
        case .box:
            card("The box", "box") {
                Text(boxLine).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("boxLine")
                HStack {
                    Text("Brightness")
                    Slider(value: $brightness, in: 5...100, step: 5) { editing in
                        if !editing { model.setBrightness(Int(brightness)) }
                    }
                    .tint(Palette.fill("box"))
                    .accessibilityIdentifier("brightness")
                    Text("\(Int(brightness)) %").monospacedDigit().frame(width: 44, alignment: .trailing)
                }
                if model.elgatoRunning {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Elgato’s app is running. Only one app can hold the box, so quit it before you plug the box in.")
                            .font(.callout)
                            .foregroundStyle(Palette.part("raycast", scheme))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 6)
                        Button("Quit Elgato’s app") { model.quitElgato() }
                            .buttonStyle(MainButton(part: "box"))
                            .accessibilityIdentifier("quitElgato")
                    }
                }
                note("Not yet tried on the real box: this version was built while the box was away. The keys on screen work without it.")
            }
        case .firstTime:
            card("First time with the box", "box") { firstTimeBody }
        case .screen:
            card("Keys on screen", "screen") {
                HStack(spacing: 6) {
                    Text("Show them")
                    choice("Where I left them", !model.deck.screenAtPointer, "placeLeft") { model.change { $0.screenAtPointer = false } }
                    choice("At the mouse pointer", model.deck.screenAtPointer, "placePointer") { model.change { $0.screenAtPointer = true } }
                }
                HStack(spacing: 6) {
                    Text("Size")
                    ForEach(ScreenSize.allCases, id: \.self) { size in
                        choice(size.title, model.deck.screenSize == size, "size-\(size.rawValue)") { model.change { $0.screenSize = size } }
                    }
                }
                Toggle("Hide after a key is pressed", isOn: Binding(
                    get: { model.deck.screenHidesAfterKey },
                    set: { on in model.change { $0.screenHidesAfterKey = on } }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("hideAfterKey")
                note("Control-Option-D shows or hides them. Right after, 1–5, Q–T and A–G press the keys, the arrows or Tab change the page and Escape hides them. A folder, Back or a page key never hides them: you are not done yet.")
                if ShortcutState.taken {
                    Text("Control-Option-D is used by another app, so it does not work here. Use the menu bar icon to show the keys.")
                        .font(.caption).foregroundStyle(Color.orange)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("shortcutTaken")
                }
            }
        case .phone:
            card("iPhone", "raycast") {
                Toggle("Let an iPhone use these keys", isOn: Binding(get: { phone.isOn }, set: { phone.setOn($0) }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("phoneOn")
                if phone.isOn {
                    Text(phone.connected.map { "Connected now: \($0)" } ?? "No iPhone connected right now")
                        .accessibilityIdentifier("phoneConnected")
                    ForEach(phone.allowed.sorted { $0.value < $1.value }, id: \.key) { token, name in
                        HStack {
                            Text("Allowed: \(name)")
                            Spacer()
                            Button("Forget") { phone.forget(token) }
                                .buttonStyle(PlainButton())
                                .accessibilityIdentifier("forgetPhone")
                        }
                    }
                }
                note("Open Deck Mate on the iPhone close to this Mac; on the same Wi-Fi it finds the Mac by itself. The first time, this Mac asks whether to allow it.")
            }
        case .links:
            card("Press keys from Raycast", "raycast") {
                Toggle("Keys can be pressed from Raycast and by link", isOn: Binding(
                    get: { linksOn },
                    set: { on in
                        linksOn = on
                        UserDefaults.standard.set(!on, forKey: Outside.offKey)
                        listedKeys = model.writeOutside()
                    }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("linksOn")
                if linksOn {
                    HStack(alignment: .firstTextBaseline) {
                        Text(listedKeys == 1 ? "1 key is listed for Raycast" : "\(listedKeys) keys are listed for Raycast")
                            .accessibilityIdentifier("listedKeys")
                        Spacer(minLength: 6)
                        Button("Show the folder") {
                            model.writeOutside()
                            NSWorkspace.shared.activateFileViewerSelecting([Outside.folder(model.store)])
                        }
                        .buttonStyle(MainButton(part: "raycast"))
                        .accessibilityIdentifier("showLinksFolder")
                    }
                    note("Once, in Raycast: Settings › Extensions › Script Commands › Add Directories, and choose this folder. From then on every key that has words is found in Raycast by its name, under “Deck Mate”. The list follows your keys by itself.")
                    note("A key pressed this way acts wherever it sits; the keys on screen and the box stay where they are. Quit all apps, Empty the bin and Eject all disks always ask first.")
                    note("Every link carries this Mac’s own pass, so a web page or another program cannot press your keys.")
                } else {
                    note("Off: nothing outside AMS Deck Mate can press a key, and the folder for Raycast is removed.")
                }
            }
            .onAppear { listedKeys = model.writeOutside() }
        case .profiles:
            card("Page groups", "profiles") {
                Toggle("Change page group with the app in front", isOn: Binding(
                    get: { model.deck.autoSwitch },
                    set: { on in model.change { $0.autoSwitch = on } }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("autoSwitch")
                note(model.pinned == nil
                     ? "Each page group lists its apps in “Set up keys”. Any other app shows the default page group."
                     : "A page group is locked by hand right now. Choose Automatic in the menu to let it follow the app again.")
            }
        case .check:
            card("Check keys", "keys") { checkBody }
        case .use:
            card("Key use", "keys") { useBody }
        case .mac:
            card("This Mac", "settings") {
                Toggle("Open at login", isOn: Binding(
                    get: { openAtLogin },
                    set: { on in
                        if on { try? SMAppService.mainApp.register() } else { try? SMAppService.mainApp.unregister() }
                        openAtLogin = SMAppService.mainApp.status == .enabled
                    }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("openAtLogin")
                HStack(alignment: .firstTextBaseline) {
                    Text(model.mayPressKeys ? "Pressing shortcuts, typing and music keys: allowed"
                                            : "Pressing shortcuts, typing and music keys: not allowed yet")
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("keysAllowed")
                    Spacer(minLength: 6)
                    if !model.mayPressKeys {
                        Button("Allow…") { ActionRunner.askToPressKeys() }
                            .buttonStyle(MainButton(part: "settings"))
                            .accessibilityIdentifier("allowKeys")
                    }
                }
                note("The Mac asks once, under Privacy & Security, Accessibility. Opening apps, links and Raycast needs no permission.")
            }
        case .elgato:
            card("Keys from Elgato", "keys") {
                if let count = model.importedKeys {
                    Text("\(count) keys were brought over.").accessibilityIdentifier("importedCount")
                }
                ForEach(model.importNotes, id: \.self) { note($0) }
                HStack {
                    Button("Bring over again…") { bringOver() }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("bringOver")
                    Spacer()
                }
                note("Reads the keys of the 15-key box from Elgato’s app. Elgato’s files are only read, never changed.")
            }
        case .kept:
            card("Where your setup is kept", "screen") {
                note("One file on this Mac, with the last \(Store.keptCopies) earlier states beside it as safety copies. Apart from the weekly copy in iCloud Drive, which holds the keys and their pictures, nothing leaves the Mac.")
                HStack {
                    Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([model.store.file]) }
                        .buttonStyle(PlainButton())
                    Button("Bring back an earlier state…") {
                        model.saveNow()
                        copies = model.store.copies()
                        restoring = true
                    }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("restoreCopies")
                    Spacer()
                }
                if let restoredNote { note(restoredNote) }
                if model.cloudCopy.isReal || model.isSample {
                    Divider()
                    CloudCopyRows(cloud: model.cloudCopy)
                }
            }
            .sheet(isPresented: $restoring) {
                RestoreView(copies: copies, bringBack: { copy in
                    restoring = false
                    restoredNote = model.restore(copy)
                        ? "Brought back the state from \(copy.date.formatted(date: .abbreviated, time: .shortened)). Undo (⌘Z) in Set up keys takes it back."
                        : "That safety copy could not be read."
                }, cancel: { restoring = false })
            }
        }
    }

    // MARK: First time with the box

    private var boxAnswer: String {
        switch model.box {
        case .absent:
            return model.elgatoRunning ? "No box seen yet — and Elgato’s app is still running. Quit it first (step 1)."
                                       : "No box seen yet. Plug it in (step 2)."
        case let .connected(name, _):
            if let last = model.lastBoxPress {
                return "The box answered (\(name)) and its keys arrive: last press at \(last.formatted(date: .omitted, time: .shortened)). All is well."
            }
            return "The box answered (\(name)). Now press any key on it: this line then says the keys arrive."
        case let .blocked(why):
            return "The Mac stopped the app from using the box: \(why) Allow it (step 3), then plug the box out and in."
        case let .unsupported(name):
            return "\(name) is plugged in, but it is the first model from 2017, which this app does not drive."
        }
    }

    private var firstTimeBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            step(1, "Quit Elgato’s app: only one app can hold the box.", done: !model.elgatoRunning) {
                if model.elgatoRunning {
                    Button("Quit Elgato’s app") { model.quitElgato() }
                        .buttonStyle(MainButton(part: "box"))
                        .accessibilityIdentifier("firstQuitElgato")
                }
            }
            step(2, "Plug the box into this Mac.", done: model.box != .absent) { EmptyView() }
            step(3, "If the Mac asks about “Input Monitoring”, allow AMS Deck Mate there (Privacy & Security).",
                 done: { if case .connected = model.box { return true } else { return false } }()) {
                Button("Open Privacy & Security") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(PlainButton())
            }
            step(4, "Press a key on the box.", done: model.lastBoxPress != nil) { EmptyView() }
            Text("What the box says").font(.subheadline.weight(.semibold)).foregroundStyle(Palette.part("box", scheme))
                .padding(.top, 4)
            Text(boxAnswer).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("boxAnswer")
            HStack {
                Button("Show the box diary") { NSWorkspace.shared.activateFileViewerSelecting([BoxLog.url]) }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("showBoxLog")
                Spacer()
            }
            note("The diary notes every step with the box. If something does not work, it shows what happened.")
        }
    }

    private func step<Extra: View>(_ number: Int, _ text: String, done: Bool, @ViewBuilder extra: () -> Extra) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 7) {
            Text(done ? "✓" : "\(number)")
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(done ? Palette.fill("settings") : Palette.fill("box"), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(text).fixedSize(horizontal: false, vertical: true)
                extra()
            }
        }
    }

    // MARK: Check keys

    private var checkBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button("Check all keys") { checked = KeyCheck.all(in: model.deck, world: KeyWorldOnMac.world) }
                    .buttonStyle(MainButton(part: "keys"))
                    .accessibilityIdentifier("checkKeys")
                Spacer()
            }
            if let checked {
                if checked.isEmpty {
                    Text("Every key can do its work.").accessibilityIdentifier("checkResult")
                } else {
                    Text(checked.count == 1 ? "1 key cannot work:" : "\(checked.count) keys cannot work:")
                        .accessibilityIdentifier("checkResult")
                    ForEach(checked, id: \.self) { line in
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Circle().fill(Color(red: 0.86, green: 0.16, blue: 0.14)).frame(width: 6, height: 6)
                            Text(line).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            note("A key whose app, file, folder, page group or Raycast extension is gone gets a red corner on screen and in “Set up keys”.")
        }
    }

    // MARK: Key use

    /// Which keys are pressed most, and which not at all: a list for tidying up.
    private var useBody: some View {
        let now = model.useNow
        // A key is named by what it is, not by what it shows this second (a running timer shows its clock).
        let name: (DeckKey) -> String = { key in
            if !key.title.isEmpty { return key.title }
            switch key.action.type {
            case .timer: return "Timer \(TimerKeys.minutes(key.action.target)) min"
            case .running: return "Open app \(RunningApps.number(key.action.target))"
            case .recent: return "Recent app \(RecentApps.number(key.action.target))"
            case .recentFile: return "Recent file \(RecentApps.number(key.action.target))"
            case .copied: return "Last copied text"
            case .toggle:
                return key.action.target == SwitchKeys.dark ? "Dark mode switch" : key.action.target == SwitchKeys.mute ? "Mute switch"
                    : key.action.target == SwitchKeys.awake ? "Keep awake switch" : "Switch"
            case .macDo: return MacDoKeys.what(key.action.target).title
            case .counter: return "Counter"
            case .stopwatch: return "Stopwatch"
            default:
                let shown = KeyArt.title(key)
                return shown.isEmpty ? key.action.type.title : shown
            }
        }
        let most = model.use.most(in: model.deck, name: name)
        let quiet = model.use.quiet(in: model.deck, now: now, name: name)
        let since = model.use.since.formatted(date: .abbreviated, time: .omitted)
        let full = model.use.days(now: now) >= KeyUse.quietDays
        return VStack(alignment: .leading, spacing: 6) {
            Text("Counted since \(since).").accessibilityIdentifier("useSince")
            Text("Pressed most").font(.callout.weight(.semibold)).foregroundStyle(Palette.part("keys", scheme)).padding(.top, 2)
            if most.isEmpty { note("No key pressed yet.") }
            ForEach(most) { line in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(line.count)").font(.callout.weight(.semibold)).monospacedDigit().frame(width: 38, alignment: .trailing)
                    Text(line.words).font(.callout).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text(full ? "Not pressed in the last \(KeyUse.quietDays) days" : "Not pressed since \(since)")
                .font(.callout.weight(.semibold)).foregroundStyle(Palette.part("keys", scheme)).padding(.top, 4)
                .accessibilityIdentifier("useQuietTitle")
            if quiet.isEmpty { note("Every key was pressed.") }
            ForEach(quiet.prefix(40)) { line in
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Circle().fill(Color.secondary.opacity(0.6)).frame(width: 5, height: 5)
                    Text(line.words).font(.callout).fixedSize(horizontal: false, vertical: true)
                }
            }
            if quiet.count > 40 { note("… and \(quiet.count - 40) more.") }
            note("Every press of a key that does something on the Mac is counted: on the box, on the keys on screen, by keyboard, and from iPhone and iPad. Keys that only move around (folders, Back, pages, page groups) and the microphone light are left out. Only the number and the time of the last press are kept, in a small file beside your keys on this Mac.")
        }
    }

    private func bringOver() {
        let alert = NSAlert()
        alert.messageText = "Bring over the keys from Elgato again?"
        alert.informativeText = "They take the place of all your page groups here. The setup as it is now stays as a safety copy."
        guard SafeAsk.run(alert, action: "Bring over") else { return }
        if !model.bringOverFromElgato() {
            let none = NSAlert()
            none.messageText = "Elgato’s app has no keys for a 15-key box on this Mac."
            none.runModal()
        }
    }

    // MARK: How it works, What's new

    private func bullet(_ text: String, _ colour: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 7) {
            Circle().fill(colour).frame(width: 5, height: 5).offset(y: -2)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
    }

    private var guidePage: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Guide.sections) { section in
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title).font(.headline).foregroundStyle(Palette.part(section.part, scheme))
                    ForEach(section.lines, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) }
                }
            }
        }
    }

    private var newsPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Guide.releases) { release in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Version \(release.id)").font(.headline).foregroundStyle(Palette.part("raycast", scheme))
                        Text(release.date).font(.callout).foregroundStyle(.secondary)
                    }
                    group("New", release.new, Palette.part("settings", scheme))
                    group("Changed", release.changed, Palette.part("screen", scheme))
                    group("Fixed", release.fixed, Palette.part("profiles", scheme))
                }
            }
        }
    }

    @ViewBuilder
    private func group(_ title: String, _ lines: [String], _ colour: Color) -> some View {
        if !lines.isEmpty {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(colour).padding(.top, 2)
            ForEach(lines, id: \.self) { bullet($0, colour) }
        }
    }
}
