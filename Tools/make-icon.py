#!/usr/bin/env python3
"""Builds the AMS Deck Mate app icon: a flat calm indigo tile with the white hand-drawn deck
(a rounded frame with six keys as dots).

It writes three things from the same numbers:

  App/Resources/AppIcon.icon   the layered icon (Apple's Icon Composer format), every glass effect off.
                               This is what macOS 26 and later show.
  App/Resources/AppIcon.icns   the loose picture file: the same drawing on Apple's tile shape.
  Docs/icon-1024.png           the same picture as a PNG, for the docs.

Run:  python3 Tools/make-icon.py        (needs Pillow and the Mac's own iconutil)
"""
import json, os, shutil, subprocess, tempfile
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---- the design (the same numbers as DeckGlyph in App/Sources/Look.swift) ----
TILE_COLOUR = (0.27, 0.33, 0.74)
WHITE = (1.0, 1.0, 1.0)
GLYPH = 0.78                  # the 24-unit drawing grid takes this share of the tile's width
STROKE = 1.9
STROKE_SMALL = 2.5            # heavier line for the small pictures (64 px and below)
FRAME = (3.5, 6.0, 20.5, 18.0)
CORNER = 2.8
DOTS = [(x, y) for y in (10.0, 14.0) for x in (8.0, 12.0, 16.0)]
DOT = 1.25

CANVAS = 1024
TILE = 824
RADIUS = 185.4


def rgb8(c):
    return tuple(round(v * 255) for v in c) + (255,)


def colour(c):
    return "srgb:" + ",".join(f"{v:.5f}" for v in c) + ",1.00000"


def glyph_svg(size, stroke):
    """The deck as filled shapes (Icon Composer colours a layer by filling it)."""
    k = size * GLYPH / 24.0
    o = size / 2 - 12 * k
    h = stroke / 2
    x0, y0, x1, y1 = FRAME

    def rect(inset, radius):
        return (f'M{o + (x0 + inset + radius) * k:.2f} {o + (y0 + inset) * k:.2f} '
                f'H{o + (x1 - inset - radius) * k:.2f} A{radius * k:.2f} {radius * k:.2f} 0 0 1 {o + (x1 - inset) * k:.2f} {o + (y0 + inset + radius) * k:.2f} '
                f'V{o + (y1 - inset - radius) * k:.2f} A{radius * k:.2f} {radius * k:.2f} 0 0 1 {o + (x1 - inset - radius) * k:.2f} {o + (y1 - inset) * k:.2f} '
                f'H{o + (x0 + inset + radius) * k:.2f} A{radius * k:.2f} {radius * k:.2f} 0 0 1 {o + (x0 + inset) * k:.2f} {o + (y1 - inset - radius) * k:.2f} '
                f'V{o + (y0 + inset + radius) * k:.2f} A{radius * k:.2f} {radius * k:.2f} 0 0 1 {o + (x0 + inset + radius) * k:.2f} {o + (y0 + inset) * k:.2f} Z')

    ring = rect(-h, CORNER + h) + " " + rect(h, CORNER - h)
    dots = "".join(f'<circle cx="{o + x * k:.2f}" cy="{o + y * k:.2f}" r="{DOT * k:.2f}" fill="#FFFFFF"/>' for x, y in DOTS)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">'
            f'<path d="{ring}" fill="#FFFFFF" fill-rule="evenodd"/>{dots}</svg>\n')


def write_layered_icon(folder):
    shutil.rmtree(folder, ignore_errors=True)
    os.makedirs(os.path.join(folder, "Assets"))
    with open(os.path.join(folder, "Assets", "deck.svg"), "w") as f:
        f.write(glyph_svg(CANVAS, STROKE))

    def same_by_day_and_night(c):
        return [{"value": {"solid": colour(c)}}, {"appearance": "dark", "value": {"solid": colour(c)}}]

    doc = {
        "fill-specializations": same_by_day_and_night(TILE_COLOUR),
        "groups": [{
            "layers": [{"fill-specializations": same_by_day_and_night(WHITE), "glass": False,
                        "image-name": "deck.svg", "name": "Deck"}],
            "name": "Deck", "blur-material": None, "lighting": "individual",
            "shadow": {"kind": "none", "opacity": 0}, "specular": False,
            "translucency": {"enabled": False, "value": 0},
        }],
        "supported-platforms": {"squares": ["macOS"]},
    }
    with open(os.path.join(folder, "icon.json"), "w") as f:
        json.dump(doc, f, indent=2)
        f.write("\n")


