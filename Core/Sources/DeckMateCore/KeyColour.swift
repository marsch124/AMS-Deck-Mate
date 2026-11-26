import Foundation

/// 0.24 — a key can wear a colour of its own instead of its kind's (his ask, 26 Nov 2026: a page group for
/// AMS Financial Steward and one for AMS Triathlon Training, "corresponding colours as well"). The colour is
/// stored as "RRGGBB"; everything else (a key without one, a word that is no colour) keeps its kind's colour.
public enum KeyColour {
    /// "1F6BCC" → (0.12, 0.42, 0.80). Takes "#1F6BCC" and small letters too; nil for anything else.
    public static func rgb(_ text: String) -> (red: Double, green: Double, blue: Double)? {
        let hex = clean(text)
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else { return nil }
        return (Double((value >> 16) & 0xFF) / 255, Double((value >> 8) & 0xFF) / 255, Double(value & 0xFF) / 255)
    }

    /// The way the file keeps it: six capital hex letters without "#"; "" for anything that is no colour.
    public static func clean(_ text: String) -> String {
        var hex = text.trimmingCharacters(in: .whitespaces).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, hex.allSatisfy({ $0.isHexDigit }) else { return "" }
        return hex
    }

    /// (0.12, 0.42, 0.80) → "1F6BCC". Values outside 0…1 are held to it.
    public static func hex(red: Double, green: Double, blue: Double) -> String {
        func byte(_ v: Double) -> Int { Int((min(max(v, 0), 1) * 255).rounded()) }
        return String(format: "%02X%02X%02X", byte(red), byte(green), byte(blue))
    }
}

extension DeckAction {
    /// True when the key's colour already says something — a signal (green, amber, red), fresh or not, a
    /// microphone in use, a bar's level. Such a key keeps that colour even when it has one of its own, and
    /// Set up keys offers no colour for it: one colour, one meaning.
    public var colourSpeaks: Bool {
        switch type {
        case .micLight, .weather, .dueToday, .paragon, .training, .focus, .bodyBattery, .garmin, .macNow,
             .worldClock, .freeUntil, .bar:
            return true
        default:
            return false
        }
    }
}
