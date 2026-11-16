import Foundation

enum PhoneGuide {
    struct Section: Identifiable { let id: String; let title: String; let part: String; let lines: [String] }
    struct Release: Identifiable { let id: String; let date: String; let new: [String]; let changed: [String]; let fixed: [String] }

    static let sections: [Section] = [
        Section(id: "what", title: "What this app is for", part: "keys", lines: [
            "Deck Mate shows the keys of your Mac's Stream Deck on the iPhone: the same 15 keys, in the same places and with the same pictures.",
            "Tap a key and your Mac does it, exactly as if you had pressed it on the box.",
            "It needs the AMS Deck Mate app open on your Mac."
        ]),
        Section(id: "finding", title: "Finding your Mac", part: "settings", lines: [
            "It finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "Wi-Fi must be on, on the iPhone and on the Mac. Some hotel networks keep devices apart; then put the Mac on your iPhone's hotspot.",
            "The first time, the iPhone may ask to find devices on your local network. Choose Allow."
        ]),
        Section(id: "allowing", title: "Allowing the iPhone", part: "settings", lines: [
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" Choose Allow on the Mac.",
            "After that the Mac remembers your iPhone and the keys appear by themselves.",
            "If the Mac was told Don't Allow, the iPhone shows \"Ask again\". Tap it and the Mac asks once more."
        ]),
        Section(id: "tapping", title: "Tapping keys", part: "keys", lines: [
            "A tap on a key makes the Mac do it. The keys on the Mac's own screen do not hide because of your tap.",
            "A key that opens a folder, goes back or moves to another page changes the keys on the iPhone and on the Mac together.",
            "A key that opens an app shows the real app icon, and its name when it has no words of its own. The Mac draws all the pictures.",
            "The iPhone keeps its screen on while it is connected. It works upright and sideways.",
            "Since 0.4 the 15 keys sit low on the screen, near your thumb, with the place line on top.",
            "Swipe left or right on the keys for the next or previous page. Small dots under the keys show which page you are on. There are no dots inside a folder or when there is one page.",
            "A key you press lights up, whether you pressed it here, on the box or on the Mac's screen.",
            "After a tap a short note at the bottom says what ran, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". If the Mac could not do it, the note is red with a warning drawing, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "The screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "These new parts need the AMS Deck Mate app at 0.4 on your Mac."
        ]),
        Section(id: "profiles", title: "Profiles follow the Mac", part: "profiles", lines: [
            "The iPhone shows the profile and page the Mac shows. When the app in front on the Mac changes and the profile changes with it, the iPhone changes too.",
            "To use a different profile, tap the top line (the profile name). A menu offers \"Automatic\" or holding one of the profiles, the same as the Mac's menu. You can also change it on the Mac, or tap a key that switches profile."
        ]),
        Section(id: "raycast", title: "Raycast keys", part: "raycast", lines: [
            "A key that runs a Raycast command works from the iPhone like any other key. The command runs on the Mac.",
            "You set up keys on the Mac, in \"Set up keys\". The iPhone shows what you set up there."
        ]),
        Section(id: "forget", title: "Forget and ask again", part: "settings", lines: [
            "In the iPhone's Settings you see which Mac it uses. \"Forget this Mac\" makes the iPhone start fresh and ask the Mac again.",
            "On the Mac, the card \"iPhone\" in Settings lists the allowed iPhones. \"Forget\" takes the permission back. That iPhone then shows \"Ask again\".",
            "On the Mac, the checkbox \"Let an iPhone use these keys\" switches all of this on or off."
        ]),
        Section(id: "looking", title: "When it says \"Looking for your Mac…\"", part: "settings", lines: [
            "Check that the AMS Deck Mate app is open on your Mac, in the menu bar at the top.",
            "Check that Wi-Fi and Bluetooth are on, on the iPhone and on the Mac.",
            "Bring the iPhone close to the Mac.",
            "On the iPhone open Settings, Privacy & Security, Local Network, and make sure Deck Mate is switched on.",
            "On the Mac, in Deck Mate's Settings, the checkbox \"Let an iPhone use these keys\" must be on.",
            "After 20 seconds a card appears: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. The button \"Open Settings\" takes you to the iPhone's Settings. The close (x) button hides the card."
        ])
    ]

    static let releases: [Release] = [
        Release(id: "0.4", date: "16 Nov 2026", new: [
            "The keys sit low on the screen, near your thumb, with the place line on top.",
            "Swipe left or right on the keys for the next or previous page. Small page dots under the keys show which page you are on (none inside a folder or with one page).",
            "Tap the top line (the profile name) for a menu: \"Automatic\", or hold one of the profiles, the same as the Mac's menu.",
            "Pressed keys light up: a key pressed on the box, on the Mac's screen or on the iPhone shows pressed here.",
            "A short note at the bottom says what ran after a tap, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". A red note with a warning drawing says when the Mac could not do it, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "After 20 seconds of \"Looking for your Mac…\" a card explains: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. It has \"Open Settings\" and a close (x) button.",
            "The new parts need the AMS Deck Mate app at 0.4 on your Mac."
        ], changed: [
            "The screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "The \"could not do it\" note and the hotspot hint use the app's own warning and close drawings."
        ], fixed: []),
        Release(id: "0.3", date: "16 Nov 2026", new: [
            "The first Deck Mate for the iPhone.",
            "It shows the same 15 keys as your Mac's Stream Deck box, in the same places and with the same pictures.",
            "It follows the profile and page the Mac shows, and changes when the app in front on the Mac changes.",
            "Tap a key and the Mac does it, exactly as if you had pressed it on the box.",
            "It finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "The first time, the Mac asks to allow your iPhone. After Allow, the iPhone is remembered. If it was refused, the iPhone shows \"Ask again\".",
            "The screen stays on while the iPhone is connected.",
            "Works upright and sideways.",
            "Pictures are drawn by the Mac, so app keys show the real app icons. Keys that open an app and have no words of their own show the app's name.",
            "Settings: which Mac, \"Forget this Mac\", the version, How it works and What's new.",
            "When it says \"Looking for your Mac…\", How it works tells you what to check."
        ], changed: [], fixed: [])
    ]
}
