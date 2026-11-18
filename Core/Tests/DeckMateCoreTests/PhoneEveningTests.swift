import DeckMateCore
import XCTest

final class PhoneEveningTests: XCTestCase {
    func testEveningWindowAndBackoff() {
        let from = PhoneEvening.defaultFrom, to = PhoneEvening.defaultTo
        XCTAssertTrue(PhoneEvening.inWindow(now: 23 * 60, from: from, to: to))
        XCTAssertTrue(PhoneEvening.inWindow(now: 6 * 60, from: from, to: to))
        XCTAssertFalse(PhoneEvening.inWindow(now: 12 * 60, from: from, to: to))
        XCTAssertEqual(PhoneEvening.restMinutes(setting: 0, on: true, now: 22 * 60, from: from, to: to), 1)
        XCTAssertEqual(PhoneEvening.restMinutes(setting: 10, on: true, now: 22 * 60, from: from, to: to), 1)
        XCTAssertEqual(PhoneEvening.restMinutes(setting: 5, on: false, now: 22 * 60, from: from, to: to), 5)
        XCTAssertEqual(PhoneEvening.restMinutes(setting: 0, on: true, now: 12 * 60, from: from, to: to), 0)
        XCTAssertEqual([1, 2, 3, 4, 5, 6, 7, 50].map { PhoneBackoff.wait(afterFailures: $0) }, [1, 2, 4, 8, 15, 30, 30, 30])
    }
}
