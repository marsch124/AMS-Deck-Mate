import XCTest
@testable import DeckMateCore

/// 0.8: the keys file looks after itself, the line to the iPhone is private, and the keys that
/// show copied texts and opened files.
final class HardeningTests: XCTestCase {
    private func emptyFolder() -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("deckmate-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func deck(named name: String) -> Deck {
        let key = DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail"))
        let group = DeckProfile(name: name, pages: [DeckPage(name: "Page 1", keys: [0: key])])
        return Deck(profiles: [group], defaultProfile: group.id)
    }

    func testADamagedKeysFileIsReplacedByTheNewestSafetyCopy() throws {
        let store = Store(folder: emptyFolder())
        XCTAssertEqual(store.start().how, .first)
        store.save(deck(named: "One"))
        store.save(deck(named: "Two"))          // "One" is now a safety copy
        store.save(deck(named: "Three"))        // and "Two"
        XCTAssertEqual(store.start().how, .loaded)

        try Data("{ not a setup".utf8).write(to: store.file)
        let start = store.start()
        guard case .recovered = start.how else { return XCTFail("\(start.how)") }
        XCTAssertEqual(start.deck?.profiles.first?.name, "Two")
        XCTAssertEqual(store.load()?.profiles.first?.name, "Two")
        let kept = try FileManager.default.contentsOfDirectory(atPath: store.backups.path)
        XCTAssertEqual(kept.filter { $0.hasPrefix("damaged ") }.count, 1)

        // Nothing readable left: it says so and still keeps the damaged file.
        let bare = Store(folder: emptyFolder())
        try Data("junk".utf8).write(to: bare.file)
        XCTAssertEqual(bare.start().how, .lost)
        XCTAssertFalse(bare.hasFile)
    }

    func testSafetyCopiesAreListedNewestFirstAndCanBeBroughtBack() throws {
        let store = Store(folder: emptyFolder())
        store.save(deck(named: "One"))
        store.save(deck(named: "Two"))
        store.save(deck(named: "Three"))
        try Data("junk".utf8).write(to: store.backups.appendingPathComponent("deck broken.json"))
        let copies = store.copies()
        XCTAssertEqual(copies.count, 2)                                 // the unreadable one is left out
        XCTAssertEqual(copies.first.flatMap(store.deck(of:))?.profiles.first?.name, "Two")
        XCTAssertEqual(copies.first?.words, "1 page group · 1 key")
    }

    func testTheDiaryIsCutBackOnlyWhenLong() {
        XCTAssertNil(Diary.trimmed("a\nb\n", over: 3, keep: 2))
        XCTAssertEqual(Diary.trimmed("a\nb\nc\nd\n", over: 3, keep: 2), "c\nd\n")
    }

    // MARK: The private line

    private func line() -> (phone: SecureLine.Session, mac: SecureLine.Session) {
        let phone = SecureLine.Keys(), mac = SecureLine.Keys()
        return (SecureLine.session(phone, role: .phone, other: mac.publicKey)!,
                SecureLine.session(mac, role: .mac, other: phone.publicKey)!)
    }

    func testBothEndsOfAPrivateLineReadEachOtherAndNobodyElse() {
        var (phone, mac) = line()
        XCTAssertEqual(phone.code, mac.code)
        XCTAssertEqual(phone.code.count, 4)
        let sealed = phone.seal(Data("press".utf8))!
        XCTAssertNil(String(data: sealed, encoding: .utf8).flatMap { $0.contains("press") ? $0 : nil })
        XCTAssertEqual(mac.open(sealed), Data("press".utf8))
        XCTAssertEqual(phone.open(mac.seal(Data("keys".utf8))!), Data("keys".utf8))

        // A stranger with keys of their own gets another number and cannot read the line.
        var stranger = SecureLine.session(SecureLine.Keys(), role: .mac, other: SecureLine.Keys().publicKey)!
        XCTAssertNil(stranger.open(phone.seal(Data("press".utf8))!))
    }

