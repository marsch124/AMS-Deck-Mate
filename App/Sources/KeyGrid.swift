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
    var onPress: (Int) -> Void

    private var width: CGFloat { side * 5 + gap * 4 }
    private var height: CGFloat { side * 3 + gap * 2 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<StreamDeckProtocol.keyCount, id: \.self) { index in
                keyView(index)
                    .offset(x: CGFloat(index % 5) * (side + gap), y: CGFloat(index / 5) * (side + gap))
            }
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
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .accessibilityElement()
        .accessibilityLabel(keys[index]?.title ?? "Empty key")
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
                    gap: model.deck.screenSize.gap) { model.click($0) }
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
