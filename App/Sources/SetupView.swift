import AppKit
import DeckMateCore
import SwiftUI

/// "Set up keys": profiles on the left, the 15 keys in the middle, the picked key on the right.
struct SetupView: View {
    @ObservedObject var model: AppModel
    var close: () -> Void = {}

    @State private var profileID: UUID?
    @State private var pageID: UUID?
    @State private var slot: Int?
    @State private var draft = DeckKey()
    @State private var saved = DeckKey()
    @State private var showIcons = false
    @Environment(\.colorScheme) private var scheme

    /// `startSlot` opens with a key already picked (for pictures).
    init(model: AppModel, close: @escaping () -> Void = {}, startSlot: Int? = nil) {
        self.model = model
        self.close = close
        _profileID = State(initialValue: model.position?.profile)
        _pageID = State(initialValue: model.position?.page)
        if let startSlot, let key = model.keys[startSlot] {
            _slot = State(initialValue: startSlot)
            _draft = State(initialValue: key)
            _saved = State(initialValue: key)
        }
    }

    private var profile: DeckProfile? {
        profileID.flatMap { model.deck.profile($0) } ?? model.deck.fallbackProfile
    }

    private var page: DeckPage? {
        guard let profile else { return nil }
        return pageID.flatMap { profile.page($0) } ?? profile.topPages.first ?? profile.pages.first
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                profilesColumn.frame(width: 200)
                Divider()
                keysColumn
                Divider()
                editorColumn.frame(width: 300)
            }
            Divider()
            HStack(spacing: 6) {
                Button("Undo") { undo() }
                    .buttonStyle(PlainButton())
                    .disabled(model.undoStack.isEmpty)
                    .accessibilityIdentifier("undo")
                Button("Redo") { redo() }
                    .buttonStyle(PlainButton())
                    .disabled(model.redoStack.isEmpty)
                    .accessibilityIdentifier("redo")
                Text("Changes are kept as you make them. ⌘Z takes them back; every earlier state also stays as a safety copy.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done") { if leaveKey() { model.saveNow(); close() } }
                    .buttonStyle(MainButton())
                    .accessibilityIdentifier("setupDone")
            }
        }
        .padding(14)
        .frame(width: 1010, height: 620)
        .background(slot == nil ? Button("") { model.saveNow(); close() }.keyboardShortcut(.cancelAction).opacity(0) : nil)
        .onAppear {
            model.edit.copy = { copyKey() }
            model.edit.paste = { pasteKey() }
        }
        .accessibilityIdentifier("setup")
    }

    // MARK: Copy, paste, undo

    private func copyKey() {
        guard let slot, let key = page?.keys[slot] else { NSSound.beep(); return }
        model.copiedKey = draft == saved ? key : draft
    }

    /// Puts the copied key on the picked place (a key already there makes way).
    private func pasteKey() {
        guard let slot, let profile, let page, let copied = model.copiedKey else { NSSound.beep(); return }
        let key = copied.copied()
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            item.pages[index].keys[slot] = key
        }
        draft = key
        saved = key
    }

    private func undo() {
        slot = nil
        model.undo()
    }

    private func redo() {
        slot = nil
        model.redo()
    }

    /// A key dropped on a key, or on a page chip (then it goes to the same place on that page).
    private func moveKey(_ item: String, to target: (page: UUID, slot: Int)) {
        let bits = item.split(separator: ":")
        guard bits.count == 3, let from = UUID(uuidString: String(bits[1])), let at = Int(bits[2]),
              let profile, leaveKey() else { return }
        model.change { $0.moveKey(in: profile.id, from: (from, at), to: target) }
        if target.page == pageID { slot = nil; pick(target.slot) } else { slot = nil }
    }

    // MARK: Profiles

    private var profilesColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Profiles").font(.headline).foregroundStyle(Palette.part("profiles", scheme))
                Spacer()
                Button(action: addProfile) { Mark(name: "control-add", size: 16, colour: Palette.part("profiles", scheme)) }
                    .buttonStyle(.plain)
                    .help("Add a profile")
                    .accessibilityIdentifier("addProfile")
            }
            ForEach(model.deck.profiles) { item in
                Button { showProfile(item) } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.name.isEmpty ? "No name" : item.name).lineLimit(1)
                        Text(profileNote(item)).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Palette.part("profiles", scheme).opacity(item.id == profile?.id ? 0.18 : 0),
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("profile-\(item.name)")
            }
            Divider().padding(.vertical, 4)
            if let profile {
                FieldLabel("Name")
                TextField("Name", text: profileName(profile))
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("profileName")
                FieldLabel("Use with apps")
                ForEach(profile.apps, id: \.self) { app in
                    HStack(spacing: 4) {
                        Text(KeyArt.appName(app)).lineLimit(1)
                        Spacer(minLength: 4)
                        Button { edit(profile) { $0.apps.removeAll { $0 == app } } } label: { Mark(name: "control-close", size: 12) }
                            .buttonStyle(.plain)
                            .help("Take this app away")
                    }
                }
                Button("Add an app…") {
                    guard let app = Chooser.app() else { return }
                    edit(profile) { if !$0.apps.contains(app) { $0.apps.append(app) } }
                }
                .buttonStyle(PlainButton())
                .accessibilityIdentifier("addApp")
                Text(profile.apps.isEmpty
                     ? (isDefault(profile) ? "The default: it shows for every app without a profile of its own."
                                           : "No app yet: it shows only when you pick it.")
                     : "Shows by itself when one of these apps is in front.")
                    .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    if !isDefault(profile) {
                        Button("Make default") { model.change { $0.defaultProfile = profile.id } }
                            .buttonStyle(PlainButton())
                    }
                    Button("Duplicate") {
                        guard leaveKey() else { return }
                        let copy = profile.duplicated(name: profile.name + " copy")
                        model.change { $0.profiles.append(copy) }
                        showProfile(copy)
                    }
                    .buttonStyle(PlainButton())
                    .accessibilityIdentifier("duplicateProfile")
                    if model.deck.profiles.count > 1 {
                        Button("Delete") { deleteProfile(profile) }
                            .buttonStyle(PlainButton())
                            .accessibilityIdentifier("deleteProfile")
                    }
                }
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }

    private func isDefault(_ item: DeckProfile) -> Bool { model.deck.fallbackProfile?.id == item.id }

    private func profileNote(_ item: DeckProfile) -> String {
        if !item.apps.isEmpty { return item.apps.map { KeyArt.appName($0) }.joined(separator: ", ") }
        return isDefault(item) ? "Default" : "By hand"
    }

    private func profileName(_ item: DeckProfile) -> Binding<String> {
        Binding(get: { model.deck.profile(item.id)?.name ?? "" },
                set: { name in edit(item) { $0.name = name } })
    }

    private func edit(_ item: DeckProfile, _ change: (inout DeckProfile) -> Void) {
        model.change { deck in
            guard let index = deck.profiles.firstIndex(where: { $0.id == item.id }) else { return }
            change(&deck.profiles[index])
        }
    }

    private func showProfile(_ item: DeckProfile) {
        guard leaveKey() else { return }
        profileID = item.id
        pageID = item.topPages.first?.id
        slot = nil
        if let pageID { model.show(profile: item.id, page: pageID) }
    }

    private func addProfile() {
        guard leaveKey() else { return }
        let new = DeckProfile(name: "New profile", pages: [DeckPage(name: "Page 1")])
        model.change { $0.profiles.append(new) }
        showProfile(new)
    }

    private func deleteProfile(_ item: DeckProfile) {
        let keys = item.pages.reduce(0) { $0 + $1.keys.count }
        let alert = NSAlert()
        alert.messageText = "Delete the profile “\(item.name)”?"
        alert.informativeText = "Its \(keys) keys go with it. The setup as it is now stays as a safety copy."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        slot = nil
        model.saveNow()
        model.change { deck in
            deck.profiles.removeAll { $0.id == item.id }
            if deck.defaultProfile == item.id { deck.defaultProfile = deck.profiles.first?.id }
        }
        if let first = model.deck.fallbackProfile { showProfile(first) }
    }

    // MARK: Pages and keys

    private var keysColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keys").font(.headline).foregroundStyle(Palette.part("keys", scheme))
            if let profile, let page {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(profile.pages) { item in
                            Button { showPage(item) } label: {
                                HStack(spacing: 4) {
                                    if item.parent != nil { Mark(name: "deck-folder", size: 13) }
                                    Text(item.name.isEmpty ? "Page" : item.name).lineLimit(1)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(Palette.part("keys", scheme).opacity(item.id == page.id ? 0.22 : 0.07),
                                            in: Capsule())
                                .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .dropDestination(for: String.self) { items, _ in
                                guard let first = items.first, first.hasPrefix("deckkey:"),
                                      let at = Int(first.split(separator: ":").last ?? "") else { return false }
                                moveKey(first, to: (item.id, at))
                                return true
                            }
                            .accessibilityIdentifier("page-\(item.name)")
                        }
                        Button(action: addPage) { Mark(name: "control-add", size: 15, colour: Palette.part("keys", scheme)) }
                            .buttonStyle(.plain)
                            .help("Add a page")
                            .accessibilityIdentifier("addPage")
                    }
                }
                KeyGrid(keys: page.keys, selected: slot, side: 72, gap: 10,
                        broken: Set(model.problems(on: page, of: profile).keys), dragPage: page.id,
                        onDrop: { moveKey($0, to: (page.id, $1)) }) { pick($0) }
                    .padding(13)
                    .background(Color(red: 0.11, green: 0.11, blue: 0.115), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                HStack(spacing: 8) {
                    TextField("Page name", text: pageName(profile, page))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 170)
                        .accessibilityIdentifier("pageName")
                    if page.parent == nil {
                        Button("Duplicate page") {
                            guard leaveKey() else { return }
                            var copyID: UUID?
                            edit(profile) { copyID = $0.duplicatePage(page.id) }
                            if let copyID, let copy = model.deck.profile(profile.id)?.page(copyID) { showPage(copy) }
                        }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("duplicatePage")
                    }
                    if page.parent != nil || profile.topPages.count > 1 {
                        Button(page.parent != nil ? "Delete folder" : "Delete page") { deletePage(profile, page) }
                            .buttonStyle(PlainButton())
                            .accessibilityIdentifier("deletePage")
                    }
                    Spacer()
                }
                Text("Click a key to change it. Drag it onto another key or a page to move it. ⌘C and ⌘V copy a key.")
                    .font(.caption).foregroundStyle(.secondary)
                legend
            } else {
                Text("No profile yet. Add one on the left.").foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private var legend: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), alignment: .leading)], alignment: .leading, spacing: 3) {
            ForEach(KeyKind.allCases.filter { $0 != .empty }, id: \.self) { kind in
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(nsColor: Palette.tile(kind)))
                        .frame(width: 11, height: 11)
                    Text(Palette.kindName(kind)).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 400, alignment: .leading)
    }

    private func pageName(_ profile: DeckProfile, _ page: DeckPage) -> Binding<String> {
        Binding(get: { model.deck.profile(profile.id)?.page(page.id)?.name ?? "" },
                set: { name in editPage(profile, page) { $0.name = name } })
    }

    private func editPage(_ profile: DeckProfile, _ page: DeckPage, _ change: (inout DeckPage) -> Void) {
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            change(&item.pages[index])
        }
    }

    private func showPage(_ item: DeckPage) {
        guard leaveKey(), let profile else { return }
        pageID = item.id
        slot = nil
        model.show(profile: profile.id, page: item.id)
    }

    private func addPage() {
        guard leaveKey(), let profile else { return }
        let new = DeckPage(name: "Page \(profile.topPages.count + 1)")
        edit(profile) { $0.pages.append(new) }
        showPage(new)
    }

    private func deletePage(_ profile: DeckProfile, _ page: DeckPage) {
        let alert = NSAlert()
        alert.messageText = "Delete “\(page.name)” with its \(page.keys.count) keys?"
        alert.informativeText = "Folders opened from it go too. The setup as it is now stays as a safety copy."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        slot = nil
        model.saveNow()
        edit(profile) { item in
            var gone: Set<UUID> = [page.id]
            var grew = true
            while grew {       // the folders inside go with it
                let more = item.pages.filter { $0.parent.map(gone.contains) == true && !gone.contains($0.id) }.map(\.id)
                grew = !more.isEmpty
                gone.formUnion(more)
            }
            item.pages.removeAll { gone.contains($0.id) }
            for index in item.pages.indices {
                item.pages[index].keys = item.pages[index].keys.filter { _, key in
                    !(key.action.type == .folder && UUID(uuidString: key.action.target).map(gone.contains) == true)
                }
            }
        }
        if let first = model.deck.profile(profile.id)?.topPages.first { showPage(first) }
    }

    /// Picks a key to edit. Unsaved changes to the key before it are asked about first.
    private func pick(_ index: Int) {
        guard index != slot, leaveKey(), let page else { return }
        let key = page.keys[index] ?? DeckKey()
        draft = key
        saved = key
        slot = index
    }

    /// True when it is fine to leave the picked key: nothing unsaved, or he chose what to do with it.
    private func leaveKey() -> Bool {
        guard slot != nil, draft != saved else { return true }
        let alert = NSAlert()
        alert.messageText = "Save the changes to this key?"
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don’t save")
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal() {
        case .alertFirstButtonReturn: save(); return true
        case .alertSecondButtonReturn: return true
        default: return false
        }
    }

    // MARK: The picked key

    @ViewBuilder
    private var editorColumn: some View {
        if let slot, let profile {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Key \(slot + 1)").font(.headline).foregroundStyle(Palette.part("keys", scheme))
                    Text("row \(slot / 5 + 1), place \(slot % 5 + 1)").font(.caption).foregroundStyle(.secondary)
                }
                if let why = KeyCheck.problem(draft, in: profile, deck: model.deck, world: KeyWorldOnMac.world) {
                    HStack(spacing: 5) {
                        Mark(name: "app-warning", size: 14, colour: Color(red: 0.86, green: 0.16, blue: 0.14))
                        Text(why).font(.callout).foregroundStyle(Color(red: 0.86, green: 0.16, blue: 0.14))
                    }
                    .accessibilityIdentifier("keyProblem")
                }
                FieldLabel("Title")
                TextField("Title", text: $draft.title)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("keyTitle")
                FieldLabel("Icon")
                HStack(spacing: 8) {
                    if let picture = KeyArt.image(for: draft, pixels: 216) {
                        Image(decorative: picture, scale: 1)
                            .resizable()
                            .interpolation(.high)
                            .frame(width: 46, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    Button(draft.icon.isEmpty ? "Automatic" : IconStore.title(draft.icon)) { showIcons = true }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("pickIcon")
                        .popover(isPresented: $showIcons, arrowEdge: .leading) {
                            IconPicker(current: draft.icon) { name in
                                draft.icon = name
                                showIcons = false
                            }
                        }
                    Spacer()
                }
                FieldLabel("What it does")
                Picker("", selection: actionType) {
                    ForEach(ActionType.forKeys, id: \.self) { Text($0.title).tag($0) }
                }
                .labelsHidden()
                .accessibilityIdentifier("actionType")
                ScrollView {
                    ActionFields(action: $draft.action, deck: model.deck, profile: profile) { title in
                        if draft.title.isEmpty { draft.title = title }
                    }
                    .padding(.trailing, 4)
                }
                .frame(maxHeight: .infinity)
                if ActionRunner.needsKeys(draft.action), !model.mayPressKeys {
                    Text("This kind of key needs the Mac’s permission once. “Try it” brings up the question.")
                        .font(.caption)
                        .foregroundStyle(Palette.part("raycast", scheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 6) {
                    Button("Try it") { tryDraft() }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("tryKey")
                    Button("Clear key") { draft = DeckKey(id: draft.id) }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("clearKey")
                    Spacer()
                    Button("Cancel") { self.slot = nil }
                        .buttonStyle(PlainButton())
                        .keyboardShortcut(.cancelAction)
                        .accessibilityIdentifier("keyCancel")
                    Button("Save") { save() }
                        .buttonStyle(MainButton())
                        .keyboardShortcut(.defaultAction)
                        .accessibilityIdentifier("keySave")
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("Key").font(.headline).foregroundStyle(Palette.part("keys", scheme))
                Text("Click one of the 15 keys to give it a title, an icon and something to do.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionType: Binding<ActionType> {
        Binding(get: { draft.action.type },
                set: { new in
                    guard new != draft.action.type else { return }
                    draft.action = DeckAction(type: new, target: new == .media ? MediaKey.playPause.rawValue : "")
                })
    }

    private func tryDraft() {
        let steps = draft.action.type == .multi ? draft.action.steps : [draft.action]
        ActionRunner.run(steps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { model.refreshStatus() }
    }

    private func save() {
        guard let slot, let profile, let page else { return }
        var key = draft
        var newFolder: DeckPage?
        if key.action.type == .folder, UUID(uuidString: key.action.target).flatMap({ profile.page($0) }) == nil {
            var folder = DeckPage(name: key.title.isEmpty ? "Folder" : key.title, parent: page.id)
            folder.keys[0] = DeckKey(title: "Back", action: DeckAction(type: .back))
            key.action.target = folder.id.uuidString
            newFolder = folder
        }
        let empty = key.action.type == .none && key.title.isEmpty && key.icon.isEmpty
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            item.pages[index].keys[slot] = empty ? nil : key
            if let newFolder { item.pages.append(newFolder) }
        }
        draft = key
        saved = key
    }
}
