import SwiftUI
import UIKit

/// Deck Mate on the iPhone: the same 15 keys as the Mac, one tap and the Mac does it.
@main
struct DeckMatePhoneApp: App {
    @StateObject private var link = LinkClient.make()
    @AppStorage("stayAwake") private var stayAwake = true
    @AppStorage("darkWhenMacSleeps") private var darkWhenMacSleeps = true

    private func keepAwake() {
        // While the Mac sleeps (and the screen goes dark with it) the iPhone or iPad may lock itself.
        if case .connected = link.state { UIApplication.shared.isIdleTimerDisabled = stayAwake && !(darkWhenMacSleeps && link.macAsleep && !link.asleepKeysShown) } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    var body: some Scene {
        WindowGroup {
            DeckScreen(link: link)
                .task { link.start() }
                // Keep the screen awake while the keys are in use, and let it sleep otherwise.
                .onChange(of: link.state, initial: true) { _, _ in keepAwake() }
                .onChange(of: stayAwake) { _, _ in keepAwake() }
                .onChange(of: link.macAsleep) { _, _ in keepAwake() }
                .onChange(of: link.asleepKeysShown) { _, _ in keepAwake() }
                .onChange(of: darkWhenMacSleeps) { _, _ in keepAwake() }
        }
    }
}
