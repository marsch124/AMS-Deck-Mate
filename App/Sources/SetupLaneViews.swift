import AppKit
import DeckMateCore
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

// 0.16, making keys easier: wrong input said at once, a key from what is in front of him,
// the deck suggesting a key, and the keys as a PDF.

private let problemRed = Color(red: 0.86, green: 0.16, blue: 0.14)

extension Notification.Name {
    /// Save was pressed in the key editor: fields that look something up do it now.
    static let deckKeySaving = Notification.Name("AMSDeckMateKeySaving")
}

// MARK: Town look-up

/// Asks the free Open-Meteo town search whether a town is there, the same one the keys use.
enum TownLookup {
    enum Answer: Equatable {
        case found(String)
        case missing
    }

    /// nil = no answer from the network: nothing is said then.
    static func look(_ town: String, done: @escaping (Answer?) -> Void) {
        guard let url = WeatherKeys.searchURL(town) else { done(nil); return }
        let request = URLRequest(url: url, timeoutInterval: 8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            let answer: Answer? = {
                guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200, let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
                guard let first = (json["results"] as? [[String: Any]])?.first, let name = first["name"] as? String else { return .missing }
                let country = first["country"] as? String ?? ""
                return .found(country.isEmpty ? name : "\(name), \(country)")
            }()
            DispatchQueue.main.async { done(answer) }
        }.resume()
    }
}

/// The town field of the Weather, World clock and Sunrise and sunset keys: when he leaves the field
/// or presses Save, the town is looked up and the place found (or "not found") is said under it.
struct TownField: View {
    @Binding var text: String
    let identifier: String
    @FocusState private var focused: Bool
    @State private var said: TownLookup.Answer?
    @State private var checked = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            TextField("Town", text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .accessibilityIdentifier(identifier)
                .onSubmit { look() }
                .onChange(of: focused) { _, now in if !now { look() } }
                .onChange(of: text) { _, now in if now.trimmingCharacters(in: .whitespaces) != checked { said = nil } }
            switch said {
            case .missing:
                Text("Town not found. Check the spelling.")
                    .font(.caption).foregroundStyle(problemRed)
                    .accessibilityIdentifier("townMissing")
            case let .found(place):
                Text(place).font(.caption).foregroundStyle(.secondary)
                    .accessibilityIdentifier("townFound")
            case nil:
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deckKeySaving)) { _ in look() }
    }

    private func look() {
        let town = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !town.isEmpty, town != checked else { return }
        checked = town
        TownLookup.look(town) { answer in
            guard text.trimmingCharacters(in: .whitespacesAndNewlines) == town else { return }
            if let answer { said = answer } else { checked = "" }
        }
    }
}

// MARK: Raycast commands that are on this Mac

/// Which commands of Raycast extensions are installed here (read from the extensions folder, and
/// read again after half a minute).
enum RaycastInstalled {
    private static var found: Set<String> = []
    private static var read = Date.distantPast

    static func has(_ owner: String, _ ext: String, _ command: String) -> Bool {
        if Date().timeIntervalSince(read) > 30 { load() }
        return found.contains("\(owner)/\(ext)/\(command)".lowercased())
    }

    private static func load() {
        read = Date()
        var all = Set<String>()
        let root = RaycastCatalog.extensionsFolder
        for name in (try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? [] {
            guard let data = try? Data(contentsOf: root.appendingPathComponent(name).appendingPathComponent("package.json")),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let ext = json["name"] as? String else { continue }
            let commands = ((json["commands"] as? [[String: Any]]) ?? []).compactMap { $0["name"] as? String }
            // Links name the owner when there is one, else the author: both find it.
            for owner in [json["owner"] as? String, json["author"] as? String].compactMap({ $0 }) where !owner.isEmpty {
                for command in commands { all.insert("\(owner)/\(ext)/\(command)".lowercased()) }
            }
        }
        found = all
    }
}

// MARK: A key from what is in front of him

extension AppModel {
    enum Placed {
        case placed(String)
        case full
        case nowhere
    }

    /// Puts a key on the first empty place of the page showing now (one `change`, so Undo takes it back).
    func addKeyHere(_ key: DeckKey) -> Placed {
        guard let position, let group = deck.profile(position.profile), let page = group.page(position.page) else { return .nowhere }
        var place: Int?
        change { place = $0.addKey(key.copied(), to: page.id, in: group.id) }
        guard let place else { return .full }
        let name = page.name.isEmpty ? group.name : "\(group.name) · \(page.name)"
        return .placed("Added as key \(place + 1) on \(name).")
    }

