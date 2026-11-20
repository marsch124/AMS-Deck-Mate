import DeckMateCore
import XCTest

final class WidePagesTests: XCTestCase {
    /// "Several pages at once": the page he is on first, then the next top pages, going round;
    /// a folder counts from its top page; never more pages than there are.
    func testSeveralPagesAtOnce() {
        let p1 = DeckPage(name: "1"), p2 = DeckPage(name: "2"), p3 = DeckPage(name: "3")
        let folder = DeckPage(name: "Folder", parent: p2.id)
        let group = DeckProfile(name: "Home", pages: [p1, p2, folder, p3])
        let deck = Deck(profiles: [group], defaultProfile: group.id)
        let pages: (UUID, Int) -> [UUID] = { page, count in
            Navigator.spread(at: DeckPosition(profile: group.id, page: page), count: count, in: deck).map(\.page)
        }
        XCTAssertEqual(pages(p1.id, 2), [p1.id, p2.id])
        XCTAssertEqual(pages(p3.id, 4), [p3.id, p1.id, p2.id], "goes round; three top pages = three pages")
        XCTAssertEqual(pages(folder.id, 4), [folder.id, p3.id, p1.id], "a folder: its top page is not shown again")
        XCTAssertEqual(pages(p2.id, 1), [p2.id])
        XCTAssertEqual(PhoneLink.tile(of: 47).tile, 3)
        XCTAssertEqual(PhoneLink.tile(of: 47).place, 2)
        XCTAssertEqual(PhoneLink.Message.wide(count: 4).since, 9)
    }
}
