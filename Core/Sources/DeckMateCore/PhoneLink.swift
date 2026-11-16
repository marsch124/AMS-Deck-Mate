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
        case hello(phone: String, token: String?)
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
