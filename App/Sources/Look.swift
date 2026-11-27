import AppKit
import DeckMateCore
import SwiftUI

enum AppInfo {
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    static let bundleID = Bundle.main.bundleIdentifier ?? "com.schabbauer.AMSDeckMate"
}

/// The colours. A key is a flat coloured tile with a white drawing; the colour says what kind of key it is.
enum Palette {
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
        NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }

    /// The app's own colour: the calm indigo of its icon.
    static let brand = rgb(0.27, 0.33, 0.74)

    /// The tile of a key, the same by day and by night (the box has no night).
    static func tile(_ kind: KeyKind) -> NSColor {
        switch kind {
        case .app: return rgb(0.18, 0.44, 0.88)        // blue
        case .web: return rgb(0.08, 0.54, 0.48)        // teal
        case .raycast: return rgb(0.86, 0.22, 0.25)    // a clear red, like Raycast's own (his pick, 0.9.1; was red-orange)
        case .shortcut: return rgb(0.48, 0.37, 0.82)   // purple
        case .text: return rgb(0.62, 0.38, 0.04)       // amber (darker in 0.16: white words reach 5.0:1)
        case .media: return rgb(0.14, 0.52, 0.26)      // green (darker in 0.16: white words reach 4.7:1)
        case .move: return rgb(0.36, 0.42, 0.51)       // grey-blue
        case .empty: return rgb(0.07, 0.07, 0.08)
        }
    }

    /// A key that asks first, waiting for its second press (0.27): a clear red, "Sure?".
    static let waiting = rgb(0.80, 0.11, 0.14)

    /// The tile of this key: its own colour when it has one (0.24), else its kind's.
    static func tile(for key: DeckKey?) -> NSColor {
        if let own = key?.ownColour { return rgb(own.red, own.green, own.blue) }
        return tile(key?.action.kind ?? .empty)
    }

    static func kindName(_ kind: KeyKind) -> String {
        switch kind {
        case .app: return "Apps"
        case .web: return "Links"
        case .raycast: return "Raycast"
        case .shortcut: return "Shortcuts"
        case .text: return "Text"
        case .media: return "Music and sound"
        case .move: return "Moving around"
        case .empty: return "Empty"
        }
    }

    /// The colour of a part of the app, for its headings and marks; a lighter shade by night.
    static func part(_ part: String, _ scheme: ColorScheme) -> Color {
        let night = scheme == .dark
        switch part {
        case "raycast": return Color(nsColor: night ? rgb(1.00, 0.52, 0.52) : rgb(0.78, 0.17, 0.20))
        case "profiles": return Color(nsColor: night ? rgb(0.72, 0.64, 0.98) : rgb(0.43, 0.32, 0.78))
        case "box": return Color(nsColor: night ? rgb(0.36, 0.80, 0.72) : rgb(0.05, 0.48, 0.42))
        case "screen": return Color(nsColor: night ? rgb(0.47, 0.71, 1.00) : rgb(0.14, 0.40, 0.84))
        case "settings": return Color(nsColor: night ? rgb(0.45, 0.82, 0.55) : rgb(0.13, 0.52, 0.26))
        default: return Color(nsColor: night ? rgb(0.62, 0.68, 1.00) : brand)
        }
    }

    /// A full-colour fill for main buttons: readable with white words by day and by night.
    static func fill(_ part: String) -> Color {
        switch part {
        case "raycast": return Color(nsColor: tile(.raycast))
        case "profiles": return Color(nsColor: tile(.shortcut))
        case "box": return Color(nsColor: tile(.web))
        case "screen": return Color(nsColor: tile(.app))
        case "settings": return Color(nsColor: tile(.media))
        default: return Color(nsColor: brand)
        }
    }
}

/// A main button: always full colour with white words, also when the window is not in front.
struct MainButton: ButtonStyle {
    var part = "keys"

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Palette.fill(part).opacity(configuration.isPressed ? 0.75 : 1),
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

/// A quiet button beside a main one.
struct PlainButton: ButtonStyle {
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(configuration.isPressed ? 0.16 : 0.08),
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

/// The hand-drawn icons: the AMS Icon Library plus the ones drawn for this app, as SVG files in the app.
enum IconStore {
    private static let folder = Bundle.main.resourceURL?.appendingPathComponent("Icons")
    private static var cache: [String: NSImage] = [:]
    private static var titles: [String: String] = [:]

