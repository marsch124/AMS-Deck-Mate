import XCTest
@testable import DeckMateCore

/// The 0.20 rules of the double press: one small data test each.
final class TwicePressTests: XCTestCase {
    /// A key with a double press: the first press waits, a second one in time is the double press,
    /// and a wait that is over lets the usual action run exactly once.
    func testTheFirstPressWaitsAndTheSecondIsTheDoublePress() {
        XCTAssertEqual(TwicePress.wait, 0.33, "a third of a second")
        var presses = TwicePress()
        XCTAssertFalse(presses.waits("mac:3"))
        XCTAssertEqual(presses.press("mac:3", at: 10), .wait)
        XCTAssertTrue(presses.waits("mac:3"))
        XCTAssertEqual(presses.press("mac:4", at: 10.1), .wait, "every key waits apart")
        XCTAssertEqual(presses.press("mac:3", at: 10.2), .twice)
        XCTAssertFalse(presses.over("mac:3", first: 10), "the double press took it: no usual action after it")
        XCTAssertTrue(presses.over("mac:4", first: 10.1), "no second press: the usual action runs")
        XCTAssertFalse(presses.over("mac:4", first: 10.1), "and only once")
        XCTAssertEqual(presses.press("mac:3", at: 20), .wait, "a press after a double press starts afresh")
        XCTAssertEqual(presses.waiting.count, 1)
    }

    /// The third action of a key: its own on a double press, the usual one on every other key; old
    /// keys files read as before, and a key with a double press keeps it through the file.
    func testAKeyCanHaveADoublePress() throws {
        let usual = DeckAction(type: .app, target: "com.apple.mail")
        let held = DeckAction(type: .app, target: "com.apple.iCal")
        let twice = DeckAction(type: .app, target: "com.apple.Notes")
        let plain = DeckKey(action: usual)
        let both = DeckKey(action: usual, held: held, twice: twice)
        XCTAssertFalse(plain.hasTwice)
        XCTAssertEqual(plain.action(long: false, twice: true), usual, "two presses of a key without one: the usual action")
        XCTAssertTrue(both.hasTwice)
        XCTAssertEqual(both.action(long: false, twice: true), twice)
        XCTAssertEqual(both.action(long: true, twice: false), held)
        XCTAssertEqual(both.action(long: false, twice: false), usual)
        XCTAssertFalse(DeckKey(action: usual, twice: DeckAction.none).hasTwice, "Nothing = no double press")

        let read = try JSONDecoder().decode(DeckKey.self, from: JSONEncoder().encode(both))
        XCTAssertEqual(read.twice, twice)
        let old = Data(#"{"id":"11111111-2222-3333-4444-555555555555","title":"Mail","icon":"","action":{"type":"app","target":"com.apple.mail"}}"#.utf8)
        XCTAssertNil(try JSONDecoder().decode(DeckKey.self, from: old).twice, "a key from before 0.20 has none")

        var deck = Deck()
        var page = DeckPage(name: "Home")
        page.keys[0] = both
        var group = DeckProfile()
        group.pages = [page]
        deck.profiles = [group]
        let at = DeckPosition(profile: group.id, page: page.id, trail: [])
        XCTAssertEqual(Navigator.press(0, at: at, in: deck, twice: true).run, [twice])
        XCTAssertEqual(Navigator.press(0, at: at, in: deck).run, [usual])
        XCTAssertTrue(deck.allActions.contains(twice), "the rules that look through every action see it too")
    }

    /// A link can ask for the double press, and a broken double press is named.
    func testALinkAndTheBrokenKeyCheckKnowTheDoublePress() {
        let link = URL(string: "amsdeckmate://press?key=Mail&twice=1&pass=abc")!
        XCTAssertEqual(DeckLinks.command(from: link, pass: "abc"), .press(key: "Mail", long: false, twice: true))
        let plain = URL(string: "amsdeckmate://press?key=Mail&pass=abc")!
        XCTAssertEqual(DeckLinks.command(from: plain, pass: "abc"), .press(key: "Mail", long: false, twice: false))
        let key = DeckKey(action: DeckAction(type: .app, target: "com.apple.mail"),
                          twice: DeckAction(type: .app, target: "com.gone.app"))
        let world = KeyWorld(appExists: { $0 == "com.apple.mail" }, fileExists: { _ in true }, raycastExtension: { _, _ in true })
        XCTAssertEqual(KeyCheck.problem(key, in: DeckProfile(), deck: Deck(), world: world), "Double press: The app is not on this Mac")
    }
}
