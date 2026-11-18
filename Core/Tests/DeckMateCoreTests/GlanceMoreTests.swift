import XCTest
@testable import DeckMateCore

/// The 0.12 rules: one small data test each.
final class GlanceMoreTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return c
    }
    private func at(_ day: Int, _ hour: Int, _ minute: Int = 0, second: Int = 0) -> Date {
        cal.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute, second: second))!
    }
    private func ev(_ start: Date, minutes: Double = 60, allDay: Bool = false) -> EventKeys.Event {
        EventKeys.Event(title: "E", start: start, end: start.addingTimeInterval(minutes * 60), allDay: allDay)
    }
    private func data(_ json: String) -> Data { Data(json.utf8) }
    private let gb: Int64 = 1_000_000_000

    // MARK: Garmin

    func testGarminCountHoursStress() {
        XCTAssertEqual(GarminKeys.count(999), "999")
        XCTAssertEqual(GarminKeys.count(1000), "1 000")
        XCTAssertEqual(GarminKeys.count(12345), "12 345")
        XCTAssertEqual(GarminKeys.hours(seconds: 26640), "7:24")
        XCTAssertEqual(GarminKeys.hours(seconds: 3660), "1:01")
        XCTAssertEqual(GarminKeys.stress(25).tone, .media)
        XCTAssertEqual(GarminKeys.stress(26).tone, .web)
        XCTAssertEqual(GarminKeys.stress(50).tone, .web)
        XCTAssertEqual(GarminKeys.stress(51).tone, .web)
        XCTAssertEqual(GarminKeys.stress(75).tone, .web)
        XCTAssertEqual(GarminKeys.stress(76).tone, .text)
    }

    func testGarminNumberFallsBackToSteps() {
        XCTAssertEqual(GarminKeys.number("sleep"), .sleep)
        XCTAssertEqual(GarminKeys.number("nonsense"), .steps)
        XCTAssertEqual(GarminKeys.number(""), .steps)
    }

    private func board(pulse: Int, avg: Int, steps: Int = 8000, goal: Int = 10000, sleep: String = #"{"recorded":true,"seconds":26640,"qualifier":"GOOD"}"#) -> Data {
        data("""
        {"today":{"steps":\(steps),"stepGoal":\(goal),"restingHr":\(pulse),"stressAvg":30},
         "sleep":\(sleep),
         "restingTrend":{"avg7":[{"bpm":\(avg + 1)},{"bpm":\(avg)}]},
         "recentWorkouts":{"last7":{"count":7,"seconds":54000}}}
        """)
    }

    func testBoardGlances() {
        let all = GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55))
        XCTAssertEqual(all[.steps], Glance(big: "8 000", words: "Steps today", tone: nil))
        XCTAssertEqual(all[.sleep], Glance(big: "7:24", words: "Good"))
        XCTAssertEqual(all[.stress], Glance(big: "30", words: "Low stress", tone: .web))
        XCTAssertEqual(all[.workouts], Glance(big: "7", words: "7 days · 15 h"))
        XCTAssertEqual(all[.pulse], Glance(big: "55", words: "Resting pulse", tone: nil))
    }

    func testBoardStepsGoalAndSleepMissing() {
        XCTAssertEqual(GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, steps: 10000))[.steps]?.tone, .media)
        XCTAssertEqual(GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, steps: 12000))[.steps]?.tone, .media)
        let none = GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, sleep: #"{"recorded":false}"#))
        XCTAssertEqual(none[.sleep]?.big, "–")
    }

    func testBoardPulseAgainstUsual() {
        let amber = GarminKeys.glances(fromBoard: board(pulse: 60, avg: 55))[.pulse]
        XCTAssertEqual(amber?.tone, nil)
        XCTAssertEqual(amber?.words, "+5 over usual")
        XCTAssertEqual(GarminKeys.glances(fromBoard: board(pulse: 63, avg: 55))[.pulse]?.tone, .text)
        XCTAssertNil(GarminKeys.glances(fromBoard: board(pulse: 58, avg: 55))[.pulse]?.tone)
    }

    func testBoardJunkIsEmpty() {
        XCTAssertTrue(GarminKeys.glances(fromBoard: data("nope")).isEmpty)
        XCTAssertTrue(GarminKeys.glances(fromBoard: data("{}")).isEmpty)
    }

    // MARK: Mac

    func testMacBattery() {
        XCTAssertEqual(MacNowKeys.battery(percent: nil, charging: false), Glance(words: "No battery"))
        XCTAssertEqual(MacNowKeys.battery(percent: 40, charging: false).tone, .media)
        XCTAssertEqual(MacNowKeys.battery(percent: 39, charging: false).tone, .text)
        XCTAssertEqual(MacNowKeys.battery(percent: 20, charging: false).tone, .text)
        XCTAssertEqual(MacNowKeys.battery(percent: 19, charging: false).tone, .raycast)
        XCTAssertEqual(MacNowKeys.battery(percent: 50, charging: true).words, "Charging")
        XCTAssertEqual(MacNowKeys.battery(percent: 50, charging: false).words, "Mac battery")
    }

    func testMacRoomAndSpace() {
        XCTAssertEqual(MacNowKeys.room(212 * gb), "212 GB")
        XCTAssertEqual(MacNowKeys.room(8_400_000_000), "8.4 GB")
        XCTAssertEqual(MacNowKeys.room(1_200 * gb), "1.2 TB")
        XCTAssertEqual(MacNowKeys.space(free: 9 * gb, total: 500 * gb).tone, .raycast)
        XCTAssertEqual(MacNowKeys.space(free: 20 * gb, total: 100 * gb).tone, .text)
        XCTAssertNil(MacNowKeys.space(free: 200 * gb, total: 500 * gb).tone)
        XCTAssertEqual(MacNowKeys.space(free: 80 * gb, total: 2_000 * gb).tone, .raycast, "4 % of a big disk")
        XCTAssertEqual(MacNowKeys.space(free: nil, total: nil), Glance(words: "Free space"))
    }

    func testMacLoadAndBusy() {
        XCTAssertEqual(MacNowKeys.load(before: (busy: 100, all: 1000), after: (busy: 400, all: 2000))!, 0.3, accuracy: 0.0001)
        XCTAssertNil(MacNowKeys.load(before: (busy: 100, all: 1000), after: (busy: 200, all: 1000)))
        XCTAssertEqual(MacNowKeys.busy(0.32).big, "30%")
        XCTAssertEqual(MacNowKeys.busy(0.32).words, "Mac calm")
        XCTAssertNil(MacNowKeys.busy(0.32).tone)
        XCTAssertEqual(MacNowKeys.busy(0.60), Glance(big: "60%", words: "Mac busy", tone: .text))
        XCTAssertEqual(MacNowKeys.busy(0.59).big, "60%")
        XCTAssertEqual(MacNowKeys.busy(0.85), Glance(big: "85%", words: "Mac very busy", tone: .raycast))
        XCTAssertEqual(MacNowKeys.busy(nil), Glance(words: "Mac busy light"))
    }

    // MARK: Clock and sun

    func testWorldClockGlance() {
        let here = TimeZone(identifier: "Europe/Stockholm")!
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        // 14:30 in Stockholm = 22:30 in Tokyo, same day.
        XCTAssertEqual(ClockKeys.glance(zone: tokyo, now: at(16, 14, 30), here: here), Glance(big: "22:30", words: ""))
        // 20:00 in Stockholm = 04:00 next day in Tokyo.
        XCTAssertEqual(ClockKeys.glance(zone: tokyo, now: at(16, 20), here: here), Glance(big: "04:00", words: "tomorrow"))
        XCTAssertEqual(ClockKeys.glance(zone: here, now: at(16, 20), here: tokyo).words, "yesterday")
    }

    func testClockZoneFromSearch() {
        XCTAssertEqual(ClockKeys.zone(fromSearch: data(#"{"results":[{"timezone":"Asia/Tokyo"}]}"#)), "Asia/Tokyo")
        XCTAssertNil(ClockKeys.zone(fromSearch: data(#"{"results":[{"timezone":"Mars/Base"}]}"#)))
        XCTAssertNil(ClockKeys.zone(fromSearch: data("junk")))
    }

    private let sunAnswer = #"{"utc_offset_seconds":3600,"daily":{"sunrise":["2026-11-18T07:30","2026-11-19T07:32"],"sunset":["2026-11-18T15:40","2026-11-19T15:38"]}}"#

    func testSunTimesFromAnswer() {
        let times = SunKeys.times(fromAnswer: data(sunAnswer))
        XCTAssertEqual(times, SunKeys.Times(sunrise: ["2026-11-18T07:30", "2026-11-19T07:32"],
                                             sunset: ["2026-11-18T15:40", "2026-11-19T15:38"], offset: 3600))
        XCTAssertNil(SunKeys.times(fromAnswer: data(#"{"daily":{}}"#)))
    }

    func testSunGlancePicksNext() {
        let times = SunKeys.times(fromAnswer: data(sunAnswer))
        // The town's clock is one hour ahead of UTC, as Stockholm's is in November.
        XCTAssertEqual(SunKeys.glance(times, now: at(18, 6)), Glance(big: "07:30", words: "Sunrise"))
        XCTAssertEqual(SunKeys.glance(times, now: at(18, 12)), Glance(big: "15:40", words: "Sunset"))
        XCTAssertEqual(SunKeys.glance(times, now: at(18, 17)), Glance(big: "07:32", words: "Sunrise"))
        XCTAssertNil(SunKeys.glance(times, now: at(19, 17)))
        XCTAssertNil(SunKeys.glance(nil, now: at(18, 6)))
    }

    // MARK: Free until

    func testEventLength() {
        XCTAssertEqual(EventKeys.length(minutes: 45), "45 min")
        XCTAssertEqual(EventKeys.length(minutes: 80), "1 h 20")
        XCTAssertEqual(EventKeys.length(minutes: 125), "2 h 05")
    }

    func testFreeGlanceBusyAndFree() {
        let now = at(16, 10, 45)
        let busy = EventKeys.freeGlance([ev(at(16, 10)), ev(at(16, 10, 30), minutes: 90), ev(at(16, 9), minutes: 30)], now: now, calendar: cal)
        XCTAssertEqual(busy, Glance(big: "Busy", words: "until 12:00", tone: .raycast))
        let free = EventKeys.freeGlance([ev(at(16, 14))], now: at(16, 10, second: 30), calendar: cal)
        XCTAssertEqual(free, Glance(big: "3 h 59", words: "Free until 14:00", tone: .media))
    }

    func testFreeGlanceIgnoresAllDayAndTomorrow() {
        let rest = Glance(big: "Free", words: "Rest of the day", tone: .media)
        let now = at(16, 10)
        XCTAssertEqual(EventKeys.freeGlance([], now: now, calendar: cal), rest)
        XCTAssertEqual(EventKeys.freeGlance([ev(at(16, 0), minutes: 1440, allDay: true)], now: now, calendar: cal), rest)
        XCTAssertEqual(EventKeys.freeGlance([ev(at(17, 9)), ev(at(16, 8))], now: now, calendar: cal), rest)
    }

    // MARK: Towns and keys

    private func deckWith(_ actions: [DeckAction]) -> Deck {
        var keys: [Int: DeckKey] = [:]
        for (index, action) in actions.enumerated() { keys[index] = DeckKey(action: action) }
        let profile = DeckProfile(name: "Main", pages: [DeckPage(name: "P", keys: keys)])
        return Deck(profiles: [profile], defaultProfile: profile.id)
    }

    func testDeckTownsAndMacNumbers() {
        let deck = deckWith([DeckAction(type: .weather, target: "Malaga"), DeckAction(type: .weather, target: " malaga "),
                             DeckAction(type: .worldClock, target: "Tokyo"), DeckAction(type: .sunTimes, target: "Malaga"),
                             DeckAction(type: .weather, target: "  "),
                             DeckAction(type: .macNow, target: "space"), DeckAction(type: .macNow, target: "junk")])
        XCTAssertEqual(deck.towns(of: .weather).map { WeatherKeys.name($0) }, ["malaga"], "once, however it is written")
        XCTAssertEqual(deck.towns(of: .worldClock), ["Tokyo"])
        XCTAssertEqual(Set(deck.allTowns.map { WeatherKeys.name($0) }), ["malaga", "tokyo"])
        XCTAssertEqual(deck.allTowns.count, 2)
        XCTAssertEqual(deck.macNumbers, [.space, .battery])
    }

    func testResolvingColoursAndTitles() {
        let live = LiveKeys(glances: [GlanceKeys.mac(.battery): MacNowKeys.battery(percent: 15, charging: false)])
        let battery = DeckKey(action: DeckAction(type: .macNow, target: "battery")).resolving(live)
        XCTAssertEqual(battery.action.kind, .raycast)
        XCTAssertEqual(battery.icon, "text:15%")
        let garmin = DeckKey(icon: "heart", action: DeckAction(type: .garmin, target: "sleep")).resolving(LiveKeys())
        XCTAssertEqual(garmin.icon, "heart")
        XCTAssertEqual(garmin.title, "Sleep last night")
        let free = DeckKey(action: DeckAction(type: .freeUntil)).resolving(LiveKeys(glances: [GlanceKeys.free: EventKeys.freeGlance([], now: at(16, 10), calendar: cal)]))
        XCTAssertEqual(free.action.kind, .media)
        XCTAssertEqual(free.title, "Rest of the day")
    }

    func testTownKeysSayWhenNoTownAndLongPressAsks() {
        for type in [ActionType.worldClock, .sunTimes] {
            XCTAssertEqual(DeckKey(action: DeckAction(type: type)).resolving(LiveKeys()).title, "Set a town")
        }
        let clock = DeckKey(action: DeckAction(type: .worldClock, target: "Tokyo"))
        XCTAssertEqual(clock.action(long: true), DeckAction(type: .weatherTown, target: clock.id.uuidString))
        XCTAssertEqual(clock.action(long: false).type, .worldClock)
        XCTAssertTrue(clock.actsOnHold)
        XCTAssertFalse(DeckKey(action: DeckAction(type: .garmin)).actsOnHold)
    }

    func testTownKeyWithoutTownIsFlagged() {
        let profile = DeckProfile(name: "Main", pages: [DeckPage(name: "P")])
        let deck = Deck(profiles: [profile], defaultProfile: profile.id)
        let world = KeyWorld(appExists: { _ in true }, fileExists: { _ in true }, raycastExtension: { _, _ in true })
        XCTAssertEqual(KeyCheck.problem(DeckKey(action: DeckAction(type: .sunTimes)), in: profile, deck: deck, world: world), "No town yet")
        XCTAssertNil(KeyCheck.problem(DeckKey(action: DeckAction(type: .sunTimes, target: "Malaga")), in: profile, deck: deck, world: world))
    }
}
