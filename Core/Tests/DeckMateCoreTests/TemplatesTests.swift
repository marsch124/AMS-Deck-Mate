import XCTest
@testable import DeckMateCore

/// The ready-made page groups: one small data test each.
final class TemplatesTests: XCTestCase {
    func testEveryTemplateIsWellFormed() {
        XCTAssertEqual(Templates.all.map(\.id), ["finder", "safari", "notion", "fusion"])
        for t in Templates.all {
            XCTAssertTrue((10...15).contains(t.keys.count), t.name)
            let titles = t.keys.map(\.title)
            XCTAssertEqual(Set(titles).count, titles.count, "\(t.name): titles are unique")
            XCTAssertFalse(titles.contains(""), t.name)
            for k in t.keys {
                XCTAssertNotEqual(k.combo.keyName, "?", "\(t.name) \(k.title): key is in the table")
                XCTAssertFalse(k.combo.keyName.isEmpty)
            }
        }
    }

    func testAnsiKeys() {
        let n = KeyCombo.ansi("N", command: true)
        XCTAssertEqual(n?.keyCode, 45)
        XCTAssertEqual(n?.label, "⌘N")
        XCTAssertEqual(KeyCombo.ansi("n")?.keyName, "N")
        XCTAssertEqual(KeyCombo.ansi("←")?.keyCode, 123)
        XCTAssertNil(KeyCombo.ansi("€"))
    }

    func testProfileFromTemplate() {
        let t = Templates.all[0]
        var deck = Deck(profiles: [DeckProfile(name: "Main")], defaultProfile: nil)
        var p = Templates.profile(from: t, in: deck)
        XCTAssertEqual(p.name, "Finder")
        XCTAssertEqual(p.apps, ["com.apple.finder"])
        XCTAssertEqual(p.pages.count, 1)
        XCTAssertEqual(p.pages[0].name, "Page 1")
        XCTAssertEqual(Set(p.pages[0].keys.keys), Set(0..<t.keys.count))
        XCTAssertEqual(p.pages[0].keys[1]?.title, t.keys[1].title)
        XCTAssertEqual(p.pages[0].keys[1]?.action.type, .shortcut)
        XCTAssertEqual(p.pages[0].keys[1]?.action.combo, t.keys[1].combo)
        deck.profiles.append(p)
        p = Templates.profile(from: t, in: deck)
        XCTAssertEqual(p.name, "Finder (ready-made)")
        XCTAssertEqual(p.apps, [], "another group already names Finder")
    }
}
