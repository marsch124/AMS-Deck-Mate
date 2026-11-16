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

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.staticTexts["phoneVersion"].waitForExistence(timeout: 5))

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