    func testAChangedOrRepeatedMessageIsRefused() {
        var (phone, mac) = line()
        let first = phone.seal(Data("press 1".utf8))!
        var changed = first
        changed[0] ^= 1
        XCTAssertNil(mac.open(changed))
        XCTAssertEqual(mac.open(first), Data("press 1".utf8))
        XCTAssertNil(mac.open(first))                                   // the same message again
        let second = phone.seal(Data("press 2".utf8))!
        XCTAssertEqual(mac.open(second), Data("press 2".utf8))
    }

    func testTheProofFitsOnlyThisLineThisSecretAndThisSide() {
        let (phone, mac) = line()
        let proof = phone.proof(secret: "s3cret", by: .phone)
        XCTAssertTrue(mac.checks(proof, secret: "s3cret", by: .phone))
        XCTAssertFalse(mac.checks(proof, secret: "other", by: .phone))
        XCTAssertFalse(mac.checks(proof, secret: "s3cret", by: .mac))
        XCTAssertFalse(line().mac.checks(proof, secret: "s3cret", by: .phone))   // another line
        XCTAssertFalse(mac.checks(nil, secret: "s3cret", by: .phone))
        XCTAssertEqual(SecureLine.promise(for: Data([1, 2, 3])).count, 32)
    }

    func testASealedLineCarriesMessagesAndRefusesReadableOnes() {
        let (phoneLine, macLine) = line()
        var phone: SecureLine.Session? = phoneLine
        var mac: SecureLine.Session? = macLine
        var reader = PhoneLink.Reader()
        reader.feed(PhoneLink.sealed(PhoneLink.frame(.press(index: 3)), by: &phone)!)
        reader.feed(PhoneLink.sealed(PhoneLink.frame(.page(step: 1)), by: &phone)!)
        XCTAssertEqual(reader.next(&mac), .press(index: 3))
        XCTAssertEqual(reader.next(&mac), .page(step: 1))
        XCTAssertNil(reader.next(&mac))
        XCTAssertFalse(reader.broken)
        reader.feed(PhoneLink.frame(.press(index: 4)))                  // readable on a sealed line
        XCTAssertNil(reader.next(&mac))
        XCTAssertTrue(reader.broken)

        var none: SecureLine.Session?
        XCTAssertNil(PhoneLink.sealed(PhoneLink.frame(.waiting), by: &none))   // nothing goes out unsealed
        XCTAssertEqual(PhoneLink.Message.secure(promise: "p", key: nil).since, 7)
    }

    // MARK: Keys that change by themselves

    func testLastCopiedTexts() {
        var list = CopiedTexts.after([], copied: "one")
        list = CopiedTexts.after(list, copied: "two")
        list = CopiedTexts.after(list, copied: "   ")                    // nothing worth keeping
        list = CopiedTexts.after(list, copied: nil)
        XCTAssertEqual(list, ["two", "one"])
        XCTAssertEqual(CopiedTexts.after(list, copied: "one"), ["one", "two"])   // pasted again: moves up, once
        for text in ["3", "4", "5"] { list = CopiedTexts.after(list, copied: text) }
        XCTAssertEqual(list.count, CopiedTexts.kept)
        XCTAssertEqual(CopiedTexts.text(number: 1, in: ["now", "before"]), "before")
        XCTAssertNil(CopiedTexts.text(number: 2, in: ["now", "before"]))
        XCTAssertEqual(CopiedTexts.preview("Meeting notes\nfor Monday morning"), "Meeting notes for…")
        XCTAssertEqual(CopiedTexts.preview(" short "), "short")
    }

