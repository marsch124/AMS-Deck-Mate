import XCTest
@testable import DeckMateCore

/// The 0.18 rules of the fan keys: one small data test each.
final class FanKeysTests: XCTestCase {
    func testFanTargetChoiceAndWords() {
        XCTAssertEqual(FanKeys.target("cool"), "fan:cool")
        XCTAssertEqual(FanKeys.choice(of: "fan:full"), "full")
        XCTAssertNil(FanKeys.choice(of: "fan:"))
        XCTAssertNil(FanKeys.choice(of: "fan:cool; rm"), "only one plain word is ever handed on")
        XCTAssertNil(FanKeys.choice(of: SwitchKeys.dark))
        XCTAssertFalse(SwitchKeys.isOwn(FanKeys.target("cool")), "a fan key is never remembered as on by Deck Mate itself")
        XCTAssertEqual(FanKeys.choices.map(FanKeys.words), ["Automatic", "Cool", "Full"])
        XCTAssertEqual(FanKeys.words("mySpeed"), "My speed")
    }

    func testTheChoiceThatIsOnComesFromFanMenusFile() {
        let file = Data(#"{"appDecides":true,"choice":"cool","since":1795549438.7,"title":"Cool","version":"0.2"}"#.utf8)
        XCTAssertEqual(FanKeys.on(state: file), "fan:cool")
        XCTAssertEqual(FanKeys.on(state: Data(#"{"choice":"quiet"}"#.utf8)), "fan:quiet", "a choice without a key lights none of the three")
        XCTAssertNil(FanKeys.on(state: nil), "no file = no fan key lit")
        XCTAssertNil(FanKeys.on(state: Data("not a file of Fan Menu".utf8)))
        XCTAssertNil(FanKeys.on(state: Data(#"{"choice":""}"#.utf8)))
    }

    func testFanKeyShowsItselfAndOnlyTheOneThatIsOnIsLit() {
        let keys = FanKeys.choices.map { DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target($0))) }
        let shown = keys.map { $0.resolving(LiveKeys(on: ["fan:cool", SwitchKeys.dark])) }
        XCTAssertEqual(shown.map(\.title), ["Automatic", "Cool", "Full 10 min"], "the key that is on without an end shows no minutes")
        XCTAssertEqual(shown.map(\.action.quiet), [false, true, false])
        XCTAssertEqual(keys[0].resolving(LiveKeys(on: ["fan:quiet"])).action.quiet, false)
        XCTAssertEqual(keys.map(\.shownIcon), ["app-fan", "app-fan", "app-fan"])
        XCTAssertEqual(keys[1].action.kind, .shortcut, "purple like every switch")
        XCTAssertEqual(ActionWords.done([keys[2].action], appName: { $0 }), "Fans: Full for 10 minutes")
        func world(_ here: Bool) -> KeyWorld { KeyWorld(appExists: { _ in here }, fileExists: { _ in true }, raycastExtension: { _, _ in true }) }
        XCTAssertNil(KeyCheck.problem(keys[0], in: DeckProfile(), deck: Deck(), world: world(true)))
        XCTAssertEqual(KeyCheck.problem(keys[0], in: DeckProfile(), deck: Deck(), world: world(false)), "AMS Fan Menu is not on this Mac")
    }

    /// 0.20: the fan key that is on shows the minutes left of Fan Menu's timed choice.
    func testTheKeyThatIsOnShowsTheMinutesLeft() {
        let file = Data(#"{"choice":"cool","endsAt":1000}"#.utf8)
        XCTAssertEqual(FanKeys.minutesLeft(state: file, now: 520), 8)
        XCTAssertEqual(FanKeys.minutesLeft(state: file, now: 541), 8, "459 seconds left rounds up")
        XCTAssertEqual(FanKeys.minutesLeft(state: file, now: 940), 0)
        XCTAssertEqual(FanKeys.minutesLeft(state: file, now: 1003), 0)
        XCTAssertNil(FanKeys.minutesLeft(state: file, now: 1010))
        XCTAssertNil(FanKeys.minutesLeft(state: Data(#"{"choice":"cool"}"#.utf8), now: 520))
        XCTAssertNil(FanKeys.minutesLeft(state: nil, now: 520))
        XCTAssertEqual(FanKeys.keyWords("cool", isOn: true, left: 8), "Cool · 8 min")
        XCTAssertEqual(FanKeys.keyWords("cool", isOn: true, left: 0), "Cool · <1 min")
        XCTAssertEqual(FanKeys.keyWords("cool", isOn: true, left: nil), "Cool")
        XCTAssertEqual(FanKeys.keyWords("cool", isOn: false, left: 8), "Cool 10 min")
        XCTAssertEqual(FanKeys.keyWords("automatic", isOn: true, left: nil), "Automatic")
        let keys = FanKeys.choices.map { DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target($0))) }
        let shown = keys.map { $0.resolving(LiveKeys(on: ["fan:cool"], fanLeft: 8)) }
        XCTAssertEqual(shown.map(\.title), ["Automatic", "Cool · 8 min", "Full 10 min"])
    }

    /// 0.19: Cool and Full are asked for ten minutes, and the key says so; Automatic has no time.
    func testCoolAndFullLastTenMinutes() {
        XCTAssertEqual(FanKeys.choices.map(FanKeys.wish), ["automatic", "cool:600", "full:600"])
        XCTAssertNil(FanKeys.seconds(for: "automatic"))
        XCTAssertNil(FanKeys.seconds(for: "quiet"), "only the two keys he asked for")
        XCTAssertEqual(FanKeys.choices.map(FanKeys.keyWords), ["Automatic", "Cool 10 min", "Full 10 min"])
        XCTAssertEqual(FanKeys.choices.map(FanKeys.longWords), ["Automatic", "Cool for 10 minutes", "Full for 10 minutes"])
        XCTAssertEqual(FanKeys.on(state: Data(#"{"choice":"cool","endsAt":1795589769.3}"#.utf8)), "fan:cool", "a timed choice lights its key like any other")
    }
}

/// 0.21: the chip temperature key.
final class ChipKeyTests: XCTestCase {
    func testDegreesFromFanMenusNowFile() {
        let file = Data(#"{"time":1000,"chip":56.4,"hottest":61.2,"fans":[1200,1300],"version":"0.6"}"#.utf8)
        XCTAssertEqual(ChipKey.degrees(file: file, now: 1004), 56)
        XCTAssertEqual(ChipKey.degrees(file: Data(#"{"time":1000,"chip":56.5}"#.utf8), now: 1000), 57)
        XCTAssertEqual(ChipKey.degrees(file: file, now: 1030), 56, "30 seconds old is still fresh")
        XCTAssertNil(ChipKey.degrees(file: file, now: 1031), "older than 30 seconds = Fan Menu is not running")
        XCTAssertNil(ChipKey.degrees(file: nil, now: 1000))
        XCTAssertNil(ChipKey.degrees(file: Data("no json".utf8), now: 1000))
        XCTAssertNil(ChipKey.degrees(file: Data(#"{"time":1000,"hottest":61}"#.utf8), now: 1000), "no chip figure")
        XCTAssertNil(ChipKey.degrees(file: Data(#"{"chip":56}"#.utf8), now: 1000), "no time = cannot be trusted")
        XCTAssertNil(ChipKey.degrees(file: Data(#"{"time":1000,"chip":"hot"}"#.utf8), now: 1000))
    }

    func testWordsKeyAndSayings() {
        XCTAssertEqual(ChipKey.keyWords(56), "Chip 56°")
        XCTAssertEqual(ChipKey.keyWords(nil), "Chip –")
        XCTAssertTrue(ChipKey.isChip("fanmenu:chip"))
        XCTAssertFalse(FanKeys.isFan(ChipKey.target), "not a fan choice")
        XCTAssertFalse(ChipKey.isChip("fan:cool"))
        XCTAssertEqual(ChipKey.openGraph, "com.schabbauer.AMSFanMenu.openGraph")
        let key = DeckKey(action: DeckAction(type: .toggle, target: ChipKey.target))
        let shown = key.resolving(LiveKeys(on: [ChipKey.target], chip: 56))
        XCTAssertEqual(shown.title, "Chip 56°")
        XCTAssertFalse(shown.action.quiet, "a figure is never lit")
        XCTAssertEqual(key.resolving(LiveKeys()).title, "Chip –")
        XCTAssertEqual(key.shownIcon, "app-fan")
        XCTAssertEqual(KeySays.does(key.action, in: Deck(), profile: nil, appName: { $0 }),
                       "Shows the chip temperature. Click: opens AMS Fan Menu's graphs.")
        func world(_ here: Bool) -> KeyWorld { KeyWorld(appExists: { _ in here }, fileExists: { _ in true }, raycastExtension: { _, _ in true }) }
        XCTAssertNil(KeyCheck.problem(key, in: DeckProfile(), deck: Deck(), world: world(true)))
        XCTAssertEqual(KeyCheck.problem(key, in: DeckProfile(), deck: Deck(), world: world(false)), "AMS Fan Menu is not on this Mac")
    }
}

/// 0.22: the fan speed key.
final class FanSpeedKeyTests: XCTestCase {
    func testTheHigherFanFromNowFile() {
        let file = Data(#"{"time":1000,"fans":[1590,1648],"chip":68.9}"#.utf8)
        XCTAssertEqual(FanSpeedKey.speed(file: file, now: 1004), 1648)
        XCTAssertEqual(FanSpeedKey.speed(file: Data(#"{"time":1000,"fans":[1700,1200]}"#.utf8), now: 1000), 1700)
        XCTAssertEqual(FanSpeedKey.speed(file: Data(#"{"time":1000,"fans":[0,0]}"#.utf8), now: 1000), 0)
    }

    func testNoReadingIsNil() {
        let file = Data(#"{"time":1000,"fans":[1590,1648]}"#.utf8)
        XCTAssertNil(FanSpeedKey.speed(file: file, now: 1031), "older than 30 seconds")
        XCTAssertNil(FanSpeedKey.speed(file: nil, now: 1000))
        XCTAssertNil(FanSpeedKey.speed(file: Data(#"{"fans":[1500]}"#.utf8), now: 1000), "no time")
        XCTAssertNil(FanSpeedKey.speed(file: Data(#"{"time":1000,"chip":60}"#.utf8), now: 1000), "no fans")
        XCTAssertNil(FanSpeedKey.speed(file: Data(#"{"time":1000,"fans":[]}"#.utf8), now: 1000), "no fan at all")
    }

    func testWordsKeyAndSayings() {
        XCTAssertEqual(FanSpeedKey.keyWords(1650), "Fans 1,650")
        XCTAssertEqual(FanSpeedKey.keyWords(980), "Fans 980")
        XCTAssertEqual(FanSpeedKey.keyWords(12345), "Fans 12,345")
        XCTAssertEqual(FanSpeedKey.keyWords(0), "Fans off")
        XCTAssertEqual(FanSpeedKey.keyWords(nil), "Fans –")
        XCTAssertFalse(FanKeys.isFan(FanSpeedKey.target))
        XCTAssertFalse(ChipKey.isChip(FanSpeedKey.target))
        let key = DeckKey(action: DeckAction(type: .toggle, target: FanSpeedKey.target))
        let shown = key.resolving(LiveKeys(on: [FanSpeedKey.target], chip: 56, fans: 1650))
        XCTAssertEqual(shown.title, "Fans 1,650")
        XCTAssertFalse(shown.action.quiet, "a figure is never lit")
        XCTAssertEqual(key.resolving(LiveKeys()).title, "Fans –")
        XCTAssertEqual(key.shownIcon, "app-fan")
        XCTAssertEqual(KeySays.does(key.action, in: Deck(), profile: nil, appName: { $0 }),
                       "Shows the fan speed. Click: opens AMS Fan Menu's graphs.")
        func world(_ here: Bool) -> KeyWorld { KeyWorld(appExists: { _ in here }, fileExists: { _ in true }, raycastExtension: { _, _ in true }) }
        XCTAssertEqual(KeyCheck.problem(key, in: DeckProfile(), deck: Deck(), world: world(false)), "AMS Fan Menu is not on this Mac")
        XCTAssertEqual(FanSpeedKey.longWords, "Fans: fan speed")
    }
}
