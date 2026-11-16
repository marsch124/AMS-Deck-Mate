import AudioToolbox
import SwiftUI
import UIKit

/// The settings of the iPhone and iPad app. Each is kept on the device and applies at once.
enum PhonePrefs {
    enum Ground: String, CaseIterable, Identifiable {
        case auto, dark, blue, forest, plum
        var id: String { rawValue }
        var title: String {
            switch self {
            case .auto: return "Day and night"
            case .dark: return "Always dark"
            case .blue: return "Night blue"
            case .forest: return "Forest"
            case .plum: return "Plum"
            }
        }
        /// The colour behind the keys; nil = the one that follows day and night.
        var colour: Color? {
            switch self {
            case .auto: return nil
            case .dark: return Color(red: 0.11, green: 0.11, blue: 0.115)
            case .blue: return Color(red: 0.07, green: 0.13, blue: 0.27)
            case .forest: return Color(red: 0.06, green: 0.20, blue: 0.16)
            case .plum: return Color(red: 0.22, green: 0.10, blue: 0.24)
            }
        }
    }

    enum Shape: String, CaseIterable, Identifiable {
        case rounded, square, pillow
        var id: String { rawValue }
        var title: String {
            switch self {
            case .rounded: return "Rounded"
            case .square: return "Square"
            case .pillow: return "Pillow"
            }
        }
        /// The corner's size as a part of the key's side.
        var corner: CGFloat {
            switch self {
            case .rounded: return 0.16
            case .square: return 0.04
            case .pillow: return 0.30
            }
        }
    }

    enum Gap: String, CaseIterable, Identifiable {
        case narrow, normal, wide
        var id: String { rawValue }
        var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
        var points: CGFloat {
            switch self {
            case .narrow: return 4
            case .normal: return 8
            case .wide: return 14
            }
        }
    }

    enum Size: String, CaseIterable, Identifiable {
        case largest, smaller
        var id: String { rawValue }
        var title: String { self == .largest ? "Largest" : "A bit smaller" }
        var scale: CGFloat { self == .largest ? 1 : 0.85 }
    }

    enum Place: String, CaseIterable, Identifiable {
        case bottom, middle, top
        var id: String { rawValue }
        var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
    }

    /// Minutes without a touch before the resting clock shows; 0 = never.
    static let restChoices = [0, 2, 5, 10]

    /// Is the resting clock due? `idle` = seconds since the last touch.
    static func rests(afterMinutes minutes: Int, idle: TimeInterval) -> Bool {
        minutes > 0 && idle >= Double(minutes) * 60
    }

    /// The soft click of a key (the keyboard's own click sound).
    static func click() {
        AudioServicesPlaySystemSound(1104)
    }
}

/// A large clock with the date: above the keys, and alone on the screen as the resting clock.
struct BigClock: View {
    var size: CGFloat
    var dimmed = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: size * 0.04) {
                Text(context.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: size, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Text(context.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.system(size: max(13, size * 0.2), weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .opacity(dimmed ? 0.55 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(dimmed ? "restingClock" : "clock")
    }
}
