import SwiftUI
import UIKit

/// Deck Mate on the iPhone: the same 15 keys as the Mac, one tap and the Mac does it.
@main
struct DeckMatePhoneApp: App {
    @StateObject private var link = LinkClient.make()
    @AppStorage("stayAwake") private var stayAwake = true

    private func keepAwake() {
        if case .connected = link.state { UIApplication.shared.isIdleTimerDisabled = stayAwake } else {
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
        }
    }
}
