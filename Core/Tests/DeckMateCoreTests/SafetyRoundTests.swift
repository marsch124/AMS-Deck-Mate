import XCTest
@testable import DeckMateCore

/// The 0.15 rules: one or two small data tests each.
final class SafetyRoundTests: XCTestCase {
    private func emptyFolder() -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("deckmate-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func deck(named name: String = "One", keys: [Int: DeckKey] = [0: DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"))]) -> Deck {
        let group = DeckProfile(name: name, pages: [DeckPage(name: "Page 1", keys: keys)])
        return Deck(profiles: [group], defaultProfile: group.id)
    }

    private func data(_ json: String) -> Data { Data(json.utf8) }

    // MARK: A. Store

    private func copyName(_ day: String, _ n: Int) -> String {
        "deck \(day) 10.00.00.\(String(format: "%03d", n)).json"
    }

    func testOnlyTodaysOldestCopiesGoAndEveryEarlierDayKeepsItsLast() {
        let today = Date()
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        let day = { (back: Int) in f.string(from: today.addingTimeInterval(-Double(back) * 86_400)) }
        var names = (0..<25).map { copyName(day(0), $0) }
        names += (1...3).map { copyName(day($0), 0) }
        let gone = Set(Store.copiesToRemove(names, today: today))
        XCTAssertEqual(gone, Set((0..<5).map { copyName(day(0), $0) }))
    }

    func testACopyOlderThanThirtyDaysGoesAndNamedFilesNeverDo() {
        let today = Date()
        let old = copyName("2020-01-01", 0)
        let fresh = (0..<20).map { copyName("2026-11-18", $0) }
        let named = ["deck before PARAGON folder 2026-11-18 0925.json", "deck first take-over 2026-11-14.json",
                     "damaged 2026-11-18 10.00.00.000.json"]
        let gone = Store.copiesToRemove([old] + fresh + named, today: today)
        XCTAssertEqual(gone, [old])
        let marked = (1...12).map { "deck kept 2026-11-\(String(format: "%02d", $0)) 10.00.00.000 x.json" }
        XCTAssertEqual(Set(Store.copiesToRemove(marked, today: today)), Set(marked.prefix(2)))
    }

    func testKeepNowWritesAMarkedCopy() throws {
        let store = Store(folder: emptyFolder())
        store.save(deck())
        store.keepNow("before a page was deleted")
        let kept = try FileManager.default.contentsOfDirectory(atPath: store.backups.path)
        XCTAssertEqual(kept.filter { $0.hasPrefix(Store.markedPrefix) }.count, 1)
    }

    func testDamagedFileIsRecoveredFromICloudWhenBackupsHaveNothing() throws {
        let cloud = emptyFolder()
        let store = Store(folder: emptyFolder(), cloud: cloud)
        try JSONEncoder().encode(deck(named: "Cloud")).write(to: cloud.appendingPathComponent(CloudCopies.name(for: Date())))
        try Data("not json".utf8).write(to: store.file)
        let start = store.start()
        guard case .recovered = start.how else { return XCTFail("\(start.how)") }
        XCTAssertEqual(store.load()?.profiles.first?.name, "Cloud")
    }

    func testAFileWithNoPageGroupCountsAsDamaged() throws {
        let store = Store(folder: emptyFolder())
        store.save(deck(named: "Good"))
        store.save(deck(named: "Better"))           // "Good" is now a copy in Backups
        try Data("{}".utf8).write(to: store.file)
        let start = store.start()
        guard case .recovered = start.how else { return XCTFail("\(start.how)") }
        XCTAssertNotNil(start.deck)
        let kept = try FileManager.default.contentsOfDirectory(atPath: store.backups.path)
        XCTAssertEqual(kept.filter { $0.hasPrefix("damaged ") && $0.hasSuffix(".json") }.count, 1)
    }

    func testNoFileTakesTheICloudCopyOrIsFirst() throws {
        let cloud = emptyFolder()
        try JSONEncoder().encode(deck(named: "Cloud")).write(to: cloud.appendingPathComponent(CloudCopies.name(for: Date())))
        let store = Store(folder: emptyFolder(), cloud: cloud)
        guard case .fromCloud = store.start().how else { return XCTFail("not from cloud") }
        XCTAssertTrue(store.hasFile)
        XCTAssertEqual(Store(folder: emptyFolder()).start().how, .first)
    }

    func testSavingNeverLowersTheFormatNumber() {
        let store = Store(folder: emptyFolder())
        var later = deck()
        later.version = 9
        store.save(later)
        XCTAssertEqual(store.load()?.version, 9)
        let other = Store(folder: emptyFolder())
        var older = deck()
        older.version = 1
        other.save(older)
        XCTAssertEqual(other.load()?.version, Deck.currentVersion)
        XCTAssertEqual(Deck.currentVersion, 3)
    }

    // MARK: B. A key kind from a later version

    func testALaterKindSurvivesDecodeAndEncode() throws {
        let raw = "something from a later version"
        let action = try JSONDecoder().decode(DeckAction.self, from: data(#"{"type": "\#(raw)", "target": "x"}"#))
        XCTAssertEqual(action.type, ActionType.none)
        XCTAssertEqual(action.laterKind, raw)
        let again = try JSONDecoder().decode(DeckAction.self, from: JSONEncoder().encode(action))
        XCTAssertEqual(again.laterKind, raw)
        // A whole deck holding such a key loses nothing.
        let key = DeckKey(title: "New", action: action)
        let whole = try JSONDecoder().decode(Deck.self, from: JSONEncoder().encode(deck(keys: [0: key])))
        XCTAssertEqual(whole.profiles[0].pages[0].keys[0]?.action.laterKind, raw)
        XCTAssertEqual(whole.profiles[0].pages[0].keys[0]?.action.target, "x")
    }

    // MARK: C. Calmer colours, gym, old numbers

    func testCalmerColours() {
        XCTAssertEqual(GarminKeys.stress(10).tone, .media)
        XCTAssertEqual(GarminKeys.stress(40).tone, .web)
        XCTAssertEqual(GarminKeys.stress(60).tone, .web)
        XCTAssertEqual(GarminKeys.stress(90).tone, .text)
        XCTAssertEqual(BatteryKeys.kind(50), .media)
        XCTAssertEqual(BatteryKeys.kind(49), .web)
        XCTAssertEqual(BatteryKeys.kind(25), .web)
        XCTAssertEqual(BatteryKeys.kind(24), .text)
        XCTAssertEqual(BatteryKeys.kind(nil), .move)
        XCTAssertEqual(FocusKeys.tone("focus"), .shortcut)
    }

    private func board(pulse: Int, avg: Int, extra: String = "") -> Data {
        data("""
        {"today":{"steps":8000,"stepGoal":10000,"restingHr":\(pulse),"stressAvg":30},
         "restingTrend":{"avg7":[{"bpm":\(avg)}]}\(extra)}
        """)
    }

    func testPulseTone() {
        XCTAssertNil(GarminKeys.glances(fromBoard: board(pulse: 60, avg: 55))[.pulse]?.tone)
        XCTAssertEqual(GarminKeys.glances(fromBoard: board(pulse: 63, avg: 55))[.pulse]?.tone, .text)
    }

    func testGymNumbers() {
        let gym = GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, extra:
            #","gym":{"available":true,"latest":{"daysAgo":3},"week":{"sessions":2,"minutes":95}}"#))
        XCTAssertEqual(gym[.gymDays]?.big, "3")
        XCTAssertEqual(gym[.gymDays]?.words, "days since the gym")
        XCTAssertEqual(gym[.gymWeek]?.big, "2")
        XCTAssertEqual(gym[.gymWeek]?.words, "7 days · 95 min")
        XCTAssertEqual(gym[.gymWeek]?.tone, .media)
        let today = GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, extra:
            #","gym":{"available":true,"latest":{"daysAgo":0},"week":{"sessions":1,"minutes":40}}"#))
        XCTAssertEqual(today[.gymDays]?.big, "today")
        let none = GarminKeys.glances(fromBoard: board(pulse: 55, avg: 55, extra: #","gym":{"available":false}"#))
        XCTAssertEqual(none[.gymDays]?.big, "–")
        XCTAssertEqual(none[.gymDays]?.words, "No gym data yet")
    }

    func testOldNumbersShowGreyBlueAndTheTime() {
        let now = Date()
        let iso = ISO8601DateFormatter()
        func synced(hoursAgo: Double) -> Data {
            board(pulse: 55, avg: 55, extra: #","updated":{"watchSyncedAt":"\#(iso.string(from: now.addingTimeInterval(-hoursAgo * 3600)))"}"#)
        }
        let old = GarminKeys.glances(fromBoard: synced(hoursAgo: 4), now: now)[.steps]
        XCTAssertEqual(old?.tone, .move)
        XCTAssertTrue(old?.words.hasPrefix("As of ") == true)
        let fresh = GarminKeys.glances(fromBoard: synced(hoursAgo: 1), now: now)[.steps]
        XCTAssertNotEqual(fresh?.tone, .move)
        XCTAssertFalse(fresh?.words.hasPrefix("As of ") == true)
        XCTAssertNil(GarminKeys.oldSince(fromBoard: board(pulse: 55, avg: 55), now: now))
        XCTAssertEqual(GarminKeys.offGlance.big, "–")
        XCTAssertEqual(GarminKeys.offGlance.words, "Board off")
    }

    // MARK: D. The line to the iPhone

    func testVersionEightMessagesAndTheDeadLine() {
        XCTAssertEqual(PhoneLink.currentVersion, 8)
        let some = PhoneLink.Message.some(place: "p", keys: [PhoneLink.Key(index: 1, title: "A", picture: nil)])
        let all: [PhoneLink.Message] = [some, .ping, .pong]
        for message in all { XCTAssertEqual(message.since, 8) }
        var reader = PhoneLink.Reader()
        XCTAssertEqual(reader.add(all.map(PhoneLink.frame).reduce(Data(), +)), all)
        let t = Date()
        XCTAssertFalse(PhoneLink.isDead(lastHeard: t, now: t.addingTimeInterval(11)))
        XCTAssertTrue(PhoneLink.isDead(lastHeard: t, now: t.addingTimeInterval(13)))
    }

    func testOnlyChangedKeysAreSent() {
        let a = PhoneLink.Key(index: 0, title: "A", picture: nil)
        let b = PhoneLink.Key(index: 1, title: "B", picture: nil)
        let b2 = PhoneLink.Key(index: 1, title: "B2", picture: Data([1]))
        XCTAssertNil(PhoneLink.changed(from: nil, to: [a, b]))
        XCTAssertEqual(PhoneLink.changed(from: [a, b], to: [a, b]), [])
        XCTAssertEqual(PhoneLink.changed(from: [a, b], to: [a, b2]), [b2])
    }

    func testAnOversizedMessageFromTheiPhoneBreaksTheLine() {
        var reader = PhoneLink.Reader()
        reader.limit = PhoneLink.largestFromPhone
        var length = UInt32(PhoneLink.largestFromPhone + 1).bigEndian
        reader.feed(Data(bytes: &length, count: 4))
        var none: SecureLine.Session?
        XCTAssertNil(reader.next(&none))
        XCTAssertTrue(reader.broken)
    }

    // MARK: E. Links, scripts, drops

    func testLinksNeedTheRightPass() {
        func command(_ text: String, pass: String = "abc") -> DeckLinks.Command? {
            DeckLinks.command(from: URL(string: text)!, pass: pass)
        }
        XCTAssertEqual(command("amsdeckmate://press?key=K&pass=abc"), .press(key: "K", long: false))
        XCTAssertEqual(command("amsdeckmate://press?key=K&hold=1&pass=abc"), .press(key: "K", long: true))
        XCTAssertEqual(command("amsdeckmate://show?group=G&pass=abc"), .show(group: "G"))
        XCTAssertEqual(command("amsdeckmate://keys?pass=abc"), .toggleKeys)
        XCTAssertNil(command("amsdeckmate://press?key=K&pass=wrong"))
        XCTAssertNil(command("amsdeckmate://press?key=K"))
        XCTAssertNil(command("amsdeckmate://press?key=K&pass=", pass: ""))
        XCTAssertNil(command("https://press?key=K&pass=abc"))
        XCTAssertNil(command("amsdeckmate://unknown?pass=abc"))
    }

    func testFindByIdOrWordsFirstGroupFirstAndInFolders() throws {
        let shared = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "m"))
        let other = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "m"))
        let a = DeckProfile(name: "A", pages: [DeckPage(name: "P", keys: [0: shared])])
        let folderKey = DeckKey(title: "Deep", action: DeckAction(type: .link, target: "x"))
        let top = DeckPage(name: "Top", keys: [:])
        let folder = DeckPage(name: "Folder", parent: top.id, keys: [2: folderKey])
        let b = DeckProfile(name: "B", pages: [top, folder, DeckPage(name: "Q", keys: [0: other])])
        let deck = Deck(profiles: [a, b], defaultProfile: a.id)
        let name: (DeckKey) -> String = { $0.title }

        XCTAssertEqual(DeckLinks.find(shared.id.uuidString, in: deck, name: name)?.key.id, shared.id)
        XCTAssertEqual(DeckLinks.find("mAiL", in: deck, name: name)?.key.id, shared.id)
        XCTAssertEqual(DeckLinks.find("mail", in: deck, first: b.id, name: name)?.key.id, other.id)
        let found = try XCTUnwrap(DeckLinks.find("deep", in: deck, name: name))
        XCTAssertEqual(found.position.page, folder.id)
        XCTAssertEqual(found.position.profile, b.id)
        XCTAssertEqual(found.position.trail, [top.id])
        XCTAssertEqual(found.index, 2)
        XCTAssertNil(DeckLinks.find("nothing", in: deck, name: name))
    }

    func testRaycastScriptsOnlyForKeysThatDoSomething() {
        let app = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "m"))
        let back = DeckKey(title: "Back", action: DeckAction(type: .back))
        let folder = DeckKey(title: "Fold", action: DeckAction(type: .folder, target: UUID().uuidString))
        let next = DeckKey(title: "Next", action: DeckAction(type: .nextPage))
        let nameless = DeckKey(title: "", action: DeckAction(type: .link, target: "x"))
        let group = DeckProfile(name: "G", pages: [DeckPage(name: "P", keys: [0: app, 1: back, 2: folder, 3: next, 4: nameless])])
        let scripts = DeckLinks.scripts(for: Deck(profiles: [group]), pass: "secret") { $0.title }
        XCTAssertEqual(scripts.count, 1)
        let text = scripts.values.first ?? ""
        XCTAssertTrue(text.contains("@raycast.title Mail"))
        XCTAssertTrue(text.contains(DeckLinks.pressLink(id: app.id, pass: "secret")))
        XCTAssertTrue(text.contains(app.id.uuidString))
    }

    func testAskingFirstClearsQuietOnMacDoOnly() {
        let macDo = DeckAction(type: .macDo, target: "quitAll", quiet: true)
        XCTAssertFalse(macDo.askingFirst.quiet)
        let multi = DeckAction(type: .multi, steps: [macDo, DeckAction(type: .raycast, target: "raycast://x", quiet: true)])
        XCTAssertFalse(multi.askingFirst.steps[0].quiet)
        XCTAssertTrue(multi.askingFirst.steps[1].quiet)
        XCTAssertTrue(DeckAction(type: .raycast, target: "raycast://x", quiet: true).askingFirst.quiet)
    }

    func testDroppedThingsBecomeKeys() {
        let app = Drops.key(forFile: "/Applications/Safari.app", bundleID: "com.apple.Safari")
        XCTAssertEqual(app.action.type, .app)
        XCTAssertEqual(app.action.target, "com.apple.Safari")
        XCTAssertEqual(app.title, "")
        let file = Drops.key(forFile: "/Users/x/Documents/Plan 2027.pdf", bundleID: nil)
        XCTAssertEqual(file.action.type, .link)
        XCTAssertEqual(file.title, "Plan 2027")
        let link = Drops.key(forLink: "https://www.example.com/a")
        XCTAssertEqual(link?.title, "example.com")
        XCTAssertEqual(link?.action.type, .link)
        XCTAssertNil(Drops.key(forLink: "just some words"))
        XCTAssertNil(Drops.key(forLink: ""))
    }
}
