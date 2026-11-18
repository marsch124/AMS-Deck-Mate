import XCTest
@testable import DeckMateCore

final class ParagonFocusTests: XCTestCase {
    private let today = ParagonKeys.Day(year: 2026, month: 11, day: 18)
    private func data(_ text: String) -> Data { Data(text.utf8) }
    private let file = #"{"day":{"day":18,"month":11,"year":2026},"dueForReview":5,"dueToday":2,"inboxCount":4,"overdue":1,"items":[{"title":"Book the flights","dueText":"2 days over","isOverdue":true,"url":"amspara://Trip"},{"title":"Second","url":"amspara://Other"}]}"#

    func testSnapshotReadsPARAGONsFile() {
        let shot = ParagonKeys.snapshot(from: data(file))
        XCTAssertEqual(shot, ParagonKeys.Snapshot(day: today, dueToday: 2, overdue: 1, inbox: 4, nextTitle: "Book the flights",
                                                  nextDue: "2 days over", nextOverdue: true, nextLink: "amspara://Trip"))
        XCTAssertNil(ParagonKeys.snapshot(from: data("not a file")))
        // A link that is not PARAGON's own is never opened.
        let odd = ParagonKeys.snapshot(from: data(#"{"day":{"day":18,"month":11,"year":2026},"items":[{"title":"x","url":"https://example.com"}]}"#))
        XCTAssertNil(odd?.nextLink)
        XCTAssertEqual(odd?.nextTitle, "x")
    }

    func testGlancesOfInboxNextAndDue() {
        let shot = ParagonKeys.snapshot(from: data(file))
        XCTAssertEqual(ParagonKeys.glance(.inbox, snapshot: shot, today: today, installed: true), Glance(big: "4", words: "Inbox", tone: .text))
        XCTAssertEqual(ParagonKeys.glance(.next, snapshot: shot, today: today, installed: true),
                       Glance(big: "2 days over", words: "Book the flights", tone: .raycast))
        XCTAssertEqual(ParagonKeys.dueGlance(snapshot: shot, today: today, installed: true), Glance(big: "2", words: "1 overdue", tone: .raycast))
        let calm = ParagonKeys.Snapshot(day: today, dueToday: 3)
        XCTAssertEqual(ParagonKeys.dueGlance(snapshot: calm, today: today, installed: true), Glance(big: "3", words: "Due today"))
        XCTAssertEqual(ParagonKeys.glance(.inbox, snapshot: calm, today: today, installed: true), Glance(big: "0", words: "Inbox"))
        XCTAssertEqual(ParagonKeys.glance(.next, snapshot: calm, today: today, installed: true), Glance(words: "Nothing next"))
        XCTAssertNil(ParagonKeys.glance(.note, snapshot: shot, today: today, installed: true))
    }

    func testAnOldFileOrNoPARAGONShowsNoNumbers() {
        let shot = ParagonKeys.snapshot(from: data(file))
        let tomorrow = ParagonKeys.Day(year: 2026, month: 11, day: 19)
        XCTAssertEqual(ParagonKeys.glance(.inbox, snapshot: shot, today: tomorrow, installed: true), Glance(big: "–", words: "Open PARAGON"))
        XCTAssertEqual(ParagonKeys.dueGlance(snapshot: nil, today: today, installed: true), Glance(big: "–", words: "Open PARAGON"))
        XCTAssertEqual(ParagonKeys.dueGlance(snapshot: shot, today: today, installed: false), Glance(words: "No PARAGON"))
        // An old file's task is not opened either: the key opens Today.
        XCTAssertEqual(ParagonKeys.openLink(.next, snapshot: shot, today: tomorrow), "amspara:///list/today")
        XCTAssertEqual(ParagonKeys.openLink(.next, snapshot: shot, today: today), "amspara://Trip")
        XCTAssertEqual(ParagonKeys.openLink(.inbox, snapshot: shot, today: today), "amspara:///list/inbox")
    }

    func testCaptureLink() {
        let task = ParagonKeys.captureLink(text: " Call the bank\nabout the card & fees ", note: false)
        let items = URLComponents(url: task!, resolvingAgainstBaseURL: false)!.queryItems!
        XCTAssertEqual(task?.scheme, "amspara")
        XCTAssertEqual(task?.host, "capture")
        XCTAssertEqual(items.first { $0.name == "text" }?.value, "Call the bank about the card & fees")
        XCTAssertEqual(items.first { $0.name == "target" }?.value, "inbox")
        XCTAssertNil(items.first { $0.name == "note" })
        let note = ParagonKeys.captureLink(text: "An idea", note: true)
        XCTAssertTrue(note!.absoluteString.hasSuffix("note=1"))
        XCTAssertNil(ParagonKeys.captureLink(text: "  \n ", note: false))
        XCTAssertNil(ParagonKeys.captureLink(text: nil, note: true))
    }

    func testFocusPlanRidesInTheKeyAndCountsAlong() {
        let classic = FocusKeys.builtIn[0]
        XCTAssertEqual(classic.seconds, 65 * 60)
        let action = FocusKeys.action(for: classic)
        XCTAssertEqual(FocusKeys.plan(of: action), classic)
        XCTAssertEqual(FocusKeys.startLink("My 90")?.absoluteString,
                       "https://marsch124.github.io/AMS-PomoTimer/?action=start&template=My%2090")
        let began = Date(timeIntervalSince1970: 1_000_000)
        let run = FocusKeys.Run(plan: classic, began: began)
        XCTAssertEqual(FocusKeys.showing(run, now: began.addingTimeInterval(30)),
                       FocusKeys.Showing(name: "Classic Pomodoro", label: "Start-up", left: 90, kind: "startup"))
        // 2 + 3 minutes in, the first Pomodoro begins.
        XCTAssertEqual(FocusKeys.showing(run, now: began.addingTimeInterval(300)),
                       FocusKeys.Showing(name: "Classic Pomodoro", label: "Pomodoro", left: 1500, kind: "focus"))
        XCTAssertEqual(FocusKeys.showing(run, now: began.addingTimeInterval(65 * 60 + 10))?.done, true)
        XCTAssertNil(FocusKeys.showing(run, now: began.addingTimeInterval(65 * 60 + 60)))
        XCTAssertNil(FocusKeys.showing(nil, now: began))
        XCTAssertEqual(FocusKeys.tone("focus"), .raycast)
        XCTAssertEqual(FocusKeys.tone("pause"), .media)
        XCTAssertEqual(FocusKeys.tone("prep"), .text)
    }

    func testTemplatesFromAPomoTimerBackup() {
        let backup = #"{"app":"AMS PomoTimer","templates":[{"name":"Classic Pomodoro","steps":[{"type":"focus","label":"Pomodoro","seconds":1200}]},{"name":"My 90","steps":[{"type":"prep","label":"","seconds":300},{"type":"focus","label":"Focus 1/3","seconds":1800},{"type":"pause","label":"Pause","seconds":0}]},{"name":"","steps":[]}]}"#
        let plans = FocusKeys.plans(fromBackup: data(backup))
        XCTAssertEqual(plans.map(\.name), ["Classic Pomodoro", "My 90"])
        XCTAssertEqual(plans[1].steps, [FocusKeys.Step(kind: "prep", label: "Preparation", seconds: 300),
                                        FocusKeys.Step(kind: "focus", label: "Focus 1/3", seconds: 1800)])
        XCTAssertEqual(FocusKeys.plans(fromBackup: data("{}")), [])
        // His own Classic takes the ready-made one's place; the list stays 5 + 1.
        let choices = FocusKeys.choices(own: plans)
        XCTAssertEqual(choices.count, 6)
        XCTAssertEqual(choices.first { $0.name == "Classic Pomodoro" }?.seconds, 1200)
    }

    func testKeysAsTheyShow() {
        let focus = DeckKey(title: "Deep", action: FocusKeys.action(for: FocusKeys.builtIn[0]))
        let idle = focus.resolving(LiveKeys())
        XCTAssertEqual(idle.title, "Deep")
        let live = LiveKeys(focus: FocusKeys.Showing(name: "Classic Pomodoro", label: "Pause", left: 125, kind: "pause"))
        let running = focus.resolving(live)
        XCTAssertEqual(running.title, "Pause")
        XCTAssertEqual(GlanceKeys.bigWords(running.icon), "2:05")
        XCTAssertEqual(running.action.kind, .media)
        // A long press stops the count.
        XCTAssertEqual(focus.action(long: true), DeckAction(type: .zero, target: "Classic Pomodoro"))

        let inbox = DeckKey(action: DeckAction(type: .paragon, target: "inbox"))
            .resolving(LiveKeys(glances: ["paragon:inbox": Glance(big: "4", words: "Inbox", tone: .text)]))
        XCTAssertEqual(GlanceKeys.bigWords(inbox.icon), "4")
        XCTAssertEqual(inbox.action.kind, .text)
        XCTAssertEqual(DeckKey(action: DeckAction(type: .paragon, target: "note")).resolving(LiveKeys()).title, "Quick note")
    }

    func testPlaylistKeyShowsItsCover() {
        let link = "https://open.spotify.com/playlist/37i9dQZF1DX8NTLI2TtZa6?si=abc"
        XCTAssertEqual(PlaylistKeys.coverName(link), "list-playlist-37i9dQZF1DX8NTLI2TtZa6")
        XCTAssertEqual(PlaylistKeys.lookupURL(link)?.absoluteString,
                       "https://open.spotify.com/oembed?url=https://open.spotify.com/playlist/37i9dQZF1DX8NTLI2TtZa6")
        XCTAssertNil(PlaylistKeys.coverName("https://example.com/x"))
        let live = LiveKeys(covers: ["list-playlist-37i9dQZF1DX8NTLI2TtZa6"])
        let key = DeckKey(action: DeckAction(type: .playlist, target: link))
        XCTAssertEqual(GlanceKeys.coverTrack(key.resolving(live).icon), "list-playlist-37i9dQZF1DX8NTLI2TtZa6")
        XCTAssertNil(GlanceKeys.coverTrack(key.resolving(LiveKeys()).icon))
        // A drawing he chose stays.
        let own = DeckKey(icon: "music", action: DeckAction(type: .playlist, target: link))
        XCTAssertEqual(own.resolving(live).icon, "music")
    }
}
