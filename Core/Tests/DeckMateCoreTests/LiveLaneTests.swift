import XCTest
@testable import DeckMateCore

final class LiveLaneTests: XCTestCase {
    let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    func testTimerWordsAreWholeMinutesUntilTheLastMinute() {
        XCTAssertEqual(TimerKeys.shown(1500), "25 min")
        XCTAssertEqual(TimerKeys.shown(721), "13 min")
        XCTAssertEqual(TimerKeys.shown(61), "2 min")
        XCTAssertEqual(TimerKeys.shown(60), "1:00")
        XCTAssertEqual(TimerKeys.shown(59), "0:59")
        XCTAssertEqual(TimerKeys.clock(154), "2:34")      // the stopwatch keeps its seconds
    }

    func testTimerKeyAndFocusKeyShowMinutes() {
        let timer = DeckKey(action: DeckAction(type: .timer, target: "25"))
        XCTAssertEqual(timer.resolving(LiveKeys(timers: ["25": 1259])).title, "21 min")
        XCTAssertEqual(timer.resolving(LiveKeys(timers: ["25": 59])).title, "0:59")
        let plan = FocusKeys.builtIn[0]
        let key = DeckKey(action: FocusKeys.action(for: plan))
        let live = LiveKeys(focus: FocusKeys.Showing(name: plan.name, label: "Pomodoro", left: 1500, kind: "focus"))
        XCTAssertEqual(GlanceKeys.bigWords(key.resolving(live).icon), "25 min")
    }

    func testClockWakesOncePerMinuteThenEverySecondInTheLastMinute() {
        XCTAssertEqual(LiveTick.wake(remaining: 1500, seconds: true), 60, accuracy: 0.001)
        XCTAssertEqual(LiveTick.wake(remaining: 1499.5, seconds: false), 59.5, accuracy: 0.001)
        XCTAssertEqual(LiveTick.wake(remaining: 30, seconds: true), 1, accuracy: 0.001)
        XCTAssertEqual(LiveTick.wake(remaining: 30, seconds: false), 30, accuracy: 0.001)   // unseen: only its end
        // 25 minutes: 24 minute changes + 60 seconds + 1 end instead of 1,500 seconds.
        var remaining = 1500.0, wakes = 0
        while remaining > 0 { remaining -= LiveTick.wake(remaining: remaining, seconds: true); wakes += 1 }
        XCTAssertEqual(wakes, 25 + 60 - 1)
    }

    func testTimersEndOnTime() {
        let state = TimerKeys.State(ends: ["5": t0.addingTimeInterval(200)], done: [:])
        XCTAssertEqual(LiveTick.wake(timers: state, now: t0, seconds: false)!, 20, accuracy: 0.001)      // 200 s left shows "4 min"; at 180 it shows "3 min"
        let last = TimerKeys.State(ends: ["1": t0.addingTimeInterval(40)], done: [:])
        XCTAssertEqual(LiveTick.wake(timers: last, now: t0, seconds: false)!, 40, accuracy: 0.001)
        XCTAssertNil(LiveTick.wake(timers: TimerKeys.State(), now: t0, seconds: true))
    }

    func testBreathingBarRisesAndFalls() {
        let id = UUID()
        let run = BreathKeys.Run(key: id, began: t0, setting: BreathKeys.setting("4-6-6"))
        XCTAssertEqual(BreathKeys.showing(run, now: t0)?.level, 0)
        XCTAssertEqual(BreathKeys.showing(run, now: t0.addingTimeInterval(2))?.level, 50)
        XCTAssertEqual(BreathKeys.showing(run, now: t0.addingTimeInterval(2))?.breathingIn, true)
        XCTAssertEqual(BreathKeys.showing(run, now: t0.addingTimeInterval(4))?.level, 100)
        XCTAssertEqual(BreathKeys.showing(run, now: t0.addingTimeInterval(7))?.level, 50)
        XCTAssertEqual(BreathKeys.showing(run, now: t0.addingTimeInterval(7))?.breathingIn, false)
        XCTAssertNil(BreathKeys.showing(run, now: t0.addingTimeInterval(60)))        // 6 breaths of 10 s
        let key = DeckKey(id: id, action: DeckAction(type: .breath))
        let live = LiveKeys(breath: BreathKeys.showing(run, now: t0.addingTimeInterval(2)))
        XCTAssertEqual(key.resolving(live).title, "Breathe in")
        XCTAssertEqual(BreathKeys.level(key.resolving(live).icon), 50)
        XCTAssertEqual(key.resolving(LiveKeys()).title, "Breathe")
        XCTAssertEqual(DeckKey(action: DeckAction(type: .breath)).resolving(live).title, "Breathe")   // another key stays idle
    }

    func testBreathingChoicesAndPresses() {
        XCTAssertEqual(BreathKeys.setting(""), BreathKeys.standard)
        XCTAssertEqual(BreathKeys.setting("4-8-20"), BreathKeys.Setting(inSeconds: 4, outSeconds: 8, breaths: 20))
        XCTAssertEqual(BreathKeys.setting("7-7-7"), BreathKeys.standard)
        XCTAssertEqual(BreathKeys.setting("4-6-6-1"), BreathKeys.standard)
        let id = UUID()
        let run = BreathKeys.pressed(nil, key: id, target: "", now: t0)
        XCTAssertNotNil(run)
        XCTAssertNil(BreathKeys.pressed(run, key: id, target: "", now: t0.addingTimeInterval(5)))      // second press stops
    }

