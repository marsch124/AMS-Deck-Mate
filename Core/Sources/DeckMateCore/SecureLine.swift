import CryptoKit
import Foundation

/// Keeps the line between the iPhone and the Mac private: nobody on the same Wi-Fi can read it,
/// change it, repeat it or sit in between.
///
/// How a line starts (the only three messages ever sent readable):
/// 1. iPhone → Mac: a promise (the SHA-256 of its one-time public key).
/// 2. Mac → iPhone: the Mac's one-time public key.
/// 3. iPhone → Mac: the iPhone's one-time public key (the Mac checks it against the promise).
/// Both sides then hold the same secret and every later message is sealed with it.
public enum SecureLine {
    public enum Role: String, Sendable { case phone, mac }

    /// One side's one-time keys for one connection.
    public struct Keys: Sendable {
        private let own = Curve25519.KeyAgreement.PrivateKey()
        public init() {}
        public var publicKey: Data { own.publicKey.rawRepresentation }
        public var promise: Data { SecureLine.promise(for: publicKey) }

        fileprivate func secret(with other: Data) -> SharedSecret? {
            guard let theirs = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: other) else { return nil }
            return try? own.sharedSecretFromKeyAgreement(with: theirs)
        }
    }

    public static func promise(for key: Data) -> Data { Data(SHA256.hash(data: key)) }

    /// The sealed line once both keys are known.
    public struct Session: Sendable {
        private let sendKey: SymmetricKey
        private let readKey: SymmetricKey
        private var sent: UInt64 = 0
        private var read: UInt64 = 0
        /// Both public keys in one number: the same on both ends only when nobody sits in between.
        public let bind: Data

        fileprivate init(sendKey: SymmetricKey, readKey: SymmetricKey, bind: Data) {
            self.sendKey = sendKey
            self.readKey = readKey
            self.bind = bind
        }

        /// The four digits both screens show when an iPhone is allowed for the first time.
        public var code: String {
            let hash = SHA256.hash(data: Data("code".utf8) + bind)
            let number = hash.prefix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
            return String(format: "%04d", number % 10_000)
        }

        /// Seals one message. Each message has its own number, so none can be repeated or moved.
        public mutating func seal(_ body: Data) -> Data? {
            guard let nonce = SecureLine.nonce(sent),
                  let box = try? ChaChaPoly.seal(body, using: sendKey, nonce: nonce) else { return nil }
            sent += 1
            var sealed = Data()          // a fresh Data: CryptoKit hands out slices that do not start at 0
            sealed.append(box.ciphertext)
            sealed.append(box.tag)
            return sealed
        }

        /// Opens the next message; nil = it was changed, repeated, out of order, or not for this line.
        public mutating func open(_ sealed: Data) -> Data? {
            guard sealed.count >= 16, let nonce = SecureLine.nonce(read),
                  let box = try? ChaChaPoly.SealedBox(nonce: nonce, ciphertext: sealed.dropLast(16), tag: sealed.suffix(16)),
                  let body = try? ChaChaPoly.open(box, using: readKey) else { return nil }
            read += 1
            return body
        }

        /// Proves "I know the secret the Mac gave this iPhone" without sending the secret, and only
        /// for this one connection.
        public func proof(secret: String, by role: Role) -> String {
            let code = HMAC<SHA256>.authenticationCode(for: Data(role.rawValue.utf8) + bind,
                                                       using: SymmetricKey(data: Data(secret.utf8)))
            return Data(code).base64EncodedString()
        }

        public func checks(_ proof: String?, secret: String, by role: Role) -> Bool {
            guard let proof, let data = Data(base64Encoded: proof) else { return false }
            return HMAC<SHA256>.isValidAuthenticationCode(data, authenticating: Data(role.rawValue.utf8) + bind,
                                                          using: SymmetricKey(data: Data(secret.utf8)))
        }
    }

    /// The sealed line for `role`, from its own keys and the other side's public key.
    public static func session(_ keys: Keys, role: Role, other: Data) -> Session? {
        guard let secret = keys.secret(with: other) else { return nil }
        let phoneKey = role == .phone ? keys.publicKey : other
        let macKey = role == .mac ? keys.publicKey : other
        let bind = Data(SHA256.hash(data: phoneKey + macKey))
        func key(_ words: String) -> SymmetricKey {
            secret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: bind, sharedInfo: Data(words.utf8), outputByteCount: 32)
        }
        let up = key("phone to mac"), down = key("mac to phone")
        return Session(sendKey: role == .phone ? up : down, readKey: role == .phone ? down : up, bind: bind)
    }

    /// A new secret for an iPhone that was just allowed.
    public static func newSecret() -> String {
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0).base64EncodedString() }
    }

    private static func nonce(_ count: UInt64) -> ChaChaPoly.Nonce? {
        var bytes = Data(count: 4)
        withUnsafeBytes(of: count.bigEndian) { bytes.append(contentsOf: $0) }
        return try? ChaChaPoly.Nonce(data: bytes)
    }
}
