# AMS Deck Mate

A small Mac menu bar app, version 0.11.1 (build 19). It drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

Each key can open an app, a link or a file, run a Raycast command, press a keyboard shortcut, type text, control music and sound, move to another page or page group, or do several things in a row. The keys change by themselves when another app comes to the front. A floating window on the screen shows the same 15 keys, so the keys also work with no box plugged in. The keys on screen can also work as a virtual deck: press Control-Option-D, the keys appear under the mouse pointer, click one and they are gone. Since 0.3 there is also Deck Mate for the iPhone (TestFlight): it shows the same 15 keys, follows the page group and page the Mac shows, and a tap on a key makes the Mac do it. It finds the Mac by itself on the same Wi-Fi (or with the Mac on the iPhone's hotspot). Since 0.4 the iPhone keys sit low near the thumb, swipe between pages, light up when pressed and say what ran. Since 0.5 (iPhone and iPad app, now 0.8, with settings for look, clock, touch and what shows) Deck Mate is also a proper iPad app, made for the iPad mini: it fills the whole screen in all four ways round, with larger keys that grow as far as the screen or window allows, low and centred. The keys on screen can be used from the keyboard (since 0.4.1 each key shows its letter while the keyboard is theirs), Set up keys can drag, copy, paste, duplicate, undo and redo (since 0.5 an "All pages" button shows every page of every page group as a small picture), and broken keys show red. At first start the keys from Elgato's app are brought over. Since 0.5 a key can have a second action on a long press (marked by a small white dot), a row of 5 favourites stays on every page on the iPhone and iPad, an iPhone or iPad can use its own keys instead of following the Mac, and the iPhone and iPad can show the Mac's battery, the app in front and a music strip (needs iPhone and iPad app 0.7). Since 0.6 (Mac) and 0.8 (iPad), an iPad held on its side also shows a navigation picture on the left: every page group with every page as a small picture, and a tap goes there.

Since 0.8 there are two more keys, "Last copied text" (pastes one of your last copied texts, kept only in memory) and "Recent file" (opens a file you opened lately); Settings can bring back an earlier safety copy of your setup, and a damaged keys file repairs itself from the newest readable copy. The link to the iPhone and iPad is now private (encrypted) and asks you to check a 4-digit number the first time, so the iPhone and iPad app 0.11 is needed with Mac 0.8.

Since 0.9 the Mac keeps a weekly copy of your keys in iCloud Drive (the newest 8), "Last copied text" has a fourth choice, "A list to pick from", and the iPhone and iPad app 0.12 shows a small lock beside the connection dot while the line is private. The code is public on GitHub and the rule tests run there by themselves at every change.

Since 0.10 there are six more kinds of key (Timer, Switch for dark mode or mute, Run an Apple Shortcut, List to pick from, Open app, Microphone light), a "Wait" step for chains, a Find a key search on the keys on screen (Space or /), a "Key use" list in Settings, and four ready-made page groups (Finder, Safari, Notion, Fusion).

Since 0.11 there are six more kinds of key: Next event, Weather, Due today (OmniFocus), Album cover (Spotify), Body Battery and Desk (puts app windows back in place). Five of them show a value in large words on the key.

## Look
Flat coloured tiles with white hand-drawn icons, one colour per kind of key: apps blue, links teal, Raycast red-orange, shortcuts purple, text amber, music green, moving around grey-blue.

## Note
0.1 was built while the box was away, so driving the real box is not yet tried. The first test is planned for January 2027.

## Build
1. `xcodegen generate`
2. `xcodebuild -scheme "AMS Deck Mate" -configuration Release -derivedDataPath build build`
3. Rule tests: `cd Core && swift test`

The installed app is at `~/Applications/AMS Deck Mate.app`. The written specification is `Docs/SPEC.md`.

## Folders
- `App/` the Mac app
- `Phone/` the iPhone and iPad app (Deck Mate 0.12; 0.5 added the iPad, 0.6 added settings)
- `Core/` the rules (moving around, Raycast links, how the box is spoken to, the link to the iPhone) and their tests
- `Docs/` the specification

The repository is public. It holds no personal data. Apart from the weekly iCloud Drive copy of your keys, nothing leaves the Mac, except that the Weather key asks Open-Meteo for a town's place and weather, and the Album cover key asks Spotify's open look-up for a cover by the song's name.
