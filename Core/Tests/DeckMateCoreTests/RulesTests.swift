import XCTest
@testable import DeckMateCore

/// One small data test per rule. No box, no screen.
final class RulesTests: XCTestCase {
    private func key(_ type: ActionType, _ target: String = "", steps: [DeckAction] = []) -> DeckKey {
        DeckKey(title: type.rawValue, action: DeckAction(type: type, target: target, steps: steps))
    }

    /// Default profile: two pages and a folder. "Work" profile belongs to one app.
    private func deck() -> (deck: Deck, main: DeckProfile, work: DeckProfile, folder: DeckPage) {
        var one = DeckPage(name: "Page 1")
        let two = DeckPage(name: "Page 2", keys: [0: key(.previousPage)])
        let folder = DeckPage(name: "Folder", parent: one.id, keys: [0: key(.back)])
        let work = DeckProfile(name: "Work", apps: ["com.example.work"], pages: [DeckPage(name: "Page 1")])
        one.keys = [
            0: key(.app, "com.example.mail"),
            1: key(.folder, folder.id.uuidString),
            2: key(.nextPage),
            3: key(.profile, work.id.uuidString),
            4: key(.multi, steps: [DeckAction(type: .link, target: "https://example.com"),
                                   DeckAction(type: .nextPage),
                                   DeckAction(type: .text, target: "hello")]),
        ]
        let main = DeckProfile(name: "Default", pages: [one, two, folder])
        return (Deck(profiles: [main, work], defaultProfile: main.id), main, work, folder)
    }

    func testAKeyThatOpensSomethingStaysOnItsPageAndSaysWhatToRun() {
        let (deck, _, _, _) = deck()
        let start = Navigator.start(in: deck)!
        let outcome = Navigator.press(0, at: start, in: deck)
        XCTAssertEqual(outcome.position, start)
        XCTAssertEqual(outcome.run.map(\.target), ["com.example.mail"])
        XCTAssertEqual(Navigator.press(9, at: start, in: deck).run, [], "an empty place does nothing")
    }

    func testAFolderOpensAndBackReturns() {
        let (deck, main, _, folder) = deck()
        let start = Navigator.start(in: deck)!
        let inside = Navigator.press(1, at: start, in: deck).position
        XCTAssertEqual(inside.page, folder.id)
        XCTAssertEqual(inside.trail, [main.pages[0].id])
        XCTAssertEqual(Navigator.press(0, at: inside, in: deck).position, start)
    }

    func testNextPageWrapsAround() {
        let (deck, main, _, _) = deck()
        let start = Navigator.start(in: deck)!
        let second = Navigator.press(2, at: start, in: deck).position
        XCTAssertEqual(second.page, main.pages[1].id)
        XCTAssertEqual(Navigator.press(0, at: second, in: deck).position.page, main.pages[0].id, "previous from page 2")
        var only = deck
        only.profiles[0].pages.remove(at: 1)
        XCTAssertEqual(Navigator.press(2, at: start, in: only).position, start, "one page: nowhere to go")
    }

    func testSeveralThingsRunInOrderAndCanMoveToo() {
        let (deck, main, _, _) = deck()
        let outcome = Navigator.press(4, at: Navigator.start(in: deck)!, in: deck)
        XCTAssertEqual(outcome.run.map(\.type), [.link, .text])
        XCTAssertEqual(outcome.position.page, main.pages[1].id)
    }

    func testTheProfileFollowsTheAppInFront() {
        let (deck, main, work, _) = deck()
        let start = Navigator.start(in: deck)!
        let atWork = Navigator.follow(app: "com.example.work", previousApp: "com.example.mail", at: start, in: deck)
        XCTAssertEqual(atWork?.profile, work.id)
        let back = Navigator.follow(app: "com.example.mail", previousApp: "com.example.work", at: atWork, in: deck)
        XCTAssertEqual(back?.profile, main.id)
    }

