import Foundation

enum PhoneGuide {
    struct Section: Identifiable { let id: String; let title: String; let part: String; let lines: [String] }
    struct Release: Identifiable { let id: String; let date: String; let new: [String]; let changed: [String]; let fixed: [String] }

    static let sections: [Section] = [
        Section(id: "what", title: "What this app is for", part: "keys", lines: [
            "Deck Mate shows the keys of your Mac's Stream Deck on the iPhone: the same 15 keys, in the same places and with the same pictures. Since 0.7 it can also show a row of 5 favourites, the app in front on the Mac, and what is playing on the Mac.",
            "Tap a key and your Mac does it, exactly as if you had pressed it on the box.",
            "It needs the AMS Deck Mate app open on your Mac."
        ]),
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open Settings with the gear. It is at the top right; since 0.13, with the iPad held on its side, it is at the bottom left; since 0.16, with the iPhone held on its side, it is in a narrow column to the right of the keys, at the bottom corner. Every choice applies at once and is remembered on this iPhone or iPad. Done closes Settings. Since 0.7 the first part is \"Keys\".",
            "Keys (since 0.7, at the top): \"Follow the Mac\" (as before) or \"My own keys\", and then, in the row \"Page group\", you pick a page group. See \"My own keys\" below. With an older Mac this card says \"Needs AMS Deck Mate 0.5 on the Mac\" and the new parts stay hidden.",
            "Showing (since 0.18; before in Keys): a switch \"Navigation picture\" (on at first). It shows the page groups and pages as small pictures on the left of an iPad or iPhone held on its side (iPhone since 0.10). Since 0.20 a swipe to the left on the picture turns this switch off, and the purple \"Pages\" tab (or a tap on it) turns it on again; the switch always shows the same state. Since 0.22 a second switch right under it (called \"Hide the picture by itself\" since 0.23, before \"Hide the picture after a minute\"; on at first) hides the picture by itself when the device is on its side and nothing has been touched for a while; off, the picture stays until you swipe it away. New in 0.23: while that switch is on, a choice \"After\" under it sets the quiet time: 30 seconds, 1 minute (as before, the starting choice) or 2 minutes. It needs a Mac at 0.6. The note about holding a key for its long-press action now stands under Touch.",
            "Look, Background: Day and night (light by day, dark by night, as before), Always dark, Night blue, Forest, Plum, Rust or Slate. The colours are deep, calm shades and the words turn light on them.",
            "Look, A colour for each page group (under Background): every page group from your Mac is listed with its own choice, \"Same as background\" (at first) or one of the colours. When that group shows, the background takes its colour, so you see at a glance which one is up. It needs a Mac at 0.4 or later, because the list comes from the Mac. Before a Mac is connected the list says so.",
            "Look, Key shape: Rounded (as before), Square or Pillow (very round corners).",
            "Look, Gaps between keys: Narrow, Normal (as before) or Wide.",
            "Look, Key size: Largest (as before) or A bit smaller (about 85 %, with more air around the keys).",
            "Look, Where the keys sit: Bottom (as before), Middle or Top.",
            "Clock, Clock above the keys (off at first): a large clock with the date in the free space above the keys. It only shows when there is room: on an iPad on its side there is room above the keys; on an iPhone on its side there is none.",
            "Clock, Resting clock: Never (at first), or after 2, 5 or 10 minutes without a touch. The keys then fade away and only a large dimmed clock with the date shows, like a desk clock. New in 0.18: the screen gets dim too, to about a quarter of the brightness you had (never below 5 %), and the keys are not drawn meanwhile. One tap anywhere brings the keys and your brightness back; that tap presses no key. Your brightness also comes back when you leave the app.",
            "Clock, Rest sooner in the evening (new in 0.18, off at first): with its From and To times (21:30 and 07:00 at first; the time may pass midnight). Between them the resting clock comes after 1 minute without a touch, whatever Resting clock says, also when it says Never.",
            "Touch, Tap buzz (on at first): the small buzz when a key is tapped. An iPad has no buzz.",
            "Touch, Click sound (off at first): a soft click when a key is tapped. It follows the silent switch and the volume of the device.",
            "Touch, Hold a key for half a second for its long-press action (keys with a small dot have one).",
            "Touch, Swipe up or down changes page group (on at first). When it is off, a swipe up or down does nothing. Swiping left or right for pages always works.",
            "Showing, \"What ran\" note (on at first): the short note at the bottom after a tap. New in 0.18: a key that did not work always shows its red note, also when this switch is off. Since 0.11 it also shows the short note \"Mac is back\" when the Mac wakes from sleep, so the same switch hides both.",
            "Showing, Page dots (on at first): the small dots under the keys.",
            "Showing, Several pages at once (new in 0.19, off at first): on the iPhone 2 pages side by side, on the iPad 4 pages. See \"Several pages at once\" below. It needs a Mac at 0.17; with an older Mac the switch says so.",
            "Showing, Keep the screen awake while connected (on at first). When it is off, the screen sleeps as usual.",
            "Showing, Dark while the Mac sleeps (on at first, since 0.9): when the Mac's screen goes to sleep, this screen goes black with a small moon and \"Mac asleep\". See \"Dark while the Mac sleeps\" below. Needs a Mac at 0.7.",
            "Showing, Warn when the battery is low (on at first): when the iPhone or iPad is at 20 % or less and not charging, a small amber line such as \"Battery 18 % – plug in\" shows centred under the heading, and also under the resting clock. It goes away when charging or above 20 %.",
            "Showing, Favourites row (on at first; since 0.18 in Showing, before in Keys): the row of 5 round favourite keys under the 15 keys (since 0.21 a column on the left beside the \"Pages\" tab, while the navigation picture is hidden on a device held on its side). It only shows when at least one favourite is set on the Mac. Needs a Mac at 0.5.",
            "Showing, Mac at a glance (on at first; since 0.18 in Showing): the name of the app in front on the Mac, as one small pill at the bottom middle, in the same green as the settings gear (since 0.13 a pill; since 0.14 without the battery; since 0.15 green instead of blue). Needs a Mac at 0.5.",
            "Showing, Music button (on at first; since 0.18 in Showing): one small round button. With the iPad on its side it is at the bottom left; with the iPhone on its side it is in the narrow column beside the keys, second from the bottom. Tap it for a small plate that shows what is playing on the Mac, with buttons. Needs a Mac at 0.5.",
                        "New in 0.19: the small lock, music and gear buttons have a tiny word under them (\"Private\", \"Music\", \"Settings\"), and the coloured link dot has the word \"Mac\" under it (a tap still says in words what its colour means). See \"Signs in this app\".",
"Your Mac: shows which Mac is used, with \"Forget this Mac\" (see below). This part is unchanged."
        ]),
        Section(id: "finding", title: "Finding your Mac", part: "settings", lines: [
            "It finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "Wi-Fi must be on, on the iPhone and on the Mac. Some hotel networks keep devices apart; then put the Mac on your iPhone's hotspot.",
            "The first time, the iPhone may ask to find devices on your local network. Choose Allow.",
            "On an iPad: put the iPad and the Mac on the same Wi-Fi, for example both on your iPhone's hotspot (an iPad without mobile data has no hotspot of its own)."
        ]),
        Section(id: "allowing", title: "Allowing the iPhone", part: "settings", lines: [
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" and shows a 4-digit number. This iPhone or iPad shows the same number. Choose Allow on the Mac only if both numbers are the same.",
            "After that the Mac remembers your iPhone and the keys appear by themselves. An iPad is asked the same way, once, and appears in the Mac's \"iPhone\" part in Settings by its name.",
            "Since 0.11 the link to the Mac is private: everything is scrambled from the first moment, so on a shared Wi-Fi (hotel, café) nobody can listen in or press your keys. The number is there so nobody can sit in between.",
            "Every iPhone and iPad has to be allowed once more after the update (one click on the Mac). The app 0.11 only talks to a Mac at 0.8 or later. With an older Mac it says \"Update AMS Deck Mate on your Mac\". An older app with the new Mac sees \"said no\".",
            "Since 0.12, while this device is connected, a small lock drawing says the line to the Mac is private. Since 0.15 it is the same green as the settings gear and a little larger. Held upright it sits beside the status dot at the top left. Held on its side it sits in the line with the settings gear and the music button (gear, music, lock): on the iPad at the bottom left, and since 0.16 on the iPhone in a narrow column to the right of the keys, at the bottom, above the music button and the gear. A tap on it shows a small card: \"Private line: nobody else on the Wi-Fi can read your keys or press them.\" A tap on the dot shows the connection card with the same sentence. The dot itself is the same green as the gear when connected, amber while looking or waiting, red when the Mac said no.",
            "If the Mac was told Don't Allow, the iPhone shows \"Ask again\". Tap it and the Mac asks once more.",
            "New in 0.18: while it waits for you to click Allow, after 30 seconds the card adds a line: wake the Mac and look for the window \"… wants to use your keys\", with a button \"Ask again\" that asks the Mac once more.",
            "New in 0.18: the permission your Mac gave this device is now kept in the device's safe store (the Keychain), only on this device, and moves there by itself; you are not asked to allow again. \"Forget this Mac\" removes it there too.",
            "New in 0.18: when the Mac is away but still listed, the app looks again after 1, 2, 4, 8, 15 and then every 30 seconds, instead of every second. It is back to 1 second when a line worked, when you return to the app, with Ask again, and when the Mac shows up again.",
            "New in 0.17: the line \"Update AMS Deck Mate on your Mac\" only comes up when the Mac was reached and did not answer two tries in a row. A sleeping Mac or a Wi-Fi blip no longer brings it up. \"Ask again\", and coming back to the app, start the count afresh."
        ]),
        Section(id: "tapping", title: "Tapping keys", part: "keys", lines: [
            "A tap on a key makes the Mac do it. The keys on the Mac's own screen do not hide because of your tap.",
            "A key that opens a folder, goes back or moves to another page changes the keys on the iPhone and on the Mac together.",
            "A key that opens an app shows the real app icon, and its name when it has no words of its own. The Mac draws all the pictures.",
            "The iPhone keeps its screen on while it is connected, except while the Mac sleeps (since 0.9, see \"Dark while the Mac sleeps\"). It works upright and sideways.",
            "On an iPad (since 0.5) the keys are large, low and centred, in all four ways round; since 0.5.1 they grow as far as the screen or window allows. On a newer iPad the app can open as a floating window: make it large once with the window's green button (or drag its corner) and the iPad remembers it. Everything else works the same.",
            "Since 0.4 the 15 keys sit low on the screen, near your thumb, with the place line on top.",
            "Held on its side (since 0.10), the iPhone puts the note on what a key did and the navigation picture in a panel on the left, so the keys get the whole height on the right and are much larger. Before 0.16 the top line (status dot and page group name) stood in that panel too, above the picture. Since 0.16 the top line stands in one line in the middle above the keys, with the status dot right in front of it, in the free room that was already there, so the keys keep their size and place. Also since 0.16 the pill with the app in front, the lock, the music button and the settings gear sit in one narrow column to the right of the keys, in the empty strip by the screen's edge: the pill at the top, in line with the top keys, turned on its side; the lock, music button and gear at the bottom, in line with the bottom keys, one above the other with the gear lowest, in the corner. The keys keep their size and place, and the left panel holds only the navigation picture, which now starts at the very top and uses the whole height of the panel (a low battery line or the note on what a key did, when shown, still appear above it). If the iPhone is turned the other way, with the camera cut-out on the right, the column moves to the free strip at the left edge of the screen, so nothing hides behind the cut-out. In 0.13 to 0.15 these buttons sat at the bottom of the left panel, which cut the picture short; before 0.13 the music button and the gear were in the top line. New in 0.24: while the navigation picture is hidden, the heading line over the keys (page group · page, with the coloured link dot) steps aside, so the keys get its height too: from 96 to 106 points. The link dot moves to the top of the narrow column beside the keys, above the Mac app, lock, music button and gear, and a tap on it still says in words what its colour means. The page dots under the keys still show which page you are on, and the page group's name shows again when the picture comes back. An iPad keeps its heading.",
            "Swipe left or right on the keys for the next or previous page. Small dots under the keys show which page you are on. There are no dots inside a folder or when there is one page.",
            "A key you press lights up, whether you pressed it here, on the box or on the Mac's screen.",
            "After a tap a short note at the bottom says what ran, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". If the Mac could not do it, the note is red with a warning drawing and always shows, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "The screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "These new parts need the AMS Deck Mate app at 0.4 on your Mac. The parts new in 0.7 (own keys, long press, favourites, Mac at a glance, music button) need it at 0.5."
        ]),
        Section(id: "profiles", title: "Page groups follow the Mac", part: "profiles", lines: [
            "The iPhone shows the page group and page the Mac shows. When the app in front on the Mac changes and the page group changes with it, the iPhone changes too.",
            "To use a different page group, open Settings and use the row \"Page group\" in the Keys card (since 0.10). Its chips are \"Automatic\" and one chip for each page group, the same as the Mac's menu. A group you pick locks: it stays until you choose \"Automatic\", and a small lock drawing shows on its chip. The name at the top is only a heading; tapping it does nothing. You can also change it on the Mac, or tap a key that switches page group.",
            "Swipe up or down on the keys to look at the next or previous page group. Since 0.10.1 this does not lock it: you stay on \"Automatic\", and the next time a different app comes forward on the Mac, the keys follow that app again. If a group was locked before the swipe, the swipe unlocks it. Only picking a group in Settings, or tapping a page in the navigation picture, locks. Needs the Mac app at 0.7.1; with an older Mac app a swipe still locks, as it did in 0.5.1 to 0.10."
        ]),
        Section(id: "ownkeys", title: "My own keys", part: "profiles", lines: [
            "In Settings, the card \"Keys\" at the top has two choices. \"Follow the Mac\" is as before: this iPhone or iPad shows the page group and page the Mac shows.",
            "\"My own keys\": pick a page group in the row \"Page group\". This iPhone or iPad then moves through that group on its own: pages, folders and Back, at its own place.",
            "The Mac's keys on screen and the box stay where they are, and the Mac still does what the tapped key says. Keys pressed elsewhere do not light up here.",
            "Swipe up or down on the keys, or use the row \"Page group\" in Settings, to change your own page group. It is remembered on this device. With own keys there is no lock and no \"Automatic\" chip in that row. If the group you picked is gone, the default group shows.",
            "The Mac keeps one place for each connected device, for as long as it is connected. After it connects again, the device starts at the first page of its group.",
            "Needs the AMS Deck Mate app at 0.5 on the Mac. With an older Mac, the Keys card says \"Needs AMS Deck Mate 0.5 on the Mac\" and the app follows the Mac as before."
        ]),
        Section(id: "navmap", title: "The navigation picture", part: "keys", lines: [
            "On an iPad or an iPhone held on its side (wider than tall; the iPhone since 0.10), the keys sit on the right and, in the panel on the left, a picture shows every page group with every one of its pages and folders as a small picture of its 15 keys, with the page's name under it.",
            "The page showing now has a blue frame. Since 0.16 each page group sits in its own framed panel: its name is white bold words on a full-colour ribbon across both small pages, purple for the page group you are in and grey-blue for the others, and the panel behind the pages is softly tinted in the same colour. Before 0.16 the name was a plain small word above the pages, purple or grey. The list scrolls when it is long.",
            "Tap a small page and the keys go there. When the iPad follows the Mac, the Mac goes there too and that page group is locked until you choose \"Automatic\" in Settings, Keys, row \"Page group\". With \"My own keys\", only the iPad's own place moves, and the page group you picked is remembered.",
            "An iPad or iPhone held upright shows no picture, because there is no room.",
            "In Settings, the switch \"Navigation picture\" in the Showing card (on at first) turns it off.",
            "New in 0.20, only with the device on its side: swipe to the left on the navigation picture to hide it. The picture follows your finger and slides off to the left, and the keys grow into the room it leaves, live, as you drag (they grow when the width is what holds them back: on an iPad without the favourites row, from about 210 to about 246 points, about a sixth bigger. With the favourites row on, and on an iPhone, the keys are already as tall as the screen allows, so they keep their size and the picture simply makes room). Let go and it springs away by itself; let go early (less than a third of the way, and no quick flick) and it springs back open.",
            "When it is hidden, a thin purple tab stands at the left edge, as tall as the keys, with the word \"Pages\" running up it and a small grip mark. Tap the tab, or pull it to the right: the picture follows your finger out again, the keys shrink back, and it springs into place. The tab is the same purple as the ribbon of the page group you are in. Since 0.22 the word \"Pages\" is bigger (15-point bold type, before 12-point) and the tab is 28 points wide (before 22). Since 0.21 the tab is exactly as tall as the keys, its top and bottom in line with them, on the iPhone too (before, on the iPhone it ran the whole height of the left side, from the top of the screen).",
            "New in 0.21: while the picture is hidden and the favourites row is on, the favourites stand in a column of five round keys right next to the tab (see \"The favourites row\"), and the 15 keys grow. On an iPhone the tab also sits about 12 points closer to the screen's left edge, and the favourites column and the keys sit right next to it (before, the keys stood in the middle with a wide gap after the tab).",
            "Swipes on the keys still change pages; only a swipe on the picture or on the tab hides or shows it. The swipe is the same as the Settings switch \"Navigation picture\": it turns that switch on or off, so it is remembered after the app closes.",
            "New in 0.22: the picture also hides by itself. With the device on its side, after one minute in which nothing on the screen was touched, it slides away with the same spring as a swipe, the favourites move into the column and the keys grow. Any touch anywhere starts the minute again. Tap or pull the \"Pages\" tab to bring it back; it hides again after the next quiet minute. Hiding by itself turns the \"Navigation picture\" switch off too, so it stays hidden after the app is closed until you bring it back. In Settings, Showing, the switch \"Hide the picture after a minute\" (on at first) turns this off.",
            "New in 0.23: you can pick the quiet time. In Settings, Showing, under the switch \"Hide the picture by itself\" (before 0.23 \"Hide the picture after a minute\"), the choice \"After\" offers 30 seconds, 1 minute (as before, the starting choice) or 2 minutes. It shows only while the switch is on. Also new: when the picture hides by itself (not when you swipe it away), the \"Pages\" tab nudges twice: it moves a little to the right and back two times, and its purple turns lighter for a moment, about a second and a half in all, so you see where the picture went. No glow, no sound. A swipe by hand does not nudge the tab.",
            "New in 0.24: hold the \"Pages\" tab for about half a second and a small list of your page groups opens. Tap one to jump straight to its first page, without opening the picture. The group you are in says \"(here)\" after its name. A plain tap on the tab still brings the picture back.",
            "Also new in 0.24: a soft tap feel, a light buzz, when the picture snaps away or comes back by your own swipe, pull or tap on the tab. It follows the switch \"Tap buzz\" in Settings, Touch (an iPad has no buzz). When the picture hides by itself there is no buzz.",
            "Also new in 0.24, iPhone only, held on its side with the picture hidden: the heading line over the keys steps aside, so the keys get its height too (96 to 106 points). The link dot moves to the top of the narrow column beside the keys and still says in words what its colour means when tapped. The page dots still show your page; the page group's name shows again when the picture comes back. An iPad keeps its heading.",
            "New in 0.25: on an iPhone held on its side with the picture hidden, the \"Pages\" tab also shows the name of the page group you are in, small and in lighter white, under the word \"Pages\" and running up the tab like it, so you still see where you are without the heading. A long name is shortened with \"…\". An iPad keeps its heading, so its tab shows only \"Pages\".",
            "Also new in 0.25: a small purple hint \"Hold for groups\" under the bottom of the \"Pages\" tab says that holding the tab opens the list of page groups. It shows for 8 seconds each time the tab appears (the picture hidden by a swipe or by itself), the first 3 times only, and never again once you have used the list (held the tab and picked a page group).",
            "New in 0.26: swipe up or down on the \"Pages\" tab (picture hidden) to go to the next or previous page group: up = the next one, down = the one before, the same as swiping up or down on the keys. It follows the Settings switch \"Swipe up or down changes page group\" (Touch): off there, off on the tab too. A soft buzz goes with it (switch \"Tap buzz\"), and on an iPhone the group's name on the tab changes with it. A tap still brings the picture back, holding still opens the list, and a swipe left or right still pulls the picture out. Also new: the hint \"Hold for groups\" is a lighter purple on a dark background, so it reads well at night.",
            "On an iPhone, while the picture is hidden, the battery warning line and the note on what a key did move over the keys, at the top in the middle.",
            "Since 0.13, on an iPad held on its side, the navigation picture is as tall as the keys: its top edge is in line with the top row of keys and its bottom edge with the bottom row of keys. Before, it started right under the top line, higher than the keys, and ran down past the page dots. When there are more pages than fit, it scrolls as before.",
            "Since 0.16, on an iPhone held on its side, the navigation picture uses the whole height of the left panel, because the app pill, lock, music button and gear moved to a narrow column to the right of the keys and the heading moved above the keys. It is about 54 points taller than with the heading above it, so more page groups show without scrolling. While the picture is hidden (since 0.24) the heading is gone as well, so the keys use that height too.",
            "Needs the AMS Deck Mate app at 0.6 on the Mac. With an older Mac the picture stays hidden. Not yet tried on a real iPhone held on its side."
        ]),
        Section(id: "several", title: "Several pages at once", part: "keys", lines: [
            "New in 0.19: \"Several pages at once\", for using the iPhone or iPad without the Stream Deck box. Switch it on in Settings, Showing (off at first).",
            "With it on, the iPhone shows 2 pages side by side (10 keys across by 3 down, 30 keys) and the iPad shows 4 pages (two above and two below, 60 keys). Each page has its own small name above it.",
            "The first page is the page you are on, as before. The others follow in the page group's order and it goes round: after the last page it continues with the first, so you see as many pages as fit (2 or 4), or fewer when the page group has fewer top pages. In a folder, the folder shows first and its own top page is not repeated. A page without a name shows as \"Page 2\", \"Page 3\" and so on. New in 0.19.1: folders fill the empty spots. When the page group has fewer top pages than the iPhone (2) or iPad (4) shows, its folders fill the rest, in their order in Set up keys. Example: \"AMS Deck\" has only the page Home plus folders, so the iPad shows Home, Apps, Tutorials and Raycast (4 pages, 60 keys; before 0.19.1 only Home, 15 keys). A Back key on a folder shown this way goes to the page the folder belongs to, and that page becomes the first one.",
            "New in 0.19.1: bigger keys. The pages are arranged in whichever way gives the biggest keys: 2 pages on an iPad sit one above the other, and 3 pages may sit two above one. Before: always side by side (2 pages) or two above and two below (4 pages). On an iPad, \"Notion\" (2 pages) has keys of about 110 points instead of about 75, about half as big again.",
            "A tap on any key does what that key does, as if you had pressed it on its own page. A key that opens a folder or another page moves the view: that page becomes the first one.",
            "A swipe sideways moves one page on, as before. The favourites row and the navigation picture still show when they are on. The Stream Deck box, if it is plugged in, keeps showing just the first page.",
            "It needs the Mac at 0.17. With an older Mac the switch says so (its note says it needs the Mac at 0.17) and the phone shows one page as before. Folders filling the empty spots and the bigger keys need the Mac at 0.17.1; with Mac 0.17 the pages show as in 0.19.",
            "Not yet tried on a real iPhone or iPad."
        ]),
        Section(id: "longpress", title: "Long press", part: "keys", lines: [
            "A key with a small white dot in its top right corner has a second action. Hold the key for half a second and the second action runs. You feel a stronger buzz.",
            "A long press on a key without a dot does the usual thing, as if you had tapped.",
            "You set the second action on the Mac, in Set up keys, under \"What it does\", in the picker \"Long press\".",
            "A broken long-press action shows the red corner, and the Mac says \"Long press: <reason>\".",
            "Needs the AMS Deck Mate app at 0.5 on the Mac. Not yet tried on a real iPhone or iPad."
        ]),
        Section(id: "favourites", title: "The favourites row", part: "keys", lines: [
            "5 keys that stay in place on every page and in every page group. They show as a row under the 15 keys. Since 0.21 they are round, in the row and everywhere else, so a round key always means a favourite and a rounded square is one of the 15 keys. They work as before: tap, or hold for the long press.",
            "New in 0.21, only with the device on its side and the navigation picture hidden: the row moves into a column of five round keys on the left, right next to the purple \"Pages\" tab, in the same order as the row (the first favourite at the top). The 15 keys then use three rows only and grow: on an iPad from about 179 to about 220 points, on an iPhone from about 68 to about 96 points. The favourites in the column are smaller than the 15 keys (about 128 points on an iPad, about 54 on an iPhone; five of them are as tall as three keys). Show the picture again and the favourites go back to the row under the keys. The move is animated, together with the picture.",
            "You set them on the Mac, in Set up keys, in the row \"Favourites\" under the 15 keys. A favourite can be anything except a folder or Back, and it can have a long press too.",
            "A favourite that moves to another page or page group moves your own place when this device has its own keys, and otherwise the Mac's place.",
            "The row only shows when at least one favourite is set. In Settings, the switch \"Favourites row\" (on at first) turns it off.",
            "Needs the AMS Deck Mate app at 0.5 on the Mac."
        ]),
        Section(id: "macnow", title: "The Mac at a glance and the music button", part: "settings", lines: [
            "Mac at a glance: one small pill at the bottom middle of the screen, with the name of the app in front on the Mac, for example \"Safari\". Since 0.15 the words and the pill are the same green as the settings gear (before, blue words on a light blue pill). It no longer shows the Mac's battery (0.13 had a second, green pill for it; it was removed in 0.14). With the iPhone held on its side (since 0.16), the pill sits at the top of the narrow column to the right of the keys, in line with the top keys, turned on its side so it reads from top to bottom. In 0.13 to 0.15 it sat in the left panel, above the buttons.",
            "Music button: a small green music mark with its word under it (since 0.21 no circle behind it). Held upright it is at the top right, beside the settings button. Since 0.13, with the iPad held on its side, it is at the bottom left, under the navigation picture. Since 0.16, with the iPhone held on its side, it is in the narrow column to the right of the keys, at the bottom, between the lock above and the gear below; in 0.13 to 0.15 it was at the bottom of the left panel. Since 0.21 it is only the green music mark, with no background at all, like the lock and the gear beside it (0.19.1 to 0.20: a light green circle behind it); while something is playing, the word under it says \"Playing\" instead of \"Music\". Tap it and a small plate opens with the song and artist playing on the Mac (Spotify and Apple Music), buttons for play or pause, next, quieter and louder, and the Mac's volume in percent. The plate has a solid background. Tap outside the plate to close it. One tap on quieter or louder moves the volume by 6 points.",
            "Until the next change of song or pause after the Mac app has started, the plate says \"Nothing playing yet\". The Mac hears about the song from the player only when something changes.",
            "Play or pause and next use the same one-time Accessibility permission on the Mac as music keys. Volume needs none. Play or pause is not yet tried.",
            "The Mac looks at its battery and volume every 5 seconds, but only while such a device is connected.",
            "Both have a switch in Settings (\"Mac at a glance\" and \"Music button\", on at first). Both need the AMS Deck Mate app at 0.5 on the Mac."
        ]),
        Section(id: "dark", title: "Dark while the Mac sleeps", part: "settings", lines: [
            "New in 0.9. When the Mac's screen goes to sleep, or the Mac sleeps, this iPhone or iPad goes black with a small moon drawing and the words \"Mac asleep\".",
            "While it is dark the screen is allowed to lock itself like normal. It no longer keeps itself awake.",
            "New in 0.18: after a tap that shows the keys, the screen stays awake until 2 minutes after your last touch; then the dark screen and the normal auto-lock come back. If the Mac sleeps and its line is then lost for 10 minutes (switched off), the screen stops saying \"Mac asleep\" and says it is looking for the Mac.",
            "When the Mac wakes, the screen brightens by itself. One tap on it shows the keys again.",
            "A switch \"Dark while the Mac sleeps\" in Settings, under Showing (on at first), turns it off. Then nothing changes: the keys stay and the screen stays awake as before.",
            "It needs the AMS Deck Mate app at 0.7 on the Mac. With an older Mac nothing changes.",
            "New in 0.11: when the Mac wakes from sleep, a short note \"Mac is back\" shows on the key screen. It uses the same switch as the \"what ran\" note, so hiding that note hides this one too. It works with a Mac at 0.7 or later."
        ]),
        Section(id: "newkeys", title: "Recent app and Ask AI keys", part: "keys", lines: [
            "Two new kinds of key, set up on the Mac (0.7), show and work here too. The Mac draws them.",
            "\"Recent app\" shows the icon and name of an app you used before the one in front on the Mac: 1st, 2nd or 3rd. The picture changes by itself as you switch apps on the Mac. Tap it and the Mac brings that app forward. Until enough apps have been used it shows a clock and \"Recent\".",
            "\"Ask AI\" opens Raycast AI Chat on the Mac with the text you last copied there already filled in. Not yet tried against the real Raycast.",
            "Since Mac 0.8, two more kinds of key show and work here too, drawn by the Mac.",
            "\"Last copied text\" (1st, 2nd or 3rd) shows the first words of a text you copied on the Mac, up to 18 letters. Those first words are visible on the key, so take care when others can see your screen. Tap it and the Mac pastes that text where its cursor is.",
            "\"Recent file\" (1st, 2nd or 3rd) shows the name of a file you opened lately on the Mac. Tap it and the Mac opens the file.",
            "Since Mac 0.9, \"Last copied text\" has a fourth choice, \"A list to pick from\". The key shows a clipboard drawing and \"Copied texts\". Tap it and a small list of your earlier copied texts opens on the Mac, at its mouse pointer. You choose there with the Mac's mouse, not on this screen."
        ]),
        Section(id: "raycast", title: "Raycast keys", part: "raycast", lines: [
            "A key that runs a Raycast command works from the iPhone like any other key. The command runs on the Mac.",
            "You set up keys on the Mac, in \"Set up keys\". The iPhone shows what you set up there."
        ]),
        Section(id: "signs", title: "Signs in this app", part: "settings", lines: [
            "Marks and colours in this app, each with one meaning. If you meet a mark that is not here, it is a bug.",
            "Coloured dot at the top (the link to the Mac), with the word \"Mac\" under it: green means connected to your Mac; amber means looking for the Mac or waiting for it to allow this iPhone or iPad; red means the Mac said no. Tap it for the words. New in 0.24: on an iPhone held on its side with the navigation picture hidden, it sits at the top of the narrow column beside the keys.",
            "Small lock (\"Private\"): the line to the Mac is private, so nobody else on the Wi-Fi can read your keys or press them. Upright it sits beside the link dot; on its side it sits in the column beside the keys. Tap it for the words.",
            "Music mark (\"Music\" under it): opens the plate with what is playing on the Mac. Since 0.21 it is only the green music mark, with no background at all, like the lock and the gear beside it (0.19.1 to 0.20: a light green circle behind it); while something is playing, the word under it says \"Playing\" instead of \"Music\". Before: it was filled green while something played, and a light green ring otherwise.",
            "Round gear (\"Settings\"): opens Settings. Everyone knows the gear; it now also has a tiny word under it.",
            "Small white dot in a key's top right corner: the key has a long-press action. Hold it for half a second.",
            "Small red corner on a key: that key is broken on the Mac. The note at the bottom says why.",
            "Red note with a warning drawing at the bottom: a key did not work. It always shows.",
            "Amber line with a warning drawing under the heading, such as \"Battery 18 % – plug in\": this iPhone or iPad is at 20 % or less and not charging.",
            "Small dots under the keys: one for each page. The filled one is the page you are on. None inside a folder or when there is one page.",
            "Blue frame in the navigation picture: the page showing now. Purple ribbon over a page group's pages: the page group you are in; grey-blue: the others.",
            "Thin purple tab at the left edge with the word \"Pages\" and a small grip mark (since 0.20): the navigation picture is hidden. Tap it, or pull it to the right, to show the picture again. Its purple is the same as the ribbon of the page group you are in. Since 0.21 it is exactly as tall as the keys, on the iPhone too. Since 0.22 the word is bigger and the tab wider; the picture also hides by itself after a quiet minute, and this tab brings it back. New in 0.23: when the picture has just hidden itself, the tab nudges twice to the right and back and its purple turns lighter for about a second and a half, to show where the picture went (a swipe by hand does not do this); the quiet time can be 30 seconds, 1 minute or 2 minutes. New in 0.24: hold the tab for about half a second and a small list of your page groups opens; tap one to jump to its first page without bringing the picture back (the group you are in says \"(here)\"). A light buzz tells you when the picture snaps away or comes back by your own swipe, pull or tap (it follows the switch \"Tap buzz\"). New in 0.25: on an iPhone held on its side the tab also shows the name of your page group under the word \"Pages\", small and in lighter white (cut short with \"…\" when long); an iPad's tab shows only \"Pages\". New in 0.26: swipe up or down on the tab for the next or previous page group (up = next); it follows the switch \"Swipe up or down changes page group\" and gives a soft buzz.",
            "Small purple words \"Hold for groups\" under the bottom of the \"Pages\" tab (since 0.25): a hint that holding the tab opens the list of your page groups. It shows for 8 seconds each time the tab appears, the first 3 times only, and stops for good once you have used the list. New in 0.26: by day it is the tab's purple, on a dark background a lighter purple.",
            "Round key: a favourite (since 0.21). One of the 5 favourites, in the row under the keys or, with the navigation picture hidden and the device on its side, in the column beside the \"Pages\" tab. Tap it to run it; hold it for the long press. A rounded square key is one of the 15 keys.",
            "Small name above each page when \"Several pages at once\" is on: the name of that page. The first page is the one you are on.",
            "Green pill at the bottom: the name of the app in front on the Mac.",
            "Black screen with a small moon and \"Mac asleep\": the Mac's screen is asleep. One tap shows the keys.",
            "Large dimmed clock with the date: the resting clock. One tap brings the keys back."
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
            "After 20 seconds a card appears: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. The button \"Open Settings\" takes you to the iPhone's Settings. The close (x) button hides the card.",
            "New in 0.17: a tap on a key while the app is looking for the Mac now says \"Looking for your Mac\". Before, the tap just vanished."
        ]),
        Section(id: "deadline", title: "When the line goes quiet", part: "settings", lines: [
            "New in 0.17, with a Mac at 0.15. The app asks the Mac \"are you there?\" every 5 seconds, and the Mac answers.",
            "When nothing at all comes back for 12 seconds, the app stops saying Connected and looks for the Mac again. Before, after a change of Wi-Fi or when the Mac dropped off the Wi-Fi, it could say Connected for ever while taps went nowhere.",
            "A sleeping Mac is not given up on. The dark \"Mac asleep\" screen stays as it was.",
            "Only the keys that look different travel now. With a running timer, only that one key's picture arrives each second, instead of all fifteen. That saves battery and Wi-Fi.",
            "With an older Mac app, everything works as before."
        ])
    ]

    static let releases: [Release] = [
        Release(id: "0.26", date: "20 Nov 2026", new: [
            "Two small new things on the purple \"Pages\" tab: a swipe changes the page group, and the hint is brighter at night. Before: iPhone and iPad app 0.25 (build 31). Now: 0.26 (build 32). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "Swipe up or down on the \"Pages\" tab, while the navigation picture is hidden, to go to the next or the previous page group: up = the next page group, down = the one before. It is the same as swiping up or down on the keys. It follows the same switch in Settings, Touch, \"Swipe up or down changes page group\": switched off there, it is off on the tab too. A soft buzz goes with it (switch \"Tap buzz\"). On an iPhone the group's name on the tab changes with it. Nothing else on the tab changed: a plain tap still brings the picture back, holding it still opens the list of page groups, and a swipe to the left or right on it still pulls the picture out.",
            "The hint \"Hold for groups\" is brighter at night. Before: the same purple by day and by night, which was dim on the dark iPad screen. Now: by day it stays the tab's purple; with a dark background it is a lighter purple, so it reads well.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The \"Pages\" tab now answers a swipe up or down (see above). Everything else is as in 0.25.",
            "How it works has changed lines in \"The navigation picture\", and \"Signs in this app\" has changed lines for the \"Pages\" tab and for the hint \"Hold for groups\". The app is now 0.26 (build 32)."
        ], fixed: [
            "A swipe up or down that ended on the tall \"Pages\" tab counted as a tap and brought the picture back (0.20 to 0.25). Now only a real tap does; a swipe up or down changes the page group."
        ]),
        Release(id: "0.25", date: "20 Nov 2026", new: [
            "Two small new things on the purple \"Pages\" tab: it shows the name of your page group, and a short hint tells you about the list. Before: iPhone and iPad app 0.24 (build 30). Now: 0.25 (build 31). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "The name of your page group on the tab. Before: with the picture hidden on an iPhone held on its side, the heading line had stepped aside (0.24), so nothing said which page group you were in. Now the \"Pages\" tab also shows the group's name under the word \"Pages\", running up the tab like it, in small type and in a lighter white. A long name is shortened with \"…\". An iPad keeps its heading, so its tab shows only \"Pages\".",
            "A small hint, \"Hold for groups\", in purple under the bottom of the \"Pages\" tab. It tells you that holding the tab opens the list of page groups (new in 0.24). It shows for 8 seconds each time the tab appears (when the picture is hidden by a swipe or by itself), but only the first 3 times, and never again once you have used the list (held the tab and picked a page group).",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The \"Pages\" tab on an iPhone held on its side now carries the page group's name (see above). Everything else is as in 0.24.",
            "How it works has changed lines in \"The navigation picture\", and \"Signs in this app\" has a changed line for the \"Pages\" tab and a new line for the hint \"Hold for groups\". The app is now 0.25 (build 31)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.24", date: "20 Nov 2026", new: [
            "Three new things: bigger keys on the iPhone when the picture is hidden, a quick page group list on the \"Pages\" tab, and a soft tap feel. Before: iPhone and iPad app 0.23 (build 29). Now: 0.24 (build 30). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "Bigger keys on an iPhone held on its side, with the picture hidden. Before: the heading line over the keys (page group · page, for example \"Default · Page 1\", with the coloured link dot) took room, and the keys were 96 points tall. Now the heading steps aside and the keys are 106 points tall. The link dot moves to the top of the narrow column beside the keys (with the Mac's app, lock, music and Settings) and a tap on it still says in words what its colour means. The page dots under the keys still show which page you are on, and the page group's name shows again when the picture comes back. An iPad is unchanged: the heading stays.",
            "Hold the \"Pages\" tab for about half a second and a small list of your page groups opens. Tap one to jump straight to its first page, without opening the picture. The group you are in says \"(here)\" after its name. A plain tap on the tab still brings the picture back.",
            "A soft tap feel, a light buzz, when the picture snaps away or comes back by your own swipe, pull or tap on the tab. It follows the switch \"Tap buzz\" in Settings, Touch. No buzz when the picture hides by itself.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "On an iPhone held on its side with the picture hidden, the heading and the link dot moved (see above). Everything else is as in 0.23.",
            "How it works has changed lines in \"The navigation picture\" and \"Signs in this app\" (the link dot and the \"Pages\" tab). The app is now 0.24 (build 30)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.23", date: "20 Nov 2026", new: [
            "Two new things: the \"Pages\" tab nudges when the picture hides by itself, and you can pick how long the quiet time is. Before: iPhone and iPad app 0.22 (build 28). Now: 0.23 (build 29). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "The tab shows where the picture went. When the navigation picture hides by itself, the purple \"Pages\" tab nudges twice: it moves a little to the right and back, two times, and its purple turns lighter for a moment. It takes about a second and a half in all. No glow, no sound. When you swipe the picture away yourself, the tab does not nudge.",
            "You pick the quiet time. In Settings, Showing, under the switch, a new choice \"After\": 30 seconds, 1 minute or 2 minutes. 1 minute is the starting choice, as it was in 0.22. The choice shows only while the switch is on.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The switch is now called \"Hide the picture by itself\". Before: \"Hide the picture after a minute\", which no longer fits now that the time can be chosen. It still starts on.",
            "Everything else is as in 0.22: any touch anywhere starts the quiet time again, and the \"Pages\" tab brings the picture back.",
            "How it works has changed lines in \"The navigation picture\" and \"Settings\", and \"Signs in this app\" has a changed line for the \"Pages\" tab. The app is now 0.23 (build 29)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.22", date: "20 Nov 2026", new: [
            "Two new things: a bigger word on the \"Pages\" tab, and the navigation picture hides by itself after a quiet minute. Before: iPhone and iPad app 0.21 (build 27). Now: 0.22 (build 28). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "The navigation picture hides by itself. When the device is on its side and nothing on the screen has been touched for one minute, the picture slides away by itself, with the same spring as a swipe. The favourites move into the column and the keys grow, exactly as when you swipe it away. Any touch anywhere on the screen starts the minute again. Tap or pull the \"Pages\" tab to bring the picture back; it hides again after the next quiet minute.",
            "A new switch in Settings, Showing, right under \"Navigation picture\": \"Hide the picture after a minute\" (on at first). Switch it off and the picture stays until you swipe it away yourself.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The word \"Pages\" on the purple tab is bigger and easier to read. Before: 12-point small type on a tab 22 points wide. Now: 15-point bold type on a tab 28 points wide. The keys keep their sizes, give or take a point or two.",
            "Hiding by itself turns the same \"Navigation picture\" switch off as a swipe does. So after the picture has hidden itself, that switch shows off, and the picture stays hidden after the app is closed until you bring it back.",
            "How it works has changed lines in \"The navigation picture\" and \"Settings\", and \"Signs in this app\" has a changed line for the \"Pages\" tab. The app is now 0.22 (build 28)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.21", date: "20 Nov 2026", new: [
            "One new thing: the favourites move next to the \"Pages\" tab when the navigation picture is hidden. Before: iPhone and iPad app 0.20 (build 26). Now: 0.21 (build 27). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "When the navigation picture is hidden on a device held on its side, the favourites row moves into a column of five keys on the left, right next to the purple \"Pages\" tab, from top to bottom in the same order as the row (the first favourite at the top). The 15 keys then use three rows only and grow: on an iPad from about 179 to about 220 points, on an iPhone from about 68 to about 96 points (sample keys, favourites row on). Show the picture again and the favourites go back to the row under the keys. The change is animated: it springs together with the picture.",
            "In the column the favourites are smaller than the 15 keys: about 128 points on an iPad and about 54 on an iPhone. Five of them are as tall as three keys.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "Favourites are round now, everywhere (in the row and in the column). Before: they were rounded squares like the 15 keys. Now: a round key always means a favourite and a rounded square is one of the 15 keys. They work as before: tap, or hold for the long press.",
            "The \"Pages\" tab is exactly as tall as the keys, its top and bottom in line with them, on the iPhone too. Before: on the iPhone it ran the whole height of the left side, from the top of the screen.",
            "The music button has no fill any more: only the green music mark, like the lock and the gear beside it. Before: a light green circle behind it.",
            "The gear (Settings) is no longer bold: it is drawn at the same size as the lock and the music mark (22 points on an iPad, 19 on an iPhone; before: 30 and 24), so all three have the same thin line.",
            "iPhone only: the tab sits about 12 points closer to the screen's left edge, and the favourites column and the keys sit right next to it. Before: the keys stood in the middle with a wide gap after the tab.",
            "How it works has changed lines in \"The favourites row\", \"The navigation picture\" and \"Settings\", and \"Signs in this app\" has a changed line for the \"Pages\" tab and a new line \"Round key: a favourite\". The app is now 0.21 (build 27)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.20", date: "20 Nov 2026", new: [
            "One new thing: hide and show the navigation picture with a swipe. Before: iPhone and iPad app 0.19.1 (build 25). Now: 0.20 (build 26). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed.",
            "Hide it: on an iPad or iPhone held on its side, put a finger on the navigation picture (the page map on the left) and swipe to the left. The picture follows your finger and slides off to the left, and the keys grow into the room it leaves, live, as you drag. Let go and it springs away by itself. Let go early (less than a third of the way, and no quick flick) and it springs back open.",
            "Show it again: when the picture is hidden, a thin purple tab stands at the left edge, as tall as the keys, with the word \"Pages\" running up it and a small grip mark. Tap the tab, or pull it to the right: the picture follows your finger out again, the keys shrink back, and it springs into place.",
            "Bigger keys while it is hidden, where there is room: on an iPad held on its side without the favourites row, the keys grow from about 210 to about 246 points (about a sixth bigger), live as you swipe. With the favourites row on (about 178 points), and on an iPhone (about 68 points with the favourites row, 96 without), the keys are already as tall as the screen allows, so they keep their size. Before: the picture could only be hidden with the switch in Settings.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The switch Settings, Showing, \"Navigation picture\" and the swipe are now the same thing. Before: only the switch could hide the picture. Now: the swipe turns that switch on or off, so it is remembered after the app is closed, and the switch shows the same state.",
            "Swipes on the keys still change pages, as before. Only a swipe on the picture or on the tab hides or shows it.",
            "On the iPhone, when the picture is hidden, the battery warning line and the note on what a key did move over the keys, at the top in the middle (they normally sit above the picture).",
            "How it works has changed lines in \"The navigation picture\" and \"Settings\", and \"Signs in this app\" has a new line for the \"Pages\" tab. The app is now 0.20 (build 26)."
        ], fixed: [
            "Nothing was broken in this round."
        ]),
        Release(id: "0.19.1", date: "20 Nov 2026", new: [
            "Small follow-up round, from trying 0.19 on the iPad. Before: iPhone and iPad app 0.19 (build 24). Now: 0.19.1 (build 25). The folders part needs Mac 0.17.1; everything else works with Mac 0.17.",
            "Several pages at once now fills empty spots with folders. Before: \"Notion\" (2 pages) showed just 2 small pages at the bottom of the iPad, and \"AMS Deck\" (only the page Home plus folders) showed 1 page of 15 keys. Now: when the page group has fewer top pages than the device shows (2 on an iPhone, 4 on an iPad), its folders fill the rest, in their order in Set up keys. \"AMS Deck\" shows Home, Apps, Tutorials and Raycast on the iPad: 4 pages, 60 keys instead of 15.",
            "A Back key on a folder shown this way goes to the page the folder belongs to, and that page then becomes the first page.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "Bigger keys. Before: the pages always sat side by side (2 pages) or two above and two below (4 pages), so 2 pages on an iPad had small keys and a large empty space. Now: the pages are arranged in whichever way gives the biggest keys. 2 pages on an iPad sit one above the other, and 3 pages may sit two above one. For \"Notion\" on an iPad the keys grow from about 75 points to about 110 points, about half as big again.",
            "The round Music button is no longer filled green while something plays. Before: filled green while music played, a light green ring otherwise. Now: always the light background with a green note; while something plays, the word under it says \"Playing\" instead of \"Music\".",
            "How it works has changed lines in \"Several pages at once\" and in \"Signs in this app\". The app is now 0.19.1 (build 25)."
        ], fixed: [
            "The \"Notion\" page group showed only 2 small pages at the bottom of the iPad. It now shows its folders too, and the keys are bigger."
        ]),
        Release(id: "0.19", date: "20 Nov 2026", new: [
            "Round of one new way to look at the keys, and a mark check. Before: iPhone and iPad app 0.18 (build 23). Now: 0.19 (build 24). It needs Mac 0.17 for the new part; everything else works with Mac 0.16 and 0.15.",
            "Several pages at once, for using the iPhone or iPad without the Stream Deck box. Before: one page of 15 keys. Now: a new switch in Settings, Showing, \"Several pages at once\" (off at first). With it on, the iPhone shows 2 pages side by side (10 keys across by 3 down, 30 keys) and the iPad 4 pages (two above and two below, 60 keys). Each page has its own small name above it.",
            "Which pages show: the first page is the page you are on, as before. The others follow in the page group's order and it goes round: after the last page it continues with the first, so you see as many pages as fit (2 or 4), or fewer when the page group has fewer top pages. In a folder, the folder shows first and its own top page is not repeated. A page without a name shows as \"Page 2\", \"Page 3\" and so on. Folders only fill empty spots (since 0.17.1, see below).",
            "Tapping: a tap on any key does what that key does, as if you had pressed it on its own page. A key that opens a folder or another page moves the view, so that page becomes the first one. A swipe sideways moves one page on, as before.",
            "The favourites row and the navigation picture still show when they are on. The Stream Deck box, if it is plugged in, keeps showing just the first page.",
            "Needs the Mac at 0.17. With an older Mac the switch says so, and the phone shows one page as before.",
            "New in How it works: a part \"Several pages at once\" and a part \"Signs in this app\".",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "The small lock, music and gear buttons now have a tiny word under them: \"Private\", \"Music\" and \"Settings\". Before: pictures only.",
            "The coloured link dot to the Mac now has the word \"Mac\" under it. Before: a dot alone. A tap still explains its colours.",
            "How it works is updated for these changes. The app is now 0.19 (build 24)."
        ], fixed: [
            "Mark check: three round buttons that were only pictures (lock, music, gear) now say what they are.",
            "Mark check: the link dot was a colour with no word. Now it has words."
        ]),
        Release(id: "0.18", date: "18 Nov 2026", new: [
            "Round of calm, safety and tidiness. Before: iPhone and iPad app 0.17 (build 22). Now: 0.18 (build 23). It works with Mac 0.16, and it also works with Mac 0.15.",
            "A note about a key that did not work always shows. Before: with the switch \"The note on what a key did\" off, you saw nothing, also when a key failed. Now: a small note shows anyway (above the keys on an iPad; over the top of the left panel on an iPhone held on its side). A new line under the switch says: \"A key that did not work always shows its note, also when this is off.\"",
            "The screen stays awake while you look at the keys of a sleeping Mac. Before: nothing kept it awake there. Now: a tap that shows the keys while the Mac sleeps keeps the screen awake until 2 minutes after your last touch. Then the dark screen and the normal auto-lock come back.",
            "\"Looking for your Mac…\" after a long silence. Before: when the line was lost while the screen said \"Mac asleep\" and no line came back, it kept saying \"Mac asleep\". Now: after 10 minutes without a line it says \"Looking for your Mac…\".",
            "Waiting for Allow is easier. Before: the card only waited. Now: after 30 seconds it adds \"Nothing yet? Wake your Mac and look for the window “… wants to use your keys”.\" and a full-colour button \"Ask again\".",
            "Settings sorted. Before: the Favourites row, the Music button, Mac at a glance and the navigation picture were in the Keys card. Now: they are in the Showing card. The long-press note is now in the Touch card. \"Swipe up or down changes page group\" is the new name (before: \"profile\"). The Music button's note on an iPad says: \"A small round button at the bottom left. Tap it for what is playing on the Mac (Spotify or Music), with play, next and volume.\" On an iPhone held on its side it says \"in the column beside the keys\" instead of \"at the bottom left\".",
            "The resting clock also dims the screen. Before: only the keys faded away. Now: while the resting clock shows, the screen goes to a quarter of the brightness you had (never below 5 %). A tap, the end of the clock, or leaving the app brings the brightness back. The keys are not drawn while it rests.",
            "Looking for the Mac is gentler. Before: a try every second, for ever. Now: after a failed try it waits 1, 2, 4, 8, 15 and then 30 seconds between tries. It is back to 1 second after a line that worked, when you come back to the app, with \"Ask again\", with \"Forget this Mac\", and when the Mac's offer appears again.",
            "The secret that allows your Mac is safer. Before: it was kept with the app's settings. Now: it is kept in the iPhone's or iPad's Keychain (its safe for passwords), only on this device and not copied elsewhere. It moves there by itself and you are not asked to allow again. \"Forget this Mac\" removes it.",
            "Rest sooner in the evening: Settings › Clock has a new switch \"Rest sooner in the evening\" (off at first), with From 21:30 and To 07:00 (the time may pass midnight). Inside those hours the resting clock comes after 1 minute without a touch, also when \"Resting clock\" says Never.",
            "The sample green tile is darker, as on the Mac, so white words read well. There is no amber tile on the phone.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "Settings are sorted anew: Showing holds the Favourites row, the Music button, Mac at a glance and the navigation picture. Before: they sat in Keys.",
            "The resting clock dims the screen too, and the search for the Mac backs off (see above).",
            "The app 0.17 keeps working with Mac 0.16, and the app 0.18 works with Mac 0.15.",
            "How it works is updated for these changes. The app is now 0.18 (build 23)."
        ], fixed: [
            "A key that failed could go unseen when the switch for the note was off. Now its note always shows.",
            "A screen that kept saying \"Mac asleep\" after a lost line now says \"Looking for your Mac…\" after 10 minutes.",
            "The search for the Mac every second, for ever, is now slower step by step."
        ]),
        Release(id: "0.17", date: "18 Nov 2026", new: [
            "A dead line now shows as dead. With a Mac at 0.15, the app asks the Mac \"are you there?\" every 5 seconds. When nothing at all comes back for 12 seconds, it stops saying Connected and looks for the Mac again. Before: after a change of Wi-Fi, or when the Mac dropped off the Wi-Fi, the app could say Connected for ever while taps went nowhere. Now: within 12 seconds it says it is looking again.",
            "A sleeping Mac is not given up on. The dark \"Mac asleep\" screen stays exactly as it was.",
            "A tap while the app is looking for the Mac now says \"Looking for your Mac\". Before: the tap vanished and nothing told you why.",
            "Only changed keys travel. With a running timer, stopwatch or focus round, the picture of that one key arrives each second, instead of all fifteen keys (about 300 KB for all fifteen, each second). That saves battery and Wi-Fi. This needs AMS Deck Mate 0.15 on the Mac.",
            "Not yet tried: the new link check on a real iPhone and iPad with the real box, which is at home until January 2027."
        ], changed: [
            "The line \"Update AMS Deck Mate on your Mac\" now only comes up when the Mac was reached and did not answer two tries in a row. Before: two failed tries of any kind, for example a sleeping Mac or a Wi-Fi blip, brought it up wrongly. \"Ask again\", and coming back to the app, start the count afresh.",
            "No screen was moved or redesigned. Keys, buttons, colours and places are exactly as in 0.16.",
            "With a Mac app older than 0.15, everything works as before: the new link check and the changed-keys-only sending need AMS Deck Mate 0.15 on the Mac. Mac 0.15 also works with the app at 0.16.",
            "How it works has a new part, \"When the line goes quiet\", and new lines in \"Allowing the iPhone\" and \"When it says Looking for your Mac\". The app is now 0.17 (build 22)."
        ], fixed: [
            "Connected for ever: a line that had died could still say Connected. Now it is noticed after 12 seconds.",
            "A tap that vanished while looking for the Mac now says \"Looking for your Mac\".",
            "\"Update AMS Deck Mate on your Mac\" no longer shows up wrongly after a sleeping Mac or a Wi-Fi blip."
        ]),
        Release(id: "0.16", date: "16 Nov 2026", new: [
            "Not yet tried: the new look of the navigation picture and the new row of buttons on a real iPad and a real iPhone held on its side."
        ], changed: [
            "The navigation picture (the plate on the left with every page group and its pages as small pictures) has a new look for the page group names. Before, each page group's name was a plain small word above its pages: purple for the page group you are in, grey for the others. Now each page group sits in its own framed panel. The name is white bold words on a full-colour ribbon that stretches across both small pages: purple for the page group you are in, grey-blue for the others. The panel behind the pages is softly tinted in the same colour.",
            "The blue frame around the page that is showing is unchanged. So are the small pictures, the names under them, the scrolling and the tap that goes to a page.",
            "On an iPhone held on its side, the buttons moved. Before, the pill with the app in front on the Mac, Settings (the gear), Music and the lock sat in the left panel, under the navigation picture, which cut the picture short. Now these four sit in one narrow column to the right of the keys, in the empty strip by the screen's edge. At the top, in line with the top keys, is the pill with the app in front on the Mac, turned on its side so it reads from top to bottom. At the bottom, in line with the bottom keys, one above the other: the lock, then Music, then Settings (the gear) lowest, in the corner. The keys keep exactly their size and place. If the iPhone is turned the other way, so that the camera cut-out is on the right, the column moves to the free strip at the left edge of the screen, left of the navigation picture, so nothing hides behind the cut-out.",
            "Because the buttons and the heading left the left panel, which now holds only the navigation picture, the navigation picture on an iPhone held on its side starts at the very top and uses the whole height of the left panel. Before, it was cut short by the pill and the three buttons under it, and the heading stood above it. Now it is about 54 points taller than with the heading above it, so even more page groups show without scrolling. A low battery line or the note on what a key did, when shown, still appear above the picture.",
            "On an iPhone held on its side, the heading (the line that says where you are, for example \"AMS Deck · Home\": page group · page) moved. Before, it stood top left, in the left panel above the navigation picture, in up to two lines, with the connection dot in front of it. Now it stands in one line in the middle above the keys, with the connection dot right in front of it. It uses the free room that was already there above the keys, so the keys keep their size and place. The iPad is unchanged.",
            "An iPad and an iPhone held upright are unchanged: the iPad keeps its buttons where 0.15 had them, and upright the gear and music stay at the top right.",
            "How it works is updated for the new names on the navigation picture and the new places of the app pill, lock, music and gear (a narrow column to the right of the keys) and the new place of the heading (one line above the keys) on an iPhone on its side. The Mac app is unchanged at 0.9.1."
        ], fixed: []),
        Release(id: "0.15", date: "16 Nov 2026", new: [], changed: [
            "The pill with the app in front on the Mac (Mac at a glance) is green now. Before, the words were blue on a light blue pill. Now the words and the pill are the same green as the settings gear.",
            "The connection dot at the top left is the same green as the settings gear when connected. Before, it had its own, brighter green. Amber (looking or waiting) and red (the Mac said no) are unchanged.",
            "The small lock for the private line is the same green as the gear and a little larger. Before, it was a very small lock right beside the connection dot at the top left. With the iPad or iPhone held on its side it moves to the bottom left, in the line with settings and music (gear, music, lock). A tap on it shows a small card: \"Private line: nobody else on the Wi-Fi can read your keys or press them.\" Held upright it stays beside the dot (there the gear and music are top right), only larger and in the new green. A tap on the dot still shows the connection card with the same sentence.",
            "Nothing else moved on the key screen. The Mac app is unchanged at 0.9."
        ], fixed: []),
        Release(id: "0.14", date: "16 Nov 2026", new: [], changed: [
            "Mac at a glance no longer shows the Mac's battery. Before (0.13), there were two small pills at the bottom middle: a green one with a battery drawing and the Mac's battery, for example \"95 %\", and a blue one with the app in front on the Mac. Now there is only the blue pill with the app in front, for example \"Claude\".",
            "Nothing else moved: the navigation picture, the music and settings buttons and the heading are exactly as in 0.13. The switch \"Mac at a glance\" in Settings, Showing, works as before. The low battery warning for the iPhone or iPad itself stays.",
            "How it works is updated for the one blue pill. The Mac app is unchanged at 0.9."
        ], fixed: []),
        Release(id: "0.13", date: "16 Nov 2026", new: [
            "Mac at a glance now shows as two small pills at the bottom middle of the screen. A green pill has a small battery drawing and the Mac's battery, for example \"95 %\" or \"95 % charging\". A blue pill has the name of the app in front on the Mac, for example \"Claude\". A Mac without a battery shows only the blue app pill.",
            "Not yet tried: the new places on a real iPad and a real iPhone held on its side."
        ], changed: [
            "The navigation picture on an iPad held on its side is now as tall as the keys. Before, it started right under the top line, higher than the keys, and ran down past the page dots. Now its top edge is in line with the top row of keys and its bottom edge with the bottom row of keys. When there are more pages than fit, it scrolls as before.",
            "The music button and the settings button (the gear) moved when the iPad or iPhone is held on its side. Before, they were at the top right, beside the heading, on every device. Now both are at the bottom left: on the iPad in the bottom-left corner under the navigation picture, on the iPhone at the bottom of its left panel.",
            "Held upright, nothing changed: the music button and the gear stay at the top right.",
            "The two buttons do the same as before. The music button opens the small music plate and the gear opens Settings.",
            "On an iPhone held on its side, the connection dot now sits in the same line as the page group name at the top of the left panel. Before, the dot, the music button and the gear shared one line above the name.",
            "Mac at a glance changed its look. Before, it was one tiny grey line at the bottom middle, for example \"95 % · Claude\". Now it is two small pills, one green for the battery and one blue for the app. On an iPhone held on its side, the pills sit in the left panel, just above the two buttons.",
            "The switch \"Mac at a glance\" in Settings, Showing, works as before and turns both pills off.",
            "How it works has the new places in \"Settings\", \"The navigation picture\", \"The Mac at a glance and the music button\" and the line about the iPhone on its side. The Mac app is unchanged at 0.9."
        ], fixed: []),
        Release(id: "0.12", date: "16 Nov 2026", new: [
            "A small lock drawing beside the connection dot at the top left of the key screen, shown while this device is connected. It tells you the line to the Mac is private (scrambled, as since 0.11).",
            "The connection card (tap the dot) now also says: \"Private line: nobody else on the Wi-Fi can read your keys or press them.\"",
            "Works with the Mac app 0.9: its key \"Last copied text\" has a fourth choice, \"A list to pick from\", which shows here as a clipboard drawing with \"Copied texts\". Tap it and the list opens on the Mac, where you pick with the mouse."
        ], changed: [
            "Nothing changes in how the link to the Mac works.",
            "How it works has new lines in \"Allowing the iPhone\" and \"Recent app and Ask AI keys\". The Mac app is now 0.9 (build 12)."
        ], fixed: []),
        Release(id: "0.11", date: "16 Nov 2026", new: [
            "The link between this iPhone or iPad and the Mac is now private. Every message is scrambled from the first moment. Before, key pictures, taps and the permission code travelled readable on the Wi-Fi, so on a shared Wi-Fi (hotel, café) someone could listen in and press your keys. Now nobody can.",
            "The first time, the Mac asks and shows a 4-digit number, and this device shows the same number. Allow on the Mac only if both numbers are the same. The number comes from both sides, so nobody can sit in between.",
            "After you allow, this device proves who it is every time without sending its secret, and the Mac proves itself the same way.",
            "New short note \"Mac is back\" on the key screen when the Mac wakes from sleep. It is shown with the \"what ran\" note, so the same switch in Settings hides it. It works with a Mac at 0.7 or later.",
            "The keys \"Last copied text\" and \"Recent file\", new in Mac 0.8, show and work here too, drawn by the Mac. \"Last copied text\" shows the first words of the copied text on the key, up to 18 letters, so they are visible to anyone looking at the screen.",
            "Needs the Mac app at 0.8 or later."
        ], changed: [
            "Every iPhone and iPad has to be allowed once more, with one click on the Mac. The old permissions are removed.",
            "The app 0.11 only talks to a Mac at 0.8 or later. With an older Mac it says \"Update AMS Deck Mate on your Mac\". An older iPhone or iPad app with the new Mac sees \"said no\".",
            "How it works has new lines in \"Allowing the iPhone\", \"Dark while the Mac sleeps\" and \"Recent app and Ask AI keys\", and a new line in Settings about the note. The Mac app is now 0.8 (build 11)."
        ], fixed: []),
        Release(id: "0.10.1", date: "16 Nov 2026", new: [
            "Needs the Mac app at 0.7.1 or later. With an older Mac app a swipe still locks, as before."
        ], changed: [
            "Swiping up or down on the keys no longer locks the page group. Before (since 0.5.1), a swipe changed the page group and locked it, so it stayed even when another app came forward on the Mac, and to unlock you had to go to Settings, Keys, Page group, Automatic. Now a swipe shows the next or previous page group but you stay on Automatic, so the next time a different app comes forward on the Mac, the keys follow that app again.",
            "If a page group was locked before the swipe, the swipe also unlocks it.",
            "Picking a page group in Settings, and tapping a page in the navigation picture, still lock it. To unlock, choose \"Automatic\" in Settings (or in the Mac's menu).",
            "With \"My own keys\" nothing changes: a swipe changes your own page group and there is no lock.",
            "How it works has the new swipe rule. The Mac app is now 0.7.1."
        ], fixed: []),
        Release(id: "0.10", date: "16 Nov 2026", new: [
            "New row \"Page group\" in Settings, in the Keys card, on the iPhone and the iPad. It has chips: \"Automatic\" and one chip for each page group. Pick a page group and it is locked: the Mac stays on it until you pick \"Automatic\". A small lock drawing shows on the chip you picked.",
            "The navigation picture now also shows on an iPhone held on its side. Before, only an iPad on its side had it. Every page group and page shows as small pictures on the left, and a tap goes there.",
            "Not yet tried: the new side panel on a real iPhone held on its side."
        ], changed: [
            "An iPhone held on its side (wider than tall) now has much larger keys. Before, the top line, the note on what a key did and the page dots sat above and below the keys, so the keys were about 80 points. Now the top line (the status dot, the page group name, the music button and the settings gear), the note on what a key did and the navigation picture sit in a panel on the left, about 200 points wide on the iPhone and 230 on the iPad. The keys get the whole height on the right and are about 100 to 115 points.",
            "The lock moved to Settings, on the iPhone and the iPad. Before, you tapped the page group name at the top and chose \"Automatic\" or \"Lock one\", and a lock drawing showed beside the name. Now the name at the top is only a heading: nothing happens when you tap it and there is no lock drawing beside it. Use the row \"Page group\" in Settings, Keys.",
            "Swiping up or down on the keys, and tapping a page in the navigation picture, still lock a page group. To unlock, choose \"Automatic\" in Settings (or in the Mac's menu).",
            "With \"My own keys\", the row \"Page group\" lists only the page groups, with no \"Automatic\", as before.",
            "The note under the switch \"Navigation picture\" now says it shows on an iPad or an iPhone held on its side. An iPhone or iPad held upright shows no picture, because there is no room.",
            "The clock above the keys still does not show on an iPhone on its side.",
            "How it works has the new places for all of these. The Mac app is unchanged."
        ], fixed: []),
        Release(id: "0.9", date: "16 Nov 2026", new: [
            "New switch \"Dark while the Mac sleeps\" in Settings, under Showing (on at first). When the Mac's screen goes to sleep, or the Mac sleeps, the iPhone or iPad goes black with a small moon drawing and the words \"Mac asleep\".",
            "While it is dark, the screen is allowed to lock itself like normal. It no longer keeps itself awake.",
            "It brightens by itself when the Mac wakes. One tap shows the keys again.",
            "The new \"Recent app\" and \"Ask AI\" keys of the Mac (0.7) show and work here too. They are drawn by the Mac. \"Recent app\" shows an app you used before the one in front, and a tap brings it forward on the Mac. \"Ask AI\" opens Raycast AI Chat with the text you last copied on the Mac.",
            "Not yet tried: the dark screen on the real iPad, and \"Ask AI\" against the real Raycast."
        ], changed: [
            "Version rule: the dark screen needs the AMS Deck Mate app at 0.7 on the Mac (now 0.7, build 9). With an older Mac nothing changes.",
            "With the switch off, the app works as in 0.8.1.",
            "How it works has two new parts, \"Dark while the Mac sleeps\" and \"Recent app and Ask AI keys\", and Settings has the new line."
        ], fixed: [
            "The music plate (opened by the small music button) and the connection card (opened by the coloured dot) now have a solid background. Before, they were see-through, so the colours of the keys behind shone through and the buttons were hard to read."
        ]),
        Release(id: "0.8.1", date: "16 Nov 2026", new: [], changed: [
            "The top of the key screen is less crowded. Everything below is on the key screen of the iPhone and iPad.",
            "The heading is larger and centred. The place, for example \"OmniFocus · OF Main\", now sits in the middle at the top: bold large title size on the iPad, title size on the iPhone. A tap on it still opens the menu of page groups, and the lock still shows beside it.",
            "The connection is one small coloured dot at the top left, instead of the line \"Connected to …\". Green means connected. Amber means looking, connecting or waiting for the Mac to allow it. Red means the Mac said no. Tap the dot for a small card that says it in words, for example \"Connected to the Mac\", and what the colours mean. The big message card in the middle while there is no Mac is unchanged.",
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
