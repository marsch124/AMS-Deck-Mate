import UIKit
import DeckMateCore

/// Made-up keys for the `-sample` launch, so the screens can be seen and tested without a Mac.
enum SampleLink {
    static let place = "Default · Page 1"
    static let status = PhoneLink.Status(profiles: [.init(id: "1", name: "Default"), .init(id: "2", name: "Writing")],
                                         current: "1", held: CommandLine.arguments.contains("-locked"), page: 0, pages: 3)

    private static let blue = UIColor(red: 0.18, green: 0.44, blue: 0.88, alpha: 1)
    private static let raycast = UIColor(red: 0.85, green: 0.33, blue: 0.17, alpha: 1)
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
