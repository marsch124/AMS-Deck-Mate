# AMS Deck Mate, specification, version 0.3 (build 3), 16 Nov 2026

A Mac menu bar app that drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

**Warning.** 0.1 was built while the box was away. Driving the real box is not yet tried. The first real test is planned for January 2027. The keys on screen, the rules and the setup do not need the box.

## 1. Purpose
- Give the 15-key Stream Deck (2019) and MK.2 their keys without Elgato's app.
- Mac app: menu bar only, no Dock icon. The version shows in Settings.
- Since 0.3 also an iPhone app that shows and presses the same keys (section 17).

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
- An app key with an empty title shows the app's name (`DeckKey.shownTitle(appName:)`, see section 18). Own words always win.
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
Three tabs: Settings (box, brightness, change profile with the app in front, the card "Keys on screen" (Show them, Hide after a key is pressed, Size), the card "iPhone" (section 17), open at login, permissions, bring over again), How it works, What's new. The version, Quit and Done are at the bottom.

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
- Rule tests live in `Core` (moving around, Raycast links, box byte layouts, tolerant decoding, the keys on screen). Run: `cd Core && swift test`.
- New in 0.3: `PhoneLink` framing: round trip (encode then decode gives the same message), split (a message arriving in pieces is put together; a half message waits), broken (a length over 4 MB or text that is not a message is refused, not crashed on). And `shownTitle`: own title wins; empty title on an app key gives the app's name; empty title and no app name stays empty; other kinds are unchanged.
- The iPhone app has one screen test that finds its keys by identifier.

## 15. Build and install
1. `xcodegen generate`
2. `xcodebuild -scheme "AMS Deck Mate" -configuration Release -derivedDataPath build build`
3. Quit the app if it runs.
4. `ditto` the built app to `~/Applications`.
5. Open it.

## 16. Not in 0.3
- The first Stream Deck from 2017.
- Other box sizes (6 and 32 keys, XL, Mini, Plus, Neo, pedal).
- Dragging keys to move them.
- Elgato plug-ins.
- Driving the real box (first test planned for January 2027).
- The iPhone app on iPad or Mac, and editing keys from the iPhone (keys are set up on the Mac only).

## 17. The iPhone link (0.3)
**What it is.** Deck Mate on the iPhone shows the same 15 keys as the box, in the same places and with the same pictures. It follows the profile and page the Mac shows (so it changes with the app in front). A tap on a key makes the Mac do it.

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
- `keys(place, keys[index, title, PNG])`: `place` is the position (the line on top of the keys, as the Mac shows it: the profile's name, plus " · " and the page's name when the profile has more than one page (e.g. "OmniFocus · Page 2") as shown on the Mac); each key has its place 0 to 14, the title shown (see `shownTitle`) and its picture as PNG, drawn by the Mac (so app keys have the real app icon). The Mac sends `keys` first when the iPhone is allowed, then again whenever the position or the setup changes.
- `press(index)`: the iPhone tapped a key.

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
- Bundle id `com.schabbauer.AMSDeckMatePhone`; display name "Deck Mate"; iOS 17 and later; iPhone only; on TestFlight. Version 0.3 (3). Source in `Phone/`; its guide is `Phone/Sources/PhoneGuide.swift`, the same shape as `App/Sources/Guide.swift`.
- Shows the 15 keys (5 columns, 3 rows) upright and sideways. Keeps the screen on while connected.
- States: "Looking for your Mac…", waiting for the Mac's answer, connected (keys), refused ("Ask again").
- Settings: which Mac, "Forget this Mac", the version, How it works, What's new.

## 18. App names on keys (0.3)
- `DeckKey.shownTitle(appName:)`: the title if it is not empty; otherwise, for an app key, the app's name (as the Mac knows it from the bundle or path); otherwise empty. Other kinds are unchanged.
- Used by the box, the Mac screen and the iPhone, so the Apps folder's keys now read Mail, Safari, Calculator and so on.

## 19. The Raycast folder (the author's own setup, data)
- On Page 1 of the Default Profile, a key "Raycast" opens a folder: Back plus 14 Raycast commands from the installed extensions: Clipboard, AI Chat, Ask Perplexity, Hide apps, New reminder, Reminders, Notion note, Find in Notion, Daily plan (NotePlan), Screenshot (CleanShot area), Text from screen (CleanShot OCR), Play/Pause and Next song (Spotify), Passwords (1Password).
- Keys that need no window run quietly (`quiet`). Changed in Set up keys as usual. This is data in `deck.json`, not a feature.
