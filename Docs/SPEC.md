# AMS Deck Mate, specification, version 0.20 (build 30), 25 Nov 2026; iPhone and iPad app 0.32 (build 38)

A Mac menu bar app that drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

**Warning.** 0.1 was built while the box was away. Driving the real box is not yet tried. The first real test is planned for January 2027. The keys on screen, the rules and the setup do not need the box.

## 1. Purpose
- Give the 15-key Stream Deck (2019) and MK.2 their keys without Elgato's app.
- Mac app: menu bar only, no Dock icon. The version shows in Settings.
- Since 0.3 also an iPhone app that shows and presses the same keys (section 17).
- Since 0.6 (Mac) and 0.8 (iPad): the navigation picture on an iPad held on its side (section 29); since 0.10 also on an iPhone held on its side, with the side panel and the lock in Settings (section 34).
- Since 0.20 (Mac) and 0.32 (iPhone and iPad): the fan key that is on shows the minutes left (section 140); a double press, a third action of every key, marked by a small white "×2" (section 141); words that say what a key does, shown as a plate under the Mac pointer and by the new "Explain" button on the iPhone and iPad (section 142). Link version is now 10 (was 9), keys-file format stays 3 (new optional field `twice` per key).
- Since 0.19 (Mac) and 0.31 (iPhone and iPad): Cool and Full fan keys last 10 minutes (section 137); the "Set up keys" window is taller so nothing is cut off (137); the owner places pages in four places for several pages at once (section 138); a switch between 1 page and 4 pages, the left-edge pull on an iPhone on its side and the blue name of the page you are on (section 139). Link version stays 9, keys-file format stays 3 (new optional field `places` per page group).
- Since 0.18 (Mac; iPhone and iPad stay 0.29, build 35): three new choices of the Switch key, "Fans: Automatic", "Fans: Cool" and "Fans: Full" (7 choices in all instead of 4), which ask AMS Fan Menu (0.2 or newer) for the fan speed and show which choice is on (section 135); one more drawing, a fan (`app-fan.svg`), 257 in all instead of 256. No link version change (still 9), no keys-file format change (still 3).
- Since 0.7 (Mac) and 0.9 (iPhone and iPad): the "Recent app" and "Ask AI (copied text)" keys, and the dark screen while the Mac sleeps (sections 31 to 33).
- Since 0.8 (Mac) and 0.11 (iPhone and iPad): the "Last copied text" and "Recent file" keys (section 36), "Bring back an earlier state" and the self-repairing keys file (section 37), the private link with a 4-digit check number (section 38), the "Mac is back" note and the trimmed box diary (section 39).
- Since 0.11 (Mac, round 2 of 3 of his picked ideas): six new kinds of key (Next event, Weather, Due today, Album cover, Body Battery, Desk; 29 kinds instead of 23), five of them showing a value at a glance (sections 56 to 62). iPhone and iPad stay 0.16 (build 21): the Mac draws the keys.
- Since 0.13 (Mac, second round of his picks): six new kinds of key (On the Mac, Join the meeting, Spotify playlist, Search for the copied text, Counter, Stopwatch; 40 kinds instead of 34), one new choice of the Switch key (Keep the Mac awake), two new drawings (eject, video camera; 256 in all) and a page of the new keys in the made-up sample keys (sections 71 to 78). iPhone and iPad stay 0.16 (build 21) and show the new keys without an update.
- Since 0.16 (Mac) and 0.18 (iPhone and iPad): three new kinds of key, 45 in all instead of 42 (Breathing pacer `breath` section 98, Progress bar `bar` 99, Often used `often` 100), the PARAGON choice "Now on my plan" (101), timers in whole minutes and one softer sound (102, and section 46), wrong input said at once (103), "New key from…" (104), the suggested key (105), "Save as PDF…" (106), darker amber and green (107), hours for a page group (108), evening dimming of the box (109), actions for Apple's Shortcuts app (110), the ready-made page group "My AMS apps" (111), the Keychain for the secrets of allowed phones (112), a failed save told, the key pictures in the iCloud copy and the format number 3 (113), scripts with a time limit, closing and quitting (114), Cancel is the Return key (115), small repairs (116), keys that rest and checks that pause (117), PARAGON's format check (118), and on the phone link and screen (119). Section 40 and 85 are corrected.
- Since 0.15 (Mac) and 0.17 (iPhone and iPad): safety copies that last longer (section 83), self-repair from iCloud and for a new Mac (84), unknown kinds kept and format number 2 (85), the outside door for key presses closed (86), no password copies (87), limits for strangers (88), calmer colours (89), Garmin board off, old numbers and gym numbers (90), declined events (91), the list of kinds (92), drop on a key (93), Raycast commands and links (94), box wake-up and diary (95), link version 8 (96). The guide's sentence about Elgato's app now says it should be quit (section 10).
- Since 0.14 (Mac, third and fourth round of his picks, plus two ideas): two new kinds of key (PARAGON, Focus rounds (PomoTimer); 42 kinds instead of 40), the Due today key counts PARAGON instead of OmniFocus, the Spotify playlist key shows the cover, and Quit all apps fills its "Stays open" list (sections 79 to 82; section 70 and section 59 changed). iPhone and iPad stay 0.16 (build 21) and show the new keys without an update.
- Since 0.12 (Mac, first round of his 28 picks from 50 new ideas): five new kinds of key (Garmin number, Mac at a glance, World clock, Sunrise and sunset, Free until; 34 kinds instead of 29) showing eleven more things at a glance, and a glance key can change its colour with its value (sections 63 to 68). The town on a World clock or Sunrise and sunset key can be changed by a long press like Weather (section 58). iPhone and iPad stay 0.16 (build 21) and show the new keys without an update.
- Since 0.10 (Mac, round 1 of 3 of his 25 picked ideas): six new kinds of key (Timer, Switch, Run an Apple Shortcut, List to pick from, Open app, Microphone light; 23 kinds instead of 17), the Wait step, Find a key on the keys on screen, Settings > Key use and four ready-made page groups (sections 46 to 55). 254 drawings (252 before). iPhone and iPad stay 0.16 (build 21): the Mac draws the keys.
- Since 0.9.4 (Mac): one more drawing to choose for a key, Drawer (`drawer.svg`), 252 in all instead of 251; his GridFit key now shows it instead of Autodesk Fusion's icon. Shows on the Stream Deck, on screen keys and on the iPhone and iPad with no update there (history below). iPhone and iPad stay 0.16 (build 21).
- Since 0.9.3 (Mac): a key can show a picture of its own instead of a white drawing (section 4 and history below); 10 web-app keys of "My Apps" show their app's real icon. iPhone and iPad stay 0.16 (build 21).
- Since 0.9.2 (Mac): six new drawings to choose for a key (Home, Arrow up, Arrow left, Arrow right, Window top half, Window bottom half), 251 in all instead of 245; they show on the Stream Deck, on screen keys and, drawn by the Mac, on the iPhone and iPad with no update there (section 14 history below). iPhone and iPad stay 0.16.
- Since 0.9.1 (Mac): the Raycast kind is a clear red (before, a red-orange that looked close to the amber of text keys), a little deeper so white words stay easy to read. It shows in the box, on screen keys, Set up keys, "All pages", and by itself on the iPhone and iPad (keys and navigation picture) with no update there. iPhone and iPad stay 0.15.
- Since 0.9 (Mac) and 0.12 (iPhone and iPad): the weekly copy of the keys in iCloud Drive (section 40), the list choice of "Last copied text" (section 41), and the lock mark for the private line (section 42).
- Since 0.16 (iPhone and iPad): page groups in the navigation picture sit in framed panels with a full-colour name ribbon; on an iPhone on its side the app pill, lock, music and gear form one narrow column to the right of the keys, the heading stands in one line in the middle above the keys with the connection dot in front of it, and the left panel holds only the navigation picture, which uses the whole height (section 45). The Mac app is unchanged at 0.9.1 (later 0.9.2).
- Since 0.15 (iPhone and iPad): the Mac at a glance pill, the connection dot (connected) and the private-line lock all use the same green as the settings gear; on its side the lock moves to the bottom left (section 44). The Mac app is unchanged at 0.9.
- Since 0.14 (iPhone and iPad): the Mac at a glance no longer shows the Mac's battery, only one blue pill with the app in front (sections 27 and 43). The Mac app is unchanged at 0.9.
- Since 0.13 (iPhone and iPad): the navigation picture is as tall as the keys, the music and settings buttons move to the bottom left on its side, and the Mac at a glance is two pills (section 43; the battery pill was removed in 0.14).
- Since 0.5 (Mac) and 0.7 (iPhone and iPad): long press, a favourites row, own keys on each iPhone or iPad, the Mac at a glance, a music button, and "All pages" in Set up keys (sections 24 to 28, and 5).

## 2. Menu bar
The icon opens a menu:
- "Show keys on screen" (shortcut Control-Option-D).
- "Set up keys…".
- Status lines at the top: "Page group: <name> (automatic)" or "(locked)"; "iPhone: connected – <name>" or "iPhone: none connected"; the box line.
- "Page group": "Automatic", or one page group pinned by hand. A pinned page group is locked: a small hand-drawn lock shows beside the name of the page group on the keys on screen (since 0.4.2). Without the lock the page group follows the app in front.
- "Page group for <front app>": a sub-menu of the page groups and "None – use the default". Picking one puts the front app's bundle identifier into that group's `apps` and takes it off every other page group, so the page group then shows by itself whenever that app is in front. "None" takes the app off all page groups.
- "Settings…".
- "Quit AMS Deck Mate".

## 3. Keys on screen
- A small floating window with the same 15 keys as the box (5 columns, 3 rows). A click does what pressing the box key does.
- It does not take the keyboard from the app the user works in. It stays above other windows, can be dragged anywhere and remembers its place.
- The top line shows the page group and page names and a button to set up keys.
- It works without the box.
- Three choices, made in Settings in the card "Keys on screen" (rules in `ScreenDeck.swift`: `ScreenDeckRules`, `ScreenSize`). Together they make the keys on screen a virtual deck: Control-Option-D, the keys appear under the mouse, click a key, they are gone.

**Show them** (`screenAtPointer`, default false)
- "Where I left them": the window comes back where the user last dragged it (as in 0.1).
- "At the mouse pointer": each time the window is shown (from the menu or with Control-Option-D) it is centred on the mouse pointer. The place the user drags it to is not remembered in this mode.
- Placement (`ScreenDeckRules.origin(pointer:size:area:margin:)`): `area` is the usable part of the screen the pointer is on; `margin` is 8 points. On each axis the wanted lower left corner is the pointer minus half the window size, then held between `low + margin` and `high - margin - length`. If the window is larger than that room, it is centred on the area. The answer is the lower left corner.

**Hide after a key is pressed** (`screenHidesAfterKey`, default false)
- Rule (`ScreenDeckRules.hides(after:setting:)`): the keys hide when the setting is on and the outcome of the click ran something on the Mac (`outcome.run` is not empty).
- A key that only moves around (folder, Back, next or previous page, switch page group) runs nothing, so the keys stay open.
- A "several things in a row" key hides them when at least one of its steps runs something on the Mac.
- Only clicks on the screen hide the keys. Pressing a key on the box does not.

**Keyboard on the keys on screen (0.4)**
- Right after the keys are shown (Control-Option-D or the menu) the window takes the keyboard. Keys 1 to 5 press the top row (places 0 to 4), Q W E R T the middle row (5 to 9), A S D F G the bottom row (10 to 14). These are matched by key position, so they are the same places on every keyboard layout.
- Left and right arrows, or Tab and Shift-Tab, change page (as Next page and Previous page). Escape hides the keys.
- After a key that does something on the Mac, the keyboard goes back to the app the user was in.
- 0.4.1: while the window has the keyboard, each key shows its letter (1 2 3 4 5 / Q W E R T / A S D F G, by place) in a small round mark in its top-left corner. The marks go away when the keyboard goes back to the previous app (after a key that does something on the Mac, or a click on the keys), so marks showing means typing works now. Only on the keys on screen; the box, the iPhone and Set up keys show none.

**Broken keys (0.4).** A key whose app, file or folder, Raycast extension, folder page or page group is gone shows a red corner mark on the screen (see section 20).

**Long press (0.5).** A key with a long-press action (`held`) shows a small white dot in its top right corner. A key with `held` acts when the mouse button is let go: let go before 0.5 s runs the normal action; still held after 0.5 s runs `held`. All other keys act at once on the click, as before. The favourites row (section 25) is not shown on the keys on screen. See section 24.

**Size** (`screenSize`, default normal)
- `ScreenSize`: small, normal, large. The side of one key (`keySide`) is 48, 64 or 80 points; the gap between keys (`gap`) is 6, 8 or 10 points. Normal is the size 0.1 had.
- The window changes size at once.

## 4. Key look and colours
- A flat coloured tile, a white hand-drawn icon, a short title.
- One colour per kind (`KeyKind`): app blue, web (links) teal, raycast red, shortcut purple, text amber, media green, move (folder, back, pages, page group) grey-blue, empty neutral.
- A "several things" key takes the kind of its first step that is not "nothing".
- An app key shows the app's own icon unless an icon is picked.
- Since 0.9.3 any key can show a picture: its `icon` is "picture:<name>", meaning the file `<name>.png` in the folder "Pictures" beside the keys file (`~/Library/Application Support/AMS Deck Mate/Pictures/`). `DeckKey.pictureName` (Core/Sources/DeckMateCore/Model.swift) gives the name, nil when the icon is a drawing or empty. Drawn in App/Sources/KeyArt.swift with rounded corners like an app icon (corner 23 % of its side), 36 of the key's 72 points wide when the key has a title, 46 when it has none. The tile keeps the colour of its kind (links teal). A missing file falls back to the automatic drawing (`autoIcon`). It shows on the Stream Deck, on screen keys, in Set up keys, "All pages", and on the iPhone and iPad (the Mac draws the keys). In Set up keys the Icon button says "Own picture"; picking a drawing or "Automatic" replaces the picture. There is no button yet to choose a file; pictures are put there by `Tools/deck-pages.py --icons` in AMS Apps Overview, which also copies the icon files. The weekly iCloud copy and the safety copies hold only the keys file, not the Pictures folder.
- An app key with an empty title shows the app's name (`DeckKey.shownTitle(appName:)`, see section 18). Own words always win.
- 252 hand-drawn icons (251 before 0.9.4, 245 before 0.9.2): the AMS Icon Library plus new ones drawn for this app. Since 0.9.2 six more come from the library: Home (a small house), Arrow up, Arrow left, Arrow right (an arrow down was already there) and Window top half, Window bottom half (joining Window left half, Window right half and Full window). Since 0.9.4 one more comes from the library: Drawer (a drawer front with a small handle, `drawer.svg`). Same style (one line, round ends, no fill); existing keys keep their drawings. A key's `icon` is a drawing's name; empty means the automatic one (`autoIcon`): deck-link, deck-raycast, deck-keyboard, deck-text, deck-play, deck-next, deck-previous, deck-volume-up, deck-volume-down, deck-mute, deck-folder, deck-back, deck-page-next, deck-page-previous, deck-profile, deck-multi.

## 5. Set up keys
- Left: page groups (heading "Page groups"). Add ("Add a page group"; the new one is named "New page group"), rename, delete, make default, "Use with apps" (the apps a page group belongs to).
- Middle: the 15 keys, with the pages and folders of the page group above them. Add page, delete page.
- Right: the clicked key. Title, Icon, "What it does". Cancel and Save on every edit; Escape is Cancel.
- "Clear key" empties a key. "Try it" runs the key.
- 0.5: under "What it does", a picker "Long press": Nothing, or any action type except "Folder of keys" (section 24). Under the 15 keys, a row "Favourites" of 5 places (section 25).
- 0.5: the button "All pages" at the top right of the Keys column. It shows every page group with every page and folder as a small picture of its 15 keys, with its name and the number of keys under it. A folder carries the folder mark; the page being edited has a coloured frame. A click on a page opens it for editing. "Back to the keys" or Escape goes back to the keys.
- 0.4 additions (details in section 20): drag to move or swap keys, drop on a page chip; copy and paste; Duplicate page; Duplicate page group; Undo and Redo; red marks for broken keys.

## 6. Key actions
`ActionType`: none, app, link, raycast, shortcut, text, media, folder, back, nextPage, previousPage, page group, multi, and since 0.10 timer, toggle, appleShortcut, list, running, micLight and wait, and since 0.11 nextEvent, weather, dueToday, cover, bodyBattery and desk, and since 0.12 garmin, macNow, worldClock, sunTimes and freeUntil, and since 0.13 macDo, joinMeeting, playlist, searchCopied, counter and stopwatch, and since 0.14 paragon and focus, and zero (not offered in the pickers: what a long press of a counter or stopwatch key runs) (also recent, askAI, copied, recentFile since 0.7 and 0.8). An unknown name decodes as none, and since 0.11.1 weatherTown (what a long press of a weather key runs; never offered in the pickers).

| Action | `target` | What happens |
|---|---|---|
| Open an app | bundle identifier, or full path when it starts with "/" | the app opens or comes forward |
| Open a link or a file | web address or file path | opened by the Mac. Also how a Raycast quicklink goes on a key |
| Raycast | the whole raycast:// link | see 7 |
| Keyboard shortcut | (uses `combo`) | the keys are pressed. Needs Accessibility |
| Type text | the text | typed. Needs Accessibility. Also how a snippet goes on a key |
| Music and sound | a `MediaKey` | playPause, next, previous, volumeUp, volumeDown, mute |
| Folder of keys | the page's id | opens that page; the page we came from is pushed on the trail |
| Back | none | pops the trail; with an empty trail goes to the group's first page |
| Next / previous page | none | moves between the top pages, wrapping round; clears the trail. With one page: nothing |
| Switch page group | the group's id | goes to that group's first page. Unknown id: nothing |
| Several things in a row | (uses `steps`) | steps run in order, a third of a second apart (since 0.10 a "Wait" step pushes the later steps back, section 52). Steps may nest to depth 4 |
| Recent app (0.7) | "1", "2" or "3" (1st, 2nd, 3rd) | brings that recent app forward; see 31 |
| Ask AI (copied text) (0.7) | none | opens Raycast AI Chat with the copied text; see 32 |
| Last copied text (0.8) | `copied`; "1", "2" or "3" (1st, 2nd, 3rd) | pastes that copied text; see 36 |
| Last copied text, list (0.9) | `copied`; "list" | opens a small list at the mouse pointer; see 41 |
| Recent file (0.8) | `recentFile`; "1", "2" or "3" (1st, 2nd, 3rd) | opens that file; see 36 |
| Timer (0.10) | `timer`; minutes as text, "5" | see 46 |
| Switch (on or off) (0.10) | `toggle`; "dark", "mute" or "own:<name>" | see 47 |
| Run an Apple Shortcut (0.10) | `appleShortcut`; the Shortcut's name | see 48 |
| List to pick from (0.10) | `list`; the entries are `steps` | see 49 |
| Open app (0.10) | `running`; "1" to "15" | see 50 |
| Microphone light (0.10) | `micLight` | shows only; see 51 |
| Wait (0.10), a step only | `wait`; seconds | see 52 |
| Next event (0.11) | `nextEvent`; an app's bundle id, or empty for Calendar | opens that app; see 57 |
| Weather (0.11) | `weather`; the town as typed | opens the Mac's Weather; see 58 |
| Due today (0.11; PARAGON since 0.14) | `dueToday` | opens Today in PARAGON (`amspara:///list/today`); see 59 |
| Album cover (0.11) | `cover` | play or pause; see 60 |
| Body Battery (0.11) | `bodyBattery` | opens the board in the browser; see 61 |
| Desk (0.11) | `desk`; the apps are `steps` | puts the windows back; see 62 |
| Garmin number (0.12) | `garmin`; "steps", "sleep", "pulse", "stress" or "workouts", and since 0.15 two gym numbers (section 90) | opens the board in the browser; see 64 |
| Mac at a glance (0.12) | `macNow`; "battery", "space" or "busy" | opens Battery, Storage (System Settings) or Activity Monitor; see 65 |
| World clock (0.12) | `worldClock`; the town as typed | opens the Mac's Clock; see 66 |
| Sunrise and sunset (0.12) | `sunTimes`; the town as typed | opens the Mac's Weather; see 67 |
| Free until (0.12) | `freeUntil`; an app's bundle id, or empty for Calendar | opens that app; see 68 |
| On the Mac (0.13) | `macDo`; "lock", "desktop", "quitAll", "emptyBin", "ejectAll" or "pastePlain"; `quiet` = without asking; for quitAll `steps` = the apps that stay open | see 71 |
| Join the meeting (0.13) | `joinMeeting` | opens the video link; see 72 |
| Spotify playlist (0.13) | `playlist`; the pasted link | plays it in Spotify; see 73 |
| Search for the copied text (0.13) | `searchCopied`; "google", "duckduckgo", "bing", "wikipedia" or "youtube" | opens the search; see 74 |
| Counter (0.13) | `counter`; the key's own id | counts one more; see 75 |
| Stopwatch (0.13) | `stopwatch`; the key's own id | start, pause, go on; see 76 |
| Zero (0.13), never picked | `zero`; the key's own id | what a long press of a counter or stopwatch key runs; see 75 and 76 |
| Switch, "Keep the Mac awake" (0.13) | `toggle`; "awake" | see 77 |
| PARAGON (0.14) | `paragon`; "inbox", "next", "copiedTask" or "note" | see 79 |
| Focus rounds (PomoTimer) (0.14) | `focus`; the plan rides in `steps` | opens PomoTimer and starts the template; see 80 |
| Nothing | none | nothing |

A shortcut (`KeyCombo`) holds keyCode, command, control, option, shift and keyName; it is recorded by pressing the keys. Its label is written as the Mac does: control, option, shift, command, key (for example ⌃⌥D).

