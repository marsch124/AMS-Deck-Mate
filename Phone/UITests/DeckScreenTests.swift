import XCTest

/// The main screen and its settings sheet, on made-up keys (no Mac needed).
final class DeckScreenTests: XCTestCase {
    func testDeckAndSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["key0"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["deckPlace"].exists)

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.staticTexts["phoneVersion"].waitForExistence(timeout: 5))

        app.buttons["doneButton"].tap()
    }
}
