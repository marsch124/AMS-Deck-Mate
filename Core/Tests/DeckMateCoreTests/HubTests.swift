import DeckMateCore
import XCTest

/// 0.26 / 0.35 (his overhaul, 27 Nov 2026): Hubs are start screens; every other page group shows one big page.
final class HubTests: XCTestCase {
    func testAHubShowsAllItsPagesAnAppPageOnlyOne() {
        let n1 = DeckPage(name: "Live"), n2 = DeckPage(name: "My apps"), n3 = DeckPage(name: "Mac apps"), n4 = DeckPage(name: "Do")
        var now = DeckProfile(name: "Now", pages: [n1, n2, n3, n4])
        now.hub = true
        let c1 = DeckPage(name: "Sessions"), c2 = DeckPage(name: "Panes")
        let claude = DeckProfile(name: "Claude", apps: ["com.anthropic.claudefordesktop"], pages: [c1, c2])
        let deck = Deck(profiles: [now, claude], defaultProfile: now.id)
        XCTAssertEqual(Navigator.spread(at: DeckPosition(profile: now.id, page: n1.id), count: 4, in: deck).count, 4)
        XCTAssertEqual(Navigator.spread(at: DeckPosition(profile: claude.id, page: c2.id), count: 4, in: deck).map(\.page), [c2.id])
        // Without any Hub nothing changes (keys of before 0.26).
        var old = deck
        old.profiles[0].hub = false
        XCTAssertEqual(Navigator.spread(at: DeckPosition(profile: claude.id, page: c1.id), count: 4, in: old).count, 2)
        // The flag is kept in the keys file, and an old file without it reads as no Hub.
        let back = try? JSONDecoder().decode(Deck.self, from: JSONEncoder().encode(deck))
        XCTAssertEqual(back?.hubs.map(\.name), ["Now"])
        XCTAssertEqual(try? JSONDecoder().decode(DeckProfile.self, from: Data(#"{"name":"Old"}"#.utf8)).hub, false)
    }

    func testTheHubKey() {
        let hubs = [(id: "now", name: "Now"), (id: "life", name: "Life")]
        let ids = hubs.map(\.id)
        XCTAssertEqual(HubKey.target(current: "claude", hubs: ids), "now", "an app's page: the first Hub")
        XCTAssertEqual(HubKey.target(current: "now", hubs: ids), "life")
        XCTAssertEqual(HubKey.target(current: "life", hubs: ids), "now", "goes round")
        XCTAssertNil(HubKey.target(current: "x", hubs: []), "no Hub: the Pages key shows")
        XCTAssertNil(HubKey.target(current: "now", hubs: ["now"]), "the only Hub leads nowhere")
        XCTAssertEqual(HubKey.word(current: "claude", hubs: hubs), "Hub")
        XCTAssertEqual(HubKey.word(current: "now", hubs: hubs), "→ Life")
        XCTAssertEqual(HubKey.word(current: "life", hubs: hubs), "→ Now")
        XCTAssertEqual(HubKey.swipe(current: "now", hubs: ids, step: 1), "life")
        XCTAssertEqual(HubKey.swipe(current: "now", hubs: ids, step: -1), "life")
        XCTAssertNil(HubKey.swipe(current: "claude", hubs: ids, step: 1), "on an app's page a swipe turns its pages")
    }

    func testOnePageFillsAnIPadMini() {
        // iPad mini on its side, room for the keys (thin line taken off): 1117 × 620, gap 8.
        let sides = OnePage.sides(width: 1117, height: 620, gap: 8)
        XCTAssertEqual(sides.key, 193)
        XCTAssertEqual(sides.favourite, 92)
    }
}
