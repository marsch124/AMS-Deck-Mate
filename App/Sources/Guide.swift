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
            "After a key that does something on the Mac, the keyboard goes back to the app you were in.",
            "Since 0.4.1, while the keys on screen have the keyboard, each key shows its letter in a small round mark in its top-left corner: 1 2 3 4 5 on the top row, Q W E R T in the middle and A S D F G at the bottom.",
            "The letters go away as soon as the keyboard goes back to the app you were in, after a key that does something on the Mac or after a click on the keys. So letters showing means typing works right now.",
            "The letters show only on the keys on screen, not on the box, the iPhone or in Set up keys.",
            "A key whose app, file, folder, Raycast command, folder page or page group is gone shows a small red mark in its corner.",
            "Since 0.5, a key with a long-press action shows a small white dot in its top right corner. Hold the mouse button on it for half a second and the second action runs. Let go sooner and the usual action runs.",
            "A key with a long-press action acts when you let go of the mouse button, so the Mac can tell a short click from a long one. All other keys act at once, as before.",
            "The favourites row is not shown on the keys on screen. It is for the iPhone and iPad."
        ]),
        Section(id: "look", title: "The look of a key", part: "keys", lines: [
            "A key is a flat coloured tile with a white hand-drawn icon and a short title.",
            "Each kind has its own colour: apps blue, links teal, Raycast red-orange, keyboard shortcuts purple, typed text amber, music and sound green, moving around grey-blue.",
            "A key that opens an app shows the app's own icon, unless you pick a hand-drawn one.",
            "A key that opens an app and has no words of its own shows the app's name, for example Mail, Safari or Calculator. Words you write on a key always win. This is the same on the box, on the screen and on the iPhone.",
            "There are 245 hand-drawn icons to pick from."
        ]),
        Section(id: "setup", title: "Set up keys", part: "keys", lines: [
            "Open it from the menu. Page groups are on the left, under \"Page groups\": add (\"Add a page group\"; the new one is named \"New page group\"), rename, delete, make default, and \"Use with apps\".",
            "In the middle are the 15 keys, with the pages and folders of the page group above them. You can add and delete pages.",
            "Since 0.5, \"All pages\" (top right of the Keys column) shows every page group with every page and folder as a small picture of its 15 keys. Under each picture are its name and the number of keys; a folder has the folder mark; the page you are editing has a coloured frame. Click a page to open it for editing. \"Back to the keys\", or Escape, goes back.",
            "Click a key to edit it on the right: Title, Icon and \"What it does\".",
            "Every edit has Cancel and Save. Escape is Cancel.",
            "\"Clear key\" empties a key. \"Try it\" runs the key.",
            "Move keys by dragging: drop a key on another place to move it there, or to swap with the key that is there. Drop a key on a page chip at the top to send it to that page, to the same place. A key already there swaps. A folder key takes its folder along.",
            "Copy and paste: with a key picked, Command-C copies it and Command-V pastes it. The pasted key replaces the picked one. This works when you are not typing in a text field.",
            "\"Duplicate page\" (beside Delete page) copies the page and its folders. The copy is named \"… copy\". \"Duplicate page group\" (beside Make default) copies the page group. The copy belongs to no app yet.",
            "Undo and Redo: Command-Z and Shift-Command-Z, or the two buttons in Set up keys. They go back through the last 30 changes for as long as the app runs. The safety copies on disk stay as before.",
            "A broken key has a red mark in its corner, on the screen and in Set up keys. Pick it and one line tells you what is missing.",
            "Since 0.5, under \"What it does\" there is a second picker, \"Long press\". See \"Long press: a second action\" below. Under the 15 keys there is a row \"Favourites\" of 5 places. See \"The favourites row\" below."
        ]),
        Section(id: "longpress", title: "Long press: a second action", part: "keys", lines: [
            "Every key can have a second action that runs when you hold it. Set it in Set up keys: pick the key, and under \"What it does\" use the picker \"Long press\". Choose Nothing, or anything a key can do except \"Folder of keys\", and fill it in like the normal action.",
            "A key with a long-press action shows a small white dot in its top right corner: on the box, on the keys on screen and on the iPhone and iPad.",
            "Hold the key for half a second (0.5 seconds). On the iPhone and iPad a long press gives a stronger buzz. On the Mac's keys on screen, hold the mouse button. On the box, hold the key.",
            "A long press on a key that has no second action does the usual thing, as if you had tapped.",
            "On the box and on the Mac's keys on screen, a key with a long-press action acts when you let go: the usual action if you let go early, the second action if you are still holding after half a second. All other keys act at once, as before.",
            "A long-press action that is broken (for example its app is gone) shows the red corner. In Set up keys the reason starts with \"Long press:\".",
            "Not yet tried on the real box. The box is away until January 2027."
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
            "Switch page group changes the page group. Several things in a row runs steps one after another, a third of a second apart.",
            "Since 0.7, two more: \"Recent app\" (the app you used before the one in front) and \"Ask AI (copied text)\" (opens Raycast AI Chat with your copied text). See the next two parts.",
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
            "Press the key and Raycast AI Chat opens with the text you copied last already filled in. The key is Raycast red-orange, with an AI drawing and the title \"Ask AI\".",
            "If nothing is copied, or you copied a picture, AI Chat just opens.",
            "Very long text is cut at 4,000 characters.",
            "Not yet tried against the real Raycast. This is a first version: if the text does not arrive in AI Chat, tell me."
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
            "Raycast has no door for quicklinks and snippets from outside. Use \"Open a link\" for a quicklink and \"Type text\" for a snippet."
        ]),
        Section(id: "profiles", title: "Page groups change by themselves", part: "profiles", lines: [
            "When an app that belongs to a page group comes to the front, the keys change to that page group. Any other app shows the default page group.",
            "A page group you pick by hand stays while you move between apps that share a group. It changes when you go to an app with another group.",
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
            "Elgato's own app must be quit while Deck Mate drives the box, because only one can hold it.",
            "Settings warns you when Elgato's app is running and has a \"Quit Elgato's app\" button.",
            "When Deck Mate quits, the box goes back to the Elgato logo."
        ]),
        Section(id: "firsttime", title: "First time with the box", part: "box", lines: [
            "This part of Settings is for the first day with the real box, which is not yet tried.",
            "Step 1: quit Elgato's app. Step 2: plug the box in. Step 3: if the Mac asks for Input Monitoring, allow it.",
            "It shows the box's answer in plain words, and a button to show the box diary (the box log), in case something does not work."
        ]),
        Section(id: "iphone", title: "On your iPhone", part: "settings", lines: [
            "Deck Mate for the iPhone shows the same 15 keys as the box, in the same places and with the same pictures. It follows the page group and page the Mac shows, so it changes when the app in front changes.",
            "Tap a key on the iPhone and the Mac does it, exactly as if you had pressed it on the box. The keys on the Mac screen do not hide because of a tap on the iPhone.",
            "The iPhone finds your Mac by itself when both are on the same Wi-Fi: at home, in a hotel, or with the Mac on your iPhone's hotspot. Without a shared Wi-Fi it also tries to reach the Mac directly, like AirDrop, but that is not proven yet.",
            "The first time, the Mac asks: \"“iPhone name” wants to use your keys. Allow?\" Choose Allow. After that the Mac remembers the iPhone. If you choose Don't Allow, the iPhone shows \"Ask again\".",
            "The pictures are drawn by the Mac, so keys that open an app show the real app icon.",
            "New in 0.4 (the Mac must be at 0.4 too): the keys sit low on the iPhone, near your thumb, with the place line on top. Swipe left or right on the keys to change page. Small dots under the keys show which page you are on. There are no dots inside a folder or when there is one page.",
            "Tap the top line (the name of the page group) for a menu: \"Automatic\", or hold one of the page groups, the same as the Mac's menu.",
            "A key you press lights up on the iPhone, whether you pressed it on the box, on the keys on the Mac screen or on the iPhone.",
            "After a tap, a short note at the bottom says what ran, for example \"Opened OmniFocus\" or \"Raycast: Clipboard history\". If the Mac could not do it, the note is red with a warning drawing, for example \"The app is not on this Mac\" or \"The Mac has not allowed key presses yet\".",
            "The iPhone screen follows day and night: light grey by day, dark by night. The keys stay as drawn.",
            "After 20 seconds of \"Looking for your Mac…\" a card explains: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. It has the button \"Open Settings\" and a close (x) button that hides the hint.",
            "If the iPhone says \"Looking for your Mac…\": check that the Mac app is open, that Wi-Fi and Bluetooth are on, that the iPhone is close to the Mac, and that Local Network is allowed for Deck Mate in the iPhone's Settings, Privacy & Security, Local Network.",
            "New in 0.7 (the Mac at 0.7 and the iPhone or iPad app at 0.9): the Mac tells a connected iPhone or iPad when its screen goes to sleep and when it wakes. With the switch \"Dark while the Mac sleeps\" in the iPhone's or iPad's Settings (on at first), the device goes black with a small moon and \"Mac asleep\", may lock itself, and brightens when the Mac wakes. One tap shows the keys again. The \"Recent app\" and \"Ask AI\" keys show and work on the iPhone and iPad too, drawn by the Mac.",
            "New in 0.5 (the Mac at 0.5 and the iPhone or iPad app at 0.7 together): own keys, the favourites row, the Mac at a glance and the music strip. See the next part."
        ]),
        Section(id: "iphonenew", title: "On your iPhone and iPad, 0.5", part: "settings", lines: [
            "My own keys. In Settings on the iPhone or iPad, the new card \"Keys\" is at the top. \"Follow the Mac\" is as before: it shows the page group and page the Mac shows. \"My own keys\": pick a page group, and the iPhone or iPad then moves through that group on its own: pages, folders and Back, at its own place.",
            "With own keys, the Mac's keys on screen and the box stay where they are. A tap on the iPhone still makes the Mac do what the key says. Keys pressed elsewhere do not light up on a device with its own keys.",
            "Swipe up or down, or use the menu in the top line, to change your own page group. It is remembered on the device. With own keys there is no lock and no \"Automatic\" in that menu. If the group you picked is gone, the default group shows.",
            "The Mac keeps one place for each connected device, for as long as it is connected. After it connects again, the device starts at the first page of its group.",
            "The favourites row: 5 keys under the 15 that stay on every page and every page group. A switch \"Favourites row\" in Settings (on at first). It shows only when at least one favourite is set.",
            "Long press works on the iPhone and iPad too: hold a key with a white dot for half a second. You feel a stronger buzz.",
            "Mac at a glance. The top line shows a small battery drawing and the Mac's battery in percent, with the app in front, for example \"82 % · Safari\", or \"82 % charging · Safari\" while it charges. A Mac without a battery shows only the app. A switch \"Mac at a glance\" in Settings (on at first).",
            "Music strip. Above the keys: song and artist, play or pause, next, quieter, the volume in percent, and louder. One tap on quieter or louder moves the volume by 6 points. It works with Spotify and Apple Music. A switch \"Music strip\" in Settings (on at first).",
            "It says \"Nothing playing yet\" until the next change of song or pause after the Mac app has started, because the Mac hears about it from the player only when something changes.",
            "Play or pause and next use the same one-time Accessibility permission on the Mac as music keys. Volume needs no permission.",
            "The Mac looks at its battery and volume every 5 seconds, but only while such a device is connected.",
            "Older versions. These new parts need the Mac at 0.5 and the iPhone or iPad app at 0.7. An iPhone or iPad at 0.7 with an older Mac works as before: its Settings say \"Needs AMS Deck Mate 0.5 on the Mac\" in the Keys card, and the new parts stay hidden. A Mac at 0.5 with an older iPhone app works as before, and the white dot still shows on the key pictures.",
            "Not yet tried: long press on the real box, long press on the real iPhone and iPad, and play or pause from the strip.",
            "New in 0.6 (the Mac at 0.6 and the iPad app at 0.8): on an iPad held on its side, the keys sit on the right and a navigation picture on the left shows every page group with every page and folder as a small picture of its 15 keys. Tap one and the keys go there. When the iPad follows the Mac, the Mac goes there too and that page group is locked until you choose \"Automatic\". With own keys only the iPad's own place moves. A switch \"Navigation picture\" in the Keys card in Settings turns it off. The Mac draws the pictures. With an older Mac it stays hidden."
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
            "Since 0.4 \"Settings\" is a short list on the left with one part at a time on the right, instead of one long page. The parts are: The box, First time with the box, Keys on screen, iPhone, Page groups, Check keys, This Mac, From Elgato and Where it is kept.",
            "They hold the box and brightness, change page group with the app in front, the keys on screen (where they show, hide after a key, size), the iPhone card, open at login, permissions, bring over again and the check for broken keys.",
            "The version number, Quit and Done stay at the bottom."
        ]),
        Section(id: "kept", title: "Where things are kept", part: "settings", lines: [
            "Your setup is one file on this Mac, in the folder \"AMS Deck Mate\" inside Application Support.",
            "Each save first keeps the previous file as a safety copy. The last 20 are kept in a \"Backups\" folder beside it.",
            "Nothing leaves your Mac."
        ])
    ]

    static let releases: [Release] = [
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
