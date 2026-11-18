import AppKit

/// 0.16: small helpers for the safety work.

/// A question before something that is not taken back: Cancel is the first button, so Return and
/// Escape both cancel. The action takes a click.
enum SafeAsk {
    static func run(_ alert: NSAlert, action: String) -> Bool {
        alert.addButton(withTitle: "Cancel")
        let button = alert.addButton(withTitle: action)
        button.keyEquivalent = ""
        return alert.runModal() == .alertSecondButtonReturn
    }
}

/// The shortcut that shows the keys on screen could not be taken: another app uses it.
enum ShortcutState {
    static var taken = false
}

/// Lets the Set up keys window ask the open key question before it closes (set by SetupView).
enum SetupGuard {
    static var mayLeave: (() -> Bool)?
}

/// Every script the app runs gets a time limit, so a stuck app cannot hold Deck Mate up.
enum Scripts {
    static func limited(_ source: String, seconds: Int = 5) -> String {
        "with timeout of \(seconds) seconds\n\(source)\nend timeout"
    }
}
