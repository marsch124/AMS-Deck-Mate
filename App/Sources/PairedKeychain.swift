import DeckMateCore
import Foundation
import LocalAuthentication
import Security

/// The secrets of the allowed iPhones, one item per iPhone in the login keychain. Every call is
/// non-interactive: if the Mac would show any window, the call fails instead, and the caller keeps
/// the secret where it was (UserDefaults). It never makes the Mac ask for a password.
enum PairedKeychain {
    static let service = "com.schabbauer.AMSDeckMate.pairedPhones"

    private static func base(_ id: String) -> [String: Any] {
        // The login keychain must never put a window on screen for this (process-wide; the app
        // uses the keychain for nothing else).
        SecKeychainSetUserInteractionAllowed(false)
        let context = LAContext()
        context.interactionNotAllowed = true
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: id,
                kSecUseAuthenticationContext as String: context]
    }

    /// The secret; nil when there is none or the Keychain could not be used without asking.
    static func read(_ id: String) -> String? {
        var query = base(id)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var found: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &found) == errSecSuccess,
              let data = found as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Saves the secret and reads it back; true only when the read-back is the same.
    @discardableResult
    static func write(_ id: String, _ secret: String) -> Bool {
        let data = Data(secret.utf8)
        var status = SecItemUpdate(base(id) as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var add = base(id)
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
            status = SecItemAdd(add as CFDictionary, nil)
        }
        return status == errSecSuccess && read(id) == secret
    }

    static func delete(_ id: String) {
        SecItemDelete(base(id) as CFDictionary)
    }
}

/// Which paired iPhones keep their secret where. Names always stay in UserDefaults.
enum PairedStore {
    private static var told = false

    private static func fail(_ why: String) {
        guard !told else { return }
        told = true
        BoxLog.note("paired iPhones: the Keychain could not be used (\(why)); secrets stay where they were")
    }

    /// Reads the saved list: names and secrets. A secret still in UserDefaults is moved to the
    /// Keychain; it leaves UserDefaults only after it was read back from the Keychain.
    static func load(_ key: String) -> (names: [String: String], secrets: [String: String]) {
        let defaults = UserDefaults.standard
        var saved = defaults.dictionary(forKey: key) as? [String: [String: String]] ?? [:]
        var names: [String: String] = [:]
        var secrets: [String: String] = [:]
        var changed = false
        for (id, entry) in saved {
            guard let name = entry["name"] else { continue }
            names[id] = name
            if let old = entry["secret"] {
                secrets[id] = old
                if PairedKeychain.write(id, old) {
                    saved[id] = ["name": name]
                    changed = true
                } else {
                    fail("moving over")
                }
            } else if let kept = PairedKeychain.read(id) {
                secrets[id] = kept
            }
        }
        if changed { defaults.set(saved, forKey: key) }
        return (names, secrets)
    }

    /// Writes the list: secrets to the Keychain, names to UserDefaults; a secret the Keychain
    /// would not take stays in UserDefaults as before.
    static func save(_ key: String, names: [String: String], secrets: [String: String]) {
        var paired: [String: [String: String]] = [:]
        for (id, name) in names {
            // A secret that could not be read this time keeps its name: it may be readable at the
            // next start, and dropping it would make him allow that iPhone again for nothing.
            guard let secret = secrets[id] else { paired[id] = ["name": name]; continue }
            if PairedKeychain.write(id, secret) {
                paired[id] = ["name": name]
            } else {
                fail("saving")
                paired[id] = ["name": name, "secret": secret]
            }
        }
        UserDefaults.standard.set(paired, forKey: key)
    }
}
