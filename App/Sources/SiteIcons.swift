import AppKit
import DeckMateCore

/// Websites' own icons, for the colour of link keys (0.28). Fetched once from the site itself (nothing else is
/// asked or sent), kept in "Site icons" beside the keys file, fetched again after 30 days.
enum SiteIcons {
    static var folder: URL? { KeyArt.picturesFolder?.deletingLastPathComponent().appendingPathComponent("Site icons") }
    /// Called on the main thread when a new icon arrived: the keys are drawn again.
    static var arrived: (() -> Void)?
    private static var images: [String: NSImage] = [:]
    private static var asked: Set<String> = []
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.httpCookieAcceptPolicy = .never
        return URLSession(configuration: configuration)
    }()

    /// The site's icon when it is here; nil while it is being fetched or when the site has none.
    static func image(forLink link: String) -> NSImage? {
        guard let name = KeyOpener.siteFileName(link), let folder else { return nil }
        if let hit = images[name] { return hit }
        let file = folder.appendingPathComponent(name)
        if let image = NSImage(contentsOf: file), image.isValid {
            images[name] = image
            let changed = (try? file.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            if Date().timeIntervalSince(changed) > 30 * 86_400 { fetch(link, into: file, name: name) }
            return image
        }
        fetch(link, into: file, name: name)
        return nil
    }

    private static func fetch(_ link: String, into file: URL, name: String) {
        guard !asked.contains(name), !CommandLine.arguments.contains("--pages") else { return }
        asked.insert(name)
        let candidates = KeyOpener.siteIconLinks(link)
        func next(_ index: Int) {
            guard index < candidates.count else { return }
            session.dataTask(with: candidates[index]) { data, response, _ in
                guard let data, (response as? HTTPURLResponse)?.statusCode == 200, data.count < 2_000_000,
                      let image = NSImage(data: data), image.isValid, image.size.width >= 16,
                      let tiff = image.tiffRepresentation, let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
                else { return next(index + 1) }
                DispatchQueue.main.async {
                    try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try? png.write(to: file, options: .atomic)
                    images[name] = image
                    arrived?()
                }
            }.resume()
        }
        next(0)
    }
}
