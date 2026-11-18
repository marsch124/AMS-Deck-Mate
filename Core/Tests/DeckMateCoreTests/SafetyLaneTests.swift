import XCTest
@testable import DeckMateCore

/// 0.16 safety lane: one small test per rule.
final class SafetyLaneTests: XCTestCase {
    private func emptyFolder() -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("deckmate-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    func testAFailedSaveIsToldOncePerRun() {
        var watch = SaveWatch()
        XCTAssertFalse(watch.saved(true))
        XCTAssertTrue(watch.saved(false))
        XCTAssertFalse(watch.saved(false))
        XCTAssertFalse(watch.saved(true))
        XCTAssertTrue(watch.saved(false))
    }

    func testTypedTextIsCutAtWholeCharacters() {
        let text = String(repeating: "a", count: 15) + "😀" + "b"
        let pieces = TypedText.pieces(text)
        XCTAssertEqual(pieces.map { String(decoding: $0, as: UTF16.self) }.joined(), text)
        XCTAssertEqual(pieces.count, 2)
        XCTAssertTrue(pieces.allSatisfy { String(decoding: $0, as: UTF16.self).utf16.count == $0.count })
        XCTAssertEqual(String(decoding: pieces[0], as: UTF16.self), String(repeating: "a", count: 15))
        XCTAssertTrue(TypedText.pieces("").isEmpty)
    }

    func testPicturesGoToICloudAndComeBackWithoutOverwriting() throws {
        let cloud = emptyFolder()
        let store = Store(folder: emptyFolder(), cloud: cloud)
        let key = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"))
        let group = DeckProfile(name: "One", pages: [DeckPage(name: "Page 1", keys: [0: key])])
        store.save(Deck(profiles: [group], defaultProfile: group.id))
        try FileManager.default.createDirectory(at: store.pictures, withIntermediateDirectories: true)
        try Data("one".utf8).write(to: store.pictures.appendingPathComponent("a.png"))
        try Data("two".utf8).write(to: store.pictures.appendingPathComponent("b.png"))
        XCTAssertTrue(store.copyToCloud())
        XCTAssertEqual(store.copyPicturesToCloud(), 0)                      // nothing new, nothing written
        try Data("three!".utf8).write(to: store.pictures.appendingPathComponent("b.png"))
        XCTAssertEqual(store.copyPicturesToCloud(), 1)                      // only the changed one

        // A new Mac: the keys and their pictures come back; a picture that exists is left alone.
        let fresh = Store(folder: emptyFolder(), cloud: cloud)
        try FileManager.default.createDirectory(at: fresh.pictures, withIntermediateDirectories: true)
        try Data("mine".utf8).write(to: fresh.pictures.appendingPathComponent("a.png"))
        guard case .fromCloud = fresh.start().how else { return XCTFail("not from iCloud") }
        XCTAssertEqual(try Data(contentsOf: fresh.pictures.appendingPathComponent("a.png")), Data("mine".utf8))
        XCTAssertEqual(try Data(contentsOf: fresh.pictures.appendingPathComponent("b.png")), Data("three!".utf8))
    }
}