## 7. Raycast
- A key holds the whole link, `raycast://extensions/<owner>/<extension>/<command>`.
- The list offers the commands of the Raycast extensions installed on this Mac (found by itself; 15 on the author's Mac, for example Notion, Spotify, CleanShot X, 1Password, Reminders) and 16 of Raycast's own (Clipboard History, AI Chat, window left and right half, Search Snippets, Search Quicklinks, Lock Screen and more).
- Since 0.4 an extension command shows the extension's own icon, read from the installed extension. Raycast's own commands keep the hand-drawn drawings.
- Since 0.4 two built-in links are corrected: AI Chat is `raycast://extensions/raycast/ai/ai-chat` and Search Quicklinks is `raycast://extensions/raycast/quicklinks/search-quicklinks`. The other built-in links could not be confirmed from the Mac; if one does not work, use "Copy Deeplink" in Raycast and paste it.
- Any Raycast link can be pasted (in Raycast: select a command, Command-K, "Copy Deeplink"). Pasted text is tidied; text that is not a Raycast link is refused.
- Script command by its file name: `raycast://script-commands/<slug>`. AI command by its name: `raycast://ai-commands/<slug>`.
- Slug: lower case, accents removed, letters and digits joined by hyphens ("Fix Spelling and Grammar" becomes fix-spelling-and-grammar).
- "Run quietly" (`quiet`) runs the command without bringing Raycast forward.
- The first time a key runs a command Raycast asks once; choose "Always open command".
- Raycast has no outside door for quicklinks and snippets: use "Open a link" and "Type text".

## 8. Page groups and the automatic change
- A page group has a name, the apps it belongs to (bundle identifiers) and pages. A page is either a top page (`parent` empty) or a folder page opened by a folder key.
- Position (`DeckPosition`): page group, page, and the trail of pages to go back through.
- `Navigator.profile(forApp:)`: the first page group that lists the app; otherwise the default page group (`fallbackProfile`: the default, or the first page group when the default is gone).
- `Navigator.follow(app, previousApp, position)`, exactly:
  1. The position is first repaired (see below). With no usable position, the start of the default page group.
  2. If "Change page group with the app in front" is off, the position stays.
  3. `wanted` = the page group of the new app; `before` = the page group of the app before it.
  4. The deck changes only when `wanted` differs from `before` and also from the page group showing now. Then it goes to the first page of `wanted`. Otherwise it stays.
- Result: a page group picked by hand stays while moving between apps that share a page group, and changes when the user goes to an app with another page group. Any other app shows the default page group.
- `repair`: a position whose page group is gone goes to the start of the default page group; a page that is gone goes to the group's first page; trail entries that no longer exist are dropped.
- `start`: the first top page of the page group asked for, else of the default page group.

## 9. Bringing over from Elgato
- At first start the app reads the keys from Elgato's app for the 15-key box: apps, links, shortcuts, typed text, music keys, folders, pages, several-things keys, and which app a page group belongs to.
- Left out: the Zoom profile, the two Final Cut profiles, and keys of kinds Deck Mate does not have (Elgato's own on-screen deck switch, plug-in keys). A folder left with nothing but its Back key is left out too, with the key that opened it (`Deck.droppingEmptyFolders`).
- Elgato's files are only read, never changed. Elgato's pictures are not taken over; every key is redrawn in the new look.
- "Bring over again" in Settings repeats it. It asks first; the current setup is kept as a safety copy.
- With nothing to bring over, the first setup (`Deck.starter`) is one page group "Default" with one empty page "Page 1".

## 10. The box
Not yet tried on the real box (see the warning at the top).
- Supported (vendor 0x0FD9): Stream Deck (2019) 0x006D; MK.2 0x0080 and 0x00A5; MK.2 Module 0x00B9 and 0x00E4. The first Stream Deck (2017, 0x0060) talks differently and is not driven yet.
- Plug in: the keys light up. Settings shows "Connected", the box's name, the serial number and a brightness slider (0 to 100, default 70).
- Elgato's own app should be quit while Deck Mate drives the box, because both apps would otherwise draw on the keys (until 0.14 the text said it must be quit because only one can hold it; that the Mac refuses a second app is not proven). Settings warns when it runs and has "Quit Elgato's app".
- On quit the box goes back to the Elgato logo.
- Long press on the box (0.5): a key with a `held` action acts when it is let go, not when it goes down: held for 0.5 s or more runs `held`, shorter runs the normal action. All other keys act on key down, as before. Not yet tried on the real box; the rule is tested in `Core` with time stamps.
- Byte layouts (from the open drivers python-elgato-streamdeck and elgato-streamdeck; code in `StreamDeckProtocol.swift`):

| What | Layout |
|---|---|
| Key picture | 72 x 72 JPEG, turned upside down (flipped both ways), cut into packets of 1024 bytes |
| Picture packet header (8 bytes) | 02, 07, key, 1 on the last packet else 0, length low, length high, packet number low, packet number high; then the data (up to 1016 bytes), zero padded |
| Key report from the box | 01 00 0F 00, then one byte per key (non-zero = down). The Mac may leave out the first byte; both are read |
| Brightness (feature, 32 bytes) | 03 08 percent (0 to 100), zero padded |
| Back to the logo (feature, 32 bytes) | 03 02, zero padded |
| Serial number | feature report 06, text from byte 2 up to the first zero byte |

## 11. Permissions
- Accessibility, asked once, for keys that press a shortcut, type text or control music and sound. Settings shows whether it is allowed and has an "Allow…" button.
- The Mac may ask for Input Monitoring when the box is first plugged in.
- New in 0.11: Calendars, full access (`NSCalendarsFullAccessUsageDescription`), asked once at the first press of a Next event key; read only. OmniFocus control (Automation, Apple events), asked once at the first press of a Due today key; counts only (not needed since 0.14: Due today counts PARAGON). Accessibility is also used by the Album cover key (play or pause) and the Desk key (window places). `NSAllowsLocalNetworking` in Info.plist lets the Body Battery key read `http://127.0.0.1:7788` (the AMS Garmin Bridge Board on this Mac).
- New in 0.14: nothing new is asked. The PARAGON keys and Due today read one small file of PARAGON (section 79) and open PARAGON through its own links; Focus rounds opens PomoTimer in the browser; the playlist cover only needs the internet. Due today no longer needs Automation for OmniFocus (asked in 0.11 to 0.13).
- New in 0.13: Join the meeting uses the same calendar access as Next event (read only). Empty the bin: Automation (Apple events) for the Finder, asked once at the first press. Spotify playlist: Automation for Spotify, asked once at the first press. Paste as plain text uses Accessibility. Lock the Mac, Show the desktop, Quit all apps, Eject all disks, Search for the copied text, Counter, Stopwatch and Keep the Mac awake ask the Mac nothing.
- New in 0.12: no new permission. The Free until key uses the same calendar access as Next event (asked once at the first press of either; "Press to allow" until then). The Garmin, Mac at a glance, World clock and Sunrise and sunset keys ask the Mac nothing.
## 12. Settings
Three tabs: Settings, How it works, What's new. The version, Quit and Done are at the bottom.
Since 0.4 the Settings tab is a list on the left with one part at a time on the right (before: one long scroll). The parts, in order: The box (box, brightness), First time with the box, Keys on screen (Show them, Hide after a key is pressed, Size), iPhone (section 17), Page groups (change page group with the app in front), Check keys, This Mac (open at login, permissions), From Elgato (bring over again), Where it is kept.
- "First time with the box": the steps for the first day with the real box (quit Elgato's app, plug the box in, allow Input Monitoring if the Mac asks), the box's answer in plain words, and a button to show the box diary (box log). Reminder: the real box is still untried (the author is away until January 2027).
- "Check keys": the button "Check all keys" lists every broken key as "Page group · Page · key: reason" (section 20).
- New in 0.16.1: in the "This Mac" card, under the "Open at login" tick box, a small grey line: "While this is on, the app also comes back by itself if it ever stops unexpectedly." (section 120). The tick box itself is unchanged; the wish is now also kept as the setting `wantsOpenAtLogin`.
- The picture used for checks (sample Settings picture) shows a made-up iPhone, never real data.
- 0.5: the Mac's Settings have no new switch. The Mac keeps one own place for each connected iPhone or iPad (in memory, for the connection) for "My own keys" (section 26). The new switches are on the iPhone and iPad (section 23).

## 13. Storage
- One file: `~/Library/Application Support/AMS Deck Mate/deck.json`. Each save first keeps the previous file as a safety copy in `Backups` beside it. Until 0.14 only the newest 20 were kept; since 0.15 see section 83.
- Since 0.8 `Store` lives in `Core/Sources/DeckMateCore/Store.swift` (before: `App/Sources/Store.swift`), so it has data tests. Copies, restore and repair of a damaged file: section 37.
- Nothing leaves the Mac.
- Decoding is tolerant: a missing or odd field gets its default, never an error. A missing `held` means no long press; a missing `favourites` means 5 empty places. A favourite whose action is a folder or Back is treated as empty (refused in Set up keys, ignored if found in the file).
- An older Mac app (before 0.5) that opens a file with `held` or `favourites` ignores them, and its next save drops them.

| Object | Fields |
|---|---|
| Deck | version (1), profiles (the page groups), defaultProfile (id of the default page group), brightness (0 to 100, default 70), autoSwitch (default true), screenAtPointer (true or false, default false), screenHidesAfterKey (true or false, default false), screenSize ("small", "normal" or "large", default "normal"), **favourites (0.5: 5 places, 0 to 4, each a key or empty; default 5 empty places)**. A missing or odd value of the screen fields means the default |
| Page group (`Profile`) | id, name, apps (bundle identifiers), pages |
| Page | id, name, parent (id of the page holding the folder key, or empty for a top page), keys (place 0 to 14 as the key; 0 top left, left to right, top to bottom) |
| Key | id, title, icon, action, **held (0.5: an Action, the long-press action; missing or "none" means no long press)** |
| Action | type, target, combo, steps (actions), quiet |
| Combo | keyCode, command, control, option, shift, keyName |

## 14. Tests
- New in 0.16.1: 195 rule tests, instead of 193. Two new, in `Core/Tests/DeckMateCoreTests/KeeperTests.swift`: "of two copies the earlier one stays" (`OneCopy.mustQuit`) and "the keeper's start order" (`Keeper.plist`). Section 120.
- New in 0.14: new data tests in `Core/Tests/DeckMateCoreTests/ParagonFocusTests.swift` for the rules of sections 79 to 82 (`ParagonKeys`, `FocusKeys`, the playlist cover, the "Stays open" start list). New check `--paragon` on the app: says what the PARAGON and focus keys would show right now and does nothing else.
- New in 0.13: new data tests in `Core/Tests/DeckMateCoreTests/MacActionsTests.swift` for the rules of sections 71 to 77 (`MacDoKeys`, `QuitKeys`, `BinKeys`, `EjectKeys`, `MeetingKeys`, `PlaylistKeys`, `SearchKeys`, `CounterKeys`, `StopwatchKeys`).
- New in 0.12: 20 new data tests, 112 in all (92 before), in `Core/Tests/DeckMateCoreTests/GlanceMoreTests.swift` for the rules of sections 63 to 68.
- New in 0.11.1: 3 new data tests, 92 in all (89 before), in `GlanceKindsTests.swift`: a weather key answers a long press with `weatherTown` (and keeps its own `held`), `actsOnHold`, and the town list `remembered` (newest first, once, at most 6) with `town(ofKey:)` and `setTown`.
- New in 0.11: 21 new data tests, 89 in all (68 before), in `Core/Tests/DeckMateCoreTests/GlanceKindsTests.swift` for the rules of sections 56 to 62 (next event and its words, weather words and answers, due count, battery level and colour, track name and cover address, desk capture and steps, the new `ActionType` cases reading back).
- New in 0.10: 16 new data tests, 68 in all (52 before): `LiveKindsTests.swift` (13: timer clock, minutes, start and stop; timer finishes once and "Done" goes away; timer key shows itself; switch steps; open apps keep their order; first free place; step timing with Wait; microphone light; pressing the new kinds runs them; key check for the new kinds; key finder; key use counts and quiet list; an old keys file still reads) and `TemplatesTests.swift` (3: every ready-made page group is well formed, the key table, a page group made from a template).
- Rule tests live in `Core` (moving around, Raycast links, box byte layouts, tolerant decoding, the keys on screen). Run: `cd Core && swift test`.
- New in 0.5 (round B): `Core` has 36 data tests (37 since 0.6, see below), 7 of them new, for the new rules: long press (`held`), favourites, own keys, and the new `PhoneLink` messages. The iPhone app's screen test now also finds the favourites row, the Mac at a glance, the music strip and the Keys card by identifier.
- New in 0.9 (data tests, seconds each): `CloudCopies.due(last:now:)` (never copied, or 7 days or more ago, is due), the copy's name ("deck <day>.json"), keeping only the newest 8; `Store.copies()` also lists the iCloud copies (`Copy.inCloud`); `CopiedTexts.choices(in:)` and `CopiedTexts.line(_:)` for the list. The iPhone app's screen test also finds `privateMark`.
- Since 0.9 the code is public on GitHub and the rule tests (49 or more) run there by themselves at every change (`.github/workflows/tests.yml`).
- New in 0.8 (data tests, seconds each): `Store` recovery (`start()` gives `.first`, `.loaded`, `.recovered` or `.lost`; a damaged file is kept as "damaged <date>.json") and `copies()` / `deck(of:)`; `Diary.trimmed` (over 1,000 lines keeps the last 500); `SecureLine` (both sides agree on the keys, a tampered message is refused, a repeated or reordered message is refused, the proof checks out and a wrong secret fails); `CopiedTexts` (the last 4, secret copies skipped, press makes it current); `RecentFiles` (the last 7 days, home folder, exclusions); `PhoneLink.wakeNote(wasAsleep:asleep:)`.
- New in 0.7: two new data tests (39 in all): the recent-apps list and "Recent app" key (`RecentApps`, `resolvingRecent`), and the Ask AI link (`RaycastLink.ask`, `fallbackText`, cut at 4,000) plus `asleep` needing version 5. The iPhone app has one more screen test, `testDarkWhileMacSleeps` (launch argument `-macAsleep`). `PhoneLink.currentVersion` is 5; message `asleep(Bool)` goes only to a side at version 5.
- New in 0.6: one new data test (37 in all) for the rule `Navigator.go`: an unknown page group or page changes nothing. The iPhone app's screen test now also finds the navigation picture by identifier.
- New in 0.4: one small data test per new rule: the new `PhoneLink` messages (round trip), the broken-key reasons, duplicate page and page group, copy and paste, moving and swapping keys between pages, undo and redo (30 steps), the keyboard places, and the "Page group for <app>" rule (an app belongs to one page group only). The iPhone app has one more screen test that finds the page group menu and page dots by identifier.
- New in 0.3: `PhoneLink` framing: round trip (encode then decode gives the same message), split (a message arriving in pieces is put together; a half message waits), broken (a length over 4 MB or text that is not a message is refused, not crashed on). And `shownTitle`: own title wins; empty title on an app key gives the app's name; empty title and no app name stays empty; other kinds are unchanged.
- The iPhone app has one screen test that finds its keys by identifier.

## 15. Build and install
1. `xcodegen generate`
2. `xcodebuild -scheme "AMS Deck Mate" -configuration Release -derivedDataPath build build`
3. Quit the app if it runs.
4. `ditto` the built app to `~/Applications`.
5. Open it.

Since 0.16.1 `Tools/install.sh` does steps 3 to 5: it stops the app politely, copies the Release build into `~/Applications`, opens it and checks that it runs under the keeper (section 120).

**0.20 (Mac, build 30, 25 Nov 2026; iPhone and iPad 0.32, build 38).** The fan key that is on shows the minutes left (section 140); double press (141); what a key does in words, the pointer note on the Mac and the "Explain" button on the phone (142); link version 10. Keys-file format (3) unchanged. Not yet proven: the double press on the real Stream Deck box, a real finger double-tapping on a real iPhone or iPad with the real Mac, and the full 10 minutes counting down on the key.

**0.19 (Mac, build 29, 25 Nov 2026; iPhone and iPad 0.31, build 37).** Fan keys Cool and Full last 10 minutes and say so (section 137); "Set up keys" window taller, nothing cut off (137); four places for the pages shown together (section 138). Link version (9) and keys-file format (3) unchanged. Not yet proven: the Stream Deck box itself, the 10 minutes on real fans, and the pages on a real iPhone or iPad.

**0.31 (iPhone and iPad, build 37, 25 Nov 2026; Mac 0.19, build 29).** A switch between 1 page and 4 pages (2 on an iPhone) on the navigation picture; the pull from the left edge on an iPhone on its side with 2 pages; the name of the page you are on in blue (section 139). Replaces 0.30 (build 36), which added the pull on an iPad (section 136). Not yet proven on a real iPhone or iPad.

**0.18 (Mac, build 28, 24 Nov 2026; iPhone and iPad stay 0.29, build 35).** Fan keys: three new choices of the Switch key that ask AMS Fan Menu for Automatic, Cool or Full and show which is on, section 135. A fan drawing, 257 in all. Link version (9) and keys-file format (3) unchanged. Not yet proven: the Stream Deck box itself, and the keys on a real iPhone or iPad.

**0.17.1 (Mac, build 27, 20 Nov 2026; iPhone and iPad 0.19.1, build 25).** Several pages at once: folders fill empty spots and the pages are arranged for the biggest keys, section 124. Not yet proven on a real iPhone or iPad.

**0.16.1 (Mac, build 25, 18 Nov 2026; iPhone and iPad stay 0.18, build 23).** The keeper: the app comes back by itself, section 120. Not yet proven: a real restart of the Mac with the keeper.

**0.16 (Mac, build 24, 18 Nov 2026; iPhone and iPad 0.18, build 23).** Round of new keys, calm, safer saving and a deck that works by itself: sections 98 to 119. Mac: Breathing pacer (98), Progress bar (99), Often used (100), Now on my plan (101), whole-minute timers and the softer sound (102), wrong input (103), New key from… (104), the suggested key (105), Save as PDF (106), darker amber and green (107), hours (108), evening dimming (109), Shortcuts actions (110), My AMS apps (111), Keychain (112), failed save, pictures in the iCloud copy, format number 3 (113), scripts, closing, quitting (114), Cancel is Return (115), repairs (116), power saving (117), PARAGON format check (118). iPhone and iPad 0.18 (119). `Deck.currentVersion` is 3. New `ActionType` cases `breath, bar, often`; new `ParagonKeys.What.plan`. Rules in `Core/Sources/DeckMateCore`: `Pacer.swift`, `OftenKeys.swift`, `BoxEvening.swift`, `SetupLane.swift`, `SafetyLane.swift`, `KindGroups.swift`, `PhoneEvening.swift`; the app side in `SetupLaneViews.swift`, `SmartViews.swift`, `DeckIntents.swift`, `SafeAsk.swift`, `PairedKeychain.swift`. Not yet tried for real: the evening dimming of the box, the Shortcuts actions run from the Shortcuts app, the Keychain move across a future new build, and everything on the real box. The phone app 0.17 keeps working with Mac 0.16, and the phone app 0.18 with Mac 0.15.

**0.15 (Mac, build 23, 18 Nov 2026; iPhone and iPad 0.17, build 22).** Safety, calmer colours and easier keys: sections 83 to 96. Mac: safety copies (83), repair (84), unknown kinds and format number 2 (85), outside door closed (86), password copies (87), stranger limits (88), calmer colours (89), Garmin board off and gym numbers (90), declined events (91), the list of kinds (92), drop on a key (93), Raycast commands and links (94), box wake-up and diary (95). Link version 8 (96), shared by the Mac and the iPhone and iPad app 0.17. New data tests for the new rules. Not yet tried for real: the box wake-up, the Raycast commands in a real Raycast, the link check with real devices.

**0.14 (Mac, build 22, 18 Nov 2026).** Third and fourth round of his picks and two ideas: two new kinds of key (sections 79 and 80: PARAGON, Focus rounds (PomoTimer); 40 kinds before, 42 now), Due today now counts PARAGON (sections 59 and 70), the Spotify playlist key shows the cover (81) and Quit all apps fills its "Stays open" list (82). New `ActionType` cases `paragon, focus`. Rules in `Core/Sources/DeckMateCore/ParagonFocus.swift` (`ParagonKeys`, `FocusKeys`), tests in `ParagonFocusTests.swift`. New check `--paragon`. No change was needed in PARAGON or PomoTimer. iPhone and iPad stay 0.16 (build 21). Not proven yet: no key was pressed for real.

**0.13 (Mac, build 21, 18 Nov 2026).** Second round of his picks: six new kinds of key (sections 71 to 76: On the Mac, Join the meeting, Spotify playlist, Search for the copied text, Counter, Stopwatch; 34 kinds before, 40 now), a fourth choice of the Switch key (77), two new drawings (78). New `ActionType` cases `macDo, joinMeeting, playlist, searchCopied, counter, stopwatch, zero`. Rules in `Core/Sources/DeckMateCore/MacActions.swift`, tests in `MacActionsTests.swift` (26 tests). 256 drawings (254 before). The made-up sample keys got a page with the new keys. iPhone and iPad stay 0.16 (build 21). Not proven yet: no key was pressed for real.

**0.12 (Mac, build 20, 18 Nov 2026).** First round of his 28 picks from 50 new ideas: five new kinds of key (sections 63 to 68: Garmin number, Mac at a glance, World clock, Sunrise and sunset, Free until; 29 kinds before, 34 now). New `ActionType` cases `garmin, macNow, worldClock, sunTimes, freeUntil`. Rules in `Core/Sources/DeckMateCore/GlanceMore.swift`, Mac side in `App/Sources/Glances.swift`. `Glance` gained `tone`. 20 new data tests (112 in all). iPhone and iPad stay 0.16 (build 21). Not proven yet: no key was pressed on a real screen or the real box.

**0.11.1 (Mac, build 19, 18 Nov 2026).** Long press on a Weather key gives it another town (section 58). New `ActionType` case `weatherTown`. 3 new data tests, 92 in all (89 before). iPhone and iPad stay 0.16 (build 21). Not proven yet: not pressed on the real box.

**0.11 (Mac, build 18, 17 Nov 2026).** Round 2 of 3: six new kinds of key (sections 56 to 62: Next event, Weather, Due today, Album cover, Body Battery, Desk; 23 kinds before, 29 now). New `ActionType` cases `nextEvent, weather, dueToday, cover, bodyBattery, desk`. Rules in `Core/Sources/DeckMateCore/GlanceKinds.swift`, Mac side in `App/Sources/Glances.swift`. `LiveKeys` gained `glances`, `battery`, `cover`, `coverReady`. Info.plist gained `NSCalendarsFullAccessUsageDescription` and `NSAllowsLocalNetworking`. iPhone and iPad stay 0.16 (build 21). Not proven yet: none of the six was pressed on a real screen; the two one-time questions (calendar, OmniFocus) are not seen yet. Round 3: the dial key on iPhone and iPad and the resting box.

**0.10 (Mac, build 17, 17 Nov 2026).** Round 1 of 3 (his 25 picked ideas): six new kinds of key (sections 46 to 51: Timer, Switch, Run an Apple Shortcut, List to pick from, Open app, Microphone light; 17 kinds before, 23 now), the Wait step (52), Find a key (53), Settings > Key use (54) and four ready-made page groups (55). Drawings: 254 (252 before). 68 data tests (52 before). iPhone and iPad stay 0.16 (build 21). Round 2: keys that need a yes from the Mac first (next calendar event, weather, OmniFocus tasks due today, album cover, Body Battery, the "Desk" key). Round 3: the dial key on iPhone and iPad and the resting box.

**0.9.4 (Mac, build 16, 17 Nov 2026).** One more drawing to choose for a key in Set up keys: Drawer (a drawer front with a small handle; file `drawer.svg`). Before: 251 drawings. Now: 252. It comes from the shared AMS icon library, same style as the others (one line, round ends, no fill), and shows on the Stream Deck, on screen keys and on the iPhone and iPad (the Mac draws the keys), so the iPhone and iPad app stays 0.16 (build 21). In his page group "My Apps", page "Home & trips", place 9: the GridFit key now shows the white drawer drawing, the same mark AMS Apps Overview shows for AMS Snug GridFit (his choice on 17 Nov, "Use the drawer"). Before it showed Autodesk Fusion's app icon. The key still opens Autodesk Fusion, stays blue (it opens an app) and did not move; a copy of the keys file from before is in Backups. Existing keys keep their icons. No new test (no new rule); 52 data tests as before.

**0.9.3 (Mac, build 15, 17 Nov 2026).** A key can show a picture (for example an app's real icon) instead of a white drawing. Before: only keys that open an installed Mac app showed a real icon; keys that open a web address or a file could only show a white drawing. Now: icon "picture:<name>" means `<name>.png` in the Pictures folder beside the keys file; `DeckKey.pictureName`, drawn in KeyArt.swift, rounded corners (23 % of the side), 36 of 72 points wide with a title and 46 without; tile keeps its kind colour; missing file falls back to the automatic drawing. Shows on the Stream Deck, on screen keys, in Set up keys and "All pages", and on the iPhone and iPad (the Mac draws the keys), so the iPhone and iPad app stays 0.16 (build 21). Set up keys: the Icon button says "Own picture"; a drawing or "Automatic" replaces it; no button yet to choose a file (`Tools/deck-pages.py --icons` in AMS Apps Overview puts the pictures and copies the icon files). The weekly iCloud copy and safety copies hold only the keys file, not Pictures; the tool can restore them. In his page group "My Apps" (34 app keys on 5 pages): 10 web-app keys now show the app's real icon instead of a white drawing: Breathing (breath), Cold Shower (ice bath), Big 12S (book), Tracking (badge), Tri Glossary (triathlon), FermentLog (bottle), PackTrack (box), CountDown (hourglass), PomoTimer (stopwatch), TechLingo (laptop). The Timers key changes from a watch drawing to the stopwatch drawing (the mark AMS Apps Overview shows for Timers). The five "Overview" keys (place 14, bottom right, on each of the five pages) have no drawing picked any more and so show AMS Apps Overview's own app icon (before: the list drawing `control-list`); 16 keys changed their icon in all. For checks from outside: `--pages <folder>` writes every page of the setup as one picture of its 15 keys (`KeyArt.pngForCheck`, five keys of 144 across) and changes nothing; with `--data <folder>` it reads another setup. The 20 installed-app keys already showed the real icon, unchanged. No icon of their own, drawing kept: Ironman plan (triathlon), Wealth (wallet), Nutrition (food); GridFit keeps Autodesk Fusion's icon. No key moved; a copy of the keys file from before is in Backups. Drawings to pick from unchanged: 251. One new data test (`testAKeyCanNameAPictureOfItsOwn`), 52 in all (51 before).

**0.9.2 (Mac, build 14, 16 Nov 2026).** Six new drawings to choose for a key in Set up keys: Home, Arrow up, Arrow left, Arrow right, Window top half, Window bottom half. Before: no house, only an arrow down, and for windows only left, right and full; 245 drawings. Now: 251. They come from the shared AMS icon library and show on the Stream Deck, on screen keys and on the iPhone and iPad (the Mac draws the keys), so the iPhone and iPad app stays 0.16 (build 21). Nothing else changed; existing keys keep their drawings.

**0.9.1 (Mac, build 13, 16 Nov 2026).** Only the colour of Raycast keys: a clear red instead of red-orange. iPhone and iPad are 0.15 (build 20) at that time; they take the colour from the Mac. Nothing else changed.

**0.9 (Mac, build 12, 16 Nov 2026).** The weekly copy of the keys in iCloud Drive (section 40), the list choice of "Last copied text" (section 41). The iPhone and iPad app is 0.12 (build 17): the lock mark (section 42). Link version stays 7. The code is public on GitHub with the rule tests running there at every change (section 14). Not proven yet: the iCloud Drive question and copy on a real Mac over weeks; the list on a real Mac in daily use.

**0.8 (Mac, build 11, 16 Nov 2026).** The keys "Last copied text" and "Recent file" (section 36), "Bring back an earlier state…" and the self-repairing keys file (section 37), the private link `secure(promise:key:)`, link version 7 (section 38), the trimmed box diary and the "Mac is back" note (section 39). `Store` moved into `Core`. The iPhone and iPad app is 0.11 (build 16). Mac 0.8 and app 0.11 only talk to each other. Not proven yet: "Recent file" and "Last copied text" on the real Mac in daily use; the number check on a real iPhone and iPad.

**0.7.1 (Mac, build 10, 16 Nov 2026).** Understands the new link message `visit(profile:)` (link version 6): a swipe on the iPhone or iPad shows a page group without locking it (section 35). The iPhone and iPad app is 0.10.1 (build 15).

**0.7 (Mac, build 9, 16 Nov 2026).** The keys "Recent app" and "Ask AI (copied text)" (sections 31, 32), and the Mac's sleep and wake news for the iPhone and iPad (section 33). The iPhone and iPad app is 0.9 (build 13). Not proven yet: "Ask AI" against the real Raycast, the dark screen on the real iPad.

**0.6 (Mac, build 8, 16 Nov 2026).** The navigation picture (section 29). The iPhone and iPad app is 0.9 (build 13) at that time; 0.10 (build 14) is the side panel and the lock in Settings (section 34). Not proven yet: the navigation picture on the real iPad.

**0.5 (Mac, build 7, 16 Nov 2026).** The features of sections 24 to 28, and "All pages" in Set up keys. The iPhone and iPad app is 0.7 (build 10). Not proven yet: long press on the real box, long press on a real iPhone or iPad, play or pause from the strip.

**0.4.1 (Mac only, build 5, 16 Nov 2026).** Only change: the keyboard letters on the keys on screen (see section 3). The iPhone app was then at 0.4 (4); it is now 0.5.2 (7), see section 22. Mac 0.4.2 is described below.

## 16. Not in 0.4
- The first Stream Deck from 2017.
- Other box sizes (6 and 32 keys, XL, Mini, Plus, Neo, pedal).
- Elgato plug-ins.
- Driving the real box (first test planned for January 2027).
- The iPhone app on the Mac (the iPad came in 0.5), and editing keys from the iPhone (keys, favourites and long press are set up on the Mac only).

## 17. The iPhone link (0.3)
**What it is.** Deck Mate on the iPhone shows the same 15 keys as the box, in the same places and with the same pictures. It follows the page group and page the Mac shows (so it changes with the app in front). A tap on a key makes the Mac do it.

**Finding each other.**
- Two Bonjour offers over TCP, same instance name (the Mac's name): `_amsdeckmate._tcp` without peer-to-peer (the shared network — proven, also from the iOS Simulator) and `_amsdeckdirect._tcp` with peer-to-peer on (AWDL, like AirDrop). On his Mac (16 Nov 2026) the peer-to-peer listener goes ready but never registers its service, so the direct way is NOT proven; a shared Wi-Fi (or the Mac on the iPhone's hotspot) is the way that works. The iPhone browses both types with peer-to-peer on and picks the Mac it talked to last, else the first by name. A connection not ready within 6 s is dropped and the search goes on. The Mac also makes a short Bonjour browse and a one-byte UDP send to 224.0.0.251:5353 at start, so macOS asks for (or refreshes) Local Network permission — each new build gets a new executable UUID, and until that refresh the system silently keeps the offer from registering.
- The Mac listens and advertises the service. The iPhone browses for it.
- The iPhone needs the Local Network permission (Settings, Privacy & Security, Local Network). The Mac may ask once to "find devices on local networks": answer Allow.

**Messages** (`PhoneLink.Message`, in `Core`, used by both apps).
- Frame: 4 bytes, big-endian, giving the length of the JSON that follows, then the JSON. Largest message: 4 MB; anything longer is refused.
- `hello(phone, token?)`: the iPhone says its name and, if it has one, its token.
- `waiting`: the Mac is asking its user; the iPhone shows that it waits.
- `welcome(token, mac)`: allowed. The Mac sends the token to keep and its own name.
- `refused`: not allowed (the user chose Don't Allow, or the checkbox is off). The iPhone shows "Ask again".
- `keys(place, keys[index, title, PNG])`: `place` is the position (the line on top of the keys, as the Mac shows it: the group's name, plus " · " and the page's name when the page group has more than one page (e.g. "Mail · Page 2") as shown on the Mac); each key has its place 0 to 14, the title shown (see `shownTitle`) and its picture as PNG, drawn by the Mac (so app keys have the real app icon). The Mac sends `keys` first when the iPhone is allowed, then again whenever the position or the setup changes.
- `press(index)`: the iPhone tapped a key.

**Version rule (0.6).** `PhoneLink.currentVersion` is 4 (it was 3 in 0.5). The navigation picture (section 29) needs the Mac at 0.6 and the iPhone and iPad app at 0.8; its new messages go only to a side that announced version 4. With an older Mac the picture stays hidden and everything else works as before.

**Version rule (0.5).** `PhoneLink.currentVersion` was 3. The Mac's version rides in `welcome`. The new parts need the Mac at 0.5 and the iPhone and iPad app at 0.7. An iPhone or iPad at 0.7 with an older Mac (which sends no version) works as before: Settings says "Needs AMS Deck Mate 0.5 on the Mac" in the Keys card and the new parts stay hidden. A Mac at 0.5 with an older iPhone app works as before; the white dot is part of the key pictures, so it still shows.

**New messages (0.5).**
- iPhone to Mac: `own(profile:)` (use my own keys with this page group; nil means "Follow the Mac"), `hold(index:)` (the key at this place was held for 0.5 s: run its `held` action, or the normal action if it has none), `favourite(index:, long:)` (a favourite 0 to 4 was tapped; `long` true for a hold), `music(command:)` with `playPause`, `next`, `volumeUp`, `volumeDown`.
- Mac to iPhone: `favourites(keys:)` (the 5 favourites: index 0 to 4, title, PNG, with the white dot where `held` is set), `mac(MacNow)` (see section 27).
- Framing, the 4 MB limit and tolerant decoding are unchanged.

**Allowing.**
- Since 0.8 (link version 7) this whole exchange is replaced by the private link and the paired-device secret of section 38; the plain `hello` token below is the 0.3 to 0.7.1 behaviour. `PhoneLink.currentVersion` is 7 until 0.14 and 8 since 0.15 (section 96).
- First contact: `hello` with no token. The Mac asks "“<iPhone name>” wants to use your keys. Allow?" with Allow and Don't Allow. Allow gives a random token and the iPhone is remembered; Don't Allow sends `refused`.
- Tokens are random. The Mac keeps them in its preferences with the iPhone's name; the iPhone keeps the token per Mac name. A `hello` with a known token is welcomed at once, with no question.
- The iPhone's "Ask again" sends a new `hello` with no token.
- "Forget" on the Mac removes the token; "Forget this Mac" on the iPhone removes its copy.

**Pressing.** A `press(index)` goes through the same press path as a key on the box (`outcome` and navigation are the same). The "Hide after a key is pressed" rule does not apply: only clicks on the Mac screen hide the keys.

**Mac Settings, card "iPhone".**
- Checkbox "Let an iPhone use these keys" (default on). Off: no listening, connected iPhones are dropped.
- The iPhone connected right now.
- The allowed iPhones, each with "Forget" to take the permission back.

**The iPhone app.**
- Bundle id `com.schabbauer.AMSDeckMatePhone`; display name "Deck Mate"; iOS 17 and later; iPhone and iPad (since 0.5); on TestFlight. Version 0.10 (14). Source in `Phone/`; its guide is `Phone/Sources/PhoneGuide.swift`, the same shape as `App/Sources/Guide.swift`.
- Shows the 15 keys (5 columns, 3 rows) upright and sideways. Keeps the screen on while connected.
- 0.4 look and behaviour: see section 21.
- States: "Looking for your Mac…", waiting for the Mac's answer, connected (keys), refused ("Ask again").
- Settings: which Mac, "Forget this Mac", the version, How it works, What's new.

## 18. App names on keys (0.3)
- `DeckKey.shownTitle(appName:)`: the title if it is not empty; otherwise, for an app key, the app's name (as the Mac knows it from the bundle or path); otherwise empty. Other kinds are unchanged.
- Used by the box, the Mac screen and the iPhone, so the Apps folder's keys now read Mail, Safari, Calculator and so on.

## 19. The Raycast folder (the author's own setup, data)
- On Page 1 of the Default Page group, a key "Raycast" opens a folder: Back plus 14 Raycast commands from the installed extensions: Clipboard, AI Chat, Ask Perplexity, Hide apps, New reminder, Reminders, Notion note, Find in Notion, Daily plan (NotePlan), Screenshot (CleanShot area), Text from screen (CleanShot OCR), Play/Pause and Next song (Spotify), Passwords (1Password).
- Keys that need no window run quietly (`quiet`). Changed in Set up keys as usual. This is data in `deck.json`, not a feature.

## 20. Set up keys, 0.4 (Mac)
**Drag.** A key is dragged to another place of the page: it moves there, or swaps with the key already there. A key dropped on a page chip at the top moves to that page, to the same place; a key already there swaps. A folder key takes its folder (and the folder's pages) along.

**Copy and paste.** Edit menu: Command-C and Command-V, when a key is picked and no text field is being edited. The pasted key replaces the picked one (it gets a new id).

**Duplicate.** "Duplicate page" (button beside Delete page) copies the page and its folders; the copy is named "<name> copy". "Duplicate page group" (button beside Make default) copies the page group; the copy belongs to no app (`apps` is empty).

**Undo and Redo.** Command-Z and Shift-Command-Z, also two buttons in Set up keys. They go back and forward through the last 30 changes to the setup, as long as the app runs (the list is not saved). The safety copies on disk (section 13) stay as before.

**Broken keys.** A key is broken when: its app is not found (bundle identifier or path), its file or folder is gone, its Raycast extension is not installed, its folder page is gone, or its page group is gone. A broken key gets a red corner mark on the screen and in Set up keys; the picked key shows the one-line reason. Settings, "Check keys", "Check all keys" lists every broken key as "Page group · Page · key: reason".

## 21. The iPhone app, 0.4
The iPhone needs the Mac at 0.4 for the new parts (marked *).
- Layout: the 15 keys sit at the bottom of the screen, near the thumb; the heading is on top (see section 30).
- Page groups by swipe: a swipe up on the keys shows the next page group, a swipe down the one before, round the end (`PhoneLink.Status.profile(after:)`); nothing happens with one page group. Since 0.10.1 (Mac 0.7.1) the swipe does not lock: it is sent as `visit(profile:)` (link version 6) and the Mac's `AppModel.visit(_:)` clears any lock and shows that group, so the keys stay on Automatic and follow the next app that comes forward. From 0.5.1 to 0.10 a swipe locked, sent as `profile(id:)`; that is still what happens when the Mac is older than 0.7.1 (link version below 6). A swipe counts when it is longer than 60 points and at least 1.5 times as long in its own direction as in the other.
- Pages: swipe left or right on the keys for the next or previous page. Page dots under the keys show which page; no dots inside a folder or with one page.
- Page group lock (changed in 0.10, section 34): the name at the top is only a heading, with no menu and no lock drawing. The lock is the row "Page group" in Settings, Keys card: chips "Automatic" and one per page group. Before 0.10 a tap on the top line opened a menu "Automatic" / "Lock one" and the lock showed beside the name (0.5.2). *
- Pressed keys light up: a key pressed on the box, on the keys on the Mac screen or on the iPhone shows pressed on the iPhone. *
- What ran: after a tap a short note at the bottom, for example "Opened Mail" or "Raycast: Clipboard history". When the Mac could not do it the note is red with the warning drawing, for example "The app is not on this Mac" or "The Mac has not allowed key presses yet". *
- Day look: the iPhone screen follows day and night (light grey by day, dark by night); the keys stay as drawn.
- Hotspot hint: after 20 seconds of "Looking for your Mac…" a card explains: turn on Personal Hotspot on the iPhone and pick the iPhone in the Mac's Wi-Fi menu. Button "Open Settings"; the close (x) button hides the hint.
- The app uses its own warning and close drawings; the 22 hand-drawn deck drawings are also in the AMS Icon Library as app marks.

## 22. The iPad, 0.5, 0.5.1 and 0.5.2 (iPhone and iPad app, build 7, 16 Nov 2026)
The Mac app was 0.4.1 (5) through 0.5.1; it is now 0.4.2 (6). On the iPhone only the version number changes.
- Deck Mate is now also an iPad app, made for the iPad mini. It fills the whole screen, upright and on its side (all four ways round), instead of a phone-sized window.
- The 15 keys are larger and sit low and centred. The top line, page dots, swipe for pages, page group menu, lit keys and the "what ran" note work the same as on the iPhone.
- On an iPad the words on screen say "iPad" instead of "iPhone".
- Hint after 20 seconds of "Looking for your Mac…" on an iPad: put the iPad and the Mac on the same Wi-Fi, for example both on the iPhone's hotspot (an iPad without mobile data has no hotspot of its own).
- The Mac asks once whether to allow the iPad, exactly like for an iPhone; in the Mac's Settings it appears in the "iPhone" part by its name.
- Installed from TestFlight on the iPad like on the iPhone.

**0.5.1 (build 6, 16 Nov 2026), iPad only; the iPhone changes only in its number.**
- On a newer iPad the app can open as a floating window. Make it large once with the window's green button (or drag its corner) and the iPad remembers it.
- The keys are larger: they grow as far as the screen or window allows (before they stopped at a fixed width). On its side the iPad mini shows keys about a fifth larger.
- Fixed: in a floating window the window's three round buttons lay over the name of the page group in the top line. The top line now steps aside for them if the app ever is in a window.

**0.5.2 (iPhone and iPad app, build 7) and Mac 0.4.2 (build 6), both 16 Nov 2026.**
- The word "held" is gone from every text; it now says "locked".
- A page group picked by hand (the row "Page group" in Settings on the iPhone and iPad, or the Mac's menu; a swipe up or down no longer locks since 0.10.1, section 35) shows a small hand-drawn lock beside the name of the page group: on the iPhone and iPad top line and on the Mac's keys on screen. Locked: the page group stays until "Automatic" is chosen (tap the top line on the iPhone and iPad; the menu bar menu on the Mac). No lock: on the Mac the page group follows the app in front.
- Mac menu line: "Page group: <name> (locked)" or "(automatic)". iPhone and iPad menu section: "Lock one".
- iPad only: the top line is larger: the name of the page group is title size and bold, the "Connected to …" line is bigger, and the settings button is larger. The iPhone top line is unchanged. (Changed in 0.8.1, see section 30: the heading is centred, there is no "Connected to …" line any more, and the iPhone heading is title size.)
- Nothing else changes. The Mac and the iPhone and iPad app work with each other in any mix of these versions.

## 23. iPhone and iPad settings, 0.6 and 0.6.1 (iPhone and iPad app, build 9, 16 Nov 2026)
(Mac 0.5 (7) since 0.7 of the iPhone and iPad app.) The Mac app was unchanged at 0.4.2 (6) in 0.6 and 0.6.1. Settings are opened with the gear at the top right (since 0.13 at the bottom left with the iPad or iPhone on its side, section 43). Every choice applies at once and is remembered on that device only. Done closes Settings. With the first (default) choice of everything the app looks and works as in 0.5.2. Four groups, then the unchanged "Your Mac" part with "Forget this Mac".

**Look**
- Background: Day and night (default: light by day, dark by night, as before) / Always dark / Night blue / Forest / Plum / Rust / Slate (Rust and Slate since 0.6.1). The colours are deep, calm shades; the words turn light on them.
- A colour for each page group (0.6.1, under Background): every page group from the Mac is listed with its own choice, "Same as background" (default) or one of the colours. While that page group shows, the background takes its colour. It needs a Mac at 0.4 or later (the list of page groups comes from the Mac); before a Mac is connected the list says so.
- Key shape: Rounded (default, as before) / Square / Pillow (very round corners).
- Gaps between keys: Narrow / Normal (default, as before) / Wide.
- Key size: Largest (default, as before) / A bit smaller (about 85 %, more air around the keys).
- Where the keys sit: Bottom (default, as before) / Middle / Top.

**Clock**
- Clock above the keys (default off): a large clock with the date in the free space above the keys. It only shows when there is room, for example on an iPad upright; not on an iPhone on its side.
- Resting clock: Never (default) / after 2, 5 or 10 minutes without a touch. The keys fade away and only a large dimmed clock with the date shows, like a desk clock. One tap anywhere brings the keys back; that tap presses no key.

**Touch**
- Tap buzz (default on): the small buzz when a key is tapped. iPhone only; an iPad has no buzz.
- Click sound (default off): a soft click when a key is tapped. It follows the device's silent switch and volume.
- Swipe up or down changes page group (default on). Off: a swipe up or down does nothing. Left and right for pages always works.

**Showing**
- "What ran" note (default on), Page dots (default on).
- Keep the screen awake while connected (default on). Off: the screen sleeps as usual.
- Warn when the battery is low (0.6.1, default on): at 20 % or less and not charging, a small amber line "Battery 18 % – plug in" shows centred under the heading and also under the resting clock. It goes away when charging or above 20 %.

**Planned, not in 0.6:** done in 0.7, see sections 24 to 28. In 0.7 the Settings list gets a new first part "Keys" (section 26) and three new switches under "Showing": Favourites row, Mac at a glance, Music strip (called "Music button" since 0.8.1) (all default on, stored on that device). With an older Mac the new parts say "Needs AMS Deck Mate 0.5 on the Mac".

## 24. Long press (Mac 0.5, iPhone and iPad 0.7)
- Stored in `deck.json` as `held` on the key: an Action like the normal one (`type`, `target`, `combo`, `steps`, `quiet`). Missing or type "none": no long press.
- Set in Set up keys: under "What it does" a picker "Long press": Nothing, or any action type except "Folder of keys", filled in like the normal action. Cancel and Save as for every edit.
- Mark: a key with a `held` action that is not "none" shows a small white dot in its top right corner. It is drawn in the key picture, so it shows on the box, on the keys on screen and on the iPhone and iPad (also on an iPhone app older than 0.7).
- A broken `held` action (app, file or folder gone and so on, as section 20) shows the red corner, with the reason "Long press: <reason>" in Set up keys and in "Check all keys".
- Time: a press of 0.5 s or more is long (`Navigator.longPress` = 0.5).
- A long press on a key without `held` does the usual thing. Since 0.20 a key can also have a double press, `twice` (section 141); the dot of this section keeps its one meaning, hold.
- iPhone and iPad: a key with `held` sends `hold(index:)` after 0.5 s, with a stronger buzz (if Tap buzz is on); a shorter tap sends `press(index:)`. A key without `held` sends `press` at once.
- Box and Mac keys on screen: a key with `held` acts when let go (short) or after 0.5 s still held (long); all other keys act at once. The box rule is not yet tried on the real box.
- "Hide after a key is pressed" applies to the action that ran, as in section 3.

## 25. Favourites row (Mac 0.5, iPhone and iPad 0.7; gold ring since 0.29, section 134)
- **Later change.** Since 0.28 on an iPad on its side with several pages at once: a column at the right of the pages, as big as the keys (section 133).
- 5 places, 0 to 4, that stay in place on every page and in every page group. Stored in `deck.json` as `favourites` on the Deck. They belong to the whole setup, not to a page group or a page.
- Any action except a folder or Back. A favourite can also have a long press (`held`).
- Set in Set up keys: a row "Favourites" under the 15 keys. Click one and edit it like any key. Copy and Paste work on favourites; dragging does not.
- Shown only on the iPhone and iPad, as a row of 5 under the 15 keys, with the same key look. Not on the box and not on the Mac's keys on screen.
- iPhone and iPad Settings, Showing: switch "Favourites row" (default on, stored on that device). The row shows only when at least one favourite is set.
- A tap sends `favourite(index:, long: false)`, a hold `favourite(index:, long: true)`. The Mac does the action like a key press. A favourite that moves to another page or page group moves the device's own place when it has its own keys (section 26), else the Mac's place.

## 26. My own keys (Mac 0.5, iPhone and iPad 0.7)
- iPhone and iPad Settings, new card "Keys" at the top: "Follow the Mac" (default, as before) or "My own keys", then a page group is picked in the row "Page group", from the Mac's list. Stored on that device (`ownKeys` and `ownProfile` settings); each device has its own choice.
- With own keys the device sends `own(profile:)`. The Mac then keeps one own place for that device: page group, page and folder path. It is kept in memory for the connection; after reconnecting, the device starts at the first page of its group. Pages, folders, Back, next and previous page, and switch page group pressed on that device move that place only.
- The Mac's keys on screen, the box and the Mac's own place do not move. The Mac still does what the tapped key says. Keys pressed elsewhere do not light up on a device with its own keys.
- Swipe up or down, or the menu in the top line, changes the own page group (round the end, as section 21), and it is remembered on the device. With own keys there is no lock and no "Automatic" in that menu.
- If the picked page group is gone, the default page group shows.
- `own(profile: nil)` means "Follow the Mac".
- With an older Mac the card says "Needs AMS Deck Mate 0.5 on the Mac" and the app follows the Mac.

## 27. The Mac at a glance (Mac 0.5, iPhone and iPad 0.7; moved in 0.8.1)
- Message `mac(MacNow)` from the Mac with the fields `battery`, `charging`, `app`, `song`, `artist`, `playing`, `volume`. It is sent when the iPhone is allowed and again when something changes.
- The Mac looks at battery and volume every 5 seconds, only while such a device is connected.
- Since 0.8.1 until 0.12: one very small centred line at the very bottom of the screen, under the page dots (before, in the top line): a small battery drawing and "73 % charging · Claude", or "82 % · Safari" when not charging. A Mac without a battery shows only the app.
- 0.13 only (section 43): two small pills at the bottom middle, a green battery pill and a blue app pill.
- Since 0.14: one small blue pill at the bottom middle with the app in front ("Claude"). The battery pill of 0.13 was removed; the Mac's battery is no longer shown on the iPhone or iPad. Since 0.15 the pill is green (the same green as the settings gear, words and pill); before, blue words on a light blue pill.
- Settings, Showing: switch "Mac at a glance" (default on, stored on that device).

## 28. The music button and plate (Mac 0.5, iPhone and iPad 0.7; button since 0.8.1)
- Since 0.8.1 (before, a strip above the keys): one small round button at the top right of the key screen, beside the settings button (since 0.13, with the iPad or iPhone on its side, at the bottom left, section 43), shown when the switch "Music button" is on (default on, stored on that device; the stored setting is the same one that was called "Music strip") and the Mac is at 0.5. Since 0.27 its note sits inside a thin green ring that is never filled (section 132). A tap opens a small plate with: song and artist, play or pause, next, quieter, the Mac's volume in percent, louder. A tap outside the plate closes it. Since 0.8.2 the plate has a solid background (the card colour), not see-through glass.
- Spotify and Apple Music. The Mac listens for the change notices both send when the song or the play state changes, so the plate says "Nothing playing yet" until the next change of song or pause after the Mac app has started.
- Buttons send `music(command:)`: `playPause`, `next`, `volumeUp`, `volumeDown`. Play or pause and next are done as the Mac's music keys, so they need the same one-time Accessibility permission. Volume moves 6 points per tap and needs no permission.
- Not yet tried: play or pause from the plate.

## 29. The navigation picture (Mac 0.6, iPad 0.8, iPhone on its side 0.10)
- **Later change.** Since 0.28 on an iPad on its side with several pages at once: opened as a plate by the "Pages" button (section 133).
- Where: on an iPad or, since 0.10, an iPhone held on its side (wider than tall). The keys sit on the right and the navigation picture on the left, in the side panel (section 34). An iPad or iPhone held upright shows no picture, because there is no room on the left.
- What it shows: every page group, with every one of its pages and folders, each as a small picture of its 15 keys with the page's name under it. A folder shows its folder mark. The page showing now has a blue frame. Since 0.16 each page group sits in its own framed panel with its name as a ribbon (section 45); before 0.16 the name was a plain small word above the pages and was highlighted for the active group. The list scrolls when it is long.
- Pictures: drawn by the Mac, PNG, 166 x 98 px each, and sent when the setup changes (and when a device that announced version 4 connects).
- Messages (only to a side that announced version 4): Mac to iPhone `map(groups:)`; each group has id, name and pages; each page has id, name, folder (yes or no) and its PNG picture. iPhone to Mac `go(profile:page:)`.
- `Status` has a new optional field `pageID`: the page showing now. The iPad uses it to draw the coloured frame and the highlighted name.
- Tap on a small page: the iPad sends `go(profile:page:)`. The rule `Navigator.go`: an unknown page group or page changes nothing.
- Follow the Mac: the Mac goes to that page and that page group is locked, as when it is picked in the top-line menu. "Automatic" in that menu lets it follow the app in front again.
- My own keys (section 26): only the iPad's own place moves, and the picked page group is remembered on the device.
- Settings, Keys card: new switch "Navigation picture" (setting key `showMap`, default on, stored on that device), with the note (since 0.10) that it shows on an iPad or iPhone held on its side.
- Older versions: the picture needs the Mac at 0.6 and the iPad app at 0.8. With an older Mac (no `map`) the picture stays hidden and everything else works as before.
- Not proven yet: on the real iPad, and (0.10) on a real iPhone held on its side.

## 30. The key screen's top (iPhone and iPad 0.8.1)
Made after 0.7 on a real iPad, where the top was too crowded. Only the key screen changes; the Mac app is unchanged (0.6, build 8).
- Heading: the place (for example "Mail · Mail Main") is centred at the top and larger: large title size and bold on the iPad, title size on the iPhone. Since 0.10 it is only a heading: no menu on a tap and no lock drawing beside it (section 34).
- Connection: one small coloured dot at the top left, instead of the line "Connected to <Mac>". Green: connected (since 0.15 the same green as the settings gear; before, its own brighter green). Amber: looking, connecting, or waiting for the Mac to allow it. Red: the Mac said no. A tap on the dot opens a small card that says it in words (for example "Connected to the Mac") and what the colours mean. Since 0.8.2 the card has a solid background (the card colour), not see-through glass. The big message card in the middle while there is no Mac is unchanged.
- Music: one small button (since 0.27 a note in a thin green ring) at the top right, beside the settings button (since 0.13 at the bottom left on its side, section 43); the plate it opens is in section 28. The Settings switch is called "Music button".
- The Mac at a glance: one very small centred line at the very bottom, under the page dots (section 27); 0.13 had two pills, since 0.14 one small pill with the app in front, green since 0.15 (section 43). Same switch.
- The iPad's own low battery warning ("Battery 18 % – plug in") sits centred under the heading.
- Test: the phone screen test now also opens the music plate and the connection card (found by their identifiers).
- Proven on the real iPad with 0.7: the Mac's battery, the app in front and the lock showed correctly.

## 31. The "Recent app" key (Mac 0.7)
- Set up keys, "What it does", "Recent app", with a choice 1st, 2nd or 3rd. New action types `recent` (the number "1"–"3" in `target`) and `askAI`; an older Mac reads an unknown type as none.
- Meaning: 1st is the app used just before the one in front, 2nd the one before that, 3rd the one before that. The key shows that app's icon and name.
- The list: the apps used last, newest first, kept by watching which app comes to the front. Deck Mate's own windows never count. The list is saved and is remembered when the Mac restarts.
- The picture changes by itself as the app in front changes, on the box, the keys on screen and the iPhone and iPad (the Mac redraws and sends the pictures).
- Press: the chosen app comes forward. If the place has no app yet, nothing happens.
- Until enough apps have been used: a clock drawing and the title "Recent", in blue (the app kind colour). Three keys side by side set to 1st, 2nd and 3rd show the last three apps.
- Colour: blue (kind app). Broken-key check: never broken.

## 32. The "Ask AI (copied text)" key (Mac 0.7)
- Set up keys, "What it does", "Ask AI (copied text)". Raycast colour (red), an AI drawing, title "Ask AI".
- Press: the Mac reads the text last copied (the clipboard) and opens Raycast AI Chat with it filled in. Nothing copied, or a picture copied: AI Chat just opens. Text over 4,000 characters is cut at 4,000.
- The link used is the corrected AI Chat link of section 7, with the text added to it.
- Not proven yet: against the real Raycast. If the text does not arrive in AI Chat, this is a first version and needs a second look.

## 33. Dark while the Mac sleeps (Mac 0.7, iPhone and iPad 0.9)
- The Mac tells a connected iPhone or iPad when its screen goes to sleep and when it wakes (the Mac sleeping counts as the screen going to sleep). New `PhoneLink` message, sent only to a side that announced the new version.
- Settings, Showing: new switch "Dark while the Mac sleeps" (default on, stored on that device).
- When the Mac sleeps and the switch is on: the iPhone or iPad shows a black screen with a small moon drawing and the words "Mac asleep", and stops keeping itself awake, so it may lock itself like normal.
- When the Mac wakes: the screen brightens by itself and the keys come back. One tap during the dark screen shows the keys again.
- With the switch off, or with an older Mac, nothing changes: the keys stay and "Keep the screen awake while connected" works as before.
- Needs the Mac at 0.7 or later.
- Not proven yet: on the real iPad.

## 34. Side panel and lock in Settings (iPhone and iPad 0.10, build 14)
Only the iPhone and iPad app changes; the Mac app is unchanged.
- Side panel: when the screen is wider than tall (iPhone or iPad on its side), the key screen has two parts. On the left is the side panel (accessibility identifier `sidePanel`), 200 points wide on the iPhone and 230 on the iPad. On the right the keys get the whole height.
- In the panel, top to bottom: the top line (status dot, page group name as heading; until 0.15 on the iPhone it was in this panel, since 0.16 it stands in the middle above the keys, section 45; until 0.12 also music button and settings gear, since 0.13 those two sat at the bottom of the panel, section 43; since 0.16 on the iPhone they sit in a narrow column to the right of the keys, section 45), the note on what a key did ("what ran", section 21), and the navigation picture (section 29). Since 0.16 on the iPhone the panel holds only the note (when shown) and the navigation picture; the buttons and the heading moved out (section 45), so the picture takes all the height.
- Key size on an iPhone on its side: about 100 to 115 points (before 0.10 about 80, because the top line, note and page dots sat above and below the keys). The iPad's keys grow as far as the space allows, as before.
- Navigation picture: now also on the iPhone on its side, same as the iPad on its side. Upright (iPhone or iPad): no picture, as before. The Settings switch `showMap` still turns it off.
- Clock above the keys: still not shown on an iPhone on its side.
- Heading: the page group name at the top is only a heading. A tap does nothing (no menu) and there is no lock drawing beside it.
- Lock in Settings (iPhone and iPad): Keys card, new row "Page group" with chips. Follow the Mac: chip "Automatic" (identifier `lockGroup-Automatic`) plus one chip per page group (identifier `lockGroup-<name>`). Picking a page group locks it: the Mac stays on it until "Automatic" (same message as before, `profile(id:)`; "Automatic" sends the unlock). The picked chip shows a small hand-drawn lock drawing. The row with "My own keys" (section 26) lists only the page groups, with no "Automatic", as before.
- Still locking: a tap on a page in the navigation picture. A swipe up or down on the keys locked in 0.10 but no longer does since 0.10.1 (section 35). To unlock: "Automatic" in Settings, or the Mac's menu (section 2).
- Test: the phone screen test finds the chips by `lockGroup-<name>` and `lockGroup-Automatic` and the panel by `sidePanel`.
- Not proven yet: on a real iPhone held on its side.

## Not proven yet (0.5, 0.6, 0.7, 0.8.1, 0.9, 0.10, 0.11, 0.11.1, 0.12, 0.13 and 0.14)
- 0.14: none of the new keys was pressed for real before the release. Not tried: the PARAGON keys against PARAGON's real file and links, the quick note window, a whole focus run against PomoTimer in the browser (also after a restart of Deck Mate), reading a real PomoTimer backup file, the playlist cover with real links, and the filled "Stays open" list.
- 0.13: none of the new keys was pressed for real before the release; they were checked with small tests only. Not tried: the questions of Quit all apps, Empty the bin and Eject all disks on a real Mac (also from the iPhone and iPad), the Finder and Spotify questions at the first press, the plain paste (Accessibility), the calendar read of Join the meeting with real meetings, a long press on a counter or stopwatch on the real box, and Keep the Mac awake over a real night.
- 0.12: the five new kinds were checked with real data from the Mac and from the board, and with small tests. Not pressed on a real screen: any of the keys, the calendar question at the first press of Free until, the long press on a World clock or Sunrise and sunset key, and the town look-ups at Open-Meteo from the keys. The box is at home until January 2027.
- 0.11.1: the long press on a Weather key (the "Weather key" window, from the box, the keys on screen and the iPhone and iPad) was checked with small tests only; not pressed on the real box. The box is at home until January 2027.
- 0.11: the six new kinds were checked with made-up data and small tests only. Not pressed on a real screen: the calendar question (Allow Full Access) and the OmniFocus question at the first press, the weather from Open-Meteo, the Spotify notice and cover look-up, the board on port 7788, and the desk put back with real windows (Accessibility). The box is at home until January 2027.
- 0.10: everything was checked with made-up keys and small tests. Dark mode's one-time question ("System Events"), a real Apple Shortcut run and the timer on the real box are not tried yet. The box is at home until January 2027.
- "Ask AI (copied text)" against the real Raycast.
- The dark screen on the real iPad.
- The navigation picture on the real iPad.
- The side panel and larger keys on a real iPhone held on its side.
- Long press on the real box (away until January 2027).
- Long press on a real iPhone or iPad.
- Play or pause from the music plate.
- "Recent file" and "Last copied text" on the real Mac over days of use (Spotlight's "last used" date, the clipboard watcher).
- The 4-digit check number on a real iPhone and iPad against the Mac.

## 35. Swipe no longer locks (Mac 0.7.1, iPhone and iPad 0.10.1)
- Before (0.5.1 to 0.10): a swipe up or down on the iPhone or iPad keys changed the page group and locked it (`profile(id:)`). Unlocking needed Settings, Keys, Page group, Automatic.
- Now: the swipe sends `visit(profile:)` (link version 6, `PhoneLink.currentVersion` is 6). The Mac's `AppModel.visit(_:)` clears the lock and shows that page group. The mode stays Automatic, so the next time a different app comes forward on the Mac the keys follow that app. If a group was locked before the swipe, the swipe unlocks it.
- Still locking: picking a page group in Settings (`lockGroup-<name>`, section 34), a tap on a page in the navigation picture, and the Mac's menu.
- With "My own keys": unchanged; a swipe changes the own page group, no lock.
- Versions: needs the Mac at 0.7.1 or later. `visit(profile:)` goes only to a side at link version 6; with an older Mac the iPhone and iPad app sends `profile(id:)` and a swipe still locks. An older iPhone or iPad app with the new Mac works as before.

## 36. "Last copied text" and "Recent file" keys (Mac 0.8)
- Set up keys, "What it does": two new action types. `copied` (ActionType, `target` "1" to "3") is shown as "Last copied text" with the choices "1st – the text copied just before the current one", "2nd", "3rd". `recentFile` (`target` "1" to "3") is shown as "Recent file" with "1st – the file opened last", "2nd", "3rd". An older Mac reads an unknown type as none. Code: `CopiedTexts` and `RecentFiles` in `Core/Sources/DeckMateCore/Live.swift`.
- Last copied text, key: shows the first words of that text (18 letters). Press: pastes it where the cursor is (needs Accessibility, like "Type text") and makes it the current copied text. Colour: amber (kind text).
- Last copied text, list: the current copied text plus the three before it (4 in all), newest first, in memory only: never written to disk, gone when the app quits. Copies that a password manager marks as secret (concealed pasteboard type) are skipped. The clipboard is only watched while at least one such key exists in the setup.
- Recent file, key: shows the file's name; press opens it. Before a file exists for the place it shows "Recent file". Colour: teal (kind link). Broken-key check: never broken.
- Recent file, list: taken from the Mac's own record of opened files (Spotlight, the "last used" date). Only the last 7 days, only inside the home folder, without the Library folder, hidden files, folders and apps. Newest first. Only looked up while at least one such key exists.
- iPhone and iPad: both keys show and work there, drawn by the Mac (first words of a copied text are therefore visible on the iPhone and iPad key; noted in their How it works).

## 37. Bringing back an earlier state, and the self-repairing keys file (Mac 0.8)
- `Store` (now in `Core/Sources/DeckMateCore/Store.swift`) gains `copies()` (the safety copies in `Backups`, newest first, with date, time, number of page groups and keys) and `deck(of:)` (reads one copy). `AppModel.restore(_:)` brings one back.
- Settings, "Where your setup is kept": new button "Bring back an earlier state…". It opens a list of the safety copies, newest first, each with its date and time and "3 page groups · 47 keys". Pick one, then "Bring back", or Cancel (Escape is Cancel).
- Restoring first keeps the current setup as a safety copy. Undo (⌘Z) also takes it back, the same as any other change.
- `Store.start()` returns `.first` (no file yet: starter keys), `.loaded`, `.recovered` or `.lost`. If `deck.json` cannot be read (before: silent empty starter keys), the newest safety copy that can be read is brought back and the damaged file is kept in `Backups` as "damaged <date>.json"; the app shows a message with the date and time of the copy used (`.recovered`). If no copy can be read, it starts with empty keys and says so (`.lost`). Since 0.15 see section 84 (iCloud copies, a new Mac, an emptied file).

## 38. The private link (Mac 0.8, iPhone and iPad 0.11; link version 7)
- Why: up to 0.7.1 every message (key pictures, taps, the permission token) travelled readable on the Wi-Fi, so on a shared Wi-Fi someone could listen in and press keys. Now every message is encrypted from the first moment. Code: `Core/Sources/DeckMateCore/SecureLine.swift`.
- `PhoneLink.currentVersion` is 7. New message `secure(promise:key:)`: the only message ever sent readable. After it, every frame is a sealed box.
- Start in three steps: (1) the iPhone sends a promise, the SHA-256 of its one-time public key; (2) the Mac answers with its own one-time public key; (3) the iPhone then shows its key, and the Mac checks it against the promise. The promise stops either side choosing its key after seeing the other's.
- Keys: Curve25519 key agreement; HKDF-SHA256 gives one key for each direction; each message is sealed with ChaCha20-Poly1305. A message counter per direction is part of the sealing; a repeated, dropped or reordered message fails and closes the line.
- First-time permission: the Mac's question and the iPhone both show the same 4-digit number, derived from both one-time keys ("Allow only if your iPhone shows the same number."). Nobody sitting in between can make both numbers equal.
- The Mac's question has "Don’t Allow" as the button for Return and Escape; "Allow" has no key and takes a click (`alert.buttons[1].keyEquivalent = ""`), so a key pressed while typing in another app cannot allow a device.
- After Allow the Mac gives the device an id and a secret. Later the device proves itself with a proof (HMAC-SHA256 of the secret over this connection's keys) instead of sending the secret, and the Mac proves itself to the device the same way. Stored on the Mac under `pairedPhones` and on the device under `macKeys`; the old `allowedPhones` and `macTokens` are deleted. So every iPhone and iPad must be allowed once more (one click on the Mac). "Forget" on the Mac and "Forget this Mac" on the device remove the pairing as before.
- Limits on the Mac: a line that has not finished the start within 10 seconds is closed; at most 8 lines at once.
- Versions: Mac 0.8 only talks to app 0.11 or later, and app 0.11 only to Mac 0.8 or later. An older iPhone or iPad app sees "said no" (refused). With an older Mac the new app shows "Update AMS Deck Mate on your Mac". The framing, the 4 MB limit and tolerant decoding of section 17 are unchanged inside the sealed box.
- Tests: SecureLine data tests (both sides agree; tamper and replay are refused; the proof checks out and a wrong secret fails).

## 39. "Mac is back" note and the box diary (Mac 0.8, iPhone and iPad 0.11)
- iPhone and iPad: when the Mac wakes from sleep (the sleep message of section 33), a short note "Mac is back" shows on the key screen. `PhoneLink.wakeNote(wasAsleep:asleep:)` decides (a note only on the step from asleep to awake). It shows together with the "what ran" note, so the Settings switch "What ran" note hides it too. Works with a Mac at 0.7 or later (no new message).
- Mac: the box diary, `~/Library/Logs/AMS Deck Mate/box.log`, is trimmed at each start by `Diary.trimmed`: over 1,000 lines keeps the last 500. Before, it only ever grew.

## 40. Weekly copy in iCloud Drive (Mac 0.9)
- Why: `deck.json` and its safety copies (20 until 0.14; section 83) lived only on this Mac, so a lost or broken Mac meant lost keys.
- Rule: `CloudCopies` in `Core/Sources/DeckMateCore/Store.swift`. `due(last:now:)` is true when there was never a copy or the last one is 7 days or more ago. `Store.copyToCloud` writes `deck <yyyy-MM-dd>.json` (named by its day) into `~/Library/Mobile Documents/com~apple~CloudDocs/AMS Deck Mate` and keeps the newest 8 (about two months); older ones are removed.
- App: `CloudCopy` in `App/Sources/LiveWatch.swift` checks at start and every 6 hours. UserDefaults keys: `cloudCopyOff` (the switch) and `cloudCopyLast` (date of the last copy).
- Settings, "Where your setup is kept": switch "Keep a weekly copy in iCloud Drive" (on at first), a line "Last copy: <date and time>" or "No copy yet", and a button "Copy now". If iCloud Drive is not switched on on the Mac, Settings says so and nothing is copied.
- The first time macOS asks once whether AMS Deck Mate may use iCloud Drive (answer Allow).
- "Bring back an earlier state…" (section 37) also lists the iCloud copies, marked "iCloud" (`Store.Copy.inCloud`).
- Only the keys file goes there: no copied texts, no `pairedPhones`.
- Since 0.16 the copy also holds the key pictures (section 113). The sentence in Settings now says the weekly copy holds the keys and their pictures.

## 41. "A list to pick from" (Mac 0.9)
- `copied` gains the `target` "list" beside "1", "2", "3". Shown in Set up keys as "A list to pick from". An older Mac reads the unknown target as no choice.
- Key: clipboard drawing and the title "Copied texts". Colour: amber, as section 36.
- Press: a small panel (`CopiedListPanel` in `App/Sources/CopiedList.swift`) opens at the mouse pointer with the earlier copied texts (up to three, not the current one), each line its first 60 letters (`CopiedTexts.line(_:)`; the choices come from `CopiedTexts.choices(in:)`). A click pastes that text where the cursor is, as the 1st, 2nd and 3rd keys do (needs Accessibility). A click elsewhere, a second press of the key, or 10 seconds closes the panel.
- From the iPhone, iPad or the box the panel also opens on the Mac (the choice is made with the mouse).
- Same privacy as section 36: memory only, secret copies skipped.

## 42. Lock mark for the private line (iPhone and iPad 0.12, build 17)
- While connected, a small lock drawing (identifier `privateMark`, Phone/Sources/DeckScreen.swift) says the line is private. It shows when `LinkClient.isPrivate` is true (the line is sealed, section 38). Since 0.15 (section 44) it is the same green as the settings gear and a little larger; held upright it sits beside the status dot at the top left, held on its side at the bottom left (section 44).
- The connection card (tap the dot) also says "Private line: nobody else on the Wi-Fi can read your keys or press them."
- Nothing changes in how the link works. Test: the phone screen test checks the lock mark by its identifier.

## 43. Key screen layout on its side (iPhone and iPad 0.13, build 18; Mac at a glance changed in 0.14, build 19)
Only the key screen of the iPhone and iPad app changes; the Mac app is unchanged at 0.9 (build 12). Code: Phone/Sources/DeckScreen.swift.
- Navigation picture, iPad on its side: before, the plate started right under the top line, higher than the keys, and ran down past the page dots. Now its top edge is in line with the top row of keys and its bottom edge with the bottom row of keys, so plate and keys are the same height. With more pages than fit, the plate scrolls as before (section 29).
- Music button and settings gear: before, top right beside the heading on every device. Now, whenever the iPad or iPhone is held on its side (wider than tall), both sit at the bottom left: on the iPad in the bottom-left corner under the plate, on the iPhone at the bottom of the left side panel (section 34). Held upright, nothing changes: both stay top right. Their actions are the same (music opens the music plate, section 28; the gear opens Settings).
- iPhone on its side, top of the left panel: the connection dot sits in the same line as the page group heading. Before, the dot, the music button and the gear shared a line above the heading. Since 0.16 on the iPhone the dot and the heading no longer stand in the left panel: they stand in one line in the middle above the keys (section 45).
- Mac at a glance (section 27): before 0.13, one very small grey line at the bottom middle, for example "95 % · Claude". In 0.13, two small pills: a green battery pill and a blue app pill. In 0.14 the battery pill was removed: now only the pill with the name of the app in front ("Claude"), at the bottom middle. Nothing else moved. Same switch in Settings, Showing ("Mac at a glance"). On the iPhone on its side the pill sat in the left panel just above the two buttons (0.13 to 0.15); since 0.16 it is at the top of the narrow column to the right of the keys, turned on its side (section 45). The low battery warning for the iPhone or iPad itself is a different thing and stays (section 6). Since 0.15 this pill is green (section 44).
- Not proven yet: on a real iPad and a real iPhone held on its side.


## 44. Green and lock place (iPhone and iPad 0.15, build 20)
Only the key screen of the iPhone and iPad app changes; the Mac app is unchanged at 0.9 (build 12). Code: Phone/Sources/DeckScreen.swift.
- Mac at a glance pill (section 27): before, blue words on a light blue pill. Now the words and the pill are the same green as the settings gear.
- Connection dot (top left): connected was its own brighter green; now the same green as the settings gear. Amber (looking, connecting, waiting) and red (the Mac said no) are unchanged.
- Private-line lock (section 42, identifier `privateMark`): before, a very small lock right beside the dot at the top left. Now the same green as the gear and a little larger. Held upright it stays beside the dot (gear and music are top right). With the iPad or iPhone held on its side it sits at the bottom left, in the line with settings and music (gear, music, lock); a tap on it shows a small card: "Private line: nobody else on the Wi-Fi can read your keys or press them." A tap on the dot still shows the connection card with the same sentence.
- Not proven yet: on a real iPad and a real iPhone.

## 45. Page group panels and the iPhone button row (iPhone and iPad 0.16, build 21)
Only the key screen of the iPhone and iPad app changes; the Mac app is unchanged at 0.9.1 (build 13; 0.9.2 later added six drawings). Code: Phone/Sources/DeckScreen.swift.
- Navigation picture (section 29), page group names: before, each page group's name was a plain small word above its pages, purple for the page group you are in and grey for the others. Now each page group sits in its own framed panel. The name is white bold words on a full-colour ribbon that stretches across both small pages: purple for the page group you are in, grey-blue for the others. The panel behind the pages is softly tinted in the same colour. The blue frame around the page that is showing is unchanged, as are the pictures, the names under them, the scrolling and the tap.
- iPhone on its side, buttons: before (0.13 to 0.15), the app pill, the settings gear, the music button and the lock sat in the left side panel (section 34) under the navigation picture, which cut the picture short. Now these four sit in one narrow column to the right of the keys, in the empty strip by the screen's edge. At the top, in line with the top keys: the app pill (section 27), turned on its side so it reads from top to bottom. At the bottom, in line with the bottom keys, one above the other: the lock (identifier `privateMark`), then music, then settings (gear) lowest, in the corner. The keys keep exactly their size and place. Their actions are unchanged.
- iPhone on its side, other direction: if the iPhone is turned so that the camera cut-out is on the right, the column moves to the free strip at the left edge of the screen, left of the navigation picture, so nothing hides behind the cut-out.
- iPhone on its side, navigation picture: before, it was cut short by the pill and the three buttons under it. Now the left panel holds only the navigation picture, which starts at the very top and uses the whole height of the panel (a low battery line or the note on what a key did, when shown, still appear above it): about 54 points taller than with the heading above it, so even more page groups show without scrolling.
- iPhone on its side, heading: the line that says where you are, for example "AMS Deck · Home" (page group · page). Before (0.10 to 0.15) it stood top left in the left panel (section 34) above the navigation picture, in up to two lines, with the connection dot in front of it. Now it stands in one line in the middle above the keys, with the connection dot right in front of it, in the free room that was already there above the keys, so the keys keep their size and place. The iPad is unchanged.
- Unchanged: the iPad on its side (buttons at the bottom left, section 43), and the iPad and iPhone upright (gear and music at the top right, lock beside the dot).
- Not proven yet: on a real iPad and a real iPhone held on its side.

## 46. Timer key (Mac 0.10)
- `ActionType.timer`; `target` = the minutes as text. Offered in Set up keys: 1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60 (`TimerKeys.choices`). A new key starts on "5". Anything odd reads as 5; the value is kept between 1 and 600 (`TimerKeys.minutes`).
- A press (`TimerKeys.pressed`): a finished timer ("Done") is put away; a running one stops; an idle one starts. Two keys with the same minutes are the same timer (the state is kept by the minutes).
- Until 0.15 the key counted down second by second as a clock, "4:59", from an hour "1:05:00" (`TimerKeys.clock`). Since 0.16 it shows whole minutes, see section 102. A key without a title shows "5 min" (its minutes). Colour: amber (the kind of typed text). Drawing: `app-timer`.
- When the time is up (`TimerKeys.tick`) the Mac plays a sound once (until 0.15: twice, 1.2 s apart; section 102), once per finished timer, and the key says "Done" for 60 seconds (`TimerKeys.doneStays`) or until pressed.
- The countdown shows on the box, on the keys on screen and on the iPhone and iPad (the Mac draws it). A timer is not saved: it is forgotten when Deck Mate quits.

## 47. Switch key (Mac 0.10)
- `ActionType.toggle`; `target` is "dark", "mute" or "own:<a name of its own>" (`SwitchKeys`). In Set up keys: "Switch (on or off)" with "Dark mode", "Mute the sound" and "Two things in turn". A new key starts on "Dark mode".
- Dark mode switches the Mac between light and dark. The first time, macOS asks once whether Deck Mate may control "System Events"; the user chooses Allow. Mute switches the sound off and on. Both follow the Mac when changed elsewhere (mute is read about every two seconds).
- "Two things in turn": the key holds two steps in `steps`: the first runs when the switch goes on, the second when it goes off (`SwitchKeys.step(of:isOn:)`; a step of kind "nothing" does nothing). The key remembers which state it is in, also after a restart. A new switch of this kind gets its own name (`SwitchKeys.newOwn()`).
- Look: a small switch mark in the top-left corner, filled when on, an outline when off. Without a title the key says "Dark" or "Light", "Muted" or "Sound on", "On" or "Off" (`SwitchKeys.words`). Colour: purple. Drawing: a moon for dark mode, the mute drawing for mute.

## 48. Run an Apple Shortcut (Mac 0.10)
- `ActionType.appleShortcut`; `target` = the name of a Shortcut of the Shortcuts app. In Set up keys: "Run an Apple Shortcut" with a list ("Pick a Shortcut…") of the Shortcuts on this Mac, or the name typed. A press runs it. Colour: purple.
- A key with no Shortcut picked is broken: the red corner and the reason "No Shortcut picked" (section 20, broken keys).
- Can also be a step of "Several things in a row", a switch of his own and an entry of a list (section 49).

## 49. List to pick from (Mac 0.10)
- `ActionType.list`; the entries are the key's `steps`. Each entry is a `DeckAction` with its own `name` (new field `DeckAction.name`; empty = made from what it does). An entry can be: open an app, open a link or a file, Raycast, keyboard shortcut, type text, music and sound, or run an Apple Shortcut.
- A press opens a small panel at the mouse pointer (the same way as the copied-text list, section 41). A click on an entry runs it. A click elsewhere, a second press of the key or 10 seconds puts the panel away.
- Pressed from the iPhone, iPad or the box, the panel also opens on the Mac (the choice is made with the mouse).
- The key takes the colour of its first entry.

## 50. Open app keys (Mac 0.10)
- `ActionType.running`; `target` "1" to "15" (`RunningApps.number`; anything odd reads as 1). The key stands for the app in that place of the list of apps open now.
- The list (`RunningApps.order(was:now:)`): apps keep their place while they stay open; a newly opened app goes to the end; an app that quit leaves a gap that closes. The key shows that app's own icon and name; a press brings the app forward (`RunningApps.app(number:in:)`). With fewer apps open the key says "No app". Colour: blue (an app key).
- New button in Set up keys, under the page's buttons: "Add an “Open apps” folder". It puts a folder key on the first empty place of the page (`DeckPage.firstFreePlace`) and a new page "Open apps" holding Back at place 1 and "Open app" 1 to 14 (`RunningApps.folder(parent:)`, 14 keys: `RunningApps.folderKeys`). When all 15 places are taken it says so and changes nothing.

## 51. Microphone light (Mac 0.10)
- `ActionType.micLight`. It shows whether any app is listening to the Mac's microphone now, read about every two seconds.
- In use: a red key (Raycast red) with the `microphone` drawing and the words "Mic in use". Free: a grey-blue key (the moving-around colour) with the `microphoneoff` drawing and "Mic free".
- A press does nothing. It only looks and never changes the microphone.
- Two new drawings from the AMS icon library, `microphone.svg` and `microphoneoff.svg`: 254 hand-drawn icons in all (252 before).
- It is not counted in the key use (section 54).

## 52. The Wait step (Mac 0.10)
- `ActionType.wait`, only as a step of "Several things in a row" (it is not offered as a key of its own). `target` = the seconds. Offered: half a second, 1, 2, 3, 5 or 10 (`StepTiming.waits`); the value is kept between 0.5 and 60 seconds, anything odd reads as 1 (`StepTiming.seconds`).
- Steps still run 0.33 seconds apart (`StepTiming.pause`). A Wait does nothing itself: it pushes everything after it back by its seconds (`StepTiming.starts`).
- A chain key shows the kind of its first step that is not "nothing" and not a Wait.
- Timer, Switch and Run an Apple Shortcut can also be steps; the same list of steps is used by "Several things in a row" and "Two things in turn".
- "Several things in a row" itself is not new: it has been there since 0.1 (Martin's "chain key"). Only the Wait step is new.

## 53. Find a key (Mac 0.10)
- On the keys on screen: a magnifier in the top line, or Space or / while the keys have the keyboard (right after Control-Option-D). While searching, letters go to the search and not to the keys' places.
- Typing a few letters lists up to six keys (`KeyFinder.hits`, limit 6) from all page groups and pages whose title, page name or page group name holds every typed word (not case-sensitive). Titles that start with the first word come first, then the rest, each group in the order of the pages. An app key without a title is searched by its app's name. Each hit shows its place, "Page group · Page".
- Up and down arrows choose; Return or a click runs the key and shows its page; Delete takes a letter away; Escape leaves the search (Escape again hides the keys).
- Keys that only move around (Back, next page, previous page) and empty places are not listed.

## 54. Key use (Mac 0.10)
- Settings has a new part "Key use" (left list). Each press of a key that does something on the Mac is counted (`KeyUse.record`): from the box, the keys on screen, the keyboard, the iPhone and the iPad. For each key (by its id) the number and the time of the last press are kept; nothing else (no words, no texts).
- Not counted: folders, Back, next and previous page, switch page group, empty keys and the microphone light.
- It shows since which day it has counted ("Counted since <day>", `KeyUse.since`), "Pressed most" (the five most pressed, most first, with their numbers; `KeyUse.most`) and "Not pressed in the last 30 days" (`KeyUse.quiet`, 30 = `KeyUse.quietDays`). In the first 30 days the second list says "Not pressed since <day>". Each key is written "Page group · Page · “Title”" (a key without a title as "key <place>"); favourites as "Favourites · “Title”".
- It is a file "use.json" beside the keys file in Application Support, on this Mac only. It is not part of the weekly iCloud copy (section 40) nor of the safety copies. An old keys file without the new fields still reads (tested).

## 55. Ready-made page groups (Mac 0.10)
- In Set up keys, the + beside "Page groups" opens a small list: "Empty page group" (as before) and four ready-made ones: Finder, Safari, Notion, Fusion (`Templates.all`, code in `Core/Sources/DeckMateCore/Templates.swift`). Each is one page "Page 1" of keyboard-shortcut keys (kind "Keyboard shortcut"), in the order of the places 1, 2, 3 and so on. The shortcuts are for the Mac versions with their standard settings and an ANSI keyboard (`KeyCombo.ansi`).
- Finder (14 keys): New window, New folder, New tab, Back, Forward, Up, Get info, Quick Look, Go to folder, Hidden files, Duplicate, Find, Downloads, Home.
- Safari (14): New tab, Close tab, Reopen tab, Back, Forward, Reload, Address bar, Find, Bookmark, Private window, Reader, Sidebar, Tab overview, Next tab.
- Notion (11): New page, Search, Back, Forward, Sidebar, New tab, Close tab, Find, New window, Parent page, Dark mode.
- Fusion (14): Line, Rectangle, Circle, Dimension, Trim, Offset, Project, Extrude, Press pull, Fillet, Move, Hole, Joint, Measure.
- The new page group belongs to the app (Finder `com.apple.finder`, Safari `com.apple.Safari`, Notion `notion.id`, Fusion `com.autodesk.fusion360`) so it shows by itself when that app is in front, unless another page group already belongs to that app. Then it belongs to no app and shows only when picked. His page group for Notion already has the app, so the ready-made Notion belongs to no app.
- If a page group of that name exists, the new one is named "<name> (ready-made)".
- Nothing existing is changed. Undo (30 steps) takes it back.

## 56. Keys that show something at a glance (Mac 0.11)
- Five of the six new kinds (Next event, Weather, Due today, Album cover, Body Battery) show a value. Rules in `Core/Sources/DeckMateCore/GlanceKinds.swift`: `Glance` (`big` = the large words, `words` = the small words), `GlanceKeys`, `EventKeys`, `WeatherKeys`, `DueKeys`, `BatteryKeys`, `CoverKeys`, `DeskKeys`.
- New `ActionType` cases: `nextEvent`, `weather`, `dueToday`, `cover`, `bodyBattery`, `desk`. Kinds of key: 29 (23 before).
- Look: the value stands on the key in LARGE white words where the drawing normally is, with small words under it; a title the user gave replaces the small words. Until a value is there the key shows its drawing.
- How a resolved key carries it: the key's `icon` as it shows now is "text:<large words>" (`GlanceKeys.textPrefix`, `bigWords(_:)`) or "cover:<track>" (`GlanceKeys.coverPrefix`, `coverTrack(_:)`). These are never saved; they are made when the keys are resolved from `LiveKeys`.
- `LiveKeys` (Live.swift) gained `glances` (by name: `GlanceKeys.event`, `due`, `battery`, `weather(<town>)`), `battery`, `cover` and `coverReady`.
- `Deck.allActions` lists every action of the setup (keys, long presses, favourites, the steps inside them); `Deck.weatherTowns` lists the towns of the weather keys, each once.
- Mac side in `App/Sources/Glances.swift`. Each watcher runs only while a key of its kind exists in the setup (found with `Deck.allActions`). The keys show on the box, on screen keys and on the iPhone and iPad (the Mac draws them).

## 57. Next event key (Mac 0.11)
- `ActionType.nextEvent`; `target` = the bundle id of the app a press opens; empty = Calendar (`EventKeys.calendarApp`, `com.apple.iCal`). In Set up keys: "Choose app…" (for example Fantastical). Colour: blue. Drawing: calendar.
- Source: EventKit, all calendars. Looks `EventKeys.daysAhead` = 7 days ahead. `EventKeys.next` picks the event that starts first among those with a time that have not ended; all-day events are left out; an event going on counts until it ends.
- Large words (`EventKeys.glance`): "Now" while it goes on; "<n> min" in the last hour before the start (rounded up); the time "14:30" later today; the weekday ("Sun" to "Sat") on another day, with the time before the title in the small words ("09:00 Dentist"). Small words: the title ("Event" when empty). No event: a dash and "No events".
- Access: the first press makes macOS ask once for calendar access (`NSCalendarsFullAccessUsageDescription`, "Allow Full Access"). Until then "Press to allow" (`EventKeys.askWords`); if refused "Calendar not allowed" (`refusedWords`; fix in System Settings > Privacy & Security > Calendars). Read only: it never writes an event.
- Follows calendar changes at once (the store's change notice) and reads again every minute.

## 58. Weather key (Mac 0.11)
- `ActionType.weather`; `target` = the town as typed (a text field in Set up keys). Colour: teal. Drawing: sun. A press opens the Mac's Weather (`WeatherKeys.weatherApp`, `com.apple.weather`).
- Large words: the temperature in whole degrees Celsius (`WeatherKeys.degrees`, "3°", "-4°"). Small words: the sky from the WMO code (`WeatherKeys.sky`): 0 Clear, 1 Mostly clear, 2 Partly cloudy, 3 Cloudy, 45 and 48 Fog, 51 to 57 Drizzle, 61 to 67 Rain, 71 to 77 Snow, 80 to 82 Showers, 85 and 86 Snow showers, 95 to 99 Thunder, anything else "Weather". No town: "Set a town" (`noTownWords`).
- Several keys with different towns work: `GlanceKeys.weather(_:)` names a glance by the lower-case town (`WeatherKeys.name`). A key's own title (for instance the town) replaces the sky.
- Service: Open-Meteo, no account, no key. Step 1, once per town: `https://geocoding-api.open-meteo.com/v1/search?name=<town>&count=1` (`searchURL`, `place(fromSearch:)`); only the town's name goes out. The place is kept in UserDefaults `weatherPlaces` (town to "lat,lon", `Place.text`). Step 2: `https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=temperature_2m,weather_code` (`weatherURL`, `now(fromWeather:)`); only the place goes out. Asked again every `everyMinutes` = 20. The Mac asks nothing.
- Long press (0.11.1): `ActionType.weatherTown`, `target` = the weather key's id; never offered in the pickers. `DeckKey.action(long:)` returns it for a weather key without `held`. `DeckKey.actsOnHold` (= `hasHeld` or a weather key) decides whether a key waits for the release, so a weather key now acts on release (a short press opens Weather then). No white long-press dot for it (the dot still means `held`).
- Rules in `Core/Sources/DeckMateCore/GlanceKinds.swift`: `Deck.town(ofKey:)`, `Deck.setTown(_:forKey:)` (an undo step for Set up keys), `WeatherKeys.remembered(_:adding:)` (newest first, each town once whatever its capitals, at most 6). Towns used are kept in UserDefaults `weatherTownsUsed`.
- The window is an alert with a combo box (`AppDelegate.askTown`), titled "Weather key": a field for the town with the remembered towns as its list; Save (Return), Cancel (Escape). It always opens on the Mac, whether the press came from the box, the keys on screen (mouse held) or the iPhone and iPad (note there: "Type the town on the Mac"). The new weather shows within a few seconds.

## 59. Due today key (Mac 0.11; PARAGON since 0.14)
- `ActionType.dueToday`. Colour: purple (red while something is overdue). Drawing: tick. Since 0.14 it counts PARAGON, not OmniFocus (before: OmniFocus tasks, only while OmniFocus was open, via AppleScript, `DueKeys`, refreshed every 120 s, press opened `omnifocus:///forecast`, Automation asked once).
- Large words: the number of PARAGON tasks due today (`ParagonKeys`, from the widget file of section 79). Small words: "Due today", or when some are overdue "2 overdue" and the key is red.
- A press opens `amspara:///list/today`. Existing Due today keys change by themselves; nothing to set up. The title in the picker is "Due today (PARAGON)".
- Source and limits: as section 79 (file read every 60 seconds; "–" and "Open PARAGON" when the file is from an earlier day; "No PARAGON" without PARAGON). Counts only; never changes a task. The Mac asks nothing.

## 60. Album cover key (Mac 0.11)
- `ActionType.cover`. Colour: green. Drawing: music note until a cover is there. A press = play or pause (the media key; needs Accessibility, section 11).
- Source: Spotify's distributed notice `com.spotify.client.PlaybackStateChanged`, read at each change; `CoverKeys.track` takes the track name from "spotify:track:<name>" (ASCII letters and digits, at most 40; anything else, such as a podcast episode, an advert or a local file, is nil). Spotify only says what plays when something changes, so the cover shows from the next song change after Deck Mate starts; before that the key says "Nothing playing" (`idleWords`).
- Picture: `https://open.spotify.com/oembed?url=https://open.spotify.com/track/<name>` (`lookupURL`); `pictureURL(fromLookup:)` takes `thumbnail_url`, https only. Only the track's name goes out; the Mac asks nothing. Covers are kept in memory only.
- Look: the key's `icon` is "cover:<track>" (section 56); the cover fills the whole key with the song's name on a dark band at the bottom. `LiveKeys.cover` holds the song, `coverReady` the tracks whose picture is in memory. A non-track shows the song's name with the music note.

## 61. Body Battery key (Mac 0.11)
- `ActionType.bodyBattery`. Large words: the latest Body Battery (0 to 100); small words "Body Battery". Drawing: battery.
- Source: the AMS Garmin Bridge Board on this Mac, `http://127.0.0.1:7788/api/board` (`BatteryKeys.boardData`), field `today.bodyBattery.latest` (`BatteryKeys.level(fromBoard:)`; a number outside 0 to 100 is nothing). Info.plist `NSAllowsLocalNetworking` allows the plain http call. Again every `everyMinutes` = 10. Nothing leaves the Mac; the Mac asks nothing.
- Colour (`BatteryKeys.kind`): green (media) from 50, teal (web) from 25 to 49, amber (text) below 25 (until 0.14: amber from 25 to 49, red below 25); grey-blue (move) while there is no number. If the board does not answer twice in a row, since 0.15 the key shows "–" and "Board off" (section 90; until 0.14 it showed its drawing).
- A press opens `http://127.0.0.1:7788/` in the browser. `LiveKeys.battery` holds the number.

## 62. Desk key (Mac 0.11)
- `ActionType.desk`; the desk is the key's `steps`, each a `DeckAction` of type `app` with `target` = the app and `name` = "x,y,width,height" (`DeskKeys.step`, `spot(_:)`, `spots(of:)`). x and y are the window's top left corner in the Mac's points (0, 0 = top left of the main screen). Colour: blue. Drawing: window. Default title "Desk".
- Set up keys: the button "Take the desk as it is now" (`DeskKeys.capture`): from the windows on screen, front to back, the front window of each app, up to `most` = 8 apps; windows smaller than `smallest` = 200 × 150 and Deck Mate's own windows are left out. The list shows each app with its size ("Safari · 1200 × 800", `Spot.size`) and a button to take one out.
- A press opens every app of the desk and puts each one's front window back in its place and size through Accessibility, waiting up to about 8 seconds for an app that is still opening. Needs Accessibility (section 11); the Mac asks at the first press if it was never given.
- Also works as a long press and as a step of "Several things in a row".
- Key check: an app that is no longer on this Mac makes the desk broken, "An app of the desk is not on this Mac"; a desk with no steps says "No windows taken yet".

## 63. Keys that show more at a glance (Mac 0.12)
- Five new kinds, eleven things to show: Garmin number (five numbers; seven since 0.15, section 90), Mac at a glance (three), World clock, Sunrise and sunset, Free until. Rules in `Core/Sources/DeckMateCore/GlanceMore.swift`: `GarminKeys`, `MacNowKeys`, `ClockKeys`, `SunKeys`, `EventKeys.freeGlance` and `EventKeys.length`. Mac side in `App/Sources/Glances.swift`.
- New `ActionType` cases: `garmin`, `macNow`, `worldClock`, `sunTimes`, `freeUntil`. Kinds of key: 34 (29 before).
- Look as in section 56: the value in large white words, small words under it (a title replaces them), the drawing until a value is there.
- New: a glance can change its colour. `Glance.tone` is a `KeyKind` (green `media`, teal `web`, amber `text`, red `raycast`, grey-blue `move`; none = the kind's own colour). On a key as it shows now, `action.name` carries the tone and `DeckAction.kind` reads it.
- Glance names in `LiveKeys.glances`: "garmin:<number>" (`GlanceKeys.garmin`), "mac:<number>" (`GlanceKeys.mac`), "clock:<town>" (`GlanceKeys.clock`), "sun:<town>" (`GlanceKeys.sun`), "free" (`GlanceKeys.free`).
- Helpers: `ActionType.hasTown` (weather, world clock, sunrise and sunset), `Deck.towns(of:)` (the towns of the keys of one kind, each once), `Deck.allTowns`, `Deck.macNumbers` (the Mac numbers the setup shows).
- Each watcher runs only while a key of its kind exists in the setup. The keys show on the box, on screen keys and on the iPhone and iPad (the Mac draws them), so the iPhone and iPad need no update.

## 64. Garmin number key (Mac 0.12)
- `ActionType.garmin`; `target` = "steps", "sleep", "pulse", "stress" or "workouts" (`GarminKeys.Number`; anything else counts as steps). Colour: teal unless the tone says otherwise. Drawings: shoes, sleep, heart, pulse, run. A press opens `http://127.0.0.1:7788/`.
- Source: the AMS Garmin Bridge Board, as for Body Battery (section 61). One fetch feeds Body Battery and all the numbers (five; seven since 0.15) (`GarminKeys.glances(fromBoard:)`), asked every 10 minutes. Nothing leaves the Mac; the Mac asks nothing. A number the board does not have is left out, and the key shows its drawing.
- Steps today: `today.steps` as "8 412" (`count`, a space between thousands); small words "Steps today"; green once `today.stepGoal` is reached.
- Sleep last night: `sleep.seconds` as "7:24" (`hours(seconds:)`), small words Garmin's own word (`sleep.qualifier`, "Good"); when `sleep.recorded` is not true: a dash and "No sleep recorded".
- Resting pulse: `today.restingHr`, small words "Resting pulse". Against the latest of `restingTrend.avg7` (the 7-day average): from 5 beats over it the small words say "+<n> over usual" with no tone (until 0.14: amber); from 8 over the tone is amber (until 0.14: red).
- Stress today: `today.stressAvg`; the words and tone from Garmin's own steps (`GarminKeys.stress`): to 25 "Resting" (green), to 50 "Low stress" (teal), to 75 "Medium stress" (teal; until 0.14 amber), above "High stress" (amber; until 0.14 red).
- Workouts, 7 days: `recentWorkouts.last7.count`; small words "7 days · <h> h" (whole hours of `seconds`), or "Workouts, 7 days" when under an hour.

## 65. Mac at a glance key (Mac 0.12)
- `ActionType.macNow`; `target` = "battery", "space" or "busy" (`MacNowKeys.Number`). Colour: grey-blue unless the tone says otherwise. Drawings: battery, folder, multi.
- Looked at every 5 seconds, only while such a key exists (`Deck.macNumbers`). The Mac asks nothing; nothing leaves it.
- Mac battery (`MacNowKeys.battery`): from the IOKit power sources; "73%", small words "Mac battery" or "Charging"; green from 40 %, amber from 20 %, red below; no battery: "No battery". A press opens `x-apple.systempreferences:com.apple.Battery-Settings.extension`.
- Free space (`MacNowKeys.space`, `room`): the start-up disk's "available for important usage"; "212 GB", "8.4 GB" under ten, "1.2 TB" from a thousand; amber under 25 GB or a tenth free, red under 10 GB or a twentieth free. A press opens `x-apple.systempreferences:com.apple.settings.Storage`.
- Mac busy light (`MacNowKeys.load`, `busy`): the share of the processors at work between two readings of their tick counters, shown in steps of 5 %. Small words "Mac calm"; from 60 % "Mac busy" (amber); from 85 % "Mac very busy" (red). A press opens Activity Monitor (`com.apple.ActivityMonitor`).

## 66. World clock key (Mac 0.12)
- `ActionType.worldClock`; `target` = the town as typed. Colour: grey-blue. Drawing: globe. A press opens the Mac's Clock (`ClockKeys.clockApp`, `com.apple.clock`).
- Large words: the time in the town's zone ("14:05"). Small words: the town (the key's own words); "tomorrow" or "yesterday" when the day there differs from the day here (`ClockKeys.glance`). No town: "Set a town".
- Service: Open-Meteo, step 1 once per town (`ClockKeys.zone(fromSearch:)`, the geocoding search of section 58 gives `timezone`). Only the town's name goes out. Town to place stays in UserDefaults `weatherPlaces`, town to time zone in `townZones`. After that nothing goes out.
- A one-minute timer redraws the clock, sunrise and sunset and free-until keys.

## 67. Sunrise and sunset key (Mac 0.12)
- `ActionType.sunTimes`; `target` = the town as typed. Colour: amber. Drawing: sunrise. A press opens the Mac's Weather.
- Source: Open-Meteo, `https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&daily=sunrise,sunset&timezone=auto&forecast_days=2` (`SunKeys.url`, `times(fromAnswer:)`). Only the place goes out; the town's name goes out once to find the place (section 58). Asked again every `SunKeys.everyHours` = 6.
- Shows whichever of today's and tomorrow's sunrise and sunset comes next (`SunKeys.glance`), on the town's own clock (`utc_offset_seconds`): "16:42" with "Sunset" or "Sunrise" under it.

## 68. Free until key (Mac 0.12)
- `ActionType.freeUntil`; `target` = the bundle id of the app a press opens; empty = Calendar (as Next event, section 57). Source: EventKit, as Next event; the same calendar access (asked once at the first press of either; "Press to allow" until then, "Calendar not allowed" if refused). Read only.
- `EventKeys.freeGlance`: an event going on: red, "Busy" with "until 15:00"; else before the next event of today that has a time: green, the time free ("1 h 20" or "45 min", `EventKeys.length`) with "Free until 14:30"; else green "Free" with "Rest of the day". All-day events are left out.
- Follows calendar changes at once; the one-minute timer redraws it.

## 69. Long press for the town (Mac 0.12)
- The long press of section 58 now works on World clock and Sunrise and sunset keys too (`ActionType.hasTown`). The window is called "Town for this key" (it was "Weather key" in 0.11.1) and offers the towns used on any of these kinds (`Deck.allTowns`; kept in UserDefaults `weatherTownsUsed`, at most 6).

## 70. Due today key replaced later
- Done in 0.14: the "Due today" key (section 59) counts PARAGON tasks instead of OmniFocus, because his tasks are in PARAGON.

## 71. On the Mac key (Mac 0.13)
- `ActionType.macDo`; `target` = a `MacDo` raw name: "lock", "desktop", "quitAll", "emptyBin", "ejectAll", "pastePlain" (`MacDoKeys.what`; anything odd counts as "desktop", the harmless one). Colour: purple, like shortcut keys. Titles in the list (`MacDo.title`): Lock the Mac, Show the desktop, Quit all apps, Empty the bin, Eject all disks, Paste as plain text. Words on a key without a title (`MacDo.short`): Lock, Desktop, Quit all, Empty bin, Eject, Paste plain. Drawings: app-lock, laptop, control-closeCircle, app-bin, deck-eject, deck-clipboard.
- Lock the Mac: locks the screen at once; the password or Touch ID is needed to come back.
- Show the desktop: moves all windows aside; a second press brings them back.
- Quit all apps: quits every open app except the Finder (`QuitKeys.finder`, `com.apple.finder`), AMS Deck Mate itself and the apps that stay open (`QuitKeys.spared`: the key's `steps`, each of type `app`; in Set up keys the list "Stays open" with the button "Add app…" and a remove button on each). `QuitKeys.toQuit` leaves out those, empty names and doubles. Question first: "Quit 6 apps?" (one app: "Quit <name>?") with Quit and Cancel; the words list the apps (`Listing.words`: "A", "A and B", "A, B and C", at most 6 names then "and N more") and say they will quit, that an app with unsaved work asks you itself, and "Stays open: …". Nothing to quit: no question. An app with unsaved work asks for itself.
- Empty the bin: question first (`BinKeys.question`): "Empty the bin?" with "12 things will be gone for good. This cannot be undone." ("1 thing" for one) with Empty and Cancel. If the Finder is set to warn before emptying, the Finder asks once more after that (Deck Mate never switches the Finder's own warning off); with "Ask first" off only the Finder's question shows. With both off the bin is emptied at once. An empty bin: the key says so and does nothing. The first press makes the Mac ask once whether AMS Deck Mate may control the Finder (section 11); the answer is Allow.
- Eject all disks: ejects every plugged-in disk, card, stick and disk picture (`EjectKeys.toEject`: local, under /Volumes, and ejectable or not built in); never the Mac's own disk, never a share on another computer. Question first (`EjectKeys.question`): "Eject 2 disks?" (one: "Eject <name>?"), with the names, Eject and Cancel. A disk still in use stays and the key names it (`EjectKeys.stayed`: "<names> is still in use and could not be ejected. Close what uses it, then press the key again."). No disk plugged in: the key says so.
- Paste as plain text: pastes the copied text without its font, size and colour. Needs Accessibility (section 11).
- "Ask first": for quitAll, emptyBin and ejectAll (`MacDo.canAsk`) the key asks on the Mac before it acts. `quiet` = without asking; the tick "Ask first" is on at first (`quiet` false) and can be taken off. `MacDoKeys.asks` says whether a key asks.
- Pressed from the iPhone or iPad, the question opens on the Mac. In the question, Return and Escape both cancel and the action needs a click (until 0.15 Return did it; section 115). The iPhone's note on what ran (`MacDoKeys.done`): "Asks on the Mac: quit all apps", or "Locked the Mac", "Showed the desktop", "Quit all apps", "Emptied the bin", "Ejected the disks", "Pasted as plain text".
- Also works as a long press and as a step of "Several things in a row".

## 72. Join the meeting key (Mac 0.13)
- `ActionType.joinMeeting`; no target. Colour: blue. Source: EventKit, the same calendar access as Next event (section 57); read only.
- `MeetingKeys.pick`: of the events that have a video link, the one that starts within ten minutes (`soon` = 600 s), else the one going on (the one that began last), else the next one within a day (`ahead` = 86,400 s). Events already over are left out.
- Links (`MeetingKeys.link`): the first link in the event's link, place and notes, in that order, whose host is Zoom (zoom.us, zoom.com), Microsoft Teams (teams.microsoft.com, teams.live.com), Google Meet (meet.google.com), Webex (webex.com), FaceTime (facetime.apple.com), Whereby (whereby.com), Jitsi (meet.jit.si), GoTo (gotomeeting.com, gotomeet.me, goto.com), and also BlueJeans (bluejeans.com) and Chime (chime.aws); a host also counts with a sub-domain. Closing marks and points after a link are cut off. No link found: the key says so.

## 73. Spotify playlist key (Mac 0.13)
- `ActionType.playlist`; `target` = the pasted link. Colour: green. In Set up keys: a field for the link; in Spotify, Share > Copy link. The note under it says what it is: playlist, album, artist, song, podcast or podcast episode (`PlaylistKeys.kind`).
- `PlaylistKeys.uri`: a link of open.spotify.com (also with a language part, "intl-de/album/ID", or "user/x/playlist/ID") or Spotify's own short form becomes `spotify:<kind>:<id>` with kind playlist, album, artist, track, show or episode and an id of letters and digits. A press plays that in Spotify. The first press makes the Mac ask once whether AMS Deck Mate may control Spotify (section 11); the answer is Allow.
- Not a proper Spotify link: the key is broken (red corner, the reason in Set up keys).

## 74. Search for the copied text key (Mac 0.13)
- `ActionType.searchCopied`; `target` = the search site (`SearchKeys.Engine`): "google" (the start choice, also for anything odd), "duckduckgo", "bing", "wikipedia", "youtube". Colour: teal. Opens the browser at `SearchKeys.address`: https://www.google.com/search?q=, https://duckduckgo.com/?q=, https://www.bing.com/search?q=, https://en.wikipedia.org/w/index.php?search=, https://www.youtube.com/results?search_query=, followed by the text, percent-coded.
- The text is the last copied text, with white space made into single spaces. A copied web address (one word starting with http:// or https://) opens as it is. Of a long text only the first 300 letters are searched (`SearchKeys.longest`). Nothing copied: nothing happens. The text goes only to the site picked.

## 75. Counter key (Mac 0.13)
- `ActionType.counter`; `target` = the key's own id (`CounterKeys.newID`, a new id for each new counter key, so two keys never share a number). Colour: amber. The number is the large word on the key.
- A press counts one more (`CounterKeys.pressed`); it stops at 99,999 (`CounterKeys.most`). A long press runs `ActionType.zero` (`ActionType.countsUp`: counter or stopwatch) and sets it back to 0 (`CounterKeys.reset`). `zero` is never offered in a picker. A key's own long press (`held`) wins over it.
- Kept in UserDefaults `counters` (a name-to-number list), so the numbers stay after a restart of the Mac.

## 76. Stopwatch key (Mac 0.13)
- `ActionType.stopwatch`; `target` = the key's own id (`StopwatchKeys.newID`). Colour: amber. The key shows the time running as the large word.
- A press starts it; another press pauses it and keeps its time; the next press goes on (`StopwatchKeys.pressed`). A long press runs `zero` and sets it back to 0 (`StopwatchKeys.reset`). `StopwatchKeys.State` holds `banked` (seconds gathered before the last pause, by stopwatch) and `since` (the moment each running one began); `seconds` gives the whole seconds shown now.
- Kept in UserDefaults `stopwatches`. It keeps running when AMS Deck Mate restarts, because the start moment is kept.

## 77. Switch key, "Keep the Mac awake" (Mac 0.13)
- A fourth choice of the Switch key (section 47): `ActionType.toggle` with `target` "awake". While it is on, the Mac and its screen do not go to sleep by themselves. Another press switches it off. It is off again after AMS Deck Mate quits or the Mac restarts. Without a title the key says "Awake" or "May sleep". Colour: purple, with the switch mark of section 47.

## 78. Drawings and sample keys (Mac 0.13)
- Two new drawings to pick for a key: eject (`deck-eject.svg`) and video camera (`deck-video.svg`). 256 drawings to pick from (254 before).
- The made-up sample keys got a page with the new keys.

## 79. PARAGON keys (Mac 0.14)
- `ActionType.paragon`; `target` = "inbox", "next", "copiedTask" or "note" (`ParagonKeys.what`). Menu titles: Inbox, Next task, Task from the copied text, Quick note. Colour: purple, like shortcut keys.
- Inbox: large words = the number of lines waiting in PARAGON's Inbox, small words "Inbox". A press opens `amspara:///list/inbox`.
- Next task: the first task on PARAGON's list (the one its widget shows first): large words = its due words ("today", "2 days over"; none = the drawing stays), small words = the task's title; red when overdue. The Inbox key is amber while something waits. A press opens the task's note in PARAGON. Nothing on the list: "Nothing next".
- Task from the copied text: a press sends the last copied text to PARAGON's capture link `amspara://capture?text=<text>&target=inbox`, as a task. PARAGON does not come to the front. Nothing copied, or not text: the Mac beeps and nothing is saved.
- Quick note: a press opens a small window on the Mac, "Note for PARAGON", one text field, Cancel and Save (Return saves, Escape cancels). Save sends `amspara://capture?text=<text>&target=inbox&note=1`. PARAGON does not come to the front. From the iPhone or iPad the window opens on the Mac.
- Source: PARAGON on the Mac writes a small file for its own widget at each reload of its notes: `~/Library/Group Containers/D24ENP83QQ.group.com.schabbauer.amspara/widget-snapshot.json`. Deck Mate only reads it, every 60 seconds. It never opens the notes folder and writes nothing there.
- Limits: the numbers are as fresh as PARAGON's last reload on this Mac. A file from an earlier day: the key shows "–" and "Open PARAGON"; a press opens PARAGON, which writes the file anew. PARAGON not on the Mac: "No PARAGON". No change in PARAGON was needed. The Mac asks nothing new. Rules: `Core/Sources/DeckMateCore/ParagonFocus.swift` (`ParagonKeys`).

## 80. Focus rounds key (Mac 0.14)
- `ActionType.focus`; colour amber while idle. In Set up keys a menu with PomoTimer's five ready-made plans: Classic Pomodoro (2 + 3 + 25 + 5 + 25 + 5 min), Four Pomodoros, Deep Work 50/10, Short Burst, Single Pomodoro; then the user's own templates after the button "Read my templates from a PomoTimer backup file…" (the backup file PomoTimer saves; read once, kept in UserDefaults `pomoPlans`; press the button again after changing templates in PomoTimer).
- The plan rides in the key's `steps`: each step has `target` = "<kind>:<seconds>" and `name` = its label (`FocusKeys`, file `ParagonFocus.swift`).
- A press opens AMS PomoTimer in the browser and starts the template with PomoTimer's own start link `?action=start&template=<name>`. The key counts along: the step's name ("Pomodoro", "Pause") and the minutes and seconds left. Purple during focus steps (until 0.14: red; section 89), green during pauses and long breaks, amber during start-up, preparation and cool-down. At the end "Done" for 60 seconds.
- While it runs a press brings PomoTimer to the front; a long press stops the count on the key (not PomoTimer). One focus run at a time. The run is kept in UserDefaults `focusRun`, so it goes on after Deck Mate restarts.
- Limits: the key counts by itself from the moment of the press; a pause or skip in PomoTimer is not known to it; a template set to wait between steps in PomoTimer runs ahead on the key. The session lands in PomoTimer's history as always. No change in PomoTimer was needed.

## 81. Spotify playlist cover (Mac 0.14)
- Before: the Spotify playlist key (section 73) was a green key with headphones. Now, once a link is pasted, the key shows the playlist's (album's, artist's, song's, podcast's) own cover across the whole key.
- The cover is fetched once from Spotify's public look-up (`https://open.spotify.com/oembed?url=<the link>`, the one the Album cover key uses, section 60); only the link is sent; the picture is kept in memory until Deck Mate quits and fetched again at the next start. A key with a picture or drawing the user chose keeps it. No internet: the headphones stay until it works.

## 82. Quit all apps, "Stays open" start list (Mac 0.14)
- Before: the "Stays open" list of Quit all apps (section 71) started empty. Now, when "Quit all apps" is chosen for a key, the list starts filled with the apps open at that moment, without the Finder and Deck Mate (they always stay), and a button "Take the apps open now" fills it again. Remove what should quit. An existing key is not changed by itself.

## 83. Safety copies of the keys file (Mac 0.15)
- Before: after each save the previous `deck.json` went to `Backups`; only the newest 20 were kept, and copies with names of their own took up some of the 20. An hour of editing pushed out yesterday's state.
- Now three sets are kept, and nothing else is pruned: (1) the newest 20 ordinary copies; (2) the last copy of each of the last 30 days; (3) a copy that ordinary saving never pushes out, named "deck kept <date>.json", made just before a page group or a page is deleted, before Elgato's keys are brought over and before an earlier state is put back; the newest 10 of these stay.
- Files with other names ("damaged <date>.json" and the like) are never removed.
- "Bring back an earlier state" lists all of them, newest first.

## 84. Self-repair from iCloud and for a new Mac (Mac 0.15)
- `Store.start()`: if `deck.json` cannot be read and no copy in `Backups` can be read, the newest readable weekly copy in iCloud Drive (section 40) is used (`.recovered`, with its date and time). Before: the iCloud copies were listed but never used for repair.
- No `deck.json` at all (a new Mac): the newest weekly iCloud copy is taken by itself, and the app says so at the start. With no iCloud copy: starter keys as before (`.first`).
- A file that decodes but holds no page group at all counts as damaged and is repaired the same way. Before: it was taken as an empty setup and then saved over.

## 85. Unknown kinds kept, format number 2 (Mac 0.15)
- A key whose `type` this version does not know decodes as an empty key that does nothing, but its original data is kept and written back exactly as read, so a newer Deck Mate finds it again. Before: it became an empty key for good at the next save.
- The file's format number (`version`) is 2 (3 since 0.16, section 113) and is never lowered. A file from a newer format is read, kept as read, and the app says so at the start.

## 86. Outside key presses closed (Mac 0.15)
- Before: the app had a door for checks through which other programs on the Mac could press keys by a message. It is closed. The app as it is used listens to no such message.

## 87. Password copies (Mac 0.15)
- A copy that a password manager marked as secret (the pasteboard's own marker for secret copies, which the "Last copied text" keys already honoured) is not used by "Search for the copied text" (section 74), "Ask AI (copied text)" (section 32) and PARAGON "Task from the copied text" (section 79). Search and task: the Mac beeps and nothing is sent or saved. Ask AI: AI Chat opens with nothing filled in.
- "Paste as plain text" (section 71) still pastes it: a paste stays on the Mac. The "Last copied text" keys (section 36) skipped such copies already.

## 88. Limits for strangers (Mac 0.15)
- A device that is not in `pairedPhones` is asked about once per connection (before: again and again).
- At most 3 such devices are connected at once and at most 2 wait to be asked about. A stranger's line is closed after 30 seconds, unless it is the one being asked about.
- The question window ("wants to use your keys") closes by itself when that device goes away.
- After three "Don't Allow" within 10 minutes nobody new is asked about for a while.
- The Mac reads nothing larger than a few lines of text from a phone.
- Allowed devices always find room: the limits count strangers only.

## 89. Calmer colours (Mac 0.15)
- Red is kept for real trouble. Before / now:
- Focus rounds (section 80): focus steps red / purple; pauses and long breaks green (same); start-up, preparation and cool-down amber (same).
- Body Battery (section 61): from 50 green (same); 25 to 49 amber / teal; below 25 red / amber.
- Stress today (section 64): resting green and low teal (same); medium amber / teal; high red / amber.
- Resting pulse (section 64): from 5 beats over the 7-day usual: the words "+<n> over usual" with amber / no colour; from 8 over: red / amber.
- Unchanged and still red: Mac very busy (from 85 %), Mac battery low (below 20 %), free space low (under 10 GB or a twentieth), PARAGON overdue.

## 90. Garmin board off, old numbers, gym numbers (Mac 0.15)
- Board off: when the board does not answer twice in a row, the Body Battery and Garmin number keys show "–" with the small words "Board off" (before: their plain drawing, and a press opened a browser error). A press then starts the AMS Garmin Bridge Board app, and the keys ask again 8 seconds later. One missed answer keeps the numbers and asks again after a minute (normal rhythm: 10 minutes).
- Old numbers: steps, stress, resting pulse and Body Battery that the watch has not renewed for more than 3 hours show grey-blue (`move`) with the small words "As of 06:29" (the time of the watch's last sync).
- Two new numbers for the Garmin number key (now 7 to choose from, was 5): "Days since the gym" ("today" on a gym day, otherwise the number of days) and "Gym, 7 days" (the number of sessions with the minutes; green when at least one). They come from the gym app's sessions that the board reads. Until the gym app has shared them: "–" and "No gym data yet".

## 91. Declined and cancelled events (Mac 0.15)
- `EKEvent.isOn` (App/Sources/MacActions.swift; false when `status == .canceled`, or when the attendee that is the current user has `participantStatus == .declined`): Next event (section 57), Free until (section 68) and Join the meeting (section 72) leave out events that were cancelled and events the user declined. Before: a declined meeting could show as the next one.

## 92. The list of kinds (Mac 0.15)
- Set up keys: the field "What it does" is a button that opens a list with a search field on top and the 42 kinds under 8 coloured headings: Open, Type and press, Music and sound, Time, At a glance, On the Mac, Moving around, Nothing. Before: one long menu of 42 lines. Since 0.16 there are 45 kinds (`breath` and `bar` under Time, `often` under Open; `KindGroups`).
- Typing filters the list, by the kind's name and by a few other words (for example "countdown" finds Timer). Return takes the first one shown. Escape closes the list.

## 93. Drop it on a key (Mac 0.15)
- In Set up keys, an app, a file or a folder dragged from the Finder, or a web address dragged from the browser, dropped on an EMPTY key makes the key and opens it for editing: an app key with the app's icon and name; a file or folder key named after it; a link key named after the website.
- A key that already does something is never replaced by a drop. Command-Z takes the drop back (one undo step).

## 94. Raycast commands and links (Mac 0.15)
- Settings, new part "Raycast and links". A folder "Raycast" beside the keys file holds one small command file per key that has words and does something (not Back, folders or page keys): `deck-<key id>.sh`. The folder is written again whenever the keys change. Button "Show the folder". Raycast needs the folder once: Settings › Extensions › Script Commands › Add Directories. The commands are listed under "Deck Mate · <page group> › <page>".
- Link forms: `amsdeckmate://press?key=<id or words>&pass=<pass>` (optional `&hold=1` for the long press; since 0.20 optional `&twice=1` for the double press, section 141), `amsdeckmate://show?group=<name>&pass=<pass>`, `amsdeckmate://keys?pass=<pass>` (show or hide the keys on screen).
- Every link needs this Mac's own pass: a random word made on this Mac, kept in UserDefaults `linkPass`. A link without it, or with a wrong one, does nothing.
- A pressed key acts wherever it sits; the keys on screen and the box do not move, except for a "Switch page group" key. Quit all apps, Empty the bin and Eject all disks always ask first, also when "Ask first" is off.
- UserDefaults `linksOff`: switches the whole thing off; the folder is then removed.

## 95. Box wake-up and diary (Mac 0.15)
- After the Mac or its screen wakes, the brightness and all 15 pictures are sent again (before: nothing was re-sent, so a box that went dark could stay dark).
- The box diary also notes the end of the box's serial number, the first picture sent (its size, sent or not) and the first key heard (which place, down or up), and says what to do if no key press shows up. Not yet tried on the real box.

## 96. Link version 8 (Mac 0.15, iPhone and iPad 0.17)
- `PhoneLink.currentVersion` is 8. New messages: `some` (only the keys that look different, so a running timer, stopwatch or focus round sends one small picture a second instead of all fifteen, about 300 KB), `ping` (the device, every 5 seconds) and `pong` (the Mac's answer).
- iPhone and iPad 0.17: when nothing at all arrives for 12 seconds, the app stops saying Connected and looks for the Mac again; the dark "Mac asleep" screen is kept as it was. A tap while it looks says "Looking for your Mac". "Update AMS Deck Mate on your Mac" only shows when the Mac was reached and did not answer two tries in a row; "Ask again" and coming back to the app restart the count.
- Mac 0.15: closes the line of a device it has not heard from for 20 seconds.
- With app 0.16 and Mac 0.15, or app 0.17 and an older Mac, everything works as before. No screen was moved or redesigned.

## 97. PARAGON's file is read in the background (Mac 0.15)
- `GlanceWatch.readParagon` reads `widget-snapshot.json` on its own queue (`paragonQueue`), one read at a time, and hands the result to the main thread. Before: the read ran on the main thread at the start, and the first read by a new build makes macOS ask "would like to access data from other apps"; the whole app stood still (no menu, no keys, no iPhone link) until that question was answered. Now the app works while the question is open, and the PARAGON keys fill in once it is allowed.
- A press of the Inbox or Next task key uses the snapshot already read (`paragonShot`); it never reads the file on the main thread.
- Raycast's commands (section 94) are also written once at the start, not only after the first change to the keys.

## 98. Breathing pacer key (Mac 0.16)
- `ActionType.breath` (`BreathKeys`, `Pacer.swift`); heading Time in `KindGroups`. `target` = "in-out-breaths", for example "4-6-6" (`BreathKeys.target`, `setting`). Rhythms offered (`BreathKeys.rhythms`): 4 in · 6 out (the default `standard`), 4 · 4, 5 · 5, 4 in · 8 out. Breaths (`counts`): 6 (default), 10, 20. Anything odd reads as the standard.
- Idle: the key's drawing and `idleWords` "Breathe". A press starts a round, a second press stops it (`BreathKeys.pressed`). While it runs, a white rounded column fills from the bottom while breathing in and empties while breathing out; icon prefix `bar:` (`barPrefix`, `level`); small words `inWords` "Breathe in" and `outWords` "Breathe out". Colour: green (media). Redrawn once a second.
- After the last breath the key returns to idle: no sound, no "Done", no numbers. The run is kept in memory only. Shows on the box, on screen and on the iPhone and iPad (the Mac draws it). The Mac asks nothing.

## 99. Progress bar key (Mac 0.16)
- `ActionType.bar` (`BarKeys`, `Pacer.swift`); heading Time. `target` = "place/count", for example "2/5" (`BarKeys.target`, `parse`): this key is part 2 of 5. Several bar keys side by side make one bar; each part's share of the whole is `BarKeys.share(place:of:progress:)`.
- What the bar follows (`BarKeys.now`): the whole focus round that runs (purple); else the timer that ends last (amber); else nothing, and the parts are empty (dark, thin outline). A part is redrawn only when its whole percent changes (icon prefix `fill:`, `percent`).
- Set up keys, with a bar key picked: the button "Fill this row with the bar" (`BarKeys.filledRow`): the EMPTY places of that row become bar parts numbered 1…n; a key that is there is never replaced.

## 100. Often used key (Mac 0.16)
- `ActionType.often` (`OftenKeys`); heading Open. `target` "1" to "5" (`number`; the editor says "1 (most)", 2, 3, 4, 5). Shows the picture and words of the key it stands for (`showing`); a press presses the real key and the press is counted for the real key (`counted`). Unfilled: the key's drawing and `notYet` "Not yet".
- Ranking (`OftenKeys.ranked`): keys pressed within the last `KeyUse.quietDays` (30) days, ordered by their total count (`KeyUse` keeps only the total and the last press). Left out: folders, Back, page keys, page group switches, other often used keys and keys that only show something.
- Button "Add an “Often used” folder" (under "Add an “Open apps” folder"): a folder (`OftenKeys.folder`) with Back and five often used keys, opened by a folder key "Often used" on the first free place; a full page says so and changes nothing.

## 101. PARAGON "Now on my plan" (Mac 0.16)
- `ParagonKeys.What.plan` (title "Now on my plan", short title "My plan", drawing `app-calendar`); `shows` is true. Read from the `plan` list in PARAGON's little file (blocks with a name, a start and an end).
- During a block: large "14:30" (the end), small "until <name>". Otherwise: the next block's start large, its name small. Nothing more planned: "Free" and `nothingPlannedWords` "Nothing more planned". A press opens Today in PARAGON. Colour: purple like the other PARAGON keys.

## 102. Timers in whole minutes, one softer sound (Mac 0.16)
- Timer and focus keys (`TimerKeys`, `FocusKeys`): more than 60 s left shows "21 min" ("75 min" from an hour); exactly 60 s "1:00"; only in the last minute seconds, "0:59". Focus keeps the step's name in the small words. The stopwatch keeps its seconds. The end, the sound and "Done" are on time. A 25-minute timer changes its picture 84 times instead of 1,500.
- A timer's end plays "Glass" once at volume 0.6 (before: twice, 1.2 s apart). Focus rounds play no sound in Deck Mate; PomoTimer plays its own.

## 103. Wrong input said at once (Mac 0.16)
- Link key (`LinkText.kind`, `SetupLane.swift`): text that is neither a file nor an address (for example it has a space) shows in red "This is not a web address or a file. Check it for spaces, or choose a file with the button." and the key counts as broken (the key's problem line is `badWords`, "This is not a web address or a file. It has a space or is not an address."). A bare name such as "example.com" gets a grey note that it opens as https://example.com.
- Town fields (Weather, World clock, Sunrise and sunset): on leaving the field, Return or Save, the town is looked up the way the keys do (Open-Meteo): red "Town not found. Check the spelling." or grey "Lisbon, Portugal". With no network nothing is shown.
- Spotify playlist: non-empty text that is no Spotify link shows in red "This is not a Spotify link. In Spotify choose Share › Copy link, then paste it here." (key problem "This is not a Spotify link"). Empty stays "No Spotify link yet".

## 104. New key from… (Mac 0.16)
- Rule `KeyFrom` in `SetupLane.swift`; the menu is built in `AppDelegate.swift`.
- Menu bar menu: up to three choices with their names: "App: <name>" (the app in front), "Link: <host>" (a copied web address; never a copy a password manager marked secret), "File: <name>" (the file opened last; only offered while a "Recent file" key exists somewhere). Nothing to offer: a grey "Nothing to make a key from yet".
- The key goes on the first empty place of the page showing now. Command-Z in Set up keys takes it back. A full page says "This page is full. … Nothing was changed."

## 105. The deck suggests a key (Mac 0.16)
- Settings › Key use, one calm card on top: "A key for <App>?" with "You used it on 9 of the last 14 days and it has no key.", a full-colour "Add a key" (says where it went: "Added as key N on …") and a quiet "Not this one" (remembered for good).
- Rule (`AppDays` in `SetupLane.swift`; `window` 14 days, `atLeast` 5): the app used on the most days; never an app that has a key (`appsWithKeys`), is a favourite or has its own page group; never Deck Mate or the Finder. Counted in `apps.json` beside the keys file (days only; `SetupLaneViews.swift`). No badge or notification anywhere.

## 106. Save as PDF (Mac 0.16)
- Set up keys › All pages: the button "Save as PDF…" (`KeysPDF.save`): every page group with its pages as small pictures and names on A4 pages with page numbers. Suggested name "Deck Mate keys.pdf"; the file opens afterwards.

## 107. Darker amber and green (Mac 0.16)
- Amber 0.73/0.47/0.06 became 0.62/0.38/0.04 (contrast with white 3.63 to 5.04). Green 0.18/0.61/0.31 became 0.14/0.52/0.26 (3.53 to 4.68). The Settings buttons use the same green. Headings are unchanged. Section 4 is corrected by this. On the phone the sample green tile is darker the same way; the phone has no amber tile.

## 108. Hours for a page group (Mac 0.16)
- Fields `hoursOn`, `hoursFrom`, `hoursTo` (minutes since midnight; default 06:00 to 09:00; the time may pass midnight) on a page group. Set up keys, page group column under "Use with apps": the tick "Show at these hours" and from/to. Grey words: "In these hours it shows instead of the default page group, for apps that have no page group of their own. An app’s own page group, and one you picked by hand, always stay."
- `Navigator.profile(forApp:in:now:)` takes the first page group whose hours include `now` instead of the default one. Looked at when the front app changes, once a minute and at wake. "Duplicate page group" does not copy hours.

## 109. Evening dimming of the box (Mac 0.16)
- Fields `eveningDim` (off by default), `eveningFrom` (21:30), `eveningTo` (07:00) and `eveningBrightness` (5 to 100, default 20) in the keys file; rule `BoxEvening` (`within`, `brightness(for:minute:)`). Settings › The box, under Brightness: the tick "Dim in the evening", "From 21:30 to 07:00" and the slider "Evening brightness".
- Looked at once a minute, at start, at wake and when a setting changes. Untested with the box at hand.

## 110. Actions for Apple's Shortcuts app (Mac 0.16)
- `DeckIntents.swift`: `PressDeckKeyIntent` ("Press a Deck Mate key"; the key is picked from a list of keys that have words and do something, subtitle "page group › page"), `ShowDeckGroupIntent` ("Show a Deck Mate page group", no lock) and `ToggleDeckKeysIntent` ("Show or hide the Deck Mate keys on screen").
- "Quit all apps", "Empty the bin" and "Eject all disks" always ask first. With Settings › Raycast and links off the actions fail with "Pressing keys from outside is switched off. Switch it on in AMS Deck Mate: Settings › Raycast and links › “Keys can be pressed from Raycast and by link”." Not yet tried from the Shortcuts app.

## 111. Ready-made page group "My AMS apps" (Mac 0.16)
- The + in Set up keys offers "My AMS apps – 12 link keys": Tidy Bar (show or hide, show, hide, arrange), Shopping (scan, trip), PARAGON (Inbox, Today, Overdue, Review, Plan), Seedboard (opens the app). Left out for lack of a link: PARAGON start and close the day, Shortcut Overview, Apps Overview. Same rules as the other ready-made groups (0.10): nothing you have is changed; Undo takes it back.

## 112. Keychain for allowed phones (Mac 0.16; iPhone and iPad 0.18)
- Mac: the secrets of allowed iPhones moved from the app's settings into the Mac's Keychain, service `com.schabbauer.AMSDeckMate.pairedPhones`, one item per phone (`PairedKeychain.swift`); the names stay in the settings. They move over by themselves and no password window shows; if the Keychain cannot be used the secret stays where it was and the box diary notes it. "Forget" removes the item. Not proven across a future re-signed build.
- iPhone and iPad: the pairing secret moved into the Keychain, this device only, not synced (`MacKeyStore`, service `com.schabbauer.AMSDeckMatePhone.macKeys`); it moves by itself with no new Allow; "Forget this Mac" removes it.

## 113. Failed save, pictures in the iCloud copy, format number 3 (Mac 0.16)
- A failed save is told once per run of failures: "The last change could not be saved" / "The last change to your keys could not be saved. Your keys keep working, and Deck Mate tries again with every change." It goes into the diary; the next good save clears it.
- The weekly iCloud copy also holds the key pictures: the folder "Pictures" in the iCloud folder, only new or changed files. Missing pictures come back, never over an existing one, with "Bring back an earlier state" from an iCloud copy, the self-repair from iCloud and the start on a new Mac. Settings › Where your setup is kept: "Apart from the weekly copy in iCloud Drive, which holds the keys and their pictures, nothing leaves the Mac."
- A restore does NOT bring back: key-use counts, counters, stopwatches and a running focus round, allowed iPhones, the locked page group, window places, recent apps, switch states, and the Settings choices kept outside the keys file.
- `Deck.currentVersion` is 3 (was 2), because page groups can have hours and the box an evening brightness. Never lowered. An older Deck Mate keeps saying at its start that the file is from a newer one.

## 114. Scripts, closing and quitting (Mac 0.16)
- Every script the app runs (dark mode, mute, Spotify, the Finder's bin, eject) has a 5-second limit and runs away from the main work; the Finder's "empty the bin" gets 60 s so its own question can be answered. Spotify, the Finder and the calendar no longer wait behind each other. The Mac's volume for the iPhone's music plate is read directly, not by a script every 5 seconds.
- The red close button of Set up keys asks "Save the changes to this key?" (Save, Don't save, Cancel keeps the window open) when a key is half edited.
- Typed text is cut at whole characters (`SafetyLane.pieces`), so emoji stay whole, and a long text no longer holds the app up. Quitting waits at most 1 second for a box that does not answer.
- If Control-Option-D belongs to another app, Settings › Keys on screen says in orange: "Control-Option-D is used by another app, so it does not work here. Use the menu bar icon to show the keys."

## 115. Cancel is the Return key (Mac 0.16)
- In "Delete the page group", "Delete page", "Bring over" (Elgato) and the questions before "Quit all apps", "Empty the bin" and "Eject all disks" (`SafeAsk.swift`), Return and Escape both cancel; the action needs a click. Until 0.15 Return did the action in the three Mac questions.

## 116. Small repairs (Mac 0.16)
- A failed Shortcut is told like any failed press: "The Shortcut “X” was not found" (or "… did not finish" / "… could not be started").
- A Raycast key whose command is no longer on this Mac shows a red corner and "This Raycast command is not on this Mac" (before: nothing happened; old wording "The Raycast extension is not installed"). Raycast's own commands, scripts and AI links are never marked.
- Weather: a temperature older than 2 hours turns the key grey-blue and says "As of 14:20". Album cover: a failed look-up is tried again at the next change. A town's time zone that the town search did not give is no longer stored (before: the Mac's own zone was kept).

## 117. Keys that rest, checks that pause (Mac 0.16)
- One clock wakes only when a key needs a new picture (`Pacer.swift`, `wake`; `shortest` 0.05 s, `unseen` 60 s). Seconds tick only when the Mac's page now has a timer, focus, stopwatch, breathing or bar key (`showsSeconds`), or an iPhone or iPad is connected; otherwise once a minute and at a timer's end. App names are remembered instead of being looked up for every picture (cleared when an app starts or quits).
- The check every 4 seconds (may it press keys, does Elgato's app run) and the 5-second look for the music plate pause while the Mac's screen sleeps, and run once at wake.

## 118. PARAGON format check (Mac 0.16)
- PARAGON's little file may carry a format number (missing = 1). A number higher than `ParagonKeys.knownFormat` (1) makes every PARAGON key and "Due today" show "–" and "Update Deck Mate". PARAGON itself is not changed yet: it needs one line for the format number in its next build (pick 52 waits for that).

## 119. iPhone and iPad 0.18 (build 23)
- A note about a key that did NOT work always shows, also with "The note on what a key did" off (above the keys on an iPad; over the top of the left panel on an iPhone on its side). Line under the switch: "A key that did not work always shows its note, also when this is off."
- A tap that shows the keys while the Mac sleeps keeps the screen awake until 2 minutes after the last touch. A line lost while "Mac asleep" with none back within 10 minutes: "Looking for your Mac…". Waiting for Allow: after 30 s "Nothing yet? Wake your Mac and look for the window “… wants to use your keys”." and a full-colour "Ask again".
- Settings: Favourites row, Music button, Mac at a glance and the navigation picture moved into the Showing card; the long-press note is in the Touch card; "Swipe up or down changes page group" (was "profile").
- While the resting clock shows, the screen dims to a quarter of the brightness (never below 5 %), restored on a tap, at the end of the clock and when the app is not active; keys are not drawn while resting. Settings › Clock: "Rest sooner in the evening" (off by default; `PhoneEvening`, from 21:30 to 07:00, may pass midnight): inside it the resting clock comes after 1 minute without a touch, also when Resting clock says Never.
- Looking for the Mac backs off (`PhoneBackoff`): 1, 2, 4, 8, 15, then 30 s between failed tries (before: every second for ever); back to 1 s after a line that worked, on coming to the front, "Ask again", "Forget this Mac" and when the Mac's offer newly appears.
- Works with Mac 0.16; the phone app 0.17 keeps working with Mac 0.16 and the phone app 0.18 with Mac 0.15. Nothing here was run on a device or simulator yet.

## 120. Comes back by itself: the keeper (Mac 0.16.1)
- **Why.** On 17 Nov 2026 a Mac restarted and did not open two menu bar apps of this family although "Open at login" was on: the Mac's own login list (`SMAppService.mainApp`) could not find them. Deck Mate relied on that list alone, so after such a restart the box, the keys on screen, the Raycast commands and the iPhone link stayed dead until the app was opened by hand.
- **The keeper.** While "Open at login" is on, the app keeps a second, independent start order with the Mac: the file `~/Library/LaunchAgents/com.schabbauer.AMSDeckMate.keeper.plist` (label `com.schabbauer.AMSDeckMate.keeper`). It runs the app's own program with `--keeper`; `RunAtLoad` is on; `KeepAlive` only after an unsuccessful exit (so a normal Quit stays closed); Aqua session; `AssociatedBundleIdentifiers` = the app, so the Mac lists it under the app's name. It opens the app at every login even when the Mac's list fails, and again if the app stops unexpectedly (measured on other apps of the family: within about a second; the Mac may wait up to 10 seconds). A Quit by the user keeps the app closed until it is opened or the next login. Switching "Open at login" off removes the keeper too. At every start the app checks the keeper is in place and writes it again if missing.
- **Hand-over.** An app opened by hand while "Open at login" is on hands itself over to the keeper (`Keeper.handsOver`): it closes and is opened again about a second later by the keeper, before it touches the box or the keys file. A link that opened the app in that moment (for example a Raycast command while it was closed) is not carried over; it must be pressed once more.
- **Only one copy.** If two copies start in the same moment (the login list and the keeper), `OneCopy.mustQuit` compares the start time, then the process number: the earlier one stays, the later one quits. Before, each saw the other and both quit, so none was left.
- **System Settings.** General, Login Items & Extensions: the app shows under "Open at Login" and under "Allow in the Background". Both must stay on. The first time the Mac may show "AMS Deck Mate added items that can run in the background".
- **Clean end.** When the Mac shuts down or an update stops the app (SIGTERM), the app ends as with Quit: the box is left tidy and the last changes are saved. Before, such a stop cut it off.
- **The remembered wish.** The setting `wantsOpenAtLogin` is the app's own note that the user wants "Open at login", apart from the Mac's list. The first time it takes what the Mac's list says.
- **Checks.** A copy started with `--checks`, `--data <folder>` or `--plain` never hands itself over to the keeper and is never the copy the Mac opens at login.
- **Where.** Rules in `Core/Sources/DeckMateCore/Keeper.swift` (`OneCopy.mustQuit`, `Keeper.plist`, `Keeper.handsOver`); app side in `App/Sources/Keeper.swift`; tests in `KeeperTests.swift` (section 14); script `Tools/install.sh` (section 15).
- **Settings line.** See section 12.
- **Proven live, 18 Nov 2026, without restarting the Mac.** A hard stop: the app was back in under 1 second. A second copy opened while one runs: the first stays. The start order forgotten and loaded again, as at login: the app starts with `--keeper`. A polite stop: stays stopped, exit code 0, and the keys file was saved on the way out (a safety copy first; 4 page groups, 17 pages, 149 keys before and after). Opened by hand: handed over. Under the keeper the iPhone link came up as before ("ready", "offered" in the box diary).
- **Check picture.** `--snapshots` now also writes `settings-mac-day.png` and `settings-mac-night.png` (Settings, "This Mac"), looked at by day and by night.
- **Not yet proven.** A real restart of the Mac with the keeper in place.
- The iPhone and iPad app is not changed (0.18, build 23).

## 121. Several pages at once (iPhone and iPad 0.19 build 24, Mac 0.17 build 26)
- **Later change.** Since 0.28 an iPad on its side has its own layout for it (section 133).
- **Purpose.** For using the iPhone or iPad without the Stream Deck box: more keys on one screen.
- **Switch.** Phone Settings, Showing, "Several pages at once". Off at first. Remembered on the device.
- **Layout.** Off: one page of 15 keys, as before. On: the iPhone shows 2 pages side by side (10 keys across by 3 down, 30 keys); the iPad shows 4 pages, two above and two below (60 keys). Each page has its own small name above it.
- **Which pages.** The first page is the page the device is on (as before). The others follow in the page group's order and it goes round: after the last page it continues with the first, so you see as many pages as fit (2 or 4), or fewer when the page group has fewer top pages. In a folder, the folder shows first and its own top page is not repeated. A page without a name shows as "Page 2", "Page 3" and so on. Folders are not shown as extra pages.
- **Tap.** A tap on any key does what that key does, as if it had been pressed on its own page. A key that opens a folder or another page moves the view: that page becomes the first one.
- **Swipe.** A sideways swipe moves one page on, as before.
- **Still shown.** The favourites row and the navigation picture show when they are on. The Stream Deck box, if plugged in, and the keys on the Mac's screen keep showing just the first page.
- **Link version 9.** The Mac understands link version 9: it sends the extra pages and carries out a tap on any of them. It needs the phone at 0.19 and the Mac at 0.17. With an older Mac the switch (Settings, Showing; its note says it needs the Mac at 0.17) says so and the phone shows one page as before; with an older phone the Mac talks as before.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 122. Mark check, Mac (Mac 0.17)
- Keys window header: the three buttons read "Search", "Set up" and "Hide" (words, not pictures; Hide has no cross any more). The cross now means "remove" everywhere in the app (Set up keys).
- Set up keys: the two look-alike "+" buttons read "+ Page group" (beside "Page groups") and "+ Page" (after the page names).

## 123. Mark check, phone (iPhone and iPad 0.19) and "Signs in this app"
- The small lock, music and gear buttons have a tiny word under them: "Private", "Music", "Settings". The coloured link dot to the Mac has the word "Mac" under it; a tap explains its colours (green, amber, red).
- Both guides have a part "Signs in this app" listing every mark and colour that means something, each with its meaning: Mac guide (red corner, white dot, letter mark, white frame, lock, header words (Search, Set up, Hide), cross, "+ Page group" and "+ Page", warning, tile colours, grey-blue old number, link dot); phone guide (link dot colours, lock, music, gear, white dot, red corner, red note, amber battery line, page dots, navigation frame and ribbons, page names, app pill, moon, resting clock).
- How it works and What's new are updated in both apps (Mac guide `Guide.swift`, phone guide `PhoneGuide.swift`).

## 124. Several pages at once: folders fill empty spots (Mac 0.17.1 build 27, iPhone and iPad 0.19.1 build 25)
- **Why.** Tried on an iPad: the page group "Notion" (2 top pages) showed just 2 small pages at the bottom, and "AMS Deck" (only the page Home plus folders) showed 1 page.
- **Rule.** The pages that show are the top pages of the page group, as in section 121. When there are fewer than the device shows (2 on an iPhone, 4 on an iPad), the page group's folders fill the rest, in their order in Set up keys. A folder that is itself the first page (the view is inside it) is not repeated. The rule lives on the Mac (it decides which pages it sends), so it needs the Mac at 0.17.1 and the phone at 0.19.1; with an older one it works as in section 121.
- **Example.** iPad with "AMS Deck": Home, Apps, Tutorials and Raycast, 4 pages (60 keys); before: Home only (15 keys).
- **Back key.** A Back key on a folder shown this way goes to the page the folder belongs to; that page then becomes the first page.
- **Bigger keys.** The phone arranges the pages in whichever way gives the biggest keys, counting the 5-by-3 grid of each page and the space left: 2 pages on an iPad sit one above the other, 3 pages may sit two above one. Before: always side by side (2) or two above and two below (4). Example: iPad with "Notion" (2 pages): keys about 75 points before, about 110 points now (about half as big again).
- **Unchanged.** The switch, the page names, tapping, swiping, the box and the keys on the Mac's screen (still just the first page). Link version 9 is unchanged.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.
- **Music button look.** The round Music button is always the light background with a green note; it no longer fills green while something plays. Its word under it says "Playing" while something plays and "Music" otherwise. Before: filled green while music played, a light green ring otherwise. (Section 123's word "Music" is now this word when nothing plays.)

## 125. Hide and show the navigation picture with a swipe (iPhone and iPad 0.20 build 26)
- **Version.** Before: iPhone and iPad app 0.19.1 (build 25). Now: 0.20 (build 26). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Where.** Only when the device is on its side (iPhone and iPad) and the navigation picture (section 29) can show: wider than tall, a Mac at 0.6 or newer, and the switch on.
- **Hide.** A finger on the navigation picture, swipe to the left. The picture follows the finger and slides off to the left, and the keys grow into the room it leaves, live, as the finger drags. On letting go it springs away by itself. Let go early (less than a third of the way, and no quick flick) and it springs back open.
- **Show.** When hidden, a thin purple tab stands at the left edge, as tall as the keys (on the iPhone only since 0.21, section 126; in 0.20 it ran the whole height of the left side there), with the word "Pages" running up it and a small grip mark. A tap on the tab, or a pull to the right, shows the picture: it follows the finger out again, the keys shrink back, and it springs into place. The tab's purple is the same purple as the ribbon of the page group you are in on the picture (section 45).
- **Keys.** A swipe on the keys themselves still changes pages, as before; only a swipe on the picture or the tab hides or shows it.
- **Same as the switch.** The swipe is the Settings, Showing, "Navigation picture" switch (`showMap`, section 29): it turns that switch on or off, so the state is remembered after the app closes, and the switch shows the same state.
- **Key size.** The keys take the freed width only when the width is what holds them back. Measured on an iPad Air 13 on its side (sample keys): without the favourites row 210 → 246 points; with the favourites row 178 → 178 (height-bound). iPhone 17 Pro on its side: 68 → 68 with the favourites row, 96 → 96 without (height-bound both ways). The map column is exactly as wide as the picture, or the 22-point tab, so the keys always get the rest.
- **iPhone only.** While the picture is hidden, the battery warning line and the note on what a key did (they normally sit above the picture in the left panel) move over the keys, at the top in the middle.
- **Texts.** What's new 0.20, How it works (parts "Settings" and "The navigation picture") and "Signs in this app" (new line for the "Pages" tab) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 126. Favourites beside the "Pages" tab, round favourites (iPhone and iPad 0.21 build 27; gold ring since 0.29, section 134)
- **Version.** Before: iPhone and iPad app 0.20 (build 26). Now: 0.21 (build 27). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Where.** Only when the device is on its side (wider than tall), the navigation picture is hidden (section 125), and the favourites row is on (section 25) with at least one favourite set.
- **Column.** The favourites row moves into a column of five keys on the left, right next to the purple "Pages" tab, from top to bottom in the same order as the row (the first favourite at the top). The 15 keys then use three rows only and grow. When the picture shows again, the favourites go back to the row under the keys. The change is animated: it springs with the picture.
- **Round.** Favourites are round everywhere, in the row and in the column, so a round key always means a favourite and a rounded square is one of the 15 keys. Behaviour is unchanged: tap runs it, a long press runs the long-press action (section 24), the white dot and the red corner show as before.
- **Size in the column.** The favourites are smaller than the 15 keys: five of them fit the height of three keys.
- **Tab height.** Correction to section 125: the "Pages" tab is exactly as tall as the keys, its top and bottom in line with them, on the iPhone too. Before (0.20), on the iPhone it ran the whole height of the left side, from the top of the screen; the iPad was already as tall as the keys.
- **iPhone only.** The tab sits about 12 points closer to the screen's left edge, and the favourites column and the keys sit right next to it on the left. Before: the keys stood in the middle with a wide gap after the tab.
- **Key size.** Measured on simulators, sample keys, favourites row on, picture hidden. iPad: keys from about 179 to about 220 points, favourites about 128 points. iPhone: keys from about 68 to about 96 points, favourites about 54 points. (Section 125 gave the sizes of 0.20.)
- **Texts.** What's new 0.21, How it works (parts "The favourites row", "The navigation picture" and "Settings") and "Signs in this app" (changed "Pages" tab line, new line "Round key: a favourite") are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.
- **Small buttons (0.21, his ask).** The music button has no background: only the music mark (22 pt iPad, 19 pt iPhone; since 0.27 inside a thin ring, section 132) in the Settings green with its word under it, like the lock. The gear is drawn at the same size as the lock and music marks (22 / 19 pt; was 30 / 24), so its line is as thin as theirs.

## 127. Bigger "Pages" word, the picture hides by itself (iPhone and iPad 0.22 build 28)
- **Version.** Before: iPhone and iPad app 0.21 (build 27). Now: 0.22 (build 28). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Bigger word.** The word "Pages" on the purple tab (section 125) is bigger and easier to read. Before: 12-point caption type on a tab 22 points wide. Now: 15-point type (subheadline, bold) on a tab 28 points wide. The keys keep their sizes, give or take a point or two.
- **Hides by itself.** Only with the device on its side and the navigation picture showing: when nothing on the screen has been touched for one minute (since 0.23 the quiet time is a choice, see section 128; 1 minute stays the starting choice), the picture slides away by itself, with the same spring as a swipe (section 125). The favourites move into the column and the keys grow, exactly as when the picture is swiped away (section 126).
- **Touch restarts the minute.** Any touch anywhere on the screen starts the minute again.
- **Bring it back.** Tap or pull the "Pages" tab: the picture shows again, and it hides again after the next quiet minute.
- **New switch.** Settings, Showing, right under "Navigation picture": "Hide the picture after a minute" (on at first; renamed "Hide the picture by itself" in 0.23, section 128). Off: the picture stays until it is swiped away.
- **Same switch as the swipe.** Hiding by itself turns the same "Navigation picture" switch off as the swipe does (section 125). After it has hidden itself that switch shows off, and the picture stays hidden after the app is closed until it is brought back.
- **Texts.** What's new 0.22, How it works (parts "The navigation picture" and "Settings") and "Signs in this app" (the "Pages" tab line) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 128. The "Pages" tab nudges, the quiet time is a choice (iPhone and iPad 0.23 build 29)
- **Version.** Before: iPhone and iPad app 0.22 (build 28). Now: 0.23 (build 29). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Nudge.** When the navigation picture hides by itself (section 127), the purple "Pages" tab nudges twice: it moves a little to the right and back, two times, and its purple turns lighter for a moment. The whole thing takes about 1.5 seconds. No glow, no sound. It shows where the picture went.
- **Not on a swipe.** When the picture is swiped away by hand (section 125), the tab does not nudge. Only hiding by itself does.
- **Quiet time is a choice.** Settings, Showing, under the switch: a choice "After" with 30 seconds, 1 minute or 2 minutes. 1 minute is the starting choice, as in 0.22 (section 127, where the time was fixed at one minute).
- **Only while on.** The choice shows only while the switch is on.
- **Switch renamed.** The switch "Hide the picture after a minute" is now called "Hide the picture by itself" (on at first, as before). Off: the picture stays until it is swiped away.
- **Unchanged from 0.22.** Any touch anywhere on the screen starts the quiet time again; the "Pages" tab (tap or pull) brings the picture back; hiding by itself turns the "Navigation picture" switch off, like a swipe.
- **Texts.** What's new 0.23, How it works (parts "The navigation picture" and "Settings") and "Signs in this app" (the "Pages" tab line) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 129. Bigger keys with the picture hidden, page groups on the "Pages" tab, a soft tap feel (iPhone and iPad 0.24 build 30)
- **Version.** Before: iPhone and iPad app 0.23 (build 29). Now: 0.24 (build 30). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Heading steps aside (iPhone only).** With the iPhone held on its side and the navigation picture hidden, the heading line over the keys (page group · page, for example "Default · Page 1", with the coloured link dot) is not shown, so the keys get its height too. Keys: 96 to 106 points (placeholders, to be filled in after measuring on the simulator).
- **Link dot.** It moves to the top of the narrow column beside the keys (the column with the Mac's app, the lock, the music button and Settings). A tap still says in words what its colour means (section on the link dot, 0.19).
- **Page dots and name.** The page dots under the keys still show which page you are on. The page group's name shows again when the picture comes back.
- **iPad.** No change: the heading stays.
- **Page groups on the "Pages" tab.** A long press (about half a second) on the tab opens a small list of your page groups. A tap on one jumps straight to its first page, without opening the picture. The group you are in says "(here)" after its name. A plain tap on the tab still brings the picture back (section 125).
- **Soft tap feel.** A light buzz when the picture snaps away or comes back by your own swipe, pull or tap on the tab. It follows the switch "Tap buzz" (Settings, Touch; an iPad has no buzz). No buzz when the picture hides by itself (section 127).
- **Texts.** What's new 0.24, How it works (parts "The navigation picture" and the iPhone-on-its-side part) and "Signs in this app" (the link dot and the "Pages" tab lines) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 130. Page group name and a hint on the "Pages" tab (iPhone and iPad 0.25 build 31)
- **Version.** Before: iPhone and iPad app 0.24 (build 30). Now: 0.25 (build 31). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Name on the tab (iPhone).** With the iPhone held on its side and the navigation picture hidden (the heading line has stepped aside since 0.24, section 129), the purple "Pages" tab also shows the name of the page group you are in: under the word "Pages", running up the tab like it, in caption size and lighter white. A long name is shortened with "…". So you still see where you are without the heading.
- **iPad.** No change: the iPad keeps its heading, so its tab shows only "Pages".
- **Hint "Hold for groups".** Small purple words under the bottom of the "Pages" tab. They say that holding the tab opens the list of page groups (section 129).
- **When the hint shows.** For 8 seconds each time the tab appears (the picture hidden by a swipe or by itself). Only the first 3 times. Never again once the list has been used (the tab held and a page group picked).
- **Texts.** What's new 0.25, How it works (part "The navigation picture") and "Signs in this app" (the "Pages" tab line and a new line for the hint) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 131. Swipe for page groups on the "Pages" tab, brighter hint at night (iPhone and iPad 0.26 build 32)
- **Version.** Before: iPhone and iPad app 0.25 (build 31). Now: 0.26 (build 32). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Swipe on the tab.** While the navigation picture is hidden, a swipe up or down on the purple "Pages" tab goes to the next (up) or the previous (down) page group, the same as a swipe up or down on the keys. It lands on the same page as the swipe on the keys does.
- **Same switch.** It follows the Settings switch "Swipe up or down changes page group" (card Touch, identifier "swipeProfiles", stored as "swipeProfiles", on at first). Off there, off on the tab too.
- **Buzz.** A soft buzz goes with each change, following the switch "Tap buzz" (Settings, Touch).
- **Name on the tab.** On an iPhone held on its side the group name on the tab (section 130) changes with the swipe. An iPad's tab shows only "Pages".
- **Unchanged.** A plain tap on the tab still brings the picture back; holding about half a second still opens the list of page groups (section 129); a swipe to the left or right on the tab still pulls the picture out.
- **Hint at night.** The hint "Hold for groups" (section 130) stays the tab's purple by day; with a dark background it is a lighter purple, so it reads well on the dark iPad screen. Its timing (8 seconds, first 3 times, never after the list was used) is unchanged.
- **Texts.** What's new 0.26, How it works (part "The navigation picture") and "Signs in this app" (the "Pages" tab line and the "Hold for groups" line) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 132. Music button: note in a thin green ring (iPhone and iPad 0.27 build 33)
- **Version.** Before: iPhone and iPad app 0.26 (build 32). Now: 0.27 (build 33). It works with the Mac app as it is (Mac 0.17.1); no Mac update is needed and the link version is unchanged.
- **Before (0.21 to 0.26).** The music note stood alone, with no ring and no fill, 22 pt on the iPad and 19 pt on the iPhone. (Earlier still: a filled green circle, then a light green circle, section 123 and 0.19.1 to 0.20.)
- **Now.** The note sits inside a thin green ring: a 1-pt line in the Settings green at half strength (colour "settings", opacity 0.5), never filled, the same by day and by night, and the same whether music plays or not. Ring 30 pt across on the iPad, 26 pt on the iPhone. The note inside is 18 pt on the iPad and 16 pt on the iPhone (before 22 / 19).
- **Unchanged.** The word under the button: "Music", or "Playing" while something plays. A tap opens the music plate (section 28). Places: bottom left on an iPad on its side, the edge column on an iPhone on its side, top right when held upright. The lock and the gear keep their look (0.21).
- **Sign.** One meaning only: note in a thin green ring = Music. No other mark in the app uses a ring for something else.
- **Texts.** What's new 0.27, How it works (parts "Settings" and "The Mac at a glance and the music button") and "Signs in this app" (the music line) are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 133. Biggest keys: iPad on its side with several pages at once (iPhone and iPad 0.28 build 34; favourites in a gold ring since 0.29, section 134)
- **Version.** Before: iPhone and iPad app 0.27 (build 33). Now: 0.28 (build 34). It works with the Mac app as it is (Mac 0.17.1, build 27); no Mac update is needed and the link version is unchanged.
- **Aim.** The owner's words: keys as big as possible is priority one; nothing may be hidden; the extras stay in sight but small. He picked "layout 5" from a picture.
- **When.** Only an iPad held on its side (wider than tall) with the Settings switch "Several pages at once" on (section 121). Unchanged: the iPhone (one page already fills its height), an iPad held upright, an iPad on its side with the switch off, the Mac app and the link version.
- **Before (0.27).** A large heading on top; the "Pages" tab or the navigation picture at the left; the 4 pages two above two; the favourites row under them; a bottom bar with Settings / Music / Private and the Mac's app pill. On an iPad mini the keys were about 50 pt and the right 40 % of the screen was empty.
- **Now: pages.** The pages fill the screen, two above two, each with its name above it (name height 16 pt, gap 14 pt between pages). The keys stay square: about 93 pt on an iPad mini (before about 50), about 114 pt on a 13-inch iPad.
- **Now: favourites.** The five round favourites (section 126) stand in one more column at the right of the pages, exactly as big as the keys, under the small word "Favourites": three beside the upper pages, two beside the lower pages.
- **Now: "Pages" button.** In the sixth place of that column, under the two lower favourites. A square as big as a key, not filled: card-coloured, purple frame, the purple word "Pages" and the name of the page group under it. A tap opens the navigation picture (section 29) as a small plate over the keys; a tap on a page there goes to it and the plate closes. A hold opens the list of page groups (section 129). The "Pages" tab at the left edge (sections 125 to 131) and the picture beside the keys are not used in this layout. Since 0.30 (section 136) the picture can also be pulled in from the left edge.
- **Now: the thin line.** Everything else is one line 30 pt high under the keys. Left: the green link dot with the word "Mac" beside it and the Mac's app pill. Middle: the heading (page group · page) in small bold type. Right: Settings, Music and Private, each a small mark with its word beside it (before: under it). The Music note keeps its thin green ring, 26 pt here (section 132).
- **Not shown here.** No page dots and no big clock (no free room; the page names above the pages show where you are). The note on what the last tap did, and the battery warning, float for a moment at the top over the keys.
- **Two pages only.** A page group that shows two pages: the pages stand side by side and the favourites plus the "Pages" button stand in a row under them (six places), because that gives bigger keys.
- **No favourites.** Favourites switched off or none set: no extra column; the "Pages" button is a small purple-framed button in the thin line.
- **Swipes.** On the keys as before: sideways = pages, up or down = page group. Since 0.30 (section 136) a swipe that starts within 32 pt of the left edge pulls the navigation picture in instead.
- **Rule in Core.** `BigKeys` in `Core/Sources/DeckMateCore/MapSwipe.swift`: `BigKeys.plan(width:height:gap:pages:favourites:)` returns across, down, the key side and where the extras go (column, row or none). Constants: between = 14, nameHeight = 16, lineHeight = 30.
- **Tests.** One data test `BigKeysTests`; one screen test `testBigKeysOnItsSide` (identifiers `severalPages`, `favouritesColumn` or `favouritesRow`, `pagesKey`, `pagesPlate`, `bigKeysLine`).
- **Signs.** New: the purple-framed square "Pages" = opens the picture of all pages; hold = page groups. It is the same "Pages" as the purple tab (same colour, same word, same two ways to open the picture and the list), in a layout where the tab is not used. A round key is still a favourite.
- **Texts.** What's new 0.28, How it works (parts "Settings", "The navigation picture", "Several pages at once", "The favourites row", "The Mac at a glance and the music button") and "Signs in this app" are updated.
- **Not yet proven.** Nothing here was run on a real iPad.

## 134. Favourites in a gold ring (iPhone and iPad 0.29 build 35)
- **Version.** Before: iPhone and iPad app 0.28 (build 34). Now: 0.29 (build 35). It works with the Mac app as it is (Mac 0.17.1, build 27); no Mac update is needed and the link version is unchanged.
- **Aim.** The owner wanted the favourites to stand out. He picked option 3 of 4 from a picture: "gold ring each".
- **Before (0.28).** The favourites were round keys (section 126) with nothing round them. The small word "Favourites" over the column of the big-keys screen (section 133) was grey.
- **Now: ring.** Every favourite has a thin gold ring outside its key: line 2 pt, or 1.5 pt when the favourite is smaller than 70 pt; the ring stands 3.5 pt outside the key. The keys keep their size; the ring uses the room between the keys. An empty favourite place has the ring too.
- **Where.** Wherever favourites show: the column and the row of the big-keys iPad screen (section 133), the favourites row under the keys (section 25), and the favourites column beside the keys (section 126), on iPad and iPhone.
- **Now: word.** The small word "Favourites" over the column is gold too.
- **Colour.** Gold is a new colour of its own for favourites: day about (0.79, 0.54, 0.05), night lighter (0.95, 0.75, 0.30); in code `PhonePalette.part("favourites")`. It is not the amber of the warning line or of "looking for the Mac".
- **Signs.** Changed: a round key in a gold ring = a favourite (stays in place on every page and page group). Gold means nothing else in the app.
- **Long press.** Not new (Mac 0.5, section 25): a favourite can have a long press, done by holding it half a second; set on the Mac in Set up keys, which draws a small dot on such a key. Mentioned in What's new 0.29 only.
- **Texts.** What's new 0.29, How it works (parts "The favourites row", "Several pages at once", "Settings") and "Signs in this app" are updated.
- **Not yet proven.** Nothing here was run on a real iPhone or iPad.

## 137. Fan keys last 10 minutes; Set up keys window (Mac 0.19)
- **Version.** Before: Mac 0.18 (build 28). Now: Mac 0.19 (build 29), 25 Nov 2026. Link version stays 9; keys-file format stays 3.
- **Before (0.18, section 135).** The Cool and Full keys posted `cool` or `full`; AMS Fan Menu kept the choice as long as its own "For" line said, and with its usual pick "Until I change" that meant for good, until another key was pressed.
- **Now.** Cool and Full ask for 10 minutes. `FanKeys.minutes = 10`; `FanKeys.wish("cool")` is `"cool:600"` (and `"full:600"`), the object of the distributed notification `com.schabbauer.AMSFanMenu.choose`. Automatic stays `"automatic"` with no time. After 10 minutes AMS Fan Menu gives the fans back to the Mac by itself and its choice goes to Automatic; the Automatic key then shows the filled switch mark (same state file and `changed` notification as in section 135). A second press on the same key sends the wish again, so the 10 minutes start afresh.
- **Words.** `FanKeys.keyWords`: on the key "Cool 10 min" and "Full 10 min" (before: "Cool", "Full"). Since 0.20 this is the wording of a key that is OFF; a key that is on shows the minutes left (section 140). `FanKeys.longWords`: in the picker of "Set up keys" and in the Raycast command names "Fans: Cool for 10 minutes" and "Fans: Full for 10 minutes"; "Fans: Automatic" unchanged.
- **Needs.** AMS Fan Menu 0.3.1 or newer (installed 25 Nov 2026). With an older AMS Fan Menu the Cool and Full keys do nothing (it does not understand the time).
- **Tests.** `FanKeysTests.testCoolAndFullLastTenMinutes`.
- **Signs.** None new; the switch mark keeps its meaning (filled = on, outline = off).
- **Set up keys window.** Before: 620 pt high, but the middle column had grown taller over the last versions, so the content was pushed up and down: the top of the left column (the first page group's name) and the first line of the right column were cut off under the title bar and the bottom line with Undo, Redo and Done was pushed out of the window. Now: the window is 1014 pt wide (before 1010: the three columns were 2 pt wider than their room) and up to 840 pt high. Rule `PagePlaces.windowHeight(screen:)`: 840, or the screen's usable height minus 32 pt for the title bar when that is less, never under 560 (on the owner's MacBook as its screen is set on 25 Nov 2026, 1312 x 848 pt with 821 usable: 789 pt, and the whole left column with five page groups fits without scrolling). Check hook, only in a copy started with `--checks`: the notification `com.schabbauer.AMSDeckMate.clickSetup` with "x,y" clicks inside the window (made inside the app, so it needs no permission). Everything starts at the top (`alignment: .top`), the bottom line is always in sight, and the left and the middle column each sit in a vertical scroll view, so a column that does not fit scrolls by itself. Data test `WidePagesTests.testDroppingAPageOntoAPlaceAndTheWindowHeight`.
- **Texts.** What's new 0.19, How it works (parts "Switch key (on or off)", "Set up keys").
- **Not yet proven.** The 10 minutes on real fans; the Stream Deck box.

## 138. Choose which pages show together (Mac 0.19; shown by iPhone and iPad 0.31)
- **Before.** The app alone decided which pages show with "Several pages at once" (section 121 and 124): the page you are on first (top left), then the next pages of the page group in order, going round, then the group's folders. A tap on a page in the navigation picture moved it to the top left and shuffled the other three.
- **Now.** In "Set up keys", left column, under each page group's settings: a box "Several pages at once" with four places numbered 1 to 4: 1 top left, 2 top right, 3 bottom left, 4 bottom right (an iPad on its side); an iPhone shows places 1 and 2. Drag a page or a folder from the row of pages above the keys into a place. Dropping on a taken place replaces it; dragging from one place to another swaps the two. The small cross in the top right corner of a taken place empties that one place (the same cross that takes an app away from "Use with apps" in the same column). The button "Let the app choose" empties all four places (everything as before); it shows only while a place is taken. A taken place shows the page as a small picture of its 15 keys with its name under it; an empty one is a dashed purple frame with "Drag a page here" and "The app chooses" under it; a place a dragged page is over gets a full purple frame. The page names in the row of pages are plain taps now (not buttons) so they can be dragged.
- **Drag rule.** `PagePlaces.page(dropped:in:)`: a dragged page carries `deckpage:` + its id, a dragged place `deckplace:` + 0 to 3; a page of another group, a dragged key or an empty place brings nothing. `DeckProfile.put(_:inPlace:)`: a page that already has a place swaps with the one that was here, so no page stands in two places; `DeckProfile.tidy` keeps exactly four entries. Data test `WidePagesTests.testDroppingAPageOntoAPlaceAndTheWindowHeight`.
- **Presses.** With places the first page shown need not be the page the device is on, so a key of ANY of the pages shown acts from the page it is drawn on (`PhoneServer.pressOnTile`; before, only pages 2 to 4 did).
- **Data.** `DeckProfile.places: [UUID?]`, 4 entries, `nil` = the app fills it. Missing in older files = all `nil` (keys-file format stays 3). A page or folder that no longer exists counts as empty. Each page group has its own. Saved with the keys.
- **Rule.** `Navigator.spread(at:count:in:)`. Placed pages always show in their places. Going to one of them (tap in the navigation picture, a folder key, Back) changes nothing on the screen except which one is the page you are on. Empty places are filled as before, starting with the page you are on (then following pages, then folders). When all places are taken and you go to a page that is not one of them, it shows in place 1 for the moment; your own page comes back there as soon as you go to one of your placed pages again.
- **Link.** The Mac to phone message `tiles(names:)` gained `at: Int?`: which of the pages shown is the page the device is on. Older apps ignore it. The link version stays 9.
- **Tests.** `WidePagesTests.testPlacedPagesStayInTheirPlaces`.
- **Signs.** New: the numbers 1 to 4 in the box mean the place on an iPad on its side (1 top left, 2 top right, 3 bottom left, 4 bottom right).
- **Texts.** What's new 0.19 (Mac) and 0.31 (phone), How it works (new part "Choose which pages show together"; "Several pages at once"), "Signs in this app".
- **Not yet proven.** On a real iPhone or iPad.

## 139. Switch 1 page / 4 pages, pull on the iPhone, blue name (iPhone and iPad 0.31 build 37)
- **Version.** Before: iPhone and iPad app 0.30 (build 36). Now: 0.31 (build 37), 25 Nov 2026. Works with Mac 0.19 (build 29); the blue name and the placed pages need Mac 0.19.
- **Switch on the screen.** Before: "Several pages at once" only in Settings, Showing. Now: on top of the navigation picture (section 29) sits a two-part switch: "4 pages" and "1 page" on an iPad, "2 pages" and "1 page" on an iPhone. The part in full purple is what shows now; a tap on the other part switches at once. It is in every form of the picture: pulled in from the left edge, in the plate of the "Pages" button, and beside the keys when one page shows. It does the same as the Settings switch (which stays; section 121). The keys keep their size (93 pt on an iPad mini with 4 pages).
- **Pull on an iPhone.** Before: with two pages side by side the iPhone had no navigation picture (the keys need the whole width). Now: the pull of section 136, as on the iPad: a finger from the far left edge to the right, the picture (320 pt wide) slides in over the keys, which dim. It goes away with a slide back to the left, a tap beside it, a tap on a page, or by itself after the quiet time set in Settings (section 127 and 128). A thin purple line at the left edge, halfway up, shows where to pull; a tap on it opens the picture too. A swipe that starts at the far left edge never changes the page.
- **iPhone with 2 pages: layout.** Before: on an iPhone on its side the two pages shared the box made for one page (ratio 5 to 4.1), beside the 200-pt panel that holds the navigation picture with one page and was empty with two; a key was 28 pt on an iPhone 17 Pro and the first page's name lay over the word "Mac". Now (`phoneWideKeys`): no panel; the pages fill the width by the big-keys rule `BigKeys.plan` (726 x 337 pt on an iPhone 17 Pro gives two pages side by side, 64-pt keys), the favourites and the "Pages" button stand in one row under them, as big as the keys; the heading line and the column in the strip beside the camera stay; the note on what a key did and the battery warning float over the top of the keys. Data test `BigKeysTests.testTwoPagesFillAnIPhoneOnItsSide`.
- **Pull on an iPhone: details.** `EdgePull.offered(bigKeys:phoneSideways:pages:hasPicture:)` says where the pull exists; the edge zone starts behind the strip beside the camera cut-out (`atEdge(startX:inset:)`, 32 pt + the left safe-area inset, 62 pt on an iPhone 17 Pro); the picture slides in behind that strip (`EdgePull.offset` with the inset added to the margin); the purple line (4 x 56 pt) stands just inside the safe area, between the strip and the first key. Data test `EdgePullTests.testThePullOnAnIPhoneWithTwoPages`.
- **Sample.** The `-sample` launch follows the switch (`LinkClient.setWide`, `sampleWide`), so it can be tried without a Mac.
- **Blue name.** With several pages at once each page has its name above its keys. The name of the page you are on is now blue and bold, the same blue as the frame round that page in the navigation picture; the other names stay grey. It uses the `at` value of section 138 (Mac 0.19).
- **Placed pages.** The pages the owner placed on the Mac (section 138) show in their places.
- **Signs.** New: the purple two-part switch (full purple part = what shows now). Changed: the thin purple line now also on an iPhone on its side with 2 pages; the blue name = the page you are on (same meaning as the blue frame in the picture).
- **Texts.** What's new 0.31, How it works (parts "Several pages at once", "The navigation picture" pointer) and "Signs in this app".
- **Not yet proven.** On a real iPhone or iPad.

## 140. The minutes left on the fan key (Mac 0.20; shown by iPhone and iPad 0.32)
- **Version.** Before: Mac 0.19 (build 29). Now: Mac 0.20 (build 30), 25 Nov 2026. The Mac draws the keys, so the iPhone and iPad show the minutes by themselves (no change needed there). Needs AMS Fan Menu 0.3.1 or newer, as before; AMS Fan Menu itself was not changed.
- **Before (0.19, section 137).** The Cool and Full keys always read "Cool 10 min" and "Full 10 min", on or off.
- **Now.** The key of the choice that is ON shows what is left: "Cool · 8 min"; in the last minute "Cool · <1 min". Whole minutes, rounded up, the same count AMS Fan Menu shows. The key that is OFF still reads "Cool 10 min" or "Full 10 min" (what a press gives). A choice that is on without an end (set in AMS Fan Menu itself with "Until I change") reads just "Cool" or "Full". "Automatic" never shows minutes.
- **Redraw.** The key is drawn again when the minute changes, not every second. Deck Mate still looks at AMS Fan Menu's note every 2 seconds (section 135) and at once when Fan Menu says it changed.
- **Own title.** A fan key with a title of its own keeps that title; the live words only show on a key without a title (as before).
- **Signs.** Changed: the words on a fan key. "Cool · 8 min" on the key that is on = minutes left; "Cool 10 min" on a key that is off = what a press gives. The switch mark is unchanged.
- **Texts.** What's new 0.20 (Mac) and 0.32 (phone), How it works ("Switch key (on or off)"), "Signs in this app" (both).
- **Not yet proven.** The full 10 minutes counting down on the key.

## 141. Double press (Mac 0.20; iPhone and iPad 0.32)
- **Version.** Before: a key had its normal action and, since 0.5, a long press (`held`, section 24). Now: Mac 0.20 (build 30) and iPhone and iPad 0.32 (build 38), 25 Nov 2026, a third action: the double press.
- **Model.** One new optional field per key in the keys file: `twice` (an Action, like `held`). Missing or type "none" = no double press (every key at first). Files from before are read unchanged, the keys-file format stays 3, and none of the owner's keys was changed (no key of his has a double press yet). In code: `DeckKey.twice`, `DeckKey.hasTwice`, `DeckKey.action(long:twice:)`.
- **Set up keys.** Right under "Long press" at the bottom of the right column there is "Double press": the same list of things a key can do and the same fields as "Long press". A favourite can have one, and so can a key that only moves around (page, folder, page group).
- **Timing rule.** `TwicePress` (`Core/Navigator.swift`): two presses within a third of a second (0.33 s) are a double press. A key that HAS a double press waits 0.33 s after one press, to see whether a second follows, and then does its normal action. Every key without a double press acts at once, exactly as before. On the box and with the mouse the wait starts when the key is let go (a key with `held` already acts on release, section 24). A double press on a key without `twice` is two presses, one after the other, as before. A long press (0.5 s) still works on a key that has both.
- **Where it counts.** The box's keys, a click on the keys on screen, a tap on the iPhone and iPad (the 15 keys and the favourites; the Mac does the waiting, so an iPhone or iPad app 0.31 gets the double press too with Mac 0.20), the key's letter typed twice while the keys on screen take the keyboard, and links (below).
- **Links.** `amsdeckmate://press?key=<id or words>&twice=1&pass=<pass>` runs the double-press action at once, with no waiting (section 94; like `&hold=1`).
- **Key check.** The check for broken keys also looks at `twice`; its note starts with "Double press: " (like "Long press: ", section 24).
- **Sign.** New: a small white "×2" in a key's top right corner = the key has a double press. It sits to the left of the place of the long-press dot (the dot keeps its one meaning: hold). A key can show both. On the box, the keys on screen and the iPhone and iPad.
- **Texts.** What's new 0.20 and 0.32, How it works (Mac: "Keys on screen", "Set up keys", new part "Double press: a third action", "Press keys from Raycast and by link"; phone: "Settings" (Touch), new part "Double press", "The favourites row"), "Signs in this app" (both).
- **Not yet proven.** The double press on the real Stream Deck box (the owner is away until January 2027); a real finger double-tapping on a real iPhone or iPad with the real Mac.

## 142. What a key does, in words; the pointer note and the Explain button; link version 10 (Mac 0.20; iPhone and iPad 0.32)
- **Version.** Before: nothing said in words what a key would do. Now: Mac 0.20 (build 30) and iPhone and iPad 0.32 (build 38), 25 Nov 2026.
- **Rule.** `KeySays` (`Core/KeySays.swift`): new words for every kind of key, said as what it WILL do: "Opens Safari", "Presses ⌘N", "Fans: Cool for 10 minutes", "Goes to the page “Money”" and so on. Up to three lines per key: tap (on the Mac: click), hold (only when holding does something else, i.e. the key has `held` or acts on hold) and twice (only when the key has a double press, section 141).
- **Mac, the keys on screen.** Resting the pointer on a key for one second shows a small light plate over the other half of the keys that says "Click …", "Hold …" and "Twice …". Moving the pointer away, or a click, removes it. Nothing else about the keys on screen changed.
- **iPhone and iPad, the Explain button.** A new small button "Explain" (a hand-drawn question mark in a ring, with its word) stands with Settings, Music and Private: in the thin line under the keys on the iPad's big-keys screen, in the narrow column beside the keys on an iPhone held on its side, in the top line when held upright. Settings, Music and Private keep their exact places; Explain is added on the side away from the screen's edge. Its own colour is pink (pink means Explain only on the iPhone and iPad).
  - Tap Explain: it becomes a filled pink button, every key gets a thin pink frame, and a plate says "Explain is on. Tap a key to read what it does — nothing is pressed. Tap Explain again to leave."
  - Tap a key or a favourite: nothing is pressed. The plate shows the key's words in bold and under them "Tap …", "Hold …" (when holding does something else) and "Twice …" (when it has a double press). Tap key after key. The plate stands at the top of the screen when the key is in the lower half, and at the bottom when the key is in the upper half, so it never covers the key.
  - Tap Explain again: the keys act again. It also ends when Settings opens or the app leaves the screen. It never ends by itself while the owner looks, so a tap meant for reading can never press a key.
  - Swipes (pages, page groups, the pull from the left edge, section 136) work as before while Explain is on.
  - The button only shows while connected to a Mac with 0.20 or later (the Mac sends the words).
- **Link version 10.** `PhoneLink.currentVersion` is 10 (was 9, section 96 and 121). The Mac sends the words of each shown key to a side at link version 10. Old and new work together: an iPhone or iPad 0.31 with Mac 0.20 gets the double press too (the Mac does the waiting) but has no Explain button; an iPhone or iPad 0.32 with a Mac before 0.20 shows no Explain button, because that Mac does not send the words. Keys-file format stays 3.
- **Signs.** New: a small white "×2" (section 141); on the iPhone and iPad a question mark in a ring with the word "Explain", pink = the Explain button, filled pink = Explain is on, and a thin pink frame round every key = Explain is on, a tap reads the key instead of pressing it. Changed: the words on a fan key (section 140). Unchanged: the small white dot = long press.
- **Texts.** What's new 0.20 and 0.32; How it works (Mac: new part "What a key says it does", "Keys on screen"; phone: new part "Explain", "Settings"), "Signs in this app" (both).
- **Not yet proven.** A real finger on a real iPhone or iPad with the real Mac.

## 136. Pull the navigation picture in from the left edge (iPhone and iPad 0.30 build 36)
- **Version.** Before: iPhone and iPad app 0.29 (build 35). Now: 0.30 (build 36), 25 Nov 2026. It works with the Mac app as it is (Mac 0.18, build 28); no Mac update is needed and the link version is unchanged.
- **Aim.** The owner missed pulling the navigation picture in from the left, which he had before 0.28 in the other layouts (the purple "Pages" tab, section 125). Since 0.28 the big-keys screen (section 133) only had the "Pages" button.
- **When.** Only an iPad held on its side with "Several pages at once" on (2 to 4 pages showing). Unchanged: the iPhone, an iPad held upright, an iPad showing one page, the Mac app and the link version.
- **Open.** A finger slides from the far left edge of the screen to the right; the navigation picture (all page groups with their pages as small pictures, section 29) slides in from the left over the keys and follows the finger. Let go after a third of its width, or flick it: it stays open; otherwise it springs back. It is 320 pt wide and as tall as the screen. The keys behind it are dimmed.
- **Close.** Slide it back to the left, tap the dimmed keys beside it, or tap a page in it (goes to that page and closes). It also closes by itself after the quiet time, following the Settings > Showing switch "Hide the picture by itself" and its "After" time (30 s, 1 min, 2 min; section 127 and 128).
- **Buzz.** A soft buzz when it snaps open or shut by hand; it follows the switch "Tap buzz".
- **Changed: swipes.** A swipe that starts within 32 pt of the left edge pulls the picture in and no longer changes the page. Swipes that start anywhere else on the keys still change page (sideways) or page group (up or down).
- **Unchanged.** The purple-framed "Pages" button (sixth place under the favourites) still opens the picture as a small plate beside it; a hold still lists the page groups. Both show the same picture.
- **Rule in Core.** `EdgePull` in `Core/Sources/DeckMateCore/MapSwipe.swift`: zone = 32 pt. Opening needs a mostly sideways drag to the right that starts in the zone; closing needs a mostly sideways drag anywhere while the picture is open. It reuses `MapSwipe.shownWidth` and `MapSwipe.opensAfter` (section 125).
- **View.** `pagesDrawer` in `Phone/Sources/DeckScreen.swift`, with identifiers `pagesDrawer`, `pagesDrawerShade` (the dimming) and `pagesEdge` (the purple line).
- **Tests.** One data test in `MapSwipeTests` for `EdgePull`.
- **Signs.** New: a thin, short purple line at the left edge of the screen, halfway up = where to pull the navigation picture in (a tap on it opens it too). Purple is the colour of pages: the same purple as the "Pages" tab, the ribbon of the page group you are in and the "Pages" button. It stands in the narrow margin at the edge, so the keys keep their size exactly (93 pt on an iPad mini).
- **Texts.** What's new 0.30, How it works (parts "Tapping keys", "The navigation picture", "Several pages at once") and "Signs in this app" are updated.
- **Not yet proven.** Nothing here was run on a real iPad.

## 135. Fan keys (Mac 0.18)
- **Version.** Before: Mac 0.17.1 (build 27). Now: Mac 0.18 (build 28), 24 Nov 2026. The iPhone and iPad app was 0.29 (build 35) at that time and needed no update: the Mac draws the keys, so the new keys show and work there by themselves. The link version stays 9 and the keys-file format stays 3.
- **What.** Three new choices of the Switch key (section 47): `ActionType.toggle` with `target` `fan:automatic`, `fan:cool` or `fan:full`. In Set up keys, "Switch (on or off)" had four choices (Dark mode, Mute the sound, Keep the Mac awake, Two things in turn); it has seven now ("Fans: Automatic", "Fans: Cool", "Fans: Full"). Rules in `Core/Sources/DeckMateCore/FanKeys.swift`, enum `FanKeys`.
- **Needs.** AMS Fan Menu (version 0.2 or newer), the owner's menu bar app that sets the MacBook's fan speed, installed on this Mac. Deck Mate never touches the fans itself; it only asks AMS Fan Menu.
- **Press.** Posts the distributed notification `com.schabbauer.AMSFanMenu.choose` with the choice word as its object. Automatic: the Mac runs the fans itself. Cool: a middle speed. Full: top speed. The speeds are Fan Menu's own, set there.
- **Fan Menu not open.** The press opens AMS Fan Menu first and posts the notification about 1.5 seconds later. **Not installed:** the press does nothing and the note says "AMS Fan Menu is not on this Mac". After a press the note says "Fans: Cool" (or Automatic, Full).
- **Key check.** While AMS Fan Menu (`com.schabbauer.AMSFanMenu`) is not on this Mac, a fan key counts as a key that cannot work: red corner in Set up keys and "AMS Fan Menu is not on this Mac" (`KeyCheck.problem`).
- **Showing which is on.** The Mac reads `~/Library/Application Support/AMS Fan Menu/state.json` (its `choice` word) every two seconds while any switch key is in use, and at once when the distributed notification `com.schabbauer.AMSFanMenu.changed` arrives. The fan key whose choice is on shows the switch mark of section 47 filled; the other fan keys show it as an outline. Same mark, same meaning as on every switch key; no new sign.
- **Follows Fan Menu.** Within a moment (two seconds at most), also when the choice is changed in Fan Menu's own panel or by its own rules (on battery, a timed choice running out, too hot, sleep). A choice with no key (Quiet, My speed, Follow temperature): no fan key is filled.
- **Second press.** Unlike the other switches, a press on a fan key that is already on changes nothing. To leave Cool, press Automatic (or Full).
- **Reaching the screens.** The "on" state travels to the box, the keys on screen and the iPhone and iPad inside the key's picture, using the existing `quiet` ("lit") flag of a shown key. So the link version does not change.
- **Look.** Purple like every switch key (colour = kind of key). Drawing: a fan with three blades, the same mark AMS Fan Menu shows in the menu bar, from the shared AMS icon library (`app-fan.svg`). One more drawing to pick in Set up keys: 257 files in the app's Icons folder (256 before). Without a title of its own the key says "Automatic", "Cool" or "Full" (0.19: "Cool 10 min", "Full 10 min"; since 0.20 the one that is on shows the minutes left, section 140).
- **Own keys.** Three fan keys were added on free places, nothing moved: page group "AMS Deck", page "Home", bottom row, the first three places (places 11, 12 and 13 counting from 1; index 10, 11, 12): Automatic, Cool, Full. A copy of the keys file from before is in Backups ("deck before fan keys 2026-11-24 2055.json"). Keys: 208 before, 211 now.
- **Tests.** `FanKeysTests`: three more data tests than before.
- **Signs.** None new. The switch mark keeps its one meaning: filled = on, outline = off; on a fan key, "on" means that fan choice is on right now.
- **Texts.** What's new 0.18, How it works (part "Switch key (on or off)", the list of drawings) are updated.
- **Not yet proven.** The Stream Deck box itself (the owner is away until January 2027), and the keys on his real iPhone and iPad.
