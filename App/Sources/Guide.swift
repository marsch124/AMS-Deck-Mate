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
            "It works without the box, so you can use the keys on a Mac with no box plugged in.",
            "Three choices in Settings, in the card \"Keys on screen\". \"Show them\": \"Where I left them\" or \"At the mouse pointer\".",
            "At the mouse pointer, the keys appear under the pointer each time. Near the edge of the screen they move in until they are whole. The place you drag them to is not remembered then.",
            "\"Hide after a key is pressed\" hides the keys after a click on a key that does something on the Mac. A key that only moves around leaves them open.",
            "\"Size\": Small, Normal or Large. The window changes size at once.",
            "Together: press Control-Option-D, the keys appear under the mouse, click one, and they are gone."
        ]),
        Section(id: "look", title: "The look of a key", part: "keys", lines: [
            "A key is a flat coloured tile with a white hand-drawn icon and a short title.",
            "Each kind has its own colour: apps blue, links teal, Raycast red-orange, keyboard shortcuts purple, typed text amber, music and sound green, moving around grey-blue.",
            "A key that opens an app shows the app's own icon, unless you pick a hand-drawn one.",
            "A key that opens an app and has no words of its own shows the app's name, for example Mail, Safari or Calculator. Words you write on a key always win. This is the same on the box, on the screen and on the iPhone.",
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
            "A folder of Raycast commands is a good start: one key \"Raycast\" that opens a page with Back and your favourite commands.",
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
        Section(id: "iphone", title: "On your iPhone", part: "settings", lines: [
            "Deck Mate for the iPhone shows the same 15 keys as the box, in the same places and with the same pictures. It follows the profile and page the Mac shows, so it changes when the app in front changes.",
            "Tap a key on the iPhone and the Mac does it, exactly as if you had pressed it on the box. The keys on the Mac screen do not hide because of a tap on the iPhone.",
            "The iPhone finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" Choose Allow. After that the Mac remembers the iPhone. If you choose Don't Allow, the iPhone shows \"Ask again\".",
            "The pictures are drawn by the Mac, so keys that open an app show the real app icon.",
            "If the iPhone says \"Looking for your Mac…\": check that the Mac app is open, that Wi-Fi and Bluetooth are on, that the iPhone is close to the Mac, and that Local Network is allowed for Deck Mate in the iPhone's Settings, Privacy & Security, Local Network."
        ]),
        Section(id: "iphonecard", title: "The iPhone card in Settings", part: "settings", lines: [
            "In the Mac's Settings there is a card \"iPhone\".",
            "The checkbox \"Let an iPhone use these keys\" is on to start with. Switch it off and no iPhone can use your keys.",
            "Under it you see the iPhone that is connected right now, and the list of allowed iPhones. \"Forget\" next to one takes the permission back. That iPhone has to ask again.",
            "The first time, the Mac may ask to \"find devices on local networks\". That is this feature. Answer Allow."
        ]),
        Section(id: "permissions", title: "What the Mac asks for", part: "settings", lines: [
            "Accessibility, once, for keys that press a keyboard shortcut, type text or control music and sound. Settings shows whether it is allowed and has an \"Allow…\" button.",
            "The Mac may also ask for Input Monitoring when the box is first plugged in."
        ]),
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open it from the menu. It has three tabs: \"Settings\", \"How it works\" and \"What's new\".",
            "\"Settings\" holds the box, brightness, change profile with the app in front, the keys on screen (where they show, hide after a key, size), the iPhone card, open at login, permissions and bring over again.",
            "The version number, Quit and Done stay at the bottom."
        ]),
        Section(id: "kept", title: "Where things are kept", part: "settings", lines: [
            "Your setup is one file on this Mac, in the folder \"AMS Deck Mate\" inside Application Support.",
            "Each save first keeps the previous file as a safety copy. The last 20 are kept in a \"Backups\" folder beside it.",
            "Nothing leaves your Mac."
        ])
    ]

    static let releases: [Release] = [
        Release(id: "0.3", date: "16 Nov 2026", new: [
            "Deck Mate on the iPhone: a new iPhone app, on TestFlight. It shows the same 15 keys as the box, in the same places and with the same pictures.",
            "The iPhone follows the profile and page the Mac shows. When the app in front on the Mac changes and the profile changes with it, the iPhone changes too.",
            "Tap a key on the iPhone and the Mac does it, exactly as if the key had been pressed on the box. The keys on the Mac screen do not hide because of a tap on the iPhone.",
            "The iPhone finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "First time: the Mac asks \"“iPhone name” wants to use your keys. Allow?\" with Allow and Don't Allow. After Allow the iPhone is remembered. If you refuse, the iPhone shows \"Ask again\".",
            "The iPhone keeps its screen on while it is connected.",
            "iPhone Settings: which Mac it uses, \"Forget this Mac\", the version, How it works and What's new.",
            "The iPhone app works upright and sideways.",
            "The pictures are drawn by the Mac, so keys that open an app show the real app icons on the iPhone.",
            "A new card \"iPhone\" in the Mac's Settings: the checkbox \"Let an iPhone use these keys\" (on to start with), the iPhone connected right now, and the allowed iPhones, each with \"Forget\" to take the permission back.",
            "The first time, the Mac may ask to \"find devices on local networks\". That is this feature. Answer Allow.",
            "A Raycast folder in the author's own setup: on Page 1 of the Default Profile a key \"Raycast\" opens a folder with Back and 14 Raycast commands from the installed extensions: Clipboard, AI Chat, Ask Perplexity, Hide apps, New reminder, Reminders, Notion note, Find in Notion, Daily plan (NotePlan), Screenshot (CleanShot area), Text from screen (CleanShot OCR), Play/Pause and Next song (Spotify) and Passwords (1Password).",
            "The keys of that folder that need no window run quietly. You can change them in Set up keys as usual."
        ], changed: [
            "A key that opens an app and has no words of its own now shows the app's name. The keys of the Apps folder now read Mail, Safari, Calculator and so on. Words you write on a key always win. This is the same on the box, on the Mac screen and on the iPhone.",
            "Settings on the Mac now holds the iPhone card, and How it works has two new parts: \"On your iPhone\" and \"The iPhone card in Settings\"."
        ], fixed: []),
        Release(id: "0.2", date: "14 Nov 2026", new: [
            "Keys on screen can now work like a virtual deck: press Control-Option-D, the keys appear under the mouse, click one, and they are gone.",
            "\"Show them\": \"Where I left them\" (as before, the window comes back where you last dragged it) or \"At the mouse pointer\". With the pointer, the window appears centred on it each time it is shown, from the menu or with Control-Option-D. It starts as \"Where I left them\".",
            "At the mouse pointer: near an edge of the screen the window moves in until it is whole, 8 points from the edge. It appears on the screen the pointer is on. The place you drag it to is not remembered in this mode.",
            "\"Hide after a key is pressed\" (a checkbox, off to start with): after a click on a key that does something on the Mac, the keys hide by themselves. That means opening an app or a link, running a Raycast command, pressing a shortcut, typing text or controlling music.",
            "A key that only moves around leaves the keys open, because you are not done yet. That means a folder, Back, next or previous page and switch profile. A \"several things in a row\" key hides them when at least one of its steps does something on the Mac. Only clicks on the screen hide them, not pressing a key on the box.",
            "\"Size\": Small, Normal or Large. One key is 48, 64 or 80 points wide, with a gap of 6, 8 or 10 points. It starts as Normal, the size 0.1 had. The window changes size at once."
        ], changed: [
            "Settings has a new card, \"Keys on screen\", for these three choices."
        ], fixed: []),
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
