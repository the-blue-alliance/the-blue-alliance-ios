import CryptoKit
import Foundation

/// Apple signs the SHA-256 hash into the identity token; Firebase needs the raw
/// value to verify it. https://firebase.google.com/docs/auth/ios/apple
struct Nonce: Equatable {

    /// 64 characters, so `byte % count` divides 256 evenly. "W" is omitted on
    /// purpose - adding it makes 65 and biases the mapping.
    static let charset: [Character] = Array(
        "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
    )

    let raw: String

    var sha256: String {
        SHA256.hash(data: Data(raw.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    init(randomBytes: (Int) throws -> [UInt8] = Nonce.secureRandomBytes) throws {
        raw = String(try randomBytes(32).map { Self.charset[Int($0) % Self.charset.count] })
    }

    static func secureRandomBytes(_ count: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        guard status == errSecSuccess else {
            throw AuthError.nonceGenerationFailed(status)
        }
        return bytes
    }
}
