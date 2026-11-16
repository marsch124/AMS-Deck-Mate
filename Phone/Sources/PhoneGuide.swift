import Foundation

enum PhoneGuide {
    struct Section: Identifiable { let id: String; let title: String; let part: String; let lines: [String] }
    struct Release: Identifiable { let id: String; let date: String; let new: [String]; let changed: [String]; let fixed: [String] }

    static let sections: [Section] = [
        Section(id: "what", title: "What this app is for", part: "keys", lines: [
            "Deck Mate shows the keys of your Mac's Stream Deck on the iPhone: the same 15 keys, in the same places and with the same pictures. Since 0.7 it can also show a row of 5 favourites, the Mac's battery and front app, and what is playing on the Mac.",
            "Tap a key and your Mac does it, exactly as if you had pressed it on the box.",
            "It needs the AMS Deck Mate app open on your Mac."
        ]),
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open Settings with the gear at the top right. Every choice applies at once and is remembered on this iPhone or iPad. Done closes Settings. Since 0.7 the first part is \"Keys\".",
            "Keys (since 0.7, at the top): \"Follow the Mac\" (as before) or \"My own keys\", and then, in the row \"Page group\", you pick a page group. See \"My own keys\" below. With an older Mac this card says \"Needs AMS Deck Mate 0.5 on the Mac\" and the new parts stay hidden.",
            "Keys (since 0.8): a switch \"Navigation picture\" (on at first). It shows the page groups and pages as small pictures on the left of an iPad held on its side. It needs a Mac at 0.6.",
            "Look, Background: Day and night (light by day, dark by night, as before), Always dark, Night blue, Forest, Plum, Rust or Slate. The colours are deep, calm shades and the words turn light on them.",
            "Look, A colour for each page group (under Background): every page group from your Mac is listed with its own choice, \"Same as background\" (at first) or one of the colours. When that group shows, the background takes its colour, so you see at a glance which one is up. It needs a Mac at 0.4 or later, because the list comes from the Mac. Before a Mac is connected the list says so.",
            "Look, Key shape: Rounded (as before), Square or Pillow (very round corners).",
            "Look, Gaps between keys: Narrow, Normal (as before) or Wide.",
            "Look, Key size: Largest (as before) or A bit smaller (about 85 %, with more air around the keys).",
            "Look, Where the keys sit: Bottom (as before), Middle or Top.",
            "Clock, Clock above the keys (off at first): a large clock with the date in the free space above the keys. It only shows when there is room, for example on an iPad upright, but not on an iPhone on its side.",
            "Clock, Resting clock: Never (at first), or after 2, 5 or 10 minutes without a touch. The keys then fade away and only a large dimmed clock with the date shows, like a desk clock. One tap anywhere brings the keys back; that tap presses no key.",
            "Touch, Tap buzz (on at first): the small buzz when a key is tapped. An iPad has no buzz.",
            "Touch, Click sound (off at first): a soft click when a key is tapped. It follows the silent switch and the volume of the device.",
            "Touch, Swipe up or down changes page group (on at first). When it is off, a swipe up or down does nothing. Swiping left or right for pages always works.",
            "Showing, \"What ran\" note (on at first): the short note at the bottom after a tap.",
            "Showing, Page dots (on at first): the small dots under the keys.",
            "Showing, Keep the screen awake while connected (on at first). When it is off, the screen sleeps as usual.",
            "Showing, Warn when the battery is low (on at first): when the iPhone or iPad is at 20 % or less and not charging, a small amber line such as \"Battery 18 % – plug in\" shows centred under the heading, and also under the resting clock. It goes away when charging or above 20 %.",
            "Showing, Favourites row (on at first): the row of 5 favourite keys under the 15 keys. It only shows when at least one favourite is set on the Mac. Needs a Mac at 0.5.",
            "Showing, Mac at a glance (on at first): the Mac's battery in percent and the name of the app in front, as one very small line at the very bottom, under the page dots. Needs a Mac at 0.5.",
            "Showing, Music button (on at first): one small round button at the top right, beside the settings button. Tap it for a small plate that shows what is playing on the Mac, with buttons. Needs a Mac at 0.5.",
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
            "These new parts need the AMS Deck Mate app at 0.4 on your Mac. The parts new in 0.7 (own keys, long press, favourites, Mac at a glance, music button) need it at 0.5."
        ]),
        Section(id: "profiles", title: "Page groups follow the Mac", part: "profiles", lines: [
            "The iPhone shows the page group and page the Mac shows. When the app in front on the Mac changes and the page group changes with it, the iPhone changes too.",
            "To use a different page group, tap the top line (the name of the group). A menu offers \"Automatic\" or \"Lock one\" of the page groups, the same as the Mac's menu. A group you picked by hand shows a small lock beside its name (since 0.5.2): it stays until you choose \"Automatic\". You can also change it on the Mac, or tap a key that switches page group.",
            "Since 0.5.1: swipe up or down on the keys for the next or previous page group. It is then locked (a small lock shows beside the name) until you choose \"Automatic\" in the top line."
        ]),
        Section(id: "ownkeys", title: "My own keys", part: "profiles", lines: [
            "In Settings, the card \"Keys\" at the top has two choices. \"Follow the Mac\" is as before: this iPhone or iPad shows the page group and page the Mac shows.",
            "\"My own keys\": pick a page group in the row \"Page group\". This iPhone or iPad then moves through that group on its own: pages, folders and Back, at its own place.",
            "The Mac's keys on screen and the box stay where they are, and the Mac still does what the tapped key says. Keys pressed elsewhere do not light up here.",
            "Swipe up or down on the keys, or use the menu in the top line, to change your own page group. It is remembered on this device. With own keys there is no lock and no \"Automatic\" in that menu. If the group you picked is gone, the default group shows.",
            "The Mac keeps one place for each connected device, for as long as it is connected. After it connects again, the device starts at the first page of its group.",
            "Needs the AMS Deck Mate app at 0.5 on the Mac. With an older Mac, the Keys card says \"Needs AMS Deck Mate 0.5 on the Mac\" and the app follows the Mac as before."
        ]),
        Section(id: "navmap", title: "The navigation picture", part: "keys", lines: [
            "On an iPad held on its side (wider than tall), the keys sit on the right and, on the left, a picture shows every page group with every one of its pages and folders as a small picture of its 15 keys, with the page's name under it.",
            "The page showing now has a coloured frame, and its page group's name is highlighted. The list scrolls when it is long.",
            "Tap a small page and the keys go there. When the iPad follows the Mac, the Mac goes there too and that page group is locked until you choose \"Automatic\" in the top line. With \"My own keys\", only the iPad's own place moves, and the page group you picked is remembered.",
            "An iPad held upright and the iPhone show no picture, because there is no room.",
            "In Settings, the switch \"Navigation picture\" in the Keys card (on at first) turns it off.",
            "Needs the AMS Deck Mate app at 0.6 on the Mac. With an older Mac the picture stays hidden. Not yet tried on the real iPad."
        ]),
        Section(id: "longpress", title: "Long press", part: "keys", lines: [
            "A key with a small white dot in its top right corner has a second action. Hold the key for half a second and the second action runs. You feel a stronger buzz.",
            "A long press on a key without a dot does the usual thing, as if you had tapped.",
            "You set the second action on the Mac, in Set up keys, under \"What it does\", in the picker \"Long press\".",
            "A broken long-press action shows the red corner, and the Mac says \"Long press: <reason>\".",
            "Needs the AMS Deck Mate app at 0.5 on the Mac. Not yet tried on a real iPhone or iPad."
        ]),
        Section(id: "favourites", title: "The favourites row", part: "keys", lines: [
            "5 keys that stay in place on every page and in every page group. They show as a row under the 15 keys.",
            "You set them on the Mac, in Set up keys, in the row \"Favourites\" under the 15 keys. A favourite can be anything except a folder or Back, and it can have a long press too.",
            "A favourite that moves to another page or page group moves your own place when this device has its own keys, and otherwise the Mac's place.",
            "The row only shows when at least one favourite is set. In Settings, the switch \"Favourites row\" (on at first) turns it off.",
            "Needs the AMS Deck Mate app at 0.5 on the Mac."
        ]),
        Section(id: "macnow", title: "The Mac at a glance and the music button", part: "settings", lines: [
            "Mac at a glance: one very small line at the very bottom of the screen, under the page dots, shows a small battery drawing and the Mac's battery in percent, with the app in front, for example \"82 % · Safari\", or \"82 % charging · Safari\" while it charges. A Mac without a battery shows only the app.",
            "Music button: a small round button at the top right, beside the settings button. It is filled green while something is playing. Tap it and a small plate opens with the song and artist playing on the Mac (Spotify and Apple Music), buttons for play or pause, next, quieter and louder, and the Mac's volume in percent. Tap outside the plate to close it. One tap on quieter or louder moves the volume by 6 points.",
            "Until the next change of song or pause after the Mac app has started, the plate says \"Nothing playing yet\". The Mac hears about the song from the player only when something changes.",
            "Play or pause and next use the same one-time Accessibility permission on the Mac as music keys. Volume needs none. Play or pause is not yet tried.",
            "The Mac looks at its battery and volume every 5 seconds, but only while such a device is connected.",
            "Both have a switch in Settings (\"Mac at a glance\" and \"Music button\", on at first). Both need the AMS Deck Mate app at 0.5 on the Mac."
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
        Release(id: "0.8.1", date: "16 Nov 2026", new: [], changed: [
            "The top of the key screen is less crowded. Everything below is on the key screen of the iPhone and iPad.",
            "The heading is larger and centred. The place, for example \"OmniFocus · OF Main\", now sits in the middle at the top: bold large title size on the iPad, title size on the iPhone. A tap on it still opens the menu of page groups, and the lock still shows beside it.",
            "The connection is one small coloured dot at the top left, instead of the line \"Connected to …\". Green means connected. Amber means looking, connecting or waiting for the Mac to allow it. Red means the Mac said no. Tap the dot for a small card that says it in words, for example \"Connected to MS MBP 2021\", and what the colours mean. The big message card in the middle while there is no Mac is unchanged.",
            "Music is one small round button at the top right, beside the settings button, instead of the strip across the screen. Tap it and a small plate opens with the song and artist, play or pause, next, quieter, the volume in percent and louder. Tap outside the plate to close it. The button is filled green while something is playing. The switch in Settings is now called \"Music button\" (it was \"Music strip\"); your choice is kept.",
            "The Mac at a glance moved to the bottom. The Mac's battery and the app in front, for example \"73 % charging · Claude\", is now one very small centred line at the very bottom of the screen, under the page dots, and no longer in the top line. It has the same switch \"Mac at a glance\".",
            "The iPad's own low battery warning, \"Battery 18 % – plug in\", now sits centred under the heading.",
            "How it works has the new places for all of these. The Mac app is unchanged (0.6, build 8)."
        ], fixed: []),
        Release(id: "0.8", date: "16 Nov 2026", new: [
            "Navigation picture on the iPad. When the iPad is held on its side (wider than tall), the keys now sit on the right and, on the left, a picture shows everything you have set up: every page group, with every one of its pages and folders as a small picture of its 15 keys and the page's name under it.",
            "The page showing now has a coloured frame, and the name of its page group is highlighted. When the list is long, it scrolls.",
            "It is live. Tap a small page and the keys go there. When this iPad follows the Mac, the Mac goes there too and that page group is locked, just as if you had picked it in the top-line menu. \"Automatic\" in that menu lets it follow the app in front again.",
            "With \"My own keys\", only this iPad's own place moves, and the page group you picked is remembered.",
            "An iPad held upright and the iPhone look and work as before, because there is no room on the left.",
            "In Settings, the Keys card has a new switch \"Navigation picture\" (on at first), with the note that it shows on an iPad held on its side.",
            "The Mac draws the small pictures and sends them when your setup changes. This needs the AMS Deck Mate app at 0.6 on the Mac (now 0.6, build 8).",
            "Not yet tried: the navigation picture on the real iPad."
        ], changed: [
            "With an older Mac, the picture stays hidden and everything else works as before.",
            "How it works has a new part, \"The navigation picture\", and Settings has the new line."
        ], fixed: []),
        Release(id: "0.7", date: "16 Nov 2026", new: [
            "My own keys. In Settings there is a new card \"Keys\" at the top. \"Follow the Mac\" is as before: it shows the page group and page the Mac shows. \"My own keys\": pick a page group, and this iPhone or iPad then moves through that group on its own: pages, folders and Back, at its own place.",
            "With own keys, the Mac's keys on screen and the box stay where they are, and the Mac still does what the tapped key says. Swipe up or down, or the menu in the top line, changes your own page group, and it is remembered on the device. There is no lock and no \"Automatic\" then. If the group is gone, the default group shows. Keys pressed elsewhere do not light up here.",
            "The Mac keeps one place for each connected device while it is connected; after it connects again the device starts at the first page of its group.",
            "Long press: a key with a second action shows a small white dot in its top right corner. Hold the key for half a second and the second action runs, with a stronger buzz. A long press on a key without a second action does the usual thing. You set the second action on the Mac, in Set up keys.",
            "Favourites row: 5 keys that stay in place on every page and in every page group, shown as a row under the 15 keys. You set them on the Mac, in Set up keys. A switch \"Favourites row\" in Settings (on at first); the row only shows when at least one favourite is set.",
            "Mac at a glance: the top line shows a small battery drawing and the Mac's battery in percent with the app in front, for example \"82 % · Safari\" (\"82 % charging · Safari\" while it charges). A Mac without a battery shows only the app. A switch \"Mac at a glance\" in Settings (on at first).",
            "Music strip: above the keys, song and artist (Spotify and Apple Music), play or pause, next, quieter, the Mac's volume in percent and louder (6 points per tap). A switch \"Music strip\" in Settings (on at first).",
            "The strip says \"Nothing playing yet\" until the next change of song or pause after the Mac app has started, because the Mac hears about it from the player when something changes.",
            "Play or pause and next need the Mac's one-time Accessibility permission, the same as music keys. Volume needs none. The Mac looks at battery and volume every 5 seconds, only while such a device is connected.",
            "These new parts need the AMS Deck Mate app at 0.5 on the Mac (now 0.5, build 7).",
            "Not yet tried: long press on a real iPhone or iPad and on the real box, and play or pause from the strip."
        ], changed: [
            "With an older Mac, the app works as before. The Keys card in Settings says \"Needs AMS Deck Mate 0.5 on the Mac\", and the new parts stay hidden.",
            "With the first choice of every setting the app looks as in 0.6.1, apart from the new strips (music, Mac at a glance and favourites), which are on at first and show only when the Mac can send them.",
            "The word “profile” is now “page group” everywhere."
        ], fixed: []),
        Release(id: "0.6.1", date: "16 Nov 2026", new: [
            "A colour for each profile. In Settings, Look, under Background, every profile from your Mac is listed with its own choice: \"Same as background\" (at first) or one of the colours. When that profile shows, the background takes its colour, so you see at a glance which profile is up. It needs a Mac at 0.4 or later, because the list of profiles comes from the Mac; before a Mac is connected the list says so.",
            "Two more background colours, Rust and Slate. The colours are now Night blue, Forest, Plum, Rust and Slate, plus Always dark and Day and night.",
            "Low battery warning. In Settings, Showing, \"Warn when the battery is low\" (on at first): when the iPhone or iPad is at 20 % or less and not charging, a small amber line such as \"Battery 18 % – plug in\" shows in the top line, and also under the resting clock. It goes away when charging or above 20 %.",
            "The Mac app is unchanged at 0.4.2 and needs no update."
        ], changed: [
            "With the first choice of every setting, the app looks and works as in 0.6, apart from the battery line, which is on at first."
        ], fixed: []),
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
