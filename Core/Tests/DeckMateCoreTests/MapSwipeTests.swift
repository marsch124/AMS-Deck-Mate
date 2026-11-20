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
