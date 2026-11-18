import AppIntents
import AppKit
import DeckMateCore

// Apple's Shortcuts app can press a key, show a page group, and show or hide the keys on screen.
// The actions run inside the running AMS Deck Mate, without opening a window, and follow the same
// switch as Raycast and links (Settings › Raycast and links).

/// A plain message for Shortcuts.
struct DeckIntentError: Error, CustomLocalizedStringResourceConvertible {
    let words: String
    var localizedStringResource: LocalizedStringResource { LocalizedStringResource(stringLiteral: words) }
}

@MainActor
private func deckModel() throws -> AppModel {
    if let why = AppModel.outsideProblem { throw DeckIntentError(words: why) }
    guard let model = AppModel.shared else { throw DeckIntentError(words: "AMS Deck Mate is not ready yet. Try again in a moment.") }
    return model
}

/// A key that has words and does something, chosen from a list.
struct DeckKeyEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Deck Mate key")
    static let defaultQuery = DeckKeyQuery()

    var id: String
    var title: String
    var place: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(place)")
    }
}

struct DeckKeyQuery: EntityQuery {
    @MainActor
    private func all() -> [DeckKeyEntity] {
        guard let model = AppModel.shared else { return [] }
        var found: [DeckKeyEntity] = []
        for group in model.deck.profiles {
            for page in group.pages {
                for index in page.keys.keys.sorted() {
                    guard let key = page.keys[index], !DeckLinks.notFromOutside.contains(key.action.type) else { continue }
                    let title = Outside.name(key).split(whereSeparator: \.isNewline).joined(separator: " ")
                    guard !title.isEmpty else { continue }
                    let place = [group.name, page.name].filter { !$0.isEmpty }.joined(separator: " › ")
                    found.append(DeckKeyEntity(id: key.id.uuidString, title: title, place: place))
                }
            }
        }
        return found
    }

    @MainActor func entities(for identifiers: [String]) async throws -> [DeckKeyEntity] {
        all().filter { identifiers.contains($0.id) }
    }

    @MainActor func suggestedEntities() async throws -> [DeckKeyEntity] { all() }
}

struct PressDeckKeyIntent: AppIntent {
    static let title: LocalizedStringResource = "Press a Deck Mate key"
    static let description = IntentDescription("Presses one of your Deck Mate keys, as if you had pressed it on the box.")
    static let openAppWhenRun = false

    @Parameter(title: "Key") var key: DeckKeyEntity

    static var parameterSummary: some ParameterSummary { Summary("Press the Deck Mate key \(\.$key)") }

    @MainActor func perform() async throws -> some IntentResult {
        let model = try deckModel()
        guard model.pressFromShortcuts(keyID: key.id) else {
            throw DeckIntentError(words: "That key is gone. Choose the key again in the action.")
        }
        return .result()
    }
}

/// A page group, chosen from a list.
struct DeckGroupEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Deck Mate page group")
    static let defaultQuery = DeckGroupQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
}

struct DeckGroupQuery: EntityQuery {
    @MainActor
    private func all() -> [DeckGroupEntity] {
        (AppModel.shared?.deck.profiles ?? []).map { DeckGroupEntity(id: $0.id.uuidString, name: $0.name.isEmpty ? "No name" : $0.name) }
    }

    @MainActor func entities(for identifiers: [String]) async throws -> [DeckGroupEntity] {
        all().filter { identifiers.contains($0.id) }
    }

    @MainActor func suggestedEntities() async throws -> [DeckGroupEntity] { all() }
}

struct ShowDeckGroupIntent: AppIntent {
    static let title: LocalizedStringResource = "Show a Deck Mate page group"
    static let description = IntentDescription("Shows a page group on the Mac’s keys and the box. It is not locked: the next app that comes forward takes over again.")
    static let openAppWhenRun = false

    @Parameter(title: "Page group") var group: DeckGroupEntity

    static var parameterSummary: some ParameterSummary { Summary("Show the Deck Mate page group \(\.$group)") }

    @MainActor func perform() async throws -> some IntentResult {
        let model = try deckModel()
        guard let id = UUID(uuidString: group.id), model.deck.profile(id) != nil else {
            throw DeckIntentError(words: "That page group is gone. Choose it again in the action.")
        }
        model.visit(id)
        return .result()
    }
}

struct ToggleDeckKeysIntent: AppIntent {
    static let title: LocalizedStringResource = "Show or hide the Deck Mate keys on screen"
    static let description = IntentDescription("Shows the Deck Mate keys on the Mac’s screen, or hides them when they are showing.")
    static let openAppWhenRun = false

    @MainActor func perform() async throws -> some IntentResult {
        _ = try deckModel()
        // The same way a link does it: the keys on screen belong to the app's window, not to the model.
        guard let url = URL(string: "\(DeckLinks.scheme)://keys?pass=\(Outside.pass)") else { return .result() }
        NSApp.delegate?.application?(NSApp, open: [url])
        return .result()
    }
}