    func testAProfilePickedByHandStaysBetweenAppsThatShareOne() {
        let (deck, main, work, _) = deck()
        let picked = Navigator.press(3, at: Navigator.start(in: deck)!, in: deck).position
        XCTAssertEqual(picked.profile, work.id)
        let still = Navigator.follow(app: "com.example.notes", previousApp: "com.example.mail", at: picked, in: deck)
        XCTAssertEqual(still?.profile, work.id, "both apps use the default profile: nothing changes")
        var off = deck
        off.autoSwitch = false
        let start = Navigator.start(in: off)!
        XCTAssertEqual(Navigator.follow(app: "com.example.work", previousApp: nil, at: start, in: off)?.profile, main.id)
    }

    func testAPositionIsPutRightAfterItsPageIsDeleted() {
        var (deck, main, _, folder) = deck()
        let inside = DeckPosition(profile: main.id, page: folder.id, trail: [main.pages[0].id])
        deck.profiles[0].pages.removeAll { $0.id == folder.id }
        XCTAssertEqual(Navigator.repair(inside, in: deck)?.page, main.pages[0].id)
        deck.profiles.removeAll { $0.id == main.id }
        XCTAssertEqual(Navigator.repair(inside, in: deck)?.profile, deck.profiles[0].id)
    }

    func testAFolderWithOnlyABackKeyIsLeftOut() {
        var (deck, main, _, folder) = deck()
        deck.profiles[0].pages[2].keys[1] = key(.app, "com.example.mail")
        XCTAssertEqual(deck.droppingEmptyFolders(), deck, "a folder with a real key stays")
        deck.profiles[0].pages[2].keys[1] = nil
        let tidy = deck.droppingEmptyFolders()
        XCTAssertNil(tidy.profiles[0].page(folder.id))
        XCTAssertNil(tidy.profiles[0].page(main.pages[0].id)?.keys[1], "the key that opened it goes too")
        XCTAssertEqual(tidy.profiles[0].page(main.pages[0].id)?.keys.count, 4)
    }

    func testAKeyPictureIsCutIntoPacketsOf1024() {
        let jpeg = Data((0..<2500).map { UInt8($0 % 251) })
        let packets = StreamDeckProtocol.imagePackets(key: 7, jpeg: jpeg)
        XCTAssertEqual(packets.map(\.count), [1024, 1024, 1024])
        XCTAssertEqual([UInt8](packets[0].prefix(8)), [0x02, 0x07, 7, 0, 0xF8, 0x03, 0, 0], "1016 bytes, packet 0")
        XCTAssertEqual([UInt8](packets[2].prefix(8)), [0x02, 0x07, 7, 1, 0xD4, 0x01, 2, 0], "468 bytes, last, packet 2")
        let joined = packets.enumerated().reduce(Data()) { all, item in
            let length = Int(item.element[4]) | Int(item.element[5]) << 8
            return all + item.element.subdata(in: 8..<(8 + length))
        }
        XCTAssertEqual(joined, jpeg)
        XCTAssertEqual(StreamDeckProtocol.imagePackets(key: 0, jpeg: Data()).count, 1)
    }

    func testKeyPressesAreReadWithAndWithoutTheReportNumber() {
        var states = [UInt8](repeating: 0, count: 15)
        states[0] = 1
        states[14] = 1
        let with = Data([0x01, 0x00, 0x0F, 0x00] + states)
        let without = Data([0x00, 0x0F, 0x00] + states)
        for report in [with, without] {
            let read = StreamDeckProtocol.keyStates(fromInput: report)
            XCTAssertEqual(read?.count, 15)
            XCTAssertEqual(read?.enumerated().filter(\.element).map(\.offset), [0, 14])
        }
        XCTAssertNil(StreamDeckProtocol.keyStates(fromInput: Data([0x01, 0x00])))
    }

    func testBrightnessAndResetReports() {
        XCTAssertEqual([UInt8](StreamDeckProtocol.brightness(140).prefix(3)), [0x03, 0x08, 100])
        XCTAssertEqual(StreamDeckProtocol.brightness(40).count, 32)
        XCTAssertEqual([UInt8](StreamDeckProtocol.resetToLogo().prefix(3)), [0x03, 0x02, 0])
        XCTAssertEqual(StreamDeckProtocol.serial(fromFeature: Data([0x06, 0x0C] + Array("AB12".utf8) + [0, 0])), "AB12")
    }

