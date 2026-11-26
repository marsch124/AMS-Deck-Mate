import Foundation
import Security
import DeckMateCore

/// The "today" note AMS Triathlon Training keeps on this device (0.33), for the Mac's "Training today" key.
/// It lives in a Keychain group both apps may read (`TrainingKeys.group`), on this device only, never in
/// iCloud. Deck Mate only reads it: nothing here writes or deletes.
enum TrainingNoteStore {
    /// The note as it is (JSON words); nil = there is none, it cannot be read, or it is far too large.
    static func read() -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: TrainingKeys.service,
                                    kSecAttrAccount as String: TrainingKeys.account,
                                    kSecAttrAccessGroup as String: TrainingKeys.group,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var found: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &found) == errSecSuccess, let data = found as? Data,
              data.count <= TrainingKeys.largest else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// The note, read as far as it makes sense.
    static func note() -> TrainingKeys.Note? {
        TrainingKeys.note(from: read().map { Data($0.utf8) })
    }
}
