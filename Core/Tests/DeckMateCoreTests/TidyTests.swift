import XCTest
@testable import DeckMateCore

/// The 0.4 rules: one small data test each.
final class TidyTests: XCTestCase {
    private func setup() -> (Deck, DeckProfile, DeckPage, DeckPage, DeckPage) {
        var one = DeckPage(name: "Page 1")
        var two = DeckPage(name: "Page 2")
        let folder = DeckPage(name: "Folder", parent: one.id, keys: [0: DeckKey(title: "Back", action: DeckAction(type: .back))])
        one.keys = [0: DeckKey(title: "Mail", action: DeckAction(type: .app, target: "com.apple.mail")),
                    1: DeckKey(title: "Folder", action: DeckAction(type: .folder, target: folder.id.uuidString))]
        two.keys = [3: DeckKey(title: "Copy", action: DeckAction(type: .text, target: "x"))]
        let profile = DeckProfile(name: "Main", pages: [one, two, folder])
        return (Deck(profiles: [profile], defaultProfile: profile.id), profile, one, two, folder)
    }

    func testMovingAKeySwapsAndTakesItsFolderAlong() {
        var (deck, profile, one, two, folder) = setup()
        deck.moveKey(in: profile.id, from: (one.id, 0), to: (one.id, 4))
        XCTAssertNil(deck.profiles[0].page(one.id)?.keys[0])
        XCTAssertEqual(deck.profiles[0].page(one.id)?.keys[4]?.title, "Mail")
        deck.moveKey(in: profile.id, from: (one.id, 1), to: (two.id, 3))
        XCTAssertEqual(deck.profiles[0].page(two.id)?.keys[3]?.title, "Folder")
        XCTAssertEqual(deck.profiles[0].page(one.id)?.keys[1]?.title, "Copy", "the key that was there swaps places")
        XCTAssertEqual(deck.profiles[0].page(folder.id)?.parent, two.id, "the folder now opens from page 2")
        let before = deck
        deck.moveKey(in: profile.id, from: (two.id, 3), to: (folder.id, 5))
        XCTAssertEqual(deck, before, "a folder key cannot go into its own folder")
    }

    func testAnAppGetsOneProfile() {
        var (deck, profile, _, _, _) = setup()
        let other = DeckProfile(name: "Other", apps: ["com.apple.Safari"])
        deck.profiles.append(other)
        deck.assign(app: "com.apple.Safari", to: profile.id)
        XCTAssertEqual(deck.profiles[0].apps, ["com.apple.Safari"])
        XCTAssertEqual(deck.profiles[1].apps, [])
        XCTAssertEqual(deck.profileNaming(app: "com.apple.Safari")?.id, profile.id)
        deck.assign(app: "com.apple.Safari", to: nil)
        XCTAssertNil(deck.profileNaming(app: "com.apple.Safari"))
    }

    func testCopiesGetNewIdsAndOpenTheirOwnFolders() {
        var (_, profile, one, _, folder) = setup()
        let copy = profile.duplicated(name: "Main copy")
        XCTAssertEqual(copy.pages.count, 3)
        XCTAssertTrue(Set(copy.pages.map(\.id)).isDisjoint(with: profile.pages.map(\.id)))
        let copiedFolder = copy.pages.first { $0.name == "Folder" }!
        XCTAssertEqual(copy.pages[0].keys[1]?.action.target, copiedFolder.id.uuidString)
        XCTAssertEqual(copiedFolder.parent, copy.pages[0].id)
        XCTAssertNotEqual(copy.pages[0].keys[0]?.id, one.keys[0]?.id)

        let new = profile.duplicatePage(one.id)!
        XCTAssertEqual(profile.topPages.map(\.name), ["Page 1", "Page 1 copy", "Page 2"])
        let newFolder = profile.pages.first { $0.parent == new }!
        XCTAssertNotEqual(newFolder.id, folder.id)
        XCTAssertEqual(profile.page(new)?.keys[1]?.action.target, newFolder.id.uuidString)
    }

    func testBrokenKeysSayWhy() {
        let (deck, profile, _, _, _) = setup()
        let world = KeyWorld(appExists: { $0 == "com.apple.mail" }, fileExists: { _ in false },
                             raycastExtension: { owner, _ in owner == "him" })
        func check(_ action: DeckAction) -> String? {
            KeyCheck.problem(DeckKey(action: action), in: profile, deck: deck, world: world)
        }
        XCTAssertNil(check(DeckAction(type: .app, target: "com.apple.mail")))
        XCTAssertEqual(check(DeckAction(type: .app, target: "com.gone.app")), "The app is not on this Mac")
        XCTAssertEqual(check(DeckAction(type: .link, target: "~/Gone")), "The file or folder is gone")
        XCTAssertNil(check(DeckAction(type: .link, target: "https://example.com")))
        XCTAssertNil(check(DeckAction(type: .raycast, target: "raycast://extensions/raycast/ai/ai-chat")), "Raycast's own")
        XCTAssertNil(check(DeckAction(type: .raycast, target: "raycast://extensions/him/tool/run")))
        XCTAssertEqual(check(DeckAction(type: .raycast, target: "raycast://extensions/else/tool/run?launchType=background")),
                       "This Raycast command is not on this Mac")
        XCTAssertEqual(check(DeckAction(type: .folder, target: UUID().uuidString)), "Its folder is gone")
        XCTAssertEqual(check(DeckAction(type: .multi, steps: [DeckAction(type: .media, target: "mute"),
                                                               DeckAction(type: .profile, target: "x")])), "Its page group is gone")
        XCTAssertEqual(KeyCheck.all(in: deck, world: world), [])
    }

