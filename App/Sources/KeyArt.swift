import AppKit
import DeckMateCore

/// Draws a key: a flat coloured tile, a white drawing, a short title. The same picture goes to the
/// screen and to the box, so what he sees on the Mac is what the box shows.
enum KeyArt {
    private static var appIcons: [String: NSImage] = [:]
    private static var pictures: [String: CGImage] = [:]
    private static var phonePictures: [String: Data] = [:]
    private static var ownPictures: [String: NSImage] = [:]

    private static var covers: [String: NSImage] = [:]

    /// The album cover of a track, when it has been fetched. Kept in memory only.
    static func cover(_ track: String) -> NSImage? { covers[track] }

    static func keep(cover: NSImage, for track: String) {
        if covers.count >= 60 { covers.removeAll() }
        covers[track] = cover
    }

    /// Where the pictures of keys with a picture of their own are kept (the setup's Pictures folder).
    static var picturesFolder: URL?

    /// A key's own picture by its name; nil when the file is not there.
    private static func ownPicture(_ name: String) -> NSImage? {
        if let hit = ownPictures[name] { return hit }
        guard let url = picturesFolder?.appendingPathComponent(name + ".png"),
              let picture = NSImage(contentsOf: url), picture.isValid else { return nil }
        ownPictures[name] = picture
        return picture
    }

