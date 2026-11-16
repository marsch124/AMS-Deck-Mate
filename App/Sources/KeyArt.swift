import AppKit
import DeckMateCore

/// Draws a key: a flat coloured tile, a white drawing, a short title. The same picture goes to the
/// screen and to the box, so what he sees on the Mac is what the box shows.
enum KeyArt {
    private static var appIcons: [String: NSImage] = [:]
    private static var pictures: [String: CGImage] = [:]
    private static var phonePictures: [String: Data] = [:]

    /// The app a key opens, as a file on this Mac.
    static func appURL(_ target: String) -> URL? {
        if target.hasPrefix("/") { return URL(fileURLWithPath: target) }
        if target.isEmpty { return nil }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: target)
    }

    static func appName(_ target: String) -> String {
        guard let url = appURL(target) else { return target.isEmpty ? "" : target }
        return FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
    }

    private static func appIcon(_ target: String) -> NSImage? {
        if let hit = appIcons[target] { return hit }
        guard let url = appURL(target), FileManager.default.fileExists(atPath: url.path) else { return nil }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        appIcons[target] = icon
        return icon
    }

    /// The words on a key: its own, or the app's name for an app key without words.
    static func title(_ key: DeckKey?) -> String {
        key?.shownTitle(appName: { appURL($0) == nil ? "" : appName($0) }) ?? ""
    }

    /// The key as a picture of `pixels` x `pixels`. nil = an empty place.
    static func image(for key: DeckKey?, pixels: Int) -> CGImage? {
        let cacheKey = "\(pixels)|\(title(key))|\(key?.shownIcon ?? "")|\(key?.action.hashValue ?? 0)"
        if let hit = pictures[cacheKey] { return hit }
        let size = CGFloat(pixels)
        guard let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        let kind = key?.action.kind ?? .empty
        context.setFillColor(Palette.tile(kind).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))
        if let key {
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
            draw(key, size: size)
            NSGraphicsContext.restoreGraphicsState()
        }
        let picture = context.makeImage()
        if pictures.count > 600 { pictures.removeAll() }
        pictures[cacheKey] = picture
        return picture
    }

    private static func draw(_ key: DeckKey, size: CGFloat) {
        let k = size / 72
        let title = Self.title(key)
        let hasTitle = !title.isEmpty
        let iconName = key.shownIcon
        // The drawing sits a little above the middle when there is a title under it.
        let iconSide = (hasTitle ? 34 : 44) * k
        let iconMid = CGPoint(x: size / 2, y: hasTitle ? size - 27 * k : size / 2)
        let iconRect = CGRect(x: iconMid.x - iconSide / 2, y: iconMid.y - iconSide / 2, width: iconSide, height: iconSide)

        if key.icon.isEmpty, key.action.type == .raycast, let icon = RaycastIcons.image(forLink: key.action.target) {
            // An extension command shows its extension's own icon on a light round tile, so dark icons read too.
            let tile = iconRect.insetBy(dx: -2 * k, dy: -2 * k)
            NSColor.white.withAlphaComponent(0.92).setFill()
            NSBezierPath(roundedRect: tile, xRadius: 9 * k, yRadius: 9 * k).fill()
            icon.draw(in: tile.insetBy(dx: 4 * k, dy: 4 * k), from: .zero, operation: .sourceOver, fraction: 1)
        } else if !iconName.isEmpty, let icon = IconStore.image(iconName) {
            icon.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1)
        } else if key.action.type == .app, let icon = appIcon(key.action.target) {
            let grown = iconRect.insetBy(dx: -4 * k, dy: -4 * k)
            icon.draw(in: grown, from: .zero, operation: .sourceOver, fraction: 1)
        } else if key.action.type == .app, let icon = IconStore.image("deck-app") {
            icon.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1)
        }

        guard hasTitle else { return }
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byTruncatingTail
        style.maximumLineHeight = 11.5 * k
        var fontSize = 10.5 * k
        var attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: NSColor.white,
            .paragraphStyle: style,
        ]
        let width = size - 6 * k
        // One line when it fits; a little smaller when it nearly fits; otherwise two lines.
        var oneLine = (title as NSString).size(withAttributes: attributes).width
        if oneLine > width, oneLine <= width * 1.15 {
            fontSize = 9.5 * k
            attributes[.font] = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
            oneLine = (title as NSString).size(withAttributes: attributes).width
        }
        let lines: CGFloat = oneLine > width && title.contains(" ") ? 2 : 1
        if lines == 2 { style.lineBreakMode = .byWordWrapping }
        let height = lines * 11.5 * k + 2 * k
        let bottom = lines == 2 ? 3 * k : 8 * k
        (title as NSString).draw(with: CGRect(x: 3 * k, y: bottom, width: width, height: height),
                                 options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                                 attributes: attributes)
    }

    /// The key for the box: 72 x 72, turned upside down (the box wants it flipped both ways), as a JPEG.
    static func jpegForBox(_ key: DeckKey?) -> Data? {
        let pixels = StreamDeckProtocol.keyPixels
        guard let picture = image(for: key, pixels: pixels),
              let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        context.translateBy(x: CGFloat(pixels), y: CGFloat(pixels))
        context.rotate(by: .pi)
        context.draw(picture, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
        guard let turned = context.makeImage() else { return nil }
        return NSBitmapImageRep(cgImage: turned).representation(using: .jpeg, properties: [.compressionFactor: 0.92])
    }

    /// The key as a PNG picture of 216 x 216, for the iPhone. nil = an empty place.
    static func pngForPhone(_ key: DeckKey?) -> Data? {
        guard let key, let picture = image(for: key, pixels: 216) else { return nil }
        let cacheKey = "\(title(key))|\(key.shownIcon)|\(key.action.hashValue)"
        if let hit = phonePictures[cacheKey] { return hit }
        let png = NSBitmapImageRep(cgImage: picture).representation(using: .png, properties: [:])
        if phonePictures.count > 300 { phonePictures.removeAll() }
        phonePictures[cacheKey] = png
        return png
    }

    static func forgetAppIcons() {
        appIcons.removeAll()
        pictures.removeAll()
        phonePictures.removeAll()
    }
}

