import XCTest
@testable import DeckMateCore

/// The 0.10 rules: one small data test each.
final class LiveKindsTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_800_000_000)
    private let day = 86_400.0

    private func deck(_ keys: [Int: DeckKey], page: String = "Page 1", group: String = "Main") -> (Deck, DeckProfile, DeckPosition) {
        let profile = DeckProfile(name: group, pages: [DeckPage(name: page, keys: keys)])
        let deck = Deck(profiles: [profile], defaultProfile: profile.id)
        return (deck, profile, Navigator.start(in: deck)!)
    }

    func testTimerClockMinutesAndStartStop() {
        XCTAssertEqual(TimerKeys.clock(59), "0:59")
        XCTAssertEqual(TimerKeys.clock(299), "4:59")
        XCTAssertEqual(TimerKeys.clock(3900), "1:05:00")
        XCTAssertEqual(TimerKeys.minutes("x"), 5)
        XCTAssertEqual(TimerKeys.minutes("0"), 1)
        let started = TimerKeys.pressed(TimerKeys.State(), target: "5", now: t0)
        XCTAssertEqual(started.ends["5"], t0.addingTimeInterval(300))
        XCTAssertTrue(TimerKeys.pressed(started, target: "5", now: t0).isIdle)
    }

    func testTimerFinishesOnceAndDoneGoesAway() {
        let started = TimerKeys.pressed(TimerKeys.State(), target: "1", now: t0)
        let end = t0.addingTimeInterval(60)
        let first = TimerKeys.tick(started, now: end)
        XCTAssertEqual(first.finished, ["1"])
        XCTAssertEqual(TimerKeys.left(first.state, now: end), ["1": 0])
        XCTAssertEqual(TimerKeys.tick(first.state, now: end.addingTimeInterval(1)).finished, [])
        XCTAssertTrue(TimerKeys.pressed(first.state, target: "1", now: end).isIdle, "a press puts Done away")
        XCTAssertTrue(TimerKeys.tick(first.state, now: end.addingTimeInterval(61)).state.isIdle)
    }

    func testTimerKeyShowsItself() {
        let key = DeckKey(action: .fresh(.timer))
        XCTAssertEqual(key.resolving(LiveKeys()).title, "5 min")
        let running = key.resolving(LiveKeys(timers: ["5": 299]))
        XCTAssertEqual(running.title, "5 min")
        XCTAssertTrue(running.action.quiet)
        XCTAssertEqual(key.resolving(LiveKeys(timers: ["5": 0])).title, "Done")
    }

    func testSwitchSteps() {
        let off = DeckAction(type: .raycast, target: "raycast://a")
        let on = DeckAction(type: .raycast, target: "raycast://b")
        let action = DeckAction(type: .toggle, target: SwitchKeys.newOwn(), steps: [off, on])
        XCTAssertEqual(SwitchKeys.step(of: action, isOn: false), off)
        XCTAssertEqual(SwitchKeys.step(of: action, isOn: true), on)
        XCTAssertNil(SwitchKeys.step(of: DeckAction(type: .toggle, steps: [off]), isOn: true))
        XCTAssertNil(SwitchKeys.step(of: DeckAction(type: .toggle, steps: [off, .none]), isOn: true))
        let key = DeckKey(action: .fresh(.toggle))
        XCTAssertEqual(key.resolving(LiveKeys()).title, "Light")
        let lit = key.resolving(LiveKeys(on: [SwitchKeys.dark]))
        XCTAssertEqual(lit.title, "Dark")
        XCTAssertTrue(lit.action.quiet)
    }

    func testOpenAppsKeepOrder() {
        XCTAssertEqual(RunningApps.order(was: ["a", "b", "c"], now: ["c", "d", "a", "a"]), ["a", "c", "d"])
        let key = DeckKey(title: "x", icon: "star", action: DeckAction(type: .running, target: "2"))
        let shown = key.resolving(LiveKeys(running: ["a", "b"]))
        XCTAssertEqual(shown.action, DeckAction(type: .app, target: "b"))
        XCTAssertEqual(shown.title, "")
        XCTAssertEqual(shown.icon, "")
        XCTAssertEqual(DeckKey(action: DeckAction(type: .running, target: "3")).resolving(LiveKeys(running: ["a"])).title, "No app")
        let folder = RunningApps.folder(parent: UUID())
        XCTAssertEqual(folder.keys[0]?.action.type, .back)
        XCTAssertEqual(folder.keys[0]?.title, "Back")
        XCTAssertEqual(folder.keys.count, 15)
        XCTAssertTrue((1...14).allSatisfy { folder.keys[$0]?.action == DeckAction(type: .running, target: String($0)) })
    }

    func testFirstFreePlace() {
        var page = DeckPage(keys: [0: DeckKey(), 1: DeckKey(), 3: DeckKey()])
        XCTAssertEqual(page.firstFreePlace, 2)
        page.keys = Dictionary(uniqueKeysWithValues: (0..<15).map { ($0, DeckKey()) })
        XCTAssertNil(page.firstFreePlace)
    }

    func testStepTiming() {
        let app = DeckAction(type: .app, target: "a")
        let starts = StepTiming.starts([app, DeckAction(type: .wait, target: "2"), app, app])
        XCTAssertEqual(starts.count, 3)
        XCTAssertEqual(starts[0].after, 0, accuracy: 0.001)
        XCTAssertEqual(starts[1].after, 2.33, accuracy: 0.001)
        XCTAssertEqual(starts[2].after, 2.66, accuracy: 0.001)
        XCTAssertEqual(StepTiming.seconds("x"), 1)
        XCTAssertEqual(StepTiming.seconds("0.1"), 0.5)
        XCTAssertEqual(StepTiming.seconds("999"), 60)
    }

    func testMicrophoneLight() {
        let key = DeckKey(action: DeckAction(type: .micLight))
        let lit = key.resolving(LiveKeys(micInUse: true))
        XCTAssertEqual(lit.title, "Mic in use")
        XCTAssertEqual(lit.action.kind, .raycast)
        let free = key.resolving(LiveKeys())
        XCTAssertEqual(free.title, "Mic free")
        XCTAssertEqual(free.action.kind, .move)
        let (d, _, pos) = deck([0: key])
        XCTAssertTrue(Navigator.press(0, at: pos, in: d).run.isEmpty)
    }

    func testPressingNewKindsRunsThem() {
        let kinds: [DeckAction] = [DeckAction(type: .timer, target: "5"), DeckAction(type: .toggle, target: SwitchKeys.dark),
                                   DeckAction(type: .list, steps: [DeckAction(type: .app, target: "a")]),
                                   DeckAction(type: .appleShortcut, target: "Go")]
        for action in kinds {
            let (d, _, pos) = deck([0: DeckKey(action: action)])
            XCTAssertEqual(Navigator.press(0, at: pos, in: d).run, [action], "\(action.type)")
        }
    }

    func testKeyCheckForNewKinds() {
        let world = KeyWorld(appExists: { _ in true }, fileExists: { _ in true }, raycastExtension: { _, _ in true })
        let (d, profile, _) = deck([:])
        func why(_ action: DeckAction) -> String? { KeyCheck.problem(DeckKey(action: action), in: profile, deck: d, world: world) }
        XCTAssertEqual(why(DeckAction(type: .appleShortcut)), "No Shortcut picked")
        XCTAssertEqual(why(DeckAction(type: .list)), "The list is empty")
        XCTAssertEqual(why(DeckAction(type: .toggle, target: SwitchKeys.newOwn())), "Nothing to switch yet")
        let filled = DeckAction(type: .toggle, target: SwitchKeys.newOwn(), steps: [DeckAction(type: .app, target: "a")])
        XCTAssertNil(why(filled))
    }

    func testKeyFinder() {
        var group = DeckProfile(name: "Work", pages: [])
        let keys: [Int: DeckKey] = [0: DeckKey(title: "Mail", action: DeckAction(type: .app, target: "m")),
                                    1: DeckKey(title: "Open Mail", action: DeckAction(type: .app, target: "m")),
                                    2: DeckKey(title: "Back", action: DeckAction(type: .back)),
                                    3: DeckKey(title: "Next", action: DeckAction(type: .nextPage)),
                                    4: DeckKey(title: "Notes", action: DeckAction(type: .app, target: "n"))]
        group.pages = [DeckPage(name: "Daily", keys: keys)]
        let deck = Deck(profiles: [group], defaultProfile: group.id)
        func found(_ words: String, limit: Int = 6) -> [String] { KeyFinder.hits(words, in: deck, limit: limit, name: { $0.title }).map(\.title) }
        XCTAssertEqual(found("mail"), ["Mail", "Open Mail"], "titles that start with the word come first")
        XCTAssertEqual(found("daily"), ["Mail", "Open Mail", "Notes"], "by page name")
        XCTAssertEqual(found("work notes"), ["Notes"], "by page group name, all words must match")
        XCTAssertEqual(found("mail notes"), [])
        XCTAssertEqual(found("back"), [])
        XCTAssertEqual(found("next"), [])
        XCTAssertEqual(found("daily", limit: 2).count, 2)
        XCTAssertEqual(found("  "), [])
    }

    func testKeyUseCountsAndQuiet() throws {
        let never = DeckKey(title: "Never", action: DeckAction(type: .app, target: "a"))
        let old = DeckKey(title: "Old", action: DeckAction(type: .app, target: "b"))
        let fresh = DeckKey(title: "Fresh", action: DeckAction(type: .app, target: "c"))
        let folder = DeckKey(title: "F", action: DeckAction(type: .folder))
        let back = DeckKey(title: "Back", action: DeckAction(type: .back))
        let (d, _, _) = deck([0: never, 1: old, 2: fresh, 3: folder, 4: back])
        let now = t0.addingTimeInterval(100 * day)
        var use = KeyUse(since: t0)
        use.record(old.id, now: t0.addingTimeInterval(10 * day))
        use.record(fresh.id, now: now.addingTimeInterval(-day))
        use.record(fresh.id, now: now.addingTimeInterval(-day))
        XCTAssertEqual(use.presses[fresh.id.uuidString], KeyUse.Entry(count: 2, last: now.addingTimeInterval(-day)))
        XCTAssertEqual(use.days(now: now), 100)
        let quiet = use.quiet(in: d, now: now, name: { $0.title })
        XCTAssertEqual(Set(quiet.map(\.id)), [never.id.uuidString, old.id.uuidString])
        XCTAssertEqual(use.most(in: d, name: { $0.title }).map(\.count), [2, 1])
        // first 30 days: pressed since the counting began is not listed
        var early = KeyUse(since: t0)
        early.record(old.id, now: t0.addingTimeInterval(day))
        let soon = early.quiet(in: d, now: t0.addingTimeInterval(5 * day), name: { $0.title })
        XCTAssertFalse(soon.map(\.id).contains(old.id.uuidString))
        XCTAssertTrue(soon.map(\.id).contains(never.id.uuidString))
        XCTAssertEqual(try JSONDecoder().decode(KeyUse.self, from: JSONEncoder().encode(use)), use)
    }

    func testOldKeysFileStillReads() throws {
        let old = try JSONDecoder().decode(DeckAction.self, from: Data(#"{"type":"app","target":"x"}"#.utf8))
        XCTAssertEqual(old.name, "")
        let unknown = try JSONDecoder().decode(DeckAction.self, from: Data(#"{"type":"timerX"}"#.utf8))
        XCTAssertEqual(unknown.type, .none)
    }
}
