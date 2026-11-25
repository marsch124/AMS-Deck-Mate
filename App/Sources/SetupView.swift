import AppKit
import DeckMateCore
import SwiftUI

/// "Set up keys": profiles on the left, the 15 keys in the middle, the picked key on the right.
struct SetupView: View {
    @ObservedObject var model: AppModel
    var close: () -> Void = {}

    @State private var profileID: UUID?
    /// The place of "Several pages at once" a dragged page is over right now.
    @State private var placeAimed: Int?
    @State private var pageID: UUID?
    @State private var slot: Int?
    @State private var draft = DeckKey()
    @State private var saved = DeckKey()
    @State private var showIcons = false
    @State private var showOverview = false
    @State private var addingGroup = false
    @Environment(\.colorScheme) private var scheme

    /// `startSlot` opens with a key already picked (for pictures).
    init(model: AppModel, close: @escaping () -> Void = {}, startSlot: Int? = nil, overview: Bool = false) {
        self.model = model
        self.close = close
        _showOverview = State(initialValue: overview)
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
            // 0.19: everything starts at the top. The columns had grown taller than the window, which
            // pushed their tops under the title bar and the bottom line out of sight; now a column that
            // does not fit (a small screen) scrolls by itself and the bottom line always shows.
            HStack(alignment: .top, spacing: 14) {
                ScrollView(.vertical, showsIndicators: false) { profilesColumn }.frame(width: 200)
                Divider()
                if showOverview {
                    overview
                } else {
                    ScrollView(.vertical, showsIndicators: false) { keysColumn }.frame(width: 426)
                    Divider()
                    editorColumn.frame(width: 300)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
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
        .frame(width: 1014, height: SetupWindow.height(screen: NSScreen.main?.visibleFrame.height), alignment: .top)
        .background(slot == nil ? Button("") { model.saveNow(); close() }.keyboardShortcut(.cancelAction).opacity(0) : nil)
        .onAppear {
            model.edit.copy = { copyKey() }
            model.edit.paste = { pasteKey() }
            SetupGuard.mayLeave = { leaveKey() }
        }
        .accessibilityIdentifier("setup")
    }

    // MARK: All pages at a glance

    /// Every group with every one of its pages and folders as a small picture; a click opens it.
    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("All pages").font(.headline).foregroundStyle(Palette.part("keys", scheme))
                Text("Click a page to change its keys.").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Save as PDF…") { KeysPDF.save(deck: model.deck, note: profileNote) }
                    .buttonStyle(PlainButton())
                    .help("Every page group with its pages as small pictures, on A4 pages")
                    .accessibilityIdentifier("savePDF")
                Button("Back to the keys") { showOverview = false }
                    .buttonStyle(PlainButton())
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("hideOverview")
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(model.deck.profiles) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(item.name.isEmpty ? "No name" : item.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Palette.part("profiles", scheme))
                                Text(profileNote(item)).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 150), spacing: 12, alignment: .topLeading)],
                                      alignment: .leading, spacing: 10) {
                                ForEach(item.pages) { page in
                                    Button { open(item, page) } label: { MiniPage(page: page, current: item.id == profile?.id && page.id == self.page?.id) }
                                        .buttonStyle(.plain)
                                        .accessibilityIdentifier("overview-\(item.name)-\(page.name)")
                                }
                            }
                        }
                    }
                }
                .padding(.trailing, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("overview")
    }

    private func open(_ item: DeckProfile, _ page: DeckPage) {
        profileID = item.id
        pageID = page.id
        slot = nil
        model.show(profile: item.id, page: page.id)
        showOverview = false
    }

    // MARK: Favourites (places 100–104 in `slot`)

    /// The favourites row is picked like a key: its five places count from 100.
    private static let favouriteBase = 100
    private var favourite: Int? { slot.flatMap { $0 >= SetupView.favouriteBase ? $0 - SetupView.favouriteBase : nil } }

    /// The key at a place: one of the page's 15, or a favourite.
    private func key(at place: Int) -> DeckKey? {
        place >= SetupView.favouriteBase ? model.deck.favourites[place - SetupView.favouriteBase] : page?.keys[place]
    }

    /// Puts a key on a place (nil clears it).
    private func put(_ key: DeckKey?, at place: Int, alsoAdding folder: DeckPage? = nil) {
        if place >= SetupView.favouriteBase {
            model.change { $0.favourites[place - SetupView.favouriteBase] = key }
        } else if let profile, let page {
            edit(profile) { item in
                guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
                item.pages[index].keys[place] = key
                if let folder { item.pages.append(folder) }
            }
        }
    }

    private var favouritesRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Favourites").font(.subheadline.weight(.semibold)).foregroundStyle(Palette.part("iphone", scheme))
            HStack(spacing: 8) {
                ForEach(0..<PhoneLink.favouriteCount, id: \.self) { index in
                    let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
                    let key = model.deck.favourites[index]
                    Group {
                        if let picture = KeyArt.image(for: key, pixels: 216) {
                            Image(decorative: picture, scale: 1).resizable().interpolation(.high)
                        } else {
                            Color.black
                        }
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(shape)
                    .overlay(shape.strokeBorder(Color.white.opacity(key == nil ? 0.10 : 0), lineWidth: 1))
                    .overlay(shape.inset(by: -3).strokeBorder(Color.white, lineWidth: favourite == index ? 2.5 : 0))
                    .contentShape(Rectangle())
                    .onTapGesture { pick(SetupView.favouriteBase + index) }
                    .accessibilityElement()
                    .accessibilityLabel(key == nil ? "Empty favourite" : KeyArt.title(key))
                    .accessibilityIdentifier("favourite\(index)")
                }
                Text("Five keys that stay in place on every page and in every page group, in a row under the keys on the iPhone and iPad.")
                    .font(.caption).foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 4)
            }
            .padding(9)
            .frame(maxWidth: 426, alignment: .leading)
            .background(Color(red: 0.11, green: 0.11, blue: 0.115), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Copy, paste, undo

    private func copyKey() {
        guard let slot, let key = key(at: slot) else { NSSound.beep(); return }
        model.copiedKey = draft == saved ? key : draft
    }

    /// Puts the copied key on the picked place (a key already there makes way).
    private func pasteKey() {
        guard let slot, let copied = model.copiedKey,
              favourite == nil || copied.action.type.fitsFavourite else { NSSound.beep(); return }
        let key = copied.copied()
        put(key, at: slot)
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

    /// An app, a file or a folder from the Finder, or a web address, dropped on a place: an empty
    /// place gets a key for it, which then opens for editing. A key that is there already stays.
    private func dropOutside(_ thing: String, at index: Int) {
        guard page != nil, key(at: index) == nil, leaveKey() else { NSSound.beep(); return }
        let new: DeckKey?
        if thing.hasPrefix("/") {
            new = Drops.key(forFile: thing, bundleID: thing.hasSuffix(".app") ? Bundle(path: thing)?.bundleIdentifier : nil)
        } else {
            new = Drops.key(forLink: thing)
        }
        guard let new else { NSSound.beep(); return }
        slot = nil
        put(new, at: index)
        pick(index)
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
                Text("Page groups").font(.headline).foregroundStyle(Palette.part("profiles", scheme))
                Spacer()
                Button { addingGroup = true } label: {
                    HStack(spacing: 3) {
                        Mark(name: "control-add", size: 14, colour: Palette.part("profiles", scheme))
                        Text("Page group").font(.callout.weight(.medium)).foregroundStyle(Palette.part("profiles", scheme))
                    }
                }
                    .buttonStyle(.plain)
                    .help("Add a page group: an empty one or a ready-made one")
                    .accessibilityIdentifier("addProfile")
                    .popover(isPresented: $addingGroup, arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Button("Empty page group") { addingGroup = false; addProfile() }
                                .buttonStyle(MainButton(part: "profiles"))
                                .accessibilityIdentifier("addEmptyGroup")
                            Text("Ready-made").font(.caption.weight(.semibold)).foregroundStyle(Palette.part("profiles", scheme))
                                .padding(.top, 2)
                            ForEach(Templates.menu) { item in
                                Button("\(item.name) – \(item.keys.count) \(item.app.isEmpty ? "link keys" : "shortcut keys")") { addingGroup = false; addReadyMade(item) }
                                    .buttonStyle(PlainButton())
                                    .accessibilityIdentifier("readyMade-\(item.id)")
                            }
                            Text("A ready-made page group shows by itself when its app is in front, unless another page group already belongs to that app.")
                                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                                .frame(width: 230, alignment: .leading)
                        }
                        .padding(12)
                    }
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
                     ? (isDefault(profile) ? "The default: it shows for every app without a page group of its own."
                                           : "No app yet: it shows only when you pick it.")
                     : "Shows by itself when one of these apps is in front.")
                    .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                HoursRows(model: model, profile: profile.id)
                placesBox(profile)
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

    // MARK: Several pages at once: his four places (0.19)

    /// The four places an iPad shows at once (an iPhone: places 1 and 2), for this page group. A page is
    /// dragged in from the row of pages; from place to place the two swap.
    private func placesBox(_ profile: DeckProfile) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Several pages at once").font(.callout.weight(.semibold)).foregroundStyle(Palette.part("profiles", scheme))
            LazyVGrid(columns: [GridItem(.fixed(97), spacing: 6), GridItem(.fixed(97))], spacing: 6) {
                ForEach(0..<DeckProfile.placeCount, id: \.self) { place in placeSlot(profile, place) }
            }
            Text("Drag a page here from the row of pages. An iPad shows all four places, an iPhone 1 and 2.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            if profile.hasPlaces {
                Button("Let the app choose") { edit(profile) { $0.places = DeckProfile.tidy([]) } }
                    .buttonStyle(PlainButton())
                    .help("Empties all four places: the page you are on comes first again, then the next ones")
                    .accessibilityIdentifier("clearPlaces")
            }
        }
        .padding(.top, 4)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("placesBox")
    }

    private func placeSlot(_ profile: DeckProfile, _ place: Int) -> some View {
        let page = place < profile.places.count ? profile.places[place].flatMap { profile.page($0) } : nil
        let colour = Palette.part("profiles", scheme)
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        return VStack(alignment: .leading, spacing: 2) {
            ZStack {
                if let page {
                    PlacePicture(page: page)
                } else {
                    Text("Drag a page here").font(.caption2).foregroundStyle(colour).multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 97, height: 50)
            .background(Color(red: 0.11, green: 0.11, blue: 0.115).opacity(page == nil ? 0.25 : 1), in: shape)
            .overlay(shape.strokeBorder(colour.opacity(placeAimed == place ? 1 : (page == nil ? 0.55 : 0)),
                                        style: StrokeStyle(lineWidth: placeAimed == place ? 2.5 : 1, dash: page == nil && placeAimed != place ? [4, 3] : [])))
            // The number of the place: 1 top left, 2 top right, 3 bottom left, 4 bottom right.
            .overlay(alignment: .topLeading) {
                Text("\(place + 1)").font(.caption2.weight(.bold)).foregroundStyle(.white)
                    .frame(width: 16, height: 16)
                    .background(Palette.fill("profiles"), in: Circle())
                    .offset(x: -3, y: -3)
            }
            .overlay(alignment: .topTrailing) {
                if page != nil {
                    Button { edit(profile) { $0.put(nil, inPlace: place) } } label: {
                        Mark(name: "control-close", size: 11).padding(3)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Empty this place")
                    .offset(x: 3, y: -3)
                    .accessibilityLabel("Empty place \(place + 1)")
                    .accessibilityIdentifier("emptyPlace\(place + 1)")
                }
            }
            Text(page.map { $0.name.isEmpty ? "Page" : $0.name } ?? "The app chooses")
                .font(.caption2).foregroundStyle(page == nil ? .secondary : .primary).lineLimit(1)
        }
        .contentShape(Rectangle())
        .draggable(PagePlaces.placeDrag + (page == nil ? "none" : "\(place)"))
        .dropDestination(for: String.self) { items, _ in
            guard let moved = PagePlaces.page(dropped: items.first ?? "", in: profile) else { return false }
            edit(profile) { $0.put(moved, inPlace: place) }
            return true
        } isTargeted: { aimed in
            if aimed { placeAimed = place } else if placeAimed == place { placeAimed = nil }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Place \(place + 1): \(page?.name ?? "the app chooses")")
        .accessibilityIdentifier("place\(place + 1)")
    }

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
        let new = DeckProfile(name: "New page group", pages: [DeckPage(name: "Page 1")])
        model.change { $0.profiles.append(new) }
        showProfile(new)
    }

    /// A ready-made page group: one page of keyboard-shortcut keys for an app.
    private func addReadyMade(_ template: PageGroupTemplate) {
        guard leaveKey() else { return }
        let new = Templates.profile(from: template, in: model.deck)
        model.change { $0.profiles.append(new) }
        showProfile(new)
    }

    /// A folder that always shows the apps open now, opened from the first empty place of this page.
    private func addOpenApps(_ profile: DeckProfile, _ page: DeckPage) {
        guard leaveKey() else { return }
        guard let place = page.firstFreePlace else {
            let alert = NSAlert()
            alert.messageText = "This page has no empty place."
            alert.informativeText = "Clear a key or pick another page, then add the “Open apps” folder again. Nothing was changed."
            alert.runModal()
            return
        }
        let folder = RunningApps.folder(parent: page.id)
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            item.pages[index].keys[place] = DeckKey(title: "Open apps", action: DeckAction(type: .folder, target: folder.id.uuidString))
            item.pages.append(folder)
        }
    }

    /// A folder that shows the keys pressed most, opened from the first empty place of this page.
    private func addOftenUsed(_ profile: DeckProfile, _ page: DeckPage) {
        guard leaveKey() else { return }
        guard let place = page.firstFreePlace else {
            let alert = NSAlert()
            alert.messageText = "This page has no empty place."
            alert.informativeText = "Clear a key or pick another page, then add the “Often used” folder again. Nothing was changed."
            alert.runModal()
            return
        }
        let folder = OftenKeys.folder(parent: page.id)
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            item.pages[index].keys[place] = DeckKey(title: "Often used", action: DeckAction(type: .folder, target: folder.id.uuidString))
            item.pages.append(folder)
        }
    }

    private func deleteProfile(_ item: DeckProfile) {
        let keys = item.pages.reduce(0) { $0 + $1.keys.count }
        let alert = NSAlert()
        alert.messageText = "Delete the page group “\(item.name)”?"
        alert.informativeText = "Its \(keys) keys go with it. The setup as it is now stays as a safety copy."
        guard SafeAsk.run(alert, action: "Delete") else { return }
        slot = nil
        model.keepState("before a page group was deleted")
        model.change { deck in
            deck.profiles.removeAll { $0.id == item.id }
            if deck.defaultProfile == item.id { deck.defaultProfile = deck.profiles.first?.id }
        }
        if let first = model.deck.fallbackProfile { showProfile(first) }
    }

    // MARK: Pages and keys

    private var keysColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Keys").font(.headline).foregroundStyle(Palette.part("keys", scheme))
                Spacer()
                Button("All pages") { if leaveKey() { slot = nil; showOverview = true } }
                    .buttonStyle(PlainButton())
                    .help("Every page group and every page at a glance")
                    .accessibilityIdentifier("showOverview")
            }
            .frame(width: 426)
            if let profile, let page {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(profile.pages) { item in
                            // A plain tap (not a button), so the page can also be dragged into one of the
                            // four places of "Several pages at once" (0.19).
                            HStack(spacing: 4) {
                                if item.parent != nil { Mark(name: "deck-folder", size: 13) }
                                Text(item.name.isEmpty ? "Page" : item.name).lineLimit(1)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(Palette.part("keys", scheme).opacity(item.id == page.id ? 0.22 : 0.07),
                                        in: Capsule())
                            .contentShape(Capsule())
                            .onTapGesture { showPage(item) }
                            .draggable(PagePlaces.pageDrag + item.id.uuidString)
                            .accessibilityAddTraits(.isButton)
                            .dropDestination(for: String.self) { items, _ in
                                guard let first = items.first, first.hasPrefix("deckkey:"),
                                      let at = Int(first.split(separator: ":").last ?? "") else { return false }
                                moveKey(first, to: (item.id, at))
                                return true
                            }
                            .accessibilityIdentifier("page-\(item.name)")
                        }
                        Button(action: addPage) {
                            HStack(spacing: 3) {
                                Mark(name: "control-add", size: 13, colour: Palette.part("keys", scheme))
                                Text("Page").font(.callout.weight(.medium)).foregroundStyle(Palette.part("keys", scheme))
                            }
                        }
                            .buttonStyle(.plain)
                            .help("Add a page")
                            .accessibilityIdentifier("addPage")
                    }
                }
                // As the box shows them right now: a timer with its minutes, an "Open app" key with its app.
                KeyGrid(keys: model.live(page.keys), selected: slot, side: 72, gap: 10,
                        broken: Set(model.problems(on: page, of: profile).keys), dragPage: page.id,
                        onDrop: { item, at in
                            if item.hasPrefix(DragKey.outside) {
                                dropOutside(String(item.dropFirst(DragKey.outside.count)), at: at)
                            } else {
                                moveKey(item, to: (page.id, at))
                            }
                        }) { pick($0) }
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
                HStack(spacing: 8) {
                    Button("Add an “Open apps” folder") { addOpenApps(profile, page) }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("addOpenApps")
                    Text("always shows the apps open now")
                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    Spacer()
                }
                HStack(spacing: 8) {
                    Button("Add an “Often used” folder") { addOftenUsed(profile, page) }
                        .buttonStyle(PlainButton())
                        .accessibilityIdentifier("addOftenUsed")
                    Text("shows the keys you press most")
                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    Spacer()
                }
                favouritesRow
                Text("Click a key to change it. Drag it onto another key or a page to move it. Drop an app, a file or a web address on an empty key to make a key for it. ⌘C and ⌘V copy a key.")
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 426, alignment: .leading)
                legend
            } else {
                Text("No page group yet. Add one on the left.").foregroundStyle(.secondary)
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
        guard SafeAsk.run(alert, action: "Delete") else { return }
        slot = nil
        model.keepState("before a page was deleted")
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
        guard index != slot, leaveKey(), page != nil else { return }
        let key = key(at: index) ?? DeckKey()
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
                    if let favourite {
                        Text("Favourite \(favourite + 1)").font(.headline).foregroundStyle(Palette.part("iphone", scheme))
                        Text("shows on the iPhone and iPad").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text("Key \(slot + 1)").font(.headline).foregroundStyle(Palette.part("keys", scheme))
                        Text("row \(slot / 5 + 1), place \(slot % 5 + 1)").font(.caption).foregroundStyle(.secondary)
                    }
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
                    Button(draft.icon.isEmpty ? "Automatic" : draft.pictureName != nil ? "Own picture" : IconStore.title(draft.icon)) { showIcons = true }
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
                KindChooser(selection: actionType, allowed: { favourite == nil || $0.fitsFavourite })
                ScrollView {
                    VStack(alignment: .leading, spacing: 7) {
                        ActionFields(action: $draft.action, deck: model.deck, profile: profile) { title in
                            if draft.title.isEmpty { draft.title = title }
                        }
                        if draft.action.type == .bar, favourite == nil {
                            Button("Fill this row with the bar") { fillBarRow() }
                                .buttonStyle(PlainButton())
                                .accessibilityIdentifier("fillBarRow")
                        }
                        FieldLabel("Long press")
                        Picker("", selection: heldType) {
                            ForEach(ActionType.forLongPress, id: \.self) { Text($0.title).tag($0) }
                        }
                        .labelsHidden()
                        .accessibilityIdentifier("heldType")
                        if draft.hasHeld {
                            ActionFields(action: heldAction, deck: model.deck, profile: profile)
                            Text("Hold the key for half a second. It shows a small dot in its corner.")
                                .font(.caption).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        FieldLabel("Double press")
                        Picker("", selection: twiceType) {
                            ForEach(ActionType.forLongPress, id: \.self) { Text($0.title).tag($0) }
                        }
                        .labelsHidden()
                        .accessibilityIdentifier("twiceType")
                        if draft.hasTwice {
                            ActionFields(action: twiceAction, deck: model.deck, profile: profile)
                            Text("Press the key twice within a third of a second. It shows a small ×2 in its corner. This key then waits a third of a second after one press before it acts, to see whether a second follows.")
                                .font(.caption).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
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
                    draft.action = DeckAction.fresh(new)
                })
    }

    /// The long-press action; "Nothing" = no long press of its own.
    private var heldType: Binding<ActionType> {
        Binding(get: { draft.held?.type ?? .none },
                set: { new in
                    guard new != (draft.held?.type ?? .none) else { return }
                    draft.held = new == .none ? nil : DeckAction.fresh(new)
                })
    }

    private var heldAction: Binding<DeckAction> {
        Binding(get: { draft.held ?? .none }, set: { draft.held = $0 })
    }

    /// The double-press action; "Nothing" = no double press of its own.
    private var twiceType: Binding<ActionType> {
        Binding(get: { draft.twice?.type ?? .none },
                set: { new in
                    guard new != (draft.twice?.type ?? .none) else { return }
                    draft.twice = new == .none ? nil : DeckAction.fresh(new)
                })
    }

    private var twiceAction: Binding<DeckAction> {
        Binding(get: { draft.twice ?? .none }, set: { draft.twice = $0 })
    }

    /// Turns the empty places of this key's row into parts of the bar and numbers the row's bar keys
    /// left to right. A place that holds a key is never replaced; this key is saved as a bar part first.
    private func fillBarRow() {
        guard let slot, favourite == nil, let profile, let page else { return }
        var keys = page.keys
        keys[slot] = draft
        let filled = BarKeys.filledRow(keys, row: slot / 5)
        edit(profile) { item in
            guard let index = item.pages.firstIndex(where: { $0.id == page.id }) else { return }
            item.pages[index].keys = filled
        }
        if let now = filled[slot] {
            draft = now
            saved = now
        }
    }

    private func tryDraft() {
        let steps = draft.action.type == .multi ? draft.action.steps : [draft.action]
        ActionRunner.run(steps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { model.refreshStatus() }
    }

    private func save() {
        NotificationCenter.default.post(name: .deckKeySaving, object: nil)
        guard let slot, let profile, let page else { return }
        if favourite != nil {
            let empty = draft.action.type == .none && draft.title.isEmpty && draft.icon.isEmpty
            put(empty ? nil : draft, at: slot)
            saved = draft
            return
        }
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

/// The height of the "Set up keys" window (0.19): tall enough for its columns, never taller than the screen.
enum SetupWindow {
    static func height(screen: CGFloat?) -> CGFloat {
        CGFloat(PagePlaces.windowHeight(screen: screen.map(Double.init)))
    }
}

/// A page in one of the four places: its 15 keys as a small picture.
struct PlacePicture: View {
    let page: DeckPage
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { column in
                        Group {
                            if let picture = KeyArt.image(for: page.keys[row * 5 + column], pixels: 48) {
                                Image(decorative: picture, scale: 1).resizable().interpolation(.high)
                            } else {
                                Color.white.opacity(0.06)
                            }
                        }
                        .frame(width: 13, height: 13)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    }
                }
            }
        }
    }
}

/// One page as a small picture of its 15 keys, with its name under it (a folder shows the folder mark).
struct MiniPage: View {
    let page: DeckPage
    let current: Bool
    private let side: CGFloat = 24
    private let gap: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            VStack(spacing: gap) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(0..<5, id: \.self) { column in
                            let shape = RoundedRectangle(cornerRadius: 4, style: .continuous)
                            Group {
                                if let picture = KeyArt.image(for: page.keys[row * 5 + column], pixels: 72) {
                                    Image(decorative: picture, scale: 1).resizable().interpolation(.high)
                                } else {
                                    Color.white.opacity(0.06)
                                }
                            }
                            .frame(width: side, height: side)
                            .clipShape(shape)
                        }
                    }
                }
            }
            .padding(6)
            .background(Color(red: 0.11, green: 0.11, blue: 0.115), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(Color.accentColor, lineWidth: current ? 2.5 : 0))
            HStack(spacing: 3) {
                if page.parent != nil { Mark(name: "deck-folder", size: 12) }
                Text(page.name.isEmpty ? "Page" : page.name).font(.caption).lineLimit(1)
                Text("\(page.keys.count)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
