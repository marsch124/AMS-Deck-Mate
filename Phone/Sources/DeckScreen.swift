import SwiftUI
import UIKit
import DeckMateCore

/// The main screen: the place line on top, the 15 keys low near the thumb, page dots and a short
/// note on what a tap did.
struct DeckScreen: View {
    @ObservedObject var link: LinkClient
    @State private var showSettings = false
    @State private var hintClosed = false
    @State private var windowWidth: CGFloat = 0
    private var inWindow: Bool {
        isPad && windowWidth > 0 && windowWidth < min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 1
    }

    /// "iPad" on an iPad, "iPhone" on an iPhone, for the words on screen.
    static let device = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private var connected: Bool {
        if case .connected = link.state { return true }
        return false
    }

    @AppStorage("ground") private var baseGround = PhonePrefs.Ground.auto
    @AppStorage("profileGrounds") private var profileGrounds = ""
    @AppStorage("batteryWarning") private var warnBattery = true
    @State private var battery: String?
    /// The background now: the showing profile's own colour, else the chosen background.
    private var ground: PhonePrefs.Ground {
        (connected ? PhonePrefs.profileGround(link.status?.current, in: profileGrounds) : nil) ?? baseGround
    }
    @AppStorage("keyShape") private var keyShape = PhonePrefs.Shape.rounded
    @AppStorage("keyGap") private var keyGap = PhonePrefs.Gap.normal
    @AppStorage("keySize") private var keySize = PhonePrefs.Size.largest
    @AppStorage("keysPlace") private var keysPlace = PhonePrefs.Place.bottom
    @AppStorage("showClock") private var showClock = false
    @AppStorage("restAfter") private var restAfter = 0
    @AppStorage("swipeProfiles") private var swipeProfiles = true
    @AppStorage("showNote") private var showNote = true
    @AppStorage("showDots") private var showDots = true
    /// The last touch, for the resting clock.
    @State private var lastTouch = Date()
    @State private var resting = false

