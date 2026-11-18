import Foundation
import Security

/// Where the pairing secret of each Mac ("id:secret") is kept: in the Keychain, on this device only.
/// Every call can fail; the caller then keeps using the old place (UserDefaults), so nobody has to press
/// Allow on the Mac again because of a Keychain that would not answer.
enum MacKeyStore {
    static let service = "com.schabbauer.AMSDeckMatePhone.macKeys"

    private static func query(_ mac: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: mac,
         kSecAttrSynchronizable as String: false]
    }

    static func read(_ mac: String) -> String? {
        var request = query(mac)
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var found: CFTypeRef?
        guard SecItemCopyMatching(request as CFDictionary, &found) == errSecSuccess, let data = found as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// True only when the value was written and reads back the same.
    @discardableResult
    static func write(_ value: String, for mac: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        var status = SecItemUpdate(query(mac) as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var add = query(mac)
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            status = SecItemAdd(add as CFDictionary, nil)
        }
        return status == errSecSuccess && read(mac) == value
    }

    static func delete(_ mac: String) {
        SecItemDelete(query(mac) as CFDictionary)
    }
}
