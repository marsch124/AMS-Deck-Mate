import DeckMateCore
import XCTest

final class PhoneLinkTests: XCTestCase {
    /// Messages arrive whole, also when the bytes come in odd pieces or several at once;
    /// rubbish closes the line.
    func testMessagesCrossTheLineInAnyPieces() {
        let keys = PhoneLink.Message.keys(place: "OmniFocus · Page 2",
                                          keys: [PhoneLink.Key(index: 0, title: "Mail", picture: Data([1, 2, 3])),
                                                 PhoneLink.Key(index: 14, title: "", picture: nil)])
        let sent: [PhoneLink.Message] = [.hello(phone: "Martin’s iPhone", token: nil), keys, .press(index: 7),
                                         .welcome(token: "abc", mac: "Mac"), .waiting, .refused]
        let wire = sent.map(PhoneLink.frame).reduce(Data(), +)
        var reader = PhoneLink.Reader()
        var got: [PhoneLink.Message] = []
        var at = 0
        while at < wire.count {                       // 5 bytes at a time
            got += reader.add(wire.subdata(in: at..<min(at + 5, wire.count)))
            at += 5
        }
        XCTAssertEqual(got, sent)
        var whole = PhoneLink.Reader()
        XCTAssertEqual(whole.add(wire), sent)

        var bad = PhoneLink.Reader()
        XCTAssertEqual(bad.add(Data([0xFF, 0xFF, 0xFF, 0xFF, 1])), [])
        XCTAssertTrue(bad.broken, "a length beyond 4 MB is not a message")
        var junk = PhoneLink.Reader()
        XCTAssertEqual(junk.add(Data([0, 0, 0, 2]) + Data("{x".utf8)), [])
        XCTAssertTrue(junk.broken)
    }

    /// An app key without words shows the app's name; his own words always win.
    func testAppKeysWithoutWordsShowTheAppName() {
        let name: (String) -> String = { ($0 as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "") }
        XCTAssertEqual(DeckKey(action: DeckAction(type: .app, target: "/Applications/Safari.app")).shownTitle(appName: name), "Safari")
        XCTAssertEqual(DeckKey(title: "Web", action: DeckAction(type: .app, target: "/Applications/Safari.app")).shownTitle(appName: name), "Web")
        XCTAssertEqual(DeckKey(title: "  ", action: DeckAction(type: .back)).shownTitle(appName: name), "")
        XCTAssertEqual(DeckKey(action: DeckAction(type: .link, target: "/x.app")).shownTitle(appName: name), "")
    }
}

