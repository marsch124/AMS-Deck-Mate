import SwiftUI

/// Settings in three tabs, like the Mac: Settings, How it works, What's new.
struct PhoneSettings: View {
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

    @ObservedObject var link: LinkClient
    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab = .settings
    @AppStorage("ground") private var ground = PhonePrefs.Ground.auto
    @AppStorage("profileGrounds") private var profileGrounds = ""
    @AppStorage("batteryWarning") private var warnBattery = true
    @AppStorage("keyShape") private var keyShape = PhonePrefs.Shape.rounded
    @AppStorage("keyGap") private var keyGap = PhonePrefs.Gap.normal
    @AppStorage("keySize") private var keySize = PhonePrefs.Size.largest
    @AppStorage("keysPlace") private var keysPlace = PhonePrefs.Place.bottom
    @AppStorage("showClock") private var showClock = false
    @AppStorage("restAfter") private var restAfter = 0
    @AppStorage("tapBuzz") private var tapBuzz = true
    @AppStorage("tapClick") private var tapClick = false
    @AppStorage("swipeProfiles") private var swipeProfiles = true
    @AppStorage("showNote") private var showNote = true
    @AppStorage("showDots") private var showDots = true
    @AppStorage("stayAwake") private var stayAwake = true
    @AppStorage("ownKeys") private var ownKeys = false
    @AppStorage("ownProfile") private var ownProfile = ""
    @AppStorage("showFavourites") private var showFavourites = true
    @AppStorage("showMusic") private var showMusic = true
    @AppStorage("showGlance") private var showGlance = true
    @AppStorage("showMap") private var showMap = true