def apple_tile(size, tile, radius, steps=48):
    """Apple's continuous-corner rounded square as a list of points."""
    x0 = y0 = (size - tile) / 2
    x1 = y1 = x0 + tile
    r = radius

    def bez(p0, p1, p2, p3):
        out = []
        for i in range(1, steps + 1):
            t = i / steps
            a, b, c, d = (1 - t) ** 3, 3 * (1 - t) ** 2 * t, 3 * (1 - t) * t * t, t ** 3
            out.append((a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0], a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1]))
        return out

    corner = [(1.528665, 0), (1.088493, 0), (0.868407, 0), (0.631494, 0.074911),
              (0.372824, 0.169060), (0.169060, 0.372824), (0.074911, 0.631494),
              (0, 0.868407), (0, 1.088493), (0, 1.528665)]
    pts = []
    for (cx, cy), (ax, ay), (bx, by) in (((x1, y0), (-1, 0), (0, 1)), ((x1, y1), (0, -1), (-1, 0)),
                                         ((x0, y1), (1, 0), (0, -1)), ((x0, y0), (0, 1), (1, 0))):
        p = [(cx + ax * u * r + bx * v * r, cy + ay * u * r + by * v * r) for u, v in corner]
        pts.append(p[0])
        pts += bez(p[0], p[1], p[2], p[3]) + bez(p[3], p[4], p[5], p[6]) + bez(p[6], p[7], p[8], p[9])
    return pts


def render_flat(stroke, ss=4):
    s = CANVAS * ss
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).polygon([(x * ss, y * ss) for x, y in apple_tile(CANVAS, TILE, RADIUS)], fill=255)
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    img.paste(Image.new("RGBA", (s, s), rgb8(TILE_COLOUR)), (0, 0), mask)
    d = ImageDraw.Draw(img)
    k = TILE * GLYPH * ss / 24
    o = s / 2 - 12 * k
    x0, y0, x1, y1 = FRAME
    d.rounded_rectangle([o + x0 * k, o + y0 * k, o + x1 * k, o + y1 * k], radius=CORNER * k,
                        outline=rgb8(WHITE), width=round(stroke * k))
    for x, y in DOTS:
        r = DOT * k * (stroke / STROKE)
        d.ellipse([o + x * k - r, o + y * k - r, o + x * k + r, o + y * k + r], fill=rgb8(WHITE))
    return img.convert("RGBa")


def shrink(master, px):
    return master.reduce(master.width // px).convert("RGBA")


def write_icns(path, img, heavy):
    tmp = tempfile.mkdtemp()
    iconset = os.path.join(tmp, "AppIcon.iconset")
    os.makedirs(iconset)
    for base in (16, 32, 128, 256, 512):
        for mult, suffix in ((1, ""), (2, "@2x")):
            px = base * mult
            shrink(heavy if px <= 64 else img, px).save(os.path.join(iconset, f"icon_{base}x{base}{suffix}.png"))
    subprocess.run(["iconutil", "-c", "icns", iconset, "-o", path], check=True)
    shutil.rmtree(tmp)


if __name__ == "__main__":
    os.makedirs(os.path.join(ROOT, "Docs"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "App", "Resources"), exist_ok=True)
    write_layered_icon(os.path.join(ROOT, "App", "Resources", "AppIcon.icon"))
    img = render_flat(STROKE)
    shrink(img, CANVAS).save(os.path.join(ROOT, "Docs", "icon-1024.png"))
    write_icns(os.path.join(ROOT, "App", "Resources", "AppIcon.icns"), img, render_flat(STROKE_SMALL))
    print("ok")