    var body: some View {
        ZStack {
            (ground.colour ?? PhonePalette.ground).ignoresSafeArea()
            VStack(spacing: 8) {
                topBar.padding(.leading, inWindow ? 76 : 0)
                if keysPlace == .top { keysBlock }
                GeometryReader { room in
                    // The free room: the message while there is no Mac, else the clock when it fits.
                    ZStack {
                        if !connected {
                            messageCard
                        } else if showClock, room.size.height >= 110 {
                            BigClock(size: min(room.size.height * 0.5, room.size.width * 0.22, 150))
                        }
                    }
                    .frame(width: room.size.width, height: room.size.height)
                }
                .frame(minHeight: connected ? 0 : 150)
                .layoutPriority(-1)
                if keysPlace != .top {
                    keysBlock
                    if keysPlace == .middle { Color.clear.layoutPriority(-1) }
                }
            }
            .padding(.horizontal, isPad ? 20 : 12)
            .padding(.vertical, isPad ? 14 : 8)
            .opacity(resting ? 0 : 1)
            if resting { restingClock }
        }
        // Every touch counts as "still here" for the resting clock (and never gets in the way of the keys).
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in lastTouch = Date() })
        .onAppear { UIDevice.current.isBatteryMonitoringEnabled = true }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { now in
            let state = UIDevice.current.batteryState
            let words = warnBattery ? PhonePrefs.batteryWarning(level: UIDevice.current.batteryLevel,
                                                                charging: state == .charging || state == .full) : nil
            if words != battery { battery = words }
            let due = PhonePrefs.rests(afterMinutes: restAfter, idle: now.timeIntervalSince(lastTouch))
            if due != resting, due { withAnimation(.easeInOut(duration: 0.6)) { resting = true } }
        }
        .preferredColorScheme(ground == .auto ? nil : .dark)
        .background(GeometryReader { box in
            // In a floating window on the iPad its three round buttons sit top left: the top line steps aside.
            Color.clear.onAppear { windowWidth = box.size.width }
                .onChange(of: box.size.width) { _, new in windowWidth = new }
        }.ignoresSafeArea())
        .sheet(isPresented: $showSettings) { PhoneSettings(link: link) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("deckScreen")
    }

    /// The note on what ran, the 15 keys and the page dots.
    private var keysBlock: some View {
        VStack(spacing: 8) {
            if showNote { noteLine }
            GeometryReader { box in
                let side = Self.keySide(in: box.size, gap: keyGap.points) * keySize.scale
                KeyGrid(link: link, side: side, gap: keyGap.points, corner: keyShape.corner)
                    .frame(width: box.size.width, height: box.size.height,
                           alignment: keysPlace == .bottom ? .bottom : (keysPlace == .top ? .top : .center))
                    .opacity(connected ? 1 : 0.35)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 30).onEnded { drag in
                        // Sideways = pages; up or down = the next or previous profile (it is then locked).
                        let across = drag.translation.width
                        let along = drag.translation.height
                        if abs(across) > 60, abs(across) > abs(along) * 1.5 {
                            link.page(across < 0 ? 1 : -1)
                        } else if swipeProfiles, abs(along) > 60, abs(along) > abs(across) * 1.5,
                                  let next = link.status?.profile(after: along < 0 ? 1 : -1) {
                            link.pickProfile(next)
                        }
                    })
            }
            .aspectRatio(5.0 / 3.0, contentMode: .fit)
            if showDots { pageDots }
        }
    }

    /// Nothing but a big dimmed clock, like a desk clock; one tap brings the keys back.
    private var restingClock: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 14) {
                BigClock(size: isPad ? 170 : 96, dimmed: true).foregroundStyle(.white)
                if let battery { batteryLine(battery) }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            lastTouch = Date()
            withAnimation(.easeOut(duration: 0.25)) { resting = false }
        }
        .transition(.opacity)
    }

    /// The side of one square key, so 5 x 3 keys with their gaps fill the room.
    static func keySide(in size: CGSize, gap: CGFloat = 8) -> CGFloat {
        let byWidth = (size.width - 4 * gap) / 5
        let byHeight = (size.height - 2 * gap) / 3
        return max(10, floor(min(byWidth, byHeight)))
    }

    // MARK: Top line

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                placeLine
                HStack(spacing: 6) {
                    Circle().fill(statusColour).frame(width: isPad ? 10 : 8, height: isPad ? 10 : 8)
                    Text(statusText)
                        .font(isPad ? .callout : .caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("linkStatus")
                if let battery { batteryLine(battery) }
            }
            Spacer(minLength: 8)
            Button { showSettings = true } label: {
                PhoneIcon(name: "iconSettings", size: isPad ? 30 : 24)
                    .foregroundStyle(PhonePalette.part("settings"))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("settingsButton")
        }
    }

    /// The place; a tap on it picks a profile (Automatic, or lock one), like the Mac's menu.
    @ViewBuilder
    private var placeLine: some View {
        let title = Text(link.place.isEmpty ? "Deck Mate" : link.place)
            .font(isPad ? .title2.weight(.bold) : .headline)
            .foregroundStyle(.primary)
            .lineLimit(1)
        if let status = link.status, connected {
            Menu {
                Button { link.pickProfile(nil) } label: {
                    if !status.held { Label("Automatic", systemImage: "checkmark") } else { Text("Automatic") }
                }
                Section("Lock one") {
                    ForEach(status.profiles, id: \.id) { profile in
                        Button { link.pickProfile(profile.id) } label: {
                            if status.held && status.current == profile.id {
                                Label(profile.name, systemImage: "checkmark")
                            } else {
                                Text(profile.name)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    title
                    if status.held {
                        // Locked: this profile stays until "Automatic" is chosen.
                        PhoneIcon(name: "iconLock", size: isPad ? 20 : 16)
                            .foregroundStyle(PhonePalette.part("profiles"))
                            .accessibilityLabel("Locked")
                            .accessibilityIdentifier("profileLock")
                    }
                    Text("▾").font((isPad ? Font.title3 : Font.subheadline).weight(.semibold))
                        .foregroundStyle(PhonePalette.part("profiles"))
                }
            }
            .tint(.primary)
            .accessibilityIdentifier("deckPlace")
        } else {
            title.accessibilityIdentifier("deckPlace")
        }
    }

    private var statusColour: Color {
        switch link.state {
        case .connected: return Color(red: 0.25, green: 0.70, blue: 0.36)
        case .refused: return Color(red: 0.90, green: 0.33, blue: 0.24)
        default: return Color(red: 0.93, green: 0.62, blue: 0.14)
        }
    }

    private var statusText: String {
        switch link.state {
        case .looking: return "Looking for your Mac…"
        case let .connecting(mac): return "Connecting to \(mac)…"
        case let .waiting(mac): return "Waiting for \(mac) to allow this \(Self.device)"
        case let .connected(mac): return "Connected to \(mac)"
        case let .refused(mac): return "\(mac) said no"
        }
    }

    /// "Battery 18 % – plug in", in amber.
    private func batteryLine(_ words: String) -> some View {
        HStack(spacing: 5) {
            PhoneIcon(name: "iconWarning", size: isPad ? 16 : 13)
            Text(words).font((isPad ? Font.callout : Font.caption).weight(.semibold))
        }
        .foregroundStyle(Color(red: 0.95, green: 0.66, blue: 0.18))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("batteryWarning")
    }

    // MARK: Under and over the keys

    /// What the last tap did, for a moment.
    @ViewBuilder
    private var noteLine: some View {
        if let note = link.note {
            HStack(spacing: 6) {
                if !note.ok { PhoneIcon(name: "iconWarning", size: 16) }
                Text(note.text).font(.callout.weight(.medium)).lineLimit(2)
            }
            .foregroundStyle(note.ok ? Color.primary : PhonePalette.problem)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(PhonePalette.card, in: Capsule())
            .transition(.opacity)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("ranNote")
        } else {
            Color.clear.frame(height: 30)
        }
    }

    /// One dot per page; none inside a folder or with one page.
    @ViewBuilder
    private var pageDots: some View {
        if let status = link.status, let page = status.page, status.pages > 1, connected {
            HStack(spacing: 7) {
                ForEach(0..<status.pages, id: \.self) { index in
                    Circle()
                        .fill(index == page ? PhonePalette.part("screen") : Color.secondary.opacity(0.35))
                        .frame(width: 7, height: 7)
                }
            }
            .frame(height: 14)
            .accessibilityElement()
            .accessibilityLabel("Page \(page + 1) of \(status.pages)")
            .accessibilityIdentifier("pageDots")
        } else {
            Color.clear.frame(height: 14)
        }
    }

    // MARK: Message card

    private var messageCard: some View {
        VStack(spacing: 8) {
            Text(cardTitle).font(.title3.weight(.semibold)).multilineTextAlignment(.center)
            if let text = cardText {
                Text(text).font(.callout).multilineTextAlignment(.center).foregroundStyle(.secondary)
            }
            if case .refused = link.state {
                Button("Ask again") { link.retry() }
                    .buttonStyle(PhoneMainButton(part: "screen"))
                    .padding(.top, 4)
                    .accessibilityIdentifier("askAgain")
            }
            TimelineView(.periodic(from: .now, by: 2)) { context in
                if let since = link.lookingSince, context.date.timeIntervalSince(since) > 20, !hintClosed {
                    hotspotHint
                }
            }
        }
        .padding(16)
        .frame(maxWidth: 360)
        .background(PhonePalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("linkMessage")
    }

    /// After 20 seconds of looking: how to put the Mac on this iPhone's hotspot.
    private var hotspotHint: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("Still not found?").font(.headline).foregroundStyle(PhonePalette.part("screen"))
                Spacer()
                Button { hintClosed = true } label: {
                    PhoneIcon(name: "iconClose", size: 16).foregroundStyle(.secondary).frame(width: 32, height: 32)
                }
                .accessibilityLabel("Close the hint")
                .accessibilityIdentifier("closeHint")
            }
            Text(isPad ? "The iPad and the Mac must be on the same Wi-Fi. Away from home: turn on Personal Hotspot on your iPhone and join it from both the iPad and the Mac."
                       : "Away from home Wi-Fi: turn on Personal Hotspot on this iPhone (Settings, Personal Hotspot), then pick this iPhone in the Mac’s Wi-Fi menu.")
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            .buttonStyle(PhoneMainButton(part: "screen"))
            .accessibilityIdentifier("openSettings")
        }
        .padding(.top, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hotspotHint")
    }

    private var cardTitle: String {
        switch link.state {
        case .looking: return "Looking for your Mac…"
        case let .connecting(mac): return "Connecting to \(mac)…"
        case let .waiting(mac): return "Allow this \(Self.device) on \(mac)"
        case let .refused(mac): return "\(mac) said no"
        case .connected: return ""
        }
    }

    private var cardText: String? {
        switch link.state {
        case .looking: return isPad ? "Open AMS Deck Mate on the Mac and put both on the same Wi-Fi."
                             : "Open AMS Deck Mate on the Mac and put both on the same Wi-Fi — or the Mac on this iPhone’s hotspot."
        case .waiting: return "Your Mac is asking whether this \(Self.device) may use the keys. Click Allow there."
        default: return nil
        }
    }
}

/// The 15 keys, 5 across and 3 down.
private struct KeyGrid: View {
    @ObservedObject var link: LinkClient
    let side: CGFloat
    var gap: CGFloat = 8
    var corner: CGFloat = 0.16

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<5, id: \.self) { column in
                        let index = row * 5 + column
                        KeyView(index: index, key: link.keys[index], side: side, corner: corner, lit: link.lit.contains(index)) {
                            link.press(index)
                        }
                    }
                }
            }
        }
    }
}

