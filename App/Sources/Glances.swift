import AppKit
import ApplicationServices
import DeckMateCore
import EventKit

/// What the glance keys read from the Mac and from outside: the calendar, the weather, OmniFocus,
/// Spotify's cover and the Garmin board. Each part only looks while a key of its kind exists.
final class GlanceWatch {
    /// A glance key looks different now.
    var onChange: (() -> Void)?

    private(set) var battery: Int?
    private(set) var cover: CoverKeys.Now?
    var coverReady: Bool { cover.map { KeyArt.cover($0.track) != nil } ?? false }

    /// What the keys show right now, by their names in `GlanceKeys`.
    var glances: [String: Glance] {
        var all: [String: Glance] = [:]
        if nextOn { all[GlanceKeys.event] = eventGlance }
        if freeOn { all[GlanceKeys.free] = freeGlance }
        let now = Date()
        for town in clockTowns {
            guard let zone = zones[WeatherKeys.name(town)].flatMap(TimeZone.init(identifier:)) else { continue }
            all[GlanceKeys.clock(town)] = ClockKeys.glance(zone: zone, now: now, here: .current)
        }
        for town in sunTowns {
            if let glance = SunKeys.glance(sun[WeatherKeys.name(town)], now: now) { all[GlanceKeys.sun(town)] = glance }
        }
        for town in clockTowns where missingTowns.contains(WeatherKeys.name(town)) { all[GlanceKeys.clock(town)] = Glance(words: "Town not found") }
        for town in sunTowns where missingTowns.contains(WeatherKeys.name(town)) { all[GlanceKeys.sun(town)] = Glance(words: "Town not found") }
        for (number, glance) in garmin { all[GlanceKeys.garmin(number)] = glance }
        for (number, glance) in macGlances { all[GlanceKeys.mac(number)] = glance }
        for town in towns {
            let name = WeatherKeys.name(town)
            if let glance = WeatherKeys.glance(weather[name]) {
                all[GlanceKeys.weather(town)] = glance
            } else if missingTowns.contains(name) {
                all[GlanceKeys.weather(town)] = Glance(words: "Town not found")
            }
        }
        if dueOn {
            all[GlanceKeys.due] = ParagonKeys.dueGlance(snapshot: paragonShot, today: GlanceWatch.today, installed: paragonHere)
        }
        if paragonOn {
            for what in ParagonKeys.What.allCases {
                if let glance = ParagonKeys.glance(what, snapshot: paragonShot, today: GlanceWatch.today, installed: paragonHere) {
                    all[ParagonKeys.glanceName(what)] = glance
                }
            }
        }
        if let glance = batteryGlance { all[GlanceKeys.battery] = glance }
        return all
    }

    private struct Shown: Equatable {
        var glances: [String: Glance]
        var battery: Int?
        var cover: CoverKeys.Now?
        var coverReady: Bool
        var covers: Set<String>
    }

    private var shown: Shown?

    /// Tells the app when something a key shows has changed, and only then.
    private func tell() {
        let now = Shown(glances: glances, battery: battery, cover: cover, coverReady: coverReady, covers: coversReady)
        guard now != shown else { return }
        shown = now
        onChange?()
    }

    private let web: URLSession = {
        let setup = URLSessionConfiguration.ephemeral
        setup.timeoutIntervalForRequest = 15
        setup.httpCookieStorage = nil
        return URLSession(configuration: setup)
    }()

