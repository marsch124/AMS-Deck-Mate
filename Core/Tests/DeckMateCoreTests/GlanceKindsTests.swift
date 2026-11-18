import XCTest
@testable import DeckMateCore

/// The 0.11 rules: one small data test each.
final class GlanceKindsTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return c
    }
    /// Monday 16 Nov 2026, Stockholm.
    private func at(_ day: Int, _ hour: Int, _ minute: Int = 0, second: Int = 0) -> Date {
        cal.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute, second: second))!
    }
    private func ev(_ title: String, _ start: Date, minutes: Double = 60, allDay: Bool = false) -> EventKeys.Event {
        EventKeys.Event(title: title, start: start, end: start.addingTimeInterval(minutes * 60), allDay: allDay)
    }
    private func data(_ json: String) -> Data { Data(json.utf8) }

    func testNextEventSkipsAllDayAndEnded() {
        let now = at(16, 10)
        let list = [ev("Past", at(16, 8)), ev("All day", at(16, 0), minutes: 1440, allDay: true),
                    ev("Later", at(16, 15)), ev("Going", at(16, 9, 30)), ev("Soon", at(16, 11))]
        XCTAssertEqual(EventKeys.next(list, now: now)?.title, "Going", "one going on counts, earliest start wins")
        XCTAssertNil(EventKeys.next([ev("Past", at(16, 8)), ev("All", at(16, 12), allDay: true)], now: now))
    }

    func testEventGlanceNowMinutesAndTimes() {
        let now = at(16, 10)
        XCTAssertEqual(EventKeys.glance(ev("Talk", at(16, 9)), now: now, calendar: cal), Glance(big: "Now", words: "Talk"))
        XCTAssertEqual(EventKeys.glance(ev("Talk", at(16, 10, 11, second: 1)), now: now, calendar: cal).big, "12 min")
        XCTAssertEqual(EventKeys.glance(ev("Talk", at(16, 14, 30)), now: now, calendar: cal), Glance(big: "14:30", words: "Talk"))
    }

    func testEventGlanceOtherDayNothingAndNoTitle() {
        let now = at(16, 10)
        XCTAssertEqual(EventKeys.glance(ev("Dentist", at(18, 9, 5)), now: now, calendar: cal),
                       Glance(big: "Wed", words: "09:05 Dentist"))
        XCTAssertEqual(EventKeys.glance(nil, now: now, calendar: cal), Glance(big: "–", words: "No events"))
        XCTAssertEqual(EventKeys.glance(ev("  ", at(16, 14)), now: now, calendar: cal).words, "Event")
    }

    func testWeatherNameAndSky() {
        XCTAssertEqual(WeatherKeys.name("  Norrköping \n"), "norrköping")
        XCTAssertEqual(WeatherKeys.sky(0), "Clear")
        XCTAssertEqual(WeatherKeys.sky(3), "Cloudy")
        XCTAssertEqual(WeatherKeys.sky(63), "Rain")
        XCTAssertEqual(WeatherKeys.sky(95), "Thunder")
        XCTAssertEqual(WeatherKeys.sky(1234), "Weather")
    }

    func testDegreesRoundAndNeverMinusZero() {
        XCTAssertEqual(WeatherKeys.degrees(3.4), "3°")
        XCTAssertEqual(WeatherKeys.degrees(-4.2), "-4°")
        XCTAssertEqual(WeatherKeys.degrees(-0.2), "0°")
    }

    func testWeatherAnswersAreRead() {
        let place = WeatherKeys.place(fromSearch: data(#"{"results":[{"name":"Norrköping","latitude":58.59,"longitude":16.18}]}"#))
        XCTAssertEqual(place, WeatherKeys.Place(latitude: 58.59, longitude: 16.18))
        XCTAssertNil(WeatherKeys.place(fromSearch: data(#"{"generationtime_ms":0.2}"#)))
        XCTAssertNil(WeatherKeys.place(fromSearch: data("junk")))
        let now = WeatherKeys.now(fromWeather: data(#"{"current":{"temperature_2m":-3.5,"weather_code":71}}"#))
        XCTAssertEqual(now, WeatherKeys.Now(temperature: -3.5, code: 71))
        XCTAssertNil(WeatherKeys.now(fromWeather: data(#"{"current":{}}"#)))
        XCTAssertNil(WeatherKeys.now(fromWeather: data("junk")))
    }

    func testPlaceTextRoundTripAndSearchCarriesOnlyTheTown() {
        let place = WeatherKeys.Place(latitude: 58.59, longitude: -16.18)
        XCTAssertEqual(WeatherKeys.Place(text: place.text), place)
        XCTAssertNil(WeatherKeys.Place(text: "95,16"))
        XCTAssertNil(WeatherKeys.Place(text: "junk"))
        let url = WeatherKeys.searchURL(" Norrköping ")!
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
        XCTAssertEqual(items.map(\.name).sorted(), ["count", "name"])
        XCTAssertEqual(items.first { $0.name == "name" }?.value, "Norrköping")
    }

    func testBatteryLevelFromBoard() {
        XCTAssertEqual(BatteryKeys.level(fromBoard: data(#"{"today":{"bodyBattery":{"latest":62}}}"#)), 62)
        XCTAssertNil(BatteryKeys.level(fromBoard: data(#"{"today":{"bodyBattery":{"latest":140}}}"#)))
        XCTAssertNil(BatteryKeys.level(fromBoard: data(#"{"today":{}}"#)))
    }

    func testBatteryColour() {
        XCTAssertEqual(BatteryKeys.kind(50), .media)
        XCTAssertEqual(BatteryKeys.kind(49), .web)
        XCTAssertEqual(BatteryKeys.kind(25), .web)
        XCTAssertEqual(BatteryKeys.kind(24), .text)
        XCTAssertEqual(BatteryKeys.kind(nil), .move)
    }

    func testCoverTrackAndPicture() {
        XCTAssertEqual(CoverKeys.track("spotify:track:4uLU6hMCjMI75M1A2tKUQC"), "4uLU6hMCjMI75M1A2tKUQC")
        XCTAssertNil(CoverKeys.track("spotify:episode:4uLU6hMCjMI75M1A2tKUQC"))
        XCTAssertNil(CoverKeys.track("spotify:track:abc/../x"))
        XCTAssertNil(CoverKeys.track(nil))
        XCTAssertEqual(CoverKeys.pictureURL(fromLookup: data(#"{"thumbnail_url":"https://i.scdn.co/a.jpg"}"#))?.absoluteString,
                       "https://i.scdn.co/a.jpg")
        XCTAssertNil(CoverKeys.pictureURL(fromLookup: data(#"{"thumbnail_url":"http://i.scdn.co/a.jpg"}"#)))
    }

    func testDeskStepSpotRoundTripAndBrokenName() {
        let spot = DeskKeys.Spot(app: "com.apple.mail", x: -20, y: 30, width: 1200, height: 800)
        XCTAssertEqual(DeskKeys.spot(DeskKeys.step(spot)), spot)
        XCTAssertNil(DeskKeys.spot(DeckAction(type: .app, target: "com.apple.mail", name: "1,2,x,4")))
        XCTAssertNil(DeskKeys.spot(DeckAction(type: .app, target: "com.apple.mail", name: "1,2,3")))
    }

    func testDeskCaptureTakesFrontWindowPerApp() {
        func w(_ app: String, _ width: Int = 800, _ height: Int = 600) -> DeskKeys.Spot {
            DeskKeys.Spot(app: app, x: 0, y: 0, width: width, height: height)
        }
        let first = DeskKeys.Spot(app: "a", x: 1, y: 1, width: 800, height: 600)
        let found = DeskKeys.capture([first, w("a"), w("me"), w("small", 100, 100), w("b")], skip: "me")
        XCTAssertEqual(found.map(\.app), ["a", "b"])
        XCTAssertEqual(found.first, first)
        let many = (1...12).map { w("app\($0)") }
        XCTAssertEqual(DeskKeys.capture(many, skip: "me").count, DeskKeys.most)
    }

    func testWeatherTownsEachOnceAlsoFromLongPress() {
        let keys: [Int: DeckKey] = [
            1: DeckKey(action: DeckAction(type: .weather, target: "Norrköping")),
            2: DeckKey(action: DeckAction(type: .weather, target: " norrköping ")),
            3: DeckKey(action: .none, held: DeckAction(type: .weather, target: "Malaga")),
            4: DeckKey(action: DeckAction(type: .weather, target: "  "))]
        let profile = DeckProfile(name: "Main", pages: [DeckPage(name: "P", keys: keys)])
        let towns = Deck(profiles: [profile], defaultProfile: profile.id).weatherTowns
        XCTAssertEqual(towns.count, 2)
        XCTAssertEqual(Set(towns.map(WeatherKeys.name)), ["norrköping", "malaga"])
    }

    func testWeatherKeyShowsItself() {
        let town = "Norrköping"
        let glance = Glance(big: "3°", words: "Cloudy")
        let live = LiveKeys(glances: [GlanceKeys.weather(town): glance])
        let key = DeckKey(action: DeckAction(type: .weather, target: town)).resolving(live)
        XCTAssertEqual(key.icon, "text:3°")
        XCTAssertEqual(key.title, "Cloudy")
        let own = DeckKey(title: "Home", action: DeckAction(type: .weather, target: town)).resolving(live)
        XCTAssertEqual(own.title, "Home")
        XCTAssertEqual(own.icon, "text:3°")
        XCTAssertEqual(DeckKey(action: DeckAction(type: .weather)).resolving(live).title, "Set a town")
    }

    func testBatteryKeyColourComesFromItsLevel() {
        let key = DeckKey(action: DeckAction(type: .bodyBattery))
        XCTAssertEqual(key.resolving(LiveKeys(battery: 80)).action.kind, .media)
        XCTAssertEqual(key.resolving(LiveKeys(battery: 10)).action.kind, .text)
        XCTAssertEqual(key.resolving(LiveKeys()).action.kind, .move)
    }

    func testCoverKeyShowsTheCoverOnlyWhenReady() {
        let now = CoverKeys.Now(track: "abc123", song: "Song", artist: "Band", playing: true)
        let key = DeckKey(icon: "music", action: DeckAction(type: .cover))
        let ready = key.resolving(LiveKeys(cover: now, coverReady: true))
        XCTAssertEqual(ready.icon, "cover:abc123")
        XCTAssertEqual(ready.title, "Song")
        let notYet = key.resolving(LiveKeys(cover: now, coverReady: false))
        XCTAssertEqual(notYet.icon, "music", "keeps drawing")
        XCTAssertEqual(key.resolving(LiveKeys()).title, "Nothing playing")
    }

    func testCoverAndBatteryActionsResolve() {
        let play = DeckAction(type: .cover).resolving(LiveKeys())
        XCTAssertEqual(play.type, .media)
        XCTAssertEqual(play.target, MediaKey.playPause.rawValue)
        let board = DeckAction(type: .bodyBattery).resolving(LiveKeys())
        XCTAssertEqual(board.type, .link)
        XCTAssertEqual(board.target, BatteryKeys.board)
    }

    func testNewKindsHaveColoursAndIcons() {
        XCTAssertEqual(DeckAction(type: .weather).kind, .web)
        XCTAssertEqual(DeckAction(type: .cover).kind, .media)
        XCTAssertEqual(DeckAction(type: .desk).kind, .app)
        XCTAssertEqual(DeckAction(type: .weather).autoIcon, "sun")
        XCTAssertEqual(DeckAction(type: .bodyBattery).autoIcon, "battery")
    }

    func testBrokenGlanceAndDeskKeysSayWhy() {
        let profile = DeckProfile(name: "Main", pages: [DeckPage(name: "P")])
        let deck = Deck(profiles: [profile], defaultProfile: profile.id)
        let world = KeyWorld(appExists: { _ in true }, fileExists: { _ in true }, raycastExtension: { _, _ in true })
        func check(_ action: DeckAction) -> String? {
            KeyCheck.problem(DeckKey(action: action), in: profile, deck: deck, world: world)
        }
        XCTAssertEqual(check(DeckAction(type: .weather)), "No town yet")
        XCTAssertNil(check(DeckAction(type: .weather, target: "Malaga")))
        XCTAssertEqual(check(DeckAction(type: .desk)), "No windows taken yet")
        let spot = DeskKeys.Spot(app: "com.apple.mail", x: 0, y: 0, width: 800, height: 600)
        XCTAssertNil(check(DeckAction(type: .desk, steps: [DeskKeys.step(spot)])))
    }

    func testDeskDoneWords() {
        let spots = (1...2).map { DeskKeys.step(DeskKeys.Spot(app: "a\($0)", x: 0, y: 0, width: 800, height: 600)) }
        XCTAssertEqual(ActionWords.done([DeckAction(type: .desk, steps: spots)], appName: { $0 }), "Set up the desk: 2 apps")
        XCTAssertEqual(ActionWords.done([DeckAction(type: .desk)], appName: { $0 }), "No windows taken yet")
    }

    // 0.11.1: a long press of a weather key asks for another town.

    func testLongPressOfWeatherKeyAsksForItsTown() {
        let key = DeckKey(action: DeckAction(type: .weather, target: "Lisbon"))
        XCTAssertTrue(key.actsOnHold)
        XCTAssertEqual(key.action(long: true), DeckAction(type: .weatherTown, target: key.id.uuidString))
        XCTAssertEqual(key.action(long: false).type, .weather)
        // A long press of its own wins.
        let own = DeckKey(action: DeckAction(type: .weather, target: "Lisbon"), held: DeckAction(type: .back))
        XCTAssertEqual(own.action(long: true).type, .back)
        XCTAssertFalse(DeckKey(action: DeckAction(type: .dueToday)).actsOnHold)
    }

    func testSetTownChangesOnlyThatWeatherKey() {
        let weather = DeckKey(action: DeckAction(type: .weather, target: "Lisbon"))
        let other = DeckKey(action: DeckAction(type: .weather, target: "Oslo"))
        let link = DeckKey(action: DeckAction(type: .link, target: "https://example.com"))
        var deck = Deck(profiles: [DeckProfile(name: "A", pages: [DeckPage(name: "1", keys: [0: weather, 1: other, 2: link])])])
        deck.setTown("  Porto ", forKey: weather.id)
        deck.setTown("Nowhere", forKey: link.id)
        XCTAssertEqual(deck.town(ofKey: weather.id), "Porto")
        XCTAssertEqual(deck.town(ofKey: other.id), "Oslo")
        XCTAssertNil(deck.town(ofKey: link.id))
        XCTAssertEqual(deck.profiles[0].pages[0].keys[2]?.action.target, "https://example.com")
    }

    func testRememberedTownsNewestFirstEachOnce() {
        XCTAssertEqual(WeatherKeys.remembered(["Lisbon", "Oslo"], adding: " oslo "), ["oslo", "Lisbon"])
        XCTAssertEqual(WeatherKeys.remembered(["A", "B", "C", "D", "E", "F"], adding: "G"), ["G", "A", "B", "C", "D", "E"])
        XCTAssertEqual(WeatherKeys.remembered(["Lisbon"], adding: "  "), ["Lisbon"])
    }
}