    func testRecentFilesAndTheKeysThatShowThem() {
        let home = "/Users/me"
        let files = RecentFiles.pick(["/Users/me/Library/Caches/a.png", "/Users/me/Documents/Plan.pdf",
                                      "/Users/me/.config/x.json", "/Applications/Safari.app/Contents/Info.plist",
                                      "/Users/me/Documents/Plan.pdf", "/Users/me/Apps/Tool.app/Contents/x",
                                      "/Users/me/Downloads/Trip.ics"], home: home)
        XCTAssertEqual(files, ["/Users/me/Documents/Plan.pdf", "/Users/me/Downloads/Trip.ics"])
        let live = LiveKeys(apps: ["front", "mail"], copied: ["now", "Earlier text"], files: files)

        let file = DeckKey(action: DeckAction(type: .recentFile, target: "1")).resolving(live)
        XCTAssertEqual(file.title, "Plan.pdf")
        XCTAssertEqual(file.action, DeckAction(type: .link, target: "/Users/me/Documents/Plan.pdf"))
        XCTAssertEqual(DeckKey(action: DeckAction(type: .recentFile, target: "3")).resolving(live).title, "Recent file")

        let copied = DeckKey(action: DeckAction(type: .copied, target: "1")).resolving(live)
        XCTAssertEqual(copied.title, "Earlier text")
        XCTAssertEqual(copied.action.type, .copied)
        XCTAssertEqual(DeckKey(action: DeckAction(type: .recent, target: "1")).resolving(live).action,
                       DeckAction(type: .app, target: "mail"))

        var deck = deck(named: "One")
        XCTAssertFalse(deck.uses(.copied))
        deck.profiles[0].pages[0].keys[1] = DeckKey(action: DeckAction(type: .multi, steps: [DeckAction(type: .copied, target: "1")]))
        XCTAssertTrue(deck.uses(.copied))
    }

    func testAWeeklyCopyGoesToTheCloudFolderAndCanBeBroughtBack() throws {
        let day = Date(timeIntervalSince1970: 1_794_800_000)
        XCTAssertTrue(CloudCopies.due(last: nil, now: day))
        XCTAssertFalse(CloudCopies.due(last: day.addingTimeInterval(-6 * 86_400), now: day))
        XCTAssertTrue(CloudCopies.due(last: day.addingTimeInterval(-7 * 86_400), now: day))
        XCTAssertTrue(CloudCopies.name(for: day).hasPrefix("deck 20"))

        let cloud = emptyFolder().appendingPathComponent("AMS Deck Mate")
        let store = Store(folder: emptyFolder(), cloud: cloud)
        XCTAssertFalse(store.copyToCloud(now: day))                      // no keys file yet
        store.save(deck(named: "One"))
        for week in 0..<10 { XCTAssertTrue(store.copyToCloud(now: day.addingTimeInterval(Double(week) * CloudCopies.every))) }
        XCTAssertTrue(store.copyToCloud(now: day.addingTimeInterval(9 * CloudCopies.every)))   // same day: written over
        let kept = try FileManager.default.contentsOfDirectory(atPath: cloud.path)
        XCTAssertEqual(kept.count, CloudCopies.kept)
        XCTAssertFalse(kept.contains(CloudCopies.name(for: day)))        // the oldest are gone

        let copies = store.copies()
        XCTAssertEqual(copies.filter(\.inCloud).count, CloudCopies.kept)
        XCTAssertEqual(copies.first(where: \.inCloud).flatMap(store.deck(of:))?.profiles.first?.name, "One")
        XCTAssertFalse(Store(folder: emptyFolder()).copyToCloud())       // no iCloud folder: nothing is made
    }

    func testTheListOfCopiedTexts() {
        XCTAssertEqual(CopiedTexts.choices(in: ["now", "a", "b", "c"]), ["a", "b", "c"])
        XCTAssertEqual(CopiedTexts.choices(in: ["now"]), [])
        XCTAssertEqual(CopiedTexts.line("one\ntwo   three"), "one two three")
        XCTAssertEqual(CopiedTexts.line(String(repeating: "x", count: 80)).count, 60)
        let key = DeckKey(action: DeckAction(type: .copied, target: CopiedTexts.list))
        XCTAssertEqual(key.resolving(LiveKeys(copied: ["now", "Earlier"])).title, "Copied texts")
    }

    func testTheMacIsBackNoteOnlyAfterSleep() {
        XCTAssertEqual(PhoneLink.wakeNote(wasAsleep: true, asleep: false), "Mac is back")
        XCTAssertNil(PhoneLink.wakeNote(wasAsleep: false, asleep: false))
        XCTAssertNil(PhoneLink.wakeNote(wasAsleep: true, asleep: true))
    }
}
