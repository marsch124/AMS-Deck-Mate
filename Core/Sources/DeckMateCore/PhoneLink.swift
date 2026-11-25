import Foundation

/// What the Mac and the iPhone say to each other. They find each other nearby (like AirDrop, also
/// without a shared Wi-Fi) under `service`. One message on the wire = 4 bytes of length, then JSON.
public enum PhoneLink {
    /// The Bonjour name the Mac offers its keys under on a shared network (home or hotel Wi-Fi).
    public static let service = "_amsdeckmate._tcp"
    /// The same offer directly, without a shared network (like AirDrop), where the Mac allows it.
    public static let directService = "_amsdeckdirect._tcp"
    /// No message is larger than this (15 key pictures are about 300 KB); anything larger = a broken line.
    public static let largest = 4_000_000

    /// One key as the iPhone shows it: the Mac draws it, the iPhone only shows the picture.
    public struct Key: Codable, Equatable, Sendable {
        /// The key's place: 0 is top left, then left to right, top to bottom, up to 14. With several
        /// pages at once (version 9) the second page's keys go on at 15, the third's at 30, the fourth's at 45.
        public var index: Int
        /// The words on the key, for VoiceOver and checks.
        public var title: String
        /// The key as a PNG picture; nil = an empty place.
        public var picture: Data?
        /// What the key does, in a few words, for "Explain" on the iPhone and iPad (version 10; a Mac
        /// before 0.20 leaves all three out): a tap, a hold (nil = the same as a tap), a double press
        /// (nil = it has none).
        public var tap: String?
        public var hold: String?
        public var twice: String?

        public init(index: Int, title: String, picture: Data?, tap: String? = nil, hold: String? = nil,
                    twice: String? = nil) {
            self.index = index
            self.title = title
            self.picture = picture
            self.tap = tap
            self.hold = hold
            self.twice = twice
        }
    }

    public enum Message: Codable, Equatable, Sendable {
        /// iPhone → Mac, the first thing it says: its name, and the token it was given before (if any).
        /// `version` 2 = the iPhone understands the messages below `press` (left out by the first iPhone app).
        case hello(phone: String, token: String?, version: Int? = nil, proof: String? = nil)
        /// Mac → iPhone: the Mac is asking its owner whether this iPhone may use the keys.
        case waiting
        /// Mac → iPhone: allowed. Keep the token and bring it next time.
        /// `version` 3 = the Mac understands `own`, `hold`, `favourite` and `music` (left out by Mac apps before 0.5).
        case welcome(token: String, mac: String, version: Int? = nil, proof: String? = nil)
        /// Mac → iPhone: not allowed.
        case refused
        /// Mac → iPhone: the keys as they are now, with the line on top ("OmniFocus · Page 2").
        case keys(place: String, keys: [Key])
        /// iPhone → Mac: a key was tapped.
        case press(index: Int)
        /// Mac → iPhone (version 2): the profiles to choose from and where the deck is.
        case status(Status)
        /// Mac → iPhone (version 2): a key was pressed somewhere (box, screen or iPhone): light it up.
        case pressed(index: Int)
        /// Mac → iPhone (version 2): what a key did, in a few words; `ok` false = the Mac could not do it.
        case ran(text: String, ok: Bool)
        /// iPhone → Mac (version 2): a swipe: +1 = next page, -1 = page before.
        case page(step: Int)
        /// iPhone → Mac (version 2): hold this profile (its id), or nil = Automatic.
        case profile(id: String?)
        /// iPhone → Mac (version 3): "My own keys" in this profile (its id); nil = follow the Mac again.
        case own(profile: String?)
        /// iPhone → Mac (version 3): a key was held for half a second: its long-press action.
        case hold(index: Int)
        /// iPhone → Mac (version 3): a key of the favourites row (0–4) was tapped, or held (`long`).
        case favourite(index: Int, long: Bool)
        /// iPhone → Mac (version 3): a button of the music strip.
        case music(command: MusicCommand)
        /// Mac → iPhone (version 3): the favourites row, five places.
        case favourites(keys: [Key])
        /// Mac → iPhone (version 3): the Mac at a glance and what is playing.
        case mac(MacNow)
        /// Mac → iPhone (version 4): every page group with its pages as small pictures, for the navigation picture.
        case map(groups: [MapGroup])
        /// iPhone → Mac (version 4): a page of the navigation picture was tapped: go there.
        case go(profile: String, page: String)
        /// Mac → iPhone (version 5): the Mac's screen went to sleep (true) or woke (false).
        case asleep(Bool)
        /// iPhone → Mac (version 6): a swipe up or down: show this page group WITHOUT locking it
        /// (it follows the app in front again at the next app change).
        case visit(profile: String)
        /// Both ways (version 7), the start of a private line and the only message ever sent readable:
        /// first the iPhone's `promise`, then the Mac's `key`, then the iPhone's `key` (see `SecureLine`).
        case secure(promise: String?, key: String?)
        /// Mac → iPhone (version 8): only these keys look different now; the others stay as they are.
        /// A timer's second then sends one small picture instead of all fifteen.
        case some(place: String, keys: [Key])
        /// iPhone → Mac (version 8), every few seconds: "are you there?"; the Mac answers `pong`. A line
        /// that stays quiet is a dead one, however connected it looks.
        case ping
        case pong
        /// iPhone → Mac (version 9): "Several pages at once": show me this many pages (1 = one, as ever;
        /// at most `mostTiles`). The keys then come as one long list, 15 per page.
        case wide(count: Int)
        /// Mac → iPhone (version 9): the names of the pages shown at once. `at` (Mac 0.19): which of
        /// them is the page the device is on; nil from an older Mac = the first.
        case tiles(names: [String], at: Int? = nil)