    /// Every icon by name: this app's own first, then the hand-drawn ones, then the marks.
    static let names: [String] = {
        guard let folder, let files = try? FileManager.default.contentsOfDirectory(atPath: folder.path) else { return [] }
        let all = files.filter { $0.hasSuffix(".svg") }.map { String($0.dropLast(4)) }
        func rank(_ name: String) -> Int {
            name.hasPrefix("deck-") ? 0 : name.hasPrefix("app-") ? 2 : name.hasPrefix("control-") ? 3 : 1
        }
        return all.sorted { (rank($0), $0) < (rank($1), $1) }
    }()

    private static func source(_ name: String) -> String? {
        guard let folder, !name.isEmpty else { return nil }
        return try? String(contentsOf: folder.appendingPathComponent(name + ".svg"), encoding: .utf8)
    }

    /// The drawing in one colour. It is a line drawing, so it stays sharp at any size.
    static func image(_ name: String, hex: String = "#FFFFFF") -> NSImage? {
        let key = name + hex
        if let hit = cache[key] { return hit }
        guard let svg = source(name)?.replacingOccurrences(of: "currentColor", with: hex),
              let image = NSImage(data: Data(svg.utf8)) else { return nil }
        cache[key] = image
        return image
    }

    /// What the drawing shows, in words (the title inside its file).
    static func title(_ name: String) -> String {
        if let hit = titles[name] { return hit }
        var title = name
        if let svg = source(name), let start = svg.range(of: "<title>"), let end = svg.range(of: "</title>") {
            title = String(svg[start.upperBound..<end.lowerBound])
        }
        titles[name] = title
        return title
    }
}

/// A drawing from the icon set in the colour of the words around it.
struct Mark: View {
    let name: String
    var size: CGFloat = 16
    var colour: Color?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        if let image = IconStore.image(name, hex: "#000000") {
            Image(nsImage: image)
                .resizable()
                .renderingMode(.template)
                .interpolation(.high)
                .frame(width: size, height: size)
                .foregroundStyle(colour ?? .primary)
        } else {
            Color.clear.frame(width: size, height: size)
        }
    }
}

/// The app's own mark: the deck, a rounded frame with six keys as dots.
enum DeckGlyph {
    static func path(in size: CGFloat) -> (frame: NSBezierPath, dots: NSBezierPath, line: CGFloat) {
        let k = size / 24
        let frame = NSBezierPath(roundedRect: NSRect(x: 3.5 * k, y: 6 * k, width: 17 * k, height: 12 * k),
                                 xRadius: 2.8 * k, yRadius: 2.8 * k)
        let dots = NSBezierPath()
        for y in [10.0, 14.0] {
            for x in [8.0, 12.0, 16.0] {
                dots.appendOval(in: NSRect(x: (x - 1.25) * k, y: (y - 1.25) * k, width: 2.5 * k, height: 2.5 * k))
            }
        }
        return (frame, dots, 1.9 * k)
    }

    /// For the menu bar: one colour, the Mac tints it black or white itself.
    static func menuBarImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 20, height: 18), flipped: false) { _ in
            let transform = NSAffineTransform()
            transform.translateX(by: 0, yBy: -1.5)
            transform.concat()
            let (frame, dots, line) = path(in: 20)
            NSColor.black.set()
            frame.lineWidth = line
            frame.stroke()
            dots.fill()
            return true
        }
        image.isTemplate = true
        return image
    }
}

/// The app's tile: indigo with the white deck, for headers.
struct AppTile: View {
    var size: CGFloat = 26

    var body: some View {
        Canvas { context, canvas in
            let k = canvas.width / 24
            context.fill(Path(roundedRect: CGRect(origin: .zero, size: canvas), cornerRadius: canvas.width * 0.23, style: .continuous),
                         with: .color(Color(nsColor: Palette.brand)))
            let inset = canvas.width * 0.11
            let scale = (canvas.width - inset * 2) / 24
            var frame = Path(roundedRect: CGRect(x: 3.5, y: 6, width: 17, height: 12), cornerRadius: 2.8)
            for y in [10.0, 14.0] {
                for x in [8.0, 12.0, 16.0] {
                    frame.addEllipse(in: CGRect(x: x - 0.6, y: y - 0.6, width: 1.2, height: 1.2))
                }
            }
            let placed = frame.applying(CGAffineTransform(translationX: inset, y: inset).scaledBy(x: scale, y: scale))
            context.stroke(placed, with: .color(.white), style: StrokeStyle(lineWidth: 1.9 * scale, lineCap: .round, lineJoin: .round))
            _ = k
        }
        .frame(width: size, height: size)
    }
}
