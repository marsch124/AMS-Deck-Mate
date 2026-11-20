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
