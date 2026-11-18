import XCTest
@testable import DeckMateCore

/// Mac 0.16.1: the app comes back by itself. One small data test per rule.
final class KeeperTests: XCTestCase {
    func testOfTwoCopiesTheEarlierOneStays() {
        let first = OneCopy.Copy(started: 100.0, pid: 900)
        let second = OneCopy.Copy(started: 100.2, pid: 120)
        // Exactly one of two copies that see each other stays: the earlier one, whatever its process number.
        XCTAssertFalse(OneCopy.mustQuit(me: first, others: [second]))
        XCTAssertTrue(OneCopy.mustQuit(me: second, others: [first]))
        // Started in the very same instant: the smaller process number stays.
        let twin = OneCopy.Copy(started: 100.0, pid: 901)
        XCTAssertFalse(OneCopy.mustQuit(me: first, others: [twin]))
        XCTAssertTrue(OneCopy.mustQuit(me: twin, others: [first]))
        // Alone: stays.
        XCTAssertFalse(OneCopy.mustQuit(me: first, others: []))
    }

    func testTheKeepersStartOrder() {
        let order = Keeper.plist(executable: "/Users/m/Applications/AMS Deck Mate.app/Contents/MacOS/AMS Deck Mate",
                                 bundleID: "com.schabbauer.AMSDeckMate")
        XCTAssertEqual(order["Label"] as? String, "com.schabbauer.AMSDeckMate.keeper")
        XCTAssertEqual(order["ProgramArguments"] as? [String],
                       ["/Users/m/Applications/AMS Deck Mate.app/Contents/MacOS/AMS Deck Mate", "--keeper"])
        // Opened at login, and again after an unexpected stop — but not after Quit.
        XCTAssertEqual(order["RunAtLoad"] as? Bool, true)
        XCTAssertEqual(order["KeepAlive"] as? [String: Bool], ["SuccessfulExit": false])
        // A copy opened by hand gives way to the keeper only while Open at login is on.
        XCTAssertTrue(Keeper.handsOver(wanted: true, openedByKeeper: false, plain: false, inApplications: true))
        XCTAssertFalse(Keeper.handsOver(wanted: false, openedByKeeper: false, plain: false, inApplications: true))
        XCTAssertFalse(Keeper.handsOver(wanted: true, openedByKeeper: true, plain: false, inApplications: true))
        XCTAssertFalse(Keeper.handsOver(wanted: true, openedByKeeper: false, plain: true, inApplications: true))
        XCTAssertFalse(Keeper.handsOver(wanted: true, openedByKeeper: false, plain: false, inApplications: false))
    }
}
