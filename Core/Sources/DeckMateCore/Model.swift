import Foundation

// The whole setup of AMS Deck Mate: profiles, their pages, and the 15 keys on each page.
// Everything decodes tolerantly: a missing or odd field gets its default, never an error.

extension KeyedDecodingContainer {
    func value<T: Decodable>(_ key: Key, _ fallback: T) -> T {
        (try? decodeIfPresent(T.self, forKey: key)) ?? fallback
    }
}

/// What a key does.
public enum ActionType: String, Codable, CaseIterable, Sendable {
    case none, app, link, raycast, shortcut, text, media, folder, back, nextPage, previousPage, profile, multi

    public init(from decoder: Decoder) throws {
        let raw = (try? decoder.singleValueContainer().decode(String.self)) ?? ""
        self = ActionType(rawValue: raw) ?? .none
    }
}

extension ActionType {
    /// A favourite stays in place on every page and profile, so it cannot be a folder (a folder
    /// belongs to one profile) or Back.
    public var fitsFavourite: Bool { self != .folder && self != .back }
}

/// The kind of a key decides its colour.
public enum KeyKind: String, CaseIterable, Sendable {
    case app, web, raycast, shortcut, text, media, move, empty
}

public enum MediaKey: String, Codable, CaseIterable, Sendable {
    case playPause, next, previous, volumeUp, volumeDown, mute

    public var title: String {
        switch self {
        case .playPause: return "Play or pause"
        case .next: return "Next track"
        case .previous: return "Previous track"
        case .volumeUp: return "Volume up"
        case .volumeDown: return "Volume down"
        case .mute: return "Mute sound"
        }
    }
}

/// A keyboard shortcut: one key with its modifier keys.
public struct KeyCombo: Codable, Hashable, Sendable {
    /// The Mac's own number for the key (virtual key code).
    public var keyCode: Int
    public var command: Bool
    public var control: Bool
    public var option: Bool
    public var shift: Bool
    /// The key in words or as its letter: "M", "F5", "Space".
    public var keyName: String

    public init(keyCode: Int, command: Bool = false, control: Bool = false, option: Bool = false,
                shift: Bool = false, keyName: String) {
        self.keyCode = keyCode
        self.command = command
        self.control = control
        self.option = option
        self.shift = shift
        self.keyName = keyName
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        keyCode = c.value(.keyCode, 0)
        command = c.value(.command, false)
        control = c.value(.control, false)
        option = c.value(.option, false)
        shift = c.value(.shift, false)
        keyName = c.value(.keyName, "")
    }

    /// The shortcut the way the Mac writes it: ⌃⌥⇧⌘M.
    public var label: String {
        (control ? "⌃" : "") + (option ? "⌥" : "") + (shift ? "⇧" : "") + (command ? "⌘" : "") + keyName
    }
}

public struct DeckAction: Codable, Hashable, Sendable {
    public var type: ActionType
    /// What the action points at, by type:
    /// app = bundle identifier, or the app's full path when it starts with "/";
    /// link = web address or file path; raycast = the whole raycast:// link; text = the text to type;
    /// media = a `MediaKey`; folder = the page's id; profile = the profile's id.
    public var target: String
    public var combo: KeyCombo?
    /// The steps of a "several things in a row" key.
    public var steps: [DeckAction]
    /// Raycast only: run without bringing Raycast to the front.
    public var quiet: Bool

    public init(type: ActionType = .none, target: String = "", combo: KeyCombo? = nil,
                steps: [DeckAction] = [], quiet: Bool = false) {
        self.type = type
        self.target = target
        self.combo = combo
        self.steps = steps
        self.quiet = quiet
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = c.value(.type, .none)
        target = c.value(.target, "")
        combo = try? c.decodeIfPresent(KeyCombo.self, forKey: .combo)
        steps = c.value(.steps, [])
        quiet = c.value(.quiet, false)
    }

    public static let none = DeckAction()

