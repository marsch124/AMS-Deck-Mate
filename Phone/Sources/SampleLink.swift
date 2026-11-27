import UIKit
import DeckMateCore

/// Made-up keys for the `-sample` launch, so the screens can be seen and tested without a Mac.
enum SampleLink {
    static let place = "Default · Page 1"
    /// "-hubs" (0.35): "Default" is the Hub "Now" and a second Hub "Life" follows; "-onApp" stands on "Writing".
    static let hubs = CommandLine.arguments.contains("-hubs")
    static let status = PhoneLink.Status(profiles: [.init(id: "1", name: hubs ? "Now" : "Default"), .init(id: "2", name: "Writing")]
                                            + (hubs ? [.init(id: "3", name: "Life")] : []),
                                         current: CommandLine.arguments.contains("-onApp") ? "2" : "1", held: CommandLine.arguments.contains("-locked"), page: 0, pages: 3,
                                         pageID: "p1")

    /// Two page groups with five pages, for the navigation picture.
    static func map() -> [PhoneLink.MapGroup] {
        func page(_ id: String, _ name: String, _ filled: Int, folder: Bool = false) -> PhoneLink.MapGroup.Page {
            .init(id: id, name: name, folder: folder, picture: mapPicture(filled))
        }
        return [PhoneLink.MapGroup(id: "1", name: hubs ? "Now" : "Default", pages: [page("p1", "Page 1", 12), page("p2", "Page 2", 4),
                                                                      page("p3", "Page 3", 7), page("f1", "Sound", 5, folder: true)],
                                   hub: hubs ? true : nil),
                PhoneLink.MapGroup(id: "2", name: "Writing", pages: [page("w1", "Page 1", 2)])]
            + (hubs ? [PhoneLink.MapGroup(id: "3", name: "Life", pages: [page("l1", "Training", 9)], hub: true)] : [])
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
        let words = [0: "Plays or pauses the music", 1: "Opens Safari", 2: "Goes to the page group “Writing”", 4: "Mutes the Mac"]
        var result: [Int: PhoneLink.Key] = [:]
        for index in 0..<PhoneLink.favouriteCount { result[index] = PhoneLink.Key(index: index, title: "", picture: nil) }
        for tile in tiles { result[tile.0] = PhoneLink.Key(index: tile.0, title: tile.1, picture: picture(tile.1, tile.2), tap: words[tile.0]) }
        return result
    }

    private static let blue = UIColor(red: 0.18, green: 0.44, blue: 0.88, alpha: 1)
    private static let raycast = UIColor(red: 0.86, green: 0.22, blue: 0.25, alpha: 1)
    private static let teal = UIColor(red: 0.08, green: 0.54, blue: 0.48, alpha: 1)
    private static let green = UIColor(red: 0.14, green: 0.52, blue: 0.26, alpha: 1)
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
        let taps = ["Opens Mail", "Opens Notes", "Opens OmniFocus", "Opens Safari", "Opens the Translate window",
                    "Shows the clipboard history", "Moves the window to the left half", "Opens today's tasks",
                    "Opens the calendar", "Plays or pauses the music", "Presses ⌘↑ to turn the volume up",
                    "Opens the Documents folder"]
        let holds = [1: "Starts a new note", 5: "Clears the clipboard history"]
        let twices = [1: "Opens the quick note"]
        var result: [Int: PhoneLink.Key] = [:]
        for (index, tile) in tiles.enumerated() {
            result[index] = PhoneLink.Key(index: index, title: tile.0, picture: picture(tile.0, tile.1),
                                          tap: taps[index], hold: holds[index], twice: twices[index])
        }
        return result
    }

    /// "Several pages at once" in pictures: the made-up keys on every page, a little shifted each time.
    static let wideNames = ["Page 1", "Apps", "PARAGON", "On the Mac"]
    static func wideKeys(_ pages: Int) -> [Int: PhoneLink.Key] {
        let one = keys()
        var result: [Int: PhoneLink.Key] = [:]
        for page in 0..<pages {
            for (index, key) in one {
                let place = (index + page * 3) % StreamDeckProtocol.keyCount
                result[page * StreamDeckProtocol.keyCount + place] =
                    PhoneLink.Key(index: page * StreamDeckProtocol.keyCount + place, title: key.title, picture: key.picture,
                                  tap: key.tap, hold: key.hold, twice: key.twice)
            }
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
