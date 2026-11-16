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
        /// The key's place: 0 is top left, then left to right, top to bottom, up to 14.
        public var index: Int
        /// The words on the key, for VoiceOver and checks.
        public var title: String
        /// The key as a PNG picture; nil = an empty place.
        public var picture: Data?

        public init(index: Int, title: String, picture: Data?) {
            self.index = index
            self.title = title
            self.picture = picture
        }
    }

    public enum Message: Codable, Equatable, Sendable {
        /// iPhone → Mac, the first thing it says: its name, and the token it was given before (if any).
        /// `version` 2 = the iPhone understands the messages below `press` (left out by the first iPhone app).
        case hello(phone: String, token: String?, version: Int? = nil)
        /// Mac → iPhone: the Mac is asking its owner whether this iPhone may use the keys.
        case waiting
        /// Mac → iPhone: allowed. Keep the token and bring it next time.
        case welcome(token: String, mac: String)
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
    }

    /// The iPhone app version that understands status, pressed, ran, page and profile.
    public static let currentVersion = 2

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

        /// The profile a swipe up (+1) or down (-1) goes to, round the end; nil with fewer than two profiles.
        public func profile(after step: Int) -> String? {
            guard profiles.count > 1 else { return nil }
            let at = profiles.firstIndex { $0.id == current } ?? 0
            return profiles[((at + step) % profiles.count + profiles.count) % profiles.count].id
        }

        public init(profiles: [Choice], current: String, held: Bool, page: Int?, pages: Int) {
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

        public init() {}

        public mutating func add(_ data: Data) -> [Message] {
            guard !broken else { return [] }
            waiting.append(data)
            var found: [Message] = []
            while waiting.count >= 4 {
                let head = waiting.prefix(4).reduce(0) { ($0 << 8) | Int($1) }
                guard head <= PhoneLink.largest else { broken = true; return found }
                guard waiting.count >= 4 + head else { break }
                let body = waiting.dropFirst(4).prefix(head)
                waiting = Data(waiting.dropFirst(4 + head))
                guard let message = try? JSONDecoder().decode(Message.self, from: Data(body)) else {
                    broken = true
                    return found
                }
                found.append(message)
            }
            return found
        }
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
