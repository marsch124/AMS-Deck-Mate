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
