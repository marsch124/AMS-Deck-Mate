import SwiftUI
import DeckMateCore

/// The choices of a breathing pacer key: the rhythm and how many breaths. They ride in the key's target.
struct BreathFields: View {
    @Binding var action: DeckAction

    var body: some View {
        let setting = BreathKeys.setting(action.target)
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: Binding(get: { "\(setting.inSeconds)-\(setting.outSeconds)" }, set: { choice in
                let parts = choice.split(separator: "-").compactMap { Int($0) }
                guard parts.count == 2 else { return }
                action.target = BreathKeys.target(.init(inSeconds: parts[0], outSeconds: parts[1], breaths: setting.breaths))
            })) {
                ForEach(BreathKeys.rhythms, id: \.inSeconds) { rhythm in
                    Text(BreathKeys.rhythmWords(inSeconds: rhythm.inSeconds, outSeconds: rhythm.outSeconds))
                        .tag("\(rhythm.inSeconds)-\(rhythm.outSeconds)")
                }
            }
            .labelsHidden()
            .accessibilityIdentifier("breathRhythm")
            Picker("", selection: Binding(get: { setting.breaths }, set: { count in
                action.target = BreathKeys.target(.init(inSeconds: setting.inSeconds, outSeconds: setting.outSeconds, breaths: count))
            })) {
                ForEach(BreathKeys.counts, id: \.self) { Text("\($0) breaths").tag($0) }
            }
            .labelsHidden()
            .accessibilityIdentifier("breathCount")
            Text("A press starts a round: a soft bar rises while you breathe in and falls while you breathe out, and the key says “Breathe in” or “Breathe out”. After the last breath it goes quietly back to “Breathe”. Another press stops it. No numbers, no sound.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// One part of a progress bar across keys.
struct BarFields: View {
    @Binding var action: DeckAction

    var body: some View {
        let part = BarKeys.parse(action.target)
        VStack(alignment: .leading, spacing: 6) {
            Text("Part \(part.place) of \(part.count)").font(.callout)
                .accessibilityIdentifier("barPart")
            Text("Several of these keys side by side make one bar. Together they fill from left to right with the focus round that is running, else with the timer that ends last. With nothing running the parts stay empty.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
}
