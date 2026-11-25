import XCTest
@testable import DeckMateCore

final class MapSwipeTests: XCTestCase {
    func testSwipeHidesAndPullShows() {
        // Open, a third of 230 to the left: hides; a short slide springs back.
        XCTAssertFalse(MapSwipe.opensAfter(wasOpen: true, moved: -80, predicted: -80, width: 230))
        XCTAssertTrue(MapSwipe.opensAfter(wasOpen: true, moved: -40, predicted: -60, width: 230))
        // A quick flick counts even when short.
        XCTAssertFalse(MapSwipe.opensAfter(wasOpen: true, moved: -30, predicted: -150, width: 230))
        // A slide the wrong way never changes it.
        XCTAssertTrue(MapSwipe.opensAfter(wasOpen: true, moved: 120, predicted: 200, width: 230))
        // Hidden: a pull to the right shows it, a pull to the left keeps it hidden.
        XCTAssertTrue(MapSwipe.opensAfter(wasOpen: false, moved: 80, predicted: 80, width: 200))
        XCTAssertFalse(MapSwipe.opensAfter(wasOpen: false, moved: -80, predicted: -200, width: 200))
        // While dragging: never below zero, only a little stretch past full.
        XCTAssertEqual(MapSwipe.shownWidth(wasOpen: true, moved: -300, width: 230), 0)
        XCTAssertEqual(MapSwipe.shownWidth(wasOpen: false, moved: 100, width: 200), 100)
        XCTAssertEqual(MapSwipe.shownWidth(wasOpen: true, moved: 100, width: 200), 215)
    }
}

final class EdgePullTests: XCTestCase {
    func testPullFromTheFarLeftEdge() {
        // Closed: only a sideways drag to the right that starts at the far left pulls the picture in.
        XCTAssertTrue(EdgePull.takes(startX: 10, open: false, across: 40, along: 5))
        XCTAssertFalse(EdgePull.takes(startX: 60, open: false, across: 40, along: 5))    // started on the keys
        XCTAssertFalse(EdgePull.takes(startX: 10, open: false, across: -40, along: 5))   // to the left
        XCTAssertFalse(EdgePull.takes(startX: 10, open: false, across: 20, along: 40))   // up or down
        // Open: a sideways drag anywhere moves it; up and down scroll the picture.
        XCTAssertTrue(EdgePull.takes(startX: 400, open: true, across: -40, along: 5))
        XCTAssertFalse(EdgePull.takes(startX: 400, open: true, across: -10, along: 40))
        // A swipe from the edge never changes the page.
        XCTAssertTrue(EdgePull.atEdge(startX: 32))
        XCTAssertFalse(EdgePull.atEdge(startX: 33))
        // Closed it stands fully outside (its width and the margin), in it stands at its place.
        XCTAssertEqual(EdgePull.offset(shown: 0, margin: 8), -328)
        XCTAssertEqual(EdgePull.offset(shown: 320, margin: 8), 0)
        XCTAssertEqual(EdgePull.offset(shown: 160, margin: 8), -164)
    }
}

final class FavouriteColumnTests: XCTestCase {
    func testColumnFitsBesideTheKeys() {
        // iPad on its side, favourites on: the keys were 178; with the column they grow, the favourites are smaller.
        let ipad = FavouriteColumn.sides(width: 1290, height: 744, gap: 8)
        XCTAssertGreaterThan(ipad.key, 178)
        XCTAssertLessThan(ipad.favourite, ipad.key)
        // The column of 5 is never taller than the 3 rows, and everything fits the width.
        XCTAssertLessThanOrEqual(5 * ipad.favourite + 4 * 8, 3 * ipad.key + 2 * 8)
        XCTAssertLessThanOrEqual(5 * ipad.key + 4 * 8 + 16 + ipad.favourite, 1290)
        // A short iPhone: the height decides.
        let phone = FavouriteColumn.sides(width: 680, height: 304, gap: 8)
        XCTAssertEqual(phone.key, 96)
        XCTAssertEqual(phone.favourite, 54)
    }
}

