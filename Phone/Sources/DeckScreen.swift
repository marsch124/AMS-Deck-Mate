import SwiftUI
import UIKit
import DeckMateCore

/// The words of one key for the Explain plate.
struct Explained: Equatable {
    var title: String
    var tap: String?
    var hold: String?
    var twice: String?
    /// The plate stands at the bottom (the key is in the upper half of the screen).
    var low: Bool
}

/// "Explain" (0.32): on or off, and the key read last. The keys read it to know a tap must only explain.
final class ExplainState: ObservableObject {
    @Published var explaining = false
    @Published var explained: Explained?
    func end() {
        if explaining { explaining = false }
        if explained != nil { explained = nil }
    }
}

/// The main screen: the place line on top, the 15 keys low near the thumb, page dots and a short
/// note on what a tap did.
struct DeckScreen: View {
    @ObservedObject var link: LinkClient
    @State private var showSettings = false
    /// Explain (0.32): the keys are read, not pressed (`explaining`, `explained` live in this object).
    @StateObject private var explain = ExplainState()
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
    @AppStorage("tapBuzz") private var tapBuzz = true
    /// His pick (0.23): how long the screen must be quiet first (30, 60 or 120 seconds).
    @AppStorage("mapQuietSeconds") private var mapQuietSeconds = 60
    /// His pick (0.23): the tab nudges twice when the picture hid by itself.
    @State private var tabNudge: CGFloat = 0
    @State private var tabLight = false
    /// His pick (0.25): the hint "Hold for groups" under the tab, the first times only.
    @AppStorage("tabHintShown") private var tabHintShown = 0
    @AppStorage("tabListUsed") private var tabListUsed = false
    @State private var tabHint = false
    @State private var onItsSide = false
    @State private var showStatus = false
    @State private var showMusicPlate = false
    @State private var showPrivate = false
    @State private var showPagesPlate = false
    /// Big keys (0.30): the navigation picture pulled in from the far left edge, over the keys.
    @State private var drawerOpen = false
    /// How much of it shows while a finger drags it (nil when no finger is on it).
    @State private var drawerPull: CGFloat?
    /// It is only built while it is in use (pulled, open, or sliding away).
    @State private var drawerLive = false
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
    /// iPad on its side with several pages at once (his pick, 0.28): the keys fill the screen, the favourites
    /// and the "Pages" button stand in one more column, everything else is one thin line under them.
    private var bigKeys: Bool {
        isPad && (onItsSide || CommandLine.arguments.contains("-forceMap")) && connected
            && (2...4).contains(slots)
    }
    /// The places the screen of several pages lays out (0.34): a page group with one page keeps the usual
    /// number, so the favourites stay where they always are (his "Keep them right", 26 Nov 2026).
    private var slots: Int { BigKeys.slots(tiles: link.tiles.count, usual: link.wideCount) }
    /// The navigation picture can be pulled in from the far left edge, over the keys: on the big-keys
    /// iPad screen (0.30) and on an iPhone on its side that shows two pages (0.31), where it has no other place.
    private var drawerPlace: Bool {
        connected && EdgePull.offered(bigKeys: bigKeys, phoneSideways: phoneSideways, pages: slots,
                                      hasPicture: !link.map.isEmpty)
    }
    /// An iPhone on its side showing two pages at once.
    private var phoneWide: Bool { phoneSideways && connected && slots >= 2 }
    /// The strip beside the camera cut-out of an iPhone on its side: the picture slides in behind it.
    private var drawerInset: CGFloat { bigKeys ? 0 : sideInsets.leading }
    /// The height of the small marks: lower in the thin line of the big-keys screen.
    private var markHeight: CGFloat { bigKeys ? 26 : (isPad ? 34 : 30) }
    /// The width of the navigation picture while a finger drags it (nil when no finger is on it).
    @State private var mapPull: CGFloat?
    /// iPhone on its side with the picture hidden: the battery line and the note sit over the keys instead.
    private var linesOverKeys: Bool { mapPlace && !showMap }
    /// iPhone on its side, picture hidden: no heading line (the link dot moves into the column beside the keys).
    private var headingShows: Bool { MapSwipe.headingShows(phoneSideways: phoneSideways, mapHidden: linesOverKeys) }
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
                        // Two pages at once (0.31): no panel at the left, the pages take the whole width
                        // (the navigation picture is pulled in from the left edge instead).
                        if !phoneWide { sidePanel }
                        // His pick (0.16): the heading in one line in the middle over the keys, in the room
                        // that was free there anyway, so the keys keep their size and their place.
                        VStack(spacing: 2) {
                            // His pick (0.24): the picture hidden, the heading steps aside and the keys take its height.
                            if headingShows { sideHeading.transition(.opacity) }
                            if phoneWide { phoneWideKeys } else { keysColumn(note: false) }
                        }
                        .overlay(alignment: .top) {
                            if linesOverKeys || phoneWide {
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
                } else if bigKeys {
                    bigKeysScreen
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
            .padding(.horizontal, bigKeys ? 8 : (isPad ? 20 : 12))
            .padding(.vertical, bigKeys ? 4 : (isPad ? 14 : 8))
            .opacity(resting || dark ? 0 : 1)
            if drawerPlace, !resting, !dark { pagesDrawer }
            if dark { asleepScreen } else if resting { restingClock }
        }
        // Big keys (0.30): a finger sliding in from the far left edge pulls the navigation picture over the keys.
        .simultaneousGesture(drawerDrag)
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
            if mapPlace, !bigKeys, mapPull == nil,
               MapSwipe.hidesBySelf(on: mapHidesBySelf, shown: showMap, idle: now.timeIntervalSince(lastTouch),
                                    after: Double(mapQuietSeconds)) {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { showMap = false }
                nudgeTab()
            }
            // The picture pulled over the big keys goes away after the same quiet time.
            if drawerOpen, drawerPull == nil,
               MapSwipe.hidesBySelf(on: mapHidesBySelf, shown: true, idle: now.timeIntervalSince(lastTouch),
                                    after: Double(mapQuietSeconds)) {
                setDrawer(false)
            }
            // The keys shown on a tap while the Mac sleeps stay for 2 minutes after the last touch.
            if keysWhileAsleep, now.timeIntervalSince(lastTouch) >= 120 { withAnimation(.easeOut(duration: 0.25)) { keysWhileAsleep = false } }
        }
        .onChange(of: resting) { _, now in now ? dimScreen() : restoreScreen() }
        .onChange(of: showSettings) { _, open in if open { explain.end() } }
        .onChange(of: connected) { _, now in if !now { explain.end() } }
        .onChange(of: link.explains) { _, now in if !now { explain.end() } }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { explain.end() }
            // Never leave the device dim: back to his brightness, and the keys instead of the resting clock.
            if phase != .active { restoreScreen(); if resting { resting = false; lastTouch = Date() } }
            // A drag cut short by leaving the app never leaves the picture half in.
            if phase != .active, drawerPull != nil { drawerPull = nil; if !drawerOpen { drawerLive = false } }
        }
        .onDisappear { restoreScreen() }
        .onChange(of: link.macAsleep) { _, _ in keysWhileAsleep = false }
        .onChange(of: drawerPlace) { _, there in if !there { drawerOpen = false; drawerPull = nil; drawerLive = false } }
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
        .overlay(alignment: explain.explained?.low == true ? .bottom : .top) {
            if explain.explaining {
                explainPlate.padding(10)
                    .padding(.bottom, bigKeys && explain.explained?.low == true ? CGFloat(BigKeys.lineHeight) + 4 : 0)
                    .allowsHitTesting(false)
            }
        }
        .environmentObject(explain)
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
        // His pick (0.25): "Hold for groups" just under the tab, apart from it (so it never widens the tab).
        .overlay(alignment: tabSpan == nil ? .bottomLeading : .topLeading) {
            if tabHint, !showMap, mapPull == nil {
                Text("Hold for groups")
                    .font(.caption2.weight(.semibold))
                    // His pick (0.26): lighter purple at night, so it reads on a dark screen.
                    .foregroundStyle(PhonePalette.part("profiles"))
                    .fixedSize()
                    .offset(y: tabSpan.map { $0.minY + $0.height + 3 } ?? 17)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .accessibilityIdentifier("tabHint")
            }
        }
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
                guard mapPull != nil else {
                    // His pick (0.26): up or down on the tab changes the page group, like on the keys.
                    if !showMap, swipeProfiles,
                       let step = MapSwipe.groupStep(across: drag.translation.width, along: drag.translation.height),
                       let next = link.status?.profile(after: step) {
                        snapFeel()
                        link.swipeProfile(next)
                    }
                    return
                }
                let open = MapSwipe.opensAfter(wasOpen: showMap, moved: drag.translation.width,
                                               predicted: drag.predictedEndTranslation.width, width: full)
                if open != showMap { snapFeel() }
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                    showMap = open
                    mapPull = nil
                }
            }
    }

    /// A thin purple tab at the left edge with "Pages" running up it: the navigation picture is hidden here.
    private var pagesTab: some View {
        // A plain tap only (0.26): a button also fired when a swipe up or down ended on the tall tab.
        Group {
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
                // His pick (0.25): the iPhone has no heading now, so the tab says which page group is showing.
                if !headingShows, let group = currentGroupName {
                    Text(group)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 110, height: 16)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 16, height: 110)
                        .accessibilityIdentifier("tabGroupName")
                }
            }
            .frame(width: Self.tabWidth)
            .frame(maxHeight: .infinity)
            .background(PhonePalette.fill("profiles"), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white.opacity(tabLight ? 0.3 : 0)))
            .offset(x: tabNudge)
            .contentShape(Rectangle())
        }
        .onTapGesture {
            snapFeel()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { showMap = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { showMap = true } }
        .onChange(of: showMap) { _, shown in if !shown, mapPlace { tabAppeared() } }
        .onAppear { if !showMap, mapPlace { tabAppeared() } }
        .accessibilityLabel(currentGroupName.map { "Pages, \($0)" } ?? "Pages")
        .accessibilityHint("Shows the navigation picture again. Hold for a list of page groups.")
        .accessibilityIdentifier("pagesTab")
        // His pick (0.24): hold the tab for the page groups; a tap on one goes to its first page.
        .contextMenu {
            ForEach(link.map, id: \.id) { group in
                if let first = group.pages.first {
                    Button(group.id == link.status?.current ? "\(group.name) (here)" : group.name) {
                        tabListUsed = true
                        withAnimation { tabHint = false }
                        link.go(group: group.id, page: first.id)
                    }
                    .accessibilityIdentifier("tabGroup-\(group.id)")
                }
            }
        }
    }

    /// The name of the page group showing now.
    private var currentGroupName: String? {
        link.map.first { $0.id == link.status?.current }?.name
    }

    /// The tab has just appeared: the hint shows for 8 seconds, the first 3 times only.
    private func tabAppeared() {
        guard MapSwipe.tabHintShows(timesShown: tabHintShown, usedList: tabListUsed) else { return }
        tabHintShown += 1
        withAnimation(.easeOut(duration: 0.3).delay(0.5)) { tabHint = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) { withAnimation(.easeIn(duration: 0.4)) { tabHint = false } }
    }

    /// A soft buzz when the picture snaps away or back by his own hand (the keys' tap-feel switch rules it).
    private func snapFeel() {
        if tapBuzz { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
    }

    /// The picture hid by itself: the tab steps out and back twice and lights up for a moment, so he sees where it went.
    private func nudgeTab() {
        let steps: [(Double, CGFloat)] = [(0.45, 7), (0.63, 0), (0.81, 7), (0.99, 0)]
        for (wait, x) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                withAnimation(.easeInOut(duration: 0.18)) { tabNudge = x; if wait == 0.45 { tabLight = true } }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { withAnimation(.easeOut(duration: 0.4)) { tabLight = false } }
    }

    /// The width of the "Pages" tab.
    static let tabWidth: CGFloat = 28

    /// iPhone on its side (his pick, 0.16): beside the keys, in the free strip by the screen's edge, one column:
    /// the Mac's app on its side at the top; the lock, music and Settings at the bottom, Settings in the corner.
    private var edgeColumn: some View {
        VStack(spacing: 0) {
            if !headingShows { statusDot.padding(.bottom, 4) }
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
            if connected, link.explains { explainButton }
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
            if connected, link.explains { explainButton }
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
                    .gesture(keysSwipe)
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

    /// A swipe on the keys: sideways = pages; up or down = the next or previous page group (not locked since 0.10.1).
    private var keysSwipe: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global).onEnded { drag in
            // Big keys (0.30): a swipe that starts at the far left edge pulls the navigation picture in instead.
            if drawerPlace, drawerOpen || drawerLive
                || EdgePull.atEdge(startX: drag.startLocation.x, inset: drawerInset) { return }
            let across = drag.translation.width
            let along = drag.translation.height
            if abs(across) > 60, abs(across) > abs(along) * 1.5 {
                link.page(across < 0 ? 1 : -1)
            } else if swipeProfiles, abs(along) > 60, abs(along) > abs(across) * 1.5,
                      let next = link.status?.profile(after: along < 0 ? 1 : -1) {
                link.swipeProfile(next)
            }
        }
    }

    // MARK: Big keys (0.28)

    /// iPad on its side, several pages at once (his pick "layout 5"): the pages as large as the screen allows,
    /// the favourites and "Pages" as big as the keys beside (or under) them, one thin line for all the rest.
    private var bigKeysScreen: some View {
        VStack(spacing: 6) {
            GeometryReader { box in
                let gap = keyGap.points
                let plan = BigKeys.plan(width: box.size.width, height: box.size.height, gap: gap,
                                        pages: slots, favourites: favouritesShow)
                let side = CGFloat(plan?.side ?? 40) * keySize.scale
                let between = CGFloat(BigKeys.between)
                let pages = WideGrid(link: link, side: side, gap: gap, corner: keyShape.corner,
                                     across: plan?.across ?? 2, between: between, slots: slots)
                Group {
                    switch plan?.extras ?? .none {
                    case .column:
                        HStack(alignment: .top, spacing: between) {
                            pages
                            extrasColumn(side: side, gap: gap)
                        }
                    case .row:
                        VStack(spacing: between) {
                            pages
                            extrasRow(side: side, gap: gap)
                        }
                    case .none:
                        pages
                    }
                }
                .frame(width: box.size.width, height: box.size.height,
                       alignment: Self.keysAlignment(keysPlace, leading: false))
                .contentShape(Rectangle())
                .gesture(keysSwipe)
            }
            // What the last tap did and the battery warning float over the top of the keys for a moment.
            .overlay(alignment: .top) {
                VStack(spacing: 4) {
                    if let battery {
                        batteryLine(battery)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(PhonePalette.card, in: Capsule())
                    }
                    if (showNote || failedNote), link.note != nil { noteLine }
                }
                .allowsHitTesting(false)
            }
            bigKeysLine
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("bigKeysScreen")
    }

    /// iPhone on its side with two pages at once (0.31): the pages fill the width, and the favourites and
    /// the "Pages" button stand in a row under them, as big as the keys — the iPad's big-keys rule
    /// (`BigKeys.plan`). Before, the pages shared a box made for one page, beside an empty panel.
    private var phoneWideKeys: some View {
        GeometryReader { box in
            let gap = keyGap.points
            let plan = BigKeys.plan(width: box.size.width, height: box.size.height, gap: gap,
                                    pages: slots, favourites: favouritesShow)
            let side = CGFloat(plan?.side ?? 30) * keySize.scale
            let between = CGFloat(BigKeys.between)
            VStack(spacing: between) {
                WideGrid(link: link, side: side, gap: gap, corner: keyShape.corner,
                         across: plan?.across ?? 2, between: between, slots: slots)
                if favouritesShow { extrasRow(side: side, gap: gap) }
            }
            .background(GeometryReader { keys in
                Color.clear.preference(key: KeysFrameKey.self, value: keys.frame(in: .named("keysRow")))
            })
            .frame(width: box.size.width, height: box.size.height,
                   alignment: Self.keysAlignment(keysPlace, leading: false))
            .opacity(connected ? 1 : 0.35)
            .contentShape(Rectangle())
            .gesture(keysSwipe)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("phoneWideKeys")
    }

    // MARK: The navigation picture pulled in from the left edge (0.30)

    /// The navigation picture over the big keys: it slides in from the far left edge with the finger, the
    /// keys behind it dim; a slide back, a tap beside it or a tap on a page sends it away again.
    private var pagesDrawer: some View {
        let full = CGFloat(EdgePull.width)
        let open = drawerPull ?? (drawerOpen ? full : 0)
        let shown = min(1, max(0, open / full))
        return ZStack(alignment: .leading) {
            Color.black.opacity(0.42 * Double(shown))
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { setDrawer(false) }
                .allowsHitTesting(drawerOpen || drawerPull != nil)
                .accessibilityElement()
                .accessibilityLabel("Close the pages")
                .accessibilityAddTraits(.isButton)
                .accessibilityHidden(!drawerOpen)
                .accessibilityIdentifier("pagesDrawerShade")
            if drawerLive {
                navigationPicture(width: full) { setDrawer(false) }
                    .padding(.vertical, 8)
                    .offset(x: CGFloat(EdgePull.offset(shown: Double(open), margin: 8 + Double(drawerInset))))
                    .padding(.leading, 8)
                    .allowsHitTesting(drawerOpen && drawerPull == nil)
                    .accessibilityHidden(!drawerOpen)
                    .accessibilityIdentifier("pagesDrawer")
            }
            // The screen itself shows where to pull: a short purple line at the edge (purple = pages).
            Capsule()
                .fill(PhonePalette.fill("profiles"))
                .frame(width: 4, height: bigKeys ? 64 : 56)
                .frame(width: bigKeys ? 8 : 12, height: 96)
                .contentShape(Rectangle())
                .onTapGesture { setDrawer(true) }
                .opacity(Double(1 - shown))
                .allowsHitTesting(!drawerOpen && drawerPull == nil)
                .accessibilityElement()
                .accessibilityLabel("Pages")
                .accessibilityHint("Pull to the right, or tap, for all pages.")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { setDrawer(true) }
                .accessibilityIdentifier("pagesEdge")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    /// The picture slides in or away by itself (a tap, a page picked, the quiet time).
    private func setDrawer(_ open: Bool, buzz: Bool = true) {
        if open { drawerLive = true }
        if buzz, open != drawerOpen { snapFeel() }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            drawerOpen = open
            drawerPull = nil
        }
        if !open { retireDrawer() }
    }

    /// Once it has slid away it is taken down, so it costs nothing while the keys show.
    private func retireDrawer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if !drawerOpen, drawerPull == nil { drawerLive = false }
        }
    }

    private var drawerDrag: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { drag in
                guard drawerPlace, !resting, !dark else { return }
                if drawerPull == nil {
                    guard EdgePull.takes(startX: drag.startLocation.x, open: drawerOpen,
                                         across: drag.translation.width, along: drag.translation.height,
                                         inset: drawerInset) else { return }
                    drawerLive = true
                }
                drawerPull = CGFloat(MapSwipe.shownWidth(wasOpen: drawerOpen, moved: drag.translation.width,
                                                         width: EdgePull.width))
            }
            .onEnded { drag in
                guard drawerPull != nil else { return }
                let open = MapSwipe.opensAfter(wasOpen: drawerOpen, moved: drag.translation.width,
                                               predicted: drag.predictedEndTranslation.width, width: EdgePull.width)
                if open != drawerOpen { snapFeel() }
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                    drawerOpen = open
                    drawerPull = nil
                }
                if !open { retireDrawer() }
            }
    }

    /// The column right of the pages: "Favourites" over three of them beside the upper pages, two more and
    /// the "Pages" button beside the lower pages, each in line with a row of keys.
    private func extrasColumn(side: CGFloat, gap: CGFloat) -> some View {
        VStack(spacing: CGFloat(BigKeys.between)) {
            ForEach(0..<2, id: \.self) { half in
                VStack(alignment: .leading, spacing: gap) {
                    Text(half == 0 ? "Favourites" : " ")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(PhonePalette.part("favourites"))
                        .lineLimit(1)
                        .frame(width: side, height: CGFloat(BigKeys.nameHeight), alignment: .leading)
                    VStack(spacing: gap) {
                        ForEach(0..<3, id: \.self) { row in
                            let place = half * 3 + row
                            if place < PhoneLink.favouriteCount { favouriteKey(place, side: side) } else { pagesKey(side: side) }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("favouritesColumn")
    }

    /// One row of pages: the favourites and the "Pages" button in a row under them.
    private func extrasRow(side: CGFloat, gap: CGFloat) -> some View {
        HStack(spacing: gap) {
            ForEach(0..<PhoneLink.favouriteCount, id: \.self) { favouriteKey($0, side: side) }
            pagesKey(side: side)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("favouritesRow")
    }

    /// "Pages", as big as a key but only a frame, so it never looks like one of his own keys: a tap opens the
    /// navigation picture as a plate over the keys, holding it lists the page groups.
    private func pagesKey(side: CGFloat, small: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: small ? 7 : side * keyShape.corner, style: .continuous)
        let colour = PhonePalette.part("profiles")
        return VStack(spacing: 2) {
            Text("Pages").font(small ? .footnote.weight(.bold) : .headline.weight(.bold))
            if !small, let group = currentGroupName {
                Text(group).font(.caption2.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.7).opacity(0.85)
            }
            // The screen itself says what holding does (his sign rule).
            if !small, side >= 80 {
                Text("Hold: groups").font(.caption2).lineLimit(1).minimumScaleFactor(0.7).opacity(0.7)
                    .accessibilityIdentifier("pagesKeyHint")
            }
        }
        .foregroundStyle(colour)
        .padding(.horizontal, small ? 10 : 4)
        .frame(width: small ? nil : side, height: small ? 24 : side)
        .background(PhonePalette.card, in: shape)
        .overlay(shape.strokeBorder(colour, lineWidth: small ? 1.5 : 2))
        .contentShape(shape)
        .onTapGesture {
            snapFeel()
            showPagesPlate = true
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(currentGroupName.map { "Pages, \($0)" } ?? "Pages")
        .accessibilityHint("Shows all pages. Hold for a list of page groups.")
        .accessibilityAction { showPagesPlate = true }
        .accessibilityIdentifier("pagesKey")
        .popover(isPresented: $showPagesPlate) {
            navigationPicture(width: 320) { showPagesPlate = false }
                .frame(height: 440)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(PhonePalette.card)
                .accessibilityIdentifier("pagesPlate")
        }
        .contextMenu {
            ForEach(link.map, id: \.id) { group in
                if let first = group.pages.first {
                    Button(group.id == link.status?.current ? "\(group.name) (here)" : group.name) {
                        link.go(group: group.id, page: first.id)
                    }
                    .accessibilityIdentifier("pagesKeyGroup-\(group.id)")
                }
            }
        }
    }

    /// The thin line under the keys: the link dot and the Mac's app at the left, the heading in the middle,
    /// Settings, music and the lock at the right, each with its word beside it.
    private var bigKeysLine: some View {
        ZStack {
            placeLine.padding(.horizontal, 330)
            HStack(spacing: 10) {
                statusDot
                if showGlance, link.newMac, let mac = link.mac, !mac.app.isEmpty {
                    glancePill(icon: nil, words: mac.app, part: "settings")
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Mac: \(mac.app)")
                        .accessibilityIdentifier("macGlance")
                }
                if !favouritesShow { pagesKey(side: 0, small: true) }
                Spacer(minLength: 8)
                if link.explains { explainButton }
                settingsButton
                if showMusic, link.newMac, let now = link.mac { musicButton(now) }
                if link.isPrivate { privateLock }
            }
        }
        .frame(height: CGFloat(BigKeys.lineHeight))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("bigKeysLine")
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
                favouriteKey(index, side: side)
                    .matchedGeometryEffect(id: "favourite\(index)", in: keysSpace)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(column ? "favouritesColumn" : "favouritesRow")
    }

    /// One favourite: round and in a thin gold ring, wherever it stands (his pick, 0.29: "gold ring each").
    private func favouriteKey(_ index: Int, side: CGFloat) -> some View {
        KeyView(index: index, key: link.favourites[index], side: side, corner: 0.5,
                lit: link.litFavourites.contains(index), name: "favourite",
                hold: { link.favourite(index, long: true) }) { link.favourite(index, long: false) }
            // The ring stands a little outside the key, in the room between the keys, so the key keeps its size.
            .overlay(Circle().strokeBorder(PhonePalette.part("favourites"), lineWidth: side < 70 ? 1.5 : 2)
                .padding(-Self.favouriteRing)
                .allowsHitTesting(false))
    }

    /// How far outside a favourite its gold ring stands.
    static let favouriteRing: CGFloat = 3.5

    // MARK: Navigation picture

    /// Every page group with its pages as small pictures; the page showing has a frame; a tap goes there.
    private func navigationPicture(width: CGFloat, picked: (() -> Void)? = nil) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                if link.wideMac { pagesSwitch(picked: picked) }
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
                                Button { link.go(group: group.id, page: page.id); picked?() } label: {
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

    /// On top of the navigation picture (his pick "3", 0.31): a two-part switch between several pages at
    /// once (4 on an iPad, 2 on an iPhone) and one page. The part in full purple is what shows now.
    private func pagesSwitch(picked: (() -> Void)?) -> some View {
        let many = link.wideOn
        return HStack(spacing: 2) {
            ForEach([true, false], id: \.self) { wide in
                let on = wide == many
                let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
                Text(wide ? "\(link.wideCount) pages" : "1 page")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(on ? Color.white : PhonePalette.part("profiles"))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .background(on ? PhonePalette.fill("profiles") : Color.clear, in: shape)
                    .contentShape(shape)
                    .onTapGesture {
                        guard !on else { return }
                        snapFeel()
                        link.setWide(wide)
                        picked?()
                    }
                    .accessibilityElement()
                    .accessibilityLabel(wide ? "Show \(link.wideCount) pages at once" : "Show 1 page")
                    .accessibilityAddTraits(on ? [.isButton, .isSelected] : .isButton)
                    .accessibilityAction { if !on { link.setWide(wide); picked?() } }
                    .accessibilityIdentifier(wide ? "showManyPages" : "showOnePage")
            }
        }
        .padding(2)
        .background(PhonePalette.part("profiles").opacity(0.16), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("pagesSwitch")
    }

    // MARK: Music

    /// One small music mark: the note in a thin green ring that is never filled (his ask, 0.27 — what he had
    /// meant in 0.19.1 and 0.21 too); the word under it says "Playing" while something plays. A tap opens the music plate.
    private func musicButton(_ now: PhoneLink.MacNow) -> some View {
        Button { showMusicPlate = true } label: {
            PhoneIcon(name: "iconMusic", size: bigKeys ? 15 : (isPad ? 18 : 16))
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(width: bigKeys ? 26 : Self.musicRing(isPad), height: bigKeys ? 26 : Self.musicRing(isPad))
                // The subtle frame: a 1-point line at half strength, no fill behind the note.
                .overlay(Circle().strokeBorder(PhonePalette.part("settings").opacity(0.5), lineWidth: 1))
                .frame(height: markHeight)
                .worded(now.playing ? "Playing" : "Music", beside: bigKeys)
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

    /// How wide the thin ring round the music note is.
    static func musicRing(_ pad: Bool) -> CGFloat { pad ? 30 : 26 }

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
                // An iPhone held upright has no room for a third button at the right (0.32: Explain stood on
                // the heading's last letters), so Explain stands at the left, beside the link dot, and the
                // heading leaves 108 points free on both sides while it shows. An iPad keeps it at the right.
                let explainLeft = !isPad && !lowButtons && connected && link.explains
                placeLine.padding(.horizontal, isPad ? 110 : (explainLeft ? 108 : 84))
                HStack(spacing: 2) {
                    statusDot
                    if explainLeft { explainButton.padding(.leading, 4) }
                    Spacer(minLength: 8)
                    if !lowButtons {
                        if isPad, connected, link.explains { explainButton }
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
            PhoneIcon(name: "iconSettings", size: bigKeys ? 18 : (isPad ? 22 : 19))
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(height: markHeight)
                .worded("Settings", beside: bigKeys)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
        .accessibilityIdentifier("settingsButton")
    }

    /// Explain: a tap turns it on or off. On, the keys only say what they do (nothing is pressed).
    private var explainButton: some View {
        let on = explain.explaining
        let colour = PhonePalette.part("explain")
        return Button {
            if on { explain.end() } else { explain.explaining = true }
        } label: {
            let ring = bigKeys ? 26 : Self.musicRing(isPad)
            PhoneIcon(name: "iconExplain", size: bigKeys ? 17 : (isPad ? 21 : 18))
                .foregroundStyle(on ? Color.white : colour)
                // Word under the mark: the mark alone stands on a filled circle, as wide as the music ring
                // (0.32: a fill behind mark and word was a blob that cut the word off).
                .frame(width: bigKeys ? nil : ring, height: bigKeys ? nil : ring)
                .background { if on, !bigKeys { Circle().fill(PhonePalette.fill("explain")) } }
                .frame(height: markHeight)
                .worded("Explain", beside: bigKeys, tint: on && bigKeys ? Color.white : colour)
                // Word beside the mark (the thin line of the big keys): one filled capsule holds both.
                .padding(.horizontal, bigKeys ? 7 : 0)
                .frame(height: bigKeys ? 24 : nil)
                .background { if on, bigKeys { Capsule().fill(PhonePalette.fill("explain")) } }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Explain")
        .accessibilityValue(on ? "on" : "off")
        .accessibilityIdentifier("explainButton")
    }

    /// The plate over the keys while Explain is on: what to do, or the words of the key read last.
    private var explainPlate: some View {
        let colour = PhonePalette.part("explain")
        return VStack(alignment: .leading, spacing: 4) {
            if let key = explain.explained {
                Text(key.title.isEmpty ? "Key" : key.title).font(.headline).lineLimit(1)
                if let tap = key.tap {
                    explainRow("Tap", tap, colour)
                    if let hold = key.hold { explainRow("Hold", hold, colour) }
                    if let twice = key.twice { explainRow("Twice", twice, colour) }
                } else {
                    Text("The Mac did not say what this key does.")
                }
            } else {
                Text("Explain is on. Tap a key to read what it does — nothing is pressed. Tap Explain again to leave.")
            }
        }
        .font(.callout)
        .padding(12)
        .frame(maxWidth: 440, alignment: .leading)
        .background(PhonePalette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(colour, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("explainPlate")
    }

    private func explainRow(_ label: String, _ words: String, _ colour: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(label).fontWeight(.semibold).foregroundStyle(colour).frame(width: 62, alignment: .leading)
            Text(words).lineLimit(2).fixedSize(horizontal: false, vertical: true)
        }
    }

    /// On its side: the lock (the line to the Mac is private) by Settings and music; a tap says it in words.
    private var privateLock: some View {
        Button { showPrivate = true } label: {
            PhoneIcon(name: "iconLock", size: bigKeys ? 17 : (isPad ? 21 : 18))
                .foregroundStyle(PhonePalette.part("settings"))
                .frame(height: markHeight)
                .worded("Private", beside: bigKeys)
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
                .frame(height: markHeight)
                .worded("Mac", beside: bigKeys)
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
            .font(bigKeys ? .headline.weight(.bold) : isPad ? .largeTitle.weight(.bold) : (phoneSideways ? .title3.weight(.bold) : .title2.weight(.bold)))
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

    /// The room between two pages; nil = the usual one for this key gap.
    var between: CGFloat?
    /// The places to lay out (0.34); more than the pages = empty places of full size, so the favourites
    /// beside or under the pages stay where they are on a page group with one page. 0 = one per page.
    var slots = 0

    static let nameHeight: CGFloat = 16
    static func between(_ gap: CGFloat) -> CGFloat { max(14, gap * 2.5) }

    var body: some View {
        let names = link.tiles
        let count = max(names.count, slots)
        let across = max(1, min(across, count))
        let between = between ?? Self.between(gap)
        VStack(spacing: between) {
            ForEach(0..<(count + across - 1) / across, id: \.self) { row in
                HStack(alignment: .top, spacing: between) {
                    ForEach(0..<across, id: \.self) { column in
                        let page = row * across + column
                        if page < names.count {
                            VStack(alignment: .leading, spacing: gap) {
                                // The page the device is on: its name blue and bold, like its frame in the navigation picture (0.31).
                                Text(names[page].isEmpty ? "Page" : names[page])
                                    .font(.caption.weight(link.tileHere == page ? .bold : .semibold))
                                    .foregroundStyle(link.tileHere == page ? PhonePalette.part("screen") : Color.secondary)
                                    .accessibilityAddTraits(link.tileHere == page ? .isSelected : [])
                                    .lineLimit(1)
                                    // As wide as its keys, so a name is cut short only when it really is longer.
                                    .frame(width: 5 * side + 4 * gap, height: Self.nameHeight, alignment: .leading)
                                    .accessibilityIdentifier("pageName\(page)")
                                KeyGrid(link: link, side: side, gap: gap, corner: corner,
                                        first: page * StreamDeckProtocol.keyCount)
                            }
                        } else {
                            // An empty place: as large as a page where a page could stand, so nothing moves.
                            Color.clear.frame(width: 5 * side + 4 * gap,
                                              height: page < count ? Self.nameHeight + 3 * side + 3 * gap : 1)
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
    @EnvironmentObject private var explain: ExplainState
    /// Where this key stands on the screen (for the plate's side when it is held, not tapped).
    @State private var midY: CGFloat = 0
    @AppStorage("tapBuzz") private var tapBuzz = true
    @AppStorage("tapClick") private var tapClick = false

    /// Explain: the key's words go to the plate; nothing is pressed.
    private func read(atY y: CGFloat) {
        guard image != nil else { return }
        if tapBuzz { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        explain.explained = Explained(title: key?.title ?? "", tap: key?.tap, hold: key?.hold, twice: key?.twice,
                                      low: y < UIScreen.main.bounds.height / 2)
    }

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
        .overlay {
            if explain.explaining { shape.strokeBorder(PhonePalette.part("explain"), lineWidth: 2).allowsHitTesting(false) }
        }
        .background(GeometryReader { box in
            Color.clear.onAppear { midY = box.frame(in: .global).midY }
                .onChange(of: box.frame(in: .global).midY) { _, new in midY = new }
        })
        .onTapGesture(coordinateSpace: .global) { location in
            if explain.explaining { read(atY: location.y); return }
            guard image != nil else { return }   // empty places do nothing
            if tapBuzz { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            if tapClick { PhonePrefs.click() }
            pressed = true
            press()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { pressed = false }
        }
        .onLongPressGesture(minimumDuration: Navigator.longPress) {
            if explain.explaining { read(atY: midY); return }
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
    /// `beside`: in the thin line of the big-keys screen the word stands beside the mark, not under it.
    @ViewBuilder
    func worded(_ word: String, beside: Bool = false, tint: Color = PhonePalette.part("settings")) -> some View {
        if beside {
            HStack(spacing: 5) {
                self
                Text(word).font(.caption.weight(.semibold)).foregroundStyle(tint).lineLimit(1)
                    .fixedSize()
            }
            .frame(minHeight: 30)
            .padding(.horizontal, 5)
        } else {
            VStack(spacing: 1) {
                self
                Text(word).font(.caption2.weight(.semibold)).foregroundStyle(tint).lineLimit(1)
                    .fixedSize()
            }
            .frame(minWidth: 44, minHeight: 44)
        }
    }
}
