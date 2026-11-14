# AMS Deck Mate, specification, version 0.2 (build 2), 14 Nov 2026

A Mac menu bar app that drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

**Warning.** 0.1 was built while the box was away. Driving the real box is not yet tried. The first real test is planned for January 2027. The keys on screen, the rules and the setup do not need the box.

## 1. Purpose
- Give the 15-key Stream Deck (2019) and MK.2 their keys without Elgato's app.
- Mac only. Menu bar only, no Dock icon. The version shows in Settings.

## 2. Menu bar
The icon opens a menu:
- "Show keys on screen" (shortcut Control-Option-D).
- "Set up keys…".
- "Profile": "Automatic", or one profile pinned by hand. A pinned profile is held.
- "Settings…".
- "Quit AMS Deck Mate".

## 3. Keys on screen
- A small floating window with the same 15 keys as the box (5 columns, 3 rows). A click does what pressing the box key does.
- It does not take the keyboard from the app the user works in. It stays above other windows, can be dragged anywhere and remembers its place.
- The top line shows the profile and page names and a button to set up keys.
- It works without the box.
- Three choices, made in Settings in the card "Keys on screen" (rules in `ScreenDeck.swift`: `ScreenDeckRules`, `ScreenSize`). Together they make the keys on screen a virtual deck: Control-Option-D, the keys appear under the mouse, click a key, they are gone.

**Show them** (`screenAtPointer`, default false)
- "Where I left them": the window comes back where the user last dragged it (as in 0.1).
- "At the mouse pointer": each time the window is shown (from the menu or with Control-Option-D) it is centred on the mouse pointer. The place the user drags it to is not remembered in this mode.
- Placement (`ScreenDeckRules.origin(pointer:size:area:margin:)`): `area` is the usable part of the screen the pointer is on; `margin` is 8 points. On each axis the wanted lower left corner is the pointer minus half the window size, then held between `low + margin` and `high - margin - length`. If the window is larger than that room, it is centred on the area. The answer is the lower left corner.

**Hide after a key is pressed** (`screenHidesAfterKey`, default false)
- Rule (`ScreenDeckRules.hides(after:setting:)`): the keys hide when the setting is on and the outcome of the click ran something on the Mac (`outcome.run` is not empty).
- A key that only moves around (folder, Back, next or previous page, switch profile) runs nothing, so the keys stay open.
- A "several things in a row" key hides them when at least one of its steps runs something on the Mac.
- Only clicks on the screen hide the keys. Pressing a key on the box does not.

**Size** (`screenSize`, default normal)
- `ScreenSize`: small, normal, large. The side of one key (`keySide`) is 48, 64 or 80 points; the gap between keys (`gap`) is 6, 8 or 10 points. Normal is the size 0.1 had.
- The window changes size at once.

## 4. Key look and colours
- A flat coloured tile, a white hand-drawn icon, a short title.
- One colour per kind (`KeyKind`): app blue, web (links) teal, raycast red-orange, shortcut purple, text amber, media green, move (folder, back, pages, profile) grey-blue, empty neutral.
- A "several things" key takes the kind of its first step that is not "nothing".
- An app key shows the app's own icon unless an icon is picked.
- 245 hand-drawn icons: the AMS Icon Library plus new ones drawn for this app. A key's `icon` is a drawing's name; empty means the automatic one (`autoIcon`): deck-link, deck-raycast, deck-keyboard, deck-text, deck-play, deck-next, deck-previous, deck-volume-up, deck-volume-down, deck-mute, deck-folder, deck-back, deck-page-next, deck-page-previous, deck-profile, deck-multi.

## 5. Set up keys
- Left: profiles. Add, rename, delete, make default, "Use with apps" (the apps a profile belongs to).
- Middle: the 15 keys, with the pages and folders of the profile above them. Add page, delete page.
- Right: the clicked key. Title, Icon, "What it does". Cancel and Save on every edit; Escape is Cancel.
- "Clear key" empties a key. "Try it" runs the key.

## 6. Key actions
`ActionType`: none, app, link, raycast, shortcut, text, media, folder, back, nextPage, previousPage, profile, multi. An unknown name decodes as none.

| Action | `target` | What happens |
|---|---|---|
| Open an app | bundle identifier, or full path when it starts with "/" | the app opens or comes forward |
| Open a link or a file | web address or file path | opened by the Mac. Also how a Raycast quicklink goes on a key |
| Raycast | the whole raycast:// link | see 7 |
| Keyboard shortcut | (uses `combo`) | the keys are pressed. Needs Accessibility |
| Type text | the text | typed. Needs Accessibility. Also how a snippet goes on a key |
| Music and sound | a `MediaKey` | playPause, next, previous, volumeUp, volumeDown, mute |
| Folder of keys | the page's id | opens that page; the page we came from is pushed on the trail |
| Back | none | pops the trail; with an empty trail goes to the profile's first page |
| Next / previous page | none | moves between the top pages, wrapping round; clears the trail. With one page: nothing |
| Switch profile | the profile's id | goes to that profile's first page. Unknown id: nothing |
| Several things in a row | (uses `steps`) | steps run in order, a third of a second apart. Steps may nest to depth 4 |
| Nothing | none | nothing |

A shortcut (`KeyCombo`) holds keyCode, command, control, option, shift and keyName; it is recorded by pressing the keys. Its label is written as the Mac does: control, option, shift, command, key (for example ⌃⌥D).

