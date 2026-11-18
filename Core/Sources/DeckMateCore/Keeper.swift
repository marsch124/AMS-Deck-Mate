// The rules of "comes back by itself" (Mac 0.16.1): only one copy, and the keeper's start order.

/// Only one copy of the app may sit in the menu bar.
public enum OneCopy {
    /// One running copy: when it started (seconds) and its process number.
    public struct Copy: Equatable {
        public let started: Double
        public let pid: Int32
        public init(started: Double, pid: Int32) { self.started = started; self.pid = pid }
    }

    /// The copies that started before `me`. Same start time: the smaller process number counts as earlier.
    public static func earlier(than me: Copy, among others: [Copy]) -> [Copy] {
        others.filter { $0.started < me.started || ($0.started == me.started && $0.pid < me.pid) }
    }

    /// When two copies start in the same moment, the one that started first stays and the later one quits.
    /// (Before Mac 0.16.1 each copy saw the other and both quit, so none was left.)
    public static func mustQuit(me: Copy, others: [Copy]) -> Bool {
        !earlier(than: me, among: others).isEmpty
    }
}

/// The keeper: a second start order with the Mac, apart from the Mac's own login list. It opens the app at
/// every login and opens it again when it stops unexpectedly.
public enum Keeper {
    public static let label = "com.schabbauer.AMSDeckMate.keeper"
    /// How a copy knows the keeper opened it.
    public static let argument = "--keeper"
    /// For checks: a copy opened with one of these never hands itself over to the keeper.
    public static let plainArguments = ["--plain", "--checks", "--data"]

    /// The start order as the Mac wants it written down.
    public static func plist(executable: String, bundleID: String) -> [String: Any] {
        [
            "Label": label,
            "ProgramArguments": [executable, argument],
            // Opened at every login …
            "RunAtLoad": true,
            // … and again after an unexpected stop, but not after Quit (a clean end).
            "KeepAlive": ["SuccessfulExit": false],
            "ProcessType": "Interactive",
            "LimitLoadToSessionType": "Aqua",
            // So that System Settings lists it under the app's own name.
            "AssociatedBundleIdentifiers": [bundleID],
        ]
    }

    /// A copy opened by hand (or by the Mac's login list) gives way to the keeper, so the app is always looked
    /// after — but only while "Open at login" is on and the app sits in an Applications folder.
    public static func handsOver(wanted: Bool, openedByKeeper: Bool, plain: Bool, inApplications: Bool) -> Bool {
        wanted && !openedByKeeper && !plain && inApplications
    }
}
