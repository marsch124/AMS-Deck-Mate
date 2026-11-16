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
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open Settings with the gear at the top right. Every choice applies at once and is remembered on this iPhone or iPad. Done closes Settings.",
            "Look, Background: Day and night (light by day, dark by night, as before), Always dark, Night blue, Forest or Plum. The three colours are deep, calm shades and the words turn light on them.",
            "Look, Key shape: Rounded (as before), Square or Pillow (very round corners).",
            "Look, Gaps between keys: Narrow, Normal (as before) or Wide.",
            "Look, Key size: Largest (as before) or A bit smaller (about 85 %, with more air around the keys).",
            "Look, Where the keys sit: Bottom (as before), Middle or Top.",
            "Clock, Clock above the keys (off at first): a large clock with the date in the free space above the keys. It only shows when there is room, for example on an iPad upright, but not on an iPhone on its side.",
            "Clock, Resting clock: Never (at first), or after 2, 5 or 10 minutes without a touch. The keys then fade away and only a large dimmed clock with the date shows, like a desk clock. One tap anywhere brings the keys back; that tap presses no key.",
            "Touch, Tap buzz (on at first): the small buzz when a key is tapped. An iPad has no buzz.",
            "Touch, Click sound (off at first): a soft click when a key is tapped. It follows the silent switch and the volume of the device.",
            "Touch, Swipe up or down changes profile (on at first). When it is off, a swipe up or down does nothing. Swiping left or right for pages always works.",
            "Showing, \"What ran\" note (on at first): the short note at the bottom after a tap.",
            "Showing, Page dots (on at first): the small dots under the keys.",
            "Showing, Keep the screen awake while connected (on at first). When it is off, the screen sleeps as usual.",
            "Your Mac: shows which Mac is used, with \"Forget this Mac\" (see below). This part is unchanged."
        ]),
        Section(id: "finding", title: "Finding your Mac", part: "settings", lines: [
            "It finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "Wi-Fi must be on, on the iPhone and on the Mac. Some hotel networks keep devices apart; then put the Mac on your iPhone's hotspot.",
            "The first time, the iPhone may ask to find devices on your local network. Choose Allow.",
            "On an iPad: put the iPad and the Mac on the same Wi-Fi, for example both on your iPhone's hotspot (an iPad without mobile data has no hotspot of its own)."
        ]),
        Section(id: "allowing", title: "Allowing the iPhone", part: "settings", lines: [
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" Choose Allow on the Mac.",
            "After that the Mac remembers your iPhone and the keys appear by themselves. An iPad is asked the same way, once, and appears in the Mac's \"iPhone\" part in Settings by its name.",
            "If the Mac was told Don't Allow, the iPhone shows \"Ask again\". Tap it and the Mac asks once more."
        ]),
        Section(id: "tapping", title: "Tapping keys", part: "keys", lines: [
            "A tap on a key makes the Mac do it. The keys on the Mac's own screen do not hide because of your tap.",
            "A key that opens a folder, goes back or moves to another page changes the keys on the iPhone and on the Mac together.",
            "A key that opens an app shows the real app icon, and its name when it has no words of its own. The Mac draws all the pictures.",
            "The iPhone keeps its screen on while it is connected. It works upright and sideways.",
            "On an iPad (since 0.5) the keys are large, low and centred, in all four ways round; since 0.5.1 they grow as far as the screen or window allows. On a newer iPad the app can open as a floating window: make it large once with the window's green button (or drag its corner) and the iPad remembers it. Everything else works the same.",
            "Since 0.4 the 15 keys sit low on the screen, near your thumb, with the place line on top.",
            "Swipe left or right on the keys for the next or previous page. Small dots under the keys show which page you are on. There are no dots inside a folder or when there is one page.",
            "A key you press lights up, whether you pressed it here, on the box or on the Mac's screen.",
            "After a tap a short note at the bottom says what ran, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". If the Mac could not do it, the note is red with a warning drawing, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "The screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "These new parts need the AMS Deck Mate app at 0.4 on your Mac."
        ]),
        Section(id: "profiles", title: "Profiles follow the Mac", part: "profiles", lines: [
            "The iPhone shows the profile and page the Mac shows. When the app in front on the Mac changes and the profile changes with it, the iPhone changes too.",
            "To use a different profile, tap the top line (the profile name). A menu offers \"Automatic\" or \"Lock one\" of the profiles, the same as the Mac's menu. A profile you picked by hand shows a small lock beside its name (since 0.5.2): it stays until you choose \"Automatic\". You can also change it on the Mac, or tap a key that switches profile.",
            "Since 0.5.1: swipe up or down on the keys for the next or previous profile. It is then locked (a small lock shows beside the name) until you choose \"Automatic\" in the top line."
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
        Release(id: "0.6", date: "16 Nov 2026", new: [
            "Settings on the iPhone and iPad. Open them with the gear at the top right. Every choice applies at once and is remembered on that device; Done closes. There are four groups.",
            "Look: Background (Day and night, Always dark, Night blue, Forest, Plum; the three colours are deep, calm shades and the words turn light on them), Key shape (Rounded, Square, Pillow with very round corners), Gaps between keys (Narrow, Normal, Wide), Key size (Largest, or A bit smaller at about 85 % with more air around) and Where the keys sit (Bottom, Middle, Top).",
            "Clock: \"Clock above the keys\" (off at first) shows a large clock with the date in the free space above the keys. It only shows when there is room, for example on an iPad upright, not on an iPhone on its side.",
            "Clock: \"Resting clock\" (Never at first, or after 2, 5 or 10 minutes without a touch). The keys fade away and only a large dimmed clock with the date shows, like a desk clock. One tap anywhere brings the keys back; that tap presses no key.",
            "Touch: Tap buzz (on at first; an iPad has no buzz), Click sound (off at first; a soft click that follows the silent switch and volume) and \"Swipe up or down changes profile\" (on at first; when off, an up or down swipe does nothing, while left and right for pages always works).",
            "Showing: the \"What ran\" note (on), Page dots (on) and \"Keep the screen awake while connected\" (on; when off, the screen sleeps as usual).",
            "The Mac app is unchanged at 0.4.2 and needs no update."
        ], changed: [
            "With the first choice of every setting, the app looks and works exactly as in 0.5.2. The \"Your Mac\" part with \"Forget this Mac\" is unchanged."
        ], fixed: []),
        Release(id: "0.5.2", date: "16 Nov 2026", new: [
            "A profile you picked by hand (from the top line's menu, by a swipe up or down, or from the Mac's menu) now shows a small hand-drawn lock beside the profile name. Locked means the profile stays until you choose \"Automatic\" (tap the top line). No lock means it follows the Mac.",
            "The menu section is now titled \"Lock one\".",
            "The Mac app is now 0.4.2 (it shows the same lock on its keys on screen). The two work together in any mix of versions."
        ], changed: [
            "The word \"held\" is gone everywhere; the texts now say \"locked\".",
            "iPad only: the top line is larger. The profile name is clearly bigger (title size, bold), the \"Connected to …\" line under it is bigger too, and the settings button is larger. The iPhone top line is unchanged."
        ], fixed: []),
        Release(id: "0.5.1", date: "16 Nov 2026", new: [
            "On a newer iPad the app can open as a floating window. Make it large once with the window's green button (or drag its corner) and the iPad remembers it.",
            "The keys on the iPad are larger: they now grow as far as the screen or window allows (before they stopped at a fixed width). On its side the iPad mini shows keys about a fifth larger.",
            "Swipe up or down on the keys to change profile: up for the next one, down for the one before, round the end. The profile is then held, like picking it from the top line; choose \"Automatic\" there to let it follow the Mac again. This works on the iPhone and the iPad.",
            "The Mac app stays at 0.4.1 and needs no update."
        ], changed: [
            "Swiping left or right for pages is unchanged."
        ], fixed: [
            "In a floating window the window's three round buttons lay over the profile name in the top line. The top line now steps aside for them if the app ever is in a window."
        ]),
        Release(id: "0.5", date: "16 Nov 2026", new: [
            "Deck Mate is now also a proper iPad app, made for the iPad mini. It fills the whole screen, upright and on its side (all four ways round), instead of a phone-sized window.",
            "On the iPad the 15 keys are larger and sit low and centred. The top line, page dots, swiping for pages, the profile menu, the lit keys and the \"what ran\" note work the same as on the iPhone.",
            "On an iPad the words on screen say \"iPad\" instead of \"iPhone\".",
            "On an iPad, the tip after 20 seconds of \"Looking for your Mac…\" says: put the iPad and the Mac on the same Wi-Fi, for example both on your iPhone's hotspot (an iPad without mobile data has no hotspot of its own).",
            "The Mac asks once whether to allow the iPad, exactly like an iPhone. In the Mac's Settings it appears in the \"iPhone\" part by its name.",
            "Install it from TestFlight on the iPad, like on the iPhone. The Mac app stays at 0.4.1 and needs no update."
        ], changed: [
            "Nothing changes on the iPhone except the version number."
        ], fixed: []),
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
