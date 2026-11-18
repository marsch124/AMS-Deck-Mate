import Foundation

/// 0.16: small rules of the safety work.

/// A failed save is told once per run of failures; the next good save clears it.
public struct SaveWatch: Equatable, Sendable {
    private var told = false
    public init() {}

    /// Feed every save's result. True = this is the first failure of a run: show the window now.
    public mutating func saved(_ ok: Bool) -> Bool {
        if ok { told = false; return false }
        if told { return false }
        told = true
        return true
    }
}

/// Typed text is cut into pieces for the keyboard; a piece never ends inside a character.
public enum TypedText {
    /// Pieces of at most `most` UTF-16 units, cut between whole characters (an emoji stays whole).
    /// A single character longer than `most` stays whole in a piece of its own.
    public static func pieces(_ text: String, most: Int = 16) -> [[UInt16]] {
        var result: [[UInt16]] = []
        var current: [UInt16] = []
        for character in text {
            let units = Array(String(character).utf16)
            if !current.isEmpty, current.count + units.count > most {
                result.append(current)
                current = []
            }
            current += units
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}

extension Store {
    /// The Pictures folder inside the iCloud folder.
    public var cloudPictures: URL? { cloud?.appendingPathComponent("Pictures", isDirectory: true) }

    /// Puts the key pictures next to the weekly copy: only new or changed files. How many were written.
    @discardableResult
    public func copyPicturesToCloud() -> Int {
        guard let target = cloudPictures else { return 0 }
        return Store.copyPictures(from: pictures, to: target, overwrite: true)
    }

    /// Copies pictures that this Mac is missing back from the iCloud folder; never over one that exists.
    @discardableResult
    public func bringBackPictures() -> Int {
        guard let source = cloudPictures else { return 0 }
        return Store.copyPictures(from: source, to: pictures, overwrite: false)
    }

    static func copyPictures(from source: URL, to target: URL, overwrite: Bool) -> Int {
        let files = FileManager.default
        let names = ((try? files.contentsOfDirectory(atPath: source.path)) ?? []).filter { !$0.hasPrefix(".") }
        guard !names.isEmpty else { return 0 }
        try? files.createDirectory(at: target, withIntermediateDirectories: true)
        var written = 0
        for name in names {
            let from = source.appendingPathComponent(name)
            let to = target.appendingPathComponent(name)
            var isFolder: ObjCBool = false
            guard files.fileExists(atPath: from.path, isDirectory: &isFolder), !isFolder.boolValue else { continue }
            let exists = files.fileExists(atPath: to.path)
            if exists {
                guard overwrite else { continue }
                let a = try? files.attributesOfItem(atPath: from.path)
                let b = try? files.attributesOfItem(atPath: to.path)
                let same = (a?[.size] as? NSNumber) == (b?[.size] as? NSNumber)
                    && abs(((a?[.modificationDate] as? Date) ?? .distantPast).timeIntervalSince((b?[.modificationDate] as? Date) ?? .distantFuture)) < 1
                if same { continue }
            }
            guard let data = try? Data(contentsOf: from) else { continue }
            do {
                try data.write(to: to, options: .atomic)
                if let date = (try? files.attributesOfItem(atPath: from.path))?[.modificationDate] as? Date {
                    try? files.setAttributes([.modificationDate: date], ofItemAtPath: to.path)
                }
                written += 1
            } catch {}
        }
        return written
    }
}
