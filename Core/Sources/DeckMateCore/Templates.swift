import Foundation

// Ready-made page groups: keys of everyday keyboard shortcuts for Finder, Safari, Notion and Autodesk Fusion,
// added with one click. Shortcuts are for the Mac versions of the apps with their standard settings.

extension KeyCombo {
    /// The Mac's key numbers for an ANSI keyboard, by the key as written.
    private static let ansiCodes: [String: Int] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7, "C": 8, "V": 9, "B": 11,
        "Q": 12, "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17, "1": 18, "2": 19, "3": 20, "4": 21,
        "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29, "]": 30, "O": 31,
        "U": 32, "[": 33, "I": 34, "P": 35, "Return": 36, "L": 37, "J": 38, "'": 39, "K": 40,
        ";": 41, "\\": 42, ",": 43, "/": 44, "N": 45, "M": 46, ".": 47, "Tab": 48, "Space": 49,
        "`": 50, "Delete": 51, "Esc": 53,
        "F1": 122, "F2": 120, "F3": 99, "F4": 118, "F5": 96, "F6": 97, "F7": 98, "F8": 100,
        "F9": 101, "F10": 109, "F11": 103, "F12": 111,
        "←": 123, "→": 124, "↓": 125, "↑": 126,
    ]

    /// A shortcut by the letter, digit or name of its key on an ANSI keyboard ("N", "1", "Space", "[", "F5", "←" ...); nil for a key not in the table.
    public static func ansi(_ key: String, command: Bool = false, control: Bool = false, option: Bool = false, shift: Bool = false) -> KeyCombo? {
        let name = key.count == 1 ? key.uppercased() : key
        guard let code = ansiCodes[name] else { return nil }
        return KeyCombo(keyCode: code, command: command, control: control, option: option, shift: shift, keyName: name)
    }
}

/// A ready-made page group: one app and its most useful shortcuts, in the order of the places 0...14.
public struct PageGroupTemplate: Identifiable, Sendable {
    public struct Key: Sendable {
        public let title: String
        /// "" = the automatic keyboard drawing; otherwise the name of a drawing in the app's icons.
        public let icon: String
        public let combo: KeyCombo
        /// A link key instead of a shortcut: the link it opens ("" = a shortcut key).
        public var link = ""
        /// An app key instead of a shortcut: the app's bundle identifier ("" = none).
        public var appID = ""
    }
    public let id: String
    public let name: String
    /// The app's bundle identifier.
    public let app: String
    public let keys: [Key]
}

public enum Templates {
    private static func key(_ title: String, _ icon: String = "", _ k: String, cmd: Bool = false, ctrl: Bool = false,
                            opt: Bool = false, shift: Bool = false) -> PageGroupTemplate.Key {
        // The table is fixed, so a missing key is a typing slip here, caught by the tests.
        let combo = KeyCombo.ansi(k, command: cmd, control: ctrl, option: opt, shift: shift)
            ?? KeyCombo(keyCode: 0, keyName: "?")
        return PageGroupTemplate.Key(title: title, icon: icon, combo: combo)
    }

    public static let all: [PageGroupTemplate] = [finder, safari, notion, fusion]

    /// What Set up keys › "+" offers: the shortcut page groups, then the one for his own apps.
    public static let menu: [PageGroupTemplate] = all + [ownApps]

    private static func link(_ title: String, _ icon: String = "", _ link: String) -> PageGroupTemplate.Key {
        PageGroupTemplate.Key(title: title, icon: icon, combo: KeyCombo(keyCode: 0, keyName: ""), link: link)
    }

    /// Links his own apps understand (each found in that app's code): AMS Tidy Bar (`application(_:open:)`),
    /// AMS Shopping Companion (`onOpenURL`), PARAGON (`AppModel.handle(url:)`). Seedboard has no link to
    /// open it, so its key opens the app. It belongs to no app: it shows when he picks it.
    public static let ownApps = PageGroupTemplate(id: "ams-apps", name: "My AMS apps", app: "", keys: [
        link("Tidy Bar: show or hide", "app-sync", "amstidybar://toggle"),
        link("Tidy Bar: show", "app-drawerOpen", "amstidybar://show"),
        link("Tidy Bar: hide", "app-drawer", "amstidybar://hide"),
        link("Tidy Bar: arrange", "app-listIndent", "amstidybar://arrange"),
        link("Shopping: scan", "app-capture", "amsshopping://scan"),
        link("Shopping: trip", "shopping", "amsshopping://trip"),
        link("PARAGON: Inbox", "app-inbox", "amspara:///list/inbox"),
        link("PARAGON: Today", "app-today", "amspara:///list/today"),
        link("PARAGON: Overdue", "app-clockAlert", "amspara:///list/overdue"),
        link("PARAGON: Review", "app-review", "amspara:///list/review"),
        link("PARAGON: Plan", "app-timeBlocks", "amspara:///plan"),
        PageGroupTemplate.Key(title: "Seedboard", icon: "", combo: KeyCombo(keyCode: 0, keyName: ""),
                              appID: "com.schabbauer.AMSSeedboard"),
    ])

