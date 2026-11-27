import XCTest
@testable import DeckMateCore

/// 0.27: app keys in their app's colour, keys that ask first ("press again").
final class KeyLookTests: XCTestCase {
    func testAppColourIsDeepNeverTealAndGraphiteWithoutColour() {
        // A light green icon → a green tile white words read on.
        let green = AppColour.tile(from: .init(0.68, 0.85, 0.64))
        XCTAssertGreaterThanOrEqual(AppColour.whiteContrast(green), 4.5)
        XCTAssertGreaterThan(green.green, green.red)
        // Teal goes to green or blue.
        let teal = AppColour.hsl(AppColour.tile(from: .init(0.14, 0.55, 0.55))).0
        XCTAssertFalse((150..<200).contains(teal))
        // A sea green (156°) counts as teal too.
        XCTAssertLessThan(AppColour.hsl(AppColour.tile(from: .init(0.05, 0.80, 0.51))).0, 150)
        // Black and white pixels only → graphite.
        let plain = Array(repeating: (0.0, 0.0, 0.0, 1.0), count: 50) + Array(repeating: (1.0, 1.0, 1.0, 1.0), count: 50)
        XCTAssertEqual(AppColour.tile(fromPixels: plain), AppColour.graphite)
        // The file keeps the look; standard = app colour.
        XCTAssertEqual(Deck().appKeys, .colour)
    }

    func testRiskyKeysAskAndPressAgainRuns() throws {
        let quit = DeckKey(action: DeckAction(type: .macDo, target: MacDo.quitAll.rawValue))
        let safari = DeckKey(action: DeckAction(type: .app, target: "com.apple.Safari"))
        XCTAssertTrue(AskFirst.marked(quit))
        XCTAssertFalse(AskFirst.marked(safari))
        XCTAssertTrue(AskFirst.asks(DeckKey(action: DeckAction(type: .toggle, target: SwitchKeys.awake)), long: false, twice: false))
        // His own setting wins both ways.
        var off = quit; off.askFirst = false
        XCTAssertFalse(AskFirst.asks(off, long: false, twice: false))
        var on = safari; on.askFirst = true
        XCTAssertTrue(AskFirst.asks(on, long: false, twice: false))
        // Written to the file only when set.
        let written = String(decoding: try JSONEncoder().encode(safari), as: UTF8.self)
        XCTAssertFalse(written.contains("askFirst"))
        XCTAssertEqual(try JSONDecoder().decode(DeckKey.self, from: JSONEncoder().encode(on)).askFirst, true)

        var wait = PressAgain()
        XCTAssertEqual(wait.press(quit.id, asks: true, long: true, twice: false, at: 10), .wait)
        XCTAssertEqual(wait.waitingKey(at: 12), quit.id)
        XCTAssertEqual(wait.press(quit.id, asks: true, long: false, twice: false, at: 12.5), .run(long: true, twice: false))
        // Too late: it waits again, nothing runs; another key ends the wait.
        XCTAssertEqual(wait.press(quit.id, asks: true, long: false, twice: false, at: 20), .wait)
        XCTAssertEqual(wait.press(quit.id, asks: true, long: false, twice: false, at: 23.5), .wait)
        XCTAssertEqual(wait.press(safari.id, asks: false, long: false, twice: false, at: 24), .usual)
        XCTAssertNil(wait.waitingKey(at: 24))
        XCTAssertEqual(DeckAction(type: .macDo, target: MacDo.emptyBin.rawValue).withoutAsking.quiet, true)
    }
}
