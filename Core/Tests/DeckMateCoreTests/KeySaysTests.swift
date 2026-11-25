import XCTest
@testable import DeckMateCore

/// The 0.20 words of "Explain": what a key will do, said before it is pressed.
final class KeySaysTests: XCTestCase {
    private func says(_ action: DeckAction, _ deck: Deck = Deck(), profile: UUID? = nil) -> String {
        KeySays.does(action, in: deck, profile: profile, appName: { $0 == "com.apple.Safari" ? "Safari" : "" })
    }

    private func lines(_ key: DeckKey) -> KeySays.Lines {
        KeySays.lines(key, in: Deck(), profile: nil, appName: { _ in "Safari" })
    }

    func testWhatAKeyWillDoInWords() {
        XCTAssertEqual(says(DeckAction(type: .app, target: "com.apple.Safari")), "Opens Safari")
        XCTAssertEqual(says(DeckAction(type: .app, target: "com.unknown.thing")), "Opens an app")
        XCTAssertEqual(says(DeckAction(type: .app)), "No app picked")
        XCTAssertEqual(says(DeckAction(type: .link, target: "https://www.apple.com/mac")), "Opens the link apple.com")
        XCTAssertEqual(says(DeckAction(type: .link, target: "/Users/me/Documents/Plan.pdf")), "Opens Plan.pdf")
        XCTAssertEqual(says(DeckAction(type: .shortcut, combo: KeyCombo(keyCode: 45, command: true, keyName: "N"))), "Presses ⌘N")
        XCTAssertEqual(says(DeckAction(type: .text, target: "Hello")), "Types “Hello”")
        XCTAssertEqual(says(DeckAction(type: .text, target: "This is a rather long text to type out")), "Types “This is a rather long te…”")
        XCTAssertEqual(says(DeckAction(type: .media, target: "next")), "Next track")
        XCTAssertEqual(says(DeckAction(type: .raycast, target: "raycast://extensions/raycast/clipboard-history/clipboard-history")), "Raycast: Clipboard history")
        XCTAssertEqual(says(DeckAction(type: .toggle, target: "fan:cool")), "Fans: Cool for 10 minutes")
        XCTAssertEqual(says(DeckAction(type: .toggle, target: "dark")), "Switches dark mode")
        XCTAssertEqual(says(DeckAction(type: .timer, target: "10")), "Timer: 10 min, start or stop")
        XCTAssertEqual(says(DeckAction(type: .none)), "Does nothing")
        XCTAssertEqual(says(DeckAction(type: .weather, target: "torremolinos")), "Shows the weather in Torremolinos; opens Weather")

        // Pages, folders and page groups, looked up in a small deck.
        let money = DeckPage(name: "Money")
        let folder = DeckPage(name: "On the Mac", parent: money.id)
        let group = DeckProfile(name: "My Apps", pages: [money, folder])
        let deck = Deck(profiles: [group])
        XCTAssertEqual(says(DeckAction(type: .folder, target: money.id.uuidString), deck, profile: group.id), "Goes to the page “Money”")
        XCTAssertEqual(says(DeckAction(type: .folder, target: folder.id.uuidString), deck, profile: nil), "Opens the folder “On the Mac”")
        XCTAssertEqual(says(DeckAction(type: .folder, target: UUID().uuidString), deck, profile: group.id), "Opens a folder that is gone")
        XCTAssertEqual(says(DeckAction(type: .profile, target: group.id.uuidString), deck), "Shows the page group “My Apps”")
        XCTAssertEqual(says(DeckAction(type: .back)), "Back")
        XCTAssertEqual(says(DeckAction(type: .nextPage)), "Next page")

        // Several things in a row.
        let two = DeckAction(type: .multi, steps: [DeckAction(type: .app, target: "com.apple.Safari"), DeckAction(type: .wait, target: "2"),
                                                   DeckAction(type: .media, target: "mute")])
        XCTAssertEqual(says(two), "Opens Safari and 1 more")

        // Tap, hold and double press.
        let counter = DeckKey(action: DeckAction(type: .counter, target: "mine"))
        XCTAssertEqual(lines(counter), KeySays.Lines(tap: "Counts one up", hold: "Back to 0", twice: nil))
        let plain = DeckKey(action: DeckAction(type: .app, target: "com.apple.Safari"))
        XCTAssertEqual(lines(plain), KeySays.Lines(tap: "Opens Safari", hold: nil, twice: nil))
        let held = DeckKey(action: DeckAction(type: .app, target: "com.apple.Safari"), held: DeckAction(type: .media, target: "mute"))
        XCTAssertEqual(lines(held).hold, "Mute sound")
        let twice = DeckKey(action: DeckAction(type: .app, target: "com.apple.Safari"), twice: DeckAction(type: .toggle, target: "awake"))
        XCTAssertEqual(lines(twice).twice, "Keeps the Mac awake, on or off")
        XCTAssertNil(lines(twice).hold)
    }

    func testEveryKindSaysSomething() {
        for type in ActionType.allCases {
            let words = says(DeckAction(type: type))
            XCTAssertFalse(words.isEmpty, "\(type) says nothing")
        }
    }
}
