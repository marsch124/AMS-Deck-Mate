import XCTest
@testable import DeckMateCore

final class BigKeysTests: XCTestCase {
    /// His iPad mini on its side, four pages: two above two, the favourites in a column, keys 93 points (were about 50).
    func testFourPagesFillAnIPadMini() {
        let plan = BigKeys.plan(width: 1117, height: 656, gap: 8, pages: 4, favourites: true)
        XCTAssertEqual(plan, BigKeys.Plan(across: 2, down: 2, side: 93, extras: .column))
        // Everything fits: 10 keys, the column, the gaps.
        let wide = 11 * 93.0 + 8 * 8 + 2 * BigKeys.between
        XCTAssertLessThanOrEqual(wide, 1117)
    }

    /// Two pages stand side by side with the favourites in a row under them: bigger keys than one above the other.
    func testTwoPagesSideBySide() {
        let plan = BigKeys.plan(width: 1117, height: 656, gap: 8, pages: 2, favourites: true)
        XCTAssertEqual(plan?.across, 2)
        XCTAssertEqual(plan?.down, 1)
        XCTAssertEqual(plan?.extras, BigKeys.Extras.row)
        XCTAssertGreaterThan(plan?.side ?? 0, 100)
    }

    func testWithoutFavouritesAndOutOfRange() {
        XCTAssertEqual(BigKeys.plan(width: 1117, height: 656, gap: 8, pages: 4, favourites: false)?.extras, BigKeys.Extras.none)
        XCTAssertNil(BigKeys.plan(width: 1117, height: 656, gap: 8, pages: 1, favourites: true))
        XCTAssertNil(BigKeys.plan(width: 1117, height: 656, gap: 8, pages: 5, favourites: true))
    }

    /// 0.31: an iPhone on its side with two pages uses the same rule (726 x 337 points on an iPhone 17 Pro):
    /// side by side, the favourites in a row under them, 64-point keys (before: 28 in a box made for one page).
    func testTwoPagesFillAnIPhoneOnItsSide() {
        let plan = BigKeys.plan(width: 726, height: 337, gap: 8, pages: 2, favourites: true)
        XCTAssertEqual(plan, BigKeys.Plan(across: 2, down: 1, side: 64, extras: .row))
        XCTAssertLessThanOrEqual(16 + 8 + 3 * 64.0 + 2 * 8 + BigKeys.between + 64, 337)
    }
}