/// Round B (Mac 0.5, iPhone and iPad 0.7): own keys, long press, favourites, the Mac at a glance.
final class RoundBTests: XCTestCase {
    private func deck() -> Deck {
        var folder = DeckPage(name: "Sound")
        var first = DeckPage(name: "Page 1")
        folder.parent = first.id
        folder.keys = [0: DeckKey(title: "Back", action: DeckAction(type: .back))]
        first.keys = [
            0: DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"),
                       held: DeckAction(type: .app, target: "com.apple.iCal")),
            1: DeckKey(title: "Sound", action: DeckAction(type: .folder, target: folder.id.uuidString)),
            2: DeckKey(title: "Safari", action: DeckAction(type: .app, target: "com.apple.Safari")),
        ]
        let main = DeckProfile(name: "Default", pages: [first, DeckPage(name: "Page 2"), folder])
        let writing = DeckProfile(name: "Writing", pages: [DeckPage(name: "Page 1")])
        return Deck(profiles: [main, writing], defaultProfile: main.id,
                    favourites: [0: DeckKey(title: "Play", action: DeckAction(type: .media, target: "playPause")),
                                 1: DeckKey(title: "Writing", action: DeckAction(type: .profile, target: writing.id.uuidString))])
    }

    /// A long press runs the key's second action; on a key without one it does the usual thing.
    func testLongPressRunsTheSecondAction() {
        let deck = deck()
        let at = Navigator.start(in: deck)!
        XCTAssertEqual(Navigator.press(0, at: at, in: deck).run.map(\.target), ["com.apple.mail"])
        XCTAssertEqual(Navigator.press(0, at: at, in: deck, long: true).run.map(\.target), ["com.apple.iCal"])
        XCTAssertEqual(Navigator.press(2, at: at, in: deck, long: true).run.map(\.target), ["com.apple.Safari"])
        XCTAssertTrue(deck.profiles[0].pages[0].keys[0]!.hasHeld)
        XCTAssertFalse(DeckKey(held: DeckAction.none).hasHeld, "a long press set to Nothing is no long press")
        XCTAssertFalse(Navigator.isLong(0.49))
        XCTAssertTrue(Navigator.isLong(0.5))
    }

    /// The long-press action is kept in the setup file, and a setup written before 0.5 still reads.
    func testLongPressAndFavouritesAreKept() throws {
        let deck = deck()
        let back = try JSONDecoder().decode(Deck.self, from: JSONEncoder().encode(deck))
        XCTAssertEqual(back, deck)
        let old = try JSONDecoder().decode(DeckKey.self, from: Data(#"{"title":"Mail","action":{"type":"app","target":"x"}}"#.utf8))
        XCTAssertNil(old.held)
        XCTAssertEqual(try JSONDecoder().decode(Deck.self, from: Data("{}".utf8)).favourites, [:])
    }

    /// A favourite acts from wherever the deck is; a folder or Back cannot be a favourite.
    func testFavouritesActFromAnywhere() {
        var deck = deck()
        let at = Navigator.start(in: deck)!
        XCTAssertEqual(Navigator.pressFavourite(0, at: at, in: deck).run.map(\.target), ["playPause"])
        XCTAssertEqual(Navigator.pressFavourite(1, at: at, in: deck).position.profile, deck.profiles[1].id)
        XCTAssertEqual(Navigator.pressFavourite(4, at: at, in: deck).position, at, "an empty place does nothing")
        deck.favourites[2] = DeckKey(title: "Back", action: DeckAction(type: .back))
        let inFolder = Navigator.press(1, at: at, in: deck).position
        XCTAssertEqual(Navigator.pressFavourite(2, at: inFolder, in: deck).position, inFolder)
        XCTAssertFalse(ActionType.folder.fitsFavourite)
        XCTAssertTrue(ActionType.profile.fitsFavourite)
    }

    /// "My own keys": the iPhone has its own place; moving there leaves the Mac's place alone,
    /// and the place is kept while the iPhone stays in its profile.
    func testOwnKeysHaveTheirOwnPlace() {
        let deck = deck()
        let mac = Navigator.start(in: deck)!
        let writing = deck.profiles[1].id.uuidString
        XCTAssertNil(Navigator.own(profile: nil, was: mac, in: deck), "nil = follow the Mac")
        XCTAssertEqual(Navigator.own(profile: writing, was: nil, in: deck)?.profile, deck.profiles[1].id)
        let own = Navigator.own(profile: deck.profiles[0].id.uuidString, was: nil, in: deck)!
        let moved = Navigator.press(1, at: own, in: deck).position
        XCTAssertNotEqual(moved, mac, "the iPhone went into the folder, the Mac did not")
        XCTAssertEqual(Navigator.own(profile: deck.profiles[0].id.uuidString, was: moved, in: deck), moved, "it keeps its place")
        XCTAssertEqual(Navigator.own(profile: "gone", was: nil, in: deck)?.profile, deck.profiles[0].id)
    }

    /// New messages only go to a side that said it knows them, and the Mac's version rides in welcome.
    func testNewMessagesNeedVersionThree() throws {
        XCTAssertEqual(PhoneLink.currentVersion, 6)
        XCTAssertEqual(PhoneLink.Message.press(index: 1).since, 1)
        XCTAssertEqual(PhoneLink.Message.page(step: 1).since, 2)
        let new: [PhoneLink.Message] = [.own(profile: "a"), .hold(index: 1), .favourite(index: 0, long: true),
                                        .music(command: .next), .favourites(keys: []), .mac(PhoneLink.MacNow())]
        XCTAssertEqual(new.map(\.since), [3, 3, 3, 3, 3, 3])
        var reader = PhoneLink.Reader()
        XCTAssertEqual(reader.add(new.map(PhoneLink.frame).reduce(Data(), +)), new)
        // A welcome from a Mac before 0.5 has no version.
        let old = try JSONDecoder().decode(PhoneLink.Message.self, from: Data(#"{"welcome":{"token":"t","mac":"Mac"}}"#.utf8))
        XCTAssertEqual(old, .welcome(token: "t", mac: "Mac", version: nil))
    }

    /// A tap on the navigation picture goes to that page; into a folder, Back leads to its page; unknown = nothing.
    func testNavigationPictureGoesToAPage() {
        let deck = deck()
        let main = deck.profiles[0]
        let second = Navigator.go(profile: main.id.uuidString, page: main.pages[1].id.uuidString, in: deck)
        XCTAssertEqual(second, DeckPosition(profile: main.id, page: main.pages[1].id))
        let folder = Navigator.go(profile: main.id.uuidString, page: main.pages[2].id.uuidString, in: deck)!
        XCTAssertEqual(Navigator.press(0, at: folder, in: deck).position.page, main.pages[0].id, "Back leads to the folder's page")
        XCTAssertNil(Navigator.go(profile: deck.profiles[1].id.uuidString, page: main.pages[1].id.uuidString, in: deck))
        XCTAssertNil(Navigator.go(profile: "gone", page: "gone", in: deck))
        XCTAssertEqual(PhoneLink.Message.go(profile: "a", page: "b").since, 4)
        XCTAssertEqual(PhoneLink.Message.map(groups: []).since, 4)
    }

    /// The top line: battery and the app in front; the volume steps by 6 and stays within 0–100.
    func testMacAtAGlanceWords() {
        XCTAssertEqual(PhoneLink.MacNow(battery: 82, app: "Safari").glance, "82 % · Safari")
        XCTAssertEqual(PhoneLink.MacNow(battery: 40, charging: true, app: "Mail").glance, "40 % charging · Mail")
        XCTAssertEqual(PhoneLink.MacNow(app: "Notes").glance, "Notes", "a Mac without a battery")
        XCTAssertEqual(PhoneLink.MacNow.volume(50, step: 1), 56)
        XCTAssertEqual(PhoneLink.MacNow.volume(3, step: -1), 0)
        XCTAssertEqual(PhoneLink.MacNow.volume(98, step: 1), 100)
    }

    /// A broken long-press action is found like a broken key.
    func testBrokenLongPressIsFound() {
        let deck = deck()
        let world = KeyWorld(appExists: { $0 != "gone" }, fileExists: { _ in true }, raycastExtension: { _, _ in true })
        let key = DeckKey(action: DeckAction(type: .app, target: "x"), held: DeckAction(type: .app, target: "gone"))
        XCTAssertEqual(KeyCheck.problem(key, in: deck.profiles[0], deck: deck, world: world), "Long press: The app is not on this Mac")
    }
}