    /// Where an app was found and what it is called, kept so the Mac's list of apps is not asked on
    /// every drawing. Forgotten when an app is opened or quit (and so after an install, which is opened).
    private static var foundApps: [String: URL?] = [:]
    private static var foundNames: [String: String] = [:]
    private static let watchApps: [NSObjectProtocol] = [NSWorkspace.didLaunchApplicationNotification,
                                                        NSWorkspace.didTerminateApplicationNotification].map { name in
        NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main) { _ in
            foundApps.removeAll()
            foundNames.removeAll()
        }
    }

    /// The app a key opens, as a file on this Mac.
    static func appURL(_ target: String) -> URL? {
        if target.hasPrefix("/") { return URL(fileURLWithPath: target) }
        if target.isEmpty { return nil }
        _ = watchApps
        if let hit = foundApps[target] { return hit }
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: target)
        if foundApps.count > 400 { foundApps.removeAll() }
        foundApps[target] = .some(url)
        return url
    }

    static func appName(_ target: String) -> String {
        guard let url = appURL(target) else { return target.isEmpty ? "" : target }
        if let hit = foundNames[target] { return hit }
        let name = FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
        if foundNames.count > 400 { foundNames.removeAll() }
        foundNames[target] = name
        return name
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
        let cacheKey = "\(pixels)|\(title(key))|\(key?.shownIcon ?? "")|\(key?.action.hashValue ?? 0)|\(key?.hasHeld ?? false)|\(key?.hasTwice ?? false)"
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
            if let track = GlanceKeys.coverTrack(key.icon), let picture = cover(track) {
                drawCover(key, picture, size: size)
            } else {
                draw(key, size: size)
            }
            if key.action.type == .toggle {
                // A small switch top left: filled with its knob to the right when on, an outline when off.
                let k = size / 72
                let pill = CGRect(x: 6 * k, y: size - 16 * k, width: 17 * k, height: 10 * k)
                let path = NSBezierPath(roundedRect: pill, xRadius: 5 * k, yRadius: 5 * k)
                let knob = CGRect(x: key.action.quiet ? pill.maxX - 8.5 * k : pill.minX + 1.5 * k, y: pill.minY + 1.5 * k,
                                  width: 7 * k, height: 7 * k)
                if key.action.quiet {
                    NSColor.white.setFill()
                    path.fill()
                    Palette.tile(kind).setFill()
                } else {
                    NSColor.white.withAlphaComponent(0.9).setStroke()
                    path.lineWidth = 1.4 * k
                    NSBezierPath(roundedRect: pill.insetBy(dx: 0.7 * k, dy: 0.7 * k), xRadius: 4.3 * k, yRadius: 4.3 * k).stroke()
                    NSColor.white.withAlphaComponent(0.9).setFill()
                }
                NSBezierPath(ovalIn: knob).fill()
            }
            if key.hasHeld {
                // A small white dot top right: this key does something else on a long press.
                let k = size / 72
                NSColor.white.withAlphaComponent(0.95).setFill()
                NSBezierPath(ovalIn: CGRect(x: size - 13 * k, y: size - 13 * k, width: 7 * k, height: 7 * k)).fill()
            }
            if key.hasTwice {
                // A small white "×2" top right, left of the long-press dot's place: this key does something else on a double press.
                let k = size / 72
                let words = NSAttributedString(string: "×2", attributes: [
                    .font: NSFont.systemFont(ofSize: 11 * k, weight: .bold),
                    .foregroundColor: NSColor.white.withAlphaComponent(0.95)])
                let box = words.size()
                words.draw(at: CGPoint(x: size - 16 * k - box.width, y: size - 9.5 * k - box.height / 2))
            }
            NSGraphicsContext.restoreGraphicsState()
        }
        let picture = context.makeImage()
        if pictures.count > 600 { pictures.removeAll() }
        pictures[cacheKey] = picture
        return picture
    }

    /// An album cover fills the whole key; the song's name stands on a dark band at the bottom.
    /// A paused song's cover is a little darker.
    private static func drawCover(_ key: DeckKey, _ picture: NSImage, size: CGFloat) {
        let k = size / 72
        let whole = CGRect(x: 0, y: 0, width: size, height: size)
        NSGraphicsContext.current?.imageInterpolation = .high
        picture.draw(in: whole, from: .zero, operation: .sourceOver, fraction: 1)
        if !key.action.quiet {
            NSColor.black.withAlphaComponent(0.35).setFill()
            whole.fill(using: .sourceOver)
        }
        let title = Self.title(key)
        guard !title.isEmpty else { return }
        NSColor.black.withAlphaComponent(0.6).setFill()
        CGRect(x: 0, y: 0, width: size, height: 19 * k).fill(using: .sourceOver)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byTruncatingTail
        (title as NSString).draw(with: CGRect(x: 3 * k, y: 3.5 * k, width: size - 6 * k, height: 12.5 * k),
                                 options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                                 attributes: [.font: NSFont.systemFont(ofSize: 9.5 * k, weight: .semibold),
                                              .foregroundColor: NSColor.white, .paragraphStyle: style])
    }

    /// The breathing bar: a soft rounded column that fills from the bottom, in white on the key's calm colour.
    private static func drawBreath(_ level: Int, size: CGFloat, hasTitle: Bool) {
        let k = size / 72
        let height = 38 * k
        let width = 22 * k
        let box = CGRect(x: (size - width) / 2, y: hasTitle ? size - 8 * k - height : (size - height) / 2, width: width, height: height)
        let round = width / 2
        NSColor.white.withAlphaComponent(0.28).setFill()
        NSBezierPath(roundedRect: box, xRadius: round, yRadius: round).fill()
        let filled = max(width, height * CGFloat(level) / 100)
        NSGraphicsContext.saveGraphicsState()
        NSBezierPath(roundedRect: box, xRadius: round, yRadius: round).addClip()
        NSColor.white.withAlphaComponent(0.92).setFill()
        CGRect(x: box.minX, y: box.minY, width: width, height: level == 0 ? 0 : filled).fill()
        NSGraphicsContext.restoreGraphicsState()
    }

    /// One part of a progress bar across keys: full = the full colour of the key, empty = the dark empty
    /// look with a thin outline, in between = the colour from the left up to its share.
    private static func drawPart(_ percent: Int, kind: KeyKind, size: CGFloat) {
        let k = size / 72
        let whole = CGRect(x: 0, y: 0, width: size, height: size)
        if percent >= 100 {
            Palette.tile(kind).setFill()
            whole.fill()
            return
        }
        Palette.tile(.empty).setFill()
        whole.fill()
        if percent > 0 {
            Palette.tile(kind).setFill()
            CGRect(x: 0, y: 0, width: size * CGFloat(percent) / 100, height: size).fill()
        }
        NSColor.white.withAlphaComponent(0.22).setStroke()
        let outline = NSBezierPath(rect: whole.insetBy(dx: 0.5 * k, dy: 0.5 * k))
        outline.lineWidth = 1 * k
        outline.stroke()
    }

    private static func draw(_ key: DeckKey, size: CGFloat) {
        let k = size / 72
        let title = Self.title(key)
        let hasTitle = !title.isEmpty
        // A key with a picture of its own whose file is missing falls back to the automatic drawing;
        // so does a key that would show a cover that is not here.
        let plain = key.pictureName == nil && GlanceKeys.coverTrack(key.icon) == nil
        let iconName = plain ? key.shownIcon : key.action.autoIcon
        // The drawing sits a little above the middle when there is a title under it.
        let iconSide = (hasTitle ? 34 : 44) * k
        let iconMid = CGPoint(x: size / 2, y: hasTitle ? size - 27 * k : size / 2)
        let iconRect = CGRect(x: iconMid.x - iconSide / 2, y: iconMid.y - iconSide / 2, width: iconSide, height: iconSide)

        if let level = BreathKeys.level(key.icon) {
            drawBreath(level, size: size, hasTitle: hasTitle)
        } else if let percent = BarKeys.percent(key.icon) {
            drawPart(percent, kind: key.action.kind, size: size)
        } else if let words = GlanceKeys.bigWords(key.icon) {
            // A glance key: large words where the drawing would be, made smaller until they fit.
            var font = NSFont.systemFont(ofSize: (hasTitle ? 25 : 30) * k, weight: .bold)
            var extent = (words as NSString).size(withAttributes: [.font: font])
            let room = size - 8 * k
            if extent.width > room {
                font = NSFont.systemFont(ofSize: font.pointSize * room / extent.width, weight: .bold)
                extent = (words as NSString).size(withAttributes: [.font: font])
            }
            (words as NSString).draw(at: CGPoint(x: (size - extent.width) / 2, y: iconMid.y - extent.height / 2),
                                     withAttributes: [.font: font, .foregroundColor: NSColor.white])
        } else if let name = key.pictureName, let picture = ownPicture(name) {
            // A picture of its own (an app's real icon): a little larger than a drawing, with an app icon's round corners.
            let side = (hasTitle ? 36 : 46) * k
            let box = CGRect(x: iconMid.x - side / 2, y: iconMid.y - side / 2, width: side, height: side)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.imageInterpolation = .high
            NSBezierPath(roundedRect: box, xRadius: side * 0.23, yRadius: side * 0.23).addClip()
            picture.draw(in: box, from: .zero, operation: .sourceOver, fraction: 1)
            NSGraphicsContext.restoreGraphicsState()
        } else if key.icon.isEmpty, key.action.type == .raycast, let icon = RaycastIcons.image(forLink: key.action.target) {
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
        let cacheKey = "\(title(key))|\(key.shownIcon)|\(key.action.hashValue)|\(key.hasHeld)|\(key.hasTwice)"
        if let hit = phonePictures[cacheKey] { return hit }
        let png = NSBitmapImageRep(cgImage: picture).representation(using: .png, properties: [:])
        if phonePictures.count > 300 { phonePictures.removeAll() }
        phonePictures[cacheKey] = png
        return png
    }

    private static var mapPictures: [Int: Data] = [:]

    /// A whole page as one small picture (166 x 98), for the iPad's navigation picture.
    static func pngForMap(_ page: DeckPage) -> Data? {
        var hasher = Hasher()
        for slot in page.keys.keys.sorted() {
            hasher.combine(slot)
            hasher.combine(title(page.keys[slot]))
            hasher.combine(page.keys[slot])
        }
        let cacheKey = hasher.finalize()
        if let hit = mapPictures[cacheKey] { return hit }
        let side = 30, gap = 4
        let width = side * 5 + gap * 4, height = side * 3 + gap * 2
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.interpolationQuality = .high
        for index in 0..<StreamDeckProtocol.keyCount {
            let box = CGRect(x: (index % 5) * (side + gap), y: height - side - (index / 5) * (side + gap), width: side, height: side)
            context.saveGState()
            context.addPath(CGPath(roundedRect: box, cornerWidth: 5, cornerHeight: 5, transform: nil))
            context.clip()
            if let picture = image(for: page.keys[index], pixels: 72) {
                context.draw(picture, in: box)
            } else {
                context.setFillColor(NSColor.white.withAlphaComponent(0.08).cgColor)
                context.fill(box)
            }
            context.restoreGState()
        }
        guard let picture = context.makeImage() else { return nil }
        let png = NSBitmapImageRep(cgImage: picture).representation(using: .png, properties: [:])
        if mapPictures.count > 200 { mapPictures.removeAll() }
        mapPictures[cacheKey] = png
        return png
    }

    /// A whole page as one large picture (five keys of 144 across), for looking at the keys from outside: `--pages`.
    static func pngForCheck(_ page: DeckPage) -> Data? {
        let side = 144, gap = 12
        let width = side * 5 + gap * 6, height = side * 3 + gap * 4
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.setFillColor(NSColor(white: 0.1, alpha: 1).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        for index in 0..<StreamDeckProtocol.keyCount {
            let box = CGRect(x: gap + (index % 5) * (side + gap), y: height - (index / 5 + 1) * (side + gap),
                             width: side, height: side)
            context.saveGState()
            context.addPath(CGPath(roundedRect: box, cornerWidth: 20, cornerHeight: 20, transform: nil))
            context.clip()
            if let picture = image(for: page.keys[index], pixels: side) {
                context.draw(picture, in: box)
            } else {
                context.setFillColor(NSColor.white.withAlphaComponent(0.08).cgColor)
                context.fill(box)
            }
            context.restoreGState()
        }
        guard let picture = context.makeImage() else { return nil }
        return NSBitmapImageRep(cgImage: picture).representation(using: .png, properties: [:])
    }

    static func forgetAppIcons() {
        mapPictures.removeAll()
        appIcons.removeAll()
        ownPictures.removeAll()
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