    public var kind: KeyKind {
        switch type {
        case .none: return .empty
        case .app: return .app
        case .link: return .web
        case .raycast: return .raycast
        case .shortcut: return .shortcut
        case .text: return .text
        case .media: return .media
        case .folder, .back, .nextPage, .previousPage, .profile: return .move
        case .multi: return steps.first(where: { $0.type != .none })?.kind ?? .shortcut
        }
    }

    /// The icon a key gets when none is picked. Empty for an app key: it shows the app's own icon.
    public var autoIcon: String {
        switch type {
        case .none, .app: return ""
        case .link: return target.lowercased().hasPrefix("http") ? "globe" : "app-openLink"
        case .raycast: return RaycastLink.icon(forLink: target)
        case .shortcut: return "deck-keyboard"
        case .text: return "deck-text"
        case .media:
            switch MediaKey(rawValue: target) ?? .playPause {
            case .playPause: return "deck-play"
            case .next: return "deck-next"
            case .previous: return "deck-previous"
            case .volumeUp: return "deck-volume-up"
            case .volumeDown: return "deck-volume-down"
            case .mute: return "deck-mute"
            }
        case .folder: return "deck-folder"
        case .back: return "deck-back"
        case .nextPage: return "deck-page-next"
        case .previousPage: return "deck-page-previous"
        case .profile: return "deck-profile"
        case .multi: return "deck-multi"
        }
    }
}

public struct DeckKey: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    /// A drawing from the icon set by its name; empty = the automatic one for what the key does.
    public var icon: String
    public var action: DeckAction
    /// What a long press (half a second) does; nil = the same as a short one.
    public var held: DeckAction?

    public init(id: UUID = UUID(), title: String = "", icon: String = "", action: DeckAction = .none,
                held: DeckAction? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.action = action
        self.held = held
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, UUID())
        title = c.value(.title, "")
        icon = c.value(.icon, "")
        action = c.value(.action, .none)
        held = try? c.decodeIfPresent(DeckAction.self, forKey: .held)
    }

    /// True when a long press does something of its own (the key then shows a small dot).
    public var hasHeld: Bool { held.map { $0.type != .none } ?? false }

    /// What a press does: the long-press action for a long press on a key that has one, else the usual one.
    public func action(long: Bool) -> DeckAction {
        if long, hasHeld, let held { return held }
        return action
    }

    public var shownIcon: String { icon.isEmpty ? action.autoIcon : icon }
}

public struct DeckPage: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    /// nil = one of the profile's pages (next / previous page move between them);
    /// set = a folder of keys, opened by a folder key on the page with this id.
    public var parent: UUID?
    /// Keys by place: 0 is top left, then left to right, top to bottom, up to 14.
    public var keys: [Int: DeckKey]

    public init(id: UUID = UUID(), name: String = "", parent: UUID? = nil, keys: [Int: DeckKey] = [:]) {
        self.id = id
        self.name = name
        self.parent = parent
        self.keys = keys
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, UUID())
        name = c.value(.name, "")
        parent = try? c.decodeIfPresent(UUID.self, forKey: .parent)
        keys = c.value(.keys, [:]).filter { (0..<StreamDeckProtocol.keyCount).contains($0.key) }
    }
}

public struct DeckProfile: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    /// Bundle identifiers of the apps this profile belongs to: it shows when one of them comes to the front.
    public var apps: [String]
    public var pages: [DeckPage]

    public init(id: UUID = UUID(), name: String = "", apps: [String] = [], pages: [DeckPage] = []) {
        self.id = id
        self.name = name
        self.apps = apps
        self.pages = pages
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, UUID())
        name = c.value(.name, "")
        apps = c.value(.apps, [])
        pages = c.value(.pages, [])
    }

    /// The pages in order, without the folders.
    public var topPages: [DeckPage] { pages.filter { $0.parent == nil } }

    public func page(_ id: UUID) -> DeckPage? { pages.first { $0.id == id } }
}

