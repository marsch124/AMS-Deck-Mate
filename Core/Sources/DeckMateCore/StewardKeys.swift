import Foundation

/// The 0.25 kind "Steward: to decide" (his yes, 26 Nov 2026): how many bank rows wait in AMS Financial Steward's
/// To decide.
///
/// Steward (0.21 or later, on the Mac) is the only writer of a tiny note in its own folder:
/// {"v":1,"written":"2026-11-26T10:00:00Z","waiting":12} — only a count and a time, never an amount or a name.
/// Deck Mate only reads it (every minute, while such a key is on a page) and a press opens Steward at To decide.
public enum StewardKeys {
    /// The one target of a Steward key.
    public static let target = "waiting"
    /// The name the glance goes by in `LiveKeys.glances`.
    public static let glanceName = "steward:waiting"
    /// Where Steward keeps the note on the Mac, from the home folder.
    public static let macFile = "Library/Containers/com.schabbauer.AMSFinancialSteward/Data/Library/Application Support/deck-note.json"
    public static let everySeconds = 60.0
    /// The newest format of the note this Deck Mate understands.
    public static let knownFormat = 1
    /// A count older than this is not shown: Steward has not looked for that long.
    public static let staleAfter: TimeInterval = 36 * 3600
    /// The note is a few dozen bytes; anything larger is not read.
    public static let largest = 4_000
    /// What a press opens (Steward 0.21's link).
    public static let link = "amsfinancialsteward://open/to-decide"

    public static let title = "To decide"
    public static let setupSays = "Shows how many bank rows wait in Steward’s To decide; opens To decide"

    public struct Note: Equatable, Sendable {
        public var format: Int
        public var written: Date
        public var waiting: Int

        public init(format: Int = 1, written: Date, waiting: Int) {
            self.format = format
            self.written = written
            self.waiting = waiting
        }
    }

    /// The note as Steward wrote it; nil for no file, a file too large, or one that is not a note.
    public static func note(from data: Data?) -> Note? {
        guard let data, data.count <= largest,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let format = json["v"] as? Int, let words = json["written"] as? String else { return nil }
        let reader = ISO8601DateFormatter()
        guard let written = reader.date(from: words) else { return nil }
        // A newer format may have changed what "waiting" means: keep only what tells "update Deck Mate".
        guard format <= knownFormat else { return Note(format: format, written: written, waiting: 0) }
        guard let waiting = json["waiting"] as? Int, waiting >= 0 else { return nil }
        return Note(format: format, written: written, waiting: waiting)
    }

    /// True while the count is fresh enough to show (written in the last 36 hours, not in the future).
    public static func isFresh(_ note: Note, now: Date) -> Bool {
        let age = now.timeIntervalSince(note.written)
        return age <= staleAfter && age >= -300
    }

    /// What the key shows: "12 / to decide" amber, "0 / all decided" green, "– / Open Steward" grey-blue.
    public static func glance(_ note: Note?, installed: Bool, now: Date) -> Glance {
        guard installed else { return Glance(words: "No Steward", tone: .move) }
        guard let note, isFresh(note, now: now) else { return Glance(big: "–", words: "Open Steward", tone: .move) }
        if note.format > knownFormat { return Glance(big: "–", words: "Update Deck Mate", tone: .move) }
        if note.waiting == 0 { return Glance(big: "0", words: "all decided", tone: .media) }
        return Glance(big: "\(note.waiting)", words: "to decide", tone: .text)
    }

    /// What the key does, in words, for "Explain" and the pointer note.
    public static func says(_ note: Note?, now: Date) -> String {
        let press = "A press opens Steward’s To decide."
        guard let note, note.format <= knownFormat, isFresh(note, now: now) else {
            return "Shows how many bank rows wait in Steward’s To decide. \(press)"
        }
        switch note.waiting {
        case 0: return "Nothing waits in Steward’s To decide. \(press)"
        case 1: return "1 bank row waits in Steward’s To decide. \(press)"
        default: return "\(note.waiting) bank rows wait in Steward’s To decide. \(press)"
        }
    }
}