/// One key: the picture the Mac drew, or an empty place. It lights up when pressed anywhere.
private struct KeyView: View {
    let index: Int
    let key: PhoneLink.Key?
    let side: CGFloat
    var corner: CGFloat = 0.16
    let lit: Bool
    let press: () -> Void
    @State private var pressed = false
    @AppStorage("tapBuzz") private var tapBuzz = true
    @AppStorage("tapClick") private var tapClick = false

    private var image: UIImage? { key?.picture.flatMap { UIImage(data: $0) } }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: side * corner, style: .continuous)
        let down = pressed || lit
        ZStack {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(width: side, height: side)
                    .clipShape(shape)
                    .overlay(shape.fill(Color.black.opacity(down ? 0.35 : 0)))
            } else {
                shape.fill(PhonePalette.emptyKey)
                    .overlay(shape.strokeBorder(Color.primary.opacity(0.10), lineWidth: 1))
            }
        }
        .frame(width: side, height: side)
        .scaleEffect(down ? 0.95 : 1)
        .animation(.easeOut(duration: 0.08), value: down)
        .contentShape(shape)
        .onTapGesture {
            guard image != nil else { return }   // empty places do nothing
            if tapBuzz { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            if tapClick { PhonePrefs.click() }
            pressed = true
            press()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { pressed = false }
        }
        .accessibilityElement()
        .accessibilityLabel(image == nil ? "Empty key" : (key?.title ?? "Key"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("key\(index)")
    }
}
