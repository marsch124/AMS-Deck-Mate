import Foundation
import CoreGraphics

/// How big the keys on screen are.
public enum ScreenSize: String, Codable, CaseIterable, Sendable {
    case small, normal, large

    public init(from decoder: Decoder) throws {
        let raw = (try? decoder.singleValueContainer().decode(String.self)) ?? ""
        self = ScreenSize(rawValue: raw) ?? .normal
    }

    /// The side of one key, in points.
    public var keySide: Double {
        switch self {
        case .small: return 48
        case .normal: return 64
        case .large: return 80
        }
    }

    /// The space between two keys, in points.
    public var gap: Double {
        switch self {
        case .small: return 6
        case .normal: return 8
        case .large: return 10
        }
    }

    public var title: String {
        switch self {
        case .small: return "Small"
        case .normal: return "Normal"
        case .large: return "Large"
        }
    }
}

/// The rules of the keys on screen. No window, no mouse: numbers in, the answer out.
public enum ScreenDeckRules {
    /// Where the keys go when they appear at the mouse pointer: centred on it, but never off the
    /// screen — near an edge they move in until they are whole, `margin` points from the edge.
    /// `area` is the usable part of the screen the pointer is on; the answer is the lower left corner.
    public static func origin(pointer: CGPoint, size: CGSize, area: CGRect, margin: Double = 8) -> CGPoint {
        func place(_ wanted: Double, _ length: Double, _ low: Double, _ high: Double) -> Double {
            let least = low + margin
            let most = high - margin - length
            guard most >= least else { return low + (high - low - length) / 2 }     // larger than the screen: centred
            return min(max(wanted, least), most)
        }
        return CGPoint(x: place(pointer.x - size.width / 2, size.width, area.minX, area.maxX),
                       y: place(pointer.y - size.height / 2, size.height, area.minY, area.maxY))
    }

    /// With "hide after a key is pressed" on, the keys hide after a key that did something on the Mac.
    /// A key that only moves around (a folder, Back, a page, a profile) leaves them open: he is not done yet.
    public static func hides(after outcome: Navigator.Outcome, setting: Bool) -> Bool {
        setting && !outcome.run.isEmpty
    }
}
