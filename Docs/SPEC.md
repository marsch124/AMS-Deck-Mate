# AMS Deck Mate, specification, version 0.7 (build 9), 16 Nov 2026; iPhone and iPad app 0.9 (build 13)

A Mac menu bar app that drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

**Warning.** 0.1 was built while the box was away. Driving the real box is not yet tried. The first real test is planned for January 2027. The keys on screen, the rules and the setup do not need the box.

## 1. Purpose
- Give the 15-key Stream Deck (2019) and MK.2 their keys without Elgato's app.
- Mac app: menu bar only, no Dock icon. The version shows in Settings.
- Since 0.3 also an iPhone app that shows and presses the same keys (section 17).
- Since 0.6 (Mac) and 0.8 (iPad): the navigation picture on an iPad held on its side (section 29).
- Since 0.7 (Mac) and 0.9 (iPhone and iPad): the "Recent app" and "Ask AI (copied text)" keys, and the dark screen while the Mac sleeps (sections 31 to 33).
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
- One colour per kind (`KeyKind`): app blue, web (links) teal, raycast red-orange, shortcut purple, text amber, media green, move (folder, back, pages, page group) grey-blue, empty neutral.
- A "several things" key takes the kind of its first step that is not "nothing".
- An app key shows the app's own icon unless an icon is picked.
- An app key with an empty title shows the app's name (`DeckKey.shownTitle(appName:)`, see section 18). Own words always win.
- 245 hand-drawn icons: the AMS Icon Library plus new ones drawn for this app. A key's `icon` is a drawing's name; empty means the automatic one (`autoIcon`): deck-link, deck-raycast, deck-keyboard, deck-text, deck-play, deck-next, deck-previous, deck-volume-up, deck-volume-down, deck-mute, deck-folder, deck-back, deck-page-next, deck-page-previous, deck-profile, deck-multi.

## 5. Set up keys
- Left: page groups (heading "Page groups"). Add ("Add a page group"; the new one is named "New page group"), rename, delete, make default, "Use with apps" (the apps a page group belongs to).
- Middle: the 15 keys, with the pages and folders of the page group above them. Add page, delete page.
- Right: the clicked key. Title, Icon, "What it does". Cancel and Save on every edit; Escape is Cancel.
- "Clear key" empties a key. "Try it" runs the key.
- 0.5: under "What it does", a picker "Long press": Nothing, or any action type except "Folder of keys" (section 24). Under the 15 keys, a row "Favourites" of 5 places (section 25).
- 0.5: the button "All pages" at the top right of the Keys column. It shows every page group with every page and folder as a small picture of its 15 keys, with its name and the number of keys under it. A folder carries the folder mark; the page being edited has a coloured frame. A click on a page opens it for editing. "Back to the keys" or Escape goes back to the keys.
- 0.4 additions (details in section 20): drag to move or swap keys, drop on a page chip; copy and paste; Duplicate page; Duplicate page group; Undo and Redo; red marks for broken keys.

## 6. Key actions
`ActionType`: none, app, link, raycast, shortcut, text, media, folder, back, nextPage, previousPage, page group, multi. An unknown name decodes as none.

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
| Several things in a row | (uses `steps`) | steps run in order, a third of a second apart. Steps may nest to depth 4 |
| Recent app (0.7) | "1", "2" or "3" (1st, 2nd, 3rd) | brings that recent app forward; see 31 |
| Ask AI (copied text) (0.7) | none | opens Raycast AI Chat with the copied text; see 32 |
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
- Elgato's own app must be quit while Deck Mate drives the box (only one can hold it). Settings warns when it runs and has "Quit Elgato's app".
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

