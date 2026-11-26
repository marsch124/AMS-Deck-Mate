import XCTest
@testable import DeckMateCore

/// The "Training today" key (Mac 0.23, iPhone and iPad 0.33): what it shows, when a note counts, what a
/// press does on each device, and the phone's guard before it opens a link.
final class TrainingKeysTests: XCTestCase {
    private let today = "2026-12-01"
    private let now = ISO8601DateFormatter().date(from: "2026-12-01T10:00:00Z")!

    private func note(_ sessions: String, day: String = "2026-12-01", written: String = "2026-12-01T06:50:12Z",
                      v: Int = 1) -> TrainingKeys.Note? {
        TrainingKeys.note(from: Data(#"{"v":\#(v),"day":"\#(day)","written":"\#(written)","sessions":[\#(sessions)],"more":1}"#.utf8))
    }

    private let run = #"{"key":"w12-tue-run","sport":"run","sportWord":"Run","title":"Easy run","minutes":45,"length":"45 min","state":"todo","canDone":true,"open":"amsworkoutsync://session/w12-tue-run","done":"amsworkoutsync://done/w12-tue-run"}"#
    private let runOnMac = #"{"key":"w12-tue-run","sport":"run","sportWord":"Run","title":"Easy run","length":"45 min","state":"todo","canDone":false,"open":"amsworkoutsync://session/w12-tue-run"}"#
    private let swimDone = #"{"key":"w12-tue-swim","sport":"swim","sportWord":"Swim","title":"Drills","length":"40 min","state":"done","canDone":false,"open":"amsworkoutsync://session/w12-tue-swim"}"#
    private let bikeMissed = #"{"key":"b","sport":"bike","sportWord":"Bike","state":"missed"}"#
    private let rest = #"{"key":"r","sport":"rest","sportWord":"Rest","state":"rest"}"#

    func testWhatTheKeyShows() {
        XCTAssertEqual(TrainingKeys.glance(note(run), installed: true), Glance(big: "45 min", words: "Run · to do"))
        // Only where a press logs the session does the key say so.
        XCTAssertEqual(TrainingKeys.glance(note(run), installed: true, logs: true), Glance(big: "45 min", words: "Run · press for done"))
        XCTAssertEqual(TrainingKeys.glance(note(runOnMac), installed: true, logs: true), Glance(big: "45 min", words: "Run · to do"))
        XCTAssertEqual(TrainingKeys.glance(note(swimDone + "," + run + "," + runOnMac), installed: true).words, "Run · to do +1")
        XCTAssertEqual(TrainingKeys.glance(note(#"{"sport":"swim","state":"todo"}"#), installed: true), Glance(big: "Swim", words: "to do"))
        XCTAssertEqual(TrainingKeys.glance(note(swimDone), installed: true), Glance(big: "Done", words: "Swim", tone: .media))
        XCTAssertEqual(TrainingKeys.glance(note(swimDone + "," + swimDone), installed: true).words, "2 sessions")
        XCTAssertEqual(TrainingKeys.glance(note(swimDone + "," + bikeMissed), installed: true), Glance(big: "Missed", words: "2 sessions", tone: .move))
        XCTAssertEqual(TrainingKeys.glance(note(rest), installed: true), Glance(big: "Rest", words: "Rest day"))
        XCTAssertEqual(TrainingKeys.glance(nil, installed: true), Glance(big: "–", words: "Open Triathlon", tone: .move))
        XCTAssertEqual(TrainingKeys.glance(nil, installed: false), Glance(words: "No Triathlon", tone: .move))
        XCTAssertEqual(TrainingKeys.glance(note(run, v: 2), installed: true).words, "Update Deck Mate")
        // Never red, whatever the note says.
        for sessions in [run, swimDone, bikeMissed, rest, swimDone + "," + bikeMissed] {
            XCTAssertNotEqual(TrainingKeys.glance(note(sessions), installed: true).tone, .raycast)
        }
    }

    func testOnlyANoteFromTodayCounts() {
        let fresh = note(run)
        let yesterday = note(run, day: "2026-11-30", written: "2026-11-30T18:00:00Z")
        let old = note(run, written: "2026-11-29T21:00:00Z")
        XCTAssertTrue(TrainingKeys.isFresh(fresh!, today: today, now: now))
        XCTAssertFalse(TrainingKeys.isFresh(yesterday!, today: today, now: now))
        XCTAssertFalse(TrainingKeys.isFresh(old!, today: today, now: now), "written more than 36 hours ago")
        XCTAssertFalse(TrainingKeys.isFresh(note(run, written: "soon")!, today: today, now: now))
        XCTAssertNil(TrainingKeys.best([yesterday, old, nil], today: today, now: now))
        // The newest of the fresh ones wins: the phone logged at 09:30, the Mac's file is from 06:50.
        let phone = note(swimDone, written: "2026-12-01T09:30:00Z")
        XCTAssertEqual(TrainingKeys.best([fresh, yesterday, phone], today: today, now: now), phone)
        XCTAssertNil(TrainingKeys.note(from: Data("no note".utf8)))
        XCTAssertNil(TrainingKeys.note(from: Data(count: TrainingKeys.largest + 1)))
        XCTAssertNil(TrainingKeys.note(from: nil))
        XCTAssertEqual(TrainingKeys.day(now, calendar: { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "Europe/Stockholm")!; return c }()), today)
    }

    func testAPressLogsOnlyOnThePhoneThatCan() {
        let done = "amsworkoutsync://done/w12-tue-run"
        let open = "amsworkoutsync://session/w12-tue-run"
        // The iPhone: its own note says the session can be logged right now.
        XCTAssertEqual(TrainingKeys.press(phone: note(run), best: note(run), today: today, now: now),
                       TrainingKeys.Press(onPhone: true, link: done, logs: true))
        // An iPad (cannot log): the session opens on the iPad.
        XCTAssertEqual(TrainingKeys.press(phone: note(runOnMac), best: note(run), today: today, now: now),
                       TrainingKeys.Press(onPhone: true, link: open, logs: false))
        // The Mac or the box, or a device that handed over no note: the Mac opens it, and never logs,
        // also when the newest note is the phone's and offers a done link.
        XCTAssertEqual(TrainingKeys.press(phone: nil, best: note(run), today: today, now: now),
                       TrainingKeys.Press(onPhone: false, link: open, logs: false))
        XCTAssertEqual(TrainingKeys.press(phone: nil, best: nil, today: today, now: now),
                       TrainingKeys.Press(onPhone: false, link: TrainingKeys.todayLink, logs: false))
        // Yesterday's note on the phone, all done, a rest day: only Triathlon Training's Today page.
        for old in [note(run, day: "2026-11-30"), note(swimDone), note(rest), note(run, v: 2)] {
            XCTAssertEqual(TrainingKeys.press(phone: old, best: nil, today: today, now: now),
                           TrainingKeys.Press(onPhone: true, link: TrainingKeys.todayLink, logs: false))
        }
        // A done link of another app's scheme is never used.
        let bad = note(#"{"sport":"run","state":"todo","canDone":true,"done":"https://example.com/done","open":"shortcuts://run"}"#)
        XCTAssertEqual(TrainingKeys.press(phone: bad, best: nil, today: today, now: now),
                       TrainingKeys.Press(onPhone: true, link: TrainingKeys.todayLink, logs: false))
    }

    func testThePhoneOpensOnlyWhatItsOwnNoteOffers() {
        let own = note(run)
        XCTAssertTrue(TrainingKeys.allows("amsworkoutsync://done/w12-tue-run", note: own))
        XCTAssertTrue(TrainingKeys.allows("amsworkoutsync://session/w12-tue-run", note: own))
        XCTAssertTrue(TrainingKeys.allows(TrainingKeys.todayLink, note: nil))
        XCTAssertFalse(TrainingKeys.allows("amsworkoutsync://done/another", note: own))
        XCTAssertFalse(TrainingKeys.allows("amsworkoutsync://done/w12-tue-run", note: nil))
        // A session that cannot be logged there offers no done link, whatever the Mac asks for.
        XCTAssertFalse(TrainingKeys.allows("amsworkoutsync://done/w12-tue-run", note: note(runOnMac)))
        XCTAssertFalse(TrainingKeys.allows("https://example.com", note: own))
        XCTAssertFalse(TrainingKeys.allows("tel:112", note: own))
    }

    func testWhatTheKeySaysAndHowItIsKept() throws {
        XCTAssertEqual(TrainingKeys.says(note(run), logs: true), "Easy run, 45 min, to do. A press logs it as done in Triathlon Training.")
        XCTAssertEqual(TrainingKeys.says(note(run), logs: false), "Easy run, 45 min, to do. A press opens it in Triathlon Training.")
        XCTAssertEqual(TrainingKeys.says(note(swimDone), logs: true), "Today's training is done. A press opens Triathlon Training.")
        XCTAssertEqual(TrainingKeys.says(nil, logs: false), "Shows today's training session. A press opens Triathlon Training.")
        // The key is kept under its own kind word, shows the glance, and both new messages need version 11.
        let key = DeckKey(action: DeckAction(type: .training, target: TrainingKeys.target))
        let kept = try JSONDecoder().decode(DeckKey.self, from: JSONEncoder().encode(key))
        XCTAssertEqual(kept.action.type, .training)
        let live = LiveKeys(glances: [TrainingKeys.glanceName: TrainingKeys.glance(note(swimDone), installed: true)])
        let shown = key.resolving(live)
        XCTAssertEqual(shown.title, "Swim")
        XCTAssertEqual(shown.icon, GlanceKeys.textPrefix + "Done")
        XCTAssertEqual(shown.action.kind, .media)
        XCTAssertEqual(key.showingTraining(TrainingKeys.glance(note(run), installed: true, logs: true)).title, "Run · press for done")
        XCTAssertEqual(PhoneLink.Message.training(note: nil).since, 11)
        XCTAssertEqual(PhoneLink.Message.open(link: TrainingKeys.todayLink).since, 11)
        XCTAssertTrue(ActionType.forKeys.contains(.training))
    }
}