    func testRaycastLinks() {
        XCTAssertEqual(RaycastLink.script(named: "Color Conversion.sh"), "raycast://script-commands/color-conversion")
        XCTAssertEqual(RaycastLink.aiCommand(named: "Fix Spelling and Grammar"), "raycast://ai-commands/fix-spelling-and-grammar")
        let link = RaycastLink.command(owner: "raycast", extensionName: "window-management", command: "left-half")
        XCTAssertEqual(link, "raycast://extensions/raycast/window-management/left-half")
        XCTAssertEqual(RaycastLink.toOpen(link, quiet: true), link + "?launchType=background")
        XCTAssertEqual(RaycastLink.toOpen(link + "?arguments=x", quiet: true), link + "?arguments=x&launchType=background")
        XCTAssertEqual(RaycastLink.toOpen(link, quiet: false), link)
        XCTAssertEqual(RaycastLink.cleaned("  raycast://confetti \n"), "raycast://confetti")
        XCTAssertNil(RaycastLink.cleaned("https://example.com"))
        XCTAssertEqual(RaycastLink.icon(forLink: link), "deck-window-left")
    }

    func testRaycastCommandsAreReadFromAnExtension() {
        let package = """
        {"name": "notes", "title": "Notes", "author": "someone", "owner": "team",
         "commands": [{"name": "new-note", "title": "New Note"}, {"title": "no name"}]}
        """
        let commands = RaycastLink.commands(fromPackage: Data(package.utf8))
        XCTAssertEqual(commands.map(\.link), ["raycast://extensions/team/notes/new-note"], "the owner wins over the author")
        XCTAssertEqual(commands.first?.group, "Notes")
        XCTAssertEqual(RaycastLink.commands(fromPackage: Data("not json".utf8)), [])
    }

    func testAnOddSetupFileStillOpens() throws {
        let json = """
        {"profiles": [{"name": "Default", "pages": [{"keys": {
            "0": {"title": "Mail", "action": {"type": "app", "target": "com.example.mail"}},
            "3": {"action": {"type": "something from a later version"}},
            "99": {"title": "off the deck"}}}]}],
         "brightness": 250}
        """
        let deck = try JSONDecoder().decode(Deck.self, from: Data(json.utf8))
        let keys = deck.profiles[0].pages[0].keys
        XCTAssertEqual(keys.keys.sorted(), [0, 3])
        XCTAssertEqual(keys[0]?.action.kind, .app)
        XCTAssertEqual(keys[3]?.action.type, ActionType.none)
        XCTAssertEqual(deck.brightness, 100)
        XCTAssertTrue(deck.autoSwitch)
        XCTAssertEqual(deck.fallbackProfile?.name, "Default")
        let again = try JSONDecoder().decode(Deck.self, from: JSONEncoder().encode(deck))
        XCTAssertEqual(again, deck)
    }

    func testEveryKindOfKeyHasItsColourAndDrawing() {
        XCTAssertEqual(DeckAction(type: .link, target: "https://example.com").autoIcon, "globe")
        XCTAssertEqual(DeckAction(type: .link, target: "~/Documents").autoIcon, "app-openLink")
        XCTAssertEqual(DeckAction(type: .app, target: "com.example.mail").autoIcon, "", "an app key shows the app's own icon")
        XCTAssertEqual(DeckAction(type: .media, target: "mute").autoIcon, "deck-mute")
        XCTAssertEqual(DeckAction(type: .back).kind, .move)
        XCTAssertEqual(DeckAction(type: .multi, steps: [DeckAction(type: .raycast)]).kind, .raycast)
        XCTAssertEqual(KeyCombo(keyCode: 46, command: true, control: true, option: true, shift: true, keyName: "M").label, "⌃⌥⇧⌘M")
    }
}
