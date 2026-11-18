import XCTest
@testable import DeckMateCore

/// The smart lane of 0.16: one small test for each rule.
final class SmartLaneTests: XCTestCase {
    func testEveningWindowPassesMidnight() {
        var deck = Deck(brightness: 70)
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 23 * 60), 70, "off by default")
        deck.eveningDim = true
        XCTAssertEqual(deck.eveningFrom, 21 * 60 + 30)
        XCTAssertEqual(deck.eveningTo, 7 * 60)
        XCTAssertEqual(deck.eveningBrightness, 20)
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 23 * 60), 20)
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 3 * 60), 20)
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 7 * 60), 70, "the end is outside")
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 12 * 60), 70)
        XCTAssertEqual(BoxEvening.brightness(for: deck, minute: 21 * 60 + 30), 20, "the start is inside")
    }

    func testOldKeysFileDecodesWithDefaults() throws {
        let deck = try JSONDecoder().decode(Deck.self, from: Data(#"{"profiles":[{"name":"A"}]}"#.utf8))
        XCTAssertFalse(deck.eveningDim)
        XCTAssertFalse(deck.profiles[0].hoursOn)
        XCTAssertEqual(deck.profiles[0].hoursFrom, 360)
        XCTAssertEqual(deck.profiles[0].hoursTo, 540)
    }

    func testHoursPageGroupShowsOnlyForAppsWithoutOwn() {
        let main = DeckProfile(name: "Main", pages: [DeckPage(name: "P")])
        let own = DeckProfile(name: "Mail", apps: ["com.apple.mail"], pages: [DeckPage(name: "P")])
        var morning = DeckProfile(name: "Morning", pages: [DeckPage(name: "P")])
        morning.hoursOn = true
        morning.hoursFrom = 22 * 60
        morning.hoursTo = 9 * 60            // passes midnight
        let deck = Deck(profiles: [main, own, morning], defaultProfile: main.id)
        XCTAssertEqual(Navigator.profile(forApp: "com.apple.Safari", in: deck), main.id, "no time given: as before")
        XCTAssertEqual(Navigator.profile(forApp: "com.apple.Safari", in: deck, now: 12 * 60), main.id)
        XCTAssertEqual(Navigator.profile(forApp: "com.apple.Safari", in: deck, now: 7 * 60), morning.id)
        XCTAssertEqual(Navigator.profile(forApp: "com.apple.Safari", in: deck, now: 23 * 60), morning.id)
        XCTAssertEqual(Navigator.profile(forApp: "com.apple.mail", in: deck, now: 7 * 60), own.id, "an app's own group wins")
        // the minute going by moves the deck from the default to the morning group
        let at = Navigator.start(in: deck, profile: main.id)
        let moved = Navigator.follow(app: "com.apple.Safari", previousApp: "com.apple.mail", at: at, in: deck, now: 7 * 60)
        XCTAssertEqual(moved?.profile, morning.id)
        let same = Navigator.follow(app: "com.apple.Safari", previousApp: "com.apple.mail", at: at, in: deck, now: 12 * 60)
        XCTAssertEqual(same?.profile, main.id)
    }

    func testOftenKeysTakeTheMostPressedAndSkipTheRest() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        func key(_ title: String, _ type: ActionType = .link) -> DeckKey { DeckKey(title: title, action: DeckAction(type: type, target: "x")) }
        let a = key("A"), b = key("B"), c = key("C"), old = key("Old"), back = key("Back", .back), often = key("O", .often)
        let page = DeckPage(name: "P", keys: [0: a, 1: b, 2: c, 3: old, 4: back, 5: often])
        let deck = Deck(profiles: [DeckProfile(name: "G", pages: [page])])
        var use = KeyUse(since: now.addingTimeInterval(-90 * 86_400))
        use.presses[a.id.uuidString] = .init(count: 5, last: now)
        use.presses[b.id.uuidString] = .init(count: 9, last: now)
        use.presses[c.id.uuidString] = .init(count: 2, last: now)
        use.presses[old.id.uuidString] = .init(count: 99, last: now.addingTimeInterval(-40 * 86_400))
        use.presses[back.id.uuidString] = .init(count: 50, last: now)
        use.presses[often.id.uuidString] = .init(count: 50, last: now)
        XCTAssertEqual(OftenKeys.ranked(in: deck, use: use, now: now).map(\.title), ["B", "A", "C"])
        XCTAssertEqual(OftenKeys.key(number: "2", in: deck, use: use, now: now)?.title, "A")
        XCTAssertNil(OftenKeys.key(number: "4", in: deck, use: use, now: now))
        // not enough presses: its drawing and "Not yet"; counting a press of it counts nothing
        let idle = DeckKey(action: DeckAction(type: .often, target: "4"))
        XCTAssertEqual(OftenKeys.showing(idle, stands: nil).title, "Not yet")
        XCTAssertNil(OftenKeys.counted(idle, long: false, in: deck, use: use, now: now))
        // a press counts for the real key
        let first = DeckKey(action: DeckAction(type: .often, target: "1"))
        XCTAssertEqual(OftenKeys.counted(first, long: false, in: deck, use: use, now: now)?.id, b.id)
        let shown = OftenKeys.showing(first, stands: b)
        XCTAssertEqual(shown.title, "B")
        XCTAssertEqual(shown.id, first.id)
        // the ready-made folder: Back and five often keys
        let folder = OftenKeys.folder(parent: UUID())
        XCTAssertEqual(folder.keys[0]?.action.type, .back)
        XCTAssertEqual((1...5).compactMap { folder.keys[$0]?.action.target }, ["1", "2", "3", "4", "5"])
    }

    func testReadyMadeKeysForOwnApps() {
        let deck = Deck(profiles: [DeckProfile(name: "Main")])
        let group = Templates.profile(from: Templates.ownApps, in: deck)
        XCTAssertEqual(group.name, "My AMS apps")
        XCTAssertTrue(group.apps.isEmpty)
        let keys = group.pages[0].keys.values
        XCTAssertTrue(keys.contains { $0.action.type == .link && $0.action.target == "amstidybar://hide" })
        XCTAssertTrue(keys.contains { $0.action.type == .app })
        XCTAssertEqual(Set(keys.map(\.title)).count, keys.count)
    }
}
