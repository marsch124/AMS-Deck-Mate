import Foundation

/// The "Training today" key (Mac 0.23, iPhone and iPad 0.33): today's session from AMS Triathlon Training.
///
/// Triathlon Training is the only writer of a small "today" note (its contract: `today-note-contract.md`,
/// round 28). Deck Mate only reads it and may open one of the note's own links. The note reaches the Mac
/// two ways: as a file in Triathlon Training's own folder on the Mac, and from an iPhone or iPad, where the
/// Deck Mate app reads it from the Keychain group both apps share and hands it to the Mac over the private line.
/// The Mac draws the key from the newest note it has.
///
/// A press (his choice, 25 Nov 2026: "Log on iPhone, open elsewhere"): on a phone whose own note says the
/// session can be logged right now, the phone opens the note's `done` link; everywhere else the session is
/// only opened. Nothing here ever writes, moves or removes anything.
public enum TrainingKeys {
    /// The one target of a training key.
    public static let target = "today"
    /// The name the glance goes by in `LiveKeys.glances`.
    public static let glanceName = "training:today"
    /// Where Triathlon Training (the iPad app on the Mac) keeps the note, from the home folder.
    public static let macFile = "Library/Containers/com.schabbauer.AMSWorkoutSync/Data/Library/Application Support/today-note.json"
    /// The Keychain item on an iPhone or iPad: a generic password, on that device only.
    public static let service = "ams.training.today"
    public static let account = "v1"
    public static let group = "D24ENP83QQ.com.schabbauer.AMSWorkoutSync"
    /// The file and the Keychain item are read again after this many seconds.
    public static let everySeconds = 60.0
    /// The only kind of link that is ever opened.
    public static let scheme = "amsworkoutsync://"
    public static let todayLink = "amsworkoutsync://today"
    /// The newest format of the note this Deck Mate understands.
    public static let knownFormat = 1
    /// A note written longer ago than this shows nothing of its sessions, even on today's date.
    public static let staleAfter: TimeInterval = 36 * 3600
    /// A note is never larger than this (the contract says under 3 KB); anything larger is not read.
    public static let largest = 16_000

    public static let title = "Training today"
    public static let oldWords = "Open Triathlon"
    public static let missingWords = "No Triathlon"
    public static let updateWords = "Update Deck Mate"

    public struct Session: Equatable, Sendable {
        public var key: String
        public var sport: String
        public var sportWord: String
        public var title: String
        public var length: String
        /// "todo", "done", "missed" or "rest"; anything else counts as to do.
        public var state: String
        public var canDone: Bool
        public var open: String?
        public var done: String?

        public var isRest: Bool { state == "rest" || sport.lowercased() == "rest" }
        public var isDone: Bool { !isRest && state == "done" }
        public var isMissed: Bool { !isRest && state == "missed" }
        public var isToDo: Bool { !isRest && !isDone && !isMissed }

        /// "Run", also when the note has no word for the sport.
        public var word: String {
            let said = sportWord.trimmingCharacters(in: .whitespacesAndNewlines)
            if !said.isEmpty { return said }
            let plain = sport.trimmingCharacters(in: .whitespacesAndNewlines)
            return plain.isEmpty ? "Session" : plain.prefix(1).uppercased() + plain.dropFirst()
        }

        /// The link that logs this session as planned; nil unless the note says it would log right now.
        public var doneLink: String? {
            guard isToDo, canDone, let done, TrainingKeys.isOwn(done) else { return nil }
            return done
        }

        /// The link that opens this session's page.
        public var openLink: String? { open.flatMap { TrainingKeys.isOwn($0) ? $0 : nil } }
    }

    public struct Note: Equatable, Sendable {
        public var format: Int
        /// The day the note is about, "2026-12-01", in the writer's own local time.
        public var day: String
        public var written: Date?
        public var sessions: [Session]

        public var firstToDo: Session? { sessions.first(where: \.isToDo) }
    }

    /// True for a link of Triathlon Training's own (the only kind that is ever opened).
    public static func isOwn(_ link: String) -> Bool {
        link.lowercased().hasPrefix(scheme) && link.count <= 300 && URL(string: link) != nil
    }