    private var version: String {
        let info = Bundle.main.infoDictionary
        return "Version \(info?["CFBundleShortVersionString"] as? String ?? "?") (\(info?["CFBundleVersion"] as? String ?? "?"))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Deck Mate").font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(PhoneMainButton(part: "settings"))
                    .accessibilityIdentifier("doneButton")
            }
            HStack(spacing: 6) {
                ForEach(Tab.allCases) { item in
                    Button { tab = item } label: {
                        Text(item.rawValue)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(item == tab ? Color.white : PhonePalette.part(item.part))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item == tab ? PhonePalette.fill(item.part) : PhonePalette.part(item.part).opacity(0.14),
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
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("phoneSettings")
    }

    // MARK: Settings

    private var settingsPage: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    PhoneIcon(name: "iconLink", size: 20)
                    Text("Your Mac").font(.headline)
                }
                .foregroundStyle(PhonePalette.part("screen"))
                Text(link.macName.map { "Connected to \($0)" } ?? "No Mac yet. Open AMS Deck Mate on your Mac.")
                    .fixedSize(horizontal: false, vertical: true)
                if link.macName != nil {
                    Button("Forget this Mac") { link.forget() }
                        .buttonStyle(PhonePlainButton())
                        .accessibilityIdentifier("forgetMac")
                    Text("The \(DeckScreen.device) then looks for a Mac again, and the Mac asks before it lets this \(DeckScreen.device) in.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            card("Keys", "screen") {
                chips([false, true], Binding(get: { ownKeys }, set: { ownKeys = $0; link.sendOwn() }), "screen", "own") {
                    $0 ? "My own keys" : "Follow the Mac"
                }
                if ownKeys {
                    if let profiles = link.status?.profiles, !profiles.isEmpty {
                        row("Page group") {
                            chips(profiles.map(\.id),
                                  Binding(get: { ownProfile.isEmpty ? (link.status?.current ?? "") : ownProfile },
                                          set: { ownProfile = $0; link.sendOwn() }),
                                  "screen", "ownGroup") { id in profiles.first { $0.id == id }?.name ?? "?" }
                        }
                    }
                    note("This \(DeckScreen.device) moves through its own page group. The Mac’s keys on screen and the Stream Deck stay where they are; the Mac still does what you tap.")
                } else {
                    note("This \(DeckScreen.device) shows the page group and page the Mac shows.")
                }
                Toggle("Favourites row", isOn: $showFavourites).accessibilityIdentifier("showFavourites")
                note("Five keys under the others that stay in place on every page and in every page group. You fill them on the Mac, in Set up keys.")
                Toggle("Music button", isOn: $showMusic).accessibilityIdentifier("showMusic")
                note("A small round button at the top right. Tap it for what is playing on the Mac (Spotify or Music), with play, next and volume.")
                Toggle("Mac at a glance", isOn: $showGlance).accessibilityIdentifier("showGlance")
                note("The Mac’s battery and the app in front, in one small line at the very bottom.")
                Toggle("Navigation picture", isOn: $showMap).accessibilityIdentifier("showMap")
                note("On an iPad held on its side: every page group and page as a small picture on the left. Tap one to go there.")
                note("Hold a key for half a second for its long-press action (keys with a small dot have one).")
                if link.macName != nil, !link.newMac {
                    Text("Needs AMS Deck Mate 0.5 on the Mac")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(PhonePalette.problem)
                        .accessibilityIdentifier("needsNewMac")
                }
            }
            card("Look", "profiles") {
                row("Background") { chips(PhonePrefs.Ground.allCases, $ground, "profiles", "ground") { $0.title } }
                VStack(alignment: .leading, spacing: 6) {
                    Text("A colour for each page group").font(.subheadline).foregroundStyle(.secondary)
                    if let profiles = link.status?.profiles, !profiles.isEmpty {
                        ForEach(profiles, id: \.id) { profile in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(profile.name).font(.callout.weight(.medium))
                                chips([PhonePrefs.Ground?.none] + PhonePrefs.profileGrounds.map { Optional($0) },
                                      Binding(get: { PhonePrefs.profileGround(profile.id, in: profileGrounds) },
                                              set: { profileGrounds = PhonePrefs.setProfileGround($0, for: profile.id, in: profileGrounds) }),
                                      "profiles", "colour-\(profile.name)") { $0?.title ?? "Same as background" }
                            }
                        }
                        note("When a page group shows, the background takes its colour, so you see which one is up.")
                    } else {
                        note("Your page groups are listed here once a Mac is connected.")
                    }
                }
                row("Key shape") { chips(PhonePrefs.Shape.allCases, $keyShape, "profiles", "shape") { $0.title } }
                row("Gaps between keys") { chips(PhonePrefs.Gap.allCases, $keyGap, "profiles", "gap") { $0.title } }
                row("Key size") { chips(PhonePrefs.Size.allCases, $keySize, "profiles", "size") { $0.title } }
                row("Where the keys sit") { chips(PhonePrefs.Place.allCases, $keysPlace, "profiles", "place") { $0.title } }
            }
            card("Clock", "box") {
                Toggle("Clock above the keys", isOn: $showClock).accessibilityIdentifier("showClock")
                note("A large clock with the date in the free room above the keys. It shows when there is room for it.")
                row("Resting clock") {
                    chips(PhonePrefs.restChoices, $restAfter, "box", "rest") { $0 == 0 ? "Never" : "\($0) min" }
                }
                note("After that long without a touch only a dimmed clock shows, like a desk clock. One tap brings the keys back.")
            }
            card("Touch", "raycast") {
                Toggle("Tap buzz", isOn: $tapBuzz).accessibilityIdentifier("tapBuzz")
                Toggle("Click sound", isOn: $tapClick).accessibilityIdentifier("tapClick")
                Toggle("Swipe up or down changes profile", isOn: $swipeProfiles).accessibilityIdentifier("swipeProfiles")
                note("Swiping left or right for pages always works.")
            }
            card("Showing", "settings") {
                Toggle("The note on what a key did", isOn: $showNote).accessibilityIdentifier("showNote")
                Toggle("Page dots", isOn: $showDots).accessibilityIdentifier("showDots")
                Toggle("Keep the screen awake while connected", isOn: $stayAwake).accessibilityIdentifier("stayAwake")
                Toggle("Warn when the battery is low", isOn: $warnBattery).accessibilityIdentifier("batteryWarningSwitch")
                note("At 20 % or less, and not charging, a small amber line says so, also on the resting clock.")
            }
            Text(version)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("phoneVersion")
        }
    }

    private func card<Content: View>(_ title: String, _ part: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(PhonePalette.part(part))
            content()
        }
        .tint(PhonePalette.fill(part))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func row<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            content()
        }
    }

    private func note(_ text: String) -> some View {
        Text(text).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
    }

    /// A few choices in a row: the picked one is full colour.
    private func chips<Value: Hashable>(_ values: [Value], _ picked: Binding<Value>, _ part: String, _ id: String,
                                        title: @escaping (Value) -> String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(values, id: \.self) { value in
                    let isOn = value == picked.wrappedValue
                    Button { picked.wrappedValue = value } label: {
                        Text(title(value))
                            .font(.callout.weight(.medium))
                            .foregroundStyle(isOn ? Color.white : PhonePalette.part(part))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(isOn ? PhonePalette.fill(part) : PhonePalette.part(part).opacity(0.14), in: Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("\(id)-\(title(value))")
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }
        }
    }

    // MARK: How it works and What's new

    private var guidePage: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(PhoneGuide.sections) { section in
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title).font(.headline).foregroundStyle(PhonePalette.part(section.part))
                    ForEach(section.lines, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) }
                }
            }
        }
    }

    private var newsPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(PhoneGuide.releases) { release in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Version \(release.id)").font(.headline).foregroundStyle(PhonePalette.part("raycast"))
                        Text(release.date).font(.callout).foregroundStyle(.secondary)
                    }
                    group("New", release.new, PhonePalette.part("settings"))
                    group("Changed", release.changed, PhonePalette.part("screen"))
                    group("Fixed", release.fixed, PhonePalette.part("profiles"))
                }
            }
        }
    }

    @ViewBuilder
    private func group(_ title: String, _ lines: [String], _ colour: Color) -> some View {
        if !lines.isEmpty {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(colour).padding(.top, 2)
            ForEach(lines, id: \.self) { line in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("•").foregroundStyle(colour)
                    Text(line).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