## 7. Raycast
- A key holds the whole link, `raycast://extensions/<owner>/<extension>/<command>`.
- The list offers the commands of the Raycast extensions installed on this Mac (found by itself; 15 on the author's Mac, for example Notion, Spotify, CleanShot X, 1Password, Reminders) and 16 of Raycast's own (Clipboard History, AI Chat, window left and right half, Search Snippets, Search Quicklinks, Lock Screen and more).
- Any Raycast link can be pasted (in Raycast: select a command, Command-K, "Copy Deeplink"). Pasted text is tidied; text that is not a Raycast link is refused.
- Script command by its file name: `raycast://script-commands/<slug>`. AI command by its name: `raycast://ai-commands/<slug>`.
- Slug: lower case, accents removed, letters and digits joined by hyphens ("Fix Spelling and Grammar" becomes fix-spelling-and-grammar).
- "Run quietly" (`quiet`) runs the command without bringing Raycast forward.
- The first time a key runs a command Raycast asks once; choose "Always open command".
- Raycast has no outside door for quicklinks and snippets: use "Open a link" and "Type text".

## 8. Profiles and the automatic change
- A profile has a name, the apps it belongs to (bundle identifiers) and pages. A page is either a top page (`parent` empty) or a folder page opened by a folder key.
- Position (`DeckPosition`): profile, page, and the trail of pages to go back through.
- `Navigator.profile(forApp:)`: the first profile that lists the app; otherwise the default profile (`fallbackProfile`: the default, or the first profile when the default is gone).
- `Navigator.follow(app, previousApp, position)`, exactly:
  1. The position is first repaired (see below). With no usable position, the start of the default profile.
  2. If "Change profile with the app in front" is off, the position stays.
  3. `wanted` = the profile of the new app; `before` = the profile of the app before it.
  4. The deck changes only when `wanted` differs from `before` and also from the profile showing now. Then it goes to the first page of `wanted`. Otherwise it stays.
- Result: a profile picked by hand stays while moving between apps that share a profile, and changes when the user goes to an app with another profile. Any other app shows the default profile.
- `repair`: a position whose profile is gone goes to the start of the default profile; a page that is gone goes to the profile's first page; trail entries that no longer exist are dropped.
- `start`: the first top page of the profile asked for, else of the default profile.

## 9. Bringing over from Elgato
- At first start the app reads the keys from Elgato's app for the 15-key box: apps, links, shortcuts, typed text, music keys, folders, pages, several-things keys, and which app a profile belongs to.
- Left out: the Zoom profile, the two Final Cut profiles, and keys of kinds Deck Mate does not have (Elgato's own on-screen deck switch, plug-in keys). A folder left with nothing but its Back key is left out too, with the key that opened it (`Deck.droppingEmptyFolders`).
- Elgato's files are only read, never changed. Elgato's pictures are not taken over; every key is redrawn in the new look.
- "Bring over again" in Settings repeats it. It asks first; the current setup is kept as a safety copy.
- With nothing to bring over, the first setup (`Deck.starter`) is one profile "Default" with one empty page "Page 1".

## 10. The box
Not yet tried on the real box (see the warning at the top).
- Supported (vendor 0x0FD9): Stream Deck (2019) 0x006D; MK.2 0x0080 and 0x00A5; MK.2 Module 0x00B9 and 0x00E4. The first Stream Deck (2017, 0x0060) talks differently and is not driven yet.
- Plug in: the keys light up. Settings shows "Connected", the box's name, the serial number and a brightness slider (0 to 100, default 70).
- Elgato's own app must be quit while Deck Mate drives the box (only one can hold it). Settings warns when it runs and has "Quit Elgato's app".
- On quit the box goes back to the Elgato logo.
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
Three tabs: Settings (box, brightness, change profile with the app in front, the card "Keys on screen" (Show them, Hide after a key is pressed, Size), open at login, permissions, bring over again), How it works, What's new. The version, Quit and Done are at the bottom.

## 13. Storage
- One file: `~/Library/Application Support/AMS Deck Mate/deck.json`. Each save first keeps the previous file as a safety copy (the last 20) in `Backups` beside it.
- Nothing leaves the Mac.
- Decoding is tolerant: a missing or odd field gets its default, never an error.

| Object | Fields |
|---|---|
| Deck | version (1), profiles, defaultProfile (id), brightness (0 to 100, default 70), autoSwitch (default true), screenAtPointer (true or false, default false), screenHidesAfterKey (true or false, default false), screenSize ("small", "normal" or "large", default "normal"). A missing or odd value of the last three means the default |
| Profile | id, name, apps (bundle identifiers), pages |
| Page | id, name, parent (id of the page holding the folder key, or empty for a top page), keys (place 0 to 14 as the key; 0 top left, left to right, top to bottom) |
| Key | id, title, icon, action |
| Action | type, target, combo, steps (actions), quiet |
| Combo | keyCode, command, control, option, shift, keyName |

## 14. Tests
- Rule tests live in `Core` (moving around, Raycast links, box byte layouts, tolerant decoding, the keys on screen). 19 tests in all: 18 rule tests and the take-over test. Run: `cd Core && swift test`.

## 15. Build and install
1. `xcodegen generate`
2. `xcodebuild -scheme "AMS Deck Mate" -configuration Release -derivedDataPath build build`
3. Quit the app if it runs.
4. `ditto` the built app to `~/Applications`.
5. Open it.

## 16. Not in 0.2
- The first Stream Deck from 2017.
- Other box sizes (6 and 32 keys, XL, Mini, Plus, Neo, pedal).
- Dragging keys to move them.
- Elgato plug-ins.
- Driving the real box (first test planned for January 2027).
