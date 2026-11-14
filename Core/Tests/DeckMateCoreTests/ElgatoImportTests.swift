import XCTest
@testable import DeckMateCore

// Builds a tiny made-up Elgato profile folder and checks how it is turned into Deck Mate's model.
final class ElgatoImportTests: XCTestCase {
    private let box = "20GBA9901"

    private func write(_ object: Any, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONSerialization.data(withJSONObject: object).write(to: url)
    }

    private func action(_ uuid: String, _ settings: [String: Any] = [:], title: String = "") -> [String: Any] {
        ["ActionID": UUID().uuidString.lowercased(), "UUID": uuid, "Name": uuid, "Settings": settings,
         "State": 0, "States": [["Title": title]]]
    }

    private func profile(_ root: URL, id: String, name: String, model: String? = nil, app: String? = nil,
                         pages: [(String, [String: Any])]) throws {
        let dir = root.appendingPathComponent("\(id.uppercased()).sdProfile")
        var m: [String: Any] = ["Name": name, "Device": ["Model": model ?? box],
                                "Pages": ["Default": "00000000-0000-0000-0000-000000000000",
                                          "Pages": pages.filter { $0.1["Top"] != nil }.map { $0.0 }]]
        if let app { m["AppIdentifier"] = app }
        try write(m, to: dir.appendingPathComponent("manifest.json"))
        for (pid, actions) in pages {
            var a = actions; a["Top"] = nil
            try write(["Name": "", "Controllers": [["Type": "Keypad", "Actions": a]]],
                      to: dir.appendingPathComponent("Profiles/\(pid.uppercased())/manifest.json"))
        }
    }

    func testImportMapsAKnownSetup() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("elgato-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let main = "11111111-1111-1111-1111-111111111111", next = "22222222-2222-2222-2222-222222222222"
        let folder = "33333333-3333-3333-3333-333333333333"
        let home = "44444444-4444-4444-4444-444444444444", editor = "55555555-5555-5555-5555-555555555555"
        let skipped = "66666666-6666-6666-6666-666666666666"
        let hotkey = ["Hotkeys": [["KeyCmd": true, "KeyCtrl": false, "KeyOption": false, "KeyShift": true,
                                   "NativeCode": 46, "VKeyCode": 46], ["NativeCode": -1]]]

        try profile(root, id: home, name: "Default Profile", app: "/Applications/Invented Tool.app", pages: [
            (main, ["Top": 1,
                    "0,0": action("com.elgato.streamdeck.system.website", ["path": "https://example.com/a"], title: "Example\n  Site"),
                    "1,0": action("com.elgato.streamdeck.system.hotkey", hotkey, title: "Mute"),
                    "2,0": action("com.elgato.streamdeck.profile.openchild", ["ProfileUUID": folder], title: "Tools"),
                    "4,2": action("com.elgato.streamdeck.page.next"),
                    "3,0": action("com.elgato.zoom.mute"),
                    "0,1": action("com.elgato.streamdeck.profile.rotate", ["ProfileUUID": skipped])]),
            (next, ["Top": 1]),
            (folder, ["0,0": action("com.elgato.streamdeck.profile.backtoparent")])
        ])
        try profile(root, id: editor, name: "Editor", app: "/System/Applications/Mail.app", pages: [(main.replacingOccurrences(of: "1", with: "7"), ["Top": 1])])
        try profile(root, id: skipped, name: "Zoom", pages: [])
        try profile(root, id: "77777777-7777-7777-7777-777777777777", name: "Other box", model: "OtherModel", pages: [])

        let r = ElgatoImport.read(folder: root)
        XCTAssertEqual(r.profiles.map { $0.name }, ["Default Profile", "Editor"])
        let d = try XCTUnwrap(r.profiles.first)
        XCTAssertEqual(r.defaultProfile, d.id)
        XCTAssertEqual(d.topPages.map { $0.name }, ["Page 1", "Page 2"])
        XCTAssertEqual(d.pages.count, 3)

        let page = d.topPages[0]
        XCTAssertEqual(page.keys[0]?.title, "Example Site")
        XCTAssertEqual(page.keys[0]?.action, DeckAction(type: .link, target: "https://example.com/a"))
        let combo = try XCTUnwrap(page.keys[1]?.action.combo)
        XCTAssertEqual(page.keys[1]?.action.type, .shortcut)
        XCTAssertEqual(combo.keyCode, 46)
        XCTAssertEqual(combo.keyName, "M")
        XCTAssertTrue(combo.command && combo.shift && !combo.option && !combo.control)
        XCTAssertEqual(page.keys[14]?.action.type, .nextPage)
        XCTAssertNil(page.keys[3], "the plugin key is skipped")
        XCTAssertNil(page.keys[5], "the switch to a skipped profile is dropped")

        let folderKey = try XCTUnwrap(page.keys[2])
        XCTAssertEqual(folderKey.action.type, .folder)
        let child = try XCTUnwrap(d.page(try XCTUnwrap(UUID(uuidString: folderKey.action.target))))
        XCTAssertEqual(child.parent, page.id)
        XCTAssertEqual(child.name, "Tools")
        XCTAssertEqual(child.keys[0]?.action.type, .back)

        XCTAssertEqual(r.profiles[1].apps, ["com.apple.mail"])
        XCTAssertEqual(d.apps, [])
        XCTAssertTrue(r.notes.contains { $0.contains("not on this Mac") })
        XCTAssertTrue(r.notes.contains { $0.contains("Skipped 1 key of a kind Deck Mate does not have: \"com.elgato.zoom.mute\"".replacingOccurrences(of: "\"", with: "")) })
        XCTAssertEqual(r.keyCount, 5)
    }
}
