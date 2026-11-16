import SwiftUI
import UIKit

/// The colours of the iPhone app: the same part colours as the Mac app, a lighter shade by night.
enum PhonePalette {
    private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    /// One colour for day and another for night, picked by the system.
    private static func dynamic(day: UIColor, night: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? night : day })
    }

    /// The app's own colour: the calm indigo of its icon.
    static let brand = rgb(0.27, 0.33, 0.74)

    /// The colour of a part of the app, for headings and marks.
    static func part(_ part: String) -> Color {
        switch part {
        case "raycast": return dynamic(day: rgb(0.78, 0.17, 0.20), night: rgb(1.00, 0.52, 0.52))
        case "profiles": return dynamic(day: rgb(0.43, 0.32, 0.78), night: rgb(0.72, 0.64, 0.98))
        case "box": return dynamic(day: rgb(0.05, 0.48, 0.42), night: rgb(0.36, 0.80, 0.72))
        case "screen": return dynamic(day: rgb(0.14, 0.40, 0.84), night: rgb(0.47, 0.71, 1.00))
        case "settings": return dynamic(day: rgb(0.13, 0.52, 0.26), night: rgb(0.45, 0.82, 0.55))
        default: return dynamic(day: brand, night: rgb(0.62, 0.68, 1.00))
        }
    }

    /// A full-colour fill for main buttons: readable with white words by day and by night.
    static func fill(_ part: String) -> Color {
        switch part {
        case "raycast": return Color(uiColor: rgb(0.86, 0.22, 0.25))
        case "profiles": return Color(uiColor: rgb(0.48, 0.37, 0.82))
        case "box": return Color(uiColor: rgb(0.08, 0.54, 0.48))
        case "screen": return Color(uiColor: rgb(0.18, 0.44, 0.88))
        case "settings": return Color(uiColor: rgb(0.18, 0.61, 0.31))
        default: return Color(uiColor: brand)
        }
    }

    /// The dark ground behind the keys.
    static let ground = dynamic(day: rgb(0.93, 0.93, 0.94), night: rgb(0.11, 0.11, 0.115))
    /// An empty key place.
    static let emptyKey = dynamic(day: rgb(0.84, 0.84, 0.86), night: rgb(0, 0, 0))
    /// The cards on the ground (messages, hints).
    static let card = dynamic(day: rgb(1, 1, 1), night: rgb(0.19, 0.19, 0.2))
    /// The red of "could not do it".
    static let problem = dynamic(day: rgb(0.80, 0.15, 0.13), night: rgb(1.0, 0.45, 0.40))
}

/// A main button: always full colour with white words.
struct PhoneMainButton: ButtonStyle {
    var part = "keys"

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(PhonePalette.fill(part).opacity(configuration.isPressed ? 0.75 : 1),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// A quiet button beside a main one.
struct PhonePlainButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(configuration.isPressed ? 0.16 : 0.08),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// A hand-drawn icon from the library, tinted like text.
struct PhoneIcon: View {
    let name: String
    var size: CGFloat = 22

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