    /// The choices of the menu "New key from…": the app in front, the link he copied, the file opened last.
    func newKeyChoices() -> [(title: String, key: DeckKey)] {
        var all: [(String, DeckKey)] = []
        if let app = frontApp, KeyArt.appURL(app) != nil {
            all.append(("App: " + KeyArt.appName(app), DeckKey(action: DeckAction(type: .app, target: app))))
        }
        if let link = KeyFrom.copiedLink(ClipboardWatch.copiedText()) {
            all.append(("Link: " + (link.title.isEmpty ? "copied link" : link.title), link))
        }
        if let file = recentFiles.first, FileManager.default.fileExists(atPath: file) {
            let key = Drops.key(forFile: (file as NSString).abbreviatingWithTildeInPath, bundleID: nil)
            all.append(("File: " + (file as NSString).lastPathComponent, key))
        }
        return all
    }
}

// MARK: The deck suggests a key

/// Counts the days each app came to the front (the last 14), in "apps.json" beside the keys file.
final class AppDaysKeeper: ObservableObject {
    static let shared = AppDaysKeeper()
    @Published private(set) var days = AppDays()
    private var file: URL?
    private var loaded = false

    /// Pictures and checks keep nothing and read nothing.
    private func keeps(_ model: AppModel) -> Bool {
        !model.isSample && !CommandLine.arguments.contains("--checks")
    }

    func load(_ model: AppModel) {
        guard !loaded else { return }
        loaded = true
        guard keeps(model) else {
            // Pictures: a made-up app used on 9 of 14 days.
            if model.isSample {
                var sample = AppDays()
                for back in 0..<9 { sample.days["com.apple.Music", default: []].append(AppDays.day(model.useNow.addingTimeInterval(Double(-back) * 86_400), calendar: .current)) }
                days = sample
            }
            return
        }
        let url = model.store.folder.appendingPathComponent("apps.json")
        file = url
        if let data = try? Data(contentsOf: url), let kept = try? JSONDecoder().decode(AppDays.self, from: data) { days = kept }
    }

    /// An app came to the front.
    func came(_ app: String?, model: AppModel) {
        guard let app, keeps(model) else { return }
        load(model)
        var new = days
        new.record(app, now: Date())
        guard new != days else { return }
        days = new
        save()
    }

    func decline(_ app: String, model: AppModel) {
        guard !days.declined.contains(app) else { return }
        load(model)
        days.declined.append(app)
        save()
    }

    func suggestion(for model: AppModel) -> AppDays.Suggestion? {
        days.suggestion(in: model.deck, now: model.useNow)
    }

    private func save() {
        guard let file, let data = try? JSONEncoder().encode(days) else { return }
        try? data.write(to: file, options: .atomic)
    }
}

/// One calm card on top of Settings › Key use, only while there is a suggestion.
struct AppSuggestionCard: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var keeper = AppDaysKeeper.shared
    @State private var said: (words: String, ok: Bool)?
    @Environment(\.colorScheme) private var scheme

    init(model: AppModel) {
        self.model = model
        AppDaysKeeper.shared.load(model)
    }