public struct Deck: Codable, Equatable, Sendable {
    public var version: Int
    public var profiles: [DeckProfile]
    /// The profile for every app that has no profile of its own.
    public var defaultProfile: UUID?
    /// Brightness of the box, 0 to 100.
    public var brightness: Int
    /// Change the profile by itself when another app comes to the front.
    public var autoSwitch: Bool
    /// Keys on screen: appear at the mouse pointer instead of where he left them.
    public var screenAtPointer: Bool
    /// Keys on screen: hide by themselves after a key that did something on the Mac.
    public var screenHidesAfterKey: Bool
    /// Keys on screen: small, normal or large.
    public var screenSize: ScreenSize
    /// The favourites row of the iPhone and iPad: up to five keys (places 0–4) that belong to no
    /// page and no profile, so they stay in place everywhere.
    public var favourites: [Int: DeckKey]

    public init(version: Int = 1, profiles: [DeckProfile] = [], defaultProfile: UUID? = nil,
                brightness: Int = 70, autoSwitch: Bool = true, screenAtPointer: Bool = false,
                screenHidesAfterKey: Bool = false, screenSize: ScreenSize = .normal,
                favourites: [Int: DeckKey] = [:]) {
        self.version = version
        self.profiles = profiles
        self.defaultProfile = defaultProfile
        self.brightness = brightness
        self.autoSwitch = autoSwitch
        self.screenAtPointer = screenAtPointer
        self.screenHidesAfterKey = screenHidesAfterKey
        self.screenSize = screenSize
        self.favourites = favourites
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = c.value(.version, 1)
        profiles = c.value(.profiles, [])
        defaultProfile = try? c.decodeIfPresent(UUID.self, forKey: .defaultProfile)
        brightness = min(100, max(0, c.value(.brightness, 70)))
        autoSwitch = c.value(.autoSwitch, true)
        screenAtPointer = c.value(.screenAtPointer, false)
        screenHidesAfterKey = c.value(.screenHidesAfterKey, false)
        screenSize = c.value(.screenSize, .normal)
        favourites = c.value(.favourites, [:]).filter {
            (0..<PhoneLink.favouriteCount).contains($0.key) && $0.value.action.type.fitsFavourite
        }
    }

    public func profile(_ id: UUID) -> DeckProfile? { profiles.first { $0.id == id } }

    /// The default profile, or the first one when the default is gone.
    public var fallbackProfile: DeckProfile? {
        defaultProfile.flatMap { profile($0) } ?? profiles.first
    }

    /// The setup without folders that hold nothing but a Back key, and without the keys that opened them.
    /// (Elgato's tutorial folder ends up like that once its tutorial keys are left out.)
    public func droppingEmptyFolders() -> Deck {
        var tidy = self
        for index in tidy.profiles.indices {
            var gone = Set<UUID>()
            var grew = true
            while grew {
                grew = false
                for page in tidy.profiles[index].pages where page.parent != nil && !gone.contains(page.id) {
                    let useful = page.keys.values.contains { key in
                        if key.action.type == .back || key.action.type == .none { return false }
                        if key.action.type == .folder, let id = UUID(uuidString: key.action.target), gone.contains(id) { return false }
                        return true
                    }
                    if !useful {
                        gone.insert(page.id)
                        grew = true
                    }
                }
            }
            guard !gone.isEmpty else { continue }
            tidy.profiles[index].pages.removeAll { gone.contains($0.id) }
            for page in tidy.profiles[index].pages.indices {
                tidy.profiles[index].pages[page].keys = tidy.profiles[index].pages[page].keys.filter { _, key in
                    !(key.action.type == .folder && UUID(uuidString: key.action.target).map(gone.contains) == true)
                }
            }
        }
        return tidy
    }

    /// A first setup for a Mac with nothing to bring over: one profile, one empty page.
    public static func starter() -> Deck {
        let profile = DeckProfile(name: "Default", pages: [DeckPage(name: "Page 1")])
        return Deck(profiles: [profile], defaultProfile: profile.id)
    }
}
