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
                    Text("The iPhone then looks for a Mac again, and the Mac asks before it lets this iPhone in.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(version)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("phoneVersion")
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
