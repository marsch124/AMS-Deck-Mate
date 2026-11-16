import SwiftUI
import UIKit
import DeckMateCore

/// The main screen: the place line, the link status, and the 5 x 3 keys.
struct DeckScreen: View {
    @ObservedObject var link: LinkClient
    @State private var showSettings = false

    private var connected: Bool {
        if case .connected = link.state { return true }
        return false
    }

    var body: some View {
        ZStack {
            PhonePalette.ground.ignoresSafeArea()
            VStack(spacing: 10) {
                topBar
                GeometryReader { box in
                    let side = Self.keySide(in: box.size)
                    KeyGrid(link: link, side: side)
                        .frame(width: box.size.width, height: box.size.height)
                        .opacity(connected ? 1 : 0.35)
                        .overlay {
                            if !connected { messageCard }
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) { PhoneSettings(link: link) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("deckScreen")
    }

    /// The side of one square key, so 5 x 3 keys with a gap of 8 fill the room.
    static func keySide(in size: CGSize) -> CGFloat {
        let gap: CGFloat = 8
        let byWidth = (size.width - 4 * gap) / 5
        let byHeight = (size.height - 2 * gap) / 3
        return max(10, floor(min(byWidth, byHeight)))
    }

    // MARK: Top line

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(link.place.isEmpty ? "Deck Mate" : link.place)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .accessibilityIdentifier("deckPlace")
                HStack(spacing: 6) {
                    Circle().fill(statusColour).frame(width: 8, height: 8)
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("linkStatus")
            }
            Spacer(minLength: 8)
            Button { showSettings = true } label: {
                PhoneIcon(name: "iconSettings", size: 24)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("settingsButton")
        }
    }

    private var statusColour: Color {
        switch link.state {
        case .connected: return Color(red: 0.36, green: 0.80, blue: 0.45)
        case .refused: return Color(red: 0.95, green: 0.40, blue: 0.30)
        default: return Color(red: 0.95, green: 0.70, blue: 0.25)
        }
    }

    private var statusText: String {
        switch link.state {
        case .looking: return "Looking for your Mac…"
        case let .connecting(mac): return "Connecting to \(mac)…"
        case let .waiting(mac): return "Waiting for \(mac) to allow this iPhone"
        case let .connected(mac): return "Connected to \(mac)"
        case let .refused(mac): return "\(mac) said no"
        }
    }

    // MARK: Message card

    private var messageCard: some View {
        VStack(spacing: 8) {
            Text(cardTitle).font(.title3.weight(.semibold)).multilineTextAlignment(.center)
            if let text = cardText {
                Text(text).font(.callout).multilineTextAlignment(.center).foregroundStyle(.secondary)
            }
            if case .refused = link.state {
                Button("Ask again") { link.retry() }
                    .buttonStyle(PhoneMainButton(part: "screen"))
                    .padding(.top, 4)
                    .accessibilityIdentifier("askAgain")
            }
        }
        .padding(16)
        .frame(maxWidth: 340)
        .background(Color(red: 0.19, green: 0.19, blue: 0.2), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .foregroundStyle(.white)
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("linkMessage")
    }

    private var cardTitle: String {
        switch link.state {
        case .looking: return "Looking for your Mac…"
        case let .connecting(mac): return "Connecting to \(mac)…"
        case let .waiting(mac): return "Allow this iPhone on \(mac)"
        case let .refused(mac): return "\(mac) said no"
        case .connected: return ""
        }
    }

    private var cardText: String? {
        switch link.state {
        case .looking: return "Open AMS Deck Mate on the Mac and put both on the same Wi-Fi — or the Mac on this iPhone’s hotspot."
        case .waiting: return "Your Mac is asking whether this iPhone may use the keys. Click Allow there."
        default: return nil
        }
    }
}

/// The 15 keys, 5 across and 3 down.
private struct KeyGrid: View {
    @ObservedObject var link: LinkClient
    let side: CGFloat
    private let gap: CGFloat = 8

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<5, id: \.self) { column in
                        let index = row * 5 + column
                        KeyView(index: index, key: link.keys[index], side: side) { link.press(index) }
                    }
                }
            }
        }
    }
}

/// One key: the picture the Mac drew, or an empty place.
private struct KeyView: View {
    let index: Int
    let key: PhoneLink.Key?
    let side: CGFloat
    let press: () -> Void
    @State private var pressed = false

    private var image: UIImage? { key?.picture.flatMap { UIImage(data: $0) } }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: side * 0.16, style: .continuous)
        ZStack {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(width: side, height: side)
                    .clipShape(shape)
                    .overlay(shape.fill(Color.black.opacity(pressed ? 0.35 : 0)))
            } else {
                shape.fill(Color.black)
                    .overlay(shape.strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
            }
        }
        .frame(width: side, height: side)
        .scaleEffect(pressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.08), value: pressed)
        .contentShape(shape)
        .onTapGesture {
            guard image != nil else { return }   // empty places do nothing
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            pressed = true
            press()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { pressed = false }
        }
        .accessibilityElement()
        .accessibilityLabel(image == nil ? "Empty key" : (key?.title ?? "Key"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("key\(index)")
    }
}
