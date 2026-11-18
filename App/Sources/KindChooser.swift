import DeckMateCore
import SwiftUI

/// "What it does": a button with the kind's name; it opens a searchable list under coloured headings.
struct KindChooser: View {
    @Binding var selection: ActionType
    let allowed: (ActionType) -> Bool
    @State private var open = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button { open = true } label: {
            HStack(spacing: 6) {
                Text(selection.title).lineLimit(1)
                Spacer(minLength: 4)
                Chevron().stroke(Color.secondary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 9, height: 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButton())
        .accessibilityIdentifier("kindPicker")
        .popover(isPresented: $open, arrowEdge: .bottom) {
            KindList(current: selection, allowed: allowed) { kind in
                selection = kind
                open = false
            } close: { open = false }
        }
    }
}

private struct Chevron: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

struct KindList: View {
    let current: ActionType
    let allowed: (ActionType) -> Bool
    let pick: (ActionType) -> Void
    let close: () -> Void
    @State private var search = ""
    @State private var highlight = 0
    @FocusState private var searching: Bool
    @Environment(\.colorScheme) private var scheme

    private var groups: [(group: KindGroup, kinds: [ActionType])] {
        KindGroup.search(search, names: { $0.title }, allowed: allowed)
    }

    private var flat: [ActionType] { groups.flatMap(\.kinds) }

    var body: some View {
        VStack(spacing: 6) {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .focused($searching)
                .accessibilityIdentifier("kindSearch")
                .onSubmit { if flat.indices.contains(highlight) { pick(flat[highlight]) } }
                .onChange(of: search) { _, _ in highlight = 0 }
                .onKeyPress(.downArrow) { highlight = min(highlight + 1, max(flat.count - 1, 0)); return .handled }
                .onKeyPress(.upArrow) { highlight = max(highlight - 1, 0); return .handled }
                .onKeyPress(.escape) { close(); return .handled }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if groups.isEmpty {
                            Text("Nothing found").font(.callout).foregroundStyle(.secondary).padding(6)
                        }
                        ForEach(groups, id: \.group.title) { entry in
                            Text(entry.group.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Palette.part(entry.group.part, scheme))
                                .padding(.horizontal, 6).padding(.top, 6).padding(.bottom, 1)
                            ForEach(entry.kinds, id: \.self) { kind in
                                row(kind).id(kind)
                            }
                        }
                    }
                }
                .onChange(of: highlight) { _, _ in
                    if flat.indices.contains(highlight) { proxy.scrollTo(flat[highlight]) }
                }
            }
        }
        .padding(8)
        .frame(width: 300, height: 420)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("kindChooser")
        .onAppear { searching = true }
    }

    private func row(_ kind: ActionType) -> some View {
        let isHot = flat.indices.contains(highlight) && flat[highlight] == kind
        return Button { pick(kind) } label: {
            HStack {
                Text(kind.title)
                Spacer(minLength: 0)
                if kind == current {
                    Circle().fill(Palette.part("keys", scheme)).frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 6).padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.part("keys", scheme).opacity(isHot ? 0.18 : 0), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("kind-\(kind.rawValue)")
    }
}
