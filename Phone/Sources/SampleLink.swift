import UIKit
import DeckMateCore

/// Made-up keys for the `-sample` launch, so the screens can be seen and tested without a Mac.
enum SampleLink {
    static let place = "Default · Page 1"
    static let status = PhoneLink.Status(profiles: [.init(id: "1", name: "Default"), .init(id: "2", name: "Writing")],
                                         current: "1", held: CommandLine.arguments.contains("-locked"), page: 0, pages: 3,
                                         pageID: "p1")

    /// Two page groups with five pages, for the navigation picture.
    static func map() -> [PhoneLink.MapGroup] {
        func page(_ id: String, _ name: String, _ filled: Int, folder: Bool = false) -> PhoneLink.MapGroup.Page {
            .init(id: id, name: name, folder: folder, picture: mapPicture(filled))
        }
        return [PhoneLink.MapGroup(id: "1", name: "Default", pages: [page("p1", "Page 1", 12), page("p2", "Page 2", 4),
                                                                      page("p3", "Page 3", 7), page("f1", "Sound", 5, folder: true)]),
                PhoneLink.MapGroup(id: "2", name: "Writing", pages: [page("w1", "Page 1", 2)])]
    }

    private static func mapPicture(_ filled: Int) -> Data? {
        let colours = [blue, blue, raycast, teal, green, grey]
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 166, height: 98), format: format).image { _ in
            for index in 0..<15 {
                (index < filled ? colours[index % colours.count] : UIColor(white: 1, alpha: 0.08)).setFill()
                UIBezierPath(roundedRect: CGRect(x: (index % 5) * 34, y: (index / 5) * 34, width: 30, height: 30), cornerRadius: 5).fill()
            }
        }.pngData()
    }

    static let mac = PhoneLink.MacNow(battery: 82, charging: false, app: "Safari", song: "Morning Light",
                                      artist: "The Sample Band", playing: true, volume: 44)

    /// Four favourites, the fourth place left empty.
    static func favourites() -> [Int: PhoneLink.Key] {
        let tiles: [(Int, String, UIColor)] = [(0, "Play", green), (1, "Safari", blue), (2, "Writing", grey), (4, "Mute", green)]
        var result: [Int: PhoneLink.Key] = [:]
        for index in 0..<PhoneLink.favouriteCount { result[index] = PhoneLink.Key(index: index, title: "", picture: nil) }
        for tile in tiles { result[tile.0] = PhoneLink.Key(index: tile.0, title: tile.1, picture: picture(tile.1, tile.2)) }
        return result
    }

    private static let blue = UIColor(red: 0.18, green: 0.44, blue: 0.88, alpha: 1)
    private static let raycast = UIColor(red: 0.86, green: 0.22, blue: 0.25, alpha: 1)
    private static let teal = UIColor(red: 0.08, green: 0.54, blue: 0.48, alpha: 1)
    private static let green = UIColor(red: 0.18, green: 0.61, blue: 0.31, alpha: 1)
    private static let grey = UIColor(red: 0.36, green: 0.42, blue: 0.51, alpha: 1)

    /// 12 keys, the last 3 places left empty.
    static func keys() -> [Int: PhoneLink.Key] {
        let tiles: [(String, UIColor)] = [
            ("Mail", blue), ("Notes", blue), ("OmniFocus", blue), ("Safari", blue),
            ("Translate", raycast), ("Clipboard", raycast), ("Window", raycast),
            ("Today", teal), ("Calendar", teal),
            ("Play", green), ("Volume", green),
            ("Documents", grey)
        ]
        var result: [Int: PhoneLink.Key] = [:]
        for (index, tile) in tiles.enumerated() {
            result[index] = PhoneLink.Key(index: index, title: tile.0, picture: picture(tile.0, tile.1))
        }
        return result
    }

    /// A flat coloured square with a white title near the bottom.
    private static func picture(_ title: String, _ colour: UIColor) -> Data? {
        let size = CGSize(width: 144, height: 144)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            colour.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: style
            ]
            (title as NSString).draw(in: CGRect(x: 6, y: 106, width: 132, height: 28), withAttributes: attributes)
        }
        return image.pngData()
    }
}
