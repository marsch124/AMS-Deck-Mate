import Foundation

/// The phone's evening rule: inside a window of the night (it may pass midnight) the resting clock
/// comes after one minute without a touch, whatever the resting clock setting says.
public enum PhoneEvening {
    /// Minutes without a touch inside the evening window.
    public static let eveningMinutes = 1
    /// Defaults: 21:30 and 07:00, as minutes since midnight.
    public static let defaultFrom = 21 * 60 + 30
    public static let defaultTo = 7 * 60

    /// Is `now` (minutes since midnight) in the window from `from` to `to`? from == to = never.
    public static func inWindow(now: Int, from: Int, to: Int) -> Bool {
        if from == to { return false }
        return from < to ? (now >= from && now < to) : (now >= from || now < to)
    }

    /// The minutes without a touch before the resting clock shows; 0 = never.
    /// `setting` is the usual resting clock choice (0 = never).
    public static func restMinutes(setting: Int, on: Bool, now: Int, from: Int, to: Int) -> Int {
        guard on, inWindow(now: now, from: from, to: to) else { return setting }
        return setting > 0 ? min(setting, eveningMinutes) : eveningMinutes
    }
}

/// How long the phone waits before it looks for a Mac again after failed tries in a row.
public enum PhoneBackoff {
    public static let waits: [TimeInterval] = [1, 2, 4, 8, 15, 30]

    /// `failures` = failed tries in a row so far (1 = the first failure): 1, 2, 4, 8, 15, then 30 s.
    public static func wait(afterFailures failures: Int) -> TimeInterval {
        waits[min(max(failures, 1), waits.count) - 1]
    }
}