    private func fetch(_ url: URL?, _ done: @escaping (Data?) -> Void) {
        guard let url else { done(nil); return }
        web.dataTask(with: url) { data, answer, _ in
            let fine = (answer as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { done(fine ? data : nil) }
        }.resume()
    }

    private func every(_ seconds: TimeInterval, _ work: @escaping () -> Void) -> Timer {
        let timer = Timer(timeInterval: seconds, repeats: true) { _ in work() }
        timer.tolerance = seconds / 10
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    /// The setup changed: each part is switched on or off with the keys that need it.
    func watch(_ deck: Deck) {
        nextOn = deck.uses(.nextEvent)
        freeOn = deck.uses(.freeUntil)
        setCalendar(nextOn || freeOn)
        setWeather(deck.towns(of: .weather))
        setClocks(deck.towns(of: .worldClock), suns: deck.towns(of: .sunTimes))
        setMac(deck.macNumbers)
        setParagon(due: deck.uses(.dueToday), keys: deck.uses(.paragon))
        setPlaylists(deck.playlistLinks)
        setCover(deck.uses(.cover))
        setBattery(deck.uses(.bodyBattery) || deck.uses(.garmin))
        tell()
    }

    /// A glance key was pressed.
    func pressed(_ action: DeckAction) {
        switch action.type {
        case .nextEvent, .freeUntil: eventPressed(action)
        case .worldClock: open(app: ClockKeys.clockApp)
        case .sunTimes: open(app: WeatherKeys.weatherApp)
        case .macNow:
            let number = MacNowKeys.number(action.target)
            if number == .busy {
                open(app: number.opens)
            } else if let url = URL(string: number.opens) {
                NSWorkspace.shared.open(url)
            }
        case .weather:
            refreshWeather()
            open(app: WeatherKeys.weatherApp)
        case .dueToday, .paragon: paragonPressed(action)
        case .desk: Desk.arrange(DeskKeys.spots(of: action))
        default: break
        }
    }

    private func open(app: String) {
        guard let url = KeyArt.appURL(app) else { return }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }

    // MARK: Next event

    private var store = EKEventStore()
    private var calendarOn = false
    private var nextOn = false
    private var freeOn = false
    private var events: [EventKeys.Event] = []
    private var eventTimer: Timer?
    private var storeWatch: NSObjectProtocol?
    private let reading = DispatchQueue(label: "glance calendar")

    private var mayReadCalendar: Bool { EKEventStore.authorizationStatus(for: .event) == .fullAccess }

    private var eventGlance: Glance {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined: return Glance(words: EventKeys.askWords)
        case .fullAccess: return EventKeys.glance(EventKeys.next(events, now: Date()), now: Date(), calendar: .current)
        default: return Glance(words: EventKeys.refusedWords)
        }
    }

    private var freeGlance: Glance {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined: return Glance(words: EventKeys.askWords)
        case .fullAccess: return EventKeys.freeGlance(events, now: Date(), calendar: .current)
        default: return Glance(words: EventKeys.refusedWords)
        }
    }

