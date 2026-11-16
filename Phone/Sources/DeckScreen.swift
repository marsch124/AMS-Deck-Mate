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
    @AppStorage("darkWhenMacSleeps") private var darkWhenMacSleeps = true
    /// A tap on the dark screen shows the keys until the Mac wakes and sleeps again.
    @State private var keysWhileAsleep = false
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
    @AppStorage("showFavourites") private var showFavourites = true
    @AppStorage("showMusic") private var showMusic = true
    @AppStorage("showGlance") private var showGlance = true
    @AppStorage("ownKeys") private var ownKeys = false
    @AppStorage("showMap") private var showMap = true
    @State private var onItsSide = false
    @State private var showStatus = false
    @State private var showMusicPlate = false
    /// The navigation picture shows on an iPad held on its side ("-forceMap" shows it anywhere, for checks).
    private var mapShows: Bool {
        showMap && connected && !link.map.isEmpty
            && (onItsSide || CommandLine.arguments.contains("-forceMap"))
    }
    private var favouritesShow: Bool { showFavourites && link.newMac && link.hasFavourites }
    /// The last touch, for the resting clock.
    @State private var lastTouch = Date()
    @State private var resting = false

    var body: some View {
        ZStack {
            (ground.colour ?? PhonePalette.ground).ignoresSafeArea()
            Group {
                if phoneSideways {
                    // iPhone on its side: everything but the keys sits in a panel on the left, so the keys get the whole height.
                    HStack(spacing: 12) {
                        sidePanel
                        keysColumn(note: false)
                    }
                } else {
                    VStack(spacing: 8) {
                        topBar.padding(.leading, inWindow ? 76 : 0)
                        HStack(spacing: 14) {
                            if mapShows { navigationPicture(width: 230) }
                            keysColumn(note: showNote)
                        }
                        glanceLine
                    }
                }
            }
            .padding(.horizontal, isPad ? 20 : 12)
            .padding(.vertical, isPad ? 14 : 8)
            .opacity(resting || dark ? 0 : 1)
            if dark { asleepScreen } else if resting { restingClock }
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
        .onChange(of: link.macAsleep) { _, _ in keysWhileAsleep = false }
        .preferredColorScheme(ground == .auto ? nil : .dark)
        .background(GeometryReader { box in
            // In a floating window on the iPad its three round buttons sit top left: the top line steps aside.
            Color.clear.onAppear { windowWidth = box.size.width; onItsSide = box.size.width > box.size.height }
                .onChange(of: box.size) { _, new in windowWidth = new.width; onItsSide = new.width > new.height }
        }.ignoresSafeArea())
        .sheet(isPresented: $showSettings) { PhoneSettings(link: link) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("deckScreen")
    }

    /// An iPhone held on its side ("-sideways" forces it, for checks).
    private var phoneSideways: Bool {
        (!isPad && onItsSide) || CommandLine.arguments.contains("-sideways")
    }

    /// iPhone on its side: the top line, the note, the navigation picture and the Mac at a glance, on the left.
    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                statusDot
                Spacer(minLength: 4)
                if showMusic, connected, link.newMac, let now = link.mac { musicButton(now) }
                settingsButton
            }
            .padding(.horizontal, -10)
            placeLine.frame(maxWidth: .infinity, alignment: .leading)
            if let battery { batteryLine(battery) }
            if showNote, link.note != nil { noteLine }
            if mapShows {
                navigationPicture(width: Self.sidePanelWidth)
            } else {
                Spacer(minLength: 0)
            }
            glanceLine
        }
        .frame(width: Self.sidePanelWidth)
        .frame(maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sidePanel")
    }

    /// The width of the left panel on an iPhone held on its side.
    static let sidePanelWidth: CGFloat = 200

    /// The keys with the free room for the message or the clock, where the settings put them.
    private func keysColumn(note: Bool) -> some View {
                VStack(spacing: 8) {
                if keysPlace == .top { keysBlock(note: note) }
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
                    keysBlock(note: note)
                    if keysPlace == .middle { Color.clear.layoutPriority(-1) }
                }
                }
    }

    /// The note on what ran, the 15 keys and the page dots.
    private func keysBlock(note: Bool) -> some View {
        VStack(spacing: 8) {
            if note { noteLine }
            GeometryReader { box in
                let side = Self.keySide(in: box.size, gap: keyGap.points, favourites: favouritesShow) * keySize.scale
                VStack(spacing: keyGap.points + Self.favouritesGap) {
                    KeyGrid(link: link, side: side, gap: keyGap.points, corner: keyShape.corner)
                    if favouritesShow {
                        HStack(spacing: keyGap.points) {
                            ForEach(0..<PhoneLink.favouriteCount, id: \.self) { index in
                                KeyView(index: index, key: link.favourites[index], side: side, corner: keyShape.corner,
                                        lit: link.litFavourites.contains(index), name: "favourite",
                                        hold: { link.favourite(index, long: true) }) { link.favourite(index, long: false) }
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("favouritesRow")
                    }
                }
                    .frame(width: box.size.width, height: box.size.height,
                           alignment: keysPlace == .bottom ? .bottom : (keysPlace == .top ? .top : .center))
                    .opacity(connected ? 1 : 0.35)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 30).onEnded { drag in
                        // Sideways = pages; up or down = the next or previous page group (not locked since 0.10.1).
                        let across = drag.translation.width
                        let along = drag.translation.height
                        if abs(across) > 60, abs(across) > abs(along) * 1.5 {
                            link.page(across < 0 ? 1 : -1)
                        } else if swipeProfiles, abs(along) > 60, abs(along) > abs(across) * 1.5,
                                  let next = link.status?.profile(after: along < 0 ? 1 : -1) {
                            link.swipeProfile(next)
                        }
                    })
            }
            .aspectRatio(favouritesShow ? 5.0 / 4.1 : 5.0 / 3.0, contentMode: .fit)
            if showDots { pageDots }
        }
    }

    /// The Mac's screen sleeps: this one goes black too.
    private var dark: Bool { darkWhenMacSleeps && link.macAsleep && !keysWhileAsleep }

    /// Black with a small moon while the Mac sleeps; one tap shows the keys.
    private var asleepScreen: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 10) {
                PhoneIcon(name: "iconMoon", size: isPad ? 34 : 26).foregroundStyle(.white.opacity(0.45))
                Text("Mac asleep").font(isPad ? .title3 : .callout).foregroundStyle(.white.opacity(0.45))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            lastTouch = Date()
            withAnimation(.easeOut(duration: 0.25)) { keysWhileAsleep = true }
        }
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("macAsleep")
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
    /// With the favourites row there is a fourth row, a little apart from the 15 keys.
    static func keySide(in size: CGSize, gap: CGFloat = 8, favourites: Bool = false) -> CGFloat {
        let byWidth = (size.width - 4 * gap) / 5
        let rows: CGFloat = favourites ? 4 : 3
        let byHeight = (size.height - (rows - 1) * gap - (favourites ? favouritesGap : 0)) / rows
        return max(10, floor(min(byWidth, byHeight)))
    }

    /// The extra room between the 15 keys and the favourites row.
    static let favouritesGap: CGFloat = 8

    // MARK: Navigation picture

    /// Every page group with its pages as small pictures; the page showing has a frame; a tap goes there.
    private func navigationPicture(width: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(link.map, id: \.id) { group in
                    let here = group.id == link.status?.current
                    VStack(alignment: .leading, spacing: 6) {
                        Text(group.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(here ? PhonePalette.part("profiles") : Color.secondary)
                            .lineLimit(1)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 78, maximum: 110), spacing: 8, alignment: .top)],
                                  alignment: .leading, spacing: 8) {
                            ForEach(group.pages, id: \.id) { page in
                                let current = here && page.id == link.status?.pageID
                                Button { link.go(group: group.id, page: page.id) } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Group {
                                            if let image = page.picture.flatMap({ UIImage(data: $0) }) {
                                                Image(uiImage: image).resizable().scaledToFit()
                                            } else {
                                                Color.primary.opacity(0.08).aspectRatio(166.0 / 98.0, contentMode: .fit)
                                            }
                                        }
                                        .padding(4)
                                        .background(Color.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                                            .strokeBorder(PhonePalette.part("screen"), lineWidth: current ? 2.5 : 0))
                                        Text(page.folder ? "▸ " + page.name : page.name)
                                            .font(.caption2)
                                            .foregroundStyle(current ? Color.primary : Color.secondary)
                                            .lineLimit(1)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(group.name), \(page.name)")
                                .accessibilityAddTraits(current ? .isSelected : [])
                                .accessibilityIdentifier("mapPage-\(page.id)")
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
        .frame(width: width)
        .background(PhonePalette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("navigationPicture")
    }

    // MARK: Music

    /// One small round button (filled while something plays); a tap opens the music plate.
    private func musicButton(_ now: PhoneLink.MacNow) -> some View {
        Button { showMusicPlate = true } label: {
            PhoneIcon(name: "iconMusic", size: isPad ? 22 : 19)
                .foregroundStyle(now.playing ? Color.white : PhonePalette.part("settings"))
                .frame(width: isPad ? 38 : 34, height: isPad ? 38 : 34)
                .background(now.playing ? PhonePalette.fill("settings") : PhonePalette.part("settings").opacity(0.14), in: Circle())
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Music")
        .accessibilityIdentifier("musicButton")
        .popover(isPresented: $showMusicPlate) {
            musicPlate(link.mac ?? now)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(PhonePalette.card)
        }
    }

    /// What is playing on the Mac, with play or pause, next, quieter and louder.
    private func musicPlate(_ now: PhoneLink.MacNow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(now.song.isEmpty ? "Nothing playing yet" : now.song).font(.headline).lineLimit(2)
                if !now.artist.isEmpty {
                    Text(now.artist).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("musicSong")
            HStack(spacing: 4) {
                musicKey("iconPlay", now.playing ? "Pause" : "Play", "musicPlay") { link.music(.playPause) }
                musicKey("iconNext", "Next track", "musicNext") { link.music(.next) }
                Spacer(minLength: 6)
                musicKey("iconQuieter", "Quieter", "musicQuieter") { link.music(.volumeDown) }
                if let volume = now.volume {
                    Text("\(volume) %").font(.callout.monospacedDigit()).foregroundStyle(.secondary)
                        .frame(minWidth: 44)
                        .accessibilityIdentifier("musicVolume")
                }
                musicKey("iconLouder", "Louder", "musicLouder") { link.music(.volumeUp) }
            }
        }
        .padding(14)
        .frame(width: 290, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("musicPlate")
    }

    private func musicKey(_ icon: String, _ label: String, _ id: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PhoneIcon(name: icon, size: isPad ? 24 : 20)
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(width: 44, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(id)
    }

    // MARK: Top line

    private var topBar: some View {
        VStack(spacing: 2) {
            ZStack {
                // The heading: large and in the middle.
                placeLine.padding(.horizontal, isPad ? 110 : 84)
                HStack(spacing: 2) {
                    statusDot
                    Spacer(minLength: 8)
                    if showMusic, connected, link.newMac, let now = link.mac { musicButton(now) }
                    settingsButton
                }
            }
            if let battery { batteryLine(battery) }
        }
    }

    private var settingsButton: some View {
        Button { showSettings = true } label: {
            PhoneIcon(name: "iconSettings", size: isPad ? 30 : 24)
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
        .accessibilityIdentifier("settingsButton")
    }

    /// The link to the Mac as one small coloured dot; a tap says it in words.
    private var statusDot: some View {
        Button { showStatus = true } label: {
            Circle().fill(statusColour)
                .frame(width: isPad ? 16 : 13, height: isPad ? 16 : 13)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(statusText)
        .accessibilityIdentifier("linkStatus")
        .popover(isPresented: $showStatus) {
            VStack(alignment: .leading, spacing: 8) {
                Text(statusText).font(.headline)
                ForEach([("Green", "connected to your Mac", Color(red: 0.25, green: 0.70, blue: 0.36)),
                         ("Amber", "looking for the Mac, or waiting for it to allow this \(Self.device)", Color(red: 0.93, green: 0.62, blue: 0.14)),
                         ("Red", "the Mac said no", Color(red: 0.90, green: 0.33, blue: 0.24))], id: \.0) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Circle().fill(row.2).frame(width: 9, height: 9)
                        Text("\(row.0): \(row.1)").font(.callout).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(width: 280, alignment: .leading)
            .presentationCompactAdaptation(.popover)
            .presentationBackground(PhonePalette.card)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("linkStatusCard")
        }
    }

    /// The Mac at a glance, very small at the very bottom: its battery and the app in front.
    @ViewBuilder
    private var glanceLine: some View {
        if showGlance, connected, link.newMac, let glance = link.mac?.glance, !glance.isEmpty {
            HStack(spacing: 4) {
                if link.mac?.battery != nil { PhoneIcon(name: "iconBattery", size: 12) }
                Text(glance).font(.caption2).lineLimit(1)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mac: \(glance)")
            .accessibilityIdentifier("macGlance")
        }
    }

    /// The place, only as a heading (picking or locking a page group is in Settings since 0.10).
    private var placeLine: some View {
        Text(link.place.isEmpty ? "Deck Mate" : link.place)
            .font(isPad ? .largeTitle.weight(.bold) : (phoneSideways ? .title3.weight(.bold) : .title2.weight(.bold)))
            .foregroundStyle(.primary)
            .lineLimit(phoneSideways ? 2 : 1)
            .minimumScaleFactor(0.6)
            .accessibilityIdentifier("deckPlace")
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
                        KeyView(index: index, key: link.keys[index], side: side, corner: corner, lit: link.lit.contains(index),
                                hold: link.newMac ? { link.hold(index) } : nil) {
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
    /// "key" for the 15 keys, "favourite" for the favourites row (for checks).
    var name = "key"
    /// A long press (half a second); nil = the Mac does not know long presses.
    var hold: (() -> Void)?
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
        .onLongPressGesture(minimumDuration: Navigator.longPress) {
            guard image != nil else { return }
            if tapBuzz { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
            pressed = true
            (hold ?? press)()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { pressed = false }
        }
        .accessibilityElement()
        .accessibilityLabel(image == nil ? "Empty \(name)" : (key?.title ?? "Key"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("\(name)\(index)")
    }
}
