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

        // Round B: the favourites row, the Mac at a glance and the music strip show with a Mac at 0.5.
        XCTAssertTrue(app.descendants(matching: .any)["favourite0"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["macGlance"].exists)
        // Music is one small button; its plate opens on a tap and closes again.
        app.buttons["musicButton"].tap()
        XCTAssertTrue(app.buttons["musicPlay"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["musicLouder"].exists)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85)).tap()
        XCTAssertTrue(app.buttons["musicPlay"].waitForNonExistence(timeout: 5))
        // The link is one small dot; a tap says it in words.
        XCTAssertEqual(app.buttons["linkStatus"].value as? String, "Private line", "the lock beside the dot")
        app.buttons["linkStatus"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["linkStatusCard"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["privateMark"].exists)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85)).tap()
        XCTAssertTrue(app.descendants(matching: .any)["linkStatusCard"].waitForNonExistence(timeout: 5))

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["own-My own keys"].waitForExistence(timeout: 5))
        app.buttons["own-My own keys"].tap()
        XCTAssertTrue(app.buttons["ownGroup-Writing"].waitForExistence(timeout: 3), "own keys: pick a page group")
        app.buttons["own-Follow the Mac"].tap()
        // The lock lives in Settings since 0.10: the locked page group is the picked chip.
        XCTAssertTrue(app.buttons["lockGroup-Default"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["lockGroup-Default"].isSelected, "a page group picked by hand shows as locked")
        XCTAssertFalse(app.buttons["lockGroup-Automatic"].isSelected)
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

    /// The navigation picture (on an iPad held on its side; forced here): every page, the one showing marked.
    func testNavigationPicture() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-forceMap"]
        app.launch()

        XCTAssertTrue(app.buttons["mapPage-p1"].waitForExistence(timeout: 10), "the navigation picture shows every page")
        XCTAssertTrue(app.buttons["mapPage-p1"].isSelected, "the page showing now is marked")

        // His placement (0.13): the plate starts in line with the top keys; Settings and music sit bottom left, under it.
        let plate = app.descendants(matching: .any)["navigationPicture"].frame
        let topKey = app.descendants(matching: .any)["key0"].frame
        XCTAssertEqual(plate.minY, topKey.minY, accuracy: 3, "the plate's top is in line with the top keys")
        let gear = app.buttons["settingsButton"].frame
        XCTAssertGreaterThan(gear.midY, plate.maxY, "Settings sits under the plate")
        XCTAssertLessThan(gear.midX, plate.midX, "Settings sits at the left")
        XCTAssertTrue(app.descendants(matching: .any)["macGlance"].exists)

        // The plate is as tall as the keys (short on an upright iPhone), so the last page group is a scroll away.
        app.descendants(matching: .any)["navigationPicture"].swipeUp()
        XCTAssertTrue(app.buttons["mapPage-w1"].waitForExistence(timeout: 5))
    }

    /// An iPhone on its side: the side panel on the left holds the heading, settings and the navigation picture.
    func testSidePanel() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-sideways", "-forceMap"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["sidePanel"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["settingsButton"].exists)
        XCTAssertTrue(app.buttons["mapPage-p1"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["key14"].exists)
    }

    /// Still looking after 20 seconds: the hotspot hint shows and can be closed.
    /// The Mac sleeps: the screen goes black with "Mac asleep"; a tap brings the keys back.
    func testDarkWhileMacSleeps() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-macAsleep"]
        app.launch()
        let dark = app.descendants(matching: .any)["macAsleep"]
        XCTAssertTrue(dark.waitForExistence(timeout: 5))
        dark.tap()
        XCTAssertFalse(dark.waitForExistence(timeout: 1))
    }

    func testHotspotHint() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-looking"]
        app.launch()

        let hint = app.descendants(matching: .any)["hotspotHint"]
        XCTAssertTrue(hint.waitForExistence(timeout: 10))
        app.buttons["closeHint"].tap()
        XCTAssertFalse(hint.waitForExistence(timeout: 2))
    }

    /// While the Mac asks, the screen shows the four digits to compare; with an older Mac it says to update it.
    func testPairingNumberAndOldMac() {
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-waiting"]
        app.launch()
        XCTAssertTrue(app.staticTexts["pairCode"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["pairCode"].label, "4821")
        app.terminate()
        app.launchArguments = ["-sample", "-macTooOld"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Update AMS Deck Mate on your Mac"].waitForExistence(timeout: 5))
    }
}