    /// The note, read as far as it makes sense; nil when the bytes are not one (or too many).
    public static func note(from data: Data?) -> Note? {
        guard let data, !data.isEmpty, data.count <= largest,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let day = json["day"] as? String else { return nil }
        func text(_ row: [String: Any], _ name: String) -> String {
            String(((row[name] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).prefix(80))
        }
        let rows = (json["sessions"] as? [[String: Any]]) ?? []
        let sessions = rows.prefix(12).map { row in
            Session(key: text(row, "key"), sport: text(row, "sport"), sportWord: text(row, "sportWord"),
                    title: text(row, "title"), length: text(row, "length"),
                    state: (row["state"] as? String) ?? "todo", canDone: (row["canDone"] as? Bool) ?? false,
                    open: row["open"] as? String, done: row["done"] as? String)
        }
        return Note(format: max(1, (json["v"] as? NSNumber)?.intValue ?? 1), day: day,
                    written: (json["written"] as? String).flatMap(moment(_:)), sessions: sessions)
    }

    static func moment(_ words: String) -> Date? {
        let plain = ISO8601DateFormatter()
        if let date = plain.date(from: words) { return date }
        let fine = ISO8601DateFormatter()
        fine.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fine.date(from: words)
    }

    /// "2026-12-01" for a moment, in this device's own calendar and time.
    public static func day(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// A note counts only when it is about the reader's own today and was written in the last 36 hours:
    /// yesterday's session is never shown.
    public static func isFresh(_ note: Note, today: String, now: Date) -> Bool {
        guard note.day == today, let written = note.written else { return false }
        return now.timeIntervalSince(written) <= staleAfter
    }

    /// The newest fresh note of all the Mac has (its own file, each phone's); nil = none is fresh.
    /// A note in a newer format than this Deck Mate knows is handed on as it is, so the key can say so.
    public static func best(_ notes: [Note?], today: String, now: Date) -> Note? {
        notes.compactMap { $0 }.filter { isFresh($0, today: today, now: now) }
            .max { ($0.written ?? .distantPast) < ($1.written ?? .distantPast) }
    }

    /// What the key shows. `note` = the fresh note to draw from (nil = none); `installed` = Triathlon Training
    /// is on this Mac or a phone has handed over a note; `logs` = a press on the device this is drawn for
    /// logs the session (an iPhone whose own note says so).
    public static func glance(_ note: Note?, installed: Bool, logs: Bool = false) -> Glance {
        guard let note else {
            return installed ? Glance(big: "–", words: oldWords, tone: .move) : Glance(words: missingWords, tone: .move)
        }
        if note.format > knownFormat { return Glance(big: "–", words: updateWords, tone: .move) }
        let real = note.sessions.filter { !$0.isRest }
        if real.isEmpty {
            return note.sessions.isEmpty ? Glance(big: "–", words: oldWords, tone: .move)
                                         : Glance(big: "Rest", words: "Rest day")
        }
        let toDo = real.filter(\.isToDo)
        if let first = toDo.first {
            let more = toDo.count > 1 ? " +\(toDo.count - 1)" : ""
            let state = logs && first.doneLink != nil ? "press for done" : "to do"
            if first.length.isEmpty { return Glance(big: first.word, words: state + more) }
            return Glance(big: first.length, words: "\(first.word) · \(state)\(more)")
        }
        let under = real.count == 1 ? real[0].word : "\(real.count) sessions"
        if real.allSatisfy(\.isDone) { return Glance(big: "Done", words: under, tone: .media) }
        // Nothing left to do and at least one missed: quiet, never red.
        return Glance(big: "Missed", words: under, tone: .move)
    }

    /// What the key does, in words, for "Explain" and the pointer note: "Easy run, 45 min, to do. A press logs it
    /// as done in Triathlon Training."
    public static func says(_ note: Note?, logs: Bool) -> String {
        let press = "A press"
        guard let note, note.format <= knownFormat, !note.sessions.isEmpty else {
            return "Shows today's training session. \(press) opens Triathlon Training."
        }
        guard let first = note.firstToDo else {
            let real = note.sessions.filter { !$0.isRest }
            let what = real.isEmpty ? "Rest day" : real.allSatisfy(\.isDone) ? "Today's training is done" : "Nothing left to do today"
            return "\(what). \(press) opens Triathlon Training."
        }
        let name = first.title.isEmpty ? first.word : first.title
        let facts = ([name] + (first.length.isEmpty ? [] : [first.length]) + ["to do"]).joined(separator: ", ")
        return logs && first.doneLink != nil ? "\(facts). \(press) logs it as done in Triathlon Training."
                                              : "\(facts). \(press) opens it in Triathlon Training."
    }

    /// The words for the setup lists and the diary.
    public static let setupSays = "Shows today's training session; opens Triathlon Training (on the iPhone: logs it as done)"

    public struct Press: Equatable, Sendable {
        /// True = the phone that was pressed opens the link; false = the Mac does.
        public var onPhone: Bool
        public var link: String
        /// True = the link logs the session as done.
        public var logs: Bool
    }

    /// What a press of the key does.
    /// - `phone`: the note of the iPhone or iPad the press came from; nil = it came from the Mac or the box,
    ///   or that device handed over no note (no Triathlon Training there, or an older Deck Mate).
    /// - `best`: the newest fresh note the Mac has.
    /// A phone with a fresh note of its own: the `done` link when the note says it would log right now, else
    /// the session's page, else Triathlon Training's Today page, all on that phone. A phone whose note is old:
    /// Today on that phone (opening Triathlon Training writes a new note). Otherwise the Mac opens the
    /// session's page, or Today.
    public static func press(phone: Note?, best: Note?, today: String, now: Date) -> Press {
        if let phone {
            guard isFresh(phone, today: today, now: now), phone.format <= knownFormat,
                  let first = phone.firstToDo else { return Press(onPhone: true, link: todayLink, logs: false) }
            if let done = first.doneLink { return Press(onPhone: true, link: done, logs: true) }
            return Press(onPhone: true, link: first.openLink ?? todayLink, logs: false)
        }
        let open = best.flatMap { $0.format <= knownFormat ? $0.firstToDo?.openLink : nil }
        return Press(onPhone: false, link: open ?? todayLink, logs: false)
    }

    /// The phone's own guard before it opens a link the Mac sent: Triathlon Training's scheme only, and only
    /// the Today page or a link that stands in the phone's OWN note. So the Mac can never make the phone
    /// open anything the note on that phone does not offer.
    public static func allows(_ link: String, note: Note?) -> Bool {
        guard isOwn(link) else { return false }
        if link == todayLink { return true }
        guard let note else { return false }
        return note.sessions.contains { $0.openLink == link || $0.doneLink == link }
    }

    /// A press on the phone and the Mac's answer belong together only this many seconds.
    public static let answerWithin: TimeInterval = 3

    /// The drawing of a sport, from the icon set; a session without a known sport gets the triathlon mark.
    public static func icon(sport: String) -> String {
        switch sport.lowercased() {
        case "run": return "run"
        case "bike", "ride", "cycle": return "bike"
        case "swim": return "swim"
        case "strength", "gym": return "strength"
        case "rest": return "sleep"
        default: return "triathlon"
        }
    }
}
