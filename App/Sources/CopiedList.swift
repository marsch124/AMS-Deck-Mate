import AppKit
import DeckMateCore
import SwiftUI

/// The small list a "Last copied text" key set to "A list to pick from" opens at the mouse
/// pointer: the earlier copied texts, one click pastes one. It never takes the keyboard, so the
/// text lands in the app in front.
final class CopiedListPanel {
    private var panel: NSPanel?
    private var outside: Any?
    private var closing: DispatchWorkItem?
    /// Goes away by itself after this many seconds.
    static let stays = 10.0

    /// The key was pressed: show the list, or put it away when it is showing.
    func toggle(texts: [String]) {
        toggle(title: "Copied texts", empty: "Nothing copied earlier yet.", rows: texts.map(CopiedTexts.line), kind: .text) {
            ActionRunner.paste(texts[$0])
        }
    }

    /// The same small list for a "List to pick from" key: `pick` gets the number of the clicked row.
    func toggle(title: String, empty: String, rows: [String], kind: KeyKind, pick: @escaping (Int) -> Void) {
        if panel != nil { close() } else { show(title, empty, rows, kind, pick) }
    }

    private func show(_ title: String, _ empty: String, _ rows: [String], _ kind: KeyKind, _ pick: @escaping (Int) -> Void) {
        let view = CopiedListView(title: title, empty: empty, rows: rows, kind: kind) { [weak self] index in
            self?.close()
            pick(index)
        }
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: host.fittingSize)
        let panel = NSPanel(contentRect: host.frame, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = host
        let pointer = AppDelegate.pointer()
        let screen = NSScreen.screens.first { NSMouseInRect(pointer, $0.frame, false) } ?? NSScreen.main
        if let area = screen?.visibleFrame {
            panel.setFrameOrigin(ScreenDeckRules.origin(pointer: pointer, size: panel.frame.size, area: area))
        }
        panel.orderFrontRegardless()
        self.panel = panel
        // A click anywhere else puts it away.
        outside = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.close()
        }
        let work = DispatchWorkItem { [weak self] in self?.close() }
        closing = work
        DispatchQueue.main.asyncAfter(deadline: .now() + CopiedListPanel.stays, execute: work)
    }

    func close() {
        closing?.cancel()
        closing = nil
        if let outside { NSEvent.removeMonitor(outside) }
        outside = nil
        panel?.orderOut(nil)
        panel = nil
    }
}

struct CopiedListView: View {
    var title = "Copied texts"
    var empty = "Nothing copied earlier yet."
    /// The rows, each already cut to one line.
    let rows: [String]
    var kind = KeyKind.text
    var pick: (Int) -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(Palette.part("keys", scheme))
                .padding(.horizontal, 6)
            if rows.isEmpty {
                Text(empty).font(.callout).foregroundStyle(.secondary)
                    .padding(.horizontal, 6).padding(.vertical, 3)
            }
            ForEach(Array(rows.enumerated()), id: \.offset) { index, text in
                HStack(spacing: 7) {
                    Text("\(index + 1)").font(.caption.weight(.bold)).foregroundStyle(.white)
                        .frame(width: 17, height: 17)
                        .background(Color(nsColor: Palette.tile(kind)), in: Circle())
                    Text(text).font(.callout).lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(width: 330, alignment: .leading)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(ClickCatcher(onDown: { _ in }, onUp: { pick(index) }))
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("copied-\(index)")
            }
        }
        .padding(8)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Color.primary.opacity(0.12)))
    }
}

/// Keeps a weekly copy of the keys file in iCloud Drive, so a lost or broken Mac does not take
/// the keys with it. Only the keys file goes there.
final class CloudCopy: ObservableObject {
    static let drive = URL(fileURLWithPath: NSHomeDirectory())
        .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs", isDirectory: true)
    static var folder: URL { drive.appendingPathComponent("AMS Deck Mate", isDirectory: true) }
    private static let offKey = "cloudCopyOff"
    private static let lastKey = "cloudCopyLast"

    @Published private(set) var isOn: Bool
    @Published private(set) var last: Date?
    /// The last try did not work (macOS said no, or iCloud Drive could not be written).
    @Published private(set) var failed = false
    @Published private(set) var busy = false

    private let store: Store
    /// Saves the setup before a copy is made.
    var save: () -> Void = {}
    private var timer: Timer?
    private let work = DispatchQueue(label: "cloud copy")

    init(store: Store) {
        self.store = store
        isOn = !UserDefaults.standard.bool(forKey: CloudCopy.offKey)
        last = UserDefaults.standard.object(forKey: CloudCopy.lastKey) as? Date
    }

    /// False for pictures and checks (no iCloud folder was given).
    var isReal: Bool { store.cloud != nil }
    var driveIsOn: Bool { FileManager.default.fileExists(atPath: CloudCopy.drive.path) }

    func start() {
        guard isReal else { return }
        // A little after start, then every six hours: copy when the last one is a week old.
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in self?.copyIfDue() }
        let timer = Timer(timeInterval: 6 * 3600, repeats: true) { [weak self] _ in self?.copyIfDue() }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func setOn(_ on: Bool) {
        isOn = on
        UserDefaults.standard.set(!on, forKey: CloudCopy.offKey)
        if on { copyIfDue() }
    }

    private func copyIfDue() {
        guard isOn, CloudCopies.due(last: last, now: Date()) else { return }
        copyNow()
    }

    /// Off the main thread: the first time macOS asks whether the app may use iCloud Drive, and
    /// the write waits for the answer.
    func copyNow() {
        guard isReal, driveIsOn, !busy else { return }
        save()
        busy = true
        let store = store
        work.async { [weak self] in
            let ok = store.copyToCloud()
            DispatchQueue.main.async {
                guard let self else { return }
                self.busy = false
                self.failed = !ok
                if ok {
                    self.last = Date()
                    UserDefaults.standard.set(self.last, forKey: CloudCopy.lastKey)
                }
                BoxLog.note("iCloud copy of the keys: \(ok ? "written" : "could not be written")")
            }
        }
    }
}

/// The iCloud lines of Settings › Where your setup is kept.
struct CloudCopyRows: View {
    @ObservedObject var cloud: CloudCopy

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Keep a weekly copy in iCloud Drive", isOn: Binding(get: { cloud.isOn }, set: { cloud.setOn($0) }))
                .toggleStyle(.switch)
                .controlSize(.small)
                .accessibilityIdentifier("cloudCopySwitch")
            if cloud.isOn {
                HStack {
                    Text(words).font(.caption).foregroundStyle(cloud.failed || !cloud.driveIsOn ? Color.orange : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("cloudCopyLast")
                    Spacer()
                    Button("Copy now") { cloud.copyNow() }
                        .buttonStyle(PlainButton())
                        .disabled(!cloud.driveIsOn || cloud.busy)
                        .accessibilityIdentifier("cloudCopyNow")
                }
            }
        }
    }

    private var words: String {
        if !cloud.driveIsOn { return "iCloud Drive is not switched on on this Mac, so no copy is made." }
        if cloud.busy { return "Copying…" }
        if cloud.failed { return "The copy could not be written. If macOS asked about iCloud Drive, choose Allow, then Copy now." }
        guard let last = cloud.last else { return "No copy yet. In iCloud Drive, folder “AMS Deck Mate”." }
        return "Last copy: \(last.formatted(date: .abbreviated, time: .shortened)), in iCloud Drive, folder “AMS Deck Mate”."
    }
}