    func testWordsForWhatAKeyDid() {
        let name: (String) -> String = { _ in "Mail" }
        XCTAssertEqual(ActionWords.done([DeckAction(type: .app, target: "x")], appName: name), "Opened Mail")
        XCTAssertEqual(ActionWords.done([DeckAction(type: .raycast, target: "raycast://extensions/raycast/clipboard-history/clipboard-history")],
                                        appName: name), "Raycast: Clipboard history")
        XCTAssertEqual(ActionWords.done([DeckAction(type: .media, target: "mute"), DeckAction(type: .text, target: "a")],
                                        appName: name), "Mute sound and 1 more")
        XCTAssertNil(ActionWords.done([], appName: name))
    }

    func testSwipingStepsThroughPagesAlsoFromAFolder() {
        let (deck, profile, one, two, folder) = setup()
        let start = DeckPosition(profile: profile.id, page: one.id)
        XCTAssertEqual(Navigator.step(1, at: start, in: deck).page, two.id)
        XCTAssertEqual(Navigator.step(-1, at: start, in: deck).page, two.id, "round the end")
        XCTAssertEqual(Navigator.step(1, at: DeckPosition(profile: profile.id, page: folder.id, trail: [one.id]), in: deck).page, two.id)
        XCTAssertEqual(Navigator.pageNumber(at: start, in: deck).page, 0)
        XCTAssertEqual(Navigator.pageNumber(at: start, in: deck).pages, 2)
        XCTAssertNil(Navigator.pageNumber(at: DeckPosition(profile: profile.id, page: folder.id), in: deck).page)
    }

    func testKeyboardRowsPressTheKeys() {
        XCTAssertEqual(ScreenDeckRules.keyIndex(forKeyCode: 18), 0)   // 1
        XCTAssertEqual(ScreenDeckRules.keyIndex(forKeyCode: 17), 9)   // T
        XCTAssertEqual(ScreenDeckRules.keyIndex(forKeyCode: 5), 14)   // G
        XCTAssertNil(ScreenDeckRules.keyIndex(forKeyCode: 53))        // Escape
        XCTAssertEqual((0..<15).compactMap(ScreenDeckRules.keyLetter).joined(), "12345QWERTASDFG")
        XCTAssertNil(ScreenDeckRules.keyLetter(15))
    }

    func testNewIPhoneMessagesCrossTheLineAndOldHelloStillReads() {
        let status = PhoneLink.Status(profiles: [.init(id: "a", name: "Main")], current: "a", held: true, page: 1, pages: 3)
        let sent: [PhoneLink.Message] = [.status(status), .pressed(index: 4), .ran(text: "Opened Mail", ok: true),
                                         .page(step: -1), .profile(id: nil), .hello(phone: "P", token: "t", version: 2)]
        var reader = PhoneLink.Reader()
        XCTAssertEqual(reader.add(sent.map(PhoneLink.frame).reduce(Data(), +)), sent)
        XCTAssertNil(status.profile(after: 1), "one profile: a swipe changes nothing")
        let three = PhoneLink.Status(profiles: [.init(id: "a", name: "A"), .init(id: "b", name: "B"), .init(id: "c", name: "C")],
                                     current: "c", held: false, page: 0, pages: 1)
        XCTAssertEqual(three.profile(after: 1), "a", "round the end")
        XCTAssertEqual(three.profile(after: -1), "b")
        let old = #"{"hello":{"phone":"P","token":null}}"#.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(PhoneLink.Message.self, from: old), .hello(phone: "P", token: nil, version: nil))
    }
}

final class ReleaseNineTests: XCTestCase {
    func testRecentAppsList() {
        var list: [String] = []
        for app in ["a", "b", "deckmate", "c", "a", "d", "e"] { list = RecentApps.after(list, front: app, skip: "deckmate") }
        XCTAssertEqual(list, ["e", "d", "a", "c"])
        XCTAssertEqual(RecentApps.app(number: 1, in: list), "d")
        XCTAssertEqual(RecentApps.app(number: 3, in: list), "c")
        XCTAssertNil(RecentApps.app(number: 1, in: ["only"]))
        let key = DeckKey(title: "", action: DeckAction(type: .recent, target: "2"))
        XCTAssertEqual(key.resolvingRecent(list).action, DeckAction(type: .app, target: "a"))
        XCTAssertEqual(key.resolvingRecent([]).title, "Recent")
        XCTAssertEqual(key.action.kind, .app)
    }

    func testAskAILink() {
        XCTAssertEqual(RaycastLink.ask(nil), RaycastLink.aiChat)
        XCTAssertEqual(RaycastLink.ask("  "), RaycastLink.aiChat)
        XCTAssertEqual(RaycastLink.ask("a & b?"), RaycastLink.aiChat + "?fallbackText=a%20%26%20b%3F")
        let long = RaycastLink.ask(String(repeating: "x", count: 5000))
        XCTAssertEqual(long.count, RaycastLink.aiChat.count + "?fallbackText=".count + 4000)
        XCTAssertEqual(PhoneLink.Message.asleep(true).since, 5)
        // A swipe that does not lock: only a Mac at version 6 knows it.
        XCTAssertEqual(PhoneLink.Message.visit(profile: "a").since, 6)
    }
}
