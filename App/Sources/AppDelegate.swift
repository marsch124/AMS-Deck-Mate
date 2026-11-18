import AppKit
import Carbon.HIToolbox
import Combine
import DeckMateCore
import ServiceManagement
import SwiftUI

/// One global shortcut (Control-Option-D) that works in every app.
enum HotKey {
    private static var action: (() -> Void)?
    private static var ref: EventHotKeyRef?
    private static var handler: EventHandlerRef?

    @discardableResult
    static func register(keyCode: Int, modifiers: Int, _ run: @escaping () -> Void) -> Bool {
        action = run
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetEventDispatcherTarget(), { _, _, _ -> OSStatus in
            DispatchQueue.main.async { HotKey.action?() }
            return noErr
        }, 1, &spec, nil, &handler)
        let id = EventHotKeyID(signature: 0x414D_444B, id: 1)
        return RegisterEventHotKey(UInt32(keyCode), UInt32(modifiers), id, GetEventDispatcherTarget(), 0, &ref) == noErr
    }
}

/// The floating keys. They take the keyboard only right after they were shown by hand, so 1–5,
/// Q–T and A–G press the keys; a click never takes it (a shortcut key must reach the app in front).
final class DeckPanel: NSPanel {
    /// Told whenever the keyboard comes or goes, so the keys show their letters only while typing works.
    var onKeyboard: ((Bool) -> Void)?
    var takesKeyboard = false {
        didSet { if !takesKeyboard { onKeyboard?(false) } }
    }
    override func becomeKey() {
        super.becomeKey()
        onKeyboard?(true)
    }
    override func resignKey() {
        super.resignKey()
        onKeyboard?(false)
    }
    var onKey: ((NSEvent) -> Bool)?
    override var canBecomeKey: Bool { takesKeyboard }
    override func keyDown(with event: NSEvent) {
        if onKey?(event) != true { super.keyDown(with: event) }
    }
    override func cancelOperation(_ sender: Any?) { orderOut(nil) }

    /// Gives the keyboard back to the app in front, and stays in sight.
    func releaseKeyboard() {
        takesKeyboard = false
        guard isKeyWindow else { return }
        orderOut(nil)
        orderFrontRegardless()
    }
}

