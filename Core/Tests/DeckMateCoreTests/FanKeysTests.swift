import XCTest
@testable import DeckMateCore

/// The 0.18 rules of the fan keys: one small data test each.
final class FanKeysTests: XCTestCase {
    func testFanTargetChoiceAndWords() {
        XCTAssertEqual(FanKeys.target("cool"), "fan:cool")
        XCTAssertEqual(FanKeys.choice(of: "fan:full"), "full")
        XCTAssertNil(FanKeys.choice(of: "fan:"))
        XCTAssertNil(FanKeys.choice(of: "fan:cool; rm"), "only one plain word is ever handed on")
        XCTAssertNil(FanKeys.choice(of: SwitchKeys.dark))
        XCTAssertFalse(SwitchKeys.isOwn(FanKeys.target("cool")), "a fan key is never remembered as on by Deck Mate itself")
        XCTAssertEqual(FanKeys.choices.map(FanKeys.words), ["Automatic", "Cool", "Full"])
        XCTAssertEqual(FanKeys.words("mySpeed"), "My speed")
    }

    func testTheChoiceThatIsOnComesFromFanMenusFile() {
        let file = Data(#"{"appDecides":true,"choice":"cool","since":1795549438.7,"title":"Cool","version":"0.2"}"#.utf8)
        XCTAssertEqual(FanKeys.on(state: file), "fan:cool")
        XCTAssertEqual(FanKeys.on(state: Data(#"{"choice":"quiet"}"#.utf8)), "fan:quiet", "a choice without a key lights none of the three")
        XCTAssertNil(FanKeys.on(state: nil), "no file = no fan key lit")
        XCTAssertNil(FanKeys.on(state: Data("not a file of Fan Menu".utf8)))
        XCTAssertNil(FanKeys.on(state: Data(#"{"choice":""}"#.utf8)))
    }

    func testFanKeyShowsItselfAndOnlyTheOneThatIsOnIsLit() {
        let keys = FanKeys.choices.map { DeckKey(action: DeckAction(type: .toggle, target: FanKeys.target($0))) }
        let shown = keys.map { $0.resolving(LiveKeys(on: ["fan:cool", SwitchKeys.dark])) }
        XCTAssertEqual(shown.map(\.title), ["Automatic", "Cool", "Full"], "the words do not change with on and off")
        XCTAssertEqual(shown.map(\.action.quiet), [false, true, false])
        XCTAssertEqual(keys[0].resolving(LiveKeys(on: ["fan:quiet"])).action.quiet, false)
        XCTAssertEqual(keys.map(\.shownIcon), ["app-fan", "app-fan", "app-fan"])
        XCTAssertEqual(keys[1].action.kind, .shortcut, "purple like every switch")
        XCTAssertEqual(ActionWords.done([keys[2].action], appName: { $0 }), "Fans: Full")
        func world(_ here: Bool) -> KeyWorld { KeyWorld(appExists: { _ in here }, fileExists: { _ in true }, raycastExtension: { _, _ in true }) }
        XCTAssertNil(KeyCheck.problem(keys[0], in: DeckProfile(), deck: Deck(), world: world(true)))
        XCTAssertEqual(KeyCheck.problem(keys[0], in: DeckProfile(), deck: Deck(), world: world(false)), "AMS Fan Menu is not on this Mac")
    }
}