/// The icons of the installed Raycast extensions: a command's own icon, else its extension's.
/// Raycast keeps each extension in a folder with a made-up name; package.json says which it is.
enum RaycastIcons {
    private struct Entry {
        var folder: URL
        var icon: String
        var commands: [String: String]
    }

    private static var index: [String: Entry]?
    private static var images: [String: NSImage] = [:]

    private static func load() -> [String: Entry] {
        if let index { return index }
        var found: [String: Entry] = [:]
        let files = FileManager.default
        let root = RaycastCatalog.extensionsFolder
        for name in (try? files.contentsOfDirectory(atPath: root.path)) ?? [] {
            let folder = root.appendingPathComponent(name)
            guard let data = try? Data(contentsOf: folder.appendingPathComponent("package.json")),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let ext = json["name"] as? String else { continue }
            var commands: [String: String] = [:]
            for entry in (json["commands"] as? [[String: Any]]) ?? [] {
                if let command = entry["name"] as? String, let icon = entry["icon"] as? String { commands[command] = icon }
            }
            let entry = Entry(folder: folder, icon: json["icon"] as? String ?? "", commands: commands)
            // Links name the owner when there is one, else the author: both find it.
            for owner in [json["owner"] as? String, json["author"] as? String].compactMap({ $0 }) where !owner.isEmpty {
                found["\(owner)/\(ext)".lowercased()] = entry
            }
        }
        index = found
        return found
    }

    static func installed(owner: String, extensionName: String) -> Bool {
        load()["\(owner)/\(extensionName)".lowercased()] != nil
    }

    static func image(forLink link: String) -> NSImage? {
        guard let parts = RaycastLink.parts(link),
              let entry = load()["\(parts.owner)/\(parts.extensionName)".lowercased()] else { return nil }
        let name = entry.commands[parts.command] ?? entry.icon
        guard !name.isEmpty else { return nil }
        let file = entry.folder.appendingPathComponent("assets").appendingPathComponent(name)
        if let hit = images[file.path] { return hit }
        guard let image = NSImage(contentsOf: file) else { return nil }
        images[file.path] = image
        return image
    }

    /// After extensions were added or removed in Raycast.
    static func forget() {
        index = nil
        images.removeAll()
    }
}