/// A window that hands Copy, Paste, Undo and Redo to the app when no text field takes them.
final class EditWindow: NSWindow {
    var commands: EditCommands?
    weak var model: AppModel?
    @objc func copy(_ sender: Any?) { commands?.copy?() }
    @objc func paste(_ sender: Any?) { commands?.paste?() }
    @objc func undo(_ sender: Any?) { model?.undo() }
    @objc func redo(_ sender: Any?) { model?.redo() }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    private var model: AppModel!
    private var item: NSStatusItem?
    private var deckPanel: DeckPanel?
    private let copiedList = CopiedListPanel()
    private var setupWindow: NSWindow?
    private var settingsWindow: NSWindow?
    /// The keys on screen were showing when "Set up keys" opened, and come back when it closes.
    private var deckWaits = false
    private var sizeWatch: AnyCancellable?
    private var clickWatch: AnyCancellable?
    private var findWatch: AnyCancellable?
    private var phone: PhoneServer!
    private static let note = "com.schabbauer.AMSDeckMate."

    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
        // For checks: "--snapshots <folder>" writes pictures of every window by day and by night, with made-up keys.
        if let index = arguments.firstIndex(of: "--snapshots"), index + 1 < arguments.count {
            Snapshots.write(to: URL(fileURLWithPath: arguments[index + 1]))
            NSApp.terminate(nil)
            return
        }
        // For checks: "--pages <folder>" writes every page of the setup as one picture of its 15 keys, as the
        // keys really look, and changes nothing ("--data <folder>" picks another setup than the real one).
        if let index = arguments.firstIndex(of: "--pages"), index + 1 < arguments.count {
            var store = Store()
            if let data = arguments.firstIndex(of: "--data"), data + 1 < arguments.count {
                store = Store(folder: URL(fileURLWithPath: arguments[data + 1]))
            }
            KeyArt.picturesFolder = store.pictures
            let folder = URL(fileURLWithPath: arguments[index + 1])
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            for group in store.load()?.profiles ?? [] {
                for page in group.pages {
                    let name = "\(group.name) - \(page.name).png".replacingOccurrences(of: "/", with: "-")
                    try? KeyArt.pngForCheck(page)?.write(to: folder.appendingPathComponent(name))
                }
            }
            print("pages written")
            NSApp.terminate(nil)
            return
        }
        // For checks: "--glance <folder>" reads the weather of Stockholm and the Body Battery for real, waits
        // seven seconds and writes the five glance keys as one picture. The setup is not touched and the Mac
        // is asked nothing (the calendar and OmniFocus keys only say whether they were allowed).
        if let index = arguments.firstIndex(of: "--glance"), index + 1 < arguments.count {
            let folder = URL(fileURLWithPath: arguments[index + 1])
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var page = DeckPage(name: "Glance")
            var kinds: [DeckAction] = [DeckAction(type: .nextEvent), DeckAction(type: .weather, target: "Stockholm"),
                                       DeckAction(type: .freeUntil), DeckAction(type: .cover), DeckAction(type: .bodyBattery)]
            kinds += GarminKeys.Number.allCases.map { DeckAction(type: .garmin, target: $0.rawValue) }
            kinds += MacNowKeys.Number.allCases.map { DeckAction(type: .macNow, target: $0.rawValue) }
            kinds += [DeckAction(type: .worldClock, target: "Stockholm"), DeckAction(type: .sunTimes, target: "Stockholm")]
            for (slot, action) in kinds.enumerated() { page.keys[slot] = DeckKey(action: action) }
            let watch = GlanceWatch()
            watch.watch(Deck(profiles: [DeckProfile(name: "Check", pages: [page])]))
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                let live = LiveKeys(glances: watch.glances, battery: watch.battery, cover: watch.cover, coverReady: watch.coverReady)
                var shown = page
                shown.keys = page.keys.mapValues { $0.resolving(live) }
                try? KeyArt.pngForCheck(shown)?.write(to: folder.appendingPathComponent("glance.png"))
                for (name, glance) in watch.glances.sorted(by: { $0.key < $1.key }) { print("\(name): \(glance.big) | \(glance.words)") }
                var places = UserDefaults.standard.dictionary(forKey: "weatherPlaces") ?? [:]
                places["stockholm"] = nil
                UserDefaults.standard.set(places, forKey: "weatherPlaces")
                var zones = UserDefaults.standard.dictionary(forKey: "townZones") ?? [:]
                zones["stockholm"] = nil
                UserDefaults.standard.set(zones, forKey: "townZones")
                print("glance written")
                NSApp.terminate(nil)
            }
            return
        }
        // Switches "Open at login" on or off from outside, then quits: "--open-at-login on".
        if let index = arguments.firstIndex(of: "--open-at-login"), index + 1 < arguments.count {
            if arguments[index + 1] == "on" { try? SMAppService.mainApp.register() } else { try? SMAppService.mainApp.unregister() }
            print("open at login:", SMAppService.mainApp.status == .enabled ? "on" : "off")
            NSApp.terminate(nil)
            return
        }
        // Only one copy in the menu bar.
        if NSRunningApplication.runningApplications(withBundleIdentifier: AppInfo.bundleID).count > 1 {
            NSApp.terminate(nil)
            return
        }
        // For checks: "--data <folder>" keeps the setup somewhere else than the real one (and makes no iCloud copies).
        var store = Store(cloud: CloudCopy.folder)
        if let index = arguments.firstIndex(of: "--data"), index + 1 < arguments.count {
            store = Store(folder: URL(fileURLWithPath: arguments[index + 1]))
        }
        model = AppModel(store: store)
        if let words = model.startNote {
            // The keys file was damaged: say once what was done about it.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                NSApp.activate(ignoringOtherApps: true)
                let alert = NSAlert()
                alert.messageText = "Your keys were looked after"
                alert.informativeText = words
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
        makeEditMenu()
        ActionRunner.townAsked = { [weak self] id in self?.askTown(id) }
        ActionRunner.showCopiedList = { [weak self] texts in self?.copiedList.toggle(texts: texts) }
        ActionRunner.showPickList = { [weak self] list in
            let entries = list.steps.filter { $0.type != .none }
            self?.copiedList.toggle(title: "Pick one", empty: "This list has no entries yet.", rows: entries.map(PickList.words),
                                    kind: list.kind) { ActionRunner.run(entries[$0]) }
        }
        phone = PhoneServer(model: model)
        phone.start()
        makeItem()
        model.onScreenKeyActed = { [weak self] in self?.deckPanel?.orderOut(nil) }
        // A click on the keys gives the keyboard back first, so a shortcut key reaches the app in front.
        clickWatch = model.ranEvents.sink { [weak self] _ in self?.deckPanel?.releaseKeyboard() }
        // A new size in Settings shows at once.
        sizeWatch = model.$deck.map(\.screenSize).removeDuplicates().dropFirst()
            .sink { [weak self] _ in DispatchQueue.main.async { self?.fitDeck() } }
        // The list of found keys under the keys makes the floating window taller, and shorter again.
        findWatch = model.$finding.combineLatest(model.$findWords).dropFirst()
            .sink { [weak self] _ in DispatchQueue.main.async { self?.fitDeck() } }
        HotKey.register(keyCode: kVK_ANSI_D, modifiers: controlKey | optionKey) { [weak self] in self?.toggleDeck() }

        // Lets a check from outside open the real windows and press keys.
        let center = DistributedNotificationCenter.default()
        center.addObserver(self, selector: #selector(toggleDeck), name: Notification.Name(AppDelegate.note + "toggleDeck"), object: nil)
        center.addObserver(self, selector: #selector(openSetup), name: Notification.Name(AppDelegate.note + "openSetup"), object: nil)
        center.addObserver(self, selector: #selector(openSettings), name: Notification.Name(AppDelegate.note + "openSettings"), object: nil)
        center.addObserver(self, selector: #selector(pressFromOutside(_:)), name: Notification.Name(AppDelegate.note + "press"), object: nil)

        // The very first start shows the keys, so there is something to see.
        if !UserDefaults.standard.bool(forKey: "shownOnce") {
            UserDefaults.standard.set(true, forKey: "shownOnce")
            showDeck()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        model?.willQuit()
    }

    @objc private func pressFromOutside(_ note: Notification) {
        if let text = note.object as? String, let index = Int(text) { model.click(index) }
    }

    /// Without an Edit menu the Mac gives no Copy, Paste or Undo keys at all (this app shows no menu bar of its own).
    private func makeEditMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        appItem.submenu = NSMenu()
        main.addItem(appItem)
        let editItem = NSMenuItem()
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = edit
        main.addItem(editItem)
        NSApp.mainMenu = main
    }

    // MARK: Menu bar

    private func makeItem() {
        // His menu bar is full up to the notch: without a place of its own a new item lands behind it.
        let place = "NSStatusItem Preferred Position deckMate"
        if UserDefaults.standard.object(forKey: place) == nil { UserDefaults.standard.set(160.0, forKey: place) }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.autosaveName = "deckMate"
        item.button?.image = DeckGlyph.menuBarImage()
        item.button?.setAccessibilityLabel("AMS Deck Mate")
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        self.item = item
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        func add(_ title: String, _ action: Selector?, key: String = "", mask: NSEvent.ModifierFlags = []) -> NSMenuItem {
            let entry = NSMenuItem(title: title, action: action, keyEquivalent: key)
            entry.keyEquivalentModifierMask = mask
            entry.target = self
            menu.addItem(entry)
            return entry
        }
        _ = add(deckPanel?.isVisible == true ? "Hide keys on screen" : "Show keys on screen", #selector(toggleDeck),
                key: "d", mask: [.control, .option])
        _ = add("Set up keys…", #selector(openSetup))
        menu.addItem(.separator())
        let place = model.profile?.name ?? "none"
        _ = add("Page group: \(place)" + (model.pinned == nil ? " (automatic)" : " (locked)"), nil)
        let automatic = add("Automatic", #selector(pickProfile(_:)))
        automatic.state = model.pinned == nil ? .on : .off
        automatic.indentationLevel = 1
        for profile in model.deck.profiles {
            let entry = add(profile.name.isEmpty ? "No name" : profile.name, #selector(pickProfile(_:)))
            entry.representedObject = profile.id.uuidString
            entry.indentationLevel = 1
            entry.state = model.pinned == profile.id ? .on : (model.pinned == nil && model.position?.profile == profile.id ? .mixed : .off)
        }
        if let app = model.frontApp, let url = KeyArt.appURL(app) {
            let name = FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
            let entry = add("Page group for \(name)", nil)
            let sub = NSMenu()
            let owner = model.deck.profileNaming(app: app)?.id
            for profile in model.deck.profiles {
                let choice = NSMenuItem(title: profile.name.isEmpty ? "No name" : profile.name,
                                        action: #selector(assignProfile(_:)), keyEquivalent: "")
                choice.target = self
                choice.representedObject = [app, profile.id.uuidString]
                choice.state = owner == profile.id ? .on : .off
                sub.addItem(choice)
            }
            sub.addItem(.separator())
            let none = NSMenuItem(title: "None – use the default", action: #selector(assignProfile(_:)), keyEquivalent: "")
            none.target = self
            none.representedObject = [app]
            none.state = owner == nil ? .on : .off
            sub.addItem(none)
            entry.submenu = sub
            entry.action = nil
        }
        menu.addItem(.separator())
        let box: String
        switch model.box {
        case .connected: box = "Box: connected"
        case .absent: box = "Box: not plugged in"
        case .blocked: box = "Box: not allowed yet (see Settings)"
        case .unsupported: box = "Box: this model is not driven yet"
        }
        _ = add(box, nil)
        _ = add(phone.isOn ? (phone.connected.map { "iPhone: connected – \($0)" } ?? "iPhone: none connected") : "iPhone: off", nil)
        _ = add("Settings…", #selector(openSettings), key: ",", mask: [.command])
        menu.addItem(.separator())
        _ = add("Quit AMS Deck Mate", #selector(quit), key: "q", mask: [.command])
    }

    @objc private func pickProfile(_ sender: NSMenuItem) {
        model.pin((sender.representedObject as? String).flatMap { UUID(uuidString: $0) })
    }

    /// "Profile for <app>": that profile shows by itself whenever the app is in front.
    @objc private func assignProfile(_ sender: NSMenuItem) {
        guard let parts = sender.representedObject as? [String], let app = parts.first else { return }
        let id = parts.count > 1 ? UUID(uuidString: parts[1]) : nil
        model.change { $0.assign(app: app, to: id) }
        if model.pinned == nil { model.pin(nil) }      // show it now
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: Keys on screen

    @objc private func toggleDeck() {
        if deckPanel?.isVisible == true { deckPanel?.orderOut(nil) } else { showDeck(keyboard: true) }
    }

    private func showDeck(keyboard: Bool = false) {
        let panel = deckPanel ?? makeDeckPanel()
        deckPanel = panel
        fitDeck()
        if model.deck.screenAtPointer {
            // Under the mouse pointer, on the screen the pointer is on, never off its edge.
            let pointer = AppDelegate.pointer()
            let screen = NSScreen.screens.first { NSMouseInRect(pointer, $0.frame, false) } ?? NSScreen.main
            if let area = screen?.visibleFrame {
                let origin = ScreenDeckRules.origin(pointer: pointer, size: panel.frame.size, area: area)
                panel.setFrameOrigin(origin)
            }
        } else {
            // Back into sight when its remembered place is on a screen that is gone.
            let onScreen = NSScreen.screens.contains { $0.visibleFrame.intersects(panel.frame) }
            if !onScreen, let screen = NSScreen.main {
                let area = screen.visibleFrame
                panel.setFrameOrigin(NSPoint(x: area.maxX - panel.frame.width - 24, y: area.minY + 24))
            }
        }
        panel.takesKeyboard = keyboard
        if keyboard { panel.makeKeyAndOrderFront(nil) } else { panel.orderFrontRegardless() }
    }

    /// 1–5, Q–T, A–G press the keys; arrows and Tab change the page; Escape hides.
    private func deckKey(_ event: NSEvent) -> Bool {
        guard let panel = deckPanel else { return false }
        let others = event.modifierFlags.intersection([.command, .control, .option])
        guard others.isEmpty else { return false }
        if model.finding {
            // Looking for a key: letters go to the search, not to the keys.
            let hits = model.findHits
            switch Int(event.keyCode) {
            case kVK_Escape: model.stopFinding()
            case kVK_Return, kVK_ANSI_KeypadEnter:
                if hits.indices.contains(model.findPick) { model.runFound(hits[model.findPick]) { panel.releaseKeyboard() } }
            case kVK_Delete:
                model.findWords = String(model.findWords.dropLast())
                model.findPick = 0
            case kVK_DownArrow: model.findPick = min(model.findPick + 1, max(0, hits.count - 1))
            case kVK_UpArrow: model.findPick = max(0, model.findPick - 1)
            default:
                let typed = (event.characters ?? "").unicodeScalars.filter { $0.value >= 0x20 && $0.value != 0x7F && $0.value < 0xF700 }
                if !typed.isEmpty, model.findWords.count < 40 {
                    model.findWords += String(String.UnicodeScalarView(typed))
                    model.findPick = 0
                }
            }
            return true
        }
        if Int(event.keyCode) == kVK_Space || event.characters == "/" {
            model.startFinding()
            return true
        }
        switch Int(event.keyCode) {
        case kVK_Escape: panel.orderOut(nil); return true
        case kVK_RightArrow: model.stepPage(1); return true
        case kVK_LeftArrow: model.stepPage(-1); return true
        case kVK_Tab: model.stepPage(event.modifierFlags.contains(.shift) ? -1 : 1); return true
        default:
            guard let index = ScreenDeckRules.keyIndex(forKeyCode: Int(event.keyCode)) else { return false }
            model.pressFromKeyboard(index) { panel.releaseKeyboard() }
            return true
        }
    }

    /// The magnifier on the keys on screen: the keys take the keyboard and the search begins; a second click ends it.
    private func findKey() {
        guard let panel = deckPanel else { return }
        if model.finding { model.stopFinding(); return }
        panel.takesKeyboard = true
        panel.makeKeyAndOrderFront(nil)
        model.startFinding()
    }

    /// Where the mouse pointer is right now, in screen points (origin bottom left).
    /// Asked of the window server directly: NSEvent.mouseLocation can be stale in an app that is not in front.
    static func pointer() -> NSPoint {
        guard let at = CGEvent(source: nil)?.location, let top = NSScreen.screens.first?.frame.maxY else {
            return NSEvent.mouseLocation
        }
        return NSPoint(x: at.x, y: top - at.y)
    }

    /// Makes the floating window as large as its keys (after a change of size), keeping its top left corner.
    private func fitDeck() {
        guard let panel = deckPanel, let host = panel.contentView else { return }
        let size = host.fittingSize
        guard size != panel.frame.size else { return }
        let corner = NSPoint(x: panel.frame.minX, y: panel.frame.maxY)
        panel.setContentSize(size)
        panel.setFrameTopLeftPoint(corner)
    }

    private func makeDeckPanel() -> DeckPanel {
        let host = NSHostingView(rootView: ScreenDeckView(model: model,
                                                          openSetup: { [weak self] in self?.openSetup() },
                                                          close: { [weak self] in self?.deckPanel?.orderOut(nil) },
                                                          find: { [weak self] in self?.findKey() },
                                                          runFound: { [weak self] hit in
                                                              self?.model.runFound(hit) { self?.deckPanel?.releaseKeyboard() }
                                                          }))
        let size = host.fittingSize
        let panel = DeckPanel(contentRect: NSRect(origin: .zero, size: size),
                            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = host
        panel.delegate = self
        panel.onKey = { [weak self] event in self?.deckKey(event) ?? false }
        panel.onKeyboard = { [weak self] on in
            guard let model = self?.model, model.keyboardOn != on else { return }
            if !on { model.stopFinding() }       // no keyboard, no search
            model.keyboardOn = on
            DispatchQueue.main.async { self?.fitDeck() }
        }
        if let saved = UserDefaults.standard.string(forKey: "deckOrigin") {
            panel.setFrameOrigin(NSPointFromString(saved))
        } else if let screen = NSScreen.main {
            let area = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: area.maxX - size.width - 24, y: area.minY + 24))
        }
        return panel
    }

    func windowDidMove(_ notification: Notification) {
        // Only a place he dragged it to is remembered, not the place under the pointer.
        guard let window = notification.object as? NSWindow, window === deckPanel, !model.deck.screenAtPointer else { return }
        UserDefaults.standard.set(NSStringFromPoint(window.frame.origin), forKey: "deckOrigin")
    }

    func windowWillClose(_ notification: Notification) {
        model?.saveNow()
        if (notification.object as? NSWindow) === setupWindow, deckWaits {
            deckWaits = false
            showDeck()
        }
    }

    // MARK: Windows

    private func show<Content: View>(_ window: inout NSWindow?, title: String, _ view: Content) {
        let host = NSHostingView(rootView: view)
        let target = window ?? {
            let made = EditWindow(contentRect: NSRect(origin: .zero, size: host.fittingSize),
                                  styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            made.commands = model.edit
            made.model = model
            made.title = title
            made.isReleasedWhenClosed = false
            made.delegate = self
            made.center()
            return made
        }()
        if !target.isVisible {
            target.contentView = host
            target.setContentSize(host.fittingSize)
        }
        window = target
        NSApp.activate(ignoringOtherApps: true)
        target.makeKeyAndOrderFront(nil)
        target.orderFrontRegardless()
    }

    @objc private func openSetup() {
        // The setup window shows the same keys, and the floating keys would lie over its buttons:
        // they step aside while it is open and come back when it closes.
        if deckPanel?.isVisible == true {
            deckPanel?.orderOut(nil)
            deckWaits = true
        }
        show(&setupWindow, title: "Set up keys", SetupView(model: model) { [weak self] in self?.setupWindow?.close() })
    }

    @objc private func openSettings() {
        show(&settingsWindow, title: "AMS Deck Mate", SettingsView(model: model, phone: phone) { [weak self] in self?.settingsWindow?.close() })
    }
}

extension AppDelegate {
    /// A weather key was held down: asks which town it should show. Type one, or pick one used before.
    func askTown(_ id: String) {
        guard let key = UUID(uuidString: id), let now = model.deck.town(ofKey: key) else { return }
        let alert = NSAlert()
        alert.messageText = "Town for this key"
        alert.informativeText = "Which town should this key show? Type one, or pick one you used before."
        let box = NSComboBox(frame: NSRect(x: 0, y: 0, width: 260, height: 26))
        box.addItems(withObjectValues: model.townsUsed)
        box.stringValue = now
        box.completes = true
        box.placeholderString = "Town"
        box.setAccessibilityIdentifier("townBox")
        alert.accessoryView = box
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = box
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let town = box.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !town.isEmpty, town != now else { return }
        model.setTown(town, forKey: key)
    }
}

/// Pictures of every window by day and by night, with made-up keys: `--snapshots <folder>`.
enum Snapshots {
    static func write(to folder: URL) {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let model = AppModel(sample: Sample.deck())
        let phone = PhoneServer(sampleFor: model)
        for (name, look) in [("day", NSAppearance.Name.aqua), ("night", NSAppearance.Name.darkAqua)] {
            shot(ScreenDeckView(model: model).padding(16), "deck-\(name)", look, folder)
            model.keyboardOn = true
            shot(ScreenDeckView(model: model).padding(16), "deck-letters-\(name)", look, folder)
            model.keyboardOn = false
            shot(SetupView(model: model, startSlot: 5), "setup-\(name)", look, folder)
            shot(SetupView(model: model, startSlot: 13), "setup-steps-\(name)", look, folder)
            shot(SetupView(model: model, startSlot: 0), "setup-long-\(name)", look, folder)
            shot(SetupView(model: model, overview: true), "setup-overview-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .settings), "settings-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .settings, startPart: .phone), "settings-phone-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .settings, startPart: .firstTime), "settings-first-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .guide), "guide-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .news), "news-\(name)", look, folder)
            shot(IconPicker(current: "", pick: { _ in }), "icons-\(name)", look, folder)
            let day = Date(timeIntervalSince1970: 1_794_800_000)
            shot(RestoreView(copies: (0..<6).map { Store.Copy(name: "deck \($0)", date: day.addingTimeInterval(Double($0) * -4000), groups: 3, keys: 47 - $0) },
                             bringBack: { _ in }, cancel: {}), "restore-\(name)", look, folder)
            shot(CopiedListView(rows: ["Meeting notes for Monday morning, with the agenda", "https://example.com/a/long/address", "Thank you!"],
                                pick: { _ in }).padding(12), "copied-list-\(name)", look, folder)
            // 0.10: the new kinds of key (page 2 of the made-up keys), finding a key, the list of a list key, key use.
            if let group = model.profile, let second = group.topPages.dropFirst().first, let first = group.topPages.first {
                model.show(profile: group.id, page: second.id)
                shot(ScreenDeckView(model: model).padding(16), "deck-new-\(name)", look, folder)
                shot(SetupView(model: model, startSlot: 2), "setup-timer-\(name)", look, folder)
                shot(SetupView(model: model, startSlot: 4), "setup-switch-\(name)", look, folder)
                shot(SetupView(model: model, startSlot: 8), "setup-list-\(name)", look, folder)
                // 0.11: the glance keys and the desk key (page 3 of the made-up keys).
                if let third = group.topPages.dropFirst(2).first {
                    model.show(profile: group.id, page: third.id)
                    shot(ScreenDeckView(model: model).padding(16), "deck-glance-\(name)", look, folder)
                    shot(SetupView(model: model, startSlot: 1), "setup-weather-\(name)", look, folder)
                    shot(SetupView(model: model, startSlot: 5), "setup-desk-\(name)", look, folder)
                    shot(SetupView(model: model, startSlot: 8), "setup-garmin-\(name)", look, folder)
                }
                // 0.12: world clock, sunrise and sunset, free until (page 4 of the made-up keys).
                if let fourth = group.topPages.dropFirst(3).first {
                    model.show(profile: group.id, page: fourth.id)
                    shot(ScreenDeckView(model: model).padding(16), "deck-glance2-\(name)", look, folder)
                }
                model.show(profile: group.id, page: first.id)
            }
            model.startFinding()
            model.findWords = "sa"
            shot(ScreenDeckView(model: model).padding(16), "deck-find-\(name)", look, folder)
            model.stopFinding()
            shot(CopiedListView(title: "Pick one", rows: ["Documents", "News", "Notes", "Sign-off"], kind: .web, pick: { _ in }).padding(12),
                 "pick-list-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .settings, startPart: .use), "settings-use-\(name)", look, folder)
            shot(SettingsView(model: model, phone: phone, startTab: .settings, startPart: .kept), "settings-kept-\(name)", look, folder)
        }
        for size in [ScreenSize.small, .large] {
            var deck = Sample.deck()
            deck.screenSize = size
            shot(ScreenDeckView(model: AppModel(sample: deck)).padding(16), "deck-\(size.rawValue)", .aqua, folder)
        }
        // The key pictures exactly as the box gets them (before they are turned), three times enlarged.
        let keys = model.keys
        let strip = NSImage(size: NSSize(width: 5 * 72 * 3, height: 3 * 72 * 3))
        strip.lockFocus()
        for index in 0..<15 {
            if let picture = KeyArt.image(for: keys[index], pixels: 72) {
                NSGraphicsContext.current?.imageInterpolation = .none
                NSImage(cgImage: picture, size: NSSize(width: 72, height: 72))
                    .draw(in: NSRect(x: (index % 5) * 216, y: (2 - index / 5) * 216, width: 216, height: 216))
            }
        }
        strip.unlockFocus()
        save(strip.tiffRepresentation.flatMap { NSBitmapImageRep(data: $0) }, "box-keys", folder)
        print("snapshots written")
    }

    private static func shot<Content: View>(_ view: Content, _ name: String, _ look: NSAppearance.Name, _ folder: URL) {
        let host = NSHostingView(rootView: view.background(Color(nsColor: .windowBackgroundColor)))
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: host.fittingSize), styleMask: [.borderless],
                              backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: look)
        window.contentView = host
        window.setFrameOrigin(NSPoint(x: -6000, y: -6000))
        window.orderFrontRegardless()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        host.layoutSubtreeIfNeeded()
        if let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) {
            host.cacheDisplay(in: host.bounds, to: rep)
            save(rep, name, folder)
        }
        window.orderOut(nil)
    }

    private static func save(_ rep: NSBitmapImageRep?, _ name: String, _ folder: URL) {
        guard let data = rep?.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: folder.appendingPathComponent(name + ".png"))
    }
}
