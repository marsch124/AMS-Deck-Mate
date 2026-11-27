import XCTest
@testable import DeckMateCore

final class GroupLookTests: XCTestCase {
    func testStandardAndColours() {
        XCTAssertEqual(GroupLook.standard, .frames)
        XCTAssertEqual(GroupLook.from(raw: "nonsense"), .frames)
        XCTAssertEqual(GroupLook.from(raw: nil), .frames)
        XCTAssertEqual(GroupLook.from(raw: "lines"), .lines)
        XCTAssertEqual((0...4).map { GroupColour.forPlace($0) }, [.purple, .blue, .green, .red, .purple])
    }
}
