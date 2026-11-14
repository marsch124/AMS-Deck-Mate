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
    var close: () -> Void = {}
    var startTab: Tab = .settings
    @State private var picked: Tab?
    @State private var openAtLogin = SMAppService.mainApp.status == .enabled
    @State private var brightness = 70.0
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
        .frame(width: 470, height: 600)
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

    private var settingsPage: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            card("Profiles", "profiles") {
                Toggle("Change profile with the app in front", isOn: Binding(
                    get: { model.deck.autoSwitch },
                    set: { on in model.change { $0.autoSwitch = on } }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("autoSwitch")
                note(model.pinned == nil
                     ? "Each profile lists its apps in “Set up keys”. Any other app shows the default profile."
                     : "A profile is held by hand right now. Choose Automatic in the menu to let it follow the app again.")
            }
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
                note("Shortcut: Control-Option-D shows or hides the keys on screen.")
            }
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
            card("Where your setup is kept", "screen") {
                note("One file on this Mac, with the last \(Store.keptCopies) earlier states beside it as safety copies. Nothing leaves the Mac.")
                HStack {
                    Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([model.store.file]) }
                        .buttonStyle(PlainButton())
                    Spacer()
                }
            }
        }
    }

    private func bringOver() {
        let alert = NSAlert()
        alert.messageText = "Bring over the keys from Elgato again?"
        alert.informativeText = "They take the place of all your profiles here. The setup as it is now stays as a safety copy."
        alert.addButton(withTitle: "Bring over")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
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