final class MapHidesBySelfTests: XCTestCase {
    func testHidesAfterAQuietMinute() {
        XCTAssertFalse(MapSwipe.hidesBySelf(on: true, shown: true, idle: 59))
        XCTAssertTrue(MapSwipe.hidesBySelf(on: true, shown: true, idle: 60))
        XCTAssertFalse(MapSwipe.hidesBySelf(on: false, shown: true, idle: 600), "switch off: it stays")
        XCTAssertFalse(MapSwipe.hidesBySelf(on: true, shown: false, idle: 600), "already hidden")
        // 0.23: the chosen quiet time.
        XCTAssertTrue(MapSwipe.hidesBySelf(on: true, shown: true, idle: 30, after: 30))
        XCTAssertFalse(MapSwipe.hidesBySelf(on: true, shown: true, idle: 90, after: 120))
        XCTAssertEqual(MapSwipe.quietChoices, [30, 60, 120])
    }
}

final class HeadingAsideTests: XCTestCase {
    func testHeadingStepsAsideOnlyOnASidewaysPhoneWithTheMapHidden() {
        XCTAssertFalse(MapSwipe.headingShows(phoneSideways: true, mapHidden: true))
        XCTAssertTrue(MapSwipe.headingShows(phoneSideways: true, mapHidden: false))
        XCTAssertTrue(MapSwipe.headingShows(phoneSideways: false, mapHidden: true), "the iPad keeps its heading")
    }
}

final class TabHintTests: XCTestCase {
    func testHintShowsThreeTimesUntilTheListIsUsed() {
        XCTAssertTrue(MapSwipe.tabHintShows(timesShown: 0, usedList: false))
        XCTAssertTrue(MapSwipe.tabHintShows(timesShown: 2, usedList: false))
        XCTAssertFalse(MapSwipe.tabHintShows(timesShown: 3, usedList: false))
        XCTAssertFalse(MapSwipe.tabHintShows(timesShown: 0, usedList: true), "once used, never again")
    }
}

final class TabGroupSwipeTests: XCTestCase {
    func testUpIsNextDownIsBefore() {
        XCTAssertEqual(MapSwipe.groupStep(across: 5, along: -90), 1)
        XCTAssertEqual(MapSwipe.groupStep(across: -10, along: 90), -1)
        XCTAssertNil(MapSwipe.groupStep(across: 0, along: 40), "too short")
        XCTAssertNil(MapSwipe.groupStep(across: 80, along: 90), "not clearly up or down")
    }

    /// 0.31: the same pull on an iPhone on its side with two pages; its edge zone starts behind the camera strip.
    func testThePullOnAnIPhoneWithTwoPages() {
        XCTAssertTrue(EdgePull.offered(bigKeys: false, phoneSideways: true, pages: 2, hasPicture: true))
        XCTAssertFalse(EdgePull.offered(bigKeys: false, phoneSideways: true, pages: 1, hasPicture: true), "one page: the picture stands beside the keys")
        XCTAssertFalse(EdgePull.offered(bigKeys: false, phoneSideways: false, pages: 2, hasPicture: true), "upright: no pull")
        XCTAssertFalse(EdgePull.offered(bigKeys: true, phoneSideways: false, pages: 4, hasPicture: false), "an old Mac sends no picture")
        XCTAssertTrue(EdgePull.offered(bigKeys: true, phoneSideways: false, pages: 4, hasPicture: true))
        XCTAssertFalse(EdgePull.atEdge(startX: 70), "an iPad: 70 points in is on the keys")
        XCTAssertTrue(EdgePull.atEdge(startX: 70, inset: 62), "an iPhone: 70 points in is just behind the camera strip")
        XCTAssertFalse(EdgePull.atEdge(startX: 120, inset: 62))
        XCTAssertTrue(EdgePull.takes(startX: 80, open: false, across: 40, along: 5, inset: 62))
        XCTAssertEqual(EdgePull.offset(shown: 0, margin: 70), -390, "closed, nothing of it peeks into the camera strip")
    }
}
