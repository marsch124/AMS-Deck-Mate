import XCTest

/// The main screen and its settings sheet, on made-up keys (no Mac needed).
final class DeckScreenTests: XCTestCase {
    func testDeckAndSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-locked"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["key0"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["deckPlace"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["pageDots"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["profileLock"].exists, "a profile picked by hand shows the lock")

        // Round B: the favourites row, the Mac at a glance and the music strip show with a Mac at 0.5.
        XCTAssertTrue(app.descendants(matching: .any)["favourite0"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["macGlance"].exists)
        XCTAssertTrue(app.buttons["musicPlay"].exists)
        XCTAssertTrue(app.buttons["musicLouder"].exists)

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["own-My own keys"].waitForExistence(timeout: 5))
        app.buttons["own-My own keys"].tap()
        XCTAssertTrue(app.buttons["ownGroup-Writing"].waitForExistence(timeout: 3), "own keys: pick a page group")
        app.buttons["own-Follow the Mac"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["showFavourites"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["showMusic"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["showGlance"].exists)
        // The settings are there, and a choice takes.
        let forest = app.buttons["ground-Forest"]
        XCTAssertTrue(forest.waitForExistence(timeout: 5))
        forest.tap()
        XCTAssertTrue(forest.isSelected)
        app.buttons["ground-Day and night"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["showClock"].exists)
        XCTAssertTrue(app.buttons["rest-Never"].exists)
        XCTAssertTrue(app.buttons["colour-Writing-Rust"].exists, "each profile can have a colour of its own")
        XCTAssertTrue(app.descendants(matching: .any)["batteryWarningSwitch"].exists)

        app.buttons["doneButton"].tap()
    }

    /// Still looking after 20 seconds: the hotspot hint shows and can be closed.
    func testHotspotHint() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-looking"]
        app.launch()

        let hint = app.descendants(matching: .any)["hotspotHint"]
        XCTAssertTrue(hint.waitForExistence(timeout: 10))
        app.buttons["closeHint"].tap()
        XCTAssertFalse(hint.waitForExistence(timeout: 2))
    }
}
