import XCTest
@testable import DeckMateCore

final class SetupLaneTests: XCTestCase {
    func testLinkText() {
        XCTAssertEqual(LinkText.kind("~/Documents/a b.pdf"), .file)
        XCTAssertEqual(LinkText.kind("https://example.com/x"), .link)
        XCTAssertEqual(LinkText.kind("example.com"), .bare("https://example.com"))
        XCTAssertEqual(LinkText.kind("example.com/a/b"), .bare("https://example.com/a/b"))
        XCTAssertEqual(LinkText.kind("my notes"), .bad)
        XCTAssertEqual(LinkText.kind("hello"), .bad)
        XCTAssertEqual(LinkText.kind("   "), .empty)
    }

    func testBrokenWordsForLinkPlaylistAndRaycastCommand() {
        let profile = DeckProfile(name: "A", pages: [DeckPage(name: "P")])
        let deck = Deck(profiles: [profile])
        let world = KeyWorld(appExists: { _ in true }, fileExists: { _ in true }, raycastExtension: { _, _ in true },
                             raycastCommand: { _, _, command in command == "here" })
        func check(_ action: DeckAction) -> String? { KeyCheck.problem(DeckKey(action: action), in: profile, deck: deck, world: world) }
        XCTAssertEqual(check(DeckAction(type: .link, target: "two words")), LinkText.badWords)
        XCTAssertNil(check(DeckAction(type: .link, target: "example.com")))
        XCTAssertEqual(check(DeckAction(type: .playlist, target: "")), "No Spotify link yet")
        XCTAssertEqual(check(DeckAction(type: .playlist, target: "hello")), "This is not a Spotify link")
        XCTAssertEqual(check(DeckAction(type: .raycast, target: "raycast://extensions/a/b/gone")), "This Raycast command is not on this Mac")
        XCTAssertNil(check(DeckAction(type: .raycast, target: "raycast://extensions/a/b/here")))
        XCTAssertNil(check(DeckAction(type: .raycast, target: "raycast://extensions/raycast/clipboard-history/clipboard-history")))
        XCTAssertNil(check(DeckAction(type: .raycast, target: "raycast://script-commands/anything")))
    }

    func testKeyGoesOnFirstEmptyPlaceAndFullPageChangesNothing() {
        var page = DeckPage(name: "P")
        page.keys[0] = DeckKey(title: "Mine", action: DeckAction(type: .text, target: "x"))
        let group = DeckProfile(name: "A", pages: [page])
        var deck = Deck(profiles: [group])
        XCTAssertEqual(deck.addKey(DeckKey(title: "New"), to: page.id, in: group.id), 1)
        XCTAssertEqual(deck.profiles[0].pages[0].keys[0]?.title, "Mine")
        for _ in 0..<13 { deck.addKey(DeckKey(title: "More"), to: page.id, in: group.id) }
        let before = deck
        XCTAssertNil(deck.addKey(DeckKey(title: "Extra"), to: page.id, in: group.id))
        XCTAssertEqual(deck, before)
        XCTAssertNil(KeyFrom.copiedLink("hello world"))
        XCTAssertNotNil(KeyFrom.copiedLink("https://example.com/a"))
    }

    func testSuggestionRules() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let now = Date(timeIntervalSince1970: 1_794_800_000)
        func used(_ app: String, _ times: Int, into days: inout AppDays) {
            for back in 0..<times { days.days[app, default: []].append(AppDays.day(now.addingTimeInterval(Double(-back) * 86_400), calendar: cal)) }
        }
        var days = AppDays()
        used("com.a.few", 4, into: &days)
        used("com.a.twelve", 12, into: &days)
        used("com.a.nine", 9, into: &days)
        used("com.apple.finder", 14, into: &days)
        used("com.schabbauer.AMSDeckMate", 14, into: &days)
        used("com.a.keyed", 13, into: &days)
        let deck = Deck(profiles: [DeckProfile(name: "A", pages: [DeckPage(name: "P", keys: [0: DeckKey(action: DeckAction(type: .app, target: "com.a.keyed"))])])])
        XCTAssertEqual(days.suggestion(in: deck, now: now, calendar: cal), AppDays.Suggestion(app: "com.a.twelve", days: 12))
        days.declined = ["com.a.twelve"]
        XCTAssertEqual(days.suggestion(in: deck, now: now, calendar: cal)?.app, "com.a.nine")
        // a page group that belongs to the app counts as a key too
        var owned = deck
        owned.profiles[0].apps = ["com.a.nine"]
        XCTAssertNil(days.suggestion(in: owned, now: now, calendar: cal))
        var today = AppDays()
        today.record("x", now: now, calendar: cal)
        XCTAssertEqual(today.count("x", now: now, calendar: cal), 1)
        // old days fall away after 14 days
        days.prune(now: now.addingTimeInterval(20 * 86_400), calendar: cal)
        XCTAssertTrue(days.days.isEmpty)
    }
}