    private func setCalendar(_ on: Bool) {
        guard on != calendarOn else { return }
        calendarOn = on
        eventTimer?.invalidate()
        eventTimer = nil
        if let storeWatch { NotificationCenter.default.removeObserver(storeWatch) }
        storeWatch = nil
        events = []
        guard on else { return }
        // The words on the key change with the clock ("12 min"), so it is read again every minute.
        eventTimer = every(60) { [weak self] in self?.readEvents() }
        storeWatch = NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: .main) { [weak self] _ in
            self?.readEvents()
        }
        readEvents()
    }

    /// Reads the events of the next seven days. It only ever reads.
    private func readEvents() {
        guard calendarOn, mayReadCalendar else { tell(); return }
        let store = store
        reading.async { [weak self] in
            let now = Date()
            let ahead = now.addingTimeInterval(Double(EventKeys.daysAhead) * 86_400)
            let found = store.events(matching: store.predicateForEvents(withStart: now.addingTimeInterval(-86_400), end: ahead, calendars: nil))
                .filter(\.isOn)
                .map { EventKeys.Event(title: $0.title ?? "", start: $0.startDate, end: $0.endDate, allDay: $0.isAllDay) }
            DispatchQueue.main.async {
                self?.events = found
                self?.tell()
            }
        }
    }

    /// The calendar was allowed from another key ("Join the meeting"): read it afresh.
    func calendarAllowed() {
        store = EKEventStore()
        readEvents()
    }

    /// The first press asks the Mac for the calendar (once); every later press opens the calendar app.
    private func eventPressed(_ action: DeckAction) {
        guard EKEventStore.authorizationStatus(for: .event) == .notDetermined else {
            open(app: action.target.isEmpty ? EventKeys.calendarApp : action.target)
            return
        }
        store.requestFullAccessToEvents { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.store = EKEventStore()
                self?.readEvents()
            }
        }
    }

    // MARK: Weather

    private var towns: [String] = []
    private var weather: [String: WeatherKeys.Now] = [:]
    private var missingTowns: Set<String> = []
    private var weatherTimer: Timer?
    private var weatherSoon: Timer?
    private static let placesKey = "weatherPlaces"

    private func setWeather(_ new: [String]) {
        guard new != towns else { return }
        towns = new
        let names = Set(new.map(WeatherKeys.name))
        weather = weather.filter { names.contains($0.key) }
        weatherTimer?.invalidate()
        weatherTimer = nil
        weatherSoon?.invalidate()
        weatherSoon = nil
        guard !new.isEmpty else { return }
        weatherTimer = every(Double(WeatherKeys.everyMinutes) * 60) { [weak self] in self?.refreshWeather() }
        // A town is still being typed: ask only once the typing has stopped for two seconds.
        let soon = Timer(timeInterval: 2, repeats: false) { [weak self] _ in self?.refreshWeather() }
        RunLoop.main.add(soon, forMode: .common)
        weatherSoon = soon
    }

    private func refreshWeather() {
        for town in towns {
            find(town) { [weak self] place in self?.readWeather(WeatherKeys.name(town), at: place) }
        }
    }

    private static let zonesKey = "townZones"
    /// The time zone of each town looked up so far, by the town's name.
    private var zones = UserDefaults.standard.dictionary(forKey: GlanceWatch.zonesKey) as? [String: String] ?? [:]

    /// A town's place and time zone. They are asked for once (only the town's name goes out) and kept.
    private func find(_ town: String, _ done: @escaping (WeatherKeys.Place) -> Void) {
        let name = WeatherKeys.name(town)
        let places = UserDefaults.standard.dictionary(forKey: GlanceWatch.placesKey) as? [String: String] ?? [:]
        if let place = places[name].flatMap(WeatherKeys.Place.init(text:)), zones[name] != nil {
            done(place)
            return
        }
        fetch(WeatherKeys.searchURL(town)) { [weak self] data in
            guard let self, let data else { return }
            guard let place = WeatherKeys.place(fromSearch: data) else {
                self.missingTowns.insert(name)
                self.tell()
                return
            }
            self.missingTowns.remove(name)
            var places = UserDefaults.standard.dictionary(forKey: GlanceWatch.placesKey) as? [String: String] ?? [:]
            places[name] = place.text
            UserDefaults.standard.set(places, forKey: GlanceWatch.placesKey)
            self.zones[name] = ClockKeys.zone(fromSearch: data) ?? TimeZone.current.identifier
            UserDefaults.standard.set(self.zones, forKey: GlanceWatch.zonesKey)
            done(place)
        }
    }

    // MARK: World clock, sunrise and sunset

    private var clockTowns: [String] = []
    private var sunTowns: [String] = []
    private var sun: [String: SunKeys.Times] = [:]
    private var clockTimer: Timer?
    private var sunTimer: Timer?
    private var townsSoon: Timer?

    private func setClocks(_ clocks: [String], suns: [String]) {
        guard clocks != clockTowns || suns != sunTowns else { return }
        clockTowns = clocks
        sunTowns = suns
        let names = Set(suns.map(WeatherKeys.name))
        sun = sun.filter { names.contains($0.key) }
        [clockTimer, sunTimer, townsSoon].forEach { $0?.invalidate() }
        clockTimer = nil
        sunTimer = nil
        townsSoon = nil
        guard !clocks.isEmpty || !suns.isEmpty else { return }
        // The time on these keys moves with the clock: looked at four times a minute, redrawn only on a change.
        clockTimer = every(15) { [weak self] in self?.tell() }
        if !suns.isEmpty { sunTimer = every(Double(SunKeys.everyHours) * 3600) { [weak self] in self?.refreshTowns() } }
        let soon = Timer(timeInterval: 2, repeats: false) { [weak self] _ in self?.refreshTowns() }
        RunLoop.main.add(soon, forMode: .common)
        townsSoon = soon
    }

    private func refreshTowns() {
        for town in clockTowns { find(town) { [weak self] _ in self?.tell() } }
        for town in sunTowns {
            let name = WeatherKeys.name(town)
            find(town) { [weak self] place in
                self?.fetch(SunKeys.url(place)) { data in
                    guard let self, let times = data.flatMap(SunKeys.times(fromAnswer:)),
                          self.sunTowns.contains(where: { WeatherKeys.name($0) == name }) else { return }
                    self.sun[name] = times
                    self.tell()
                }
            }
        }
    }

    // MARK: The Mac at a glance

    private var macNumbers: Set<MacNowKeys.Number> = []
    private var macGlances: [MacNowKeys.Number: Glance] = [:]
    private var macTimer: Timer?
    private var macLooks = 0
    private var ticks: (busy: UInt64, all: UInt64)?

    private func setMac(_ numbers: Set<MacNowKeys.Number>) {
        guard numbers != macNumbers else { return }
        macNumbers = numbers
        macTimer?.invalidate()
        macTimer = nil
        macGlances = [:]
        macLooks = 0
        ticks = nil
        guard !numbers.isEmpty else { return }
        macTimer = every(5) { [weak self] in self?.readMac() }
        readMac()
    }

    /// Battery and load every five seconds, the free space once a minute. Nothing here needs a permission.
    private func readMac() {
        if macNumbers.contains(.battery) {
            let power = MacWatch.battery()
            macGlances[.battery] = MacNowKeys.battery(percent: power?.percent, charging: power?.charging ?? false)
        }
        if macNumbers.contains(.space), macLooks % 12 == 0 {
            let room = try? URL(fileURLWithPath: "/").resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            macGlances[.space] = MacNowKeys.space(free: room?.volumeAvailableCapacityForImportantUsage, total: room?.volumeTotalCapacity.map(Int64.init))
        }
        if macNumbers.contains(.busy) {
            let now = GlanceWatch.processorTicks()
            if let now, let before = ticks { macGlances[.busy] = MacNowKeys.busy(MacNowKeys.load(before: before, after: now)) }
            ticks = now
        }
        macLooks += 1
        tell()
    }

    /// The clocks of the Mac's processors: the ticks spent working, and all ticks.
    private static func processorTicks() -> (busy: UInt64, all: UInt64)? {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let user = UInt64(info.cpu_ticks.0), system = UInt64(info.cpu_ticks.1), idle = UInt64(info.cpu_ticks.2), nice = UInt64(info.cpu_ticks.3)
        return (user + system + nice, user + system + idle + nice)
    }

    private func readWeather(_ name: String, at place: WeatherKeys.Place) {
        fetch(WeatherKeys.weatherURL(place)) { [weak self] data in
            guard let self, let now = data.flatMap(WeatherKeys.now(fromWeather:)),
                  self.towns.contains(where: { WeatherKeys.name($0) == name }) else { return }
            self.weather[name] = now
            self.tell()
        }
    }

    // MARK: PARAGON (the file it writes for its own widget)

    private var dueOn = false
    private var paragonOn = false
    private var paragonShot: ParagonKeys.Snapshot?
    private var paragonHere = false
    private var paragonTimer: Timer?

    /// PARAGON is on this Mac when something opens its links.
    static var paragonInstalled: Bool {
        URL(string: ParagonKeys.anyLink).flatMap { NSWorkspace.shared.urlForApplication(toOpen: $0) } != nil
    }

    static var today: ParagonKeys.Day {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return ParagonKeys.Day(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0)
    }

    /// PARAGON's file as it is now. Only read, never written; the notes themselves are never opened.
    static func paragonSnapshot() -> ParagonKeys.Snapshot? {
        let file = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(ParagonKeys.file)
        return (try? Data(contentsOf: file)).flatMap(ParagonKeys.snapshot(from:))
    }

    private func setParagon(due: Bool, keys: Bool) {
        dueOn = due
        paragonOn = keys
        let on = due || keys
        guard on != (paragonTimer != nil) else { return }
        paragonTimer?.invalidate()
        paragonTimer = nil
        paragonShot = nil
        guard on else { return }
        paragonTimer = every(ParagonKeys.everySeconds) { [weak self] in self?.readParagon() }
        readParagon()
    }

    private let paragonQueue = DispatchQueue(label: "paragon file", qos: .utility)
    private var paragonReading = false

    /// Reads PARAGON's file away from the main thread: the first time, the Mac asks whether AMS Deck
    /// Mate may read another app's data, and the read waits for that answer. The app must not wait with it.
    private func readParagon() {
        paragonHere = GlanceWatch.paragonInstalled
        guard !paragonReading else { return }
        paragonReading = true
        paragonQueue.async { [weak self] in
            let shot = GlanceWatch.paragonSnapshot()
            DispatchQueue.main.async {
                guard let self else { return }
                self.paragonReading = false
                guard self.paragonTimer != nil else { return }
                self.paragonShot = shot
                self.tell()
            }
        }
    }

    /// A PARAGON key was pressed.
    private func paragonPressed(_ action: DeckAction) {
        if action.type == .dueToday {
            openParagon(ParagonKeys.todayLink, inFront: true)
            return
        }
        let what = ParagonKeys.what(action.target)
        switch what {
        case .inbox, .next:
            openParagon(ParagonKeys.openLink(what, snapshot: paragonShot, today: GlanceWatch.today), inFront: true)
        case .copiedTask:
            guard let link = ParagonKeys.captureLink(text: ClipboardWatch.copiedText(), note: false) else {
                NSSound.beep()
                return
            }
            openParagon(link.absoluteString, inFront: false)
        case .note:
            let alert = NSAlert()
            alert.messageText = "Note for PARAGON"
            alert.informativeText = "It goes into PARAGON's Inbox as a note."
            let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            field.placeholderString = "Note"
            field.setAccessibilityIdentifier("paragonNote")
            alert.accessoryView = field
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.window.initialFirstResponder = field
            NSApp.activate(ignoringOtherApps: true)
            guard alert.runModal() == .alertFirstButtonReturn,
                  let link = ParagonKeys.captureLink(text: field.stringValue, note: true) else { return }
            openParagon(link.absoluteString, inFront: false)
        }
        // PARAGON writes its file anew after it took something in.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            guard let self, self.paragonTimer != nil else { return }
            self.readParagon()
        }
    }

    private func openParagon(_ link: String, inFront: Bool) {
        guard let url = URL(string: link), GlanceWatch.paragonInstalled else { NSSound.beep(); return }
        let how = NSWorkspace.OpenConfiguration()
        how.activates = inFront
        NSWorkspace.shared.open(url, configuration: how)
    }

    // MARK: Spotify playlist covers

    private var listCovers: [String] = []

    /// The covers of the playlist keys that are here, by their names.
    var coversReady: Set<String> { Set(listCovers.filter { KeyArt.cover($0) != nil }) }

    private func setPlaylists(_ links: [String]) {
        listCovers = links.compactMap(PlaylistKeys.coverName)
        for link in links {
            guard let name = PlaylistKeys.coverName(link), KeyArt.cover(name) == nil, asked.insert(name).inserted else { continue }
            // The picture comes from Spotify's open look-up, by the link only.
            fetch(PlaylistKeys.lookupURL(link)) { [weak self] data in
                guard let self, let address = data.flatMap(CoverKeys.pictureURL(fromLookup:)) else {
                    self?.asked.remove(name)       // no answer: asked again when the keys change
                    return
                }
                self.fetch(address) { data in
                    guard let data, let picture = NSImage(data: data), picture.isValid else { self.asked.remove(name); return }
                    KeyArt.keep(cover: picture, for: name)
                    self.tell()
                }
            }
        }
    }

    // MARK: Album cover (Spotify)

    private var coverWatch: NSObjectProtocol?
    private var asked: Set<String> = []

    private func setCover(_ on: Bool) {
        guard on != (coverWatch != nil) else { return }
        if let coverWatch { DistributedNotificationCenter.default().removeObserver(coverWatch) }
        coverWatch = nil
        cover = nil
        guard on else { return }
        // Spotify says to every app that listens what plays, whenever the song changes or playing
        // starts or stops. No permission is needed to hear it.
        coverWatch = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.spotify.client.PlaybackStateChanged"), object: nil, queue: .main) { [weak self] note in
            self?.spotifySaid(note.userInfo ?? [:])
        }
    }

    private func spotifySaid(_ said: [AnyHashable: Any]) {
        let state = said["Player State"] as? String ?? ""
        guard state != "Stopped" else {
            cover = nil
            tell()
            return
        }
        let track = CoverKeys.track(said["Track ID"] as? String) ?? ""
        cover = CoverKeys.Now(track: track, song: said["Name"] as? String ?? "", artist: said["Artist"] as? String ?? "",
                              playing: state == "Playing")
        tell()
        guard !track.isEmpty, KeyArt.cover(track) == nil, asked.insert(track).inserted else { return }
        if asked.count > 200 { asked = [track] }
        // The picture comes from Spotify's open look-up, by the track's name only.
        fetch(CoverKeys.lookupURL(track)) { [weak self] data in
            guard let self, let address = data.flatMap(CoverKeys.pictureURL(fromLookup:)) else { return }
            self.fetch(address) { data in
                guard let data, let picture = NSImage(data: data), picture.isValid else { return }
                KeyArt.keep(cover: picture, for: track)
                self.tell()
            }
        }
    }

    // MARK: Body Battery (the Garmin board on this Mac)

    private var batteryTimer: Timer?
    private var garmin: [GarminKeys.Number: Glance] = [:]
    private var batteryGlance: Glance?
    /// How many times in a row the board gave no answer. One miss keeps the numbers; from the second
    /// the keys say "Board off".
    private var boardMisses = 0
    /// True while the Garmin keys say "Board off": a press then starts the board.
    private(set) var boardOff = false

    private func setBattery(_ on: Bool) {
        guard on != (batteryTimer != nil) else { return }
        batteryTimer?.invalidate()
        batteryTimer = nil
        battery = nil
        batteryGlance = nil
        garmin = [:]
        boardMisses = 0
        boardOff = false
        guard on else { return }
        batteryTimer = every(Double(BatteryKeys.everyMinutes) * 60) { [weak self] in self?.readBattery() }
        readBattery()
    }

    private func readBattery() {
        fetch(URL(string: BatteryKeys.boardData)) { [weak self] data in
            guard let self, self.batteryTimer != nil else { return }
            if let data {
                self.boardMisses = 0
                self.boardOff = false
                let old = GarminKeys.oldSince(fromBoard: data, now: Date())
                let level = BatteryKeys.level(fromBoard: data)
                // A number that is hours old keeps showing, grey-blue, with the time it is from.
                self.battery = old == nil ? level : nil
                self.batteryGlance = BatteryKeys.glance(level, old: old)
                self.garmin = GarminKeys.glances(fromBoard: data)
            } else {
                self.boardMisses += 1
                guard self.boardMisses >= 2 else {
                    // One miss: the numbers stay, and the board is asked again in a minute.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
                        if self?.boardMisses == 1 { self?.readBattery() }
                    }
                    return
                }
                self.boardOff = true
                self.battery = nil
                self.batteryGlance = GarminKeys.offGlance
                self.garmin = Dictionary(uniqueKeysWithValues: GarminKeys.Number.allCases.map { ($0, GarminKeys.offGlance) })
            }
            self.tell()
        }
    }

    /// A Garmin key was pressed: the board's page, or, while the board is off, the board's own app,
    /// which starts it. The keys ask again a few seconds later.
    func openBoard() {
        if boardOff, let app = GlanceWatch.boardApp {
            NSWorkspace.shared.openApplication(at: app, configuration: NSWorkspace.OpenConfiguration())
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                if self?.batteryTimer != nil { self?.readBattery() }
            }
        } else if let url = URL(string: BatteryKeys.board) {
            NSWorkspace.shared.open(url)
        }
    }

    /// The board's own app on this Mac, when it is installed.
    static var boardApp: URL? {
        let name = "AMS Garmin Bridge Board.app"
        let folders = FileManager.default.urls(for: .applicationDirectory, in: [.userDomainMask, .localDomainMask])
        return folders.map { $0.appendingPathComponent(name) }.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    // MARK: Made-up values for pictures

    /// What the glance keys of the made-up setup show.
    static let sampleGlances: [String: Glance] = [
        GlanceKeys.event: Glance(big: "14:30", words: "Dentist"),
        GlanceKeys.weather("Lisbon"): Glance(big: "17°", words: "Partly cloudy"),
        GlanceKeys.due: Glance(big: "3", words: "1 overdue", tone: .raycast),
        ParagonKeys.glanceName(.inbox): Glance(big: "4", words: "Inbox", tone: .text),
        ParagonKeys.glanceName(.next): Glance(big: "today", words: "Book the flights"),
        GlanceKeys.battery: Glance(big: "62", words: BatteryKeys.words),
        GlanceKeys.garmin(.steps): Glance(big: "8 412", words: "Steps today"),
        GlanceKeys.garmin(.sleep): Glance(big: "7:24", words: "Good"),
        GlanceKeys.garmin(.pulse): Glance(big: "52", words: "+6 over usual"),
        GlanceKeys.garmin(.stress): Glance(big: "18", words: "Resting", tone: .media),
        GlanceKeys.garmin(.workouts): Glance(big: "5", words: "7 days · 6 h"),
        GlanceKeys.mac(.battery): Glance(big: "73%", words: "Mac battery", tone: .media),
        GlanceKeys.mac(.space): Glance(big: "212 GB", words: "Free space"),
        GlanceKeys.mac(.busy): Glance(big: "85%", words: "Mac very busy", tone: .raycast),
        GlanceKeys.clock("Tokyo"): Glance(big: "22:05"),
        GlanceKeys.sun("Lisbon"): Glance(big: "17:21", words: "Sunset"),
        GlanceKeys.free: Glance(big: "1 h 20", words: "Free until 14:30", tone: .media),
    ]
    static let sampleCover = CoverKeys.Now(track: "sample", song: "Morning Light", artist: "The Samples", playing: true)

    /// A made-up cover, drawn here: no real record's picture goes into the check pictures.
    static func keepSampleCover() {
        let side: CGFloat = 300
        let picture = NSImage(size: NSSize(width: side, height: side))
        picture.lockFocus()
        NSGradient(starting: NSColor(red: 0.96, green: 0.55, blue: 0.25, alpha: 1),
                   ending: NSColor(red: 0.45, green: 0.20, blue: 0.55, alpha: 1))?
            .draw(in: NSRect(x: 0, y: 0, width: side, height: side), angle: 60)
        NSColor.white.withAlphaComponent(0.85).setFill()
        NSBezierPath(ovalIn: NSRect(x: 95, y: 120, width: 110, height: 110)).fill()
        picture.unlockFocus()
        KeyArt.keep(cover: picture, for: sampleCover.track)
    }
}

