import AppKit
import DeckMateCore
import SwiftUI

/// Hears a mouse press anywhere on it and says where — also on the very first click on a window
/// that is not in front (a plain button would only wake the window up).
struct ClickCatcher: NSViewRepresentable {
    var onDown: (CGPoint) -> Void

    final class Catcher: NSView {
        var onDown: ((CGPoint) -> Void)?
        override var isFlipped: Bool { true }
        override var mouseDownCanMoveWindow: Bool { false }
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
        override func mouseDown(with event: NSEvent) {
            onDown?(convert(event.locationInWindow, from: nil))
        }
    }

    func makeNSView(context: Context) -> Catcher {
        let view = Catcher()
        view.onDown = onDown
        return view
    }

    func updateNSView(_ view: Catcher, context: Context) {
        view.onDown = onDown
    }
}

/// The 15 keys, five across and three down, drawn exactly as the box shows them.
struct KeyGrid: View {
    let keys: [Int: DeckKey]
    var pressed: Set<Int> = []
    var selected: Int?
    var side: CGFloat = 64
    var gap: CGFloat = 8
    /// Broken keys get a red corner.
    var broken: Set<Int> = []
    /// The keys on screen while they take the keyboard: each key shows its letter (1, Q, A …).
    var letters = false
    /// Set up keys: keys are picked with a plain click and can be dragged onto each other
    /// ("deckkey:<page>:<place>"); the keys on screen use the click catcher instead.
    var dragPage: UUID?
    var onDrop: ((String, Int) -> Void)?
    var onPress: (Int) -> Void

    private var width: CGFloat { side * 5 + gap * 4 }
    private var height: CGFloat { side * 3 + gap * 2 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<StreamDeckProtocol.keyCount, id: \.self) { index in
                keyView(index)
                    .offset(x: CGFloat(index % 5) * (side + gap), y: CGFloat(index / 5) * (side + gap))
            }
            if dragPage == nil {
            ClickCatcher { point in
                let column = Int(point.x / (side + gap))
                let row = Int(point.y / (side + gap))
                guard (0..<5).contains(column), (0..<3).contains(row),
                      point.x - CGFloat(column) * (side + gap) <= side,
                      point.y - CGFloat(row) * (side + gap) <= side else { return }
                onPress(row * 5 + column)
            }
            .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height, alignment: .topLeading)
    }

    @ViewBuilder
    private func keyView(_ index: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: side * 0.16, style: .continuous)
        let isPressed = pressed.contains(index)
        Group {
            if let picture = KeyArt.image(for: keys[index], pixels: 216) {
                Image(decorative: picture, scale: 1)
                    .resizable()
                    .interpolation(.high)
            } else {
                Color.black
            }
        }
        .frame(width: side, height: side)
        .clipShape(shape)
        .overlay(shape.fill(Color.black.opacity(isPressed ? 0.28 : 0)))
        .overlay(shape.strokeBorder(Color.white.opacity(keys[index] == nil ? 0.10 : 0), lineWidth: 1))
        .overlay(shape.inset(by: -3).strokeBorder(Color.white, lineWidth: selected == index ? 2.5 : 0))
        .overlay(alignment: .topLeading) {
            if letters, keys[index] != nil, let letter = ScreenDeckRules.keyLetter(index) {
                Text(letter)
                    .font(.system(size: max(9, side * 0.17), weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.8))
                    .frame(width: max(13, side * 0.26), height: max(13, side * 0.26))
                    .background(Color.white.opacity(0.88), in: Circle())
                    .padding(side * 0.05)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("letter\(index)")
            }
        }
        .overlay(alignment: .topTrailing) {
            if broken.contains(index) {
                BrokenCorner(side: side * 0.3).accessibilityIdentifier("broken\(index)")
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .modifier(DragKey(page: dragPage, index: index, filled: keys[index] != nil,
                          press: { onPress(index) }, drop: { onDrop?($0, index) }))
        .accessibilityElement()
        .accessibilityLabel(keys[index] == nil ? "Empty key" : KeyArt.title(keys[index]))
        .accessibilityIdentifier("key\(index)")
    }
}

/// The keys on screen: a small dark deck that floats above the other windows.
struct ScreenDeckView: View {
    @ObservedObject var model: AppModel
    var openSetup: () -> Void = {}
    var close: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(model.placeLine)
                    .font((model.deck.screenSize == .small ? Font.caption : Font.callout).weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                    .accessibilityIdentifier("deckPlace")
                if model.pinned != nil {
                    Text("held")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer(minLength: 8)
                headerButton("control-settings", "Set up keys", "deckSetup", openSetup)
                headerButton("control-close", "Hide the keys", "deckClose", close)
            }
            KeyGrid(keys: model.keys, pressed: model.pressed, side: model.deck.screenSize.keySide,
                    gap: model.deck.screenSize.gap,
                    broken: Set(model.problems(on: model.page, of: model.profile).keys),
                    letters: model.keyboardOn) { model.click($0) }
        }
        .padding(10)
        .background(Color(red: 0.11, green: 0.11, blue: 0.115), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        .fixedSize()
        .accessibilityIdentifier("screenDeck")
    }

    private func headerButton(_ icon: String, _ help: String, _ id: String, _ action: @escaping () -> Void) -> some View {
        Mark(name: icon, size: 15, colour: .white.opacity(0.8))
            .frame(width: 22, height: 20)
            .contentShape(Rectangle())
            .overlay(ClickCatcher { _ in action() })
            .help(help)
            .accessibilityLabel(help)
            .accessibilityIdentifier(id)
    }
}

/// The red corner of a key that cannot work any more.
struct BrokenCorner: View {
    let side: CGFloat
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: side, y: 0))
                path.addLine(to: CGPoint(x: side, y: side))
                path.closeSubpath()
            }
            .fill(Color(red: 0.86, green: 0.16, blue: 0.14))
            Text("!").font(.system(size: side * 0.42, weight: .heavy)).foregroundStyle(.white)
                .padding(.trailing, side * 0.1).padding(.top, side * 0.0)
        }
        .frame(width: side, height: side)
        .clipShape(UnevenRoundedRectangle(topTrailingRadius: side * 0.5, style: .continuous))
    }
}

/// In Set up keys: a click picks the key, a drag moves it.
private struct DragKey: ViewModifier {
    let page: UUID?
    let index: Int
    let filled: Bool
    let press: () -> Void
    let drop: (String) -> Void

    func body(content: Content) -> some View {
        if let page {
            content
                .contentShape(Rectangle())
                .onTapGesture(perform: press)
                .draggable(filled ? "deckkey:\(page.uuidString):\(index)" : "")
                .dropDestination(for: String.self) { items, _ in
                    guard let item = items.first, item.hasPrefix("deckkey:") else { return false }
                    drop(item)
                    return true
                }
        } else {
            content
        }
    }
}