    static let finder = PageGroupTemplate(id: "finder", name: "Finder", app: "com.apple.finder", keys: [
        key("New window", "", "N", cmd: true),
        key("New folder", "app-folder", "N", cmd: true, shift: true),
        key("New tab", "", "T", cmd: true),
        key("Back", "app-back", "[", cmd: true),
        key("Forward", "app-forward", "]", cmd: true),
        key("Up", "app-arrowUp", "↑", cmd: true),
        key("Get info", "app-info", "I", cmd: true),
        key("Quick Look", "", "Space"),
        key("Go to folder", "", "G", cmd: true, shift: true),
        key("Hidden files", "", ".", cmd: true, shift: true),
        key("Duplicate", "", "D", cmd: true),
        key("Find", "app-search", "F", cmd: true),
        key("Downloads", "", "L", cmd: true, opt: true),
        key("Home", "home", "H", cmd: true, shift: true),
    ])

    static let safari = PageGroupTemplate(id: "safari", name: "Safari", app: "com.apple.Safari", keys: [
        key("New tab", "", "T", cmd: true),
        key("Close tab", "", "W", cmd: true),
        key("Reopen tab", "", "T", cmd: true, shift: true),
        key("Back", "app-back", "[", cmd: true),
        key("Forward", "app-forward", "]", cmd: true),
        key("Reload", "app-sync", "R", cmd: true),
        key("Address bar", "globe", "L", cmd: true),
        key("Find", "app-search", "F", cmd: true),
        key("Bookmark", "app-bookmark", "D", cmd: true),
        key("Private window", "app-lock", "N", cmd: true, shift: true),
        key("Reader", "app-read", "R", cmd: true, shift: true),
        key("Sidebar", "", "L", cmd: true, shift: true),
        key("Tab overview", "", "\\", cmd: true, shift: true),
        key("Next tab", "", "Tab", ctrl: true),
    ])

    static let notion = PageGroupTemplate(id: "notion", name: "Notion", app: "notion.id", keys: [
        key("New page", "app-compose", "N", cmd: true),
        key("Search", "app-search", "P", cmd: true),
        key("Back", "app-back", "[", cmd: true),
        key("Forward", "app-forward", "]", cmd: true),
        key("Sidebar", "", "\\", cmd: true),
        key("New tab", "", "T", cmd: true),
        key("Close tab", "", "W", cmd: true),
        key("Find", "", "F", cmd: true),
        key("New window", "", "N", cmd: true, shift: true),
        key("Parent page", "", "U", cmd: true, shift: true),
        key("Dark mode", "app-moon", "L", cmd: true, shift: true),
    ])

    static let fusion = PageGroupTemplate(id: "fusion", name: "Fusion", app: "com.autodesk.fusion360", keys: [
        key("Line", "", "L"),
        key("Rectangle", "", "R"),
        key("Circle", "", "C"),
        key("Dimension", "app-ruler", "D"),
        key("Trim", "", "T"),
        key("Offset", "", "O"),
        key("Project", "", "P"),
        key("Extrude", "", "E"),
        key("Press pull", "", "Q"),
        key("Fillet", "", "F"),
        key("Move", "", "M"),
        key("Hole", "", "H"),
        key("Joint", "", "J"),
        key("Measure", "", "I"),
    ])

    /// The page group a template makes for this setup: one page "Page 1" with the template's keys in places 0, 1, 2 ...,
    /// each a `.shortcut` key. It is named after the template; when a page group of that name exists already, the name
    /// gets " (ready-made)" added. It belongs to the template's app unless another page group already names that app.
    public static func profile(from template: PageGroupTemplate, in deck: Deck) -> DeckProfile {
        var keys: [Int: DeckKey] = [:]
        for (place, k) in template.keys.prefix(15).enumerated() {
            let action: DeckAction
            if !k.link.isEmpty { action = DeckAction(type: .link, target: k.link) }
            else if !k.appID.isEmpty { action = DeckAction(type: .app, target: k.appID) }
            else { action = DeckAction(type: .shortcut, combo: k.combo) }
            // An app key shows the app's own icon and name.
            keys[place] = DeckKey(title: k.appID.isEmpty ? k.title : "", icon: k.appID.isEmpty ? k.icon : "", action: action)
        }
        let taken = deck.profiles.contains { $0.name == template.name }
        let appTaken = template.app.isEmpty || deck.profileNaming(app: template.app) != nil
        return DeckProfile(name: taken ? template.name + " (ready-made)" : template.name,
                           apps: appTaken ? [] : [template.app],
                           pages: [DeckPage(name: "Page 1", keys: keys)])
    }
}
