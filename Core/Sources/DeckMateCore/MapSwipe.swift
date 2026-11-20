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

    /// The width that shows while the finger drags: never below zero, and a little stretch past full.
    public static func shownWidth(wasOpen: Bool, moved: Double, width: Double) -> Double {
        let raw = (wasOpen ? width : 0) + moved
        if raw > width { return width + (raw - width) * 0.15 }
        return max(0, raw)
    }
}
