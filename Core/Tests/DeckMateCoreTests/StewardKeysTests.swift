import XCTest
@testable import DeckMateCore

/// The "Steward: to decide" key (Mac 0.25): what it reads from Steward's note and what it shows.
final class StewardKeysTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2026-12-01T10:00:00Z")!

    private func note(_ json: String) -> StewardKeys.Note? { StewardKeys.note(from: Data(json.utf8)) }

    func testWhatTheKeyShows() {
        let twelve = note(#"{"v":1,"written":"2026-12-01T09:59:00Z","waiting":12}"#)
        XCTAssertEqual(twelve?.waiting, 12)
        XCTAssertEqual(StewardKeys.glance(twelve, installed: true, now: now), Glance(big: "12", words: "to decide", tone: .text))
        XCTAssertEqual(StewardKeys.glance(note(#"{"v":1,"written":"2026-12-01T09:00:00Z","waiting":0}"#), installed: true, now: now),
                       Glance(big: "0", words: "all decided", tone: .media))
        // Older than 36 hours, no note at all, not on this Mac, a newer format.
        XCTAssertEqual(StewardKeys.glance(note(#"{"v":1,"written":"2026-11-29T21:00:00Z","waiting":3}"#), installed: true, now: now).words, "Open Steward")
        XCTAssertEqual(StewardKeys.glance(nil, installed: true, now: now), Glance(big: "–", words: "Open Steward", tone: .move))
        XCTAssertEqual(StewardKeys.glance(twelve, installed: false, now: now).words, "No Steward")
        XCTAssertEqual(StewardKeys.glance(note(#"{"v":2,"written":"2026-12-01T09:59:00Z"}"#), installed: true, now: now).words, "Update Deck Mate")
        // Not a note.
        XCTAssertNil(note(#"{"waiting":3}"#))
        XCTAssertNil(note(#"{"v":1,"written":"2026-12-01T09:59:00Z","waiting":-1}"#))
        XCTAssertTrue(DeckAction(type: .steward, target: StewardKeys.target).colourSpeaks)
    }
}
