import Foundation

/// The navigation picture slides away with a swipe to the left and comes back with a pull to the right (0.20).
public enum MapSwipe {
    /// How far the finger must go, as a part of the picture's width, for the picture to change state.
    public static let farEnough = 1.0 / 3.0
    /// How far a quick flick would carry it, as a part of the width, to count too.
    public static let flick = 0.5

    /// Whether the picture is open after the finger lets go.
    /// - Parameters:
    ///   - wasOpen: open before the drag started.
    ///   - moved: how far the finger went sideways (left is below zero).
    ///   - predicted: where a flick would carry it (the system's guess), sideways.
    ///   - width: the picture's full width.
    public static func opensAfter(wasOpen: Bool, moved: Double, predicted: Double, width: Double) -> Bool {
        guard width > 0 else { return wasOpen }
        let sign: Double = wasOpen ? -1 : 1           // closing goes left, opening goes right
        let far = sign * moved >= width * farEnough
        let flicked = sign * predicted >= width * flick
        return (far || flicked) ? !wasOpen : wasOpen
    }

    /// The quiet time after which the picture hides by itself (his pick, 0.22).
    public static let quietSeconds = 60.0

    /// The quiet times he can pick in Settings (0.23): 30 seconds, 1 minute, 2 minutes.
    public static let quietChoices = [30, 60, 120]

    /// Whether the picture hides by itself now: the switch is on, it shows, and nothing was touched for `after` seconds.
    public static func hidesBySelf(on: Bool, shown: Bool, idle: Double, after: Double = quietSeconds) -> Bool {
        on && shown && idle >= max(10, after)
    }

    /// iPhone on its side with the picture hidden: the heading steps aside so the keys get its height (his pick, 0.24).
    public static func headingShows(phoneSideways: Bool, mapHidden: Bool) -> Bool {
        !(phoneSideways && mapHidden)
    }

    /// The hint "Hold for groups" under the tab (his pick, 0.25): the first 3 times the tab appears,
    /// and never again once he has used the list.
    public static let hintTimes = 3
    public static func tabHintShows(timesShown: Int, usedList: Bool) -> Bool {
        !usedList && timesShown < hintTimes
    }

    /// An up or down swipe on the "Pages" tab, like on the keys (his pick, 0.26): +1 = the next page group
    /// (finger up), −1 = the one before (finger down), nil = not a clear up-or-down swipe.
    public static func groupStep(across: Double, along: Double) -> Int? {
        guard abs(along) > 60, abs(along) > abs(across) * 1.5 else { return nil }
        return along < 0 ? 1 : -1
    }

    /// The width that shows while the finger drags: never below zero, and a little stretch past full.
    public static func shownWidth(wasOpen: Bool, moved: Double, width: Double) -> Double {
        let raw = (wasOpen ? width : 0) + moved
        if raw > width { return width + (raw - width) * 0.15 }
        return max(0, raw)
    }
}

/// With the navigation picture hidden, the five favourites stand in a column left of the 15 keys (his pick, 0.21).
public enum FavouriteColumn {
    /// The extra room between the favourites column and the keys (on top of the key gap).
    public static let extraGap = 8.0

    /// The side of one of the 15 keys and of one favourite, so 3 rows of keys and a column of 5 favourites
    /// (as tall as the 3 rows) fill `width` × `height`.
    public static func sides(width: Double, height: Double, gap: Double) -> (key: Double, favourite: Double) {
        // Width: 5 keys + 4 gaps + the column gap + one favourite, where a favourite = (3 keys + 2 gaps − 4 gaps) / 5.
        let byWidth = (width - 4 * gap - (gap + extraGap) + 0.4 * gap) / 5.6
        let byHeight = (height - 2 * gap) / 3
        let key = max(10, (min(byWidth, byHeight)).rounded(.down))
        return (key, max(6, ((3 * key - 2 * gap) / 5).rounded(.down)))
    }

    /// Width over height of the keys with the column, for fitting the box.
    public static let ratio = 1.9
}

/// "Several pages at once" on an iPad held on its side (his pick, 0.28, "layout 5"): the keys come first.
/// The pages fill the screen; the five favourites and the "Pages" button stand in one more column at the
/// right, as big as the keys (or, with one row of pages, in a row under them); all the rest is one thin line.
public enum BigKeys {
    /// The room between two pages, and between the pages and the favourites.
    public static let between = 14.0
    /// The height of a page's name above its keys.
    public static let nameHeight = 16.0
    /// The height of the thin line under the keys (dot, heading, the three marks).
    public static let lineHeight = 30.0

    /// Where the favourites and the "Pages" button stand: in a column at the right (six places beside two
    /// rows of pages), in a row under one row of pages, or nowhere (no favourites to show).
    public enum Extras: Sendable { case column, row, none }

    public struct Plan: Equatable, Sendable {
        /// Pages side by side, and rows of pages.
        public let across: Int
        public let down: Int
        /// The side of one key, and of one favourite.
        public let side: Double
        public let extras: Extras
    }

    /// The layout that gives the biggest square keys for `pages` pages in width × height; nil for fewer
    /// than 2 pages or more than 4 (then the usual screen shows).
    public static func plan(width: Double, height: Double, gap: Double, pages: Int, favourites: Bool) -> Plan? {
        guard (2...4).contains(pages) else { return nil }
        var best: Plan?
        for down in 1...2 {
            let across = (pages + down - 1) / down
            // One page above another only when both rows are used.
            guard down == 1 || pages > across * (down - 1) else { continue }
            let extras: Extras = !favourites ? .none : (down == 2 ? .column : .row)
            let a = Double(across), d = Double(down)
            let byWidth = (width - a * 4 * gap - (a - 1) * between - (extras == .column ? between : 0))
                / (5 * a + (extras == .column ? 1 : 0))
            let byHeight = (height - d * (nameHeight + 3 * gap) - (d - 1) * between - (extras == .row ? between : 0))
                / (3 * d + (extras == .row ? 1 : 0))
            let side = max(10, min(byWidth, byHeight).rounded(.down))
            if side > (best?.side ?? 0) { best = Plan(across: across, down: down, side: side, extras: extras) }
        }
        return best
    }
}