## 12. Settings
Three tabs: Settings, How it works, What's new. The version, Quit and Done are at the bottom.
Since 0.4 the Settings tab is a list on the left with one part at a time on the right (before: one long scroll). The parts, in order: The box (box, brightness), First time with the box, Keys on screen (Show them, Hide after a key is pressed, Size), iPhone (section 17), Page groups (change page group with the app in front), Check keys, This Mac (open at login, permissions), From Elgato (bring over again), Where it is kept.
- "First time with the box": the steps for the first day with the real box (quit Elgato's app, plug the box in, allow Input Monitoring if the Mac asks), the box's answer in plain words, and a button to show the box diary (box log). Reminder: the real box is still untried (the author is away until January 2027).
- "Check keys": the button "Check all keys" lists every broken key as "Page group · Page · key: reason" (section 20).
- The picture used for checks (sample Settings picture) shows a made-up iPhone, never real data.
- 0.5: the Mac's Settings have no new switch. The Mac keeps one own place for each connected iPhone or iPad (in memory, for the connection) for "My own keys" (section 26). The new switches are on the iPhone and iPad (section 23).

## 13. Storage
- One file: `~/Library/Application Support/AMS Deck Mate/deck.json`. Each save first keeps the previous file as a safety copy (the last 20) in `Backups` beside it.
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
- Rule tests live in `Core` (moving around, Raycast links, box byte layouts, tolerant decoding, the keys on screen). Run: `cd Core && swift test`.
- New in 0.5 (round B): `Core` has 36 data tests (37 since 0.6, see below), 7 of them new, for the new rules: long press (`held`), favourites, own keys, and the new `PhoneLink` messages. The iPhone app's screen test now also finds the favourites row, the Mac at a glance, the music strip and the Keys card by identifier.
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

**0.7 (Mac, build 9, 16 Nov 2026).** The keys "Recent app" and "Ask AI (copied text)" (sections 31, 32), and the Mac's sleep and wake news for the iPhone and iPad (section 33). The iPhone and iPad app is 0.9 (build 13). Not proven yet: "Ask AI" against the real Raycast, the dark screen on the real iPad.

**0.6 (Mac, build 8, 16 Nov 2026).** The navigation picture (section 29). The iPhone and iPad app is 0.8.2 (build 13). Not proven yet: the navigation picture on the real iPad.

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
- `keys(place, keys[index, title, PNG])`: `place` is the position (the line on top of the keys, as the Mac shows it: the group's name, plus " · " and the page's name when the page group has more than one page (e.g. "OmniFocus · Page 2") as shown on the Mac); each key has its place 0 to 14, the title shown (see `shownTitle`) and its picture as PNG, drawn by the Mac (so app keys have the real app icon). The Mac sends `keys` first when the iPhone is allowed, then again whenever the position or the setup changes.
- `press(index)`: the iPhone tapped a key.

**Version rule (0.6).** `PhoneLink.currentVersion` is 4 (it was 3 in 0.5). The navigation picture (section 29) needs the Mac at 0.6 and the iPhone and iPad app at 0.8; its new messages go only to a side that announced version 4. With an older Mac the picture stays hidden and everything else works as before.

**Version rule (0.5).** `PhoneLink.currentVersion` was 3. The Mac's version rides in `welcome`. The new parts need the Mac at 0.5 and the iPhone and iPad app at 0.7. An iPhone or iPad at 0.7 with an older Mac (which sends no version) works as before: Settings says "Needs AMS Deck Mate 0.5 on the Mac" in the Keys card and the new parts stay hidden. A Mac at 0.5 with an older iPhone app works as before; the white dot is part of the key pictures, so it still shows.

**New messages (0.5).**
- iPhone to Mac: `own(profile:)` (use my own keys with this page group; nil means "Follow the Mac"), `hold(index:)` (the key at this place was held for 0.5 s: run its `held` action, or the normal action if it has none), `favourite(index:, long:)` (a favourite 0 to 4 was tapped; `long` true for a hold), `music(command:)` with `playPause`, `next`, `volumeUp`, `volumeDown`.
- Mac to iPhone: `favourites(keys:)` (the 5 favourites: index 0 to 4, title, PNG, with the white dot where `held` is set), `mac(MacNow)` (see section 27).
- Framing, the 4 MB limit and tolerant decoding are unchanged.

**Allowing.**
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
- Bundle id `com.schabbauer.AMSDeckMatePhone`; display name "Deck Mate"; iOS 17 and later; iPhone and iPad (since 0.5); on TestFlight. Version 0.8.2 (13). Source in `Phone/`; its guide is `Phone/Sources/PhoneGuide.swift`, the same shape as `App/Sources/Guide.swift`.
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
- Page groups by swipe (0.5.1): a swipe up on the keys locks the next page group, a swipe down the one before, round the end (`PhoneLink.Status.profile(after:)`, sent as `profile(id:)`); nothing happens with one page group. A swipe counts when it is longer than 60 points and at least 1.5 times as long in its own direction as in the other.
- Pages: swipe left or right on the keys for the next or previous page. Page dots under the keys show which page; no dots inside a folder or with one page.
- Page group menu: a tap on the top line (the name of the page group) opens a menu: "Automatic", or "Lock one" of the page groups (as the Mac's menu). A hand-picked page group shows the lock beside its name (0.5.2). *
- Pressed keys light up: a key pressed on the box, on the keys on the Mac screen or on the iPhone shows pressed on the iPhone. *
- What ran: after a tap a short note at the bottom, for example "Opened OmniFocus" or "Raycast: Clipboard history". When the Mac could not do it the note is red with the warning drawing, for example "The app is not on this Mac" or "The Mac has not allowed key presses yet". *
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
- A page group picked by hand (the top line's menu, a swipe up or down on the iPhone and iPad, or the Mac's menu) shows a small hand-drawn lock beside the name of the page group: on the iPhone and iPad top line and on the Mac's keys on screen. Locked: the page group stays until "Automatic" is chosen (tap the top line on the iPhone and iPad; the menu bar menu on the Mac). No lock: on the Mac the page group follows the app in front.
- Mac menu line: "Page group: <name> (locked)" or "(automatic)". iPhone and iPad menu section: "Lock one".
- iPad only: the top line is larger: the name of the page group is title size and bold, the "Connected to …" line is bigger, and the settings button is larger. The iPhone top line is unchanged. (Changed in 0.8.1, see section 30: the heading is centred, there is no "Connected to …" line any more, and the iPhone heading is title size.)
- Nothing else changes. The Mac and the iPhone and iPad app work with each other in any mix of these versions.

## 23. iPhone and iPad settings, 0.6 and 0.6.1 (iPhone and iPad app, build 9, 16 Nov 2026)
(Mac 0.5 (7) since 0.7 of the iPhone and iPad app.) The Mac app was unchanged at 0.4.2 (6) in 0.6 and 0.6.1. Settings are opened with the gear at the top right. Every choice applies at once and is remembered on that device only. Done closes Settings. With the first (default) choice of everything the app looks and works as in 0.5.2. Four groups, then the unchanged "Your Mac" part with "Forget this Mac".

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
- A long press on a key without `held` does the usual thing.
- iPhone and iPad: a key with `held` sends `hold(index:)` after 0.5 s, with a stronger buzz (if Tap buzz is on); a shorter tap sends `press(index:)`. A key without `held` sends `press` at once.
- Box and Mac keys on screen: a key with `held` acts when let go (short) or after 0.5 s still held (long); all other keys act at once. The box rule is not yet tried on the real box.
- "Hide after a key is pressed" applies to the action that ran, as in section 3.

## 25. Favourites row (Mac 0.5, iPhone and iPad 0.7)
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
- Since 0.8.1: one very small centred line at the very bottom of the screen, under the page dots (before, in the top line): a small battery drawing and "73 % charging · Claude", or "82 % · Safari" when not charging. A Mac without a battery shows only the app.
- Settings, Showing: switch "Mac at a glance" (default on, stored on that device).

## 28. The music button and plate (Mac 0.5, iPhone and iPad 0.7; button since 0.8.1)
- Since 0.8.1 (before, a strip above the keys): one small round button at the top right of the key screen, beside the settings button, shown when the switch "Music button" is on (default on, stored on that device; the stored setting is the same one that was called "Music strip") and the Mac is at 0.5. It is filled green while something is playing. A tap opens a small plate with: song and artist, play or pause, next, quieter, the Mac's volume in percent, louder. A tap outside the plate closes it. Since 0.8.2 the plate has a solid background (the card colour), not see-through glass.
- Spotify and Apple Music. The Mac listens for the change notices both send when the song or the play state changes, so the plate says "Nothing playing yet" until the next change of song or pause after the Mac app has started.
- Buttons send `music(command:)`: `playPause`, `next`, `volumeUp`, `volumeDown`. Play or pause and next are done as the Mac's music keys, so they need the same one-time Accessibility permission. Volume moves 6 points per tap and needs no permission.
- Not yet tried: play or pause from the plate.

## 29. The navigation picture (Mac 0.6, iPad 0.8)
- Where: only on an iPad held on its side (wider than tall). The keys sit on the right and the navigation picture on the left. An iPad held upright and the iPhone are unchanged, because there is no room on the left.
- What it shows: every page group, with every one of its pages and folders, each as a small picture of its 15 keys with the page's name under it. A folder shows its folder mark. The page showing now has a coloured frame and the name of its page group is highlighted. The list scrolls when it is long.
- Pictures: drawn by the Mac, PNG, 166 x 98 px each, and sent when the setup changes (and when a device that announced version 4 connects).
- Messages (only to a side that announced version 4): Mac to iPhone `map(groups:)`; each group has id, name and pages; each page has id, name, folder (yes or no) and its PNG picture. iPhone to Mac `go(profile:page:)`.
- `Status` has a new optional field `pageID`: the page showing now. The iPad uses it to draw the coloured frame and the highlighted name.
- Tap on a small page: the iPad sends `go(profile:page:)`. The rule `Navigator.go`: an unknown page group or page changes nothing.
- Follow the Mac: the Mac goes to that page and that page group is locked, as when it is picked in the top-line menu. "Automatic" in that menu lets it follow the app in front again.
- My own keys (section 26): only the iPad's own place moves, and the picked page group is remembered on the device.
- Settings, Keys card: new switch "Navigation picture" (setting key `showMap`, default on, stored on that device), with the note that it shows on an iPad held on its side.
- Older versions: the picture needs the Mac at 0.6 and the iPad app at 0.8. With an older Mac (no `map`) the picture stays hidden and everything else works as before.
- Not proven yet: on the real iPad.

## 30. The key screen's top (iPhone and iPad 0.8.1)
Made after 0.7 on a real iPad, where the top was too crowded. Only the key screen changes; the Mac app is unchanged (0.6, build 8).
- Heading: the place (for example "OmniFocus · OF Main") is centred at the top and larger: large title size and bold on the iPad, title size on the iPhone. A tap opens the menu of page groups (section 21). The lock shows beside it for a page group picked by hand.
- Connection: one small coloured dot at the top left, instead of the line "Connected to <Mac>". Green: connected. Amber: looking, connecting, or waiting for the Mac to allow it. Red: the Mac said no. A tap on the dot opens a small card that says it in words (for example "Connected to MS MBP 2021") and what the colours mean. Since 0.8.2 the card has a solid background (the card colour), not see-through glass. The big message card in the middle while there is no Mac is unchanged.
- Music: one small round button at the top right, beside the settings button; the plate it opens is in section 28. The Settings switch is called "Music button".
- The Mac at a glance: one very small centred line at the very bottom, under the page dots (section 27). Same switch.
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
- Set up keys, "What it does", "Ask AI (copied text)". Raycast colour (red-orange), an AI drawing, title "Ask AI".
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

## Not proven yet (0.5, 0.6, 0.7, 0.8.1 and 0.9)
- "Ask AI (copied text)" against the real Raycast.
- The dark screen on the real iPad.
- The navigation picture on the real iPad.
- Long press on the real box (away until January 2027).
- Long press on a real iPhone or iPad.
- Play or pause from the music plate.
