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
            "Click the small icon to open the menu: \"Show keys on screen\", \"Set up keys…\", \"Page group\", \"Settings…\" and \"Quit AMS Deck Mate\".",
            "Under \"Page group\" you choose \"Automatic\" or pin one page group by hand.",
            "The top of the menu tells you what is going on: \"Page group: <name>\" with \"(automatic)\" or \"(locked)\", \"iPhone: connected – <name>\" or \"iPhone: none connected\", and a line about the box.",
            "\"Page group for <the app in front>\" is a small list of your page groups and \"None – use the default\". Pick one and that page group shows by itself whenever that app is in front. The app is taken off any other page group, so it belongs to only one."
        ]),
        Section(id: "screen", title: "Keys on screen", part: "screen", lines: [
            "\"Show keys on screen\" opens a small floating window with the same 15 keys as the box. The shortcut is Control-Option-D.",
            "A click does what pressing the box key does. The window does not take the keyboard away from the app you are working in.",
            "It stays above other windows, you can drag it anywhere, and it remembers its place.",
            "The top line shows the page group and page names and a button to set up keys. While \"Set up keys\" is open the floating keys step aside, and come back when you close it.",
            "It works without the box, so you can use the keys on a Mac with no box plugged in.",
            "Three choices in Settings, in the card \"Keys on screen\". \"Show them\": \"Where I left them\" or \"At the mouse pointer\".",
            "At the mouse pointer, the keys appear under the pointer each time. Near the edge of the screen they move in until they are whole. The place you drag them to is not remembered then.",
            "\"Hide after a key is pressed\" hides the keys after a click on a key that does something on the Mac. A key that only moves around leaves them open.",
            "\"Size\": Small, Normal or Large. The window changes size at once.",
            "Together: press Control-Option-D, the keys appear under the mouse, click one, and they are gone.",
            "You can also use the keyboard. Right after the keys appear, 1 to 5 press the top row, Q W E R T the middle row and A S D F G the bottom row. These are the same places on every keyboard.",
            "The left and right arrow keys, or Tab and Shift-Tab, change page. Escape hides the keys.",
            "New in 0.10: Space or / (or the new magnifier in the top line) opens \"Find a key\". See the part \"Find a key\" below.",
            "After a key that does something on the Mac, the keyboard goes back to the app you were in.",
            "Since 0.4.1, while the keys on screen have the keyboard, each key shows its letter in a small round mark in its top-left corner: 1 2 3 4 5 on the top row, Q W E R T in the middle and A S D F G at the bottom.",
            "The letters go away as soon as the keyboard goes back to the app you were in, after a key that does something on the Mac or after a click on the keys. So letters showing means typing works right now.",
            "The letters show only on the keys on screen, not on the box, the iPhone or in Set up keys.",
            "A key whose app, file, folder, Raycast command, folder page or page group is gone shows a small red mark in its corner.",
            "Since 0.5, a key with a long-press action shows a small white dot in its top right corner. Hold the mouse button on it for half a second and the second action runs. Let go sooner and the usual action runs.",
            "A key with a long-press action acts when you let go of the mouse button, so the Mac can tell a short click from a long one. All other keys act at once, as before.",
            "New in 0.20: a key can have a double press too (see \"Double press: a third action\" below). Click twice within a third of a second (0.33 seconds) and the double-press action runs. A key with a double press shows a small white \"×2\" in its top right corner. Before: no key could have a double press, and two quick clicks were just two clicks.",
            "A key with a double press waits a third of a second after one click, to see whether a second click follows. Every key without a double press still acts at once, as before.",
            "New in 0.20: rest the mouse pointer on a key for one second and a small light plate says in words what that key does: \"Click …\", \"Hold …\" (only when holding does something else) and \"Twice …\" (only when the key has a double press). The plate stands over the other half of the keys, so it never covers the key you point at. Move the pointer away, or click, and it goes. Before: nothing showed. Nothing else about the keys on screen changed.",
            "The favourites row is not shown on the keys on screen. It is for the iPhone and iPad.",
            "New in 0.16: if another app already uses Control-Option-D, Settings › Keys on screen says in orange: \"Control-Option-D is used by another app, so it does not work here. Use the menu bar icon to show the keys.\" Before: the shortcut simply did nothing.",
            "New in 0.17: the three small buttons in the top line now read \"Search\", \"Set up\" and \"Hide\". Before: a magnifier, a gear and a cross, with no words. Hide has no cross any more, so the cross means \"remove\" only, in Set up keys."
        ]),
        Section(id: "look", title: "The look of a key", part: "keys", lines: [
            "A key is a flat coloured tile with a white hand-drawn icon and a short title.",
            "Each kind has its own colour: apps blue, links teal, Raycast red, keyboard shortcuts purple, typed text amber, music and sound green, moving around grey-blue.",
            "A key that opens an app shows the app's own icon, unless you pick a hand-drawn one.",
            "Since 0.9.3 a key can also show a picture of its own, for example an app's real icon, instead of a white drawing. This works for any key, also one that opens a web address or a file. The picture has rounded corners like an app icon and sits on the key's usual colour (links stay teal). If the picture file is gone, the key shows the usual drawing for what it does.",
            "The pictures are files in the folder \"Pictures\" beside your keys. The AMS Apps Overview tool puts them there. There is no button to choose a picture in the app yet.",
            "A key that opens an app and has no words of its own shows the app's name, for example Mail, Safari or Calculator. Words you write on a key always win. This is the same on the box, on the screen and on the iPhone.",
            "There are 257 hand-drawn icons to pick from. Since 0.9.2 they include a house, arrows in all four directions, and window top half and bottom half next to the left half, right half and full window drawings. Since 0.9.4 there is also a drawer. Since 0.10 there are a microphone and a crossed-out microphone. Since 0.18 there is also a fan with three blades.",
            "New in 0.10: timer keys are amber, switch keys and Apple Shortcut keys are purple, and an \"Open app\" key is blue like any app key. The microphone light is red while a microphone is in use and grey-blue while it is free.",
            "New in 0.11: the five keys that show something at a glance put the value in large white words where the drawing normally is, with small words under it. See \"Keys that show something at a glance\" below. Next event and Desk are blue, Weather is teal, Due today is purple, Album cover is green, and Body Battery is green, amber or red by its number. New in 0.12: a glance key can also change its colour with its value. The five new kinds are Garmin number (teal), Mac at a glance (grey-blue), World clock (grey-blue), Sunrise and sunset (amber) and Free until (green or red, by your calendar).",
            "New in 0.13: \"On the Mac\" keys are purple like shortcut keys. \"Join the meeting\" is blue, \"Spotify playlist\" is green, \"Search for the copied text\" is teal, and \"Counter\" and \"Stopwatch\" are amber. Two new drawings to pick: an eject mark and a video camera, so there are 256 to choose from.",
            "New in 0.14: \"PARAGON\" keys are purple, like shortcut keys. \"Focus rounds (PomoTimer)\" keys are amber while nothing runs, then red during a focus step, green during a pause or long break, and amber again during start-up, preparation and cool-down. \"Due today\" turns red when something is overdue. A \"Spotify playlist\" key shows the playlist's own cover once it is found.",
            "New in 0.15: calmer colours. Red is kept for real trouble. The \"Focus rounds\" key is purple while you focus (before: red); the pause stays green, and start-up, preparation and cool-down stay amber. \"Body Battery\" is green from 50, teal from 25 to 49 (before: amber) and amber below 25 (before: red). \"Stress today\" is green when resting, teal when low or medium (medium was amber) and amber when high (before: red). \"Resting pulse\" shows no colour from 5 beats over your usual (before: amber) and amber from 8 over (before: red). Red stays for: Mac very busy, Mac battery low, free space low and a PARAGON task overdue. A number the watch has not renewed for more than 3 hours turns grey-blue (see \"Garmin number key\").",
            "New in 0.16: darker amber and green, so the white words are easier to read. Amber went from 0.73 / 0.47 / 0.06 to 0.62 / 0.38 / 0.04, and green from 0.18 / 0.61 / 0.31 to 0.14 / 0.52 / 0.26. The buttons in Settings use the same green, so they are a little darker too. The headings are as before.",
            "New in 0.16: \"Breathing pacer\" is green, like the music keys. \"Progress bar\" is purple while a focus round runs and amber for a timer. \"Now on my plan\" is purple, like the other PARAGON keys. An \"Often used\" key wears the colour and picture of the key it stands for. A Weather key that is more than 2 hours old turns grey-blue (see \"Weather key\")."
        ]),
        Section(id: "setup", title: "Set up keys", part: "keys", lines: [
            "Open it from the menu. Page groups are on the left, under \"Page groups\": add (\"Add a page group\"; the new one is named \"New page group\"), rename, delete, make default, and \"Use with apps\".",
            "New in 0.17: the two look-alike \"+\" buttons now have words. The one beside \"Page groups\" reads \"+ Page group\" and the one after the page names reads \"+ Page\". Before: both were just a \"+\".",
            "New in 0.10: the + beside \"Page groups\" now opens a small list: \"Empty page group\" and four ready-made ones. See \"Ready-made page groups\" below. Under the page's buttons there is also \"Add an “Open apps” folder\". See \"Open app keys\" below.",
            "New in 0.11: six more kinds under \"What it does\": \"Next event\", \"Weather\", \"Due today\", \"Album cover\", \"Body Battery\" and \"Desk\". The Weather key has a field for the town, and the Desk key has the button \"Take the desk as it is now\" and a list of the apps it holds.",
            "New in 0.12: five more kinds under \"What it does\": \"Garmin number\", \"Mac at a glance\", \"World clock\", \"Sunrise and sunset\" and \"Free until\". Garmin number and Mac at a glance have a list to pick the number from. World clock and Sunrise and sunset have a field for the town.",
            "New in 0.13: six more kinds under \"What it does\": \"On the Mac\", \"Join the meeting\", \"Spotify playlist\", \"Search for the copied text\", \"Counter\" and \"Stopwatch\". \"On the Mac\" has a list of six choices. \"Spotify playlist\" has a field for the link, and \"Search for the copied text\" has a list of five search sites. \"Switch (on or off)\" has a fourth choice, \"Keep the Mac awake\".",
            "New in 0.14: two more kinds under \"What it does\": \"PARAGON\" (a menu of four choices: Inbox, Next task, Task from the copied text, Quick note) and \"Focus rounds (PomoTimer)\" (a menu of five ready-made plans, and a button to read your own templates). \"Quit all apps\" now fills its list \"Stays open\" for you, with a button \"Take the apps open now\".",
            "New in 0.15: \"What it does\" is now a button that opens a list with a search field on top and the 42 kinds under 8 coloured headings: Open, Type and press, Music and sound, Time, At a glance, On the Mac, Moving around and Nothing. Before: one long menu of 42 lines. Type a few letters and the list shrinks; a few other words work too, for example \"countdown\" finds Timer. Return takes the first kind shown. Escape closes the list.",
            "New in 0.15: drop it on a key. See \"Drop it on a key\" below.",
            "New in 0.16: three more kinds under \"What it does\", so now 45: \"Breathing pacer\" and \"Progress bar (part of a row)\" under Time, and \"Often used key\" under Open. PARAGON has a fifth choice, \"Now on my plan\". See \"Breathing pacer key\", \"Progress bar across keys\", \"Often used keys\" and \"Now on my plan\" below.",
            "New in 0.16: wrong input is said at once. A link key with text that is neither a file nor a web address (for example it has a space) gets a red line: \"This is not a web address or a file. Check it for spaces, or choose a file with the button.\" The key counts as broken. A bare name like \"example.com\" gets a grey note that it opens as https://example.com.",
            "New in 0.16: a town (Weather, World clock, Sunrise and sunset) is looked up when you leave the field, press Return or Save. A town that is not found says in red \"Town not found. Check the spelling.\" A found one says in grey, for example \"Lisbon, Portugal\". With no internet nothing is shown. A Spotify playlist text that is no Spotify link says in red \"This is not a Spotify link. In Spotify choose Share › Copy link, then paste it here.\" An empty field still says \"No Spotify link yet\".",
            "New in 0.16: the red close button of Set up keys asks \"Save the changes to this key?\" when a key is half edited. Save, Don't save, or Cancel, which keeps the window open.",
            "New in 0.16: \"All pages\" has a button \"Save as PDF…\". See \"Save your keys as a PDF\" below. The menu bar menu has \"New key from…\" (see below), and Settings › Key use can suggest a key (see \"The deck suggests a key\").",
            "New in 0.16: under the page's buttons, next to \"Add an “Open apps” folder\", there is \"Add an “Often used” folder\". The ready-made list under the + beside \"Page groups\" has a fifth page group, \"My AMS apps\" (see below). In the column of page groups, under \"Use with apps\", a page group can have hours (see \"Hours for a page group\").",
            "In the middle are the 15 keys, with the pages and folders of the page group above them. You can add and delete pages.",
            "Since 0.5, \"All pages\" (top right of the Keys column) shows every page group with every page and folder as a small picture of its 15 keys. Under each picture are its name and the number of keys; a folder has the folder mark; the page you are editing has a coloured frame. Click a page to open it for editing. \"Back to the keys\", or Escape, goes back.",
            "Click a key to edit it on the right: Title, Icon, Colour and \"What it does\". For a key that shows a picture, the Icon button says \"Own picture\". Picking a drawing, or \"Automatic\", replaces the picture.",
            "New in 0.24: beside the Icon there is a \"Colour\" well (Apple's colour picker). Pick a colour and the key wears it on the box, on the screen and on the iPhone and iPad. The small button \"Kind's colour\" puts the colour of its kind back. Keys whose colour already says something (the microphone light, Weather, Due today, PARAGON, Training today, Steward: to decide, Focus rounds, Body Battery, the Garmin numbers, Mac at a glance, World clock, Free until and the progress bar keys) show no colour well and keep their colour.",
            "Every edit has Cancel and Save. Escape is Cancel.",
            "\"Clear key\" empties a key. \"Try it\" runs the key.",
            "Move keys by dragging: drop a key on another place to move it there, or to swap with the key that is there. Drop a key on a page chip at the top to send it to that page, to the same place. A key already there swaps. A folder key takes its folder along.",
            "Copy and paste: with a key picked, Command-C copies it and Command-V pastes it. The pasted key replaces the picked one. This works when you are not typing in a text field.",
            "\"Duplicate page\" (beside Delete page) copies the page and its folders. The copy is named \"… copy\". \"Duplicate page group\" (beside Make default) copies the page group. The copy belongs to no app yet.",
            "Undo and Redo: Command-Z and Shift-Command-Z, or the two buttons in Set up keys. They go back through the last 30 changes for as long as the app runs. The safety copies on disk stay as before.",
            "A broken key has a red mark in its corner, on the screen and in Set up keys. Pick it and one line tells you what is missing.",
            "Since 0.5, under \"What it does\" there is a second picker, \"Long press\". See \"Long press: a second action\" below. Under the 15 keys there is a row \"Favourites\" of 5 places. See \"The favourites row\" below. New in 0.20: right under \"Long press\" there is a third picker, \"Double press\". See \"Double press: a third action\" below. Its note in the check for broken keys starts with \"Double press:\".",
            "New in 0.19: the window is taller and nothing is cut off. Before: it was 620 points high, but the middle column had grown taller than that, so the top of the left column (the name of the first page group) and the first line of the right column were cut off under the title bar, and the bottom line with Undo, Redo and Done was pushed out of the window. Now: the window is up to 840 points high (never taller than the screen allows; 789 on this MacBook as its screen is set today), everything starts at the top, the bottom line with Undo, Redo and Done is always in sight, and the left and middle columns scroll by themselves if a screen is too small for them.",
            "New in 0.19: in the left column, under each page group's settings, there is a box \"Several pages at once\". See \"Choose which pages show together\" below.",
            "New in 0.26: in the page group's settings there is a switch \"Hub — a start screen\". It marks the page group as a Hub. See \"Hubs: start screens\" below."
        ]),
        Section(id: "places", title: "Choose which pages show together", part: "keys", lines: [
            "New in 0.19. An iPad on its side can show 4 pages at once (2 above, 2 below) and an iPhone 2 side by side. This is the setting \"Several pages at once\" in the iPhone and iPad app. Before: only the app decided which pages. The page you were on always came first (top left), then the next pages of the page group in their order, going round, then the group's folders. So a tap on a page in the navigation picture moved that page to the top left and shuffled the other three. You could not place pages yourself.",
            "Now: in Set up keys, in the left column under each page group's settings, the box \"Several pages at once\" has four places, numbered 1 to 4. 1 is top left, 2 is top right, 3 is bottom left and 4 is bottom right, as on an iPad on its side. An iPhone shows places 1 and 2.",
            "You drag a page, or a folder, from the row of pages above the keys into a place. Dropping on a place that is taken replaces what was there. Dragging from one place to another swaps the two. The small cross in the corner of a place empties that one place. The button \"Let the app choose\" empties all four places, and then everything is as before.",
            "Each page group has its own four places. They are saved with the keys. An empty place says \"The app chooses\" under it.",
            "The rule: pages you placed always show in their places. Going to one of them (a tap in the navigation picture, a folder key, Back) changes nothing on the screen except which one is \"the page you are on\". Places you left empty are filled by the app as before, starting with the page you are on.",
            "When all places are taken and you go to a page that is not one of them, that page shows in place 1 for the moment. Your own page comes back there as soon as you go to one of your placed pages again.",
            "A page or folder that is gone no longer counts: its place is empty. The box, if it is plugged in, and the keys on screen on the Mac still show just the first page. The iPhone and iPad app 0.31 shows the name of the page you are on in blue."
        ]),
        Section(id: "longpress", title: "Long press: a second action", part: "keys", lines: [
            "Every key can have a second action that runs when you hold it. Set it in Set up keys: pick the key, and under \"What it does\" use the picker \"Long press\". Choose Nothing, or anything a key can do except \"Folder of keys\", and fill it in like the normal action.",
            "A key with a long-press action shows a small white dot in its top right corner: on the box, on the keys on screen and on the iPhone and iPad.",
            "Hold the key for half a second (0.5 seconds). On the iPhone and iPad a long press gives a stronger buzz. On the Mac's keys on screen, hold the mouse button. On the box, hold the key.",
            "A long press on a key that has no second action does the usual thing, as if you had tapped.",
            "New in 0.13: on a Counter key or a Stopwatch key, a long press sets it back to 0. It needs no setting, and the key shows no white dot for it. If you give such a key a long press of your own, that one runs instead.",
            "On the box and on the Mac's keys on screen, a key with a long-press action acts when you let go: the usual action if you let go early, the second action if you are still holding after half a second. All other keys act at once, as before.",
            "A long-press action that is broken (for example its app is gone) shows the red corner. In Set up keys the reason starts with \"Long press:\".",
            "New in 0.20: the white dot keeps its one meaning, hold. A key with a double press shows a different mark, \"×2\", beside it. A key can have both. The long press still works on a key that has both: hold it for half a second.",
            "Not yet tried on the real box. The box is away until January 2027."
        ]),
        Section(id: "twicepress", title: "Double press: a third action", part: "keys", lines: [
            "New in 0.20. Every key can have a third action that runs when you press it twice. Before: a key had its usual action and, since 0.5, a long press. Now: a double press as well.",
            "Set it in Set up keys: pick the key, and right under \"Long press\" at the bottom of the right column there is \"Double press\". It offers the same list of things a key can do, and the same fields. \"Nothing\" means no double press, and that is how every key is at first. No key of yours has a double press yet.",
            "A key with a double press shows a small white \"×2\" in its top right corner, to the left of the place of the long-press dot: on the box, on the keys on screen and on the iPhone and iPad. The dot still means only \"hold\". A key can have both, the \"×2\" and the dot side by side.",
            "How to press it: two presses within a third of a second (0.33 seconds). It works on the Stream Deck box's keys, on a click on the keys on screen, on a tap on the iPhone and iPad (the 15 keys and the favourites), and by a link (see \"Press keys from Raycast and by link\"). While the keys on screen take the keyboard, the key's letter typed twice within a third of a second counts too.",
            "The price, said plainly: a key that has a double press waits a third of a second after one press, to see whether a second press follows, and only then does its usual thing. Every key without a double press acts at once, exactly as before. On the box and with the mouse the wait starts when you let the key go.",
            "A double press on a key without one is two presses, one after the other, as before.",
            "Favourites can have a double press too. So can a key that only moves around (a page, a folder or a page group key).",
            "A double-press action that is broken (for example its app is gone) shows the red corner. In Set up keys the reason starts with \"Double press:\".",
            "Your keys file was not changed by this, and files from before are read as they are. Not yet tried: the double press on the real box, and a real finger double-tapping on the iPhone or iPad with this Mac."
        ]),
        Section(id: "keysays", title: "What a key says it does", part: "keys", lines: [
            "New in 0.20. Every kind of key now has words that say what it will do, for example \"Opens Safari\", \"Presses ⌘N\", \"Fans: Cool for 10 minutes\" or \"Goes to the page “Money”\". Before: nothing said it, and you had to remember or open Set up keys. Up to three lines per key: a tap (on the Mac a click), a hold (only when holding does something else) and twice (only when the key has a double press).",
            "On the Mac's keys on screen: rest the mouse pointer on a key for one second. A small light plate over the other half of the keys says \"Click …\", \"Hold …\" and \"Twice …\". Move the pointer away, or click, and it goes.",
            "On the iPhone and iPad (app 0.32) the same words show with the new \"Explain\" button. The Mac sends them, so the button only shows while the phone is connected to a Mac with 0.20 or later. With an older Mac the button is not there. With an iPhone or iPad app 0.31 and this Mac, everything works, and the phone has no Explain button."
        ]),
        Section(id: "favourites", title: "The favourites row", part: "keys", lines: [
            "5 keys that stay in place on every page and in every page group. They show only on the iPhone and iPad, as a row under the 15 keys.",
            "Set them up on the Mac in Set up keys: under the 15 keys there is a row \"Favourites\" of 5 places. Click one and edit it like any key: title, icon, what it does, and a long press too.",
            "A favourite can be anything except a folder or Back. Copy and Paste work on favourites. Dragging does not.",
            "A favourite that moves to another page or page group moves the place of the iPhone or iPad when it has its own keys, and otherwise the Mac's place.",
            "The favourites are not shown on the box, which has 15 keys, nor on the Mac's keys on screen.",
            "On the iPhone and iPad, Settings has a switch \"Favourites row\" (on at first). The row only shows when at least one favourite is set.",
            "They need Mac 0.5 and iPhone and iPad 0.7."
        ]),
        Section(id: "broken", title: "Broken keys and \"Check keys\"", part: "keys", lines: [
            "A key is broken when its app, file or folder, Raycast extension, folder page or page group is gone. It gets a red mark in its corner.",
            "In Settings, \"Check keys\" has the button \"Check all keys\". It lists every broken key as \"Page group · Page · key: reason\".",
            "Fix a broken key in Set up keys: pick it and choose again what it does."
        ]),
        Section(id: "actions", title: "What a key can do", part: "keys", lines: [
            "Open an app. Open a link or a file: web pages, folders and files.",
            "Raycast: run a Raycast command. Keyboard shortcut: press the keys to record them.",
            "Type text. Music and sound: play or pause, next, previous, volume up, volume down, mute.",
            "Folder of keys opens another page of keys, and Back returns. Next page and Previous page move between pages.",
            "Switch page group changes the page group. Several things in a row runs steps one after another, a third of a second apart, unless you put a \"Wait\" step between two of them (since 0.10). See \"Several things in a row and Wait\".",
            "Since 0.10, six more kinds: \"Timer\", \"Switch (on or off)\", \"Run an Apple Shortcut\", \"List to pick from\", \"Open app\" and \"Microphone light\". That makes 23 kinds of key, instead of 17. See the parts after \"Recent file key\".",
            "Since 0.11, six more kinds: \"Next event\", \"Weather\", \"Due today\", \"Album cover\", \"Body Battery\" and \"Desk\". That makes 29 kinds of key, instead of 23. See the parts after \"Ready-made page groups\".",
            "Since 0.12, five more kinds: \"Garmin number\", \"Mac at a glance\", \"World clock\", \"Sunrise and sunset\" and \"Free until\". That makes 34 kinds of key, instead of 29. See the parts after \"Body Battery key\".",
            "Since 0.13, six more kinds: \"On the Mac\", \"Join the meeting\", \"Spotify playlist\", \"Search for the copied text\", \"Counter\" and \"Stopwatch\". That makes 40 kinds of key, instead of 34. \"Switch (on or off)\" also has a new choice, \"Keep the Mac awake\". See the parts after \"Desk key\".",
            "Since 0.14, two more kinds: \"PARAGON\" and \"Focus rounds (PomoTimer)\". That makes 42 kinds of key, instead of 40. \"Due today\" now counts PARAGON tasks. See \"PARAGON keys\" and \"Focus rounds key\" after \"Stopwatch key\".",
            "Since 0.15, the 42 kinds are not a long menu any more: \"What it does\" opens a list with a search field and 8 coloured headings. \"Garmin number\" has seven numbers to pick from, instead of five.",
            "Since 0.16, three more kinds: \"Breathing pacer\", \"Progress bar (part of a row)\" and \"Often used key\". That makes 45 kinds of key, instead of 42. PARAGON has a fifth choice, \"Now on my plan\". See the parts after \"PARAGON keys\".",
            "Since 0.23, one more kind: \"Training today\", in the same group as the PARAGON kinds. It shows today's training session from AMS Triathlon Training. See \"Training today key\" after \"PARAGON keys\".",
            "Since 0.25, one more kind: \"Steward: to decide\", in the group \"At a glance\" beside \"Training today\". It shows how many bank rows wait in AMS Financial Steward's To decide. See \"Steward: to decide key\" after \"Training today key\".",
            "Since 0.7, two more: \"Recent app\" (the app you used before the one in front) and \"Ask AI (copied text)\" (opens Raycast AI Chat with your copied text). See the next two parts.",
            "Since 0.8, two more: \"Last copied text\" and \"Recent file\". See the two parts after \"Ask AI about copied text\".",
            "Nothing leaves the key empty.",
            "Since 0.5, every key can have a second action on a long press, and 5 favourite keys stay on every page for the iPhone and iPad."
        ]),
        Section(id: "recentapp", title: "Recent app key", part: "keys", lines: [
            "New in 0.7. In Set up keys, under \"What it does\", choose \"Recent app\" and then 1st, 2nd or 3rd.",
            "The key shows the icon and name of an app you used before the one in front. 1st is the app you used just before this one, 2nd is the one before that, 3rd the one before that.",
            "The picture changes by itself as you switch apps, on the box, on the keys on screen and on the iPhone and iPad. Press the key and that app comes forward.",
            "Deck Mate's own windows never count as an app you used.",
            "The list is remembered when the Mac restarts.",
            "Until enough apps have been used, the key shows a clock drawing and the word \"Recent\" in blue, the app colour.",
            "Put three of them side by side, set to 1st, 2nd and 3rd, and you have your last three apps."
        ]),
        Section(id: "askai", title: "Ask AI about copied text", part: "raycast", lines: [
            "New in 0.7. In Set up keys, under \"What it does\", choose \"Ask AI (copied text)\".",
            "Press the key and Raycast AI Chat opens with the text you copied last already filled in. The key is Raycast red, with an AI drawing and the title \"Ask AI\".",
            "If nothing is copied, or you copied a picture, AI Chat just opens.",
            "Very long text is cut at 4,000 characters.",
            "New in 0.15: a copy that a password manager marked as secret is not used. Before: it was sent to AI Chat like any other text. Now: AI Chat just opens, with nothing filled in.",
            "Not yet tried against the real Raycast. This is a first version: if the text does not arrive in AI Chat, tell me."
        ]),
        Section(id: "copiedkey", title: "Last copied text key", part: "keys", lines: [
            "New in 0.8. In Set up keys, under \"What it does\", choose \"Last copied text\" and then 1st, 2nd or 3rd.",
            "1st is the text copied just before the current one, 2nd the one before that, 3rd the one before that. The key shows the first words of that text, up to 18 letters.",
            "Press the key and that text is pasted where your cursor is. It also becomes the text you copied last, so pressing Command-V does the same.",
            "Deck Mate remembers your last 4 copied texts: the current one and three before it. They are kept in memory only. They are never written to a file and are gone when the app quits.",
            "A copy that a password manager marks as secret is skipped, so passwords never show on a key. Since 0.15 the keys \"Search for the copied text\", \"Ask AI\" and PARAGON \"Task from the copied text\" skip such copies too.",
            "Deck Mate only watches what you copy while at least one such key exists in your setup.",
            "It needs the same one-time Accessibility yes as \"Type text\".",
            "The key is amber, like the other keys that type text.",
            "On the iPhone and iPad the key shows too, drawn by the Mac. The first words of a copied text are visible on the key.",
            "New in 0.9: a fourth choice, \"A list to pick from\". The key shows a clipboard drawing and the words \"Copied texts\".",
            "Press it and a small list opens at the mouse pointer on the Mac. It shows your earlier copied texts, up to three, each with its first 60 letters.",
            "Click one and it is pasted where your cursor is, exactly like the 1st, 2nd and 3rd keys.",
            "Click anywhere else, press the key again, or wait 10 seconds, and the list goes away.",
            "Pressed from the iPhone, iPad or the box, the list also opens on the Mac, because the choice is made with the mouse."
        ]),
        Section(id: "recentfilekey", title: "Recent file key", part: "keys", lines: [
            "New in 0.8. In Set up keys, under \"What it does\", choose \"Recent file\" and then 1st, 2nd or 3rd.",
            "1st is the file you opened last, 2nd the one before that, 3rd the one before that. The key shows the name of the file. Press it and the file opens.",
            "The list comes from the Mac's own record of opened files. Only the last 7 days count, and only files in your home folder. Folders, apps, hidden files and anything in the Library folder are left out.",
            "Deck Mate only looks this up while at least one such key exists in your setup.",
            "The key is teal, like the other keys that open files and links. Until there is a file for its place, it shows \"Recent file\".",
            "On the iPhone and iPad the key shows too, drawn by the Mac."
        ]),
        Section(id: "timer", title: "Timer key", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"Timer\" and pick the minutes: 1, 2, 3, 5, 10, 15, 20, 25, 30, 45 or 60.",
            "Press the key and the timer starts. Changed in 0.16: the key counts in whole minutes. While more than 60 seconds are left it says for example \"21 min\" (\"75 min\" for an hour or more), at exactly one minute \"1:00\", and only in the last minute it counts seconds, for example \"0:59\". Before: it counted every second, for example \"4:59\". Press again and it stops.",
            "When the time is up, the Mac plays one soft sound (\"Glass\", a little quieter than before) and the key says \"Done\" for one minute, or until you press it. Before 0.16 the sound played twice, 1.2 seconds apart. The end and the word \"Done\" come on time, as before. A focus round makes no sound in Deck Mate (PomoTimer plays its own). The stopwatch keeps its seconds.",
            "A key without a title shows \"5 min\" (or whatever minutes you picked). Words you write on a key win.",
            "Two keys with the same minutes are the same timer: start one and the other counts down too.",
            "The key is amber. The countdown shows on the box, on the keys on screen and on the iPhone and iPad.",
            "A timer is forgotten when Deck Mate quits."
        ]),
        Section(id: "switch", title: "Switch key (on or off)", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"Switch (on or off)\". It has three choices, since 0.13 a fourth, \"Keep the Mac awake\", since 0.18 three more, \"Fans: Automatic\", \"Fans: Cool\" and \"Fans: Full\", since 0.21 an eighth, \"Fans: chip temperature\", and since 0.22 a ninth, \"Fans: fan speed\". That makes nine.",
            "New in 0.13: \"Keep the Mac awake\". While it is on, the Mac and its screen do not go to sleep by themselves. Press again to switch it off. It is off again after AMS Deck Mate quits or the Mac restarts. Without a title the key says \"Awake\" or \"May sleep\".",
            "\"Dark mode\" switches the Mac between light and dark. The first time, the Mac asks once whether Deck Mate may control \"System Events\". Choose Allow.",
            "\"Mute the sound\" mutes and unmutes the Mac.",
            "New in 0.18: fan keys. \"Fans: Automatic\", \"Fans: Cool\" and \"Fans: Full\" set the fan speed of your MacBook. For this you need AMS Fan Menu (version 0.2 or newer; since 0.19 version 0.3.1 or newer) on this Mac. Deck Mate never touches the fans itself. It only asks AMS Fan Menu.",
            "A press asks AMS Fan Menu for that choice. Automatic: the Mac runs the fans itself. Cool: a middle speed. Full: top speed. The speeds are the ones set in AMS Fan Menu.",
            "If AMS Fan Menu is not open, the press opens it first and asks about a second and a half later. If it is not installed, the press does nothing and the note says \"AMS Fan Menu is not on this Mac\". After a press the note says, for example, \"Fans: Cool\". Set up keys also marks a fan key as a key that cannot work while AMS Fan Menu is not on this Mac.",
            "The fan key of the choice that is on right now shows the small switch mark filled. The other fan keys show it as an outline. It is the same mark as on every switch key. Filled means on, outline means off.",
            "The keys follow AMS Fan Menu within a moment (about two seconds at most). That is also so when you change the choice in the Fan Menu panel, or when Fan Menu changes it by its own rules (on battery, a timed choice running out, too hot, sleep). If Fan Menu is on a choice that has no key (Quiet, My speed, Follow temperature), no fan key is filled.",
            "One difference from the other switches: a second press on a fan key that is already on changes nothing. To leave Cool, press Automatic (or Full).",
            "New in 0.19: Cool and Full last 10 minutes. The Cool key and the Full key ask AMS Fan Menu for 10 minutes. After 10 minutes AMS Fan Menu gives the fans back to the Mac by itself and its choice goes to Automatic, so the Automatic key shows the filled switch mark again. Before (0.18): Cool or Full stayed on as long as the \"For\" line in AMS Fan Menu said, and with its usual pick \"Until I change\" that meant for good. The Automatic key is unchanged and has no time.",
            "A second press on the same Cool or Full key starts the 10 minutes afresh. For this you need AMS Fan Menu 0.3.1 or newer. With an older AMS Fan Menu the Cool and Full keys do nothing.",
            "New in 0.20: the fan key that is on shows the minutes left. Before (0.19): the Cool and Full keys always read \"Cool 10 min\" and \"Full 10 min\", whether they were on or off. Now: the key of the choice that is on shows what is left, for example \"Cool · 8 min\", and in the last minute \"Cool · <1 min\". Whole minutes, rounded up, the same count AMS Fan Menu shows. The key of a choice that is off still reads \"Cool 10 min\" or \"Full 10 min\": that is what a press gives.",
            "A choice that is on with no end (set in AMS Fan Menu itself with \"Until I change\") reads just \"Cool\" or \"Full\". \"Automatic\" never shows minutes.",
            "The key is drawn again when the minute changes, not every second. Deck Mate still looks at AMS Fan Menu's note every 2 seconds, as before, and at once when AMS Fan Menu says it changed. A fan key with a title of your own keeps that title: the live words only show on a key without a title. This needs AMS Fan Menu 0.3.1 or newer, as before; AMS Fan Menu itself did not change. The iPhone and iPad need no update for this: the Mac draws the keys.",
            "A fan key is purple like every switch key. Its drawing is a fan with three blades, the same as AMS Fan Menu shows in the menu bar. Without a title it says \"Automatic\", \"Cool 10 min\" or \"Full 10 min\" while the choice is off (before 0.19: \"Cool\" and \"Full\"), and while it is on, the minutes left, for example \"Cool · 8 min\" (since 0.20). In Set up keys the picker and the Raycast commands read \"Fans: Cool for 10 minutes\" and \"Fans: Full for 10 minutes\".",
            "The iPhone and iPad app need no update. The Mac draws the keys, so the fan keys show and work there by themselves.",
            "New in 0.22: \"Fans: fan speed\". Like the chip key, this key is not a switch: it shows how fast the Mac's fans turn, in turns per minute, live, for example \"Fans 1,650\". With two fans it shows the faster one. \"Fans off\" means every fan stands still. \"Fans –\" means there is no fresh reading (AMS Fan Menu is not running, is older than 0.6, or its note is more than 30 seconds old). A press opens the large graph window of AMS Fan Menu (it opens AMS Fan Menu first if it is not running), the same as the chip key. It has no long press of its own. It is purple like every switch key and shows no switch mark, because a speed is not on or off.",
            "New in 0.21: \"Fans: chip temperature\". This key is not a switch: it shows the Mac's chip temperature in whole degrees, live, for example \"Chip 56°\". A press opens the large graph window of AMS Fan Menu (it opens AMS Fan Menu first if it is not running). It needs AMS Fan Menu 0.6 or newer on this Mac, which writes the temperature down every 5 seconds. Without it, or when AMS Fan Menu is not running, the key reads \"Chip –\" (and a press still asks for the graph). It has no long press of its own. Deck Mate looks every 2 seconds and draws the key again only when the whole degree changes. It is purple like every switch key and shows no switch mark, because a figure is not on or off.",
            "\"Two things in turn\": you set what happens when it goes on and what happens when it goes off. The key remembers which one it is, also after a restart.",
            "The key shows a small switch mark in its top-left corner: filled when on, an outline when off. On a fan key, filled means this fan choice is on right now.",
            "A key without a title says \"Dark\" or \"Light\", \"Muted\" or \"Sound on\", \"On\" or \"Off\".",
            "Dark mode and mute follow the Mac also when you change them somewhere else. Mute follows within about two seconds.",
            "The key is purple."
        ]),
        Section(id: "appleShortcut", title: "Apple Shortcut key", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"Run an Apple Shortcut\".",
            "Pick one of the Shortcuts from the Shortcuts app in a list (\"Pick a Shortcut…\"), or type its name.",
            "Press the key and that Shortcut runs. The key is purple.",
            "A key with no Shortcut picked gets the red corner \"No Shortcut picked\".",
            "New in 0.16: when a Shortcut fails, the key says so like any failed press, for example \"The Shortcut “X” was not found\", or \"… did not finish\" or \"… could not be started\". Before: no word."
        ]),
        Section(id: "pickList", title: "List to pick from", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"List to pick from\". One key opens a small list at the mouse pointer.",
            "Each entry has a name and does one thing: open an app, open a link or a file, run Raycast, press a keyboard shortcut, type text, music and sound, or run an Apple Shortcut.",
            "Click an entry to run it. A click anywhere else, a second press of the key, or ten seconds puts the list away.",
            "Tapped on the iPhone or iPad, the list shows on the Mac, because the choice is made with the mouse.",
            "An entry without a name shows what it does."
        ]),
        Section(id: "openApps", title: "Open app keys", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"Open app\" and pick 1st to 15th. The key stands for one of the apps that are open right now.",
            "The apps are in the order they were opened. An app keeps its place while it stays open, and a newly opened app goes to the end.",
            "The key shows that app's own icon and name. Press it and the app comes forward. With fewer apps open it says \"No app\".",
            "Under the page's buttons there is a new button \"Add an “Open apps” folder\". It puts a folder key on the first empty place of the page. Inside are Back and Open app 1 to 14, so the folder is always a live picture of what is open.",
            "When the page is full, it says so and changes nothing."
        ]),
        Section(id: "micLight", title: "Microphone light", part: "keys", lines: [
            "New in 0.10. In Set up keys, under \"What it does\", choose \"Microphone light\".",
            "It shows whether any app is listening to the Mac's microphone right now. Red with a microphone and \"Mic in use\", or grey-blue with a crossed-out microphone and \"Mic free\".",
            "It changes within about two seconds. A press does nothing. It only looks and never changes the microphone."
        ]),
        Section(id: "wait", title: "Several things in a row and Wait", part: "keys", lines: [
            "The key \"Several things in a row\" was already there. New in 0.10 is the step \"Wait\": half a second, 1, 2, 3, 5 or 10 seconds between two steps. It is for an app that needs a moment to open.",
            "Without a Wait, steps still run a third of a second apart.",
            "A Timer, a Switch and \"Run an Apple Shortcut\" can also be steps."
        ]),
        Section(id: "findKey", title: "Find a key", part: "screen", lines: [
            "New in 0.10. On the keys on screen, click the magnifier in the top line, or press Space or / while the keys have the keyboard (right after Control-Option-D).",
            "Type a few letters. Up to six keys from all page groups and pages are listed under the keys, when their title, page or page group holds every word you typed. Titles that start with the word come first. Each shows its place, \"Page group · Page\".",
            "Up and down arrows choose. Return, or a click, runs the key and shows its page. Delete takes a letter away. Escape leaves the search, and Escape again hides the keys.",
            "Keys that only move around (Back, next page, previous page) are not listed.",
            "While you search, letters go to the search and not to the keys."
        ]),
        Section(id: "keyUse", title: "Key use", part: "settings", lines: [
            "New in 0.10. Settings has a new part, \"Key use\", in the list on the left.",
            "Deck Mate counts each press of a key that does something on the Mac: from the box, the keys on screen, the keyboard, the iPhone and the iPad.",
            "It shows since which day it has counted, \"Pressed most\" (the five most pressed keys, with their numbers) and \"Not pressed in the last 30 days\". In the first 30 days that list says \"Not pressed since <day>\". It is a list for tidying up, each key as \"Page group · Page · “Title”\".",
            "Keys that only move around (folders, Back, pages, page group) and the microphone light are not counted.",
            "Only the number and the time of the last press are kept, in a small file \"use.json\" beside your keys file on this Mac. It is not part of the iCloud copy."
        ]),
        Section(id: "readyMade", title: "Ready-made page groups", part: "profiles", lines: [
            "New in 0.10. In Set up keys, the + beside \"Page groups\" opens a small list: \"Empty page group\" and four ready-made ones: Finder, Safari, Notion and Fusion. Each has one page of keyboard-shortcut keys for that app.",
            "The new page group shows by itself when that app is in front. If another page group already belongs to that app (yours for Notion does), the new one belongs to no app and shows only when you pick it.",
            "If a page group of that name exists, the new one is named for example \"Notion (ready-made)\".",
            "Nothing you have is changed. Undo takes it back."
        ]),
        Section(id: "glance", title: "Keys that show something at a glance", part: "keys", lines: [
            "New in 0.11. Five new kinds of key show a value: Next event, Weather, Due today, Album cover and Body Battery. You find them in Set up keys, under \"What it does\".",
            "New in 0.12. Eleven more things to show at a glance, as five new kinds of key: Garmin number (five numbers to pick from; seven since 0.15), Mac at a glance (three numbers to pick from), World clock, Sunrise and sunset, and Free until. They are in Set up keys, under \"What it does\", and they look and work like the five above: the value in large white words where the drawing is, small words under it (your own title replaces the small words), and the drawing until a value is there.",
            "New in 0.12: a glance key can change its colour with its value, for example green when all is well and red when something needs you. Each part below says when.",
            "The value stands on the key in large white words, where the drawing normally is, with small words under it. If you gave the key a title, your title replaces the small words.",
            "Until a value is there, the key shows its drawing.",
            "They show on the box, on the keys on screen and on the iPhone and iPad (the Mac draws them), so the iPhone and iPad app needs no update.",
            "Deck Mate only looks things up while at least one key of that kind exists in your setup."
        ]),
        Section(id: "nextEvent", title: "Next event key", part: "keys", lines: [
            "New in 0.11. In Set up keys, under \"What it does\", choose \"Next event\". The key is blue with a calendar drawing.",
            "It shows the next event in your calendars that has a time. All-day events are left out. It looks 7 days ahead.",
            "The large words: \"Now\" while the event goes on; for example \"12 min\" in the last hour before it starts; its time, for example \"14:30\", later today; the weekday, for example \"Wed\", on another day. On another day the time stands before the title in the small words, for example \"09:00 Dentist\".",
            "The small words are the event's title. With no event in the next 7 days the key shows a dash and \"No events\".",
            "A press opens the Calendar app. Under \"Choose app…\" you can pick another app instead, for example Fantastical.",
            "The first time, the Mac asks once whether AMS Deck Mate may see your calendar. Until then the key says \"Press to allow\". Choose \"Allow Full Access\".",
            "Deck Mate only reads. It never changes an event.",
            "If you said no, the key says \"Calendar not allowed\". Change it in System Settings › Privacy & Security › Calendars.",
            "The key follows changes in your calendar at once, and looks again every minute.",
            "New in 0.15: events that were cancelled, and events you declined, are left out. Before: a meeting you had declined could show as the next one."
        ]),
        Section(id: "weatherKey", title: "Weather key", part: "keys", lines: [
            "New in 0.11. In Set up keys, under \"What it does\", choose \"Weather\" and type a town. The key is teal with a sun drawing.",
            "The large words are the temperature in whole degrees Celsius, for example \"3°\". The small words are the sky in a word or two: Clear, Mostly clear, Partly cloudy, Cloudy, Fog, Drizzle, Rain, Snow, Showers, Snow showers or Thunder.",
            "Without a town the key says \"Set a town\".",
            "You can have several Weather keys with different towns. Give each key the town as its title to tell them apart. The title then shows instead of the sky.",
            "The weather is asked for again every 20 minutes. A press opens the Mac's Weather app.",
            "New in 0.11.1. Hold a Weather key down (a long press, half a second) to give it another town. A small window \"Weather key\" opens on the Mac with a field for the town. Type one, or pick one of up to six towns you used before from the list in the same field. Save (Return) or Cancel (Escape). The key shows the new town's weather within a few seconds. Undo in Set up keys takes it back.",
            "New in 0.12: the same long press now works for World clock and Sunrise and sunset keys too. The small window is now called \"Town for this key\" instead of \"Weather key\", and its list offers the towns you used on any of these three kinds of key.",
            "It works from the box, from the keys on screen (hold the mouse button) and from the iPhone and iPad (a long press there). The window always opens on the Mac; the iPhone and iPad say \"Type the town on the Mac\".",
            "If the Weather key has a long press of its own (set in Set up keys), that long press is kept instead. A Weather key does not show the small white dot for this; the dot still means a long press of your own. Like every key with a long press, a Weather key acts when you let go, so a short press opens Weather on release.",
            "Privacy: the free weather service Open-Meteo gets the town's name once, to find its place. After that it gets only that place (its position on the map). Nothing else about you goes out. There is no account and no key, and the Mac asks nothing.",
            "New in 0.16: a temperature that is more than 2 hours old turns the key grey-blue and the small words say for example \"As of 14:20\". Before: an old temperature stayed on the key for ever with no sign. A town you type in Set up keys is checked at once (see \"Set up keys\")."
        ]),
        Section(id: "dueToday", title: "Due today key", part: "keys", lines: [
            "New in 0.11, changed in 0.14. In Set up keys, under \"What it does\", choose \"Due today (PARAGON)\". The key is purple with a tick drawing.",
            "Before (0.11 to 0.13): the key counted OmniFocus tasks, only while OmniFocus was open. Now: it counts the tasks in PARAGON that are due today. Your tasks are in PARAGON.",
            "The large words are the number of PARAGON tasks due today. When some are overdue, the small words say how many, for example \"2 overdue\", and the key turns red. Otherwise the small words say \"Due today\".",
            "A press opens Today in PARAGON.",
            "The numbers come from the small file PARAGON writes for its own widget, read every 60 seconds. They are as fresh as PARAGON's last reload on this Mac. See \"PARAGON keys\".",
            "A \"Due today\" key you already have changes by itself. There is nothing to set up. The question the Mac asked about controlling OmniFocus is not needed any more.",
            "Deck Mate only counts. It never changes a task."
        ]),
        Section(id: "albumCover", title: "Album cover key", part: "keys", lines: [
            "New in 0.11. In Set up keys, under \"What it does\", choose \"Album cover\". The key is green.",
            "It shows the cover of the song Spotify plays, filling the whole key, with the song's name on a dark band at the bottom. Until a cover is there it shows a music note.",
            "A press plays or pauses, like the other music keys. It needs the Mac's Accessibility yes, the same one as the shortcut, text and music keys.",
            "The cover appears with the next song change after Deck Mate starts, because Spotify only says what plays when something changes. Before that the key says \"Nothing playing\".",
            "The picture comes from Spotify's own open look-up, by the song's name only. Nothing about you is sent, and the Mac asks nothing.",
            "A podcast, an advert or a local file shows the song's name with the music note.",
            "Covers are kept in memory only.",
            "New in 0.16: when a cover could not be found, the key looks again at the next change of song. Before: it never looked again."
        ]),
        Section(id: "bodyBattery", title: "Body Battery key", part: "keys", lines: [
            "New in 0.11. In Set up keys, under \"What it does\", choose \"Body Battery\". The key has a battery drawing.",
            "The large words are your latest Body Battery, from your AMS Garmin Bridge Board, which runs on this Mac from login. The small words say \"Body Battery\".",
            "Changed in 0.15: the key is green from 50, teal from 25 to 49 (before: amber) and amber below 25 (before: red). It is grey-blue while there is no number.",
            "It asks again every 10 minutes. A press opens the board in the browser.",
            "Nothing leaves the Mac, and the Mac asks nothing.",
            "New in 0.15: when the board does not answer twice in a row, the key shows \"–\" and \"Board off\". Before: it fell back to its plain drawing, and a press opened a browser error. Now a press starts the AMS Garmin Bridge Board app, and the key asks again 8 seconds later. One missed answer keeps the numbers and asks again after a minute.",
            "New in 0.15: a number the watch has not renewed for more than 3 hours turns grey-blue, and its small words say \"As of 06:29\" (the time of the watch's last sync)."
        ]),
        Section(id: "garminKey", title: "Garmin number key", part: "keys", lines: [
            "New in 0.12. In Set up keys, under \"What it does\", choose \"Garmin number\" and pick one of seven numbers from the list (five before 0.15). The key is teal unless it says otherwise below.",
            "All seven come from your AMS Garmin Bridge Board, which runs on this Mac from login, the same place the Body Battery key gets its number. One look at the board feeds all the keys and Body Battery. It asks again every 10 minutes. Nothing leaves the Mac, and the Mac asks nothing.",
            "New in 0.15: when the board does not answer twice in a row, these keys show \"–\" and \"Board off\" (before: they fell back to their plain look, and a press opened a browser error). A press then starts the AMS Garmin Bridge Board app, and the keys ask again 8 seconds later. One missed answer keeps the numbers and asks again after a minute.",
            "New in 0.15: steps, stress, resting pulse and Body Battery that the watch has not renewed for more than 3 hours turn grey-blue, and their small words say \"As of 06:29\" (the time of the watch's last sync).",
            "\"Steps today\": your steps so far, for example \"8 412\", with \"Steps today\" under it. The key turns green once you have reached your step goal for the day.",
            "\"Sleep last night\": the hours and minutes, for example \"7:24\", with Garmin's own word for the night under it, for example \"Good\". If the watch was not worn, the key shows a dash and \"No sleep recorded\".",
            "\"Resting pulse\": today's resting pulse, with \"Resting pulse\" under it. It is compared with the average of your last 7 days. From 5 beats over it, the small words say for example \"+6 over usual\", with no colour (before: amber). From 8 over it, the key turns amber (before: red).",
            "\"Stress today\": today's average stress number, with Garmin's own steps in words under it: up to 25 \"Resting\" (green), up to 50 \"Low stress\" (teal), up to 75 \"Medium stress\" (teal; before: amber), above that \"High stress\" (amber; before: red).",
            "\"Workouts, 7 days\": how many workouts you did in the last seven days, with the hours under it, for example \"7 days · 15 h\".",
            "New in 0.15, \"Days since the gym\": \"today\" on a gym day, otherwise the number of days, with \"Days since the gym\" under it.",
            "New in 0.15, \"Gym, 7 days\": how many gym sessions in the last seven days, with the minutes. The key is green when there was at least one. Both gym numbers come from the sessions of the gym app that the Garmin board reads. Until the gym app has shared them, the keys show \"–\" and \"No gym data yet\".",
            "A press opens the board in the browser."
        ]),
        Section(id: "macNowKey", title: "Mac at a glance key", part: "keys", lines: [
            "New in 0.12. In Set up keys, under \"What it does\", choose \"Mac at a glance\" and pick one of three numbers from the list. The key is grey-blue unless it says otherwise below.",
            "The Mac looks every 5 seconds, and only while such a key exists in your setup. The Mac asks nothing and nothing leaves the Mac.",
            "\"Mac battery\": the charge, for example \"73%\", with \"Mac battery\" under it, or \"Charging\" while the cable is in. Green from 40 %, amber from 20 %, red below. A Mac without a battery says \"No battery\". A press opens Battery in System Settings.",
            "\"Free space\": the room left on the Mac's disk, for example \"212 GB\" (\"8.4 GB\" under ten, \"1.2 TB\" from a thousand), with \"Free space\" under it. The key turns amber under 25 GB or when a tenth is free, and red under 10 GB or when a twentieth is free. A press opens Storage in System Settings.",
            "\"Mac busy light\": how hard the Mac's processors work, in steps of 5 %, for example \"35%\", so the key does not flicker. Under it: \"Mac calm\"; from 60 % \"Mac busy\" (amber); from 85 % \"Mac very busy\" (red). A press opens Activity Monitor."
        ]),
        Section(id: "worldClock", title: "World clock key", part: "keys", lines: [
            "New in 0.12. In Set up keys, under \"What it does\", choose \"World clock\" and type a town. The key is grey-blue with a globe drawing.",
            "The large words are the time there, for example \"14:05\". The town stands under it. When it is another day there than here, the small words say \"tomorrow\" or \"yesterday\" instead. The key follows the time every minute.",
            "You can have several World clock keys with different towns. Without a town the key says \"Set a town\".",
            "Privacy: the free service Open-Meteo gets the town's name once, to find its time zone. After that nothing goes out. The Mac asks nothing.",
            "New in 0.16: if the town search gives no time zone for a town, none is stored. Before: the Mac's own zone was kept for that town for ever, so the clock could be wrong.",
            "A press opens the Mac's Clock. Hold the key down to give it another town (see \"Weather key\")."
        ]),
        Section(id: "sunTimes", title: "Sunrise and sunset key", part: "keys", lines: [
            "New in 0.12. In Set up keys, under \"What it does\", choose \"Sunrise and sunset\" and type a town. The key is amber with a sunrise drawing.",
            "It shows whichever comes next, on the town's own clock: the large words are the time, for example \"16:42\", and under it \"Sunset\" (or \"Sunrise\").",
            "The times are asked for again every 6 hours. Privacy: Open-Meteo gets the town's name once, to find its place. After that it gets only that place, on the map. The Mac asks nothing.",
            "A press opens the Mac's Weather. Hold the key down to give it another town (see \"Weather key\")."
        ]),
        Section(id: "freeUntil", title: "Free until key", part: "keys", lines: [
            "New in 0.12. In Set up keys, under \"What it does\", choose \"Free until\". It uses your calendars, like \"Next event\".",
            "While an event goes on, the key is red: \"Busy\" with \"until 15:00\" under it.",
            "Before the next event of today that has a time, the key is green: how long you are free, for example \"1 h 20\" or \"45 min\", with \"Free until 14:30\" under it.",
            "With nothing more today, the key is green and says \"Free\" with \"Rest of the day\" under it. All-day events are left out.",
            "It needs the same yes as \"Next event\" to see your calendar. The Mac asks once, at the first press of either key, and until then the key says \"Press to allow\". Deck Mate only reads and never changes an event.",
            "The key follows changes in your calendar at once and looks again every minute. A press opens Calendar, or the app you chose with \"Choose app…\".",
            "New in 0.15: cancelled events and events you declined are left out. Before: a declined meeting could make you look busy."
        ]),
        Section(id: "deskKey", title: "Desk key", part: "keys", lines: [
            "New in 0.11. In Set up keys, under \"What it does\", choose \"Desk\". The key is blue with a window drawing. Without a title it says \"Desk\".",
            "The button \"Take the desk as it is now\" remembers the apps that have a window on screen right now: up to 8 apps, the front window of each, with its place and size. Small panels (under 200 × 150) are left out, and so are Deck Mate's own windows.",
            "The list shows each app with its window size, for example \"Safari · 1200 × 800\", and a button to take one out.",
            "A press opens every app of the desk and puts each one's front window back in its place and size. It waits up to about 8 seconds for an app that is still opening.",
            "It needs the Mac's Accessibility yes, the same one the shortcut, text and music keys use. The Mac asks at the first press if it was never given.",
            "A Desk key also works as a long press and as a step of \"Several things in a row\".",
            "A desk whose app is no longer on this Mac is marked as broken: \"An app of the desk is not on this Mac\". A desk with nothing in it says \"No windows taken yet\"."
        ]),
        Section(id: "macDo", title: "On the Mac keys", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"On the Mac\" and pick one of six things from the list. The key is purple, like a shortcut key.",
            "\"Lock the Mac\" locks the screen at once. You need your password or Touch ID to get back in.",
            "\"Show the desktop\" moves all windows aside so the desktop shows. A second press brings them back.",
            "\"Quit all apps\" quits every open app except the Finder, AMS Deck Mate itself and the apps you list under \"Stays open\". Use the button \"Add app…\" to add one; each has a remove button. New in 0.14: the list starts filled with the apps open at that moment (without the Finder and Deck Mate, which always stay), and the button \"Take the apps open now\" fills it again; remove what should quit. A key you already have is not changed by itself. It asks first on the Mac and names the apps, for example \"Quit 6 apps?\" with Quit and Cancel. An app with unsaved work still asks you itself.",
            "\"Empty the bin\" asks first and says how many things are in the bin, for example \"12 things will be gone for good. This cannot be undone.\" with Empty and Cancel. If your Finder is set to warn before emptying, the Finder asks once more after that. Take the tick off \"Ask first\" to see only the Finder's question. With an empty bin the key says so and does nothing. The first press makes the Mac ask once whether AMS Deck Mate may control the Finder. Choose Allow.",
            "\"Eject all disks\" asks first and names the disks, for example \"Eject 2 disks?\" with Eject and Cancel. It ejects every plugged-in disk, card, stick and disk picture. It never ejects the Mac's own disk and never a share on another computer. A disk that is still in use stays, and the key tells you which one. With no disk plugged in, it says so.",
            "For \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\" there is a tick \"Ask first\" (on at first). You can take it off, and the key then acts at once.",
            "When one of these three is pressed from the iPhone or iPad, the question opens on the Mac. Changed in 0.16: in the questions of \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\", Return and Escape both cancel. Before: Return did it. The action itself needs a click on its button.",
            "\"Paste as plain text\" pastes the text you copied without its font, size and colour. It needs the Mac's Accessibility yes, like shortcut keys. It still pastes a copy that a password manager marked as secret, because a paste stays on the Mac."
        ]),
        Section(id: "meetingKey", title: "Join the meeting key", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"Join the meeting\". The key is blue.",
            "A press opens the video link of your meeting. It takes the meeting that starts within ten minutes. If there is none, the one going on now. If there is none, the next one within a day.",
            "It finds links of Zoom, Microsoft Teams, Google Meet, Webex, FaceTime, Whereby, Jitsi and GoTo, in the event's link, its place or its notes. If no link is found, the key says so.",
            "It uses the same calendar yes as \"Next event\". It only reads and never changes an event.",
            "New in 0.15: cancelled events and events you declined are left out. Before: a declined meeting could be the one it joined."
        ]),
        Section(id: "playlistKey", title: "Spotify playlist key", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"Spotify playlist\" and paste a Spotify link. The key is green.",
            "The link can be a playlist, an album, an artist, a song or a podcast. In Spotify, use Share, then Copy link.",
            "A press starts it playing in Spotify. The first press makes the Mac ask once whether AMS Deck Mate may control Spotify. Choose Allow.",
            "A key without a proper Spotify link shows the red corner of a broken key.",
            "New in 0.14: the key shows the cover. Before: a green key with headphones. Now: once a link is pasted, the key shows the playlist's (or album's, artist's, song's or podcast's) own cover across the whole key. It is fetched once from Spotify's public look-up, the same one the Album cover key uses. Only the link is sent. The cover is kept.",
            "A key with a picture or a drawing you chose yourself keeps yours. With no internet, the headphones stay until it works."
        ]),
        Section(id: "searchKey", title: "Search for the copied text key", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"Search for the copied text\". The key is teal.",
            "A press opens your browser with a search for the text you copied last. Choose the search site: Google (at first), DuckDuckGo, Bing, Wikipedia or YouTube.",
            "A copied web address opens as it is. Of a long text only the first 300 letters are searched. If nothing is copied, nothing happens. New in 0.15: a copy that a password manager marked as secret counts as nothing copied: the Mac beeps and nothing is searched.",
            "The text goes only to the search site you picked."
        ]),
        Section(id: "counterKey", title: "Counter key", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"Counter\". The key is amber.",
            "Every press counts one more, shown as a large number on the key. It stops at 99,999.",
            "Hold the key down (a long press) to set it back to 0.",
            "The number is kept when the Mac restarts. Each counter key has its own number."
        ]),
        Section(id: "stopwatchKey", title: "Stopwatch key", part: "keys", lines: [
            "New in 0.13. In Set up keys, under \"What it does\", choose \"Stopwatch\". The key is amber.",
            "A press starts it and the key shows the time running. Another press pauses it. The next press goes on.",
            "Hold the key down (a long press) to set it back to 0.",
            "It keeps running when AMS Deck Mate restarts. Each stopwatch key has its own time."
        ]),
        Section(id: "paragonKeys", title: "PARAGON keys", part: "keys", lines: [
            "New in 0.14. In Set up keys, under \"What it does\", choose \"PARAGON\" and pick one of four things from the menu (five since 0.16: see \"Now on my plan\"). The key is purple, like a shortcut key.",
            "\"Inbox\": the large words are the number of lines waiting in PARAGON's Inbox, with \"Inbox\" under it. A press opens PARAGON's Inbox.",
            "\"Next task\": the key shows the first task on PARAGON's list, the same one PARAGON's widget shows first. The large words say when it is due, for example \"today\" or \"2 days over\"; the task's own words stand small underneath. An overdue task turns the key red. A press opens that task's note in PARAGON. With nothing on the list the key says \"Nothing next\".",
            "\"Task from the copied text\": a press puts the text you copied last into PARAGON's Inbox as a task. PARAGON does not come to the front. If nothing is copied, or what you copied is not text, the Mac beeps and nothing is saved. New in 0.15: a copy that a password manager marked as secret counts as nothing copied: the Mac beeps and nothing is saved.",
            "\"Quick note\": a press opens a small window on the Mac, \"Note for PARAGON\", with one text field and Cancel and Save. Return saves and Escape cancels. Save puts the words into PARAGON's Inbox as a note line. PARAGON does not come to the front. Pressed from the iPhone or iPad, the window opens on the Mac.",
            "Where the numbers come from: each time PARAGON on the Mac reloads its notes, it writes a small file for its own widget. Deck Mate only reads that file, every 60 seconds. It never opens your notes folder and writes nothing there.",
            "So the numbers are as fresh as PARAGON's last reload on this Mac. If the file is from an earlier day, the key shows \"–\" and \"Open PARAGON\"; a press opens PARAGON, which writes the file anew. If PARAGON is not on this Mac, the key says \"No PARAGON\".",
            "Adding a task or a note uses PARAGON's own capture link, so nothing had to change in PARAGON. The Mac asks nothing new for these keys.",
            "Not changed: Deck Mate never reads or changes a task by itself. It only counts, shows and adds.",
            "New in 0.16: if PARAGON's little file carries a format number that is higher than Deck Mate knows (it knows 1; a missing number counts as 1), every PARAGON key and \"Due today\" show \"–\" and \"Update Deck Mate\" instead of wrong numbers. PARAGON itself has not been changed yet: it needs one small line for this in its next build, and until then the check never fires."
        ]),
        Section(id: "trainingKey", title: "Training today key", part: "keys", lines: [
            "New in 0.23. In Set up keys, under \"What it does\", choose \"Training today\" (it stands in the same group as the PARAGON kinds). The key shows today's training session from AMS Triathlon Training. It needs AMS Triathlon Training 2.8 or later, opened at least once that day. A press opens the session in AMS Triathlon Training. On an iPhone it can also log the session as done (see below).",
            "What the key says. A session to do: the planned length in large words, for example \"45 min\", and under it the sport and \"to do\", for example \"Run · to do\". With more than one session to do: \"Run · to do +1\" (one more waits). A session with no planned length: the sport in large words, for example \"Run\", and \"to do\" under it. The key is teal.",
            "All of today's sessions are done: \"Done\" in large words, the sport under it (or \"2 sessions\"), and the key turns green. Missed (nothing left to do, at least one missed): \"Missed\" in large words, the sport under it, and the key is grey-blue. A rest day: \"Rest\" in large words and \"Rest day\" under it, teal.",
            "No fresh facts: \"–\" in large words and \"Open Triathlon\" under it, grey-blue. This is so when AMS Triathlon Training was not opened today on any device Deck Mate can see, when its note is more than 36 hours old, or when the note is from another day. The key never shows yesterday's session, and it is never red.",
            "Two more cases. \"No Triathlon\": AMS Triathlon Training is not on this Mac and no iPhone has told Deck Mate anything. \"Update Deck Mate\": the note is in a newer format than this Deck Mate knows.",
            "What a press does. On the iPhone, in Deck Mate, when AMS Triathlon Training is on that iPhone and the session is today's, still to do and has a planned length: the press logs it as done, exactly as planned, the same as the button \"Done as planned\" in AMS Triathlon Training. AMS Triathlon Training comes to the front on the session's page, and that is your confirmation. On an iPhone the key then says \"Run · press for done\" under the length instead of \"Run · to do\". A second press is harmless.",
            "On the Mac, on the Stream Deck, on the iPad, and whenever logging is not possible, a press only opens the session in AMS Triathlon Training: on the device where you pressed, if AMS Triathlon Training is there, else on the Mac. Nothing is changed. The reason: only the iPhone can log sessions in AMS Triathlon Training. The Mac and iPad versions cannot.",
            "On the key \"–\" with \"Open Triathlon\", a press opens the Today page of AMS Triathlon Training. Once it has been opened, the key shows the session: within a minute on the Mac, and on the phone when Deck Mate comes to the front again.",
            "The pointer note on the keys on screen, and \"Explain\" on the iPhone and iPad, say the session's full name, for example \"Easy run, 45 min, to do. A press opens it in Triathlon Training.\" (on an iPhone that can log it: \"… A press logs it as done in Triathlon Training.\").",
            "Where the key gets its facts. AMS Triathlon Training writes a small \"today\" note with only: the sport, the session's name, the planned length, whether it is done, and this week's hours. Deck Mate only reads it. On the Mac it reads the file \"today-note.json\" in AMS Triathlon Training's own folder, once a minute, and only while such a key is on a page. The first time, the Mac asks whether AMS Deck Mate may access data from other apps. Click Allow (it is the same question as for PARAGON's file).",
            "On an iPhone or iPad, AMS Triathlon Training keeps the same note in the device's Keychain, in a group that both apps share, for this device only and never in iCloud. Deck Mate on the phone reads it when it connects to the Mac, when it comes to the front and once a minute, and tells the Mac over the private line. The Mac draws the key from the newest note it has, its own file or a phone's. So the Stream Deck also shows \"Done\" after you logged on the iPhone, as long as Deck Mate on the phone was open after it.",
            "For a press on the phone, the Mac answers with the link to open. The phone opens a link only if it starts with \"amsworkoutsync://\", only within 3 seconds of a press on that phone, and only if the link is in the phone's own note (or is the Today page).",
            "Older apps: a Deck Mate on the phone before 0.33 still shows the key (the Mac draws it), but a press there always opens the session on the Mac. A Mac before 0.23 does not know this kind of key.",
            "Your keys file keeps its format (3). The key is saved as the kind \"training\" with the target \"today\". An older Deck Mate keeps a key it does not know as it is. No key was added to your pages: place it yourself in Set up keys. (The built-in sample deck, shown on a Mac without keys of its own, has one.)",
            "Not changed: Deck Mate never changes anything in AMS Triathlon Training by itself. It reads the note, and it logs a session only when you press the key on the iPhone."
        ]),
        Section(id: "stewardKey", title: "Steward: to decide key", part: "keys", lines: [
            "New in 0.25. In Set up keys, under \"What it does\", choose \"Steward: to decide\" (it stands in the group \"At a glance\", beside \"Training today\"). The key shows how many bank rows wait in AMS Financial Steward's To decide. It needs AMS Financial Steward 0.21 or later, opened at least once in the last 36 hours. A press opens AMS Financial Steward at To decide.",
            "What the key says. Rows wait: the number in large figures, for example \"12\", and \"to decide\" under it. The key is amber. Nothing waits: \"0\" in large figures and \"all decided\" under it, and the key turns green.",
            "No fresh count: \"–\" in large words and \"Open Steward\" under it, grey-blue. This is so when Steward has not counted for 36 hours, or never. The key never shows an old number as if it were fresh, and it is never red.",
            "Two more cases. \"No Steward\": AMS Financial Steward is not on this Mac. \"–\" with \"Update Deck Mate\": the note is in a newer format than this Deck Mate knows.",
            "On the key \"–\" with \"Open Steward\", a press opens AMS Financial Steward at To decide as well. Once Steward has counted, the key shows the number: within a minute.",
            "The pointer note on the keys on screen, and \"Explain\" on the iPhone and iPad, say it in words, for example \"12 bank rows wait in Steward’s To decide. A press opens Steward’s To decide.\" On \"No Steward\" a press only beeps.",
            "Where the key gets its facts. AMS Financial Steward 0.21 leaves a tiny note with ONLY the count and the time: no amounts, no names. Deck Mate only reads it. On the Mac it reads the file \"deck-note.json\" in AMS Financial Steward's own folder, once a minute, and only while such a key is on a page. The first time, the Mac may ask whether AMS Deck Mate may access data from other apps. Click Allow (it is the same question as for the files of PARAGON and AMS Triathlon Training). The key never writes there.",
            "The colour says something (amber, green, grey-blue), so this key shows no colour well in Set up keys, like the other glance keys (see \"Set up keys\").",
            "The iPhone and iPad show the key as a picture drawn by the Mac, so they need no update. A press there is carried out by the Mac.",
            "Your keys file keeps its format (3). The key is saved as the kind \"steward\" with the target \"waiting\". An older Deck Mate keeps a key it does not know as it is. No key was added to your pages by the app: place it yourself in Set up keys. (In the owner's own keys, the key \"To decide\" on the page group \"Steward\" is this key.)",
            "Not changed: Deck Mate never changes anything in AMS Financial Steward. It reads the count and opens the app."
        ]),
        Section(id: "focusKey", title: "Focus rounds key", part: "keys", lines: [
            "New in 0.14. In Set up keys, under \"What it does\", choose \"Focus rounds (PomoTimer)\". The key is amber while nothing runs.",
            "The menu offers PomoTimer's five ready-made plans: Classic Pomodoro (2 + 3 + 25 + 5 + 25 + 5 minutes), Four Pomodoros, Deep Work 50/10, Short Burst and Single Pomodoro. Your own templates come after the button \"Read my templates from a PomoTimer backup file…\". Choose the backup file PomoTimer saves. It is read once and kept in Deck Mate. Press the button again after you change templates in PomoTimer.",
            "A press opens AMS PomoTimer in the browser and starts that template there. The key counts along: the step's name (\"Pomodoro\", \"Pause\") and the minutes and seconds left. Changed in 0.15: it is purple during focus steps (before: red), green during pauses and long breaks, and amber during start-up, preparation and cool-down. At the end it shows \"Done\" for 60 seconds.",
            "While it runs, a press brings PomoTimer back to the front. A long press stops the count on the key. It does not stop PomoTimer.",
            "Only one focus run at a time. It goes on after Deck Mate restarts.",
            "Good to know: the key counts by itself from the moment of the press. If you pause or skip a step in PomoTimer, the key does not know. A template set to wait between steps in PomoTimer runs ahead on the key.",
            "The session lands in PomoTimer's history as always. Nothing had to change in PomoTimer."
        ]),
        Section(id: "dropKey", title: "Drop it on a key", part: "keys", lines: [
            "New in 0.15. In Set up keys, drag an app, a file or a folder from the Finder, or a web address from the browser, onto an EMPTY key. The key is made for you and opens for editing.",
            "An app gives an app key with the app's icon and name. A file or a folder gives a key named after it. A web address gives a link key named after the website.",
            "A key that already does something is never replaced by a drop. Only empty keys take one.",
            "Command-Z takes a drop back. Before 0.15 a key had to be filled in by hand: pick \"What it does\", then find the app or file."
        ]),
        Section(id: "linksKey", title: "Press keys from Raycast and by link", part: "settings", lines: [
            "New in 0.15. In Settings there is a new part, \"Raycast and links\". Before: a key could only be pressed from the box, the keys on screen, the iPhone, the iPad and the keyboard. Now it can also be pressed from Raycast, and by a link.",
            "Deck Mate keeps a folder of small commands: one for every key that has words and does something. Keys that only move around (Back, folders, page keys) get none. The folder is written again whenever your keys change.",
            "Once Raycast knows the folder, every key can be found and pressed by its name in Raycast. It is listed under \"Deck Mate · <page group> › <page>\". Raycast learns the folder once: in Raycast, open Settings › Extensions › Script Commands › Add Directories and choose it. Settings has the button \"Show the folder\".",
            "A key pressed this way does its job wherever it sits. The keys on screen and the box do not move, except for a \"Switch page group\" key, which does switch.",
            "Links also exist, for your own use: press a key, show a page group, and show or hide the keys on screen.",
            "New in 0.20: a key that has a double press can be pressed twice from outside too. In a link, add \"&twice=1\" to the press link: it runs the double-press action at once, with no waiting. Before: only the usual action and, with \"&hold=1\", the long press could be pressed this way.",
            "Every link carries this Mac's own pass: a random word made on this Mac. So a web page or another program cannot press your keys.",
            "Pressed this way, \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\" always ask first, also when the key says \"without asking\".",
            "A switch in the same part of Settings turns the whole thing off. The folder of commands then goes away.",
            "New in 0.16: Apple's Shortcuts app can press keys too. See \"Actions for Apple's Shortcuts app\"."
        ]),
        Section(id: "breathKey", title: "Breathing pacer key", part: "keys", lines: [
            "New in 0.16. In Set up keys, under \"What it does\" and the heading Time, choose \"Breathing pacer\". The key is green, like the music keys.",
            "Before the first press it shows its drawing and the word \"Breathe\". A press starts a round. A second press stops it.",
            "While it runs, a white rounded column fills from the bottom while you breathe in and empties while you breathe out. The small words say \"Breathe in\" or \"Breathe out\". The key changes once a second.",
            "After the last breath the key goes back quietly. There is no sound, no \"Done\" and no numbers.",
            "In Set up keys you choose the rhythm: 4 in · 6 out (at first), 4 · 4, 5 · 5 or 4 in · 8 out. And the number of breaths: 6 (at first), 10 or 20.",
            "It shows on the box, on the keys on screen and on the iPhone and iPad (the Mac draws it). The round is kept in memory only, so it is gone when the app quits."
        ]),
        Section(id: "barKey", title: "Progress bar across keys", part: "keys", lines: [
            "New in 0.16. In Set up keys, under \"What it does\" and the heading Time, choose \"Progress bar (part of a row)\". Put several of them side by side and they make one bar.",
            "The bar fills from left to right with the whole focus round that runs (purple). With no focus round it fills with the timer that ends last (amber). With nothing running the parts are empty: dark, with a thin outline.",
            "When a bar key is picked, Set up keys shows the button \"Fill this row with the bar\". It turns the EMPTY places of that row into bar parts and numbers them. A key that is there is never replaced.",
            "A key is redrawn only when its whole percent changes, so the bar costs almost nothing."
        ]),
        Section(id: "oftenKey", title: "Often used keys", part: "keys", lines: [
            "New in 0.16. In Set up keys, under \"What it does\" and the heading Open, choose \"Often used key\" and pick \"1 (most)\", 2, 3, 4 or 5.",
            "The key shows the picture and words of the key you press most (1), second most (2), and so on, and a press presses that real key. The press is counted for the real key. Before it has one, it shows its drawing and the word \"Not yet\".",
            "Only keys pressed in the last 30 days count, the one with the most presses first. Folders, Back, page keys, page group switches, other often used keys and keys that only show something are left out.",
            "The button \"Add an “Often used” folder\" (under the \"Add an “Open apps” folder\" button) puts a folder key \"Often used\" on the first free place. Inside are Back and five often used keys. A full page says so and changes nothing."
        ]),
        Section(id: "planKey", title: "Now on my plan", part: "keys", lines: [
            "New in 0.16. In Set up keys, under \"What it does\", choose \"PARAGON\" and then \"Now on my plan\". The key is purple, with the short title \"My plan\".",
            "During a block of your plan the large words are the end time, for example \"14:30\", and the small words say \"until <name>\". Between blocks the large words are the next block's start and the small words its name.",
            "With nothing more planned the key says \"Free\" and \"Nothing more planned\".",
            "A press opens Today in PARAGON.",
            "It reads the plan from PARAGON's own little file, like the other PARAGON keys, and shares their limits (see \"PARAGON keys\")."
        ]),
        Section(id: "newKeyFrom", title: "New key from…", part: "keys", lines: [
            "New in 0.16. In the menu bar menu, \"New key from…\" offers up to three choices with their names: \"App: <name>\" (the app in front), \"Link: <web address>\" (a web address you copied; a copy a password manager marked secret is never used) and \"File: <name>\" (the file you opened last; only offered while a \"Recent file\" key exists somewhere).",
            "With nothing to offer the line is grey and says \"Nothing to make a key from yet\".",
            "The key goes on the first empty place of the page showing now. Command-Z in Set up keys takes it back. A full page says \"This page is full.\" and nothing is changed."
        ]),
        Section(id: "suggestKey", title: "The deck suggests a key", part: "settings", lines: [
            "New in 0.16. In Settings › Key use, one calm card sits on top: \"A key for <app>?\" with \"You used it on 9 of the last 14 days and it has no key.\" (the numbers are an example).",
            "\"Add a key\" (full colour) makes the key and says where it went, for example \"Added as key N on …\". \"Not this one\" (quiet) is remembered for good.",
            "The rule: the app you used on the most days, at least 5 of the last 14. Never an app that has a key, is a favourite or has its own page group, and never Deck Mate or the Finder.",
            "Deck Mate counts only the days, in a small file \"apps.json\" beside the keys file. No badge and no notification appear anywhere."
        ]),
        Section(id: "pdfKeys", title: "Save your keys as a PDF", part: "keys", lines: [
            "New in 0.16. In Set up keys, \"All pages\" has the button \"Save as PDF…\".",
            "The file shows every page group with its pages as small pictures and names, on A4 pages with page numbers. The suggested name is \"Deck Mate keys.pdf\". The file opens afterwards."
        ]),
        Section(id: "hoursGroup", title: "Hours for a page group", part: "profiles", lines: [
            "New in 0.16. In Set up keys, in the column of page groups, under \"Use with apps\", tick \"Show at these hours\" and set from and to. At first it says 06:00 to 09:00. The time may pass midnight.",
            "The grey words say: \"In these hours it shows instead of the default page group, for apps that have no page group of their own. An app’s own page group, and one you picked by hand, always stay.\"",
            "Deck Mate looks when the front app changes, once a minute, and at wake. \"Duplicate page group\" does not copy the hours."
        ]),
        Section(id: "eveningBox", title: "Dimming the box in the evening", part: "box", lines: [
            "New in 0.16. In Settings › The box, under Brightness, tick \"Dim in the evening\" (off at first).",
            "Then it says \"From 21:30 to 07:00\" (you can change both; the time may pass midnight) and an \"Evening brightness\" slider from 5 to 100, at first 20 %. In those hours the box takes the evening brightness.",
            "Deck Mate looks once a minute, at start, at wake and when a setting changes.",
            "Not yet tried on the real box."
        ]),
        Section(id: "shortcutsActions", title: "Actions for Apple's Shortcuts app", part: "settings", lines: [
            "New in 0.16. Apple's Shortcuts app now has three actions from Deck Mate: \"Press a Deck Mate key\", \"Show a Deck Mate page group\" and \"Show or hide the Deck Mate keys on screen\".",
            "\"Press a Deck Mate key\" lets you pick the key from a list of the keys that have words and do something. Each is shown as \"page group › page\". \"Show a Deck Mate page group\" does not lock it.",
            "\"Quit all apps\", \"Empty the bin\" and \"Eject all disks\" always ask first.",
            "When the switch in Settings › Raycast and links is off, the actions say: \"Pressing keys from outside is switched off. Switch it on in AMS Deck Mate: Settings › Raycast and links › “Keys can be pressed from Raycast and by link”.\"",
            "Not yet tried from the Shortcuts app itself."
        ]),
        Section(id: "myAmsApps", title: "My AMS apps", part: "profiles", lines: [
            "New in 0.16. The + beside \"Page groups\" in Set up keys has a new ready-made page group, \"My AMS apps – 12 link keys\".",
            "Its keys: AMS Tidy Bar (show or hide, show, hide, arrange), Shopping (scan, trip), PARAGON (Inbox, Today, Overdue, Review, Plan) and Seedboard (opens the app).",
            "Left out because those apps have no such link: PARAGON's start and close the day, Shortcut Overview and Apps Overview.",
            "It follows the same rules as the other ready-made page groups: nothing you have is changed, and Undo takes it back."
        ]),
        Section(id: "raycast", title: "Raycast keys", part: "raycast", lines: [
            "A folder of Raycast commands is a good start: one key \"Raycast\" that opens a page with Back and your favourite commands.",
            "Pick a command from a list. It holds the commands of the Raycast extensions on this Mac, found by itself, and 16 of Raycast's own.",
            "A command from an extension now shows that extension's own icon, taken from the extension installed on this Mac. Raycast's own commands keep the hand-drawn drawings.",
            "Two of Raycast's own links were corrected: AI Chat and Search Quicklinks. The other built-in links could not be checked from this Mac. If one does not work, use \"Copy Deeplink\" in Raycast and paste it.",
            "Or paste any Raycast link: in Raycast select a command, press Command-K and choose \"Copy Deeplink\".",
            "A script command goes on a key by its name, and an AI command by its name.",
            "\"Run quietly\" runs a command without bringing Raycast forward.",
            "The first time a key runs a command, Raycast asks once. Choose \"Always open command\".",
            "Raycast has no door for quicklinks and snippets from outside. Use \"Open a link\" for a quicklink and \"Type text\" for a snippet.",
            "New in 0.16: a key whose Raycast command is no longer on this Mac shows a red corner and says \"This Raycast command is not on this Mac\". Before: nothing happened when you pressed it. Raycast's own commands, script commands and AI links are never marked this way."
        ]),
        Section(id: "hubs", title: "Hubs: start screens", part: "profiles", lines: [
            "New in 0.26. A Hub is a start screen. Any page group can be marked as a Hub: in Set up keys, in the page group's settings (left column), use the new switch \"Hub — a start screen\". Before: there was no such switch.",
            "Your keys now have two Hubs. \"Now\" is where Deck Mate always starts: four pages, Live, My apps, Mac apps and Do. \"Life\" has four pages too: Training & health, Money & home, Work & focus and Mac, which holds every one of your apps.",
            "On an iPad held on its side with \"Several pages at once\" on, a Hub shows all its pages at once (up to four). Any other page group, for example an app's page, shows ONE page with the biggest keys. The Favourites stay in their column on the right, with the Hub key under them. An app page with more pages: swipe sideways, or press its \"More keys\" key (it stands in the last place), to get to the next one.",
            "The Hub key stands under the Favourites, where the \"Pages\" key was, and only when your keys have a Hub. Without Hubs the \"Pages\" key stays as before. On an app page it says \"Hub\" and goes to the first Hub (Now). On a Hub it says \"→ Life\" or \"→ Now\" and goes to the other Hub. Hold it for the list of all page groups, as you did with the \"Pages\" key. The navigation picture still comes in with a pull from the far left edge (the thin purple line).",
            "Swipe sideways on a Hub and you are on the other Hub.",
            "Following the Mac is unchanged. An app with its own page group comes to the front: its page shows. Another app comes to the front: the start Hub (Now) shows. A page you picked by hand stays while you move between apps that have no page group of their own.",
            "Hold an app key on a Hub and you see that app's page, without bringing the app forward on the Mac. This is set for each key as its long-press action (see \"Long press: a second action\").",
            "The iPhone, the Stream Deck box and the Mac's keys on screen are unchanged. A Hub shows there as a normal page group, one page at a time.",
            "Your keys were rebuilt for this (an example, not a feature of the app; it lives in your keys file, and a copy of your old keys is in Backups). New: the Hubs Now and Life, and the app pages PARAGON, Seedboard, Raycast, Alfred and Notion (WET and Daily Tracking are now one page). The pages Steward, Triathlon and Claude follow the same places: Settings in the bottom row and \"More keys\" in the last place. The old \"AMS Deck\" home key is gone, because the Hub key does its work. Removed at your wish: the old AMS Deck group (Home and its folders), OmniFocus and the Elgato tutorial page.",
            "The iPad parts are in the iPhone and iPad app 0.35 (build 41)."
        ]),
        Section(id: "profiles", title: "Page groups change by themselves", part: "profiles", lines: [
            "New in 0.26: Hubs are start screens (see \"Hubs: start screens\"). Another app than one with its own page group shows the start Hub (Now). Following the Mac is otherwise unchanged.",
            "When an app that belongs to a page group comes to the front, the keys change to that page group. Any other app shows the default page group.",
            "A page group you pick by hand stays while you move between apps that share a group. It changes when you go to an app with another group.",
            "New in 0.24: a page group made for one app can wear that app's own colours, by giving its keys colours of their own (see \"Set up keys\"). Example: a page group \"Steward\" for AMS Financial Steward, with one key for each part of Steward in that part's colour, and a page group \"Triathlon\" for AMS Triathlon Training. They show by themselves when that app is in front, like any page group that belongs to an app.",
            "Picking a page group in the menu locks it: a small lock shows beside its name on the keys on screen (since 0.4.2), and it stays until you choose \"Automatic\". You can switch the automatic change off in Settings.",
            "Since 0.7.1: when you swipe up or down on the keys of the iPhone or iPad, that device shows the next or previous page group, but it does not lock it. The Mac goes back to following the app in front, and if a group was locked, the swipe unlocks it. Picking a group in the iPhone's or iPad's Settings, or tapping a page in the navigation picture, still locks. This needs the iPhone or iPad app at 0.10.1; with an older app a swipe still locks."
        ]),
        Section(id: "bringover", title: "Bringing over your Elgato keys", part: "profiles", lines: [
            "At first start the app reads the keys from Elgato's app for the 15-key box: apps, links, shortcuts, typed text, music keys, folders, pages, several-things keys and which app a page group belongs to.",
            "Left out are the Zoom profile, the two Final Cut profiles, and keys of kinds Deck Mate does not have. A folder that would be left empty is left out too.",
            "Elgato's files are only read, never changed. Elgato's pictures are not taken over: every key is redrawn in the new look.",
            "\"Bring over again\" in Settings repeats it. It asks first, and your current setup is kept as a safety copy."
        ]),
        Section(id: "box", title: "The box", part: "box", lines: [
            "Plug it in and the keys light up. Settings shows \"Connected\" with the box's name and serial number, and a brightness slider.",
            "Elgato's own app should be quit while Deck Mate drives the box, because both apps would otherwise draw on the keys. (Before 0.15 this said it must be quit, because only one can hold it. That is not proven.)",
            "Settings warns you when Elgato's app is running and has a \"Quit Elgato's app\" button.",
            "When Deck Mate quits, the box goes back to the Elgato logo.",
            "New in 0.15, not yet tried on the real box: after the Mac or its screen wakes, the brightness and all 15 pictures are sent again. Before: nothing was sent again, so a box that went dark could stay dark.",
            "New in 0.16, saving power: keys that nobody sees rest. One clock wakes only when a key needs a new picture. Seconds tick only while the page showing now has a timer, focus, stopwatch, breathing or bar key, or an iPhone or iPad is connected. Otherwise it looks once a minute and at the end of a timer. App names are remembered, not looked up for every picture. A 25-minute timer changes its picture 84 times, instead of 1,500.",
            "New in 0.16: the check every 4 seconds (may it press keys, does Elgato's app run) and the look every 5 seconds for the iPhone's music plate pause while the Mac's screen sleeps, and run once at wake.",
            "New in 0.16: every small script the app runs (dark mode, mute, Spotify, the Finder's bin, eject) has a time limit of 5 seconds (60 seconds for the Finder's \"empty the bin\", so its own question can be answered) and runs away from the app's main work. Before: Spotify, the Finder and the calendar could wait behind each other. The Mac's volume for the iPhone's music plate is read directly, not by a script every 5 seconds.",
            "New in 0.16: typed text keeps emoji whole (it is cut only between whole characters), and a long text no longer holds the app up. When you quit, the app waits at most 1 second for a box that does not answer. Before: no limit."
        ]),
        Section(id: "firsttime", title: "First time with the box", part: "box", lines: [
            "This part of Settings is for the first day with the real box, which is not yet tried.",
            "Step 1: quit Elgato's app. Step 2: plug the box in. Step 3: if the Mac asks for Input Monitoring, allow it.",
            "It shows the box's answer in plain words, and a button to show the box diary (the box log), in case something does not work.",
            "New in 0.15: the box diary also notes the last digits of the box's serial number, the first picture sent (its size, and whether it was sent) and the first key heard (which place, down or up). It also says what to do if no key press shows up."
        ]),
        Section(id: "iphone", title: "On your iPhone", part: "settings", lines: [
            "Deck Mate for the iPhone shows the same 15 keys as the box, in the same places and with the same pictures. It follows the page group and page the Mac shows, so it changes when the app in front changes.",
            "Tap a key on the iPhone and the Mac does it, exactly as if you had pressed it on the box. The keys on the Mac screen do not hide because of a tap on the iPhone.",
            "The iPhone finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" and shows a 4-digit number. The iPhone shows the same number. Choose Allow only if both numbers are the same. After that the Mac remembers the iPhone. If you choose Don't Allow, the iPhone shows \"Ask again\".",
            "Allow takes a click with the mouse: Return and Escape both mean \"Don’t Allow\".",
            "Since 0.8 the link between the Mac and the iPhone or iPad is private: everything is scrambled from the first moment, so on a shared Wi-Fi nobody can listen in or press your keys. Mac 0.8 needs the iPhone and iPad app at 0.11 or later.",
            "The pictures are drawn by the Mac, so keys that open an app show the real app icon.",
            "New in 0.4 (the Mac must be at 0.4 too): the keys sit low on the iPhone, near your thumb, with the place line on top. Swipe left or right on the keys to change page. Small dots under the keys show which page you are on. There are no dots inside a folder or when there is one page.",
            "Tap the top line (the name of the page group) for a menu: \"Automatic\", or hold one of the page groups, the same as the Mac's menu.",
            "A key you press lights up on the iPhone, whether you pressed it on the box, on the keys on the Mac screen or on the iPhone.",
            "After a tap, a short note at the bottom says what ran, for example \"Opened Mail\" or \"Raycast: Clipboard history\". If the Mac could not do it, the note is red with a warning drawing, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "The iPhone screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "After 20 seconds of \"Looking for your Mac…\" a card explains: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. It has the button \"Open Settings\" and a close (x) button that hides the hint.",
            "If the iPhone says \"Looking for your Mac…\": check that the Mac app is open, that Wi-Fi and Bluetooth are on, that the iPhone is close to the Mac, and that Local Network is allowed for Deck Mate in the iPhone's Settings, Privacy & Security, Local Network.",
            "New in 0.7 (the Mac at 0.7 and the iPhone or iPad app at 0.9): the Mac tells a connected iPhone or iPad when its screen goes to sleep and when it wakes. With the switch \"Dark while the Mac sleeps\" in the iPhone's or iPad's Settings (on at first), the device goes black with a small moon and \"Mac asleep\", may lock itself, and brightens when the Mac wakes. One tap shows the keys again. The \"Recent app\" and \"Ask AI\" keys show and work on the iPhone and iPad too, drawn by the Mac.",
            "New in 0.5 (the Mac at 0.5 and the iPhone or iPad app at 0.7 together): own keys, the favourites row, the Mac at a glance and the music strip (today a small music button; see below). See the next part.",
            "New in 0.15 (the Mac at 0.15 and the iPhone or iPad app at 0.17): the Mac sends only the keys that look different. With a running timer, stopwatch or focus round, one small picture arrives each second, instead of all fifteen (about 300 KB). The iPhone or iPad asks \"are you there?\" every 5 seconds and the Mac answers. The Mac closes the line of an iPhone or iPad it has not heard from for 20 seconds, and the device then looks for the Mac again. With the app at 0.16, everything works as before.",
            "New in 0.17 (the Mac at 0.17 and the iPhone or iPad app at 0.19): \"Several pages at once\", for using the iPhone or iPad without the box. With the switch on in the phone's Settings, Showing, the iPhone shows 2 pages side by side (30 keys) and the iPad 4 pages (60 keys), each with its page name above it. The first page is the page you are on; the others are the next pages of the same page group. It goes round: after the last page it continues with the first. In a folder, the folder shows first and its own top page is not repeated. A page without a name shows as \"Page 2\", \"Page 3\" and so on. (Since 0.17.1 folders can fill empty spots, see below.) A tap on any key does what that key does. The Mac sends all of them: it understands link version 9 (the new, longer way the Mac and the phone talk). With an older phone, everything works as before. The box, if it is plugged in, keeps showing just the first page, and so do the keys on screen on the Mac. New in 0.17.1 (the Mac at 0.17.1 and the iPhone or iPad app at 0.19.1): when the page group has fewer top pages than the device shows, its folders fill the empty spots, in their order in Set up keys; so \"AMS Deck\", with only the page Home and some folders, shows Home, Apps, Tutorials and Raycast on an iPad (before: only Home). A Back key on a folder shown this way goes to the page the folder belongs to, which then becomes the first page. The phone also arranges the pages in whichever way gives the biggest keys (2 pages on an iPad sit one above the other, 3 pages may sit two above one). The Mac decides which pages show, so this needs the Mac at 0.17.1. New in 0.19: you can place the pages yourself in Set up keys, see \"Choose which pages show together\" above."
        ]),
        Section(id: "iphonenew", title: "On your iPhone and iPad, 0.5", part: "settings", lines: [
            "My own keys. In Settings on the iPhone or iPad, the new card \"Keys\" is at the top. \"Follow the Mac\" is as before: it shows the page group and page the Mac shows. \"My own keys\": pick a page group, and the iPhone or iPad then moves through that group on its own: pages, folders and Back, at its own place.",
            "With own keys, the Mac's keys on screen and the box stay where they are. A tap on the iPhone still makes the Mac do what the key says. Keys pressed elsewhere do not light up on a device with its own keys.",
            "Swipe up or down, or use the menu in the top line, to change your own page group. It is remembered on the device. With own keys there is no lock and no \"Automatic\" in that menu. If the group you picked is gone, the default group shows.",
            "The Mac keeps one place for each connected device, for as long as it is connected. After it connects again, the device starts at the first page of its group.",
            "The favourites row: 5 keys under the 15 that stay on every page and every page group. A switch \"Favourites row\" in Settings (on at first). It shows only when at least one favourite is set.",
            "Long press works on the iPhone and iPad too: hold a key with a white dot for half a second. You feel a stronger buzz.",
            "New in 0.20: the double press works on the iPhone and iPad too: tap a key with a \"×2\" twice within a third of a second. The Mac does the waiting, so an iPhone or iPad app 0.31 gets the double press too.",
            "New in 0.20 (Mac) with the iPhone and iPad app 0.32: a button \"Explain\" on the phone says in words what a key does, without pressing it. The Mac sends the words, so the button needs this Mac at 0.20. See \"What a key says it does\" below.",
            "Mac at a glance. Today (since the app 0.14) the iPhone or iPad shows one small pill with the name of the app in front on the Mac, for example \"Safari\". The Mac's battery was dropped from it. A switch \"Mac at a glance\" in Settings (on at first).",
            "Music button. Since the app 0.13 there is one small round music button, beside the settings button, that opens a plate with song and artist, play or pause, next, quieter, the volume in percent, and louder. One tap on quieter or louder moves the volume by 6 points. It works with Spotify and Apple Music. A switch \"Music button\" in Settings (on at first). Before, this was a strip above the keys.",
            "The plate says \"Nothing playing yet\" until the next change of song or pause after the Mac app has started, because the Mac hears about it from the player only when something changes.",
            "Play or pause and next use the same one-time Accessibility permission on the Mac as music keys. Volume needs no permission.",
            "The Mac looks at its volume every 5 seconds, but only while such a device is connected.",
            "Older versions. These new parts need the Mac at 0.5 and the iPhone or iPad app at 0.7. An iPhone or iPad at 0.7 with an older Mac works as before: its Settings say \"Needs AMS Deck Mate 0.5 on the Mac\" in the Keys card, and the new parts stay hidden. A Mac at 0.5 with an older iPhone app works as before, and the white dot still shows on the key pictures.",
            "Not yet tried: long press on the real box, long press on the real iPhone and iPad, and play or pause from the strip.",
            "New in 0.6 (the Mac at 0.6 and the iPad app at 0.8): on an iPad held on its side, the keys sit on the right and a navigation picture on the left shows every page group with every page and folder as a small picture of its 15 keys. Tap one and the keys go there. When the iPad follows the Mac, the Mac goes there too and that page group is locked until you choose \"Automatic\". With own keys only the iPad's own place moves. A switch \"Navigation picture\" in the Keys card in Settings turns it off. The Mac draws the pictures. With an older Mac it stays hidden."
        ]),
        Section(id: "iphonecard", title: "The iPhone card in Settings", part: "settings", lines: [
            "In the Mac's Settings there is a card \"iPhone\".",
            "The checkbox \"Let an iPhone use these keys\" is on to start with. Switch it off and no iPhone can use your keys.",
            "Under it you see the iPhone that is connected right now, and the list of allowed iPhones. \"Forget\" next to one takes the permission back. That iPhone has to ask again.",
            "Since 0.8, every iPhone and iPad that used the Mac before has to be allowed once more, with one click on the Mac. After that it is as before.",
            "The first time, the Mac may ask to \"find devices on local networks\". That is this feature. Answer Allow.",
            "New in 0.15: strangers on the same Wi-Fi. A device you have not allowed is asked about once per connection (before: again and again). At most 3 such devices are connected at once, and at most 2 wait to be asked about. A stranger's line is closed after 30 seconds, unless you are being asked about it right now. The window \"wants to use your keys\" closes by itself when that device goes away. After three \"Don't Allow\" within 10 minutes, nobody new is asked about for a while. The Mac reads nothing larger than a few lines of text from a phone. Your own iPhone and iPad, already allowed, always find room.",
            "New in 0.15: a hidden door is closed. Before, the app had a door meant for checks, through which other programs on the Mac could press keys by a message. The app as you use it now listens to nothing of the kind.",
            "New in 0.16: the secret of each allowed iPhone or iPad now lives in the Mac's Keychain (its safe for passwords), one entry for each device, instead of in the app's settings. The names stay in the settings. It moves over by itself and never shows a password window. If the Keychain cannot be used, the secret stays where it was and a note goes into the box diary. \"Forget\" removes it. Not yet proven across a future new build of the app."
        ]),
        Section(id: "signs", title: "Signs in this app", part: "settings", lines: [
            "Marks and colours on the keys, the keys on screen and the screens of this app, each with one meaning. If you meet a mark that is not here, it is a bug.",
            "Small red triangle in a key's top right corner: that key is broken. Its app, file, folder, Raycast command, folder page or page group is gone. \"Check keys\" lists it.",
            "Small white dot in a key's top right corner: the key has a long-press action. Hold it for half a second.",
            "Small white \"×2\" in a key's top right corner (new in 0.20): the key has a double press. Press it twice within a third of a second. It sits to the left of the place of the dot, and a key can show both.",
            "Small round white mark with a letter or number in a key's top left corner (1 to 5, Q to T, A to G): the key can be pressed with that letter right now. It shows only on the keys on screen and only while they have the keyboard.",
            "White frame round a key in \"Set up keys\": the key you are editing.",
            "Small lock in the top line of the keys on screen: the page group is locked. It stays until you choose \"Automatic\" in the menu.",
            "Words in the top line of the keys on screen: \"Search\" (find a key by its name), \"Set up\" (opens Set up keys) and \"Hide\" (closes the keys on screen and takes nothing away). They are words, not pictures. Hide has no cross.",
            "Numbers 1 to 4 in the box \"Several pages at once\" in Set up keys: the place on an iPad on its side (1 top left, 2 top right, 3 bottom left, 4 bottom right). An iPhone shows 1 and 2. They are places, not a count.",
            "Cross in Set up keys (beside an app, a page or a key): remove it. The cross means \"remove\" and nothing else anywhere in this app.",
            "\"+ Page group\" (beside \"Page groups\") adds a page group. \"+ Page\" (after the page names) adds a page to the page group you are in. They are two different buttons with two different words.",
            "Words with a degree sign on a key, \"Chip 56°\" (new in 0.21): the Mac's chip temperature in whole degrees, read from AMS Fan Menu. \"Chip –\" means there is no fresh reading (AMS Fan Menu is not running, or is older than 0.6). It is a figure, not a switch, so this key has no switch mark; the switch mark keeps its one meaning, filled = on, outline = off.",
            "Words with a number on a key, \"Fans 1,650\" (new in 0.22): the speed of the faster fan in turns per minute, read from AMS Fan Menu. \"Fans off\" = every fan stands still. \"Fans –\" = there is no fresh reading (AMS Fan Menu is not running, or is older than 0.6). It is a figure, not a switch, so this key has no switch mark either; the switch mark keeps its one meaning, filled = on, outline = off.",
            "Green \"Done\" on a \"Training today\" key (new in 0.23): all of today's training sessions are done. Green is used here as on the other keys, for good and all fine. Teal key = a session to do or a rest day. Grey-blue key = nothing fresh to show (\"–\" and \"Open Triathlon\", never yesterday's session) or nothing left to do and one missed (\"Missed\"). It is never red.",
            "\"+1\" behind the words on a \"Training today\" key, \"Run · to do +1\" (new in 0.23): one more session waits today. \"–\" in large words: nothing fresh to show, a press opens AMS Triathlon Training.",
            "Amber, green or grey-blue on a \"Steward: to decide\" key (new in 0.25): amber = bank rows wait in To decide (the number in large figures), green = \"0\" and \"all decided\", grey-blue = no fresh count (\"–\" and \"Open Steward\", or no count for 36 hours). It is never red.",
            "Words on a fan key (changed in 0.20): \"Cool · 8 min\" on the key that is on means the minutes left; \"Cool 10 min\" on a key that is off means what a press gives. \"Cool\" alone means on with no end.",
            "Key-sized frame in purple with the word \"Hub\", \"→ Life\" or \"→ Now\" (new in 0.26; iPad held on its side with \"Several pages at once\" on, under the Favourites): goes to a start screen. \"Hub\" on an app page goes to the first Hub (Now); \"→ Life\" or \"→ Now\" on a Hub goes to the other Hub. Hold it for the list of all page groups. Purple means pages in this app, and it still does.",
            "Warning triangle in Set up keys: something on that key needs your attention, with the reason beside it.",
            "Coloured tiles: apps blue, links teal, Raycast red, shortcuts and switches purple, typed text and timers amber, music and sound green, moving around grey-blue. A colour that changes with a value (Body Battery, Stress, Focus rounds, Free until, Mac at a glance) is explained in the part for that key. Red on a key means real trouble only.",
            "A key in a colour that is not one of the kind colours above (new in 0.24): it wears a colour of its own, usually the colour of a part of another app, for example the teal of Budget in AMS Financial Steward. Signal colours (green, amber, red, and grey-blue for old facts) are never replaced by a colour of your own.",
            "Grey-blue number on a glance key: the number is old (a Garmin number more than 3 hours old, a Weather key more than 2 hours old).",
            "Small dot beside a name in Settings: green or tick-like means allowed or on, red means not allowed or off. The words beside it say which.",
            "Link dot on the iPhone and iPad: green means connected to the Mac, amber means looking for the Mac or waiting for it to allow this device, red means the Mac said no. A small lock beside it means the line is private. These are shown on the iPhone, not on the Mac."
        ]),
        Section(id: "permissions", title: "What the Mac asks for", part: "settings", lines: [
            "Accessibility, once, for keys that press a keyboard shortcut, type text, paste a last copied text or control music and sound. Settings shows whether it is allowed and has an \"Allow…\" button.",
            "The Mac may also ask for Input Monitoring when the box is first plugged in.",
            "New in 0.11: \"Next event\" makes the Mac ask once whether Deck Mate may see your calendar (Allow Full Access; it only reads). \"Due today\" made the Mac ask once whether Deck Mate may control OmniFocus (until 0.13; not needed since 0.14). The \"Desk\" key and the \"Album cover\" key use the Accessibility yes. Weather, Album cover and Body Battery ask the Mac nothing.",
            "New in 0.12: nothing new is asked. \"Free until\" uses the same calendar yes as \"Next event\". The Garmin, Mac at a glance, World clock and Sunrise and sunset keys ask the Mac nothing.",
            "New in 0.13: \"Join the meeting\" uses the same calendar yes as \"Next event\" and only reads. \"Empty the bin\" makes the Mac ask once whether Deck Mate may control the Finder. \"Spotify playlist\" makes the Mac ask once whether Deck Mate may control Spotify. \"Paste as plain text\" uses the Accessibility yes. Choose Allow each time. The other new keys ask the Mac nothing.",
            "New in 0.14: nothing new is asked. The PARAGON keys and \"Due today\" only read a small file of PARAGON and open PARAGON. \"Focus rounds\" opens PomoTimer in the browser. \"Due today\" no longer needs the question about controlling OmniFocus. A \"Spotify playlist\" cover only needs the internet.",
            "New in 0.15: nothing new is asked. \"Raycast and links\" asks the Mac nothing; Raycast itself asks once about the folder you add.",
            "New in 0.16: nothing new is asked. The Keychain move shows no password window. The new keys (Breathing pacer, Progress bar, Often used, Now on my plan) ask the Mac nothing, and nor does the first run of Apple's Shortcuts actions.",
            "New in 0.23: the \"Training today\" key reads one more small file of another app, \"today-note.json\" of AMS Triathlon Training. The first time, the Mac asks whether AMS Deck Mate may access data from other apps (the same question as for PARAGON's file). Choose Allow. The key never writes there.",
            "New in 0.25: the \"Steward: to decide\" key reads one more small file of another app, \"deck-note.json\" of AMS Financial Steward (only the count of rows and the time). The first time, the Mac may ask whether AMS Deck Mate may access data from other apps (the same question as for the other two files). Choose Allow. The key never writes there."
        ]),
        Section(id: "settings", title: "Settings", part: "settings", lines: [
            "Open it from the menu. It has three tabs: \"Settings\", \"How it works\" and \"What's new\".",
            "Since 0.4 \"Settings\" is a short list on the left with one part at a time on the right, instead of one long page. The parts are: The box, First time with the box, Keys on screen, iPhone, Page groups, Check keys, Key use (new in 0.10), Raycast and links (new in 0.15), This Mac, From Elgato and Where it is kept.",
            "They hold the box and brightness, change page group with the app in front, the keys on screen (where they show, hide after a key, size), the iPhone card, open at login, permissions, bring over again and the check for broken keys.",
            "The version number, Quit and Done stay at the bottom.",
            "New in 0.16, no new parts, but new lines in old ones: the box's evening dimming in \"The box\"; the warning about Control-Option-D in \"Keys on screen\"; the card \"A key for <app>?\" at the top of \"Key use\"; and in \"Where it is kept\" the words about the key pictures in the iCloud copy.",
            "New in 0.17, no new parts: the iPhone card is unchanged. The Mac now understands link version 9 (several pages at once on an iPhone or iPad); nothing to switch on here.",
            "\"Open at login\" (in \"This Mac\"): while it is on, the Mac opens AMS Deck Mate every time you log in. New in 0.16.1: the app also keeps a second, separate start order with the Mac, called the keeper. It opens the app at every login even if the Mac's own login list fails, and it opens the app again by itself if it ever stops unexpectedly (usually within a second; the Mac may wait up to 10 seconds). Before, the app stayed gone until you opened it by hand, and so did the box, the keys on screen, the Raycast commands and the iPhone link.",
            "If you quit the app yourself with \"Quit\", it stays closed until you open it or until the next login. Switching \"Open at login\" off takes the keeper away too. At every start the app checks that the keeper is in place and puts it back if it is missing.",
            "If you open the app by hand while \"Open at login\" is on, it closes and comes back about a second later. That is normal: it hands itself over to the keeper so it is always protected. A link that opened the app in that very moment (for example a Raycast command while the app was closed) is not carried over, so press it once more.",
            "In System Settings, General, Login Items & Extensions, AMS Deck Mate now shows in two places: under \"Open at Login\" and under \"Allow in the Background\". Leave both on. The first time, the Mac may show a note \"AMS Deck Mate added items that can run in the background\". That is the keeper."
        ]),
        Section(id: "kept", title: "Where things are kept", part: "settings", lines: [
            "Your setup is one file on this Mac, in the folder \"AMS Deck Mate\" inside Application Support.",
            "Each save first keeps the previous file as a safety copy in a \"Backups\" folder beside it. Before 0.15 only the newest 20 were kept, so an hour of editing pushed out yesterday's state, and copies with names of their own took up some of the 20. Now three things are kept: the newest 20; plus the last copy of each of the last 30 days; plus a copy that ordinary saving never pushes out, made just before a page group or a page is deleted, before Elgato's keys are brought over, and before an earlier state is put back. The newest 10 of these are kept; their names start \"deck kept\". Copies with other names are never removed.",
            "Since 0.8, Settings, \"Where your setup is kept\", has a button \"Bring back an earlier state…\". It opens a list of the safety copies, newest first, each with its date and time and for example \"3 page groups · 47 keys\". Pick one and choose \"Bring back\", or Cancel (Escape is Cancel).",
            "Before it brings one back, your setup as it is now is kept as a safety copy, and Undo (Command-Z) also takes it back.",
            "New in 0.9: once a week the Mac also puts a copy of your keys file into iCloud Drive, in a folder called \"AMS Deck Mate\". Each copy is named by its day, for example \"deck 2026-11-16.json\". If this Mac is lost or broken, your keys are still there.",
            "The newest 8 copies are kept, about two months. Older ones are removed.",
            "In Settings, \"Where your setup is kept\", there is a switch \"Keep a weekly copy in iCloud Drive\" (on at first), a line \"Last copy: <date and time>\" (or \"No copy yet\") and a button \"Copy now\".",
            "The first time, the Mac asks once whether AMS Deck Mate may use iCloud Drive. Choose Allow.",
            "If iCloud Drive is not switched on on this Mac, Settings says so and nothing is copied.",
            "\"Bring back an earlier state…\" now also lists the iCloud copies, marked \"iCloud\".",
            "Only the keys file and, since 0.16, the key pictures go to iCloud Drive. Your copied texts and the permissions for iPhones never do.",
            "If your keys file is damaged, Deck Mate now repairs itself at start. It brings back the newest safety copy that can be read, keeps the damaged file in the Backups folder as \"damaged <date>.json\", and shows a message saying which copy (date and time) it brought back. If no copy can be read, it starts with empty keys and says so.",
            "New in 0.15: when no copy on the Mac can be read, the damaged file is also repaired from the weekly copy in iCloud Drive. Before: the iCloud copies were listed but never used for repair. A Mac with no keys file at all, for example a new Mac, takes the newest weekly iCloud copy by itself and says so at the start.",
            "New in 0.15: a keys file that can be read but holds no page group at all (an emptied file) now counts as damaged and is repaired. Before: it was taken as an empty setup and saved over.",
            "New in 0.15: an older app with a newer file. A key of a kind this version does not know shows as empty and does nothing, but it is written back exactly as it was, so a newer Deck Mate finds it again. Before: it was turned into an empty key for good. The file's format number is now 2 and is never lowered. When the file is from a newer Deck Mate, the app says so at the start.",
            "The box diary in \"~/Library/Logs/AMS Deck Mate\" is trimmed at each start: when it has more than 1,000 lines, only the last 500 are kept.",
            "New in 0.16: a failed save says so. A window \"The last change could not be saved\" says: \"The last change to your keys could not be saved. Your keys keep working, and Deck Mate tries again with every change.\" It comes once for each run of failures, a note goes into the box diary, and the next good save clears it. Before: a failed save went unseen.",
            "New in 0.16: the weekly iCloud copy also holds the key pictures, in a folder \"Pictures\" inside the iCloud folder (only new or changed files go). Before: only the keys file was copied, so a key picture was lost with a Mac. Missing pictures come back, never over a picture that is there, with \"Bring back an earlier state…\" from an iCloud copy, with the self-repair from iCloud, and at the start on a new Mac.",
            "What a restore does not bring back: how often keys were pressed, counters, stopwatches and a running focus round, the allowed iPhones, the locked page group, window places, recent apps, switch states, and the Settings choices that are kept outside the keys file.",
            "New in 0.16: the file's format number is now 3, instead of 2, because a page group can have hours and the box an evening brightness. It is never lowered. An older Deck Mate that meets the new file keeps saying at its start that the file is from a newer one.",
            "Apart from the weekly iCloud Drive copy, which holds the keys and their pictures, nothing leaves your Mac."
        ])
    ]

    static let releases: [Release] = [
        Release(id: "0.26", date: "27 Nov 2026", new: [
            "Hubs, two start screens. Before: every page group was alike, and the keys had no start screen of their own. Now: a page group can be marked as a Hub. In Set up keys, in the page group's settings, there is a new switch \"Hub — a start screen\". The Mac app is now 0.26 (build 36); the iPhone and iPad app is now 0.35 (build 41).",
            "Your keys now have two Hubs. \"Now\" is where Deck Mate always starts: four pages, Live, My apps, Mac apps and Do. \"Life\" has four pages: Training & health, Money & home, Work & focus and Mac, which holds every one of your apps.",
            "iPad held on its side with \"Several pages at once\" on: a Hub shows all its pages at once (up to four). Any other page group, an app's page, shows ONE page with the biggest keys. The Favourites stay in their column on the right, with the Hub key under them. An app page with more pages: swipe sideways, or press its \"More keys\" key (last place), to get the next one.",
            "The Hub key (iPad, under the Favourites, where the \"Pages\" key was; only when your keys have a Hub, otherwise the \"Pages\" key stays as before). On an app page it says \"Hub\" and goes to the first Hub (Now). On a Hub it says \"→ Life\" or \"→ Now\" and goes to the other Hub. Hold it for the list of all page groups, as before with the \"Pages\" key. The navigation picture still comes in with a pull from the far left edge (the thin purple line).",
            "Swipe sideways on a Hub and you are on the other Hub.",
            "Hold an app key on a Hub and you see that app's page, without bringing the app forward on the Mac. It is set for each key as its long-press action.",
            "Your keys were rebuilt (an example, not a feature of the app; it lives in your keys file, and a copy of the old keys is in Backups). New: the Hubs Now and Life, and the app pages PARAGON, Seedboard, Raycast, Alfred and Notion (WET and Daily Tracking are now one page). The pages Steward, Triathlon and Claude follow the same places: Settings in the bottom row and \"More keys\" in the last place. The old \"AMS Deck\" home key is gone, because the Hub key does its work. Removed at your wish: the old AMS Deck group (Home and its folders), OmniFocus and the Elgato tutorial page."
        ], changed: [
            "Following the Mac is unchanged: an app with its own page group comes to the front and its page shows; another app shows the start Hub (Now). A page you picked by hand stays while you move between apps that have no page group of their own.",
            "The iPhone, the Stream Deck box and the Mac's keys on screen are unchanged. A Hub shows there as a normal page group, one page at a time.",
            "How it works has a new part \"Hubs: start screens\" and changed lines in \"Set up keys\", \"Page groups change by themselves\" and \"Signs in this app\" (a new line for the Hub key). The specification has a new numbered item. The Mac app is now 0.26 (build 36); the iPhone and iPad app is now 0.35 (build 41)."
        ], fixed: []),
        Release(id: "0.25", date: "26 Nov 2026", new: [
            "A key that tells how many bank rows wait for your decision. Before: Deck Mate had no key for AMS Financial Steward, so you had to open Steward to see whether anything waited in To decide. Now: a new kind in Set up keys, under \"What it does\", in the group \"At a glance\", beside \"Training today\": \"Steward: to decide\". The number of rows that wait stands on the key in large figures, with \"to decide\" under it, in amber.",
            "When nothing waits: \"0\" with \"all decided\" under it, in green. When Steward has not counted for 36 hours, or never: \"–\" with \"Open Steward\" under it, in grey-blue (the key never shows an old number as if it were fresh, and it is never red). \"No Steward\": AMS Financial Steward is not on this Mac. \"–\" with \"Update Deck Mate\": Steward wrote its note in a newer format than this Deck Mate knows.",
            "A press opens AMS Financial Steward at To decide. On the key \"–\" with \"Open Steward\" a press does the same.",
            "Needs AMS Financial Steward 0.21 or later on the Mac. Steward leaves a tiny note in its own folder with ONLY the count and the time: no amounts and no names. Deck Mate reads it once a minute, only while such a key is on a page, and never writes it. The first time, the Mac may ask whether AMS Deck Mate may access data from other apps. Choose Allow (the same question as for the files of PARAGON and AMS Triathlon Training).",
            "Its colour says something (amber = rows wait, green = all decided, grey-blue = no fresh count), so this key offers no colour of its own, like the other glance keys since 0.24.",
            "In your keys (an example, not a feature of the app; it lives in your keys file): on the page group \"Steward\", the key \"To decide\" (row 1, third place) is now this key. On the page group \"Triathlon\", a new key \"New session\" (the keys ⌘N, in the blue of Triathlon's Plan) took the place of \"Ironman plan\". That key opened the old Excel file, which no longer follows the plan since the plan moved into AMS Triathlon Training on 25 Nov.",
            "The iPhone and iPad app stays 0.33. The Mac draws each key as a picture and sends it, so the phone and the iPad show the new key without a new version. Your keys file keeps its format (3): the key is saved as the kind \"steward\" with the target \"waiting\". An older Deck Mate keeps a key it does not know as it is. Nothing of yours was changed by the app."
        ], changed: [
            "Set up keys: the list \"What it does\" has one more kind, \"Steward: to decide\", in the group \"At a glance\".",
            "How it works has a new part \"Steward: to decide key\" and changed lines in \"What a key can do\", \"What the Mac asks for\" and \"Signs in this app\" (a new line for amber, green and grey-blue on this key). The specification has a new numbered item. The Mac app is now 0.25 (build 35); the iPhone and iPad app stays 0.33 (build 39)."
        ], fixed: []),
        Release(id: "0.24", date: "26 Nov 2026", new: [
            "A key can wear a colour of its own. Before: every key had the colour of its kind (apps blue, links teal, switches purple and so on), and you could not change it. Now: in Set up keys, beside the key's Icon, there is a new \"Colour\" well. Click it and Apple's colour picker opens. Pick a colour and the key wears it: on the box, on the keys on screen, and on the iPhone and iPad.",
            "Back to the old colour. Next to the well there is a small button \"Kind's colour\". It takes the colour of your own away, and the key has the colour of its kind again. A key without a colour of its own looks exactly as before.",
            "Keys whose colour already says something keep it, and show no colour well: the microphone light, Weather, Due today, PARAGON, Training today, Focus rounds, Body Battery, the Garmin numbers, Mac at a glance (battery, free space, busy), World clock, Free until, and the progress bar keys. One colour, one meaning: a green, amber or red on those keys is a message, so it is never painted over.",
            "Why. So that a page group made for one app can wear that app's own colours. Example, two page groups were added to your keys at the same time (they live in your keys, not in the app). \"Steward\" shows when AMS Financial Steward is in front: one key for each part of Steward (Overview, Routine, To decide, Transactions, Report, Budget, Big tickets, Long term, Strategy, Events, Wealth, Pension, Purchase note, Settings), each in that part's own colour, and a key back to AMS Deck. \"Triathlon\" shows when AMS Triathlon Training is in front: Training today, Today, Plan, Body, Progress and Settings in Triathlon's own colours, then Body Battery and the Garmin numbers, the Ironman plan and Workouts.",
            "The iPhone and iPad app stays 0.33. The Mac draws each key as a picture and sends it, so the phone and the iPad show the new colours without a new version.",
            "Kept in your keys file as a small \"colour\" (six letters and digits, for example 1F6BCC). A key without a colour of its own is written exactly as before, so nothing changes in your keys. The keys file keeps its format (3), and an older Deck Mate simply shows the key in the colour of its kind. The app did not change any key of yours."
        ], changed: [
            "Set up keys: a \"Colour\" well and a \"Kind's colour\" button beside the Icon, for every kind that does not already say something with its colour.",
            "How it works: the part \"Set up keys\" tells about the Colour well, the part \"Page groups change by themselves\" has a paragraph on page groups that wear an app's colours, and \"Signs in this app\" has a new line. The specification has a new numbered item. The Mac app is now 0.24 (build 34); the iPhone and iPad app stays 0.33 (build 39)."
        ], fixed: []),
        Release(id: "0.23", date: "26 Nov 2026", new: [
            "A key with today's training. Before: Deck Mate had no key for AMS Triathlon Training, so you had to open that app to see today's session. Now: a new kind in Set up keys, under \"What it does\", in the same group as the PARAGON kinds: \"Training today\". The key shows today's session from AMS Triathlon Training, and a press on the iPhone can log it as done. It needs AMS Triathlon Training 2.8 or later, opened at least once that day.",
            "What the key says. A session to do: the planned length in large words, for example \"45 min\", and under it \"Run · to do\". With more than one session to do: \"Run · to do +1\". A session with no planned length: the sport in large words, \"Run\", and \"to do\" under it. The key is teal.",
            "All of today's sessions done: \"Done\" in large words, the sport under it (or \"2 sessions\"), and the key turns green. Missed (nothing left to do, at least one missed): \"Missed\", the sport under it, grey-blue. A rest day: \"Rest\" and \"Rest day\" under it, teal.",
            "No fresh facts: \"–\" in large words and \"Open Triathlon\" under it, grey-blue. This is so when AMS Triathlon Training was not opened today on any device Deck Mate can see, when its note is more than 36 hours old, or when the note is from another day. The key never shows yesterday's session, and it is never red. \"No Triathlon\": AMS Triathlon Training is not on the Mac and no iPhone has told Deck Mate anything. \"Update Deck Mate\": the note is in a newer format than this Deck Mate knows.",
            "The same words show on the keys on screen, on the Stream Deck and on the phone, except one line: on an iPhone where a press will log the session, it says \"Run · press for done\" under the length instead of \"Run · to do\".",
            "What a press does (your choice: log on the iPhone, open elsewhere). In Deck Mate on the iPhone, when AMS Triathlon Training is on that iPhone and the session is today's, still to do and has a planned length: the press logs it as done, exactly as planned, the same as the button \"Done as planned\" in AMS Triathlon Training. AMS Triathlon Training comes to the front on the session's page, and that is your confirmation. A second press is harmless.",
            "On the Mac, on the Stream Deck, on the iPad, and whenever logging is not possible, a press only opens the session in AMS Triathlon Training: on the device where you pressed, if AMS Triathlon Training is there, else on the Mac. Nothing is changed. The reason: only the iPhone can log sessions in AMS Triathlon Training. The Mac and iPad versions cannot. On the key \"–\" with \"Open Triathlon\", a press opens the Today page; once it has been opened, the key shows the session (within a minute on the Mac, on the phone when Deck Mate comes to the front again).",
            "\"Explain\" on the iPhone and iPad and the pointer note on the Mac say the session's full name, for example \"Easy run, 45 min, to do. A press logs it as done in Triathlon Training.\" or \"Easy run, 45 min, to do. A press opens it in Triathlon Training.\"",
            "Where the key gets its facts. AMS Triathlon Training writes a small \"today\" note with only: the sport, the session's name, the planned length, whether it is done, and this week's hours. Deck Mate only reads it. On the Mac, the file \"today-note.json\" in AMS Triathlon Training's own folder, read once a minute and only while such a key is on a page. The first time, the Mac asks whether AMS Deck Mate may access data from other apps (the same question as for PARAGON's file). Click Allow.",
            "On an iPhone or iPad, AMS Triathlon Training keeps the same note in the device's Keychain, in a group that both apps share, for this device only and never in iCloud. Deck Mate on the phone reads it (read only) when it connects to the Mac, when it comes to the front and once a minute, and tells the Mac over the private line (link version 11, a new message \"training\"). The Mac draws the key from the newest note it has, its own file or a phone's. So the Stream Deck also shows \"Done\" after you logged on the iPhone, as long as Deck Mate on the phone was open after it.",
            "For a press on the phone, the Mac answers with the link to open (a new message \"open\", from the Mac to the phone, link version 11). The phone opens a link only if it starts with \"amsworkoutsync://\", only within 3 seconds of a press on that phone, and only if the link is in the phone's own note (or is the Today page).",
            "Old and new together. A Deck Mate on the phone before 0.33 still shows the key (the Mac draws it), but a press there always opens the session on the Mac. A Mac before 0.23 does not know this kind of key. The iPhone and iPad app is now 0.33 (build 39).",
            "Your keys file keeps its format (3). The key is saved as the kind \"training\" with the target \"today\", so an older Deck Mate keeps a key it does not know as it is. The app did not add any key to your pages: place it yourself in Set up keys. (Only the built-in sample deck, shown on a Mac without keys of its own, has one.)",
            "Tried on this Mac on 26 Nov 2026: the new build read AMS Triathlon Training's real note file and drew the key from it. Not tried on real devices yet: the Keychain shared between the two apps on a real iPhone, the Mac's question about data from other apps for the installed app, the links really opening AMS Triathlon Training, a press on the phone, and the real Stream Deck box. Only signed builds on real devices can show these."
        ], changed: [
            "Set up keys: the list \"What it does\" has one more kind, \"Training today\".",
            "How it works has a new part \"Training today key\" and changed lines in \"What a key can do\", \"What the Mac asks for\" and \"Signs in this app\" (new lines for the green \"Done\", the grey-blue key, \"+1\" and \"–\"). The specification has a new numbered item. The Mac app is now 0.23 (build 33); the iPhone and iPad app is now 0.33 (build 39)."
        ], fixed: []),
        Release(id: "0.22", date: "25 Nov 2026", new: [
            "A key with the fan speed. Before: Deck Mate had a key with the chip temperature (0.21) but nothing that showed how fast the fans turn. Now: a new choice in Set up keys, under \"What it does\" > \"Switch (on or off)\": \"Fans: fan speed\" (nine choices now, were eight). The key shows the speed of the Mac's fans live, in turns per minute, as words on its face: \"Fans 1,650\" (with a comma between the thousands, the same on every Mac).",
            "With two fans it shows the faster of the two. When every fan stands still it says \"Fans off\" (not \"Fans 0\"). Without a fresh reading it says \"Fans –\".",
            "A press does the same as the chip key: it opens the large graph window of AMS Fan Menu (if AMS Fan Menu is not open, it is opened first and asked about a second and a half later; if it is not installed, the note says \"AMS Fan Menu is not on this Mac\"). \"Explain\" and the pointer note read \"Shows the fan speed. Click: opens AMS Fan Menu's graphs.\" After a press the note says \"Opened the Fan Menu graph\". The key has no long press of its own.",
            "It reads the same note that AMS Fan Menu 0.6 or newer writes down every 5 seconds (the same file as the chip key). When both keys are on your deck, Deck Mate reads the file once, not twice, every 2 seconds, and draws a key again only when its words change. Without AMS Fan Menu 0.6 (not running, older, or the note more than 30 seconds old) the key reads \"Fans –\". A press still asks for the graph.",
            "Look: purple like every switch key, with the fan drawing, and no switch mark, like the chip key. A new line in \"Signs in this app\" says what \"Fans 1,650\", \"Fans off\" and \"Fans –\" mean.",
            "iPhone and iPad: no update needed. The Mac draws the key and sends the picture, so the phone shows \"Fans 1,650\" and a tap on the phone asks the Mac, which opens the graph on the Mac (the phone keeps its 0.32, build 38).",
            "Your keys file keeps its format (3). The key is saved as a Switch key with the target \"fanmenu:fans\", so an older Deck Mate that meets it shows an ordinary switch it does not know. The app did not add any key to your pages: your own keys file was not touched, so place the key yourself in Set up keys. (Only the built-in sample deck, shown on a Mac without keys of its own, has one, next to the chip key.)",
            "Not yet tried: with a real AMS Fan Menu 0.6, and on the real Stream Deck box."
        ], changed: [
            "Set up keys, Switch key: the choice list has one more entry, \"Fans: fan speed\", and for it the note under the list says what it does and that it shows no switch mark.",
            "How it works has changed lines in \"Switch key (on or off)\" and \"Signs in this app\" (a new line for the words \"Fans 1,650\"). The specification has a new numbered item. The Mac app is now 0.22 (build 32); the iPhone and iPad app stays 0.32 (build 38). The build number is now the same in the app's information file and in the project settings (0.21 had only one of the two raised)."
        ], fixed: []),
        Release(id: "0.21", date: "25 Nov 2026", new: [
            "A key with the chip temperature. Before: Deck Mate had fan keys (Automatic, Cool, Full) and no key that showed how hot the Mac is. Now: a new choice in Set up keys, under \"What it does\" > \"Switch (on or off)\": \"Fans: chip temperature\" (eight choices now, were seven). The key shows the chip temperature of the Mac live, in whole degrees, as words on its face: \"Chip 56°\".",
            "It is already on your deck: AMS Deck > Home, bottom right, the last free place of the row with the three fan keys (before: that place was empty; nothing else moved). Drag it elsewhere in Set up keys if you like.",
            "A press opens the large graph window of AMS Fan Menu (Deck Mate asks AMS Fan Menu for it; if AMS Fan Menu is not open, it is opened first and asked about a second and a half later; if it is not installed, the note says \"AMS Fan Menu is not on this Mac\"). The key has no long press of its own; you can still give it one in \"Long press\" like any key.",
            "It needs AMS Fan Menu 0.6 or newer, which now writes the figure down every 5 seconds while it runs. Deck Mate reads it every 2 seconds, as it already looks at the Mac, and draws the key again only when the whole degree changes. Without AMS Fan Menu 0.6 (not running, older, or the figure more than 30 seconds old) the key reads \"Chip –\". A press still asks for the graph.",
            "Look: purple like every switch key, with the fan drawing, and no switch mark. Before: every switch key showed the small switch mark in its top left corner. Now: this one does not, because it shows a figure and is never on or off. A new line in \"Signs in this app\" says so.",
            "iPhone and iPad: no update needed. The Mac draws the key and sends the picture, so the phone shows \"Chip 56°\" and a tap on the phone asks the Mac, which opens the graph on the Mac. \"Explain\" on the phone reads \"Shows the chip temperature. Click: opens AMS Fan Menu's graphs.\" (the phone keeps its 0.32, build 38).",
            "Your keys file keeps its format (3). The key is saved as a Switch key with the target \"fanmenu:chip\", so an older Deck Mate that meets it shows an ordinary switch it does not know. No key was added to your pages: place it yourself in Set up keys.",
            "Not yet tried: with a real AMS Fan Menu 0.6 (it was being built at the same time), and on the real Stream Deck box."
        ], changed: [
            "Set up keys, Switch key: the choice list has one more entry, \"Fans: chip temperature\", and for it the note under the list says what it does and that it shows no switch mark.",
            "How it works has changed lines in \"Switch key (on or off)\" and \"Signs in this app\" (a new line for the words \"Chip 56°\"). The specification has a new numbered item. The Mac app is now 0.21 (build 31); the iPhone and iPad app stays 0.32 (build 38)."
        ], fixed: []),
        Release(id: "0.20", date: "25 Nov 2026", new: [
            "Round of three things. Before: Mac 0.19 (build 29) and iPhone and iPad app 0.31 (build 37). Now: Mac 0.20 (build 30) and iPhone and iPad app 0.32 (build 38). The link between the Mac and the phone is now version 10 (it was 9). Old and new work together: see the last lines of this entry.",
            "The fan key shows the minutes left. Before: the Cool key and the Full key always read \"Cool 10 min\" and \"Full 10 min\", on or off. Now: the key of the choice that is on shows what is left, for example \"Cool · 8 min\", and in the last minute \"Cool · <1 min\" (whole minutes, rounded up, the same count AMS Fan Menu shows). The key that is off still reads \"Cool 10 min\" or \"Full 10 min\", which is what a press gives. A choice that is on with no end (set in AMS Fan Menu with \"Until I change\") reads just \"Cool\" or \"Full\". \"Automatic\" never shows minutes.",
            "The key is drawn again when the minute changes, not every second. Deck Mate still looks at AMS Fan Menu's note every 2 seconds, as before, and at once when AMS Fan Menu says it changed. A fan key with a title of your own keeps its title. This needs AMS Fan Menu 0.3.1 or newer, as before. AMS Fan Menu itself was not changed, and the iPhone and iPad show the minutes by themselves, because the Mac draws the keys.",
            "A double press. Before: a key had its usual action and, since 0.5, a long press (hold half a second; marked by a small white dot). Now: right under \"Long press\" in Set up keys there is \"Double press\", with the same list of things a key can do and the same fields. \"Nothing\" means no double press, and that is how every key is at first. No key of yours has one yet.",
            "A key with a double press shows a small white \"×2\" in its top right corner, to the left of the place of the long-press dot. The dot keeps its one meaning, hold. A key can have both, side by side.",
            "How it is pressed: two presses within a third of a second (0.33 seconds). It counts on the box's keys, on a click on the keys on screen, on a tap on the iPhone and iPad (the 15 keys and the favourites), and by a link: a link with \"&twice=1\" runs the double-press action at once.",
            "The price, said plainly: a key that has a double press waits a third of a second after one press, to see whether a second press follows, and only then does its usual thing. Every key without a double press acts at once, exactly as before. On the box and with the mouse the wait starts when you let the key go. A double press on a key without one is two presses, one after the other, as before. A long press still works on a key that has both.",
            "Favourites can have a double press too, and so can a key that only moves around (a page, a folder or a page group key). The check for broken keys also looks at the double press: its note starts with \"Double press:\", like \"Long press:\". Your keys file got one new optional entry per key; files from before are read as they are, and none of your keys was changed.",
            "What a key does, in words. Before: nothing said what a key would do. Now every kind of key has words for it, said as what it will do: \"Opens Safari\", \"Presses ⌘N\", \"Fans: Cool for 10 minutes\", \"Goes to the page “Money”\". Up to three lines per key: a click, a hold (only when holding does something else) and twice (only when the key has a double press).",
            "On the keys on screen: rest the mouse pointer on a key for one second and a small light plate over the other half of the keys says \"Click …\", \"Hold …\" and \"Twice …\". Move the pointer away, or click, and it goes. Nothing else about the keys on screen changed.",
            "The iPhone and iPad app 0.32 gets an \"Explain\" button that shows the same words when you tap a key, without pressing it. The Mac sends the words, so that button needs this Mac at 0.20.",
            "Old and new together: an iPhone or iPad app 0.31 with this Mac gets the double press too (the Mac does the waiting) but has no Explain button. An iPhone or iPad app 0.32 with a Mac before 0.20 shows no Explain button, because that Mac does not send the words.",
            "Not yet tried: the double press on the real Stream Deck box, a real finger double-tapping on the iPhone or iPad with this Mac, and the full 10 minutes counting down on the fan key." 
        ], changed: [
            "The Cool and Full keys read \"Cool · 8 min\" while they are on. Before: \"Cool 10 min\" always. Now: the minutes left on the key that is on, \"Cool 10 min\" on a key that is off (see above).",
            "The keys on screen: a key with a double press acts a third of a second after one click, not at once. Before: every key acted at once except a key with a long press, which acts when you let go. Now: a key with a double press waits too. Keys without one are as before.",
            "How it works has changed lines in \"Keys on screen\", \"Set up keys\", \"Long press: a second action\", \"Switch key (on or off)\", \"Press keys from Raycast and by link\", \"On your iPhone\" and \"Signs in this app\" (a new line for \"×2\" and a changed line for the words on a fan key; the dot is unchanged), and has new parts \"Double press: a third action\" and \"What a key says it does\". The specification has new numbered items. The Mac app is now 0.20 (build 30)."
        ], fixed: []),
        Release(id: "0.19", date: "25 Nov 2026", new: [
            "Round of three things. Before: Mac 0.18 (build 28). Now: Mac 0.19 (build 29). The iPhone and iPad app is now 0.31 (build 37; it was 0.30, build 36).",
            "Fan keys last 10 minutes. Before: the Cool key and the Full key asked AMS Fan Menu for their choice, and it stayed on as long as the \"For\" line in AMS Fan Menu said. With its usual pick \"Until I change\" that meant for good, until you pressed another key. Now: both keys ask for 10 minutes. After 10 minutes AMS Fan Menu gives the fans back to the Mac by itself and its choice goes to Automatic, and the Automatic key then shows the filled switch mark. A second press on the same key starts the 10 minutes afresh. The Automatic key is unchanged and has no time.",
            "The fan keys say so on their face. Before: \"Cool\" and \"Full\". Now: \"Cool 10 min\" and \"Full 10 min\". In Set up keys the picker and the Raycast command names now read \"Fans: Cool for 10 minutes\" and \"Fans: Full for 10 minutes\".",
            "This needs AMS Fan Menu 0.3.1 or newer (installed on 25 Nov 2026). With an older AMS Fan Menu the Cool and Full keys do nothing.",
            "You choose which pages show together. Before: an iPad on its side shows 4 pages at once and an iPhone 2, but only the app decided which. The page you were on always came first (top left), then the next pages of the page group in their order, going round, then the group's folders. A tap on a page in the navigation picture moved that page to the top left and shuffled the other three. Now: in Set up keys, in the left column under each page group's settings, there is a new box \"Several pages at once\" with four places, numbered 1 to 4 (1 top left, 2 top right, 3 bottom left, 4 bottom right; an iPhone shows 1 and 2).",
            "You drag a page or a folder from the row of pages above the keys into a place. Dragging onto a place that is taken replaces it. Dragging from one place to another swaps the two. The button \"Let the app choose\" empties all four places, and then everything is as before. Each page group has its own four places, saved with the keys.",
            "The rule: pages you placed always show in their places. Going to one of them (a tap in the navigation picture, a folder key, Back) changes nothing on the screen except which one is \"the page you are on\". Places you left empty are filled by the app as before, starting with the page you are on. When all places are taken and you go to a page that is not one of them, it shows in place 1 for the moment; your own page comes back there as soon as you go to one of your placed pages again.",
            "This needs the iPhone and iPad app 0.31 to show the name of the page you are on in blue. With the older app, the places still work.",
            "The small cross in the corner of a place empties that one place. An empty place says \"The app chooses\" under it.",
            "Tried on this Mac: AMS Fan Menu was asked for Cool for one minute and went back to Automatic by itself when the minute was up. Also tried: the Cool key itself (AMS Fan Menu then showed Cool, ending 600 seconds later), and the real Set up keys window with your own keys (nothing cut off, a click on a page name still opens it). Not yet tried: waiting the full 10 minutes, dragging a page into a place with a real mouse, the pages on a real iPad or iPhone, and the Stream Deck box itself."
        ], changed: [
            "Set up keys: the window is taller. Before: it was 620 points high, but its middle column had grown taller than that, so the whole content was pushed up and down. The top of the left column (the name of the first page group) and the first line of the right column were cut off under the title bar, and the bottom line with Undo, Redo and Done was pushed out of the window. Now: the window is up to 840 points high (never taller than the screen allows; 789 on this MacBook as its screen is set today), everything starts at the top, the bottom line with Undo, Redo and Done is always in sight, and the left and middle columns scroll by themselves if a screen is too small for them.",
            "How it works has changed lines in \"Switch key (on or off)\", in \"Set up keys\" and \"Signs in this app\", and has a new part \"Choose which pages show together\". The specification has new numbered items. The Mac app is now 0.19 (build 29)."
        ], fixed: [
            "The top of \"Set up keys\" was cut off and its bottom line was out of sight. This is fixed (see the change above)."
        ]),
        Release(id: "0.18", date: "24 Nov 2026", new: [
            "Fan keys. Before: Mac 0.17.1 (build 27) and iPhone and iPad app 0.29 (build 35). Now: Mac 0.18 (build 28); the iPhone and iPad app stays 0.29 (build 35) and needs no update, because the Mac draws the keys, so the new keys show and work there by themselves.",
            "Three new choices for the kind \"Switch (on or off)\" in Set up keys. Before: four choices (Dark mode, Mute the sound, Keep the Mac awake, Two things in turn). Now: seven. The new ones are \"Fans: Automatic\", \"Fans: Cool\" and \"Fans: Full\".",
            "They work together with your other Mac app, AMS Fan Menu (version 0.2 or newer), which sets the fan speed of the MacBook. It must be installed on this Mac. Deck Mate never touches the fans itself. It only asks AMS Fan Menu.",
            "A press on a fan key asks AMS Fan Menu for that choice. Automatic: the Mac runs the fans itself. Cool: a middle speed. Full: top speed. The speeds are the ones you set in AMS Fan Menu.",
            "If AMS Fan Menu is not open, the press opens it first and asks about a second and a half later. If it is not installed, the press does nothing and the note says \"AMS Fan Menu is not on this Mac\". After a press the note says \"Fans: Cool\" (or Automatic, Full). Set up keys also marks a fan key as a key that cannot work while AMS Fan Menu is not on this Mac.",
            "The key shows which choice is on. The fan key of the choice that is on right now shows the small switch mark in its top-left corner filled. The other fan keys show it as an outline. It is the same mark, with the same meaning, as on every switch key. There is no new sign in the app.",
            "The keys follow AMS Fan Menu within a moment (about two seconds at most). That is also so when the choice is changed in the Fan Menu panel, or when Fan Menu changes it by its own rules (on battery, a timed choice running out, too hot, sleep). If Fan Menu is on a choice that has no key (Quiet, My speed, Follow temperature), no fan key is filled.",
            "One difference from the other switches: a second press on a fan key that is already on changes nothing. To leave Cool, press Automatic (or Full).",
            "Look. A fan key is purple like every switch key. Its drawing is a fan with three blades, the same mark AMS Fan Menu shows in the menu bar. It is one more hand-drawn drawing to pick in Set up keys: 257 drawings, 256 before. Without a title of its own the key says \"Automatic\", \"Cool\" or \"Full\".",
            "In your own keys, three fan keys were added on free places, and nothing was moved: page group \"AMS Deck\", page \"Home\", bottom row, the first three places (places 11, 12 and 13): Automatic, Cool, Full. Keys: 208 before, 211 now. A copy of the keys from before is in Backups (\"deck before fan keys 2026-11-24 2055.json\").",
            "Not yet tried: the Stream Deck box itself, and the fan keys on your real iPhone and iPad."
        ], changed: [
            "How it works has changed lines in \"Switch key (on or off)\" and in the list of drawings. The specification has a new numbered part. The Mac app is now 0.18 (build 28)."
        ], fixed: [
        ]),
        Release(id: "0.17.1", date: "20 Nov 2026", new: [
            "Small follow-up round, from trying 0.19 on the iPad. Before: Mac 0.17 (build 26) and iPhone and iPad app 0.19 (build 24). Now: Mac 0.17.1 (build 27) and iPhone and iPad app 0.19.1 (build 25).",
            "Several pages at once now fills empty spots with folders. Before: the page group \"Notion\" has 2 top pages, so the iPad showed just 2 pages, small, at the bottom; \"AMS Deck\" has only the page Home plus folders, so the iPad showed 1 page (15 keys). Now: when the page group has fewer top pages than the device shows (2 on an iPhone, 4 on an iPad), its folders fill the rest, in their order in Set up keys. \"AMS Deck\" now shows Home, Apps, Tutorials and Raycast on the iPad: 4 pages, 60 keys instead of 15.",
            "A Back key on a folder shown this way goes to the page the folder belongs to, and that page then becomes the first page.",
            "The rule for which pages show lives on the Mac, so this needs the Mac at 0.17.1 and the phone at 0.19.1. With an older Mac or phone, it works as in 0.17 and 0.19.",
            "Not yet tried: none of this was run on a real iPhone or iPad."
        ], changed: [
            "Bigger keys. Before: the pages always sat side by side (2 pages) or two above and two below (4 pages), so 2 pages on an iPad had small keys and a large empty space. Now: the iPhone and iPad arrange the pages in whichever way gives the biggest keys. 2 pages on an iPad sit one above the other, and 3 pages may sit two above one. For \"Notion\" on an iPad the keys grow from about 75 points to about 110 points, about half as big again.",
            "How it works has changed lines in \"Several pages at once\" (in \"On your iPhone\"). The specification has new numbered items. The Mac app is now 0.17.1 (build 27)."
        ], fixed: [
            "The \"Notion\" page group showed only 2 small pages at the bottom of the iPad. It now shows its folders too, and the keys are bigger."
        ]),
        Release(id: "0.17", date: "20 Nov 2026", new: [
            "Round of one new way to use the iPhone and iPad, and a mark check. Before: Mac 0.16.1 (build 25) and iPhone and iPad app 0.18 (build 23). Now: Mac 0.17 (build 26) and iPhone and iPad app 0.19 (build 24).",
            "Several pages at once (the Mac's part). Before: the iPhone and iPad showed one page of 15 keys. Now: with the new switch \"Several pages at once\" in the phone's Settings, Showing, the iPhone shows 2 pages side by side (30 keys) and the iPad 4 pages (60 keys). The Mac now understands link version 9, the new, longer way it talks to the phone: it sends the extra pages, and it carries out a tap on any of them exactly as if you had pressed that key on its own page.",
            "Which pages show: the first one is the page the phone is on, as before. The others are the next pages of the same page group, in their order, and it goes round: after the last page it continues with the first. So the phone shows 2 (iPhone) or 4 (iPad) pages, or fewer when the page group has fewer top pages. In a folder, the folder shows first and its own top page is not repeated. A page without a name shows as \"Page 2\", \"Page 3\" and so on. Folders are not shown as extra pages.",
            "A key that opens a folder or another page moves the view: that page becomes the first one on the phone.",
            "Nothing changes on the Mac: the box, if it is plugged in, and the keys on screen keep showing just the first page.",
            "Needs the phone app at 0.19 and this Mac at 0.17. With an older Mac the switch on the phone says so and the phone shows one page as before. With an older phone, the Mac talks as before.",
            "Not yet tried: none of this was run on a real iPhone or iPad. The real box is at home until January 2027."
        ], changed: [
            "The keys on screen: the three buttons in the top line now read \"Search\", \"Set up\" and \"Hide\". Before: a magnifier, a gear and a cross, with no words. Hide has no cross any more.",
            "Set up keys: the two \"+\" buttons now read \"+ Page group\" and \"+ Page\". Before: both were a plain \"+\", one beside \"Page groups\" and one after the page names.",
            "How it works has a new part, \"Signs in this app\" (every mark and colour that means something), and new lines in \"On your iPhone\", \"Set up keys\", \"Keys on screen\" and \"Settings\". The specification has new numbered items. The Mac app is now 0.17 (build 26)."
        ], fixed: [
            "Mark check: the cross meant two things (\"hide the keys\" in the top line of the keys on screen, \"remove\" in Set up keys). Now the top-line button reads \"Hide\" with no cross, so the cross means \"remove\" everywhere in the app.",
            "Mark check: two look-alike \"+\" buttons in Set up keys, one for a page group and one for a page. Now they have words.",
            "Mark check: the magnifier and the gear in the top line were pictures only. Now they read \"Search\" and \"Set up\"."
        ]),
        Release(id: "0.16.1", date: "18 Nov 2026", new: [
            "Mac only. Before: Mac 0.16 (build 24). Now: Mac 0.16.1 (build 25). The iPhone and iPad app is not changed and stays at 0.18 (build 23).",
            "Why: the Mac's own login list can fail without saying so. On 17 Nov 2026 a Mac restarted and did not open two menu bar apps of this family, although \"Open at login\" was on: the Mac's login list could not find them. AMS Deck Mate relied on that list alone, so after such a restart the Stream Deck box, the keys on screen, the Raycast commands and the iPhone link would stay dead until the app was opened by hand.",
            "New: the keeper. While \"Open at login\" is on, the app now keeps a second start order with the Mac, apart from the Mac's login list. It opens the app at every login, even when the Mac's own login list fails. Before: if that list failed, nothing opened the app.",
            "New: the app comes back by itself. If it ever stops unexpectedly, the keeper opens it again. Measured on other apps of the family: within about a second; the Mac may wait up to 10 seconds. Before: the app stayed gone until you opened it by hand.",
            "If you quit the app yourself with \"Quit\", it stays closed until you open it or until the next login. Switching \"Open at login\" off removes the keeper too. At every start the app checks that the keeper is in place and puts it back if it is missing.",
            "New line in Settings, in the \"This Mac\" card, under the \"Open at login\" tick box, in small grey words: \"While this is on, the app also comes back by itself if it ever stops unexpectedly.\" Before: no such line.",
            "Rule tests: 195, instead of 193. Two are new: \"of two copies the earlier one stays\" and \"the keeper's start order\".",
            "Checked on 18 Nov 2026 without restarting the Mac: after a sudden stop the app was back in under a second; a second copy closed and the first stayed; started as at login, the app opened by itself; after Quit it stayed closed. Not yet proven: a real restart of the Mac."
        ], changed: [
            "Opening the app by hand while \"Open at login\" is on: the app hands itself over to the keeper. It closes and comes back about a second later, before it touches the box or your keys file, so it is always protected. Before: it simply stayed as you opened it, without the keeper. A link that opened the app in that very moment (for example a Raycast command while the app was closed) is not carried over: press it once more.",
            "In System Settings, General, Login Items & Extensions, AMS Deck Mate now shows in two places: under \"Open at Login\" and under the background list (\"Allow in the Background\"). Leave both on. Before: only under \"Open at Login\". The first time the Mac may show a note \"AMS Deck Mate added items that can run in the background\".",
            "When the Mac shuts down or an update stops the app, the app now ends cleanly, just as with \"Quit\": the box is left tidy and the last changes are saved. Before: such a stop cut the app off.",
            "The app now remembers that you want \"Open at login\" in a note of its own, apart from the Mac's list. The first time it takes over what the Mac's list says. Before: it relied on the Mac's list alone.",
            "For checks: a copy started with \"--checks\", \"--data <folder>\" or \"--plain\" never hands itself over to the keeper and is never the copy the Mac opens at login.",
            "The iPhone and iPad app is not changed. It stays at 0.18 (build 23) and works with this Mac."
        ], fixed: [
            "Only one copy stays. If two copies start in the same moment (the Mac's login list and the keeper), the one that started first stays and the later one closes. Before: each saw the other and both closed, so none was left."
        ]),
        Release(id: "0.16", date: "18 Nov 2026", new: [
            "Round of new keys, calm, safer saving and a deck that works by itself. Before: Mac 0.15 (build 23) and iPhone and iPad app 0.17 (build 22). Now: Mac 0.16 (build 24) and iPhone and iPad app 0.18 (build 23). The app 0.17 keeps working with Mac 0.16, and the app 0.18 works with Mac 0.15.",
            "New key \"Breathing pacer\" (green, under Time). Before: no key could guide a breath. Now: a press starts a round and a second press stops it. A white rounded column fills while you breathe in and empties while you breathe out, with \"Breathe in\" and \"Breathe out\" under it. After the last breath it goes back quietly: no sound, no \"Done\", no numbers. Rhythm: 4 in · 6 out (at first), 4 · 4, 5 · 5 or 4 in · 8 out. Breaths: 6 (at first), 10 or 20.",
            "New key \"Progress bar (part of a row)\" (under Time). Before: nothing showed a whole focus round or timer across several keys. Now: put several bar keys side by side and they make one bar that fills from left to right with the focus round that runs (purple), else with the timer that ends last (amber). With nothing running the parts are empty. The button \"Fill this row with the bar\" turns the EMPTY places of a row into numbered bar parts and never replaces a key.",
            "New key \"Often used key\" (under Open). Before: the keys you press most were found by hand. Now: choose \"1 (most)\" to 5. The key shows the picture and words of that key, and a press presses the real key, counted for the real key. Only keys pressed in the last 30 days count. Not yet filled, it says \"Not yet\". The button \"Add an “Often used” folder\" makes a folder with Back and five often used keys.",
            "New PARAGON key \"Now on my plan\" (short title \"My plan\"). Before: 4 PARAGON choices. Now: 5. During a block it shows the end time, for example \"14:30\", and \"until <name>\"; between blocks the next start and name; with nothing more planned \"Free\" and \"Nothing more planned\". A press opens Today in PARAGON.",
            "New ready-made page group \"My AMS apps – 12 link keys\" (the + beside \"Page groups\"): Tidy Bar (show or hide, show, hide, arrange), Shopping (scan, trip), PARAGON (Inbox, Today, Overdue, Review, Plan) and Seedboard. Before: 4 ready-made page groups. Now: 5.",
            "Kinds of key: 45, instead of 42.",
            "Calm: timers in whole minutes. Before: a timer key counted every second, for example \"4:59\". Now: \"21 min\" while more than 60 seconds are left (\"75 min\" for an hour or more), \"1:00\" at exactly a minute, and seconds only in the last minute (\"0:59\"). The focus rounds key does the same and keeps the step's name in the small words. The stopwatch keeps its seconds. A 25-minute timer changes its picture 84 times, instead of 1,500.",
            "Calm: a softer sound. Before: a timer's end played a sound twice, 1.2 seconds apart. Now: \"Glass\" once, at volume 0.6. Focus rounds make no sound in Deck Mate; PomoTimer plays its own.",
            "Making keys: wrong input is said at once. A link key with text that is neither a file nor a web address (for example it has a space) says in red \"This is not a web address or a file. Check it for spaces, or choose a file with the button.\" and counts as broken; a bare \"example.com\" gets a grey note that it opens as https://example.com. A town (Weather, World clock, Sunrise and sunset) is looked up when you leave the field: red \"Town not found. Check the spelling.\" or grey \"Lisbon, Portugal\"; with no internet nothing is shown. A Spotify playlist text that is no Spotify link says in red \"This is not a Spotify link. In Spotify choose Share › Copy link, then paste it here.\" Before: nothing said anything until you pressed the key.",
            "Making keys: \"New key from…\" in the menu bar menu. Before: no such line. Now: up to three choices, \"App: <name>\" (the app in front), \"Link: <web address>\" (a web address you copied) and \"File: <name>\" (the file you opened last, only while a \"Recent file\" key exists). The key goes on the first empty place of the page showing now. Command-Z in Set up keys takes it back. A full page says \"This page is full.\" and changes nothing. With nothing to offer: \"Nothing to make a key from yet\".",
            "Making keys: the deck suggests a key. Before: nothing. Now: in Settings › Key use one calm card, \"A key for <app>?\" with for example \"You used it on 9 of the last 14 days and it has no key.\", a full-colour \"Add a key\" and a quiet \"Not this one\" (remembered for good). It picks the app used on the most days, at least 5 of the last 14, never an app that has a key, a favourite or its own page group, and never Deck Mate or the Finder. Only the days are counted, in a small file \"apps.json\". No badge, no notification.",
            "Making keys: \"Save as PDF…\" in Set up keys › All pages. Before: no way to get your keys on paper. Now: every page group with its pages as small pictures and names, on A4 pages with page numbers. The suggested name is \"Deck Mate keys.pdf\", and the file opens afterwards.",
            "Making keys: darker amber and green so white words read well. Amber from 0.73 / 0.47 / 0.06 to 0.62 / 0.38 / 0.04 (contrast 3.63 to 5.04). Green from 0.18 / 0.61 / 0.31 to 0.14 / 0.52 / 0.26 (3.53 to 4.68). The buttons in Settings use the same green, so they are a little darker. Headings are as before.",
            "The deck by itself: hours for a page group. In Set up keys, under \"Use with apps\", tick \"Show at these hours\" with from and to (at first 06:00 to 09:00; may pass midnight). In those hours the page group shows instead of the default one, for apps with no page group of their own. An app's own page group, and one you picked by hand, always stay. Looked at when the front app changes, once a minute and at wake. \"Duplicate page group\" does not copy hours.",
            "The deck by itself: evening dimming of the box (not yet tried on the real box). In Settings › The box, under Brightness: \"Dim in the evening\" (off at first), \"From 21:30 to 07:00\" and an \"Evening brightness\" slider from 5 to 100, at first 20 %. Looked at once a minute, at start, at wake and when a setting changes.",
            "The deck by itself: actions for Apple's Shortcuts app. Before: only the Mac's keys, Raycast and links could press a key. Now: \"Press a Deck Mate key\" (pick from the keys that have words and do something, shown as \"page group › page\"), \"Show a Deck Mate page group\" (does not lock it) and \"Show or hide the Deck Mate keys on screen\". \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\" always ask first. With \"Raycast and links\" switched off, the actions say \"Pressing keys from outside is switched off. Switch it on in AMS Deck Mate: Settings › Raycast and links › “Keys can be pressed from Raycast and by link”.\" Not yet tried from the Shortcuts app.",
            "Safety: the secrets of allowed iPhones and iPads moved into the Mac's Keychain (its safe for passwords), one entry for each device. Before: they were in the app's settings. Now: it moves over by itself, shows no password window, and \"Forget\" removes the entry. If the Keychain cannot be used, the secret stays where it was and the box diary says so. Not yet proven across a future new build of the app.",
            "Safety: a failed save says so. Before: unseen. Now: a window \"The last change could not be saved\" with \"The last change to your keys could not be saved. Your keys keep working, and Deck Mate tries again with every change.\" It comes once for each run of failures, goes into the box diary, and the next good save clears it.",
            "Safety: the weekly iCloud copy also holds the key pictures (folder \"Pictures\" in the iCloud folder, only new or changed files). Before: only the keys file. Missing pictures come back, never over one that is there, with \"Bring back an earlier state…\" from an iCloud copy, with the self-repair from iCloud, and at the start on a new Mac. Settings › Where your setup is kept now says: \"Apart from the weekly copy in iCloud Drive, which holds the keys and their pictures, nothing leaves the Mac.\"",
            "Safety: what a restore does NOT bring back: how often keys were pressed, counters, stopwatches and a running focus round, the allowed iPhones, the locked page group, window places, recent apps, switch states, and the Settings choices kept outside the keys file.",
            "Safety: every small script the app runs (dark mode, mute, Spotify, the Finder's bin, eject) has a time limit of 5 seconds (60 seconds for the Finder's \"empty the bin\") and runs away from the app's main work. Before: Spotify, the Finder and the calendar could wait behind each other. The Mac's volume for the iPhone's music plate is read directly, not by a script every 5 seconds.",
            "Safety: the red close button of Set up keys asks \"Save the changes to this key?\" (Save, Don't save, or Cancel, which keeps the window open) when a key is half edited. Before: no question was asked.",
            "Safety: Cancel is the Return key. In \"Delete the page group\", \"Delete page\", \"Bring over\" (Elgato) and the questions before \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\", Return and Escape both cancel, and the action needs a click. Before: in the questions about quitting, the bin and ejecting, Return did the action.",
            "Safety: if Control-Option-D belongs to another app, Settings › Keys on screen says in orange: \"Control-Option-D is used by another app, so it does not work here. Use the menu bar icon to show the keys.\" Before: it silently did nothing.",
            "Safety: typed text keeps emoji whole (cut only at whole characters), and a long text no longer holds the app up. Quitting waits at most 1 second for a box that does not answer.",
            "Repairs: a failed Shortcut is told like any failed press: \"The Shortcut “X” was not found\", or \"… did not finish\" or \"… could not be started\". A key whose Raycast command is no longer on this Mac shows a red corner and \"This Raycast command is not on this Mac\" (before: nothing happened; Raycast's own commands, scripts and AI links are never marked).",
            "Repairs: a Weather temperature older than 2 hours turns the key grey-blue and says for example \"As of 14:20\". Before: it stayed for ever with no sign. An Album cover key whose look-up failed tries again at the next change of song. Before: never again. A town's time zone that the town search did not give is no longer stored. Before: the Mac's own zone was kept for that town for ever.",
            "Saving power: keys nobody sees rest. One clock wakes only when a key needs a new picture. Seconds tick only while the Mac's page now has a timer, focus, stopwatch, breathing or bar key, or an iPhone or iPad is connected; otherwise once a minute and at a timer's end. App names are remembered instead of being looked up for every picture.",
            "Saving power: the check every 4 seconds (may it press keys, does Elgato's app run) and the look every 5 seconds for the iPhone's music plate pause while the Mac's screen sleeps, and run once at wake.",
            "PARAGON's little file may now carry a format number (missing counts as 1). If it is higher than Deck Mate knows (1), every PARAGON key and \"Due today\" show \"–\" and \"Update Deck Mate\" instead of wrong numbers. PARAGON itself has not been changed yet; it needs one small line in its next build.",
            "The keys file's format number is now 3, instead of 2, because a page group can have hours and the box an evening brightness. An older Deck Mate keeps saying at its start that the file is from a newer one.",
            "New data tests for the new rules and one screen test for the new screens.",
            "Not yet tried for real: the evening dimming of the box, the Shortcuts actions run from the Shortcuts app, the Keychain move on a future new build of the app, and everything on the real box (it is at home until January 2027)."
        ], changed: [
            "There are 45 kinds of key to choose from, instead of 42. PARAGON has 5 choices, instead of 4. There are 5 ready-made page groups, instead of 4.",
            "Timer and focus rounds keys show whole minutes, and a timer's end plays one softer sound instead of two.",
            "Cancel is the Return key in the questions before deleting, bringing over and quitting all apps, emptying the bin and ejecting all disks.",
            "Amber and green key colours are darker (see above). Settings buttons are a little darker green too.",
            "The weekly iCloud copy holds the key pictures too. The keys file's format number is 3, instead of 2.",
            "Settings › Where your setup is kept now says the weekly copy holds the keys and their pictures.",
            "How it works has new parts: \"Breathing pacer key\", \"Progress bar across keys\", \"Often used keys\", \"Now on my plan\", \"New key from…\", \"The deck suggests a key\", \"Save your keys as a PDF\", \"Hours for a page group\", \"Dimming the box in the evening\", \"Actions for Apple's Shortcuts app\" and \"My AMS apps\". It is corrected in \"Timer key\", \"On the Mac keys\", \"Where things are kept\", \"The iPhone card in Settings\", \"Weather key\", \"PARAGON keys\", \"The look of a key\", \"Set up keys\", \"What a key can do\" and \"Settings\".",
            "The Mac app is now 0.16 (build 24). The iPhone and iPad app is now 0.18 (build 23)."
        ], fixed: [
            "A failed save went unseen. Now it says so once for each run of failures.",
            "A key picture was lost with the Mac because only the keys file was copied to iCloud. Now the pictures go too.",
            "Closing Set up keys with the red button while a key was half edited asked nothing. Now it asks.",
            "Return could do the action of the questions about quitting all apps, emptying the bin and ejecting disks. Now it cancels.",
            "A shortcut taken by another app, a Raycast command gone from the Mac and a failed Shortcut gave no word. Now each says so.",
            "An old Weather temperature stayed for ever. Now it turns grey-blue with \"As of 14:20\".",
            "An Album cover that was not found was never looked for again. Now it is tried again at the next change.",
            "A town's time zone that was not found was replaced for ever by the Mac's own. Now none is stored.",
            "An emoji in typed text could be cut in half, and a long text held the app up. Now text is cut at whole characters.",
            "Quitting waited on a box that did not answer. Now it waits at most 1 second.",
            "Spotify, the Finder and the calendar could wait behind each other. Now scripts have a time limit and run away from the main work."
        ]),
        Release(id: "0.15", date: "18 Nov 2026", new: [
            "Round of safety, calmer colours and easier keys. Before: Mac 0.14 (build 22). Now: Mac 0.15 (build 23). Needs nothing new on the iPhone or iPad; the iPhone and iPad app 0.17 (build 22) adds a few things (see its What's new).",
            "Fixed, the start: when the Mac asks whether AMS Deck Mate may \"access data from other apps\" (that is PARAGON's list for the PARAGON keys; the Mac asks again after an update), the whole app used to stand still until you answered: no menu, no keys, no link to the iPhone. Now the app works while the question is open, and the PARAGON keys fill in once you click Allow.",
            "Safety, the hidden door: the app had a door meant for checks, through which other programs on the Mac could press keys by a message. It is closed. The app as you use it listens to nothing of the kind.",
            "Safety, copied passwords: before, the keys \"Search for the copied text\", \"Ask AI\" and PARAGON \"Task from the copied text\" used a copy even when a password manager had marked it as secret. Now they do not: the Mac beeps instead for the search and the task, and AI Chat just opens. \"Paste as plain text\" still pastes it, because a paste stays on the Mac. The \"Last copied text\" keys skipped such copies already.",
            "Safety, strangers on the same Wi-Fi: a device you have not allowed is asked about once per connection (before: again and again). At most 3 such devices are connected at once and at most 2 wait to be asked about. A stranger's line is closed after 30 seconds unless you are being asked about it. The window \"wants to use your keys\" closes by itself when that device goes away. After three \"Don't Allow\" within 10 minutes, nobody new is asked about for a while. The Mac reads nothing larger than a few lines of text from a phone. Your own iPhone and iPad always find room.",
            "Safety copies of the keys file: before, only the newest 20 were kept, so an hour of editing pushed out yesterday's state, and copies with names of their own took up some of the 20. Now: the newest 20, plus the last copy of each of the last 30 days, plus a copy that ordinary saving never pushes out. That copy is made just before a page group or a page is deleted, before Elgato's keys are brought over and before an earlier state is put back. The newest 10 of these stay; their names start \"deck kept\". Copies with other names are never removed.",
            "Self-repair: a damaged keys file is now also repaired from the weekly copy in iCloud Drive when no copy on the Mac can be read. Before: the iCloud copies were listed but never used for repair. A Mac with no keys file at all (a new Mac) takes the newest weekly iCloud copy by itself and says so at the start.",
            "An emptied keys file: a file that can be read but holds no page group at all now counts as damaged and is repaired. Before: it was taken as an empty setup and then saved over.",
            "Older app, newer file: a key of a kind this version does not know shows as empty and does nothing, but it is now written back exactly as it was, so a newer Deck Mate finds it again. Before: it was turned into an empty key for good. The file's format number is now 2 and is never lowered. When the file is from a newer Deck Mate, the app says so at the start.",
            "Calmer colours, red kept for real trouble. Focus rounds: purple while focusing (before: red); pause stays green; start-up, preparation and cool-down stay amber. Body Battery: green from 50, teal from 25 to 49 (before: amber), amber below 25 (before: red). Stress today: resting green, low teal, medium teal (before: amber), high amber (before: red). Resting pulse: from 5 beats over the 7-day usual the words say \"+5 over usual\" with no colour (before: amber); from 8 over, amber (before: red). Unchanged and still red: Mac very busy, Mac battery low, free space low and PARAGON overdue.",
            "Garmin board off: when the board does not answer twice in a row, the Body Battery and Garmin keys show \"–\" and \"Board off\". Before: they fell back to their plain look and a press opened a browser error. A press now starts the AMS Garmin Bridge Board app, and the keys ask again 8 seconds later. One missed answer keeps the numbers and asks again after a minute.",
            "Old numbers: steps, stress, resting pulse and Body Battery that the watch has not renewed for more than 3 hours turn grey-blue, and their small words say \"As of 06:29\" (the time of the watch's last sync).",
            "Two new numbers for the \"Garmin number\" key. Before: 5 to choose from. Now: 7. \"Days since the gym\" shows \"today\" on a gym day, otherwise the number of days. \"Gym, 7 days\" shows how many sessions, with the minutes, and is green when there was at least one. They come from the gym app's sessions that the Garmin board reads. Until the gym app has shared them, the key shows \"–\" and \"No gym data yet\".",
            "Cancelled and declined events: \"Next event\", \"Free until\" and \"Join the meeting\" now leave out events that were cancelled and events you declined. Before: a declined meeting could show as the next one.",
            "Kinds of key: the field \"What it does\" in Set up keys is now a button that opens a list with a search field on top and the 42 kinds under 8 coloured headings: Open, Type and press, Music and sound, Time, At a glance, On the Mac, Moving around and Nothing. Before: one long menu of 42 lines. Typing filters the list, also by a few other words (for example \"countdown\" finds Timer). Return takes the first kind shown. Escape closes the list.",
            "Drop it on a key: in Set up keys, drag an app, a file or a folder from the Finder, or a web address from the browser, onto an EMPTY key. The key is made (an app key with the app's icon and name; a file or folder key named after it; a link key named after the website) and opens for editing. A key that already does something is never replaced by a drop. Command-Z takes it back.",
            "Press keys from Raycast and by link: a new part in Settings, \"Raycast and links\". Deck Mate keeps a folder of small commands, one for every key that has words and does something (not Back, folders or page keys), written again whenever the keys change. Once Raycast knows the folder (Raycast: Settings › Extensions › Script Commands › Add Directories; needed once; Settings has \"Show the folder\"), every key can be found and pressed by its name in Raycast, listed under \"Deck Mate · <page group> › <page>\". A pressed key acts wherever it sits; the keys on screen and the box do not move, except for a \"Switch page group\" key. Links also exist, for your own use: press a key, show a page group, show or hide the keys on screen.",
            "Links are safe: every link carries this Mac's own pass (a random word made on this Mac), so a web page or another program cannot press your keys. Pressed this way, \"Quit all apps\", \"Empty the bin\" and \"Eject all disks\" always ask first, also when the key says \"without asking\". A switch turns the whole thing off; the folder then goes.",
            "The box (still not tried, it is at home until January 2027): after the Mac or its screen wakes, the brightness and all 15 pictures are sent again. Before: nothing was sent again, so a box that went dark could stay dark. The box diary also notes the last digits of the box's serial number, the first picture sent (its size, and whether it was sent) and the first key heard (which place, down or up), and says what to do if no key press shows up.",
            "The link to the iPhone and iPad: the Mac sends only the keys that look different. With a running timer, stopwatch or focus round, one small picture a second instead of all fifteen (about 300 KB). The iPhone asks \"are you there?\" every 5 seconds and the Mac answers. The Mac closes the line of an iPhone it has not heard from for 20 seconds. This needs the iPhone and iPad app 0.17 for the new parts; the app 0.16 keeps working as before.",
            "New data tests for the new rules.",
            "Not yet tried for real: the box wake-up, the Raycast commands in a real Raycast, and the link to the iPhone check with the real iPhone and iPad."
        ], changed: [
            "Elgato's app: the guide now says it SHOULD be quit while Deck Mate drives the box, because both apps would otherwise draw on the keys. Before: it said it must be quit, because only one can hold the box. That is not proven.",
            "The \"Garmin number\" key has 7 numbers, instead of 5. The 42 kinds of key are chosen from a list with a search field, instead of one long menu.",
            "The safety copies of the keys file: the newest 20 plus one per day for 30 days plus up to 10 copies before big changes, instead of only the newest 20.",
            "How it works has new parts, \"Drop it on a key\" and \"Press keys from Raycast and by link\". It is corrected where it still described the old iPhone and iPad screen (a battery line and a music strip; today there is one small pill with the app in front and a small music button that opens a plate). It is updated for the new colours and limits, the seven Garmin numbers, the safety copies, the self-repair, the list of kinds, the strangers and the box.",
            "The Mac app is now 0.15 (build 23). The iPhone and iPad app is now 0.17 (build 22)."
        ], fixed: [
            "A damaged keys file with no readable copy on the Mac was never repaired from iCloud. Now it is.",
            "An emptied keys file was saved over as if it were a new setup. Now it is repaired.",
            "A key of a kind unknown to an older app was turned into an empty key for good. Now it is kept as it was.",
            "A declined or cancelled meeting could show as the next event, make you look busy or be the one joined. Now it is left out.",
            "A box that went dark after sleep could stay dark. Now the Mac sends the brightness and the pictures again (not yet tried on the real box).",
            "A press on a Body Battery or Garmin key with the board off opened a browser error. Now it starts the board app and the key says \"Board off\"."
        ]),
        Release(id: "0.14", date: "18 Nov 2026", new: [
            "Two new things a key can do. This is the third and fourth round of the ideas you picked, plus two ideas of mine. Before: 40 kinds of key. Now: 42. They are in Set up keys, under \"What it does\".",
            "New kind \"PARAGON\" (purple, like shortcut keys) with a menu of four choices. Before: no key could show or add anything in PARAGON. Now: one key each.",
            "PARAGON, \"Inbox\": the key shows how many lines wait in PARAGON's Inbox, with \"Inbox\" under the number. A press opens PARAGON's Inbox.",
            "PARAGON, \"Next task\": the key shows the first task on PARAGON's list (the same one PARAGON's widget shows first): when it is due in large words, for example \"today\" or \"2 days over\", and the task's own words small underneath. An overdue task turns the key red. A press opens the task's note in PARAGON. With nothing on the list the key says \"Nothing next\".",
            "PARAGON, \"Task from the copied text\": a press puts the text you copied last into PARAGON's Inbox as a task. PARAGON does not come to the front. If nothing, or no text, is copied, the Mac beeps and nothing is saved.",
            "PARAGON, \"Quick note\": a press opens a small window on the Mac, \"Note for PARAGON\", with one text field and Cancel and Save (Return saves, Escape cancels). Save puts the words into PARAGON's Inbox as a note line. PARAGON does not come to the front. Pressed from the iPhone or iPad, the window opens on the Mac.",
            "Where the PARAGON numbers come from: PARAGON on the Mac writes a small file for its own widget each time it reloads its notes. Deck Mate only reads it, every 60 seconds. It never opens your notes folder and writes nothing there. Limits: the numbers are as fresh as PARAGON's last reload on this Mac. If the file is from an earlier day, the key shows \"–\" and \"Open PARAGON\", and a press opens PARAGON, which writes it anew. If PARAGON is not on the Mac, the key says \"No PARAGON\".",
            "Adding a task or a note uses PARAGON's own capture link, so nothing had to change in PARAGON. The Mac asks nothing new for these keys.",
            "The \"Due today\" key counts PARAGON now. Before: \"Due today (OmniFocus)\" counted OmniFocus tasks, only while OmniFocus was open. Now: \"Due today (PARAGON)\" shows the number of PARAGON tasks due today. When tasks are overdue, the small words say for example \"2 overdue\" and the key turns red. A press opens Today in PARAGON. A \"Due today\" key you already have changes by itself; nothing to set up. The question the Mac asked about controlling OmniFocus is not needed any more.",
            "New kind \"Focus rounds (PomoTimer)\" (amber while nothing runs). Its menu has PomoTimer's five ready-made plans: Classic Pomodoro (2 + 3 + 25 + 5 + 25 + 5 minutes), Four Pomodoros, Deep Work 50/10, Short Burst and Single Pomodoro. Your own templates come after the button \"Read my templates from a PomoTimer backup file…\": choose the backup file PomoTimer saves. It is read once and kept in Deck Mate; press the button again after you change templates in PomoTimer.",
            "Focus rounds, the press: it opens AMS PomoTimer in the browser and starts that template there. The key counts along: the step's name (\"Pomodoro\", \"Pause\") and the minutes and seconds left. Red during focus steps, green during pauses and long breaks, amber during start-up, preparation and cool-down. At the end it shows \"Done\" for 60 seconds.",
            "Focus rounds, while it runs: a press brings PomoTimer back to the front. A long press stops the count on the key (it does not stop PomoTimer). Only one focus run at a time. It goes on after Deck Mate restarts. The session lands in PomoTimer's history as always.",
            "Focus rounds, limits: the key counts by itself from the moment of the press. If you pause or skip a step in PomoTimer, the key does not know. A template set to wait between steps in PomoTimer runs ahead on the key. Nothing had to change in PomoTimer.",
            "The \"Spotify playlist\" key shows the cover. Before: a green key with headphones. Now: once a link is pasted, the key shows the playlist's (album's, artist's, song's, podcast's) own cover across the whole key. It is fetched once from Spotify's public look-up (the same one the Album cover key uses; only the link is sent) and kept. A key with a picture or drawing you chose yourself keeps yours. With no internet, the headphones stay until it works.",
            "\"Quit all apps\", \"Stays open\": Before: the list started empty. Now: when you choose \"Quit all apps\" for a key, the list starts filled with the apps open at that moment (without the Finder and Deck Mate, which always stay), and a button \"Take the apps open now\" fills it again. Remove what should quit. A key you already have is not changed by itself.",
            "New check \"--paragon\": it says what the PARAGON and focus keys would show right now, and does nothing else.",
            "New data tests for the PARAGON and focus rules.",
            "Not yet tried for real: none of these keys was pressed for real before this release."
        ], changed: [
            "There are 42 kinds of key to choose from, instead of 40.",
            "\"Due today\" counts PARAGON instead of OmniFocus (see above).",
            "The Mac asks nothing new for these keys, and the OmniFocus question is gone.",
            "How it works has new parts: \"PARAGON keys\" and \"Focus rounds key\", a rewritten \"Due today key\", and new lines in \"The look of a key\", \"Set up keys\", \"What a key can do\", \"Spotify playlist key\", \"On the Mac keys\" and \"What the Mac asks for\".",
            "The Mac app is now 0.14 (build 22). The iPhone and iPad app stays 0.16 (build 21) and shows the new keys without an update, because the Mac draws the keys."
        ], fixed: []),
        Release(id: "0.13", date: "18 Nov 2026", new: [
            "Twelve new things a key can do. This is the second round of the ideas you picked. Before: 34 kinds of key. Now: 40, and \"Switch (on or off)\" has a fourth choice. They are in Set up keys, under \"What it does\".",
            "New kind \"On the Mac\" (purple, like shortcut keys) with six choices. Before: no key could lock the Mac, quit apps, empty the bin or eject disks. Now: one key each.",
            "On the Mac, \"Lock the Mac\": locks the screen at once. You need your password or Touch ID to get back in.",
            "On the Mac, \"Show the desktop\": moves all windows aside so the desktop shows. A second press brings them back.",
            "On the Mac, \"Quit all apps\": quits every open app except the Finder, AMS Deck Mate itself and the apps you list under \"Stays open\" (button \"Add app…\", each with a remove button). It asks first on the Mac and names the apps, for example \"Quit 6 apps?\" with Quit and Cancel. An app with unsaved work still asks you itself. The tick \"Ask first\" is on at first and can be taken off.",
            "On the Mac, \"Empty the bin\": asks first and says how many things are in the bin, for example \"12 things will be gone for good. This cannot be undone.\" with Empty and Cancel. If your Finder is set to warn before emptying, the Finder asks once more after that. Take the tick off \"Ask first\" to see only the Finder's question. With an empty bin the key says so and does nothing. The first press makes the Mac ask once whether AMS Deck Mate may control the Finder: choose Allow. \"Ask first\" is on at first and can be taken off.",
            "On the Mac, \"Eject all disks\": asks first and names the disks, for example \"Eject 2 disks?\" with Eject and Cancel. It ejects every plugged-in disk, card, stick and disk picture. It never ejects the Mac's own disk and never a share on another computer. A disk that is still in use stays, and the key tells you which one. With no disk plugged in, it says so. \"Ask first\" is on at first and can be taken off.",
            "On the Mac, \"Paste as plain text\": pastes the text you copied without its font, size and colour. It needs the Mac's Accessibility yes, like shortcut keys.",
            "When \"Quit all apps\", \"Empty the bin\" or \"Eject all disks\" is pressed from the iPhone or iPad, the question opens on the Mac. In the question, Return does it and Escape cancels.",
            "New kind \"Join the meeting\" (blue): opens the video link of your meeting. It takes the one that starts within ten minutes, else the one going on now, else the next one within a day. It finds links of Zoom, Microsoft Teams, Google Meet, Webex, FaceTime, Whereby, Jitsi and GoTo in the event's link, place or notes. If no link is found, the key says so. It uses the same calendar yes as \"Next event\" and only reads.",
            "New kind \"Spotify playlist\" (green): paste a Spotify link (a playlist, album, artist, song or podcast; in Spotify, Share, then Copy link). A press starts it playing in Spotify. The first press makes the Mac ask once whether AMS Deck Mate may control Spotify: choose Allow. A key without a proper Spotify link shows the red corner of a broken key.",
            "New kind \"Search for the copied text\" (teal): opens your browser with a search for the text you copied last. Choose Google (at first), DuckDuckGo, Bing, Wikipedia or YouTube. A copied web address opens as it is. Of a long text only the first 300 letters are searched. If nothing is copied, nothing happens. The text goes only to the search site you picked.",
            "New kind \"Counter\" (amber): every press counts one more, shown as a large number on the key. Hold the key down (a long press) to set it back to 0. It stops at 99,999. The number is kept when the Mac restarts. Each counter key has its own number.",
            "New kind \"Stopwatch\" (amber): a press starts it and the key shows the time running. Another press pauses it. The next press goes on. Hold the key down to set it back to 0. It keeps running when AMS Deck Mate restarts. Each stopwatch key has its own time.",
            "New choice for \"Switch (on or off)\": \"Keep the Mac awake\". While it is on, the Mac and its screen do not go to sleep by themselves. Press again to switch it off. It is off again after AMS Deck Mate quits or the Mac restarts. The key says \"Awake\" or \"May sleep\".",
            "Two new drawings to pick for a key: an eject mark and a video camera. Before: 254 drawings. Now: 256.",
            "The made-up sample keys got a page with the new keys.",
            "Not yet tried for real: none of these keys was pressed for real before this release."
        ], changed: [
            "There are 40 kinds of key to choose from, instead of 34.",
            "A long press on a Counter or Stopwatch key sets it back to 0.",
            "The Mac asks for something new in two places: the Finder (\"Empty the bin\") and Spotify (\"Spotify playlist\"), each once at the first press. \"Join the meeting\" uses the calendar yes that \"Next event\" already needs.",
            "How it works has new parts: \"On the Mac keys\", \"Join the meeting key\", \"Spotify playlist key\", \"Search for the copied text key\", \"Counter key\" and \"Stopwatch key\", and new lines in \"What a key can do\", \"The look of a key\", \"Set up keys\", \"Long press: a second action\", \"Switch key (on or off)\" and \"What the Mac asks for\".",
            "The Mac app is now 0.13 (build 21). The iPhone and iPad app stays 0.16 (build 21) and shows the new keys without an update, because the Mac draws the keys."
        ], fixed: []),
        Release(id: "0.12", date: "18 Nov 2026", new: [
            "Five new kinds of key in Set up keys, under \"What it does\". Before: 29 kinds of key. Now: 34. This is the first round of the 28 ideas you picked from 50 new ones. Together they show eleven new things at a glance. Like the five glance keys of 0.11, the value stands on the key in large white words, where the drawing normally is, with small words under it. If you gave the key a title, your title replaces the small words. Until a value is there, the key shows its drawing. They show on the box, on the keys on screen and on the iPhone and iPad.",
            "New for all glance keys: a key can change its colour with its value. Before: only Body Battery did. Now: Garmin number, Mac at a glance and Free until do too, as told below.",
            "\"Garmin number\" (teal): you pick one of five numbers in Set up keys. All come from your AMS Garmin Bridge Board on this Mac, the same source as Body Battery. One look at the board, every 10 minutes, feeds all of them. Nothing leaves the Mac and the Mac asks nothing. A press opens the board in the browser. If the board is not running, the key shows its drawing.",
            "Garmin number, \"Steps today\": for example \"8 412\" with \"Steps today\" under it. The key turns green once the day's step goal is reached.",
            "Garmin number, \"Sleep last night\": the hours and minutes, for example \"7:24\", with Garmin's word for the night under it, for example \"Good\". When the watch was not worn: a dash and \"No sleep recorded\".",
            "Garmin number, \"Resting pulse\": today's number with \"Resting pulse\" under it. It is compared with the average of the last 7 days. From 5 beats over it, the small words say for example \"+6 over usual\" and the key turns amber. From 8 over, it turns red.",
            "Garmin number, \"Stress today\": today's average, with Garmin's own steps under it: up to 25 \"Resting\" (green), up to 50 \"Low stress\" (teal), up to 75 \"Medium stress\" (amber), above that \"High stress\" (red).",
            "Garmin number, \"Workouts, 7 days\": how many workouts in the last seven days, with the hours under it, for example \"7 days · 15 h\".",
            "\"Mac at a glance\" (grey-blue): you pick one of three numbers. The Mac looks every 5 seconds, only while such a key exists in your setup. The Mac asks nothing and nothing leaves it.",
            "Mac at a glance, \"Mac battery\": for example \"73%\" with \"Mac battery\" under it, or \"Charging\". Green from 40 %, amber from 20 %, red below. \"No battery\" on a Mac without one. A press opens Battery in System Settings.",
            "Mac at a glance, \"Free space\": the room left on the Mac's disk, for example \"212 GB\" (\"8.4 GB\" under ten, \"1.2 TB\" from a thousand). Amber under 25 GB or when a tenth is free, red under 10 GB or when a twentieth is free. A press opens Storage in System Settings.",
            "Mac at a glance, \"Mac busy light\": how hard the Mac's processors work, in steps of 5 %. Under it \"Mac calm\"; from 60 % \"Mac busy\" (amber); from 85 % \"Mac very busy\" (red). A press opens Activity Monitor.",
            "\"World clock\" (grey-blue, globe drawing): you type a town. The key shows the time there, for example \"14:05\", with the town under it, or \"tomorrow\" or \"yesterday\" when it is another day there than here. It follows the time every minute. The free service Open-Meteo gets the town's name once, to find its time zone. After that nothing goes out. A press opens the Mac's Clock.",
            "\"Sunrise and sunset\" (amber, sunrise drawing): you type a town. The key shows whichever comes next, on the town's own clock: for example \"16:42\" with \"Sunset\" (or \"Sunrise\") under it. It asks again every 6 hours. Open-Meteo gets the town's name once, then only its place. A press opens the Mac's Weather.",
            "\"Free until\" (your calendar): uses the same calendar yes as \"Next event\", which the Mac asks once at the first press of either; until then \"Press to allow\". While an event goes on, the key is red: \"Busy\" with \"until 15:00\". Before the next event of today that has a time, it is green: how long you are free, for example \"1 h 20\" or \"45 min\", with \"Free until 14:30\". With nothing more today: green \"Free\" with \"Rest of the day\". All-day events are left out. A press opens Calendar, or the app you chose with \"Choose app…\".",
            "Holding a key down to change its town (new in 0.11.1 for Weather) now works for World clock and Sunrise and sunset too. The small window is now called \"Town for this key\" and offers the towns you used on any of these keys.",
            "Good to know: the \"Due today\" key counts OmniFocus tasks. It will be replaced by a key for PARAGON in a later round, because your tasks are in PARAGON.",
            "Checked by the maker with real data from the Mac and from the board, and with 20 new data tests. Not yet tried for real: no key was pressed on a real screen or on the real box yet."
        ], changed: [
            "There are 34 kinds of key to choose from, instead of 29.",
            "The Mac asks for nothing new. \"Free until\" uses the calendar yes that \"Next event\" already needs.",
            "How it works has new parts: \"Garmin number key\", \"Mac at a glance key\", \"World clock key\", \"Sunrise and sunset key\" and \"Free until key\", and new lines in \"Keys that show something at a glance\", \"The look of a key\", \"Set up keys\", \"Weather key\", \"Due today key\" and \"What the Mac asks for\".",
            "The Mac app is now 0.12 (build 20). The iPhone and iPad app stays 0.16 (build 21) and shows the new keys without an update, because the Mac draws the keys."
        ], fixed: []),
        Release(id: "0.11.1", date: "18 Nov 2026", new: [
            "Hold a Weather key down to give it another town. Before: the town could only be changed in Set up keys. Now: a long press (half a second) on a Weather key opens a small window called \"Weather key\" on the Mac, with a field for the town. Type a town, or pick one of up to six towns you used before from the list in the same field. Save (Return) or Cancel (Escape). The key shows the new town's weather within a few seconds. Undo in Set up keys takes it back.",
            "It works from the box, from the keys on screen (hold the mouse button) and from the iPhone and iPad (a long press there). The window always opens on the Mac. On the iPhone and iPad a small note says \"Type the town on the Mac\".",
            "A Weather key with a long press of its own (set in Set up keys) keeps that long press, and does not open the town window.",
            "A Weather key does not show the small white long-press dot for this. The dot still means a long press of your own.",
            "Not yet tried for real: the long press on a Weather key was not pressed on the real box by the maker yet."
        ], changed: [
            "Like every key with a long press, a Weather key now acts when you let go, not at the moment it goes down. Before: a short press opened Weather the moment the key went down. Now: it opens Weather when you let go.",
            "How it works: the part \"Weather key\" tells about the long press.",
            "The Mac app is now 0.11.1 (build 19). The iPhone and iPad app stays 0.16 (build 21) and needs no update."
        ], fixed: []),
        Release(id: "0.11", date: "17 Nov 2026", new: [
            "Six new kinds of key in Set up keys, under \"What it does\". Before: 23 kinds of key. Now: 29. This is round 2 of 3 of the ideas you picked. Five of them show something at a glance: the value stands on the key in large white words, where the drawing normally is, with small words under it. If you gave the key a title, your title replaces the small words. Until a value is there, the key shows its drawing. They show on the box, on the keys on screen and on the iPhone and iPad.",
            "\"Next event\" (blue, calendar drawing): shows the next event in your calendars that has a time, looking 7 days ahead. All-day events are left out. Large words: \"Now\" while the event goes on; for example \"12 min\" in the last hour before it starts; its time, for example \"14:30\", later today; the weekday, for example \"Wed\", on another day, with the time before the title in the small words (\"09:00 Dentist\"). Small words: the event's title. With no event in 7 days: a dash and \"No events\". A press opens the Calendar app, or another app you choose with \"Choose app…\", for example Fantastical. The first time, the Mac asks once whether AMS Deck Mate may see your calendar. Until then the key says \"Press to allow\"; choose \"Allow Full Access\". Deck Mate only reads and never changes an event. If you say no, the key says \"Calendar not allowed\" (change it in System Settings › Privacy & Security › Calendars). It follows calendar changes at once and looks again every minute.",
            "\"Weather\" (teal, sun drawing): you type a town in Set up keys. Large words: the temperature in whole degrees Celsius, for example \"3°\". Small words: the sky in a word or two (Clear, Mostly clear, Partly cloudy, Cloudy, Fog, Drizzle, Rain, Snow, Showers, Snow showers, Thunder). With no town yet: \"Set a town\". Several Weather keys with different towns are fine; give each key the town as its title to tell them apart (the title then shows instead of the sky). The weather is asked for again every 20 minutes. A press opens the Mac's Weather app. Privacy: the free weather service Open-Meteo gets the town's name once, to find its place, and after that only that place (its position on the map). Nothing else about you goes out. No account, no key, and the Mac asks nothing.",
            "\"Due today\" (purple, tick drawing): the large words are the number of OmniFocus tasks that are due today or overdue (not completed, not dropped). Small words: \"Due today\". It counts only while OmniFocus is open; otherwise the key says \"OmniFocus closed\", because Deck Mate never opens OmniFocus just to count. It counts again every 2 minutes. A press opens OmniFocus on its Forecast. The first time, the Mac asks once whether AMS Deck Mate may control OmniFocus. Until then the key says \"Press to allow\"; choose Allow, or OK. Deck Mate only counts and never changes a task.",
            "\"Album cover\" (green, music note drawing until a cover is there): shows the cover of the song Spotify plays, filling the whole key, with the song's name on a dark band at the bottom. A press plays or pauses; like the other music keys it needs the Mac's Accessibility yes. The cover appears with the next song change after Deck Mate starts, because Spotify only says what plays when something changes; before that the key says \"Nothing playing\". The picture comes from Spotify's own open look-up, by the song's name only. Nothing about you is sent, and the Mac asks nothing. A podcast, an advert or a local file shows the song's name with the music note. Covers are kept in memory only.",
            "\"Body Battery\" (battery drawing): the large words are your latest Body Battery from your AMS Garmin Bridge Board, which runs on this Mac from login. Small words: \"Body Battery\". The key is green from 50, amber from 25 to 49 and red below 25, and grey-blue while there is no number. It asks again every 10 minutes. A press opens the board in the browser. Nothing leaves the Mac, and the Mac asks nothing. If the board is not running, the key just shows its drawing.",
            "\"Desk\" (blue, window drawing; without a title it says \"Desk\"): in Set up keys the button \"Take the desk as it is now\" remembers the apps that have a window on screen right now. Up to 8 apps, the front window of each, with its place and size. Small panels (under 200 × 150) are left out, and so are Deck Mate's own windows. The list shows each app with its window size, for example \"Safari · 1200 × 800\", and a button to take one out. A press opens every app of the desk and puts each one's front window back in its place and size; it waits up to about 8 seconds for an app that is still opening. It needs the Mac's Accessibility yes, the same one the shortcut, text and music keys use; the Mac asks at the first press if it was never given. A Desk key also works as a long press and as a step of \"Several things in a row\". A desk whose app is no longer on this Mac is marked as broken (\"An app of the desk is not on this Mac\"); a desk with nothing in it says \"No windows taken yet\".",
            "The Mac looks things up only while a key of that kind exists in your setup. The iPhone and iPad need no update, because the Mac draws the keys.",
            "Round 3 will bring the dial key on iPhone and iPad and the resting box.",
            "Not yet tried for real: none of the six was pressed on a real screen yet by the maker. The first press of \"Next event\" and of \"Due today\" each brings one question from the Mac. The box is at home until January 2027."
        ], changed: [
            "There are 29 kinds of key to choose from, instead of 23.",
            "The Mac now asks for two more yeses, each once and only when you press such a key: to see your calendar (Next event) and to control OmniFocus (Due today). Before: only Accessibility, and System Events for dark mode.",
            "How it works has new parts: \"Keys that show something at a glance\", \"Next event key\", \"Weather key\", \"Due today key\", \"Album cover key\", \"Body Battery key\" and \"Desk key\", and new lines in \"What a key can do\", \"The look of a key\", \"Set up keys\" and \"What the Mac asks for\".",
            "The Mac app is now 0.11 (build 18). The iPhone and iPad app stays 0.16 (build 21) and needs no update, because the Mac draws the keys."
        ], fixed: []),
        Release(id: "0.10", date: "17 Nov 2026", new: [
            "Six new kinds of key in Set up keys, under \"What it does\". Before: 17 kinds of key. Now: 23.",
            "\"Timer\": pick the minutes (1, 2, 3, 5, 10, 15, 20, 25, 30, 45 or 60). A press starts it and the key counts down, second by second, for example \"4:59\". Another press stops it. When the time is up, the Mac plays a sound twice and the key says \"Done\" for one minute, or until you press it. A key without a title shows \"5 min\". Two keys with the same minutes are the same timer. The key is amber. The countdown shows on the box, on the keys on screen and on the iPhone and iPad. A timer is forgotten when Deck Mate quits.",
            "\"Switch (on or off)\" with three choices: \"Dark mode\" (switches the Mac between light and dark; the first time, the Mac asks once whether Deck Mate may control \"System Events\", and you choose Allow), \"Mute the sound\", and \"Two things in turn\" (you set what happens when it goes on and what happens when it goes off; the key remembers which it is, also after a restart). The key shows a small switch mark in its top-left corner: filled when on, an outline when off. Without a title it says \"Dark\" or \"Light\", \"Muted\" or \"Sound on\", \"On\" or \"Off\". The key is purple. Dark mode and mute follow the Mac also when you change them somewhere else (mute within about two seconds).",
            "\"Run an Apple Shortcut\": pick one of the Shortcuts from the Shortcuts app in a list (\"Pick a Shortcut…\"), or type its name. A press runs it. A key with no Shortcut picked gets the red corner \"No Shortcut picked\". The key is purple.",
            "\"List to pick from\": one key that opens a small list at the mouse pointer. Each entry has a name and does one thing: open an app, open a link or a file, Raycast, a keyboard shortcut, type text, music and sound, or run an Apple Shortcut. Click an entry to run it. A click elsewhere, a second press or ten seconds puts the list away. Tapped on the iPhone or iPad, the list shows on the Mac. An entry without a name shows what it does.",
            "\"Open app\": a key that stands for one of the apps open right now (1st to 15th, in the order they were opened; an app keeps its place while it stays open, and a newly opened app goes to the end). It shows that app's own icon and name, and a press brings the app forward. With fewer apps open it says \"No app\".",
            "New button \"Add an “Open apps” folder\" in Set up keys, under the page's buttons. It puts a folder key on the first empty place of the page. Inside are Back and Open app 1 to 14, so the folder is always a live picture of what is open. When the page is full, it says so and changes nothing.",
            "\"Microphone light\": shows whether any app is listening to the Mac's microphone right now. A red key with a microphone and \"Mic in use\", or a grey-blue key with a crossed-out microphone and \"Mic free\". It changes within about two seconds. A press does nothing. It only looks and never changes the microphone. Two drawings were added from the AMS icon library, a microphone and a crossed-out microphone: 254 drawings to pick from now, instead of 252.",
            "New step \"Wait\" in \"Several things in a row\": half a second, 1, 2, 3, 5 or 10 seconds between two steps. It is for an app that needs a moment to open. A Timer, a Switch and \"Run an Apple Shortcut\" can also be steps.",
            "Find a key, on the keys on screen. Click the new magnifier in the top line, or press Space or / while the keys have the keyboard (right after Control-Option-D). Type a few letters: up to six keys from all page groups and pages whose title, page or page group holds every word you typed are listed under the keys, titles that start with the word first, each with its place (\"Page group · Page\"). Up and down arrows choose, Return or a click runs the key and shows its page, Delete takes a letter away, Escape leaves the search (Escape again hides the keys). Keys that only move around (Back, next page, previous page) are not listed. While you search, letters go to the search and not to the keys.",
            "Settings has a new part, \"Key use\", in the list on the left. Deck Mate now counts each press of a key that does something on the Mac: from the box, the keys on screen, the keyboard, the iPhone and the iPad. It shows since which day it has counted, \"Pressed most\" (the five most pressed keys with their numbers) and \"Not pressed in the last 30 days\" (during the first 30 days: \"Not pressed since <day>\"). That is a list for tidying up, each key as \"Page group · Page · “Title”\". Keys that only move around (folders, Back, pages, page group) and the microphone light are not counted. Only the number and the time of the last press are kept, in a small file \"use.json\" beside your keys file on this Mac. It is not part of the iCloud copy.",
            "Ready-made page groups. In Set up keys, the + beside \"Page groups\" now opens a small list: \"Empty page group\" and four ready-made ones, Finder, Safari, Notion and Fusion. Each has one page of keyboard-shortcut keys for that app. The new page group shows by itself when that app is in front, unless another page group already belongs to that app (yours for Notion does). Then it belongs to no app and shows only when you pick it. If a page group of that name exists, the new one is named for example \"Notion (ready-made)\". Nothing you have is changed, and Undo takes it back.",
            "Round 1 of 3. You picked these from a list of 25 ideas. Round 2 will bring the keys that need a yes from the Mac first: next calendar event, weather, OmniFocus tasks due today, album cover, Body Battery and the \"Desk\" key. Round 3 will bring the dial key on iPhone and iPad and the resting box.",
            "Not yet tried for real: everything was checked with made-up keys and small tests. Dark mode's one-time question, running a real Apple Shortcut, and the timer on the real box are not tried yet. The box is at home until January 2027."
        ], changed: [
            "The key \"Several things in a row\" was already there, under that name. What is new is the step \"Wait\". Before, steps always ran a third of a second apart. Now they still do, unless you put a Wait between them.",
            "On the keys on screen, the keyboard now also knows Space and / for finding a key. Before, only the places, the arrows, Tab and Escape.",
            "There are 254 hand-drawn drawings to pick from, instead of 252.",
            "How it works has new parts: \"Timer key\", \"Switch key (on or off)\", \"Apple Shortcut key\", \"List to pick from\", \"Open app keys\", \"Microphone light\", \"Several things in a row and Wait\", \"Find a key\", \"Key use\" and \"Ready-made page groups\", and new lines in \"Keys on screen\", \"The look of a key\", \"Set up keys\", \"What a key can do\" and \"Settings\".",
            "The Mac app is now 0.10 (build 17). The iPhone and iPad app stays 0.16 (build 21) and needs no update, because the Mac draws the keys."
        ], fixed: []),
        Release(id: "0.9.4", date: "17 Nov 2026", new: [
            "One more hand-drawn drawing to choose for a key in \"Set up keys\", where you pick a key's drawing: Drawer (a drawer front with a small handle).",
            "There are now 252 drawings to choose from, instead of 251. It is drawn in the same style as all the others (one line, round ends, no fill) and comes from the shared AMS icon library, so the other AMS apps can use the same drawing.",
            "Existing keys keep their drawings. The new one shows on the Stream Deck, on the keys on screen, and on the iPhone and iPad, because the Mac draws the keys. No iPhone or iPad update is needed."
        ], changed: [
            "In your page group \"My Apps\", on the page \"Home & trips\", the GridFit key (place 9) now shows the white drawer drawing, the same mark AMS Apps Overview shows for AMS Snug GridFit. Before, it showed Autodesk Fusion's app icon. You chose this yourself (\"Use the drawer\").",
            "The key still opens Autodesk Fusion, stays blue because it opens an app, and did not move. Nothing else changed. A copy of the keys from before is in Backups.",
            "No new test, because there is no new rule: there are still 52 tests. The Mac app is now 0.9.4 (build 16); the iPhone and iPad app stays 0.16 (build 21)."
        ], fixed: []),
        Release(id: "0.9.3", date: "17 Nov 2026", new: [
            "A key can now show a picture instead of a white hand-drawn drawing, for example an app's real icon. Before, only a key that opens an app installed on the Mac showed a real icon; a key that opens a web address or a file could only show a white drawing.",
            "The picture is a file in the folder \"Pictures\" beside your keys (in AMS Deck Mate's folder under Application Support). A key points to it by name. It is drawn with rounded corners like an app icon, 36 of the key's 72 points wide when the key has a title and 46 when it has none. The key's tile keeps the colour of its kind, so links stay teal. If the picture file is missing, the key shows the usual automatic drawing for what it does.",
            "It shows on the Stream Deck, on the keys on screen, in Set up keys and \"All pages\", and on the iPhone and iPad, because the Mac draws the keys. No iPhone or iPad update is needed; that app stays 0.16 (build 21).",
            "In Set up keys the Icon button says \"Own picture\" for a key that shows one. Picking a drawing or \"Automatic\" replaces the picture. There is no button yet to choose a picture file in the app: the AMS Apps Overview tool (Tools/deck-pages.py with --icons) puts the pictures there and copies the icon files.",
            "The weekly copy in iCloud Drive and the safety copies hold only your keys, not the Pictures folder. The tool can put the pictures back at any time.",
            "A new test checks that a key can name a picture of its own. There are now 52 tests, instead of 51."
        ], changed: [
            "In your page group \"My Apps\" (34 app keys on 5 pages), 10 web-app keys now show the app's real icon. Before, they showed a white drawing: Breathing (a breath drawing), Cold Shower (an ice bath), Big 12S (a book), Tracking (a badge), Tri Glossary (a triathlon drawing), FermentLog (a bottle), PackTrack (a box), CountDown (an hourglass), PomoTimer (a stopwatch) and TechLingo (a laptop).",
            "The Timers key changes from a watch drawing to the stopwatch drawing, the same mark AMS Apps Overview shows for Timers.",
            "The five \"Overview\" keys, bottom right on each of the five pages, now show AMS Apps Overview's own app icon. Before, they showed a white list drawing. In all, 16 keys changed their icon: 10 web apps, Timers and the 5 Overview keys.",
            "The 20 keys that open an installed app already showed the real icon and are unchanged. Three apps have no icon of their own and keep their drawing: Ironman plan (triathlon), Wealth (wallet) and Nutrition (food). GridFit keeps Autodesk Fusion's icon, because it opens Fusion and has no icon of its own.",
            "No key moved. A copy of the keys from before is in Backups. The number of hand-drawn drawings to pick from is unchanged: 251. The Mac app is now 0.9.3 (build 15); the iPhone and iPad app stays 0.16 (build 21)."
        ], fixed: []),
        Release(id: "0.9.2", date: "16 Nov 2026", new: [
            "Six new hand-drawn drawings to choose for a key in \"Set up keys\", where you pick a key's drawing: Home (a small house), Arrow up, Arrow left, Arrow right, Window top half and Window bottom half.",
            "Before, there was no house, only an arrow down, and for windows only left half, right half and full window. Now there are arrows in all four directions, and window top half and bottom half join the other three window drawings.",
            "There are now 251 drawings to choose from, instead of 245. They are drawn in the same style as all the others (one line, round ends, no fill) and come from the shared AMS icon library, so the other AMS apps can use the same drawings.",
            "Existing keys keep their drawings. The new ones show on the Stream Deck, on the keys on screen, and on the iPhone and iPad, because the Mac draws the keys. No iPhone or iPad update is needed. The Mac app is now 0.9.2 (build 14); the iPhone and iPad app stays 0.16."
        ], changed: [], fixed: []),
        Release(id: "0.9.1", date: "16 Nov 2026", new: [], changed: [
            "Before, Raycast keys were a red-orange that looked close to the amber of \"type text\" keys. Now they are a clear red, like Raycast's own red, a little deeper so the white words and drawings stay easy to read.",
            "The new red shows everywhere the Mac draws keys: the box, the keys on screen, Set up keys and \"All pages\". The Raycast headings in Settings and in the guide use the matching red.",
            "On the iPhone and iPad the keys and the small page pictures in the navigation picture get the new red by themselves once the Mac app is updated. No iPhone or iPad update is needed. The Mac app is now 0.9.1 (build 13); the iPhone and iPad app stays 0.15."
        ], fixed: []),
        Release(id: "0.9", date: "16 Nov 2026", new: [
            "A weekly copy of your keys in iCloud Drive. Once a week the Mac puts a copy of your keys file into iCloud Drive, in the folder \"AMS Deck Mate\", named by its day, for example \"deck 2026-11-16.json\". The newest 8 are kept (about two months) and older ones are removed. The Mac looks at start and every 6 hours whether a week has passed.",
            "In Settings, \"Where your setup is kept\": a switch \"Keep a weekly copy in iCloud Drive\" (on at first), a line \"Last copy: <date and time>\" (or \"No copy yet\") and a button \"Copy now\".",
            "The first time, macOS asks once whether AMS Deck Mate may use iCloud Drive. Choose Allow. If iCloud Drive is not switched on on this Mac, Settings says so and nothing is copied.",
            "\"Bring back an earlier state…\" now also lists the iCloud copies, marked \"iCloud\".",
            "Only the keys file goes to iCloud Drive. No copied texts and no permissions for iPhones.",
            "The key \"Last copied text\" has a fourth choice, \"A list to pick from\". Press it and a small list appears at the mouse pointer with your earlier copied texts (up to three, each with its first 60 letters). Click one and it is pasted where your cursor is, like the 1st, 2nd and 3rd keys. Click anywhere else, press the key again, or wait 10 seconds and the list goes away.",
            "That key shows a clipboard drawing and the words \"Copied texts\". Pressed from the iPhone, iPad or the box, the list also opens on the Mac, because the choice is made with the mouse."
        ], changed: [
            "Before, your keys and their 20 safety copies lived only on this Mac, so a lost or broken Mac meant lost keys. Now there is also a weekly copy in iCloud Drive.",
            "Before, \"Last copied text\" had three choices (1st, 2nd, 3rd). Now it has four.",
            "The Mac app is now 0.9 (build 12). The iPhone and iPad app is 0.12 (build 17). The link between them is unchanged.",
            "How it works has new lines in \"Last copied text key\" and \"Where things are kept\"."
        ], fixed: []),
        Release(id: "0.8", date: "16 Nov 2026", new: [
            "New key \"Last copied text\". In Set up keys, under \"What it does\", choose \"Last copied text\" and pick 1st, 2nd or 3rd: 1st is the text copied just before the current one, 2nd the one before that, 3rd the one before that. The key shows the first words of that text (18 letters). Press it and the text is pasted where your cursor is, and it becomes the text you copied last.",
            "Deck Mate remembers your last 4 copied texts (the current one and three before it) in memory only. They are never written to a file and are gone when the app quits. Copies that a password manager marks as secret are skipped. Deck Mate only watches what you copy while at least one such key exists. It needs the same Accessibility yes as \"Type text\". The key is amber.",
            "New key \"Recent file\". Pick 1st, 2nd or 3rd: the file you opened last, the one before, the one before that. The key shows the file's name and a press opens it. The list comes from the Mac's own record of opened files: the last 7 days, inside your home folder, without the Library folder, hidden files, folders and apps. It is only looked up while such a key exists. The key is teal. Before there is a file it shows \"Recent file\".",
            "New button \"Bring back an earlier state…\" in Settings, \"Where your setup is kept\". It opens a list of the safety copies, newest first, each with its date and time and for example \"3 page groups · 47 keys\". Pick one and choose \"Bring back\" (or Cancel; Escape is Cancel). Your setup as it is now is first kept as a safety copy, and Undo (Command-Z) also takes it back.",
            "The link to the iPhone and iPad is now private. Every message is scrambled from the first moment. Before, key pictures, taps and the permission code travelled readable on the Wi-Fi, so on a shared Wi-Fi (hotel, café) someone could listen in and press your keys. Now nobody can.",
            "The first time an iPhone or iPad asks, the Mac's question and the device both show the same 4-digit number. The Mac says: \"Allow only if your iPhone shows the same number.\" The number comes from both sides, so nobody can sit in between and fake it.",
            "Allow always takes a click with the mouse. The Return key and Escape both mean \"Don’t Allow\", so a key you press while typing somewhere else can never let a stranger in.",
            "After you allow, the device proves who it is every time without ever sending its secret, and the Mac proves itself to the device the same way.",
            "The Mac closes a connection that has not finished starting within 10 seconds, and accepts at most 8 connections at once.",
            "Works with the iPhone and iPad app 0.11 (new \"Mac is back\" note)."
        ], changed: [
            "Every iPhone and iPad has to be allowed once more, with one click on the Mac. The old permissions are removed.",
            "Mac 0.8 only talks to the iPhone and iPad app 0.11 or later, and the app 0.11 only to Mac 0.8 or later. An older iPhone or iPad app sees \"said no\". With an older Mac, the new app says \"Update AMS Deck Mate on your Mac\".",
            "Before, a damaged keys file made the app start silently with empty starter keys. Now it brings back the newest safety copy that can be read, keeps the damaged file in the Backups folder as \"damaged <date>.json\", and tells you which copy (date and time) it used. If no copy can be read, it starts with empty keys and says so.",
            "The box diary used to only grow. Now, at each start, a diary over 1,000 lines is cut to its last 500.",
            "The iPhone and iPad app is now 0.11 (build 16). The Mac app is 0.8 (build 11).",
            "How it works has two new parts, \"Last copied text key\" and \"Recent file key\", and new lines in \"What a key can do\", the iPhone parts and \"Where things are kept\"."
        ], fixed: [
            "A damaged keys file no longer means silently losing your keys: the Mac now repairs it from a safety copy (see above)."
        ]),
        Release(id: "0.7.1", date: "16 Nov 2026", new: [
            "Works with the iPhone and iPad app 0.10.1: a swipe up or down on the keys there now shows the next or previous page group without locking it."
        ], changed: [
            "Before, a swipe on the iPhone or iPad changed the page group and locked it, so it stayed when another app came forward on the Mac. Now the Mac shows the page group but stays on \"Automatic\", so the next time a different app comes forward, the keys follow that app again. If a group was locked before the swipe, the swipe unlocks it.",
            "Picking a page group in the menu or in the iPhone's Settings, and tapping a page in the navigation picture, still lock it. With \"My own keys\" nothing changes.",
            "With an older iPhone or iPad app (before 0.10.1) a swipe still locks, as before."
        ], fixed: []),
        Release(id: "0.7", date: "16 Nov 2026", new: [
            "New key \"Recent app\". In Set up keys, under \"What it does\", choose \"Recent app\" and pick 1st, 2nd or 3rd. It shows the icon and name of an app you used before the one in front: 1st is the app just before, 2nd the one before that, 3rd the one before that.",
            "The picture changes by itself as you switch apps, on the box, on the keys on screen and on the iPhone and iPad. Press the key and that app comes forward.",
            "Deck Mate's own windows never count. The list of recent apps is remembered when the Mac restarts.",
            "Until enough apps have been used, the key shows a clock drawing and the word \"Recent\" in blue, the app colour.",
            "Three of them side by side, set to 1st, 2nd and 3rd, show your last three apps.",
            "New key \"Ask AI about copied text\". In Set up keys, under \"What it does\", choose \"Ask AI (copied text)\". It opens Raycast AI Chat with the text you last copied already filled in. The key is Raycast red-orange with an AI drawing and the title \"Ask AI\".",
            "If nothing is copied, or you copied a picture, AI Chat just opens. Very long text is cut at 4,000 characters.",
            "Not yet tried against the real Raycast. This is a first version: if the text does not show up in AI Chat, tell me.",
            "The Mac now tells a connected iPhone or iPad when its screen goes to sleep and when it wakes. The iPad and iPhone app at 0.9 uses this for its new dark screen."
        ], changed: [
            "The iPhone and iPad app is now 0.9 (build 13).",
            "How it works has two new parts, \"Recent app key\" and \"Ask AI about copied text\", and new lines in \"What a key can do\" and in the part about the iPhone and iPad."
        ], fixed: []),
        Release(id: "0.6", date: "16 Nov 2026", new: [
            "Navigation picture on the iPad. When an iPad is held on its side (wider than tall), the key screen now has the keys on the right and, on the left, a picture of everything you have set up: every page group, with every one of its pages and folders as a small picture of its 15 keys and the page's name under it.",
            "The page showing now has a coloured frame, and the name of its page group is highlighted. When the list is long, it scrolls.",
            "It is live. Tap a small page and the keys go there. When the iPad follows the Mac, the Mac goes there too, and that page group is locked, just as if you had picked it in the top-line menu. \"Automatic\" in that menu lets it follow the app in front again.",
            "With \"My own keys\", only the iPad's own place moves, and the page group you picked is remembered.",
            "An iPad held upright and the iPhone look and work as before, because there is no room on the left.",
            "In Settings on the iPhone and iPad, the Keys card has a new switch \"Navigation picture\" (on at first), with the note that it shows on an iPad held on its side.",
            "The Mac draws the small pictures and sends them to the iPad whenever your setup changes.",
            "Version rule: the navigation picture needs the Mac at 0.6 and the iPhone and iPad app at 0.8. With an older Mac app the picture stays hidden and everything else works as before.",
            "Not yet tried: the navigation picture on the real iPad."
        ], changed: [
            "The iPhone and iPad app is now 0.8 (build 11).",
            "How it works has a new line in the part about the iPhone and iPad."
        ], fixed: []),
        Release(id: "0.5", date: "16 Nov 2026", new: [
            "Long press: every key can have a second action that runs when you hold the key. In Set up keys, under \"What it does\", there is a new picker \"Long press\": Nothing, or anything a key can do except \"Folder of keys\", filled in like the normal action.",
            "A key with a long-press action shows a small white dot in its top right corner: on the box, on the keys on screen and on the iPhone and iPad.",
            "Hold a key for half a second (0.5 seconds): on the iPhone and iPad (with a stronger buzz), on the Mac's keys on screen (hold the mouse button) and on the box. A long press on a key without a second action does the usual thing.",
            "On the box and on the Mac's keys on screen, a key with a long-press action acts when you let go of it: the usual action if you let go early, the second action after half a second. All other keys act at once, as before.",
            "A long-press action that is broken (its app, file or folder is gone) shows the red corner, with \"Long press: …\" and the reason in Set up keys. It is saved in deck.json as \"held\" on the key.",
            "Favourites row: 5 keys that stay in place on every page and in every page group. They show only on the iPhone and iPad, as a row under the 15 keys. Not on the box and not on the Mac's keys on screen.",
            "Set up keys: a row \"Favourites\" of 5 places under the 15 keys. Click one and edit it like any key: title, icon, what it does and long press. A favourite can be anything except a folder or Back. Copy and Paste work on favourites; dragging does not. It is saved in deck.json as \"favourites\".",
            "A favourite that moves to another page or page group moves the place of the iPhone or iPad when it has its own keys, and otherwise the Mac's place.",
            "All pages: Set up keys has a new button \"All pages\" at the top right of the Keys column. It shows every page group with every page and folder as a small picture of its 15 keys, with its name and number of keys under it. Folders have the folder mark, and the page you are editing has a coloured frame. Click a page to open it for editing. \"Back to the keys\", or Escape, goes back.",
            "iPhone and iPad, My own keys: in Settings, a new card \"Keys\" at the top. \"Follow the Mac\" is as before. \"My own keys\": pick a page group, and the iPhone or iPad moves through that group on its own: pages, folders and Back, at its own place.",
            "With own keys, the Mac's keys on screen and the box stay where they are, and the Mac still does what the tapped key says. Swipe up or down, or the top-line menu, changes the own page group, and it is remembered on the device. There is no lock and no \"Automatic\" then. If the group is gone, the default group shows. Keys pressed elsewhere do not light up on that device.",
            "The Mac keeps one place for each connected device while it is connected; after connecting again the device starts at the first page of its group.",
            "iPhone and iPad, Mac at a glance: the top line shows a small battery drawing and the Mac's battery in percent with the app in front, for example \"82 % · Safari\" (\"82 % charging · Safari\" while it charges). A Mac without a battery shows only the app. A switch \"Mac at a glance\" in Settings (on at first).",
            "iPhone and iPad, Music strip: above the keys, song and artist, play or pause, next, quieter, the Mac's volume in percent and louder (6 points per tap), with Spotify and Apple Music. A switch \"Music strip\" in Settings (on at first). A switch \"Favourites row\" too.",
            "The strip says \"Nothing playing yet\" until the next change of song or pause after the Mac app has started, because the Mac hears about it from the player when something changes.",
            "Play or pause and next need the same one-time Accessibility permission as music keys. Volume needs none. The Mac looks at battery and volume every 5 seconds, only while such a device is connected.",
            "Version rule: the new parts need the Mac at 0.5 and the iPhone and iPad app at 0.7. With an older Mac, the iPhone Settings say \"Needs AMS Deck Mate 0.5 on the Mac\" in the Keys card and the new parts stay hidden. A Mac at 0.5 with an older iPhone app works as before (the dot still shows on the key pictures).",
            "Not yet tried: long press on the real box (the box is away until January 2027), long press on the real iPhone and iPad, and play or pause from the strip."
        ], changed: [
            "The iPhone and iPad app is now 0.7 (build 10). An iPhone or iPad at 0.7 with an older Mac works as before, and Settings says \"Needs AMS Deck Mate 0.5 on the Mac\" on the new parts.",
            "Keys with a long-press action now act when you let go on the box and on the Mac's keys on screen (all other keys act at once, as before).",
            "How it works has new parts, \"Long press: a second action\" and \"The favourites row\", and a new part for the iPhone and iPad. The part \"Set up keys\" tells about \"All pages\".",
            "The word “profile” is now “page group” everywhere."
        ], fixed: []),
        Release(id: "0.4.2", date: "16 Nov 2026", new: [
            "Keys on screen: a profile picked by hand (from the menu bar menu, or from the iPhone or iPad) now shows a small hand-drawn lock beside the profile name. Locked means the profile stays until you choose \"Automatic\" in the menu bar menu. Without the lock, the profile follows the app in front.",
            "Menu: the first line now reads \"Profile: <name> (locked)\" or \"(automatic)\"."
        ], changed: [
            "The word \"held\" is gone everywhere; the texts now say \"locked\".",
            "The iPhone and iPad app is now 0.5.2 (its profile menu says \"Lock one\"). The two work together in any mix of versions."
        ], fixed: [
            "Nothing else changed in this version."
        ]),
        Release(id: "0.4.1", date: "16 Nov 2026", new: [
            "Keys on screen: while they have the keyboard (right after showing them with Control-Option-D or the menu), each key shows its keyboard letter in a small round mark in its top-left corner: 1 2 3 4 5 on the top row, Q W E R T in the middle and A S D F G at the bottom.",
            "The letters go away as soon as the keyboard goes back to the app you were in (after a key that does something on the Mac, or after a click on the keys). So letters showing means typing works right now.",
            "The letters show only on the keys on screen. The box, the iPhone and Set up keys show none."
        ], changed: [
            "Mac app only. The iPhone app stays at 0.4."
        ], fixed: [
            "Nothing else changed in this version."
        ]),
        Release(id: "0.4", date: "16 Nov 2026", new: [
            "iPhone: the keys sit low on the screen, near the thumb. The 15 keys are at the bottom and the place line is on top.",
            "iPhone: swipe left or right on the keys to go to the next or previous page. Small page dots under the keys show which page you are on. There are no dots inside a folder or when there is only one page.",
            "iPhone: tap the top line (the profile name) for a menu: \"Automatic\", or hold one of the profiles. It is the same as the Mac's menu.",
            "iPhone: pressed keys light up. A key pressed on the box, on the keys on the Mac screen or on the iPhone shows as pressed on the iPhone.",
            "iPhone: a short note at the bottom says what ran after a tap, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". When the Mac could not do it, the note is red with a warning drawing, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "iPhone: a hint after 20 seconds of \"Looking for your Mac…\". It says to turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu, with a button \"Open Settings\" and a close (x) button.",
            "The iPhone needs the Mac at 0.4 for the new parts (lighting up, the notes, the profile menu).",
            "Keys on screen: a keyboard. Right after showing them (Control-Option-D or the menu), the keys 1 to 5, Q to T and A to G press the 15 keys, in the same places on every keyboard. Left and right arrows, or Tab and Shift-Tab, change page. Escape hides them. After a key that does something on the Mac, the keyboard goes back to the app you were in.",
            "Menu: it now shows what is going on: \"Profile: <name> (automatic)\" or \"(held)\", \"iPhone: connected – <name>\" or \"iPhone: none connected\", and the box line.",
            "Menu: \"Profile for <the app in front>\" lists the profiles and \"None – use the default\". Pick one and that profile shows by itself whenever that app is in front. The app is taken off any other profile.",
            "Set up keys: drag keys to move or swap them. Drop a key on a page chip at the top to move it to that page, to the same place; a key already there swaps. A folder key takes its folder along.",
            "Set up keys: copy and paste keys with Command-C and Command-V when a key is picked and no text is being edited. The pasted key replaces the picked one.",
            "Set up keys: \"Duplicate page\" beside Delete page copies the page and its folders, named \"… copy\". \"Duplicate profile\" beside Make default copies the profile; the copy belongs to no app.",
            "Set up keys: Undo and Redo (Command-Z and Shift-Command-Z, also two buttons) for the last 30 changes, for as long as the app runs. The safety copies on disk stay as before.",
            "Broken keys show red: a key whose app, file or folder, Raycast extension, folder page or profile is gone gets a small red mark in its corner, on the screen and in Set up keys. The picked key shows the reason in one line.",
            "Settings, \"Check keys\": the button \"Check all keys\" lists every broken key as \"Profile · Page · key: reason\".",
            "Settings, \"First time with the box\": the steps for the first day with the real box (quit Elgato's app, plug the box in, allow Input Monitoring if the Mac asks), the box's answer in plain words, and a button to show the box diary.",
            "Raycast: commands from an extension now show that extension's own icon, taken from the installed extension. Raycast's own commands keep the hand-drawn drawings.",
            "The 22 hand-drawn deck drawings are now also in the AMS Icon Library, as app marks."
        ], changed: [
            "iPhone: the screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "iPhone: the \"could not do it\" note and the hotspot hint use the app's own warning and close drawings.",
            "Settings is shorter: a list on the left (The box, First time with the box, Keys on screen, iPhone, Profiles, Check keys, This Mac, From Elgato, Where it is kept) and one part at a time on the right, instead of one long scroll.",
            "Pictures for checks never show real data: the sample Settings picture shows a made-up iPhone."
        ], fixed: [
            "Raycast: two of Raycast's own links were wrong and are corrected. AI Chat is now raycast://extensions/raycast/ai/ai-chat and Search Quicklinks is now raycast://extensions/raycast/quicklinks/search-quicklinks.",
            "The other built-in Raycast links could not be checked from this Mac. If one does not work, use \"Copy Deeplink\" in Raycast and paste it."
        ]),
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
