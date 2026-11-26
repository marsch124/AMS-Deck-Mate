import XCTest
@testable import DeckMateCore

/// A key's own colour (Mac 0.24): read and written as "RRGGBB", kept through the keys file, a file without
/// own colours written as before, and never laid over a colour that already says something.
final class KeyColourTests: XCTestCase {
    func testColourWords() {
        XCTAssertEqual(KeyColour.clean("#1f6bcc"), "1F6BCC")
        XCTAssertEqual(KeyColour.clean("blue"), "")
        XCTAssertEqual(KeyColour.clean("12345"), "")
        XCTAssertEqual(KeyColour.hex(red: 0, green: 0.5, blue: 1), "0080FF")
        let c = KeyColour.rgb("0080FF")!
        XCTAssertEqual(c.red, 0); XCTAssertEqual(c.green, 128.0 / 255); XCTAssertEqual(c.blue, 1)
        XCTAssertNil(KeyColour.rgb(""))
    }

    func testKeptThroughTheFileAndOldKeysUnchanged() throws {
        let link = DeckAction(type: .link, target: "amsfinancialsteward://open/budget")
        let coloured = DeckKey(title: "Budget", action: link, colour: "0D857A")
        let back = try JSONDecoder().decode(DeckKey.self, from: JSONEncoder().encode(coloured))
        XCTAssertEqual(back.colour, "0D857A")
        XCTAssertNotNil(back.ownColour)
        // A key without a colour of its own writes no "colour" at all, as before 0.24.
        let plain = String(decoding: try JSONEncoder().encode(DeckKey(title: "Budget", action: link)), as: UTF8.self)
        XCTAssertFalse(plain.contains("colour"))
        // A word that is no colour reads as none.
        let odd = try JSONDecoder().decode(DeckKey.self, from: Data(#"{"title":"x","colour":"teal","action":{"type":"link","target":"x"}}"#.utf8))
        XCTAssertEqual(odd.colour, "")
    }

    func testSignalColoursStay() {
        XCTAssertNil(DeckKey(action: DeckAction(type: .bodyBattery), colour: "0D857A").ownColour)
        XCTAssertNil(DeckKey(action: DeckAction(type: .training, target: "today"), colour: "0D857A").ownColour)
        XCTAssertNil(DeckKey(action: DeckAction(type: .garmin, target: "sleep"), colour: "0D857A").ownColour)
        XCTAssertNotNil(DeckKey(action: DeckAction(type: .app, target: "com.example"), colour: "0D857A").ownColour)
    }
}
