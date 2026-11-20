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
    private var keysWhileAsleep: Bool {
        get { link.asleepKeysShown }
        nonmutating set { link.asleepKeysShown = newValue }
    }
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("eveningRest") private var eveningRest = false
    @AppStorage("eveningFrom") private var eveningFrom = PhoneEvening.defaultFrom
    @AppStorage("eveningTo") private var eveningTo = PhoneEvening.defaultTo
    /// The brightness he had before the resting clock dimmed the screen.
    @State private var savedBrightness: CGFloat?
    /// A failed press shows its note even when the note switch is off.
    private var failedNote: Bool { !showNote && link.note?.ok == false }
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
    /// His pick (0.22): the picture hides by itself after a quiet minute.
    @AppStorage("mapHidesBySelf") private var mapHidesBySelf = true
    @State private var onItsSide = false
    @State private var showStatus = false
    @State private var showMusicPlate = false
    @State private var showPrivate = false
    /// Where the keys sit in the row they share with the navigation picture, so the plate lines up with them.
    @State private var keysFrame = CGRect.zero
    /// The camera cut-out is on the right (iPhone turned the other way): the column beside the keys moves left.
    @State private var islandTrailing = false
    @State private var sideInsets = EdgeInsets()
    /// On its side, Settings and music sit at the bottom left (upright: top right, as ever).
    private var lowButtons: Bool {
        phoneSideways || (isPad && onItsSide) || CommandLine.arguments.contains("-forceMap")
    }
    /// The navigation picture shows on an iPad held on its side ("-forceMap" shows it anywhere, for checks).
    /// The navigation picture has its place here: shown, or hidden behind the "Pages" tab (0.20: a swipe hides it).
    private var mapPlace: Bool {
        connected && !link.map.isEmpty
            // An iPhone showing two pages at once needs all its width for the keys.
            && (isPad || link.tiles.count < 2)
            && (onItsSide || CommandLine.arguments.contains("-forceMap"))
    }
    /// The width of the navigation picture while a finger drags it (nil when no finger is on it).
    @State private var mapPull: CGFloat?
    /// iPhone on its side with the picture hidden: the battery line and the note sit over the keys instead.
    private var linesOverKeys: Bool { mapPlace && !showMap }
    /// The picture hidden: the favourites stand in a column left of the keys (his pick, 0.21).
    private var favColumn: Bool { favouritesShow && mapPlace && !showMap }
    /// The favourites and the keys glide between the row and the column.
    @Namespace private var keysSpace
    private var favouritesShow: Bool { showFavourites && link.newMac && link.hasFavourites }
    /// The last touch, for the resting clock.
    @State private var lastTouch = Date()
    @State private var resting = false

    var body: some View {
        ZStack {
            (ground.colour ?? PhonePalette.ground).ignoresSafeArea()
            Group {
                if resting {
                    Color.clear
                } else if phoneSideways {
                    // iPhone on its side: everything but the keys sits in a panel on the left, so the keys get the whole height.
                    HStack(spacing: 12) {
                        sidePanel
                        // His pick (0.16): the heading in one line in the middle over the keys, in the room
                        // that was free there anyway, so the keys keep their size and their place.
                        VStack(spacing: 2) {
                            sideHeading
                            keysColumn(note: false)
                        }
                        .overlay(alignment: .top) {
                            if linesOverKeys {
                                VStack(spacing: 4) {
                                    if let battery {
                                        batteryLine(battery)
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                            .background(PhonePalette.card, in: Capsule())
                                    }
                                    if (showNote || failedNote), link.note != nil { noteLine }
                                }
                            }
                        }
                    }
                    .coordinateSpace(.named("keysRow"))
                    .onPreferenceChange(KeysFrameKey.self) { keysFrame = $0 }
                    // His pick (0.21): the picture hidden, the tab moves to the edge of the safe area (the
                    // column with Settings sits there when the camera is on the right, so then it stays).
                    .padding(.leading, linesOverKeys && !islandTrailing ? -12 : 0)
                    // His pick (0.16): the app pill, lock, music and Settings stand in the free strip by the
                    // screen's edge, beside the keys, so the keys keep their size and their place.
                    .padding(islandTrailing ? .leading : .trailing, edgeReserve)
                    .overlay(alignment: islandTrailing ? .topLeading : .topTrailing) {
                        edgeColumn
                            .frame(width: Self.edgeWidth, height: max(keysFrame.height, 0))
                            .offset(x: (islandTrailing ? -1 : 1) * (Self.edgeWidth + Self.edgeGap - edgeReserve),
                                    y: max(keysFrame.minY, 0))
                    }
                } else {
                    VStack(spacing: 8) {
                        topBar.padding(.leading, inWindow ? 76 : 0)
                        HStack(spacing: 14) {
                            if mapPlace { mapColumn }
                            keysColumn(note: showNote)
                        }
                        .coordinateSpace(.named("keysRow"))
                        .onPreferenceChange(KeysFrameKey.self) { keysFrame = $0 }
                        bottomBar
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
            let parts = Calendar.current.dateComponents([.hour, .minute], from: now)
            let minutes = PhoneEvening.restMinutes(setting: restAfter, on: eveningRest,
                                                   now: (parts.hour ?? 0) * 60 + (parts.minute ?? 0),
                                                   from: eveningFrom, to: eveningTo)
            let due = PhonePrefs.rests(afterMinutes: minutes, idle: now.timeIntervalSince(lastTouch))
            if due != resting, due { withAnimation(.easeInOut(duration: 0.6)) { resting = true } }
            // His pick (0.22): a minute without a touch, the picture slides away by itself, like a swipe.
            if mapPlace, mapPull == nil,
               MapSwipe.hidesBySelf(on: mapHidesBySelf, shown: showMap, idle: now.timeIntervalSince(lastTouch)) {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { showMap = false }
            }
            // The keys shown on a tap while the Mac sleeps stay for 2 minutes after the last touch.
            if keysWhileAsleep, now.timeIntervalSince(lastTouch) >= 120 { withAnimation(.easeOut(duration: 0.25)) { keysWhileAsleep = false } }
        }
        .onChange(of: resting) { _, now in now ? dimScreen() : restoreScreen() }
        .onChange(of: scenePhase) { _, phase in
            // Never leave the device dim: back to his brightness, and the keys instead of the resting clock.
            if phase != .active { restoreScreen(); if resting { resting = false; lastTouch = Date() } }
        }
        .onDisappear { restoreScreen() }
        .onChange(of: link.macAsleep) { _, _ in keysWhileAsleep = false }
        // Turned from one side straight to the other the size stays the same: only this tells.
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in readIslandSide() }
        .preferredColorScheme(ground == .auto ? nil : .dark)
        .background(GeometryReader { box in
            // In a floating window on the iPad its three round buttons sit top left: the top line steps aside.
            Color.clear.onAppear { windowWidth = box.size.width; onItsSide = box.size.width > box.size.height; readIslandSide() }
                .onChange(of: box.size) { _, new in windowWidth = new.width; onItsSide = new.width > new.height; readIslandSide() }
        }.ignoresSafeArea())
        .background(GeometryReader { box in
            // The free strips left and right of the safe area (beside the camera cut-out and opposite it).
            Color.clear.onAppear { sideInsets = box.safeAreaInsets }
                .onChange(of: box.safeAreaInsets) { _, new in sideInsets = new }
        })
        .sheet(isPresented: $showSettings) { PhoneSettings(link: link) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("deckScreen")
    }

    /// The resting clock dims the screen to a quarter of his brightness (not below 5 %).
    private func dimScreen() {
        if savedBrightness == nil { savedBrightness = UIScreen.main.brightness }
        UIScreen.main.brightness = max(0.05, (savedBrightness ?? 0.2) * 0.25)
    }

    private func restoreScreen() {
        guard let saved = savedBrightness else { return }
        UIScreen.main.brightness = saved
        savedBrightness = nil
    }

    /// An iPhone held on its side ("-sideways" forces it, for checks).
    private var phoneSideways: Bool {
        (!isPad && onItsSide) || CommandLine.arguments.contains("-sideways")
    }

    /// iPhone on its side: the connection dot and the heading in one line, in the middle over the keys.
    private var sideHeading: some View {
        HStack(spacing: -8) {
            statusDot
            placeLine
        }
        .frame(height: 26)
        .frame(maxWidth: .infinity)
        .offset(x: -8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sideHeading")
    }

    /// iPhone on its side: the navigation picture on the left, from the very top (a battery line or the note above it).
    @ViewBuilder
    private var sidePanel: some View {
        if mapPlace {
            // The picture slides away to the left with a swipe; the lines above it slide with it.
            VStack(alignment: .leading, spacing: 6) {
                if !linesOverKeys {
                    VStack(alignment: .leading, spacing: 6) {
                        if let battery { batteryLine(battery) }
                        if showNote, link.note != nil { noteLine }
                    }
                    .frame(width: Self.sidePanelWidth, alignment: .leading)
                    .frame(width: max(0, mapPull ?? Self.sidePanelWidth), alignment: .trailing)
                    .clipped()
                }
                // His pick (0.21): the tab as tall as the keys, its top and bottom in line with them.
                mapSlot(width: Self.sidePanelWidth, tabSpan: keysFrame.height > 0 ? keysFrame : nil)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .top) { if failedNote, !linesOverKeys { noteLine } }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("sidePanel")
        } else {
            VStack(alignment: .leading, spacing: 6) {
                if let battery { batteryLine(battery) }
                if showNote, link.note != nil { noteLine }
                Spacer(minLength: 0)
            }
            .frame(width: Self.sidePanelWidth)
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .top) { if failedNote { noteLine } }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("sidePanel")
        }
    }

    // MARK: Hiding the navigation picture (0.20)

    /// The navigation picture, or the "Pages" tab where it hides. A swipe to the left on the picture slides
    /// it away (it follows the finger and the keys grow into its room); a tap or a pull on the tab brings it back.
    private func mapSlot(width full: CGFloat, tabSpan: CGRect? = nil) -> some View {
        let open = mapPull ?? (showMap ? full : 0)
        let shown = min(1, max(0, open / full))
        return ZStack(alignment: .topLeading) {
            navigationPicture(width: full)
                .frame(width: max(0, min(open, full)), alignment: .trailing)
                .clipped()
                .opacity(Double(min(1, shown * 1.6)))
                .allowsHitTesting(mapPull == nil && showMap)
            pagesTab
                .frame(height: tabSpan?.height)
                .padding(.top, tabSpan.map { max(0, $0.minY) } ?? 0)
                .frame(maxHeight: .infinity, alignment: .top)
                .opacity(Double(max(0, 1 - shown * 3)))
                .allowsHitTesting(mapPull == nil && !showMap)
        }
        .frame(width: max(open, Self.tabWidth), alignment: .leading)
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .simultaneousGesture(mapDrag(width: full))
    }

    private func mapDrag(width full: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 14, coordinateSpace: .global)
            .onChanged { drag in
                // Only a mostly sideways drag moves it; up and down still scroll the picture.
                guard mapPull != nil || abs(drag.translation.width) > abs(drag.translation.height) * 1.3 else { return }
                mapPull = CGFloat(MapSwipe.shownWidth(wasOpen: showMap, moved: drag.translation.width, width: full))
            }
            .onEnded { drag in
                guard mapPull != nil else { return }
                let open = MapSwipe.opensAfter(wasOpen: showMap, moved: drag.translation.width,
                                               predicted: drag.predictedEndTranslation.width, width: full)
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                    showMap = open
                    mapPull = nil
                }
            }
    }

    /// A thin purple tab at the left edge with "Pages" running up it: the navigation picture is hidden here.
    private var pagesTab: some View {
        Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { showMap = true }
        } label: {
            VStack(spacing: 10) {
                Capsule().fill(.white.opacity(0.8)).frame(width: 3, height: 22)
                // His pick (0.22): a bigger word, easy to read (was 12-point caption type).
                Text("Pages")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
                    .frame(width: 20, height: 56)
                Capsule().fill(.white.opacity(0.8)).frame(width: 3, height: 22)
            }
            .frame(width: Self.tabWidth)
            .frame(maxHeight: .infinity)
            .background(PhonePalette.fill("profiles"), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pages")
        .accessibilityHint("Shows the navigation picture again")
        .accessibilityIdentifier("pagesTab")
    }

    /// The width of the "Pages" tab.
    static let tabWidth: CGFloat = 28

    /// iPhone on its side (his pick, 0.16): beside the keys, in the free strip by the screen's edge, one column:
    /// the Mac's app on its side at the top; the lock, music and Settings at the bottom, Settings in the corner.
    private var edgeColumn: some View {
        VStack(spacing: 0) {
            GeometryReader { room in
                if showGlance, connected, link.newMac, let mac = link.mac, !mac.app.isEmpty {
                    // Turned a quarter: it reads from the top down and is as long as the room allows.
                    glancePill(icon: nil, words: mac.app, part: "settings")
                        .frame(height: Self.edgePill)
                        .frame(width: max(room.size.height - 6, 10), alignment: .leading)
                        .rotationEffect(.degrees(90), anchor: .topLeading)
                        .offset(x: (room.size.width + Self.edgePill) / 2)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Mac: \(mac.app)")
                        .accessibilityIdentifier("macGlance")
                }
            }
            if connected, link.isPrivate { privateLock }
            if showMusic, connected, link.newMac, let now = link.mac { musicButton(now) }
            settingsButton
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("edgeColumn")
    }

    /// The column beside the keys: its width, its distance from the keys and the height of the pill on its side.
    static let edgeWidth: CGFloat = 36
    static let edgeGap: CGFloat = 8
    static let edgePill: CGFloat = 22

    /// The room the column still needs inside the safe area: none on an iPhone with a camera cut-out
    /// (the strip beside the keys is free there), else just enough to keep it on the screen.
    private var edgeReserve: CGFloat {
        let strip = (islandTrailing ? sideInsets.leading : sideInsets.trailing) + 12
        return min(Self.edgeWidth + Self.edgeGap, max(0, Self.edgeWidth + Self.edgeGap + 6 - strip))
    }

    /// Which side the camera cut-out is on: turned so that it is on the right, the column moves to the left edge.
    private func readIslandSide() {
        for wait in [0.0, 0.4, 1.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
                let right = !isPad && scene?.effectiveGeometry.interfaceOrientation == .landscapeLeft
                if right != islandTrailing { islandTrailing = right }
            }
        }
    }

    /// Settings in the corner and music beside it, at the bottom left.
    private var lowButtonRow: some View {
        HStack(spacing: 2) {
            settingsButton
            if showMusic, connected, link.newMac, let now = link.mac { musicButton(now) }
            if connected, link.isPrivate { privateLock }
            Spacer(minLength: 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("lowButtons")
    }

    /// Under the keys: the Mac at a glance in the middle and, on its side, Settings and music at the bottom left.
    @ViewBuilder
    private var bottomBar: some View {
        if lowButtons {
            ZStack {
                glanceLine
                lowButtonRow
            }
        } else {
            glanceLine
        }
    }

    /// The navigation picture beside the keys: its top and bottom in line with the top and bottom keys.
    private var mapColumn: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: max(0, keysFrame.minY))
            mapSlot(width: Self.mapWidth)
                .frame(height: keysFrame.height > 0 ? keysFrame.height : nil)
            Spacer(minLength: 0)
        }
        // Exactly as wide as the picture (or the tab), so the keys get all the rest.
        .frame(width: max(mapPull ?? (showMap ? Self.mapWidth : 0), Self.tabWidth))
    }

    /// The width of the navigation picture beside the keys.
    static let mapWidth: CGFloat = 230

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
                let wide = link.tiles.count > 1
                let column = favColumn && !wide
                let layout = Self.wideLayout(in: box.size, gap: keyGap.points, pages: link.tiles.count, favourites: favouritesShow)
                let sides = FavouriteColumn.sides(width: box.size.width, height: box.size.height, gap: keyGap.points)
                let side = (column ? CGFloat(sides.key)
                            : wide ? layout.side : Self.keySide(in: box.size, gap: keyGap.points, favourites: favouritesShow)) * keySize.scale
                let favouriteSide = column ? CGFloat(sides.favourite) * keySize.scale : side
                Group {
                    if column {
                        // His pick (0.21): the picture hidden, the favourites stand in a column left of the keys.
                        HStack(alignment: .top, spacing: keyGap.points + CGFloat(FavouriteColumn.extraGap)) {
                            favourites(side: favouriteSide, column: true)
                            KeyGrid(link: link, side: side, gap: keyGap.points, corner: keyShape.corner)
                                .matchedGeometryEffect(id: "grid", in: keysSpace)
                        }
                    } else {
                        VStack(spacing: keyGap.points + Self.favouritesGap) {
                            if wide {
                                WideGrid(link: link, side: side, gap: keyGap.points, corner: keyShape.corner, across: layout.across)
                            } else {
                                KeyGrid(link: link, side: side, gap: keyGap.points, corner: keyShape.corner)
                                    .matchedGeometryEffect(id: "grid", in: keysSpace)
                            }
                            if favouritesShow { favourites(side: favouriteSide, column: false) }
                        }
                    }
                }
                    .background(GeometryReader { keys in
                        Color.clear.preference(key: KeysFrameKey.self, value: keys.frame(in: .named("keysRow")))
                    })
                    .frame(width: box.size.width, height: box.size.height,
                           alignment: Self.keysAlignment(keysPlace, leading: column))
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
            .aspectRatio(favColumn && link.tiles.count < 2 ? FavouriteColumn.ratio : (favouritesShow ? 5.0 / 4.1 : 5.0 / 3.0),
                         contentMode: .fit)
            // With the favourites column the keys stand right beside the "Pages" tab (his pick, 0.21).
            .frame(maxWidth: .infinity, alignment: favColumn ? .leading : .center)
            if showDots { pageDots }
        }
        .overlay(alignment: .top) {
            if !note, !phoneSideways, failedNote { noteLine.offset(y: -36) }
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

    /// "Several pages at once": the pages are laid out the way that gives the biggest keys (his pick,
    /// 0.19.1): side by side, one above the other, or two above two.
    static func wideLayout(in size: CGSize, gap: CGFloat = 8, pages: Int, favourites: Bool = false) -> (across: Int, side: CGFloat) {
        guard pages > 1 else { return (1, 0) }
        var best = (across: min(2, pages), side: CGFloat(0))
        for across in 1...pages {
            let down = (pages + across - 1) / across
            guard (down - 1) * across < pages else { continue }     // no row left empty
            let side = wideKeySide(in: size, gap: gap, across: across, down: down, favourites: favourites)
            if side > best.side + 0.5 { best = (across, side) }
        }
        return best
    }

    /// The side of one key with the pages `across` × `down`, each with its name above it.
    static func wideKeySide(in size: CGSize, gap: CGFloat, across: Int, down: Int, favourites: Bool) -> CGFloat {
        let across = CGFloat(across), down = CGFloat(down)
        let between = WideGrid.between(gap)
        let byWidth = (size.width - across * 4 * gap - (across - 1) * between) / (5 * across)
        let rows = 3 * down + (favourites ? 1 : 0)
        let fixed = down * WideGrid.nameHeight + down * 2 * gap + (down - 1) * between
            + (favourites ? gap + favouritesGap : 0)
        return max(10, floor(min(byWidth, (size.height - fixed) / rows)))
    }

    /// The extra room between the 15 keys and the favourites row.
    static let favouritesGap: CGFloat = 8

    /// Where the keys sit in their box: low, high or in the middle; left with the favourites column.
    static func keysAlignment(_ place: PhonePrefs.Place, leading: Bool) -> Alignment {
        switch place {
        case .bottom: return leading ? .bottomLeading : .bottom
        case .top: return leading ? .topLeading : .top
        case .middle: return leading ? .leading : .center
        }
    }

    /// The five favourites, round (his pick, 0.21: a round key is always a favourite), in a row under the keys
    /// or in a column left of them; each one glides between the two places.
    private func favourites(side: CGFloat, column: Bool) -> some View {
        let gap = keyGap.points
        let stack = column ? AnyLayout(VStackLayout(spacing: gap)) : AnyLayout(HStackLayout(spacing: gap))
        return stack {
            ForEach(0..<PhoneLink.favouriteCount, id: \.self) { index in
                KeyView(index: index, key: link.favourites[index], side: side, corner: 0.5,
                        lit: link.litFavourites.contains(index), name: "favourite",
                        hold: { link.favourite(index, long: true) }) { link.favourite(index, long: false) }
                    .matchedGeometryEffect(id: "favourite\(index)", in: keysSpace)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(column ? "favouritesColumn" : "favouritesRow")
    }

    // MARK: Navigation picture

    /// Every page group with its pages as small pictures; the page showing has a frame; a tap goes there.
    private func navigationPicture(width: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(link.map, id: \.id) { group in
                    let here = group.id == link.status?.current
                    // His pick (0.16, "style 4"): every page group in its own frame, its name on a full-colour
                    // ribbon across both pages: purple where he is, grey-blue for the others.
                    let ribbon = here ? PhonePalette.fill("profiles") : PhonePalette.quietFill
                    VStack(alignment: .leading, spacing: 0) {
                        Text(group.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ribbon)
                            .accessibilityAddTraits(here ? [.isHeader, .isSelected] : .isHeader)
                            .accessibilityIdentifier("mapGroup-\(group.id)")
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 74, maximum: 110), spacing: 8, alignment: .top)],
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
                        .padding(6)
                    }
                    .background(ribbon.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(7)
        }
        .frame(width: width)
        .background(PhonePalette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("navigationPicture")
    }

    // MARK: Music

    /// One small music mark with no fill (his asks, 0.19.1 and 0.21); the word under it says "Playing" while something plays. A tap opens the music plate.
    private func musicButton(_ now: PhoneLink.MacNow) -> some View {
        Button { showMusicPlate = true } label: {
            // His ask (0.21): no fill at all, like the lock and the gear beside it.
            PhoneIcon(name: "iconMusic", size: isPad ? 22 : 19)
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(height: isPad ? 34 : 30)
                .worded(now.playing ? "Playing" : "Music")
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
                    if !lowButtons {
                        if showMusic, connected, link.newMac, let now = link.mac { musicButton(now) }
                        settingsButton
                    }
                }
            }
            if let battery { batteryLine(battery) }
        }
    }

    private var settingsButton: some View {
        Button { showSettings = true } label: {
            // His ask (0.21): not bold — the same size as the lock and music marks, so the same thin line.
            PhoneIcon(name: "iconSettings", size: isPad ? 22 : 19)
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(height: isPad ? 34 : 30)
                .worded("Settings")
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
        .accessibilityIdentifier("settingsButton")
    }

    /// On its side: the lock (the line to the Mac is private) by Settings and music; a tap says it in words.
    private var privateLock: some View {
        Button { showPrivate = true } label: {
            PhoneIcon(name: "iconLock", size: isPad ? 21 : 18)
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(height: isPad ? 34 : 30)
                .worded("Private")
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Private line")
        .accessibilityIdentifier("privateLock")
        .popover(isPresented: $showPrivate) {
            Text("Private line: nobody else on the Wi-Fi can read your keys or press them.")
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
                .frame(width: 270, alignment: .leading)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(PhonePalette.card)
                .accessibilityIdentifier("privateCard")
        }
    }

    /// The link to the Mac as one small coloured dot; a tap says it in words.
    private var statusDot: some View {
        Button { showStatus = true } label: {
            Circle().fill(statusColour)
                .frame(width: isPad ? 16 : 13, height: isPad ? 16 : 13)
                .frame(height: isPad ? 34 : 30)
                .worded("Mac")
                // Upright, a small lock beside the dot: the line to the Mac is private.
                // (On its side the lock sits bottom left, by Settings and music.)
                .overlay(alignment: .trailing) {
                    if link.isPrivate, !lowButtons {
                        PhoneIcon(name: "iconLock", size: isPad ? 17 : 14).foregroundStyle(PhonePalette.part("settings"))
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(statusText)
        .accessibilityValue(link.isPrivate ? "Private line" : "")
        .accessibilityIdentifier("linkStatus")
        .popover(isPresented: $showStatus) {
            VStack(alignment: .leading, spacing: 8) {
                Text(statusText).font(.headline)
                if link.isPrivate {
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        PhoneIcon(name: "iconLock", size: 12).foregroundStyle(statusColour)
                        Text("Private line: nobody else on the Wi-Fi can read your keys or press them.")
                            .font(.callout).fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("privateMark")
                }
                ForEach([("Green", "connected to your Mac", PhonePalette.part("settings")),
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

    /// The Mac at a glance at the very bottom: the app in front, in one small pill, green like Settings (his picks: 0.14 no battery, 0.15 green).
    @ViewBuilder
    private var glanceLine: some View {
        if showGlance, connected, link.newMac, let mac = link.mac, !mac.app.isEmpty {
            glancePill(icon: nil, words: mac.app, part: "settings")
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mac: \(mac.app)")
            .accessibilityIdentifier("macGlance")
        }
    }

    /// One small pill in its part's colour.
    private func glancePill(icon: String?, words: String, part: String) -> some View {
        HStack(spacing: 4) {
            if let icon { PhoneIcon(name: icon, size: isPad ? 15 : 12) }
            Text(words).font((isPad ? Font.footnote : Font.caption).weight(.semibold)).lineLimit(1)
        }
        .foregroundStyle(PhonePalette.part(part))
        .padding(.horizontal, isPad ? 11 : 8)
        .padding(.vertical, isPad ? 5 : 3)
        .background(PhonePalette.part(part).opacity(0.15), in: Capsule())
    }

    /// The place, only as a heading (picking or locking a page group is in Settings since 0.10).
    private var placeLine: some View {
        Text(link.place.isEmpty ? "Deck Mate" : link.place)
            .font(isPad ? .largeTitle.weight(.bold) : (phoneSideways ? .title3.weight(.bold) : .title2.weight(.bold)))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .accessibilityIdentifier("deckPlace")
    }

    private var statusColour: Color {
        switch link.state {
        case .connected: return PhonePalette.part("settings")   // the same green as Settings (his pick, 0.15)
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
            if case .waiting = link.state, let code = link.pairCode {
                Text(code)
                    .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(PhonePalette.part("screen"))
                    .accessibilityIdentifier("pairCode")
            }
            if let text = cardText {
                Text(text).font(.callout).multilineTextAlignment(.center).foregroundStyle(.secondary)
            }
            if case .waiting = link.state {
                TimelineView(.periodic(from: .now, by: 2)) { context in
                    if let since = link.waitingSince, context.date.timeIntervalSince(since) > 30 {
                        VStack(spacing: 8) {
                            Text("Nothing yet? Wake your Mac and look for the window “… wants to use your keys”.")
                                .font(.callout).multilineTextAlignment(.center)
                            Button("Ask again") { link.retry() }
                                .buttonStyle(PhoneMainButton(part: "screen"))
                                .accessibilityIdentifier("askAgainWaiting")
                        }
                        .padding(.top, 4)
                    }
                }
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
        case .looking, .connecting:
            if link.macTooOld { return "Update AMS Deck Mate on your Mac" }
            if case let .connecting(mac) = link.state { return "Connecting to \(mac)…" }
            return "Looking for your Mac…"
        case let .waiting(mac): return "Allow this \(Self.device) on \(mac)"
        case let .refused(mac): return "\(mac) said no"
        case .connected: return ""
        }
    }

    private var cardText: String? {
        switch link.state {
        case .looking, .connecting:
            if link.macTooOld {
                return "This app keeps the line to your Mac private. For that the Mac needs AMS Deck Mate 0.8 or later."
            }
            if case .connecting = link.state { return nil }
            return isPad ? "Open AMS Deck Mate on the Mac and put both on the same Wi-Fi."
                         : "Open AMS Deck Mate on the Mac and put both on the same Wi-Fi — or the Mac on this iPhone’s hotspot."
        case .waiting:
            return link.pairCode == nil
                ? "Your Mac is asking whether this \(Self.device) may use the keys. Click Allow there."
                : "Your Mac is asking whether this \(Self.device) may use the keys. Click Allow there if it shows the same number."
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
    /// "Several pages at once": the second page's keys start at 15, the third's at 30 …
    var first = 0

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<5, id: \.self) { column in
                        let index = first + row * 5 + column
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

/// "Several pages at once": the pages side by side (iPhone: 2) or two above two (iPad: 4), each
/// with its name above it. The first is the page the device is on.
private struct WideGrid: View {
    @ObservedObject var link: LinkClient
    let side: CGFloat
    var gap: CGFloat = 8
    var corner: CGFloat = 0.16
    /// How many pages sit side by side (the rest go below).
    var across = 2

    static let nameHeight: CGFloat = 16
    static func between(_ gap: CGFloat) -> CGFloat { max(14, gap * 2.5) }

    var body: some View {
        let names = link.tiles
        let across = max(1, min(across, names.count))
        VStack(spacing: Self.between(gap)) {
            ForEach(0..<(names.count + across - 1) / across, id: \.self) { row in
                HStack(alignment: .top, spacing: Self.between(gap)) {
                    ForEach(0..<across, id: \.self) { column in
                        let page = row * across + column
                        if page < names.count {
                            VStack(alignment: .leading, spacing: gap) {
                                Text(names[page].isEmpty ? "Page" : names[page])
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .frame(height: Self.nameHeight)
                                    .accessibilityIdentifier("pageName\(page)")
                                KeyGrid(link: link, side: side, gap: gap, corner: corner,
                                        first: page * StreamDeckProtocol.keyCount)
                            }
                        } else {
                            Color.clear.frame(width: 5 * side + 4 * gap, height: 1)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("severalPages")
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

/// Where the 15 keys (and the favourites row) sit, handed up to the row they share with the navigation picture.
private struct KeysFrameKey: PreferenceKey {
    static let defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

private extension View {
    /// A small button's word under its mark (his rule: a button that is only a symbol gets a word).
    func worded(_ word: String) -> some View {
        VStack(spacing: 1) {
            self
            Text(word).font(.caption2.weight(.semibold)).foregroundStyle(PhonePalette.part("settings")).lineLimit(1)
                .fixedSize()
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}
