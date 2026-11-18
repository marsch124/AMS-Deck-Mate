import SwiftUI
import DeckMateCore

/// A time of day (minutes since midnight) as a small hour-and-minute field.
struct MinutesField: View {
    @Binding var minutes: Int
    var id: String

    var body: some View {
        DatePicker("", selection: Binding(
            get: {
                Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: Date()) ?? Date()
            },
            set: { minutes = DayMinutes.of($0) }), displayedComponents: .hourAndMinute)
            .labelsHidden()
            .datePickerStyle(.field)
            .fixedSize()
            .accessibilityIdentifier(id)
    }
}

/// Settings › The box: dim the box in the evening.
struct EveningDimRows: View {
    @ObservedObject var model: AppModel
    @State private var level = Double(BoxEvening.defaultBrightness)
    @State private var loaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("Dim in the evening", isOn: Binding(
                get: { model.deck.eveningDim },
                set: { on in model.change { $0.eveningDim = on } }))
                .toggleStyle(.checkbox)
                .accessibilityIdentifier("eveningDim")
            if model.deck.eveningDim {
                HStack(spacing: 6) {
                    Text("From")
                    MinutesField(minutes: Binding(get: { model.deck.eveningFrom },
                                                  set: { v in model.change { $0.eveningFrom = v } }), id: "eveningFrom")
                    Text("to")
                    MinutesField(minutes: Binding(get: { model.deck.eveningTo },
                                                  set: { v in model.change { $0.eveningTo = v } }), id: "eveningTo")
                    Spacer()
                }
                HStack {
                    Text("Evening brightness")
                    Slider(value: $level, in: 5...100, step: 5) { editing in
                        if !editing { model.change { $0.eveningBrightness = Int(level) } }
                    }
                    .tint(Palette.fill("box"))
                    .accessibilityIdentifier("eveningBrightness")
                    Text("\(Int(level)) %").monospacedDigit().frame(width: 44, alignment: .trailing)
                }
            }
            Text("From the first time to the second the box is as bright as the evening brightness says, otherwise as bright as the slider above. The time may pass midnight.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            level = Double(model.deck.eveningBrightness)
        }
    }
}

/// Set up keys › page group: show it at certain hours.
struct HoursRows: View {
    @ObservedObject var model: AppModel
    let profile: UUID

    private var current: DeckProfile? { model.deck.profile(profile) }

    private func change(_ edit: @escaping (inout DeckProfile) -> Void) {
        model.change { deck in
            guard let at = deck.profiles.firstIndex(where: { $0.id == profile }) else { return }
            edit(&deck.profiles[at])
        }
    }

    var body: some View {
        if let current {
            VStack(alignment: .leading, spacing: 4) {
                Toggle("Show at these hours", isOn: Binding(get: { current.hoursOn }, set: { on in change { $0.hoursOn = on } }))
                    .toggleStyle(.checkbox)
                    .accessibilityIdentifier("hoursOn")
                if current.hoursOn {
                    HStack(spacing: 4) {
                        MinutesField(minutes: Binding(get: { current.hoursFrom }, set: { v in change { $0.hoursFrom = v } }), id: "hoursFrom")
                        Text("to")
                        MinutesField(minutes: Binding(get: { current.hoursTo }, set: { v in change { $0.hoursTo = v } }), id: "hoursTo")
                    }
                }
                Text("In these hours it shows instead of the default page group, for apps that have no page group of their own. An app’s own page group, and one you picked by hand, always stay.")
                    .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// The fields of an "Often used" key.
struct OftenFields: View {
    @Binding var action: DeckAction

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: Binding(get: { OftenKeys.number(action.target) }, set: { action.target = String($0) })) {
                ForEach(1...OftenKeys.count, id: \.self) { Text($0 == 1 ? "1 (most)" : "\($0)").tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .accessibilityIdentifier("oftenPicker")
            Text("Shows the key you pressed most in the last 30 days (1), or the second, third, fourth or fifth most, with its picture and words. A press presses that key. Until there are enough presses it says “Not yet”.")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
}
