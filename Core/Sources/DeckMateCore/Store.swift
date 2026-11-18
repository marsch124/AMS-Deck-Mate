import Foundation

/// Where the setup lives: one file on this Mac. Every save first keeps the file that was there
/// as a safety copy, so a bad save can always be taken back.
public struct Store {
    public let folder: URL
    /// The folder in iCloud Drive for the weekly copies; nil = none are made (checks, pictures).
    public let cloud: URL?
    public static let keptCopies = 20

    public init(folder: URL? = nil, cloud: URL? = nil) {
        self.folder = folder ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AMS Deck Mate", isDirectory: true)
        self.cloud = cloud
    }

    public var file: URL { folder.appendingPathComponent("deck.json") }
    public var backups: URL { folder.appendingPathComponent("Backups", isDirectory: true) }
    /// Pictures a key can show instead of a drawing (an app's real icon), as <name>.png.
    public var pictures: URL { folder.appendingPathComponent("Pictures", isDirectory: true) }

    /// nil when there is no setup yet (first start), when the file cannot be read at all, or when it
    /// reads but holds no page group (a file like "{}" is damaged, not an empty setup).
    public func load() -> Deck? { Store.read(file) }

    public var hasFile: Bool { FileManager.default.fileExists(atPath: file.path) }

    @discardableResult
    public func save(_ deck: Deck) -> Bool {
        let files = FileManager.default
        try? files.createDirectory(at: backups, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        var deck = deck
        deck.version = max(deck.version, Deck.currentVersion)
        guard let data = try? encoder.encode(deck) else { return false }
        if let old = try? Data(contentsOf: file) {
            if old == data { return true }
            keepCopy(of: old)
        }
        do {
            try data.write(to: file, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    /// Puts the file as it is now among the safety copies and keeps the newest ones.
    public func keepCopy(of data: Data) {
        let files = FileManager.default
        // Two saves in the same thousandth of a second must not land on one name.
        let stamp = Store.stamp()
        var name = "deck \(stamp).json"
        var extra = 0
        while files.fileExists(atPath: backups.appendingPathComponent(name).path), extra < 26 {
            name = "deck \(stamp)\(Character(UnicodeScalar(UInt8(97 + extra)))).json"
            extra += 1
        }
        try? data.write(to: backups.appendingPathComponent(name), options: .atomic)
        tidyCopies()
    }

    /// Keeps the file as it is now as a copy that ordinary saving never pushes out: the state just
    /// before something large (a page or a page group deleted, Elgato's keys brought over, an earlier
    /// state put back). `why` becomes part of its name. The newest `keptMarked` of these stay.
    public func keepNow(_ why: String) {
        guard let data = try? Data(contentsOf: file) else { return }
        let files = FileManager.default
        try? files.createDirectory(at: backups, withIntermediateDirectories: true)
        let words = why.filter { $0.isLetter || $0.isNumber || $0 == " " }
        try? data.write(to: backups.appendingPathComponent("\(Store.markedPrefix)\(Store.stamp()) \(words).json"), options: .atomic)
        tidyCopies()
    }

    private func tidyCopies() {
        let files = FileManager.default
        let names = (try? files.contentsOfDirectory(atPath: backups.path)) ?? []
        for name in Store.copiesToRemove(names, today: Date()) {
            try? files.removeItem(at: backups.appendingPathComponent(name))
        }
    }

    public static let markedPrefix = "deck kept "
    public static let keptMarked = 10
    /// A day's last copy stays this many days.
    public static let keptDays = 30

    /// The day ("2026-11-18") in the name of a copy written by a save; nil for every other file
    /// (a copy with a name of its own, a damaged file): those are never removed.
    static func day(ofSavedCopy name: String) -> String? {
        guard name.hasPrefix("deck "), name.hasSuffix(".json") else { return nil }
        let rest = name.dropFirst(5)
        guard rest.count >= 23, rest.prefix(4).allSatisfy(\.isNumber) else { return nil }
        let day = String(rest.prefix(10))
        let parts = day.split(separator: "-")
        guard parts.count == 3, parts.allSatisfy({ $0.allSatisfy(\.isNumber) }),
              rest.dropFirst(10).first == " " else { return nil }
        return day
    }

    /// Which safety copies go. Kept: the newest `keptCopies` written by a save, the last copy of each
    /// of the last `keptDays` days (so an hour of editing cannot push out yesterday), and the newest
    /// `keptMarked` copies made before something large. A file with any other name is never touched.
    public static func copiesToRemove(_ names: [String], today: Date) -> [String] {
        let saved = names.filter { day(ofSavedCopy: $0) != nil }.sorted()
        var keep = Set(saved.suffix(keptCopies))
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.locale = Locale(identifier: "en_US_POSIX")
        let oldest = format.string(from: today.addingTimeInterval(-Double(keptDays) * 86_400))
        var lastOfDay: [String: String] = [:]
        for name in saved { lastOfDay[day(ofSavedCopy: name) ?? ""] = name }
        for (day, name) in lastOfDay where day >= oldest { keep.insert(name) }
        let marked = names.filter { $0.hasPrefix(markedPrefix) && $0.hasSuffix(".json") }.sorted()
        return saved.filter { !keep.contains($0) } + marked.dropLast(keptMarked)
    }

    private static func stamp() -> String {
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyy-MM-dd HH.mm.ss.SSS"
        stamp.locale = Locale(identifier: "en_US_POSIX")
        return stamp.string(from: Date())
    }

    // MARK: Safety copies

    /// One safety copy that can be read.
    public struct Copy: Identifiable, Equatable, Sendable {
        /// The file's name in the Backups folder.
        public var name: String
        /// When it was written.
        public var date: Date
        public var groups: Int
        public var keys: Int
        /// True for a weekly copy in iCloud Drive.
        public var inCloud: Bool
        public var id: String { (inCloud ? "cloud/" : "mac/") + name }

        public init(name: String, date: Date, groups: Int, keys: Int, inCloud: Bool = false) {
            self.name = name
            self.date = date
            self.groups = groups
            self.keys = keys
            self.inCloud = inCloud
        }

        /// "3 page groups · 47 keys"
        public var words: String {
            "\(groups) page \(groups == 1 ? "group" : "groups") · \(keys) \(keys == 1 ? "key" : "keys")"
        }
    }

    /// The safety copies that can be read, newest first: the ones on this Mac and, when there is
    /// an iCloud folder, the weekly copies in it.
    public func copies() -> [Copy] {
        let files = FileManager.default
        var found: [Copy] = []
        for (folder, inCloud) in [(backups, false)] + (cloud.map { [($0, true)] } ?? []) {
            let names = ((try? files.contentsOfDirectory(atPath: folder.path)) ?? [])
                .filter { $0.hasPrefix("deck ") && $0.hasSuffix(".json") }
            for name in names {
                let url = folder.appendingPathComponent(name)
                guard let deck = Store.read(url) else { continue }
                let date = ((try? files.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date) ?? .distantPast
                let keys = deck.profiles.reduce(0) { $0 + $1.pages.reduce(0) { $0 + $1.keys.count } }
                found.append(Copy(name: name, date: date, groups: deck.profiles.count, keys: keys, inCloud: inCloud))
            }
        }
        return found.sorted { ($0.date, $0.name) > ($1.date, $1.name) }
    }

    public func deck(of copy: Copy) -> Deck? {
        url(of: copy).flatMap { Store.read($0) }
    }

    /// Where a copy is: the Backups folder on this Mac, or the iCloud folder.
    func url(of copy: Copy) -> URL? {
        (copy.inCloud ? cloud : backups)?.appendingPathComponent(copy.name)
    }

    /// Puts the keys file as it is now into the iCloud folder, named by its day, and keeps the
    /// newest ones. False when there is no iCloud folder, no readable keys file, or the write failed.
    @discardableResult
    public func copyToCloud(now: Date = Date()) -> Bool {
        let files = FileManager.default
        guard let cloud, Store.read(file) != nil, let data = try? Data(contentsOf: file) else { return false }
        do {
            try files.createDirectory(at: cloud, withIntermediateDirectories: true)
            try data.write(to: cloud.appendingPathComponent(CloudCopies.name(for: now)), options: .atomic)
        } catch {
            return false
        }
        copyPicturesToCloud()
        let names = ((try? files.contentsOfDirectory(atPath: cloud.path)) ?? [])
            .filter { $0.hasPrefix("deck ") && $0.hasSuffix(".json") }
            .sorted()
        for name in names.dropLast(CloudCopies.kept) {
            try? files.removeItem(at: cloud.appendingPathComponent(name))
        }
        return true
    }

    /// A file as a setup; nil when it cannot be read or holds no page group at all.
    private static func read(_ url: URL) -> Deck? {
        guard let data = try? Data(contentsOf: url),
              let deck = try? JSONDecoder().decode(Deck.self, from: data), !deck.profiles.isEmpty else { return nil }
        return deck
    }

    // MARK: Starting

    public enum Start: Equatable, Sendable {
        /// No file yet: the very first start.
        case first
        /// The file was read as usual.
        case loaded
        /// The file was damaged: the safety copy written at this time took its place.
        case recovered(Date)
        /// The file was damaged and no safety copy could be read.
        case lost
        /// No file on this Mac, but a weekly copy in iCloud Drive: it became the setup (a new Mac).
        case fromCloud(Date)
    }

    /// Reads the setup at start. A damaged file is never thrown away: it is kept in Backups as
    /// "damaged <time>.json", and the newest safety copy that can be read takes its place.
    public func start() -> (deck: Deck?, how: Start) {
        let files = FileManager.default
        guard hasFile else {
            // A Mac without a keys file: the newest weekly copy in iCloud Drive, when there is one.
            for copy in copies() where copy.inCloud {
                guard let deck = deck(of: copy), let url = url(of: copy), let data = try? Data(contentsOf: url) else { continue }
                try? files.createDirectory(at: folder, withIntermediateDirectories: true)
                try? data.write(to: file, options: .atomic)
                bringBackPictures()
                return (deck, .fromCloud(copy.date))
            }
            return (nil, .first)
        }
        if let deck = load() { return (deck, .loaded) }
        try? files.createDirectory(at: backups, withIntermediateDirectories: true)
        try? files.moveItem(at: file, to: backups.appendingPathComponent("damaged \(Store.stamp()).json"))
        // The newest copy that can be read, on this Mac or among the weekly ones in iCloud Drive.
        for copy in copies() {
            guard let deck = deck(of: copy), let url = url(of: copy), let data = try? Data(contentsOf: url) else { continue }
            try? data.write(to: file, options: .atomic)
            if copy.inCloud { bringBackPictures() }
            return (deck, .recovered(copy.date))
        }
        return (nil, .lost)
    }
}

/// The weekly copies of the keys file in iCloud Drive.
public enum CloudCopies {
    /// How many are kept: about two months.
    public static let kept = 8
    public static let every: TimeInterval = 7 * 24 * 3600

    /// True when it is time for a copy: never made, or the last one is a week old.
    public static func due(last: Date?, now: Date) -> Bool {
        guard let last else { return true }
        return now.timeIntervalSince(last) >= every || last > now
    }

    /// "deck 2026-11-16.json": one a day at most, and the names sort by age.
    public static func name(for date: Date) -> String {
        let day = DateFormatter()
        day.dateFormat = "yyyy-MM-dd"
        day.locale = Locale(identifier: "en_US_POSIX")
        return "deck \(day.string(from: date)).json"
    }
}

/// The box diary must not grow without end.
public enum Diary {
    /// The diary cut down to its last `keep` lines once it has more than `over`; nil = leave it as it is.
    public static func trimmed(_ text: String, over: Int = 1000, keep: Int = 500) -> String? {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        guard lines.count > over else { return nil }
        return lines.suffix(keep).joined(separator: "\n") + "\n"
    }
}