    var body: some View {
        let suggestion = keeper.suggestion(for: model)
        Group {
            if let said {
                Text(said.words).foregroundStyle(said.ok ? Color.primary : problemRed)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("suggestionDone")
            } else if let suggestion {
                VStack(alignment: .leading, spacing: 6) {
                    Text("A key for \(KeyArt.appName(suggestion.app))?")
                        .font(.headline).foregroundStyle(Palette.part("keys", scheme))
                    Text("You used it on \(suggestion.days) of the last \(AppDays.window) days and it has no key.")
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        Button("Add a key") { add(suggestion) }
                            .buttonStyle(MainButton(part: "keys"))
                            .fixedSize()
                            .accessibilityIdentifier("suggestionAdd")
                        Button("Not this one") { keeper.decline(suggestion.app, model: model) }
                            .buttonStyle(PlainButton())
                            .accessibilityIdentifier("suggestionNo")
                        Spacer()
                    }
                }
                .accessibilityIdentifier("suggestion")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(suggestion != nil || said != nil ? 10 : 0)
        .background(suggestion != nil || said != nil ? Color.primary.opacity(0.05) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(height: suggestion == nil && said == nil ? 0 : nil)
        .onAppear { keeper.load(model) }
    }

    private func add(_ suggestion: AppDays.Suggestion) {
        switch model.addKeyHere(DeckKey(action: DeckAction(type: .app, target: suggestion.app))) {
        case let .placed(words): said = (words, true)
        case .full: said = ("This page is full. Show a page with an empty place, then add the key again. Nothing was changed.", false)
        case .nowhere: said = ("There is no page showing yet. Nothing was changed.", false)
        }
    }
}

// MARK: Save my keys as a PDF

/// Every page group with its pages as small pictures and names, on A4 sheets.
enum KeysPDF {
    private static let sheet = CGSize(width: 595, height: 842)
    private static let margin: CGFloat = 36
    private static let columns = 3
    private static let cell = CGSize(width: 144, height: 114)
    private static let gap: CGFloat = 14

    private enum Block {
        case title
        case group(String, String)
        case row([DeckPage])
        var height: CGFloat {
            switch self {
            case .title: return 46
            case .group: return 30
            case .row: return KeysPDF.cell.height + KeysPDF.gap
            }
        }
    }

    private static func sheets(of deck: Deck, note: (DeckProfile) -> String) -> [[Block]] {
        var blocks: [[Block]] = [[]]
        var used: CGFloat = 0
        let room = sheet.height - margin * 2
        func put(_ block: Block, keepWith next: CGFloat = 0) {
            if used + block.height + next > room { blocks.append([]); used = 0 }
            blocks[blocks.count - 1].append(block)
            used += block.height
        }
        put(.title)
        for group in deck.profiles {
            var first = true
            var index = 0
            while index < group.pages.count || first {
                if first { put(.group(group.name.isEmpty ? "No name" : group.name, note(group)), keepWith: Block.row([]).height); first = false }
                guard index < group.pages.count else { break }
                put(.row(Array(group.pages[index..<min(index + columns, group.pages.count)])))
                index += columns
            }
        }
        return blocks.filter { !$0.isEmpty }
    }

    private struct Sheet: View {
        let blocks: [Block]
        let number: Int
        let count: Int

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .title:
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deck Mate keys").font(.title2.weight(.semibold)).foregroundStyle(Color(nsColor: Palette.brand))
                            Text(Date().formatted(date: .long, time: .omitted)).font(.caption).foregroundStyle(.gray)
                        }
                        .frame(height: block.height, alignment: .topLeading)
                    case let .group(name, note):
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(name).font(.headline).foregroundStyle(Color(nsColor: Palette.tile(.shortcut)))
                            Text(note).font(.caption).foregroundStyle(.gray).lineLimit(1)
                        }
                        .frame(height: block.height, alignment: .topLeading)
                    case let .row(pages):
                        HStack(alignment: .top, spacing: KeysPDF.gap) {
                            ForEach(pages) { page in MiniPage(page: page, current: false).frame(width: KeysPDF.cell.width, alignment: .leading) }
                        }
                        .frame(height: block.height, alignment: .topLeading)
                    }
                }
                Spacer(minLength: 0)
                Text("Page \(number) of \(count)").font(.caption2).foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundStyle(.black)
            .environment(\.colorScheme, .light)
            .padding(KeysPDF.margin)
            .frame(width: KeysPDF.sheet.width, height: KeysPDF.sheet.height, alignment: .topLeading)
            .background(Color.white)
        }
    }

    /// The PDF of the whole setup, drawn as lines and pictures on A4 sheets.
    @MainActor
    static func data(for deck: Deck, note: (DeckProfile) -> String) -> Data? {
        let all = sheets(of: deck, note: note)
        let data = NSMutableData()
        var box = CGRect(origin: .zero, size: sheet)
        guard let consumer = CGDataConsumer(data: data), let context = CGContext(consumer: consumer, mediaBox: &box, nil) else { return nil }
        for (index, blocks) in all.enumerated() {
            let renderer = ImageRenderer(content: Sheet(blocks: blocks, number: index + 1, count: all.count))
            renderer.proposedSize = ProposedViewSize(sheet)
            renderer.render { _, draw in
                context.beginPDFPage(nil)
                draw(context)
                context.endPDFPage()
            }
        }
        context.closePDF()
        return data as Data
    }

    /// Asks where to put it, writes it, and opens it. Says so when it cannot be written.
    @MainActor
    static func save(deck: Deck, note: (DeckProfile) -> String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "Deck Mate keys.pdf"
        panel.prompt = "Save"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let data = data(for: deck, note: note), (try? data.write(to: url, options: .atomic)) != nil else {
            let alert = NSAlert()
            alert.messageText = "The PDF could not be saved."
            alert.informativeText = "Try another place."
            alert.runModal()
            return
        }
        NSWorkspace.shared.open(url)
    }
}
