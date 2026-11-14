import Foundation

enum Guide {
    struct Section: Identifiable { let id: String; let title: String; let part: String; let lines: [String] }
    struct Release: Identifiable { let id: String; let date: String; let new: [String]; let changed: [String]; let fixed: [String] }

    static let sections: [Section] = [
        Section(id: "what", title: "What this app is for", part: "settings", lines: [
            "AMS Deck Mate drives your Stream Deck box with 15 keys straight over its cable. It needs no Elgato app and no subscription.",
            "It lives in the menu bar at the top of the screen and has no Dock icon. It is for the Mac only."
        ]),
        Section(id: "testing", title: "Not yet tried on the real box", part: "box", lines: [
            "Version 0.1 was built while the box was away. Driving the real box is therefore not yet tried.",
            "The first real test is planned for January 2027. The keys on screen work without the box and can be used right away."
        ]),
        Section(id: "menu", title: "The menu bar", part: "settings", lines: [
            "Click the small icon to open the menu: \"Show keys on screen\", \"Set up keys…\", \"Profile\", \"Settings…\" and \"Quit AMS Deck Mate\".",
            "Under \"Profile\" you choose \"Automatic\" or pin one profile by hand."
        ]),
        Section(id: "screen", title: "Keys on screen", part: "screen", lines: [
            "\"Show keys on screen\" opens a small floating window with the same 15 keys as the box. The shortcut is Control-Option-D.",
            "A click does what pressing the box key does. The window does not take the keyboard away from the app you are working in.",
            "It stays above other windows, you can drag it anywhere, and it remembers its place.",
            "The top line shows the profile and page names and a button to set up keys. While \"Set up keys\" is open the floating keys step aside, and come back when you close it.",
            "It works without the box, so you can use the keys on a Mac with no box plugged in."
        ]),
        Section(id: "look", title: "The look of a key", part: "keys", lines: [
            "A key is a flat coloured tile with a white hand-drawn icon and a short title.",
            "Each kind has its own colour: apps blue, links teal, Raycast red-orange, keyboard shortcuts purple, typed text amber, music and sound green, moving around grey-blue.",
            "A key that opens an app shows the app's own icon, unless you pick a hand-drawn one.",
            "There are 245 hand-drawn icons to pick from."
        ]),
        Section(id: "setup", title: "Set up keys", part: "keys", lines: [
            "Open it from the menu. Profiles are on the left: add, rename, delete, make default, and \"Use with apps\".",
            "In the middle are the 15 keys, with the pages and folders of the profile above them. You can add and delete pages.",
            "Click a key to edit it on the right: Title, Icon and \"What it does\".",
            "Every edit has Cancel and Save. Escape is Cancel.",
            "\"Clear key\" empties a key. \"Try it\" runs the key."
        ]),
        Section(id: "actions", title: "What a key can do", part: "keys", lines: [
            "Open an app. Open a link or a file: web pages, folders and files.",
            "Raycast: run a Raycast command. Keyboard shortcut: press the keys to record them.",
            "Type text. Music and sound: play or pause, next, previous, volume up, volume down, mute.",
            "Folder of keys opens another page of keys, and Back returns. Next page and Previous page move between pages.",
            "Switch profile changes the profile. Several things in a row runs steps one after another, a third of a second apart.",
            "Nothing leaves the key empty."
        ]),
        Section(id: "raycast", title: "Raycast keys", part: "raycast", lines: [
            "Pick a command from a list. It holds the commands of the Raycast extensions on this Mac, found by itself, and 16 of Raycast's own.",
            "Or paste any Raycast link: in Raycast select a command, press Command-K and choose \"Copy Deeplink\".",
            "A script command goes on a key by its name, and an AI command by its name.",
            "\"Run quietly\" runs a command without bringing Raycast forward.",
            "The first time a key runs a command, Raycast asks once. Choose \"Always open command\".",
            "Raycast has no door for quicklinks and snippets from outside. Use \"Open a link\" for a quicklink and \"Type text\" for a snippet."
        ]),
        Section(id: "profiles", title: "Profiles change by themselves", part: "profiles", lines: [
            "When an app that belongs to a profile comes to the front, the keys change to that profile. Any other app shows the default profile.",
            "A profile you pick by hand stays while you move between apps that share a profile. It changes when you go to an app with another profile.",
            "Pinning a profile in the menu holds it. You can switch the automatic change off in Settings."
        ]),
        Section(id: "bringover", title: "Bringing over your Elgato keys", part: "profiles", lines: [
            "At first start the app reads the keys from Elgato's app for the 15-key box: apps, links, shortcuts, typed text, music keys, folders, pages, several-things keys and which app a profile belongs to.",
            "Left out are the Zoom profile, the two Final Cut profiles, and keys of kinds Deck Mate does not have. A folder that would be left empty is left out too.",
            "Elgato's files are only read, never changed. Elgato's pictures are not taken over: every key is redrawn in the new look.",
            "\"Bring over again\" in Settings repeats it. It asks first, and your current setup is kept as a safety copy."
        ]),
        Section(id: "box", title: "The box", part: "box", lines: [
            "Plug it in and the keys light up. Settings shows \"Connected\" with the box's name and serial number, and a brightness slider.",
            "Elgato's own app must be quit while Deck Mate drives the box, because only one can hold it.",
            "Settings warns you when Elgato's app is running and has a \"Quit Elgato's app\" button.",
            "When Deck Mate quits, the box goes back to the Elgato logo."
        ]),
        Section(id: "permissions", title: "What the Mac asks for", part: "settings", lines: [
            "Accessibility, once, for keys that press a keyboard shortcut, type text or control music and sound. Settings shows whether it is allowed and has an \"Allow…\" button.",
            "The Mac may also ask for Input Monitoring when the box is first plugged in."
        ]),
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open it from the menu. It has three tabs: \"Settings\", \"How it works\" and \"What's new\".",
            "\"Settings\" holds the box, brightness, change profile with the app in front, open at login, permissions and bring over again.",
            "The version number, Quit and Done stay at the bottom."
        ]),
        Section(id: "kept", title: "Where things are kept", part: "settings", lines: [
            "Your setup is one file on this Mac, in the folder \"AMS Deck Mate\" inside Application Support.",
            "Each save first keeps the previous file as a safety copy. The last 20 are kept in a \"Backups\" folder beside it.",
            "Nothing leaves your Mac."
        ])
    ]

    static let releases: [Release] = [
        Release(id: "0.1", date: "14 Nov 2026", new: [
            "AMS Deck Mate: a new Mac menu bar app that drives a Stream Deck box with 15 keys (Stream Deck 2019 and MK.2) straight over its cable. No Elgato app, no subscription.",
            "Not yet tried on the real box: 0.1 was built while the box was away. The first real test is planned for January 2027.",
            "Menu bar icon with a menu: \"Show keys on screen\", \"Set up keys…\", \"Profile\", \"Settings…\" and \"Quit AMS Deck Mate\". No Dock icon.",
            "Keys on screen: a small floating window with the same 15 keys as the box, opened with the menu or Control-Option-D.",
            "A click on a key does what pressing the box key does. The window does not take the keyboard from the app you work in.",
            "The window stays above other windows, can be dragged anywhere and remembers its place.",
            "Its top line shows the profile and page names and a button to set up keys.",
            "It works without the box, so the keys can be used on a Mac with no box plugged in.",
            "A new look for keys: a flat coloured tile, a white hand-drawn icon and a short title.",
            "One colour per kind: apps blue, links teal, Raycast red-orange, keyboard shortcuts purple, typed text amber, music and sound green, moving around grey-blue.",
            "A key that opens an app shows the app's own icon unless you pick a hand-drawn one.",
            "245 hand-drawn icons to pick from: the AMS Icon Library plus new ones drawn for this app.",
            "Set up keys window: profiles on the left, with add, rename, delete, make default and \"Use with apps\".",
            "In the middle: the 15 keys, with the pages and folders of the profile above them, and add page and delete page.",
            "On the right: click a key to edit Title, Icon and \"What it does\", with Cancel and Save. Escape is Cancel.",
            "\"Clear key\" empties a key. \"Try it\" runs the key.",
            "Key action: open an app.",
            "Key action: open a link or a file (web pages, folders, files). This is also how a Raycast quicklink goes on a key.",
            "Key action: Raycast.",
            "Key action: keyboard shortcut. Press the keys to record it.",
            "Key action: type text. This is also how a snippet goes on a key.",
            "Key action: music and sound, with play or pause, next, previous, volume up, volume down and mute.",
            "Key action: folder of keys, which opens another page of keys, with a Back key to return.",
            "Key actions: next page and previous page.",
            "Key action: switch profile.",
            "Key action: several things in a row. The steps run one after another, a third of a second apart.",
            "Key action: nothing.",
            "Raycast keys: pick a command from a list of the Raycast extensions installed on this Mac (found by itself; 15 today, for example Notion, Spotify, CleanShot X, 1Password and Reminders) and 16 of Raycast's own (Clipboard History, AI Chat, window left and right half, Search Snippets, Search Quicklinks, Lock Screen and more).",
            "Raycast keys: or paste any Raycast link. In Raycast select a command, press Command-K and choose \"Copy Deeplink\".",
            "Raycast keys: a script command goes on a key by its name, and an AI command by its name.",
            "Raycast keys: \"Run quietly\" runs a command without bringing Raycast forward.",
            "Raycast keys: the first time a key runs a command Raycast asks once. Choose \"Always open command\".",
            "Raycast has no door for quicklinks and snippets from outside, so those use \"Open a link\" and \"Type text\".",
            "Profiles change by themselves: when an app that belongs to a profile comes to the front, the keys change to that profile. Any other app shows the default profile.",
            "A profile picked by hand (menu or a Switch profile key) stays while you move between apps that share a profile, and changes when you go to an app with another profile.",
            "\"Change profile with the app in front\" can be switched off in Settings. Pinning a profile in the menu holds it.",
            "Bringing over the Elgato keys at first start: apps, links, shortcuts, typed text, music keys, folders, pages, several-things keys, and which app a profile belongs to.",
            "Left out: the Zoom profile, the two Final Cut profiles, and keys of kinds Deck Mate does not have (Elgato's own on-screen deck switch, plug-in keys). A folder that would be left empty is left out too.",
            "Elgato's files are only read, never changed. Elgato's pictures are not taken over: every key is redrawn in the new look.",
            "\"Bring over again\" in Settings repeats it. It asks first, and the current setup is kept as a safety copy.",
            "The box: plug it in and the keys light up. Settings shows \"Connected\" with the box's name and serial number, and a brightness slider.",
            "A warning in Settings when Elgato's own app is running, with a \"Quit Elgato's app\" button, because only one app can hold the box.",
            "When Deck Mate quits, the box goes back to the Elgato logo.",
            "Permissions: Accessibility, asked once, for keys that press a shortcut, type text or control music and sound. Settings shows whether it is allowed and has an \"Allow…\" button.",
            "The Mac may also ask for Input Monitoring when the box is first plugged in.",
            "Settings with three tabs: Settings (box, brightness, change profile with the app in front, open at login, permissions, bring over again), How it works and What's new.",
            "The version number shows at the bottom of Settings, with Quit and Done.",
            "Your setup is kept in one file on this Mac, \"deck.json\" in Application Support. Each save first keeps the previous file as a safety copy (the last 20) in a \"Backups\" folder beside it.",
            "Nothing leaves your Mac."
        ], changed: [], fixed: [])
    ]
}