        /// The oldest version of the other side that understands this message. Anything newer than
        /// the other side knows must not be sent: it would close the line.
        public var since: Int {
            switch self {
            case .hello, .waiting, .welcome, .refused, .keys, .press: return 1
            case .status, .pressed, .ran, .page, .profile: return 2
            case .own, .hold, .favourite, .music, .favourites, .mac: return 3
            case .map, .go: return 4
            case .asleep: return 5
            case .visit: return 6
            case .secure: return 7
            case .some, .ping, .pong: return 8
            case .wide, .tiles: return 9
            }
        }
    }

    /// The version that understands everything above: 2 = status, pressed, ran, page and profile;
    /// 3 = own keys, long press, favourites, the Mac at a glance and the music strip.
    /// 4 = the navigation picture; 5 = the Mac says when it sleeps; 6 = a swipe shows a page group without locking it.
    /// 7 = the line is private: sealed from its first moment (`SecureLine`); older versions are no longer answered.
    /// 8 = only the keys that changed are sent, and the iPhone asks "are you there?" every few seconds.
    /// 9 = several pages at once (`wide`, `tiles`), for an iPhone or iPad used without the box.
    /// 10 = every key comes with the words for what it does (`tap`, `hold`, `twice`), for "Explain".
    public static let currentVersion = 10

    /// "Several pages at once": at most this many pages (an iPad: two above, two below).
    public static let mostTiles = 4
    /// How many pages each kind of device shows at once.
    public static func tiles(pad: Bool) -> Int { pad ? 4 : 2 }
    /// Which page of the ones shown a key belongs to, and its place on that page.
    public static func tile(of index: Int) -> (tile: Int, place: Int) {
        (index / StreamDeckProtocol.keyCount, index % StreamDeckProtocol.keyCount)
    }

    /// The iPhone asks "are you there?" this often, and gives the line up when nothing at all came
    /// from the Mac for `quietLimit` seconds (two answers missed). The Mac closes a line it has not
    /// heard from for `macQuietLimit` seconds.
    public static let pingEvery: TimeInterval = 5
    public static let quietLimit: TimeInterval = 12
    public static let macQuietLimit: TimeInterval = 20

    /// True when a line has been quiet for too long to still be alive.
    public static func isDead(lastHeard: Date, now: Date, limit: TimeInterval = quietLimit) -> Bool {
        now.timeIntervalSince(lastHeard) > limit
    }

    /// The keys that look different from what the iPhone has; nil = it has none yet (or another
    /// number of them), so all of them must go.
    public static func changed(from old: [Key]?, to new: [Key]) -> [Key]? {
        guard let old, old.count == new.count else { return nil }
        return zip(old, new).filter { $0 != $1 }.map(\.1)
    }

    /// No message from an iPhone is larger than this (a hello, a press): the Mac reads nothing bigger.
    public static let largestFromPhone = 65_536

    /// One page group of the navigation picture.
    public struct MapGroup: Codable, Equatable, Sendable {
        public struct Page: Codable, Equatable, Sendable {
            public var id: String
            public var name: String
            /// True for a folder of keys.
            public var folder: Bool
            /// The page's 15 keys as one small PNG picture.
            public var picture: Data?
            public init(id: String, name: String, folder: Bool, picture: Data?) {
                self.id = id; self.name = name; self.folder = folder; self.picture = picture
            }
        }
        public var id: String
        public var name: String
        public var pages: [Page]
        public init(id: String, name: String, pages: [Page]) { self.id = id; self.name = name; self.pages = pages }
    }
    /// How many keys the favourites row has.
    public static let favouriteCount = 5

    public enum MusicCommand: String, Codable, Sendable {
        case playPause, next, volumeUp, volumeDown
    }

    /// The Mac at a glance, for the iPhone's top line and music strip.
    public struct MacNow: Codable, Equatable, Sendable {
        /// The battery in percent; nil = a Mac without a battery.
        public var battery: Int?
        public var charging: Bool
        /// The name of the app in front on the Mac; empty = not known.
        public var app: String
        /// What is playing; empty = nothing heard of yet.
        public var song: String
        public var artist: String
        public var playing: Bool
        /// The Mac's sound volume in percent; nil = not known.
        public var volume: Int?

