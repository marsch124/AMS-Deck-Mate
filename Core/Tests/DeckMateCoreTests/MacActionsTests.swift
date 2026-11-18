import XCTest
@testable import DeckMateCore

/// The 0.13 rules: one small data test each.
final class MacActionsTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    func testMacDoWhatOddTargetIsDesktop() {
        XCTAssertEqual(MacDoKeys.what("lock"), .lock)
        XCTAssertEqual(MacDoKeys.what("quitAll"), .quitAll)
        XCTAssertEqual(MacDoKeys.what("nonsense"), .desktop)
        XCTAssertEqual(MacDoKeys.what(""), .desktop)
    }

    func testMacDoAsksOnlyForTheThreeAndNotWhenQuiet() {
        for what in MacDo.allCases {
            let expected = [MacDo.quitAll, .emptyBin, .ejectAll].contains(what)
            XCTAssertEqual(MacDoKeys.asks(DeckAction(type: .macDo, target: what.rawValue)), expected, what.rawValue)
            XCTAssertFalse(MacDoKeys.asks(DeckAction(type: .macDo, target: what.rawValue, quiet: true)), what.rawValue)
        }
    }

    func testMacDoDoneWords() {
        XCTAssertEqual(MacDoKeys.done(DeckAction(type: .macDo, target: "lock")), "Locked the Mac")
        XCTAssertEqual(MacDoKeys.done(DeckAction(type: .macDo, target: "emptyBin")), "Asks on the Mac: empty the bin")
        XCTAssertEqual(MacDoKeys.done(DeckAction(type: .macDo, target: "emptyBin", quiet: true)), "Emptied the bin")
        XCTAssertEqual(MacDoKeys.done(DeckAction(type: .macDo, target: "odd")), "Showed the desktop")
    }

    func testListingWords() {
        XCTAssertEqual(Listing.words([]), "")
        XCTAssertEqual(Listing.words(["A"]), "A")
        XCTAssertEqual(Listing.words(["A", "B"]), "A and B")
        XCTAssertEqual(Listing.words(["A", "B", "C"]), "A, B and C")
        XCTAssertEqual(Listing.words(["A", "B", "C", "D", "E"], limit: 3), "A, B, C and 2 more")
        XCTAssertEqual(Listing.words(["A", "B", "C"], limit: 3), "A, B and C")
    }

    func testQuitToQuitRules() {
        let open = ["com.apple.finder", "com.me.deck", "com.apple.Safari", "COM.APPLE.SAFARI", "com.keep.me", "", "com.x.y"]
        let out = QuitKeys.toQuit(open: open, spared: ["com.KEEP.me"], own: "COM.ME.DECK")
        XCTAssertEqual(out, ["com.apple.Safari", "com.x.y"])
        XCTAssertEqual(QuitKeys.toQuit(open: ["COM.APPLE.FINDER"], spared: [], own: "x"), [])
    }

    func testQuitSparedOnlyAppSteps() {
        let action = DeckAction(type: .macDo, target: "quitAll", steps: [
            DeckAction(type: .app, target: "com.a"),
            DeckAction(type: .app, target: ""),
            DeckAction(type: .link, target: "https://x.com"),
        ])
        XCTAssertEqual(QuitKeys.spared(action), ["com.a"])
    }

    func testQuitQuestion() {
        XCTAssertNil(QuitKeys.question(names: [], stays: ["A"]))
        XCTAssertEqual(QuitKeys.question(names: ["Safari"], stays: [])?.title, "Quit Safari?")
        let three = QuitKeys.question(names: ["A", "B", "C"], stays: [])
        XCTAssertEqual(three?.title, "Quit 3 apps?")
        XCTAssertFalse(three!.words.contains("Stays open"))
        XCTAssertTrue(three!.words.hasPrefix("A, B and C will quit."))
        XCTAssertTrue(QuitKeys.question(names: ["A"], stays: ["Mail", "Notes"])!.words.hasSuffix("Stays open: Mail and Notes."))
    }

    func testBinQuestion() {
        XCTAssertNil(BinKeys.question(count: 0))
        XCTAssertTrue(BinKeys.question(count: 1)!.words.hasPrefix("1 thing will"))
        XCTAssertTrue(BinKeys.question(count: 12)!.words.hasPrefix("12 things will"))
        XCTAssertEqual(BinKeys.question(count: 1)?.title, "Empty the bin?")
    }

    func testEjectToEject() {
        typealias V = EjectKeys.Volume
        let mac = V(name: "Mac", path: "/Volumes/Mac", isInternal: true, isEjectable: false)
        let t7 = V(name: "T7", path: "/Volumes/T7", isInternal: false, isEjectable: true)
        let dmg = V(name: "Disk", path: "/Volumes/Disk", isInternal: true, isEjectable: true)
        let share = V(name: "NAS", path: "/Volumes/NAS", isInternal: false, isEjectable: true, isLocal: false)
        let odd = V(name: "Odd", path: "/System/Volumes/Data", isInternal: false, isEjectable: true)
        XCTAssertEqual(EjectKeys.toEject([mac, t7, dmg, share, odd]).map(\.name), ["T7", "Disk"])
    }

    func testEjectQuestionAndStayed() {
        XCTAssertNil(EjectKeys.question(names: []))
        XCTAssertEqual(EjectKeys.question(names: ["T7"])?.title, "Eject T7?")
        XCTAssertEqual(EjectKeys.question(names: ["A", "B"])?.title, "Eject 2 disks?")
        XCTAssertTrue(EjectKeys.question(names: ["A", "B"])!.words.hasPrefix("A and B will be ejected."))
        XCTAssertNil(EjectKeys.stayed([]))
        XCTAssertTrue(EjectKeys.stayed(["T7"])!.hasPrefix("T7 is still in use"))
        XCTAssertTrue(EjectKeys.stayed(["A", "B"])!.hasPrefix("A and B are still in use"))
    }

    func testMeetingLinkFindsKnownHosts() {
        XCTAssertEqual(MeetingKeys.link(in: ["Join: https://zoom.us/j/123?pwd=x now"]), "https://zoom.us/j/123?pwd=x")
        XCTAssertEqual(MeetingKeys.link(in: ["<https://teams.microsoft.com/l/meetup-join/abc>"]), "https://teams.microsoft.com/l/meetup-join/abc")
        XCTAssertEqual(MeetingKeys.link(in: ["See https://meet.google.com/abc-defg-hij."]), "https://meet.google.com/abc-defg-hij")
        XCTAssertEqual(MeetingKeys.link(in: ["https://company.zoom.us/j/9"]), "https://company.zoom.us/j/9")
    }

    func testMeetingLinkIgnoresOthersAndKeepsOrder() {
        XCTAssertNil(MeetingKeys.link(in: ["https://example.com/page", "no link", ""]))
        XCTAssertNil(MeetingKeys.link(in: ["https://notzoom.us/j/1"]))
        XCTAssertEqual(MeetingKeys.link(in: ["https://example.com", "https://meet.jit.si/a", "https://zoom.us/j/2"]), "https://meet.jit.si/a")
    }

    private func event(_ title: String, _ start: Double, _ end: Double, link: Bool = true) -> MeetingKeys.Event {
        MeetingKeys.Event(title: title, start: t0.addingTimeInterval(start), end: t0.addingTimeInterval(end),
                          texts: link ? ["https://zoom.us/j/\(title)"] : ["no link"])
    }

    func testMeetingPickSoonBeatsGoingOn() {
        let going = event("going", -1800, 1800)
        let soon = event("soon", 300, 3900)
        XCTAssertEqual(MeetingKeys.pick([going, soon], now: t0)?.title, "soon")
    }

    func testMeetingPickGoingOnBeatsLater() {
        let going = event("going", -1800, 1800)
        let later = event("later", 3600, 7200)
        XCTAssertEqual(MeetingKeys.pick([later, going], now: t0)?.title, "going")
    }

    func testMeetingPickLaterWhenNothingElse() {
        XCTAssertEqual(MeetingKeys.pick([event("later", 3600, 7200)], now: t0)?.title, "later")
        XCTAssertEqual(MeetingKeys.pick([event("later", 3600, 7200)], now: t0)?.link, "https://zoom.us/j/later")
        XCTAssertNil(MeetingKeys.pick([], now: t0))
    }

    func testMeetingPickSkipsNoLinkEndedAndTooFar() {
        XCTAssertNil(MeetingKeys.pick([event("nolink", 60, 600, link: false)], now: t0))
        XCTAssertNil(MeetingKeys.pick([event("ended", -3600, -60)], now: t0))
        XCTAssertNil(MeetingKeys.pick([event("far", 90_000, 93_000)], now: t0))
    }

    func testPlaylistUriFromLinks() {
        XCTAssertEqual(PlaylistKeys.uri("https://open.spotify.com/playlist/37i9dQZF1DX?si=abc123"), "spotify:playlist:37i9dQZF1DX")
        XCTAssertEqual(PlaylistKeys.uri("https://open.spotify.com/intl-de/playlist/37i9dQZF1DX"), "spotify:playlist:37i9dQZF1DX")
        XCTAssertEqual(PlaylistKeys.uri("  spotify:playlist:ABC123 \n"), "spotify:playlist:ABC123")
        XCTAssertEqual(PlaylistKeys.uri("spotify:user:name:playlist:ID9"), "spotify:playlist:ID9")
        XCTAssertEqual(PlaylistKeys.uri("https://open.spotify.com/album/AL1"), "spotify:album:AL1")
        XCTAssertEqual(PlaylistKeys.uri("https://open.spotify.com/track/TR1?si=x"), "spotify:track:TR1")
    }

    func testPlaylistUriRejectsOthers() {
        XCTAssertNil(PlaylistKeys.uri("https://example.com/playlist/ABC"))
        XCTAssertNil(PlaylistKeys.uri("rubbish"))
        XCTAssertNil(PlaylistKeys.uri(""))
        XCTAssertNil(PlaylistKeys.uri("https://open.spotify.com/playlist/"))
    }

    func testPlaylistKindWords() {
        XCTAssertEqual(PlaylistKeys.kind("https://open.spotify.com/track/TR1"), "song")
        XCTAssertEqual(PlaylistKeys.kind("spotify:show:SH1"), "podcast")
        XCTAssertEqual(PlaylistKeys.kind("spotify:episode:EP1"), "podcast episode")
        XCTAssertEqual(PlaylistKeys.kind("spotify:playlist:P1"), "playlist")
        XCTAssertNil(PlaylistKeys.kind("nope"))
    }

    func testSearchAddress() {
        XCTAssertNil(SearchKeys.address(.google, text: nil))
        XCTAssertNil(SearchKeys.address(.google, text: "  \n "))
        XCTAssertEqual(SearchKeys.address(.google, text: "a b&c"), "https://www.google.com/search?q=a%20b%26c")
        XCTAssertEqual(SearchKeys.address(.bing, text: "x\n\n  y"), "https://www.bing.com/search?q=x%20y")
    }

    func testSearchCopiedAddressStaysAndLongIsCut() {
        XCTAssertEqual(SearchKeys.address(.google, text: "https://example.com/a?b=1"), "https://example.com/a?b=1")
        let cut = SearchKeys.address(.google, text: String(repeating: "a", count: 400))
        XCTAssertEqual(cut, "https://www.google.com/search?q=" + String(repeating: "a", count: 300))
    }

    func testSearchEngineStartsAndOddTarget() {
        XCTAssertEqual(SearchKeys.engine("duckduckgo"), .duckduckgo)
        XCTAssertEqual(SearchKeys.engine("odd"), .google)
        XCTAssertEqual(SearchKeys.address(.duckduckgo, text: "q"), "https://duckduckgo.com/?q=q")
        XCTAssertEqual(SearchKeys.address(.wikipedia, text: "q"), "https://en.wikipedia.org/w/index.php?search=q")
        XCTAssertEqual(SearchKeys.address(.youtube, text: "q"), "https://www.youtube.com/results?search_query=q")
    }

    func testCounterRules() {
        var counts = CounterKeys.pressed([:], id: "a")
        counts = CounterKeys.pressed(counts, id: "a")
        counts = CounterKeys.pressed(counts, id: "b")
        XCTAssertEqual(counts, ["a": 2, "b": 1])
        XCTAssertEqual(CounterKeys.pressed(counts, id: ""), counts)
        XCTAssertEqual(CounterKeys.reset(counts, id: "a"), ["b": 1])
        XCTAssertEqual(CounterKeys.count(counts, id: "zzz"), 0)
        XCTAssertEqual(CounterKeys.pressed(["a": 99_999], id: "a")["a"], 99_999)
        XCTAssertEqual(CounterKeys.pressed(["a": 99_998], id: "a")["a"], 99_999)
    }

    func testStopwatchPressPauseGoOnReset() {
        var s = StopwatchKeys.pressed(.init(), id: "w", now: t0)
        XCTAssertTrue(s.isRunning)
        XCTAssertEqual(StopwatchKeys.seconds(s, now: t0.addingTimeInterval(10)), ["w": 10])
        s = StopwatchKeys.pressed(s, id: "w", now: t0.addingTimeInterval(10))
        XCTAssertFalse(s.isRunning)
        XCTAssertEqual(s.banked["w"], 10)
        XCTAssertEqual(StopwatchKeys.seconds(s, now: t0.addingTimeInterval(500)), ["w": 10])
        s = StopwatchKeys.pressed(s, id: "w", now: t0.addingTimeInterval(100))
        XCTAssertEqual(StopwatchKeys.seconds(s, now: t0.addingTimeInterval(105)), ["w": 15])
        s = StopwatchKeys.pressed(s, id: "w", now: t0.addingTimeInterval(120))
        XCTAssertEqual(s.banked["w"], 30)
        XCTAssertEqual(StopwatchKeys.reset(s, id: "w"), StopwatchKeys.State())
        XCTAssertEqual(StopwatchKeys.seconds(StopwatchKeys.reset(s, id: "w"), now: t0), [:])
        XCTAssertEqual(StopwatchKeys.pressed(.init(), id: "", now: t0), StopwatchKeys.State())
    }

    func testStopwatchStateRoundTrip() throws {
        let s = StopwatchKeys.State(banked: ["a": 12.5], since: ["b": t0])
        let data = try JSONEncoder().encode(s)
        XCTAssertEqual(try JSONDecoder().decode(StopwatchKeys.State.self, from: data), s)
    }

    func testActionTypeCountsUp() {
        XCTAssertTrue(ActionType.counter.countsUp)
        XCTAssertTrue(ActionType.stopwatch.countsUp)
        XCTAssertFalse(ActionType.timer.countsUp)
        XCTAssertFalse(ActionType.macDo.countsUp)
    }
}
