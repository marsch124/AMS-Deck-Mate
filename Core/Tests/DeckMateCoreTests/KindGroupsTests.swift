import XCTest
@testable import DeckMateCore

final class KindGroupsTests: XCTestCase {
    private func name(_ kind: ActionType) -> String { kind.rawValue }

    func testEveryPickableKindIsInExactlyOneGroup() {
        for kind in ActionType.forKeys {
            XCTAssertEqual(KindGroup.all.filter { $0.kinds.contains(kind) }.count, 1, "\(kind)")
        }
        XCTAssertEqual(KindGroup.all.flatMap(\.kinds).count, ActionType.forKeys.count)
    }

    func testSearchFindsTimerAlsoByExtraWords() {
        XCTAssertTrue(KindGroup.search("timer", names: name).flatMap(\.kinds).contains(.timer))
        XCTAssertTrue(KindGroup.search("countdown", names: name).flatMap(\.kinds).contains(.timer))
    }

    func testEmptySearchReturnsAllGroups() {
        XCTAssertEqual(KindGroup.search("", names: name).count, KindGroup.all.count)
    }
}