    func testBarPartsFillLeftToRight() {
        XCTAssertEqual(BarKeys.share(place: 1, of: 5, progress: 0.5), 100)
        XCTAssertEqual(BarKeys.share(place: 3, of: 5, progress: 0.5), 50)
        XCTAssertEqual(BarKeys.share(place: 4, of: 5, progress: 0.5), 0)
        XCTAssertEqual(BarKeys.share(place: 5, of: 5, progress: 1), 100)
        XCTAssertEqual(BarKeys.share(place: 2, of: 4, progress: 0.499), 99)
        XCTAssertEqual(BarKeys.parse("2/5").place, 2)
        XCTAssertEqual(BarKeys.parse("9/5").count, 1)       // odd = one part
        let key = DeckKey(action: DeckAction(type: .bar, target: "2/2"))
        XCTAssertEqual(BarKeys.percent(key.resolving(LiveKeys()).icon), 0)
        XCTAssertEqual(BarKeys.percent(key.resolving(LiveKeys(bar: BarKeys.Now(progress: 0.75, tone: .text, total: 60))).icon), 50)
    }

    func testBarFollowsFocusThenTheLastTimer() {
        let plan = FocusKeys.builtIn[4]            // 1 + 25 + 2 minutes
        let run = FocusKeys.Run(plan: plan, began: t0)
        let timers = TimerKeys.State(ends: ["5": t0.addingTimeInterval(100), "25": t0.addingTimeInterval(1500)])
        let now = t0.addingTimeInterval(840)
        XCTAssertEqual(BarKeys.now(focus: run, timers: timers, at: now)?.progress ?? 0, 0.5, accuracy: 0.001)
        let follow = BarKeys.now(focus: nil, timers: timers, at: t0.addingTimeInterval(750))
        XCTAssertEqual(follow?.progress ?? 0, 0.5, accuracy: 0.001)        // the 25-minute timer: 750 of 1500 left
        XCTAssertNil(BarKeys.now(focus: nil, timers: TimerKeys.State(done: ["5": t0]), at: t0))
    }

    func testFillRowNeverReplacesAKey() {
        let mail = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"))
        var keys: [Int: DeckKey] = [5: DeckKey(action: DeckAction(type: .bar)), 7: mail, 3: mail]
        keys = BarKeys.filledRow(keys, row: 1)
        XCTAssertEqual(keys[7], mail)
        XCTAssertEqual(keys[3], mail)
        XCTAssertEqual(keys[5]?.action.target, "1/4")
        XCTAssertEqual(keys[6]?.action.target, "2/4")
        XCTAssertEqual(keys[8]?.action.target, "3/4")
        XCTAssertEqual(keys[9]?.action.target, "4/4")
        XCTAssertNil(keys[0])
    }

    func testParagonFormatNumber() {
        let day = #""day":{"year":2026,"month":11,"day":18}"#
        let old = ParagonKeys.snapshot(from: Data("{\(day),\"inboxCount\":4}".utf8))
        XCTAssertEqual(old?.format, 1)
        let new = ParagonKeys.snapshot(from: Data("{\(day),\"inboxCount\":4,\"format\":2}".utf8))
        let today = ParagonKeys.Day(year: 2026, month: 11, day: 18)
        let glance = ParagonKeys.glance(.inbox, snapshot: new, today: today, installed: true)
        XCTAssertEqual(glance, Glance(big: "–", words: "Update Deck Mate"))
        XCTAssertEqual(ParagonKeys.dueGlance(snapshot: new, today: today, installed: true).words, "Update Deck Mate")
        XCTAssertEqual(ParagonKeys.glance(.inbox, snapshot: old, today: today, installed: true)?.big, "4")
    }

    func testNowOnMyPlan() {
        let day = #""day":{"year":2026,"month":11,"day":18}"#
        let file = "{\(day),\"plan\":[{\"title\":\"Design review\",\"start\":780,\"end\":870},{\"title\":\"Write\",\"start\":900,\"end\":960},{\"title\":\"\",\"start\":1,\"end\":2}]}"
        let shot = ParagonKeys.snapshot(from: Data(file.utf8))
        let today = ParagonKeys.Day(year: 2026, month: 11, day: 18)
        func shows(_ minute: Int) -> Glance? { ParagonKeys.glance(.plan, snapshot: shot, today: today, installed: true, minute: minute) }
        XCTAssertEqual(shows(800), Glance(big: "14:30", words: "until Design review"))
        XCTAssertEqual(shows(500), Glance(big: "13:00", words: "Design review"))
        XCTAssertEqual(shows(880), Glance(big: "15:00", words: "Write"))
        XCTAssertEqual(shows(1000), Glance(big: "Free", words: "Nothing more planned"))
        let none = ParagonKeys.snapshot(from: Data("{\(day)}".utf8))
        XCTAssertEqual(ParagonKeys.glance(.plan, snapshot: none, today: today, installed: true, minute: 800)?.big, "Free")
        XCTAssertEqual(ParagonKeys.openLink(.plan, snapshot: shot, today: today), ParagonKeys.todayLink)
    }

    func testOldTemperatureTurnsGreyBlue() {
        let now = WeatherKeys.Now(temperature: 4, code: 3)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let fresh = WeatherKeys.glance(now, fetched: t0, at: t0.addingTimeInterval(3600), calendar: calendar)
        XCTAssertNil(fresh?.tone)
        let old = WeatherKeys.glance(now, fetched: t0, at: t0.addingTimeInterval(2 * 3600 + 1), calendar: calendar)
        XCTAssertEqual(old?.tone, .move)
        XCTAssertEqual(old?.words, "As of 08:00")
        let key = DeckKey(action: DeckAction(type: .weather, target: "Oslo"))
        XCTAssertEqual(key.resolving(LiveKeys(glances: [GlanceKeys.weather("Oslo"): old!])).action.kind, .move)
    }
}
