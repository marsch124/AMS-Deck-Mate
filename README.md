# AMS Deck Mate

A small Mac menu bar app, version 0.4.1 (build 5). It drives a Stream Deck box with 15 keys straight over its cable, without Elgato's app and without a subscription.

Each key can open an app, a link or a file, run a Raycast command, press a keyboard shortcut, type text, control music and sound, move to another page or profile, or do several things in a row. The keys change by themselves when another app comes to the front. A floating window on the screen shows the same 15 keys, so the keys also work with no box plugged in. The keys on screen can also work as a virtual deck: press Control-Option-D, the keys appear under the mouse pointer, click one and they are gone. Since 0.3 there is also Deck Mate for the iPhone (TestFlight): it shows the same 15 keys, follows the profile and page the Mac shows, and a tap on a key makes the Mac do it. It finds the Mac by itself on the same Wi-Fi (or with the Mac on the iPhone's hotspot). Since 0.4 the iPhone keys sit low near the thumb, swipe between pages, light up when pressed and say what ran. Since 0.5 (iPhone and iPad app) Deck Mate is also a proper iPad app, made for the iPad mini: it fills the whole screen in all four ways round, with larger keys low and centred. The keys on screen can be used from the keyboard (since 0.4.1 each key shows its letter while the keyboard is theirs), Set up keys can drag, copy, paste, duplicate, undo and redo, and broken keys show red. At first start the keys from Elgato's app are brought over.

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
- `Phone/` the iPhone and iPad app (Deck Mate, 0.5 adds the iPad)
- `Core/` the rules (moving around, Raycast links, how the box is spoken to, the link to the iPhone) and their tests
- `Docs/` the specification

The repository is private. Nothing leaves the Mac.
