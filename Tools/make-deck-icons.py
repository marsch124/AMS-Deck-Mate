#!/usr/bin/env python3
"""The 24 icons drawn for AMS Deck Mate, in the AMS style: a 24-point grid, one 1.9 stroke with
round ends, no fill. Written as SVG files next to the copy of the AMS Icon Library in
App/Resources/Icons (names start with "deck-").

Run:  python3 Tools/make-deck-icons.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "App", "Resources", "Icons")

SPEAKER = "M4 9.8h3.2l4.3-3.6v11.6l-4.3-3.6H4z"
WINDOW = "M4.5 5.5h15a1.5 1.5 0 0 1 1.5 1.5v10a1.5 1.5 0 0 1 -1.5 1.5h-15a1.5 1.5 0 0 1 -1.5-1.5v-10a1.5 1.5 0 0 1 1.5-1.5z"

ICONS = {
    "raycast": ("Raycast", "M4.5 19.5 19.5 4.5 M4.5 12 12 4.5 M12 19.5 19.5 12"),
    "keyboard": ("Keyboard shortcut", "M4.5 6.5h15a1.5 1.5 0 0 1 1.5 1.5v8a1.5 1.5 0 0 1 -1.5 1.5h-15a1.5 1.5 0 0 1 -1.5-1.5v-8a1.5 1.5 0 0 1 1.5-1.5z M7 10.2h.01 M10.3 10.2h.01 M13.7 10.2h.01 M17 10.2h.01 M8.5 14h7"),
    "text": ("Type text", "M4.5 18 9 6l4.5 12 M6.2 14h5.6 M16.5 10.5h3 M16.5 14.2h3 M16.5 18h3"),
    "play": ("Play or pause", "M5.5 6.5v11l8-5.5z M16.5 7v10 M19.5 7v10"),
    "next": ("Next track", "M5.5 6.5v11l8.5-5.5z M18 6.5v11"),
    "previous": ("Previous track", "M18.5 6.5v11l-8.5-5.5z M6 6.5v11"),
    "volume-up": ("Volume up", SPEAKER + " M15 9.5a3.6 3.6 0 0 1 0 5 M17.6 7a7.2 7.2 0 0 1 0 10"),
    "volume-down": ("Volume down", SPEAKER + " M15 9.5a3.6 3.6 0 0 1 0 5"),
    "mute": ("Mute sound", SPEAKER + " M15.5 9.5l5 5 M20.5 9.5l-5 5"),
    "folder": ("Folder of keys", "M3.5 7.5a1.5 1.5 0 0 1 1.5-1.5h4l2 2.2h8a1.5 1.5 0 0 1 1.5 1.5v7.8a1.5 1.5 0 0 1 -1.5 1.5h-14a1.5 1.5 0 0 1 -1.5-1.5z M8.5 13.6h.01 M12 13.6h.01 M15.5 13.6h.01"),
    "back": ("Back", "M9 14.5 4.5 10 9 5.5 M4.5 10h10a5 5 0 0 1 0 10h-3"),
    "page-next": ("Next page", "M4.5 12h.01 M8.5 12h.01 M13 6.5l5.5 5.5-5.5 5.5"),
    "page-previous": ("Previous page", "M19.5 12h-.01 M15.5 12h-.01 M11 6.5 5.5 12l5.5 5.5"),
    "profile": ("Profile", "M12 4.5 20 9l-8 4.5L4 9z M4.5 12.8 12 17l7.5-4.2 M4.5 16.3 12 20.5l7.5-4.2"),
    "multi": ("Several things in a row", "M4.5 6h5v4h-5z M14.5 14h5v4h-5z M9.5 8h4a1.5 1.5 0 0 1 1.5 1.5v2"),
    "script": ("Script", WINDOW + " M7 9.5l3 2.5-3 2.5 M12.5 14.8h4.5"),
    "clipboard": ("Clipboard", "M8.5 5.5h-2a1.5 1.5 0 0 0 -1.5 1.5v12a1.5 1.5 0 0 0 1.5 1.5h11a1.5 1.5 0 0 0 1.5-1.5v-12a1.5 1.5 0 0 0 -1.5-1.5h-2 M9 4h6v3.2h-6z M8.5 12h7 M8.5 15.8h4.5"),
    "window-left": ("Window left half", WINDOW + " M12 5.5v13 M5.8 9h3.4 M5.8 12h3.4 M5.8 15h3.4"),
    "window-right": ("Window right half", WINDOW + " M12 5.5v13 M14.8 9h3.4 M14.8 12h3.4 M14.8 15h3.4"),
    "window-full": ("Window full size", WINDOW + " M6.5 12V9.5H9 M17.5 12v2.5H15"),
    "window-top": ("Window top half", WINDOW + " M3 12h18 M6.5 8.75h11"),
    "window-bottom": ("Window bottom half", WINDOW + " M3 12h18 M6.5 15.25h11"),
    "eject": ("Eject", "M12 5l7.5 9h-15z M4.5 18.5h15"),
    "video": ("Join video meeting", "M5 6.5h8a2 2 0 0 1 2 2v7a2 2 0 0 1 -2 2h-8a2 2 0 0 1 -2-2v-7a2 2 0 0 1 2-2z M15 10.5l5.5-3v9l-5.5-3"),
    "ai": ("AI", "M11 4.5c.6 3.8 2.2 5.4 6 6-3.8.6-5.4 2.2-6 6-.6-3.8-2.2-5.4-6-6 3.8-.6 5.4-2.2 6-6z M18 15.5v4 M16 17.5h4"),
    "app": ("App", "M6.5 4.5h11a2 2 0 0 1 2 2v11a2 2 0 0 1 -2 2h-11a2 2 0 0 1 -2-2v-11a2 2 0 0 1 2-2z M9 9h.01 M15 9h.01 M9 15h.01 M15 15h.01"),
}

SVG = ('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" '
       'stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">\n'
       '  <title>{title}</title>\n  <path d="{path}"/>\n</svg>\n')

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for key, (title, path) in ICONS.items():
        with open(os.path.join(OUT, f"deck-{key}.svg"), "w") as f:
            f.write(SVG.format(title=title, path=path))
    print(len(ICONS), "icons")
