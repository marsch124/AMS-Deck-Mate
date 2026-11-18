import Foundation

/// Times of day as minutes since midnight (0...1439), and whether a time falls inside a window that
/// may pass midnight. Used by the evening dimming of the box and by page groups with hours.
public enum DayMinutes {
    public static let perDay = 1440

    /// The minute of the day of a date, in the Mac's own time.
    public static func of(_ date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return min(perDay - 1, max(0, (parts.hour ?? 0) * 60 + (parts.minute ?? 0)))
    }

    /// True when `now` is from `from` (included) until `to` (not included). The window may pass
    /// midnight (21:30 to 07:00). From and to the same = no time at all.
    public static func within(_ now: Int, from: Int, to: Int) -> Bool {
        if from == to { return false }
        return from < to ? (now >= from && now < to) : (now >= from || now < to)
    }

    /// "21:30"
    public static func clock(_ minutes: Int) -> String {
        let m = min(perDay - 1, max(0, minutes))
        return String(format: "%02d:%02d", m / 60, m % 60)
    }
}

/// The box dims in the evening: inside the window it gets the evening brightness, outside the usual one.
public enum BoxEvening {
    public static let defaultFrom = 21 * 60 + 30
    public static let defaultTo = 7 * 60
    public static let defaultBrightness = 20

    /// The brightness (0 to 100) the box should have at this minute of the day.
    public static func brightness(for deck: Deck, minute: Int) -> Int {
        guard deck.eveningDim, DayMinutes.within(minute, from: deck.eveningFrom, to: deck.eveningTo) else {
            return deck.brightness
        }
        return deck.eveningBrightness
    }
}