/// The desk key: which windows are where right now, and putting them back.
enum Desk {
    /// The front window of every app with a window on screen, front to back, at most eight apps.
    /// Reading where windows are needs no permission (their names are never read).
    static func now() -> [DeskKeys.Spot] {
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        var apps: [pid_t: String] = [:]
        var windows: [DeskKeys.Spot] = []
        for window in list {
            guard (window[kCGWindowLayer as String] as? Int) == 0,
                  let pid = window[kCGWindowOwnerPID as String] as? pid_t,
                  let bounds = window[kCGWindowBounds as String] as? [String: Any],
                  let frame = CGRect(dictionaryRepresentation: bounds as CFDictionary) else { continue }
            if apps[pid] == nil {
                let app = NSRunningApplication(processIdentifier: pid)
                apps[pid] = app?.activationPolicy == .regular ? app?.bundleIdentifier ?? "" : ""
            }
            guard let app = apps[pid], !app.isEmpty else { continue }
            windows.append(DeskKeys.Spot(app: app, x: Int(frame.minX), y: Int(frame.minY),
                                         width: Int(frame.width), height: Int(frame.height)))
        }
        return DeskKeys.capture(windows, skip: AppInfo.bundleID)
    }

    /// Opens every app of the desk and puts its front window in its place. The app at the top of
    /// the list ends up in front. Moving another app's window needs the Mac's Accessibility yes.
    static func arrange(_ spots: [DeskKeys.Spot]) {
        guard ActionRunner.mayPressKeys else { ActionRunner.askToPressKeys(); return }
        for (index, spot) in spots.reversed().enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {
                guard let url = KeyArt.appURL(spot.app) else { return }
                NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { app, _ in
                    guard let app else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { place(app.processIdentifier, spot, tries: 16) }
                }
            }
        }
    }

    /// Puts the app's front window in its place; an app that is still opening is tried again for about eight seconds.
    private static func place(_ pid: pid_t, _ spot: DeskKeys.Spot, tries: Int) {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 1)
        var found: CFTypeRef?
        let windows = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &found) == .success
            ? (found as? [AXUIElement]) ?? [] : []
        let window = windows.first { element in
            var role: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &role)
            return role as? String == kAXStandardWindowSubrole as String
        } ?? windows.first
        guard let window else {
            if tries > 1 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { place(pid, spot, tries: tries - 1) } }
            return
        }
        AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanFalse)
        var point = CGPoint(x: spot.x, y: spot.y)
        var size = CGSize(width: spot.width, height: spot.height)
        guard let position = AXValueCreate(.cgPoint, &point), let extent = AXValueCreate(.cgSize, &size) else { return }
        // Place, size, place again: a window that was too large for where it stood is first moved, then fits.
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, extent)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
    }
}
