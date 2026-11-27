import Foundation

/// How the pages shown at once ("Several pages at once") are set apart. Pure data, no drawing.
public enum GroupLook: String, CaseIterable, Sendable {
    case frames, plates, lines

    /// The standard look; an unknown or missing stored value reads as this.
    public static let standard = GroupLook.frames

    public static func from(raw: String?) -> GroupLook {
        raw.flatMap(GroupLook.init(rawValue:)) ?? .standard
    }
}

/// The colour of a page place: place 0 purple, 1 blue, 2 green, 3 red; then it starts again.
public enum GroupColour: String, CaseIterable, Sendable {
    case purple, blue, green, red

    public static func forPlace(_ place: Int) -> GroupColour {
        let all = allCases
        return all[((place % all.count) + all.count) % all.count]
    }
}