        public init(battery: Int? = nil, charging: Bool = false, app: String = "", song: String = "",
                    artist: String = "", playing: Bool = false, volume: Int? = nil) {
            self.battery = battery
            self.charging = charging
            self.app = app
            self.song = song
            self.artist = artist
            self.playing = playing
            self.volume = volume
        }

        /// The words for the top line: "82 % · Safari", "82 % charging · Safari", or only the app.
        public var glance: String {
            var bits: [String] = []
            if let battery { bits.append(charging ? "\(battery) % charging" : "\(battery) %") }
            if !app.isEmpty { bits.append(app) }
            return bits.joined(separator: " · ")
        }

        /// The volume after a step louder (+1) or quieter (-1): 6 points a step, kept within 0–100.
        public static func volume(_ now: Int, step: Int) -> Int { min(100, max(0, now + step * 6)) }
    }

    /// The profiles and pages, for the iPhone's top line and page dots.
    public struct Status: Codable, Equatable, Sendable {
        public struct Choice: Codable, Equatable, Sendable {
            public var id: String
            public var name: String
            public init(id: String, name: String) { self.id = id; self.name = name }
        }
        public var profiles: [Choice]
        /// The profile showing now.
        public var current: String
        /// True when a profile is held by hand; false = Automatic.
        public var held: Bool
        /// The page showing now among the profile's pages (0 = first); nil inside a folder.
        public var page: Int?
        public var pages: Int
        /// The page showing now, by its id (from Mac 0.6; also set inside a folder).
        public var pageID: String?

        /// The profile a swipe up (+1) or down (-1) goes to, round the end; nil with fewer than two profiles.
        public func profile(after step: Int) -> String? {
            guard profiles.count > 1 else { return nil }
            let at = profiles.firstIndex { $0.id == current } ?? 0
            return profiles[((at + step) % profiles.count + profiles.count) % profiles.count].id
        }

        public init(profiles: [Choice], current: String, held: Bool, page: Int?, pages: Int, pageID: String? = nil) {
            self.pageID = pageID
            self.profiles = profiles
            self.current = current
            self.held = held
            self.page = page
            self.pages = pages
        }
    }

    /// A message ready to send: its length in 4 bytes (big end first), then the JSON.
    public static func frame(_ message: Message) -> Data {
        let body = (try? JSONEncoder().encode(message)) ?? Data()
        var length = UInt32(body.count).bigEndian
        var data = Data(bytes: &length, count: 4)
        data.append(body)
        return data
    }

    /// Collects the bytes as they come in and hands out whole messages. Bytes arrive in any pieces:
    /// half a message, or three at once.
    public struct Reader: Sendable {
        private var waiting = Data()
        /// True once something arrived that cannot be a message: the line should be closed.
        public private(set) var broken = false
        /// A message longer than this breaks the line.
        public var limit = PhoneLink.largest

        public init() {}

        /// Takes in bytes as they arrive.
        public mutating func feed(_ data: Data) {
            guard !broken else { return }
            waiting.append(data)
        }

        /// The next whole message, or nil when none is complete yet. With a `session` every message
        /// must be sealed by it; without one only readable messages are understood. One at a time,
        /// because the message that starts the private line changes how the next one is read.
        public mutating func next(_ session: inout SecureLine.Session?) -> Message? {
            guard !broken, waiting.count >= 4 else { return nil }
            let head = waiting.prefix(4).reduce(0) { ($0 << 8) | Int($1) }
            guard head <= limit else { broken = true; return nil }
            guard waiting.count >= 4 + head else { return nil }
            var body = Data(waiting.dropFirst(4).prefix(head))
            waiting = Data(waiting.dropFirst(4 + head))
            if session != nil {
                guard let opened = session?.open(body) else { broken = true; return nil }
                body = opened
            }
            guard let message = try? JSONDecoder().decode(Message.self, from: body) else {
                broken = true
                return nil
            }
            return message
        }

        /// Every whole readable message in `data` (a line that is not sealed).
        public mutating func add(_ data: Data) -> [Message] {
            feed(data)
            var found: [Message] = []
            var none: SecureLine.Session?
            while let message = next(&none) { found.append(message) }
            return found
        }
    }

    /// A framed message sealed for a private line: its length, then the sealed JSON. nil without a line.
    public static func sealed(_ frame: Data, by session: inout SecureLine.Session?) -> Data? {
        guard session != nil, frame.count >= 4, let body = session?.seal(Data(frame.dropFirst(4))) else { return nil }
        var length = UInt32(body.count).bigEndian
        var data = Data(bytes: &length, count: 4)
        data.append(body)
        return data
    }
}

extension DeckKey {
    /// The words shown on the key. An app key without words of its own shows the app's name
    /// (`appName` turns the key's target into the name, e.g. "/Applications/Safari.app" into "Safari").
    public func shownTitle(appName: (String) -> String) -> String {
        let own = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard own.isEmpty, action.type == .app, !action.target.isEmpty else { return own }
        return appName(action.target)
    }
}
