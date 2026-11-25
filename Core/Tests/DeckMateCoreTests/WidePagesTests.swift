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
        XCTAssertEqual(pages(p3.id, 4), [p3.id, p1.id, p2.id, folder.id], "goes round, then the folders fill up")
        XCTAssertEqual(pages(folder.id, 4), [folder.id, p3.id, p1.id], "a folder: its top page is not shown again")
        let spread = Navigator.spread(at: DeckPosition(profile: group.id, page: p1.id), count: 4, in: deck)
        XCTAssertEqual(spread.last?.trail, [p2.id], "a folder shown to fill up knows its page, for its Back key")
        XCTAssertEqual(pages(p2.id, 1), [p2.id])
        XCTAssertEqual(PhoneLink.tile(of: 47).tile, 3)
        XCTAssertEqual(PhoneLink.tile(of: 47).place, 2)
        XCTAssertEqual(PhoneLink.Message.wide(count: 4).since, 9)
    }

    /// 0.19: a page he put into a place stays there; going to one of them moves nothing; empty places
    /// are filled by the app; with every place taken another page comes in at place 1 for the moment.
    func testPlacedPagesStayInTheirPlaces() {
        let home = DeckPage(name: "Home")
        let apps = DeckPage(name: "Apps", parent: home.id), tutorials = DeckPage(name: "Tutorials", parent: home.id)
        let raycast = DeckPage(name: "Raycast", parent: home.id), glance = DeckPage(name: "At a glance", parent: home.id)
        var group = DeckProfile(name: "AMS Deck", pages: [home, apps, tutorials, raycast, glance])
        func pages(_ page: DeckPage, _ count: Int = 4) -> [String] {
            let deck = Deck(profiles: [group], defaultProfile: group.id)
            return Navigator.spread(at: DeckPosition(profile: group.id, page: page.id), count: count, in: deck)
                .map { group.page($0.page)?.name ?? "?" }
        }
        XCTAssertEqual(pages(glance), ["At a glance", "Apps", "Tutorials", "Raycast"], "no places: the page he is on comes first, as before")
        group.put(home.id, inPlace: 0); group.put(apps.id, inPlace: 1); group.put(raycast.id, inPlace: 2); group.put(glance.id, inPlace: 3)
        XCTAssertEqual(pages(home), ["Home", "Apps", "Raycast", "At a glance"])
        XCTAssertEqual(pages(glance), ["Home", "Apps", "Raycast", "At a glance"], "going to a placed page moves nothing")
        XCTAssertEqual(pages(tutorials), ["Tutorials", "Apps", "Raycast", "At a glance"], "every place taken: another page takes place 1 for the moment")
        XCTAssertEqual(pages(home, 2), ["Home", "Apps"], "an iPhone shows places 1 and 2")
        group.put(nil, inPlace: 2)
        XCTAssertEqual(pages(home), ["Home", "Apps", "Tutorials", "At a glance"], "an empty place is filled by the app")
        XCTAssertEqual(pages(tutorials), ["Home", "Apps", "Tutorials", "At a glance"], "a page that is not placed takes the empty place")
        group.put(glance.id, inPlace: 0)
        XCTAssertEqual(group.places, [glance.id, apps.id, nil, home.id], "a page put into a taken place swaps with it")
        group.pages.removeAll { $0.id == glance.id }
        XCTAssertEqual(pages(home), ["Tutorials", "Apps", "Raycast", "Home"], "a page that is gone leaves its place to the app")
        let deck = Deck(profiles: [group], defaultProfile: group.id)
        let at = DeckPosition(profile: group.id, page: raycast.id, trail: [home.id])
        let shown = Navigator.spread(at: at, count: 4, in: deck)
        XCTAssertEqual(Navigator.spot(of: at, in: shown), 0, "the page he is on took the first empty place")
        XCTAssertEqual(shown[1].trail, [home.id], "a placed folder knows its page, for its Back key")
        let saved = try? JSONDecoder().decode(DeckProfile.self, from: JSONEncoder().encode(group))
        XCTAssertEqual(saved?.places, group.places, "the places are saved with the keys")
        let old = try? JSONDecoder().decode(DeckProfile.self, from: Data(#"{"name":"Old"}"#.utf8))
        XCTAssertEqual(old?.places, [nil, nil, nil, nil], "an older file has no places")
        group.places = [nil, nil, nil, nil]
        XCTAssertFalse(group.hasPlaces)
    }

    /// 0.19: what a drop onto a place brings, and how tall the "Set up keys" window is.
    func testDroppingAPageOntoAPlaceAndTheWindowHeight() {
        let home = DeckPage(name: "Home"), apps = DeckPage(name: "Apps")
        var group = DeckProfile(name: "AMS Deck", pages: [home, apps])
        XCTAssertEqual(PagePlaces.page(dropped: PagePlaces.pageDrag + apps.id.uuidString, in: group), apps.id)
        XCTAssertNil(PagePlaces.page(dropped: PagePlaces.pageDrag + UUID().uuidString, in: group), "a page of another group")
        XCTAssertNil(PagePlaces.page(dropped: "deckkey:whatever:3", in: group), "a dragged key is not a page")
        XCTAssertNil(PagePlaces.page(dropped: PagePlaces.placeDrag + "1", in: group), "an empty place brings nothing")
        group.put(apps.id, inPlace: 1)
        XCTAssertEqual(PagePlaces.page(dropped: PagePlaces.placeDrag + "1", in: group), apps.id)
        XCTAssertNil(PagePlaces.page(dropped: PagePlaces.placeDrag + "none", in: group))
        XCTAssertEqual(PagePlaces.windowHeight(screen: 1080), 840)
        XCTAssertEqual(PagePlaces.windowHeight(screen: 720), 688, "a small screen: the window fits, the columns scroll")
        XCTAssertEqual(PagePlaces.windowHeight(screen: 821), 789, "his MacBook with larger text")
        XCTAssertEqual(PagePlaces.windowHeight(screen: nil), 840)
    }
}
