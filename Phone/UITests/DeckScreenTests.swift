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
        // His placement (0.15): the lock sits in the same line as Settings and music, right of them.
        let lock = app.buttons["privateLock"].frame
        XCTAssertEqual(lock.midY, gear.midY, accuracy: 3, "the lock is in line with Settings")
        XCTAssertGreaterThan(lock.midX, gear.midX, "the lock comes after Settings and music")
        XCTAssertTrue(app.descendants(matching: .any)["macGlance"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["mapGroup-1"].exists, "every page group has its ribbon (0.16)")
        snap(app, "navigation")

        // The plate is as tall as the keys (short on an upright iPhone), so the last page group is a scroll away.
        app.descendants(matching: .any)["navigationPicture"].swipeUp()
        XCTAssertTrue(app.buttons["mapPage-w1"].waitForExistence(timeout: 5))
    }

    /// 0.20: a swipe to the left hides the navigation picture behind the "Pages" tab and the keys grow; a tap brings it back.
    func testSwipeHidesNavigationPicture() {
        // He only ever holds the iPhone and iPad on their side.
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-forceMap", "-tabHintShown", "0", "-tabListUsed", "NO"]
        app.launch()

        let plate = app.descendants(matching: .any)["navigationPicture"]
        XCTAssertTrue(plate.waitForExistence(timeout: 10))
        // A run before may have left the picture hidden: bring it back first.
        if app.buttons["pagesTab"].isHittable { app.buttons["pagesTab"].tap(); sleep(1) }
        let before = app.descendants(matching: .any)["key0"].frame.width
        snap(app, "map-shown")
        plate.swipeLeft()
        let tab = app.buttons["pagesTab"]
        XCTAssertTrue(tab.waitForExistence(timeout: 5) && tab.isHittable, "the Pages tab stands where the picture was")
        sleep(1)
        let after = app.descendants(matching: .any)["key0"].frame.width
        print("KEY SIDE before \(before) after \(after)")
        // His pick (0.21): the favourites stand in a column left of the keys, and the keys grow.
        let column = app.descendants(matching: .any)["favouritesColumn"]
        XCTAssertTrue(column.exists, "the favourites stand in a column")
        XCTAssertLessThan(column.frame.maxX, app.descendants(matching: .any)["key0"].frame.minX, "left of the keys")
        XCTAssertGreaterThan(after, before, "the keys grow with the favourites in a column")
        print("FAVOURITE COLUMN width \(column.frame.width)")
        snap(app, "pages-tab")
        // 0.25: on an iPhone (no heading) the tab names the page group.
        if UIDevice.current.userInterfaceIdiom == .phone {
            XCTAssertTrue(tab.label.contains("Default"), "the tab says which page group shows")
        }
        XCTAssertTrue(app.descendants(matching: .any)["tabHint"].waitForExistence(timeout: 3), "the hint shows under the tab (0.25)")
        // 0.26: a swipe up on the tab goes to the next page group.
        // (The sample has no Mac to answer, so only check it never opens the picture; the rule has its own test.)
        tab.swipeUp()
        sleep(1)
        XCTAssertFalse(app.buttons["mapPage-p1"].isHittable, "an up or down swipe on the tab keeps the picture hidden")
        // 0.24: hold the tab for the page groups.
        tab.press(forDuration: 1.0)
        XCTAssertTrue(app.buttons["tabGroup-1"].waitForExistence(timeout: 5), "holding the tab lists the page groups")
        snap(app, "tab-menu")
        app.buttons["tabGroup-1"].tap()
        tab.tap()
        XCTAssertTrue(app.buttons["mapPage-p1"].waitForExistence(timeout: 5), "a tap on the tab brings the picture back")

        // Without the favourites row the keys are held back by the width: hidden, they grow.
        app.terminate()
        app.launchArguments = ["-sample", "-forceMap", "-showFavourites", "NO"]
        app.launch()
        XCTAssertTrue(plate.waitForExistence(timeout: 10))
        let narrow = app.descendants(matching: .any)["key0"].frame.width
        plate.swipeLeft()
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
        sleep(1)
        let wide = app.descendants(matching: .any)["key0"].frame.width
        print("KEY SIDE no favourites before \(narrow) after \(wide)")
        snap(app, "pages-tab-no-favourites")
        tab.tap()
        XCTAssertTrue(app.buttons["mapPage-p1"].waitForExistence(timeout: 5))
    }

    /// An iPhone on its side: the side panel on the left holds the heading and the navigation picture;
    /// his placement (0.16): the Mac's app, the lock, music and Settings stand in one column right of the keys.
    func testSidePanel() {
        let phone = UIDevice.current.userInterfaceIdiom == .phone
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        // As he has it: no favourites row, so the keys are as wide as the room allows.
        app.launchArguments = (phone ? ["-sample"] : ["-sample", "-sideways", "-forceMap"]) + ["-showFavourites", "NO"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["sidePanel"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["mapPage-p1"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["mapGroup-1"].exists, "every page group has its ribbon")
        XCTAssertTrue(app.descendants(matching: .any)["key14"].exists)

        let lastKey = app.descendants(matching: .any)["key4"].frame
        let bottomKey = app.descendants(matching: .any)["key14"].frame
        let gear = app.buttons["settingsButton"].frame
        let lock = app.buttons["privateLock"].frame
        let pill = app.descendants(matching: .any)["macGlance"].frame
        XCTAssertGreaterThan(gear.minX, lastKey.maxX - 4, "Settings stands right of the keys")
        XCTAssertGreaterThan(lock.minX, lastKey.maxX - 4, "the lock stands right of the keys")
        XCTAssertGreaterThan(pill.minX, lastKey.maxX - 4, "the Mac's app stands right of the keys")
        XCTAssertGreaterThan(gear.midY, lock.midY, "Settings is the lowest, the lock above it")
        XCTAssertLessThan(pill.midY, lock.midY, "the Mac's app is at the top")
        let favourites = app.descendants(matching: .any)["favouritesRow"]
        let keysBottom = favourites.exists ? favourites.frame.maxY : bottomKey.maxY
        XCTAssertLessThanOrEqual(gear.maxY, keysBottom + 6, "the column ends with the bottom keys")
        if phone {
            // The keys keep their size: the column stands in the free strip by the screen's edge, not in their room.
            XCTAssertGreaterThan(gear.midX, app.windows.firstMatch.frame.maxX - 60, "the column is in the strip by the edge")
        }

        // His placement (0.16): the heading in one line in the middle over the keys; the plate starts at the very top.
        let heading = app.staticTexts["deckPlace"].frame
        let topKey = app.descendants(matching: .any)["key0"].frame
        let middleKey = app.descendants(matching: .any)["key2"].frame
        XCTAssertLessThanOrEqual(heading.maxY, topKey.minY + 2, "the heading stands over the keys")
        XCTAssertEqual(heading.midX, middleKey.midX, accuracy: 30, "the heading is in the middle over the keys")
        XCTAssertLessThan(app.descendants(matching: .any)["sidePanel"].frame.minY, heading.maxY, "the plate starts at the top")
        if phone {
            XCTAssertGreaterThan(topKey.width, 85, "the keys keep their size")
        }
        snap(app, "sideways")

        // Settings still opens from there.
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["doneButton"].waitForExistence(timeout: 5))
        app.buttons["doneButton"].tap()

        // Turned the other way the camera cut-out is on the right: the column moves to the free left edge.
        if phone {
            XCUIDevice.shared.orientation = .landscapeRight
            let panel = app.descendants(matching: .any)["sidePanel"]
            let moved = NSPredicate { _, _ in app.buttons["settingsButton"].frame.midX < panel.frame.minX }
            wait(for: [expectation(for: moved, evaluatedWith: nil)], timeout: 6)
            snap(app, "sideways-turned")
        }
    }

    /// 0.28: an iPad on its side with several pages at once puts the keys first: the pages fill the screen,
    /// the favourites stand in a column as big as the keys, "Pages" opens the navigation picture as a plate.
    func testBigKeysOnItsSide() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "iPad only")
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-wide", "-showFavourites", "YES"]
        app.launch()

        let any = app.descendants(matching: .any)
        XCTAssertTrue(any["severalPages"].waitForExistence(timeout: 10))
        XCTAssertTrue(any["bigKeysLine"].exists)
        let key = any["key0"].frame, favourite = any["favourite0"].frame, screen = app.frame
        // The keys are big (they were about 50 points on an iPad mini, 0.27) and a favourite is as big as a key.
        XCTAssertGreaterThan(key.width, 85)
        XCTAssertEqual(favourite.width, key.width, accuracy: 1)
        // The favourites stand right of the last key of the upper pages, and the whole width is used.
        XCTAssertGreaterThan(favourite.minX, any["key19"].frame.maxX)
        XCTAssertGreaterThan(favourite.maxX, screen.width * 0.93)
        // The thin line is under the keys, with Settings in it.
        XCTAssertGreaterThan(app.buttons["settingsButton"].frame.minY, any["key59"].frame.maxY)
        snap(app, "bigkeys")
        // "Pages" opens the navigation picture as a plate; a page in it goes there and closes it.
        any["pagesKey"].tap()
        XCTAssertTrue(any["pagesPlate"].waitForExistence(timeout: 5))
        snap(app, "bigkeys-pages")
    }

    /// 0.30: on the big-keys screen a finger sliding in from the far left edge pulls the navigation picture
    /// over the keys; a tap beside it sends it away again.
    func testPullPagesFromTheLeftEdge() throws {
        try XCTSkipUnless(UIDevice.current.userInterfaceIdiom == .pad, "iPad only")
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchArguments = ["-sample", "-wide", "-showFavourites", "YES"]
        app.launch()

        let any = app.descendants(matching: .any)
        XCTAssertTrue(any["severalPages"].waitForExistence(timeout: 10))
        XCTAssertTrue(any["pagesEdge"].exists)
        XCTAssertFalse(any["pagesDrawer"].exists)
        let keyBefore = any["key0"].frame
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)).withOffset(CGVector(dx: 8, dy: 0))
        from.press(forDuration: 0.05, thenDragTo: from.withOffset(CGVector(dx: 260, dy: 0)))
        XCTAssertTrue(any["pagesDrawer"].waitForExistence(timeout: 5))
        // The keys keep their size and place behind it.
        XCTAssertEqual(any["key0"].frame, keyBefore)
        snap(app, "bigkeys-drawer")
        any["pagesDrawerShade"].tap()
        XCTAssertFalse(any["pagesDrawer"].waitForExistence(timeout: 2))
    }

    /// A picture for the eye, only when the run asks for it (TEST_RUNNER_DECK_SHOTS=<folder>).
    private func snap(_ app: XCUIApplication, _ name: String) {
        guard let folder = ProcessInfo.processInfo.environment["DECK_SHOTS"] else { return }
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: folder).appendingPathComponent(name + ".png"))
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
