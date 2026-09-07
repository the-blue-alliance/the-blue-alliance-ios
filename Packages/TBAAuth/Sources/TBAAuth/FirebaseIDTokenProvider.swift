import FirebaseAuth
import Foundation

/// Separate from `AuthService` because it can't be `@MainActor` - callers fetch
/// tokens from arbitrary task contexts.
public final class FirebaseIDTokenProvider: Sendable {

    public init() {}

    public var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    public func idToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notSignedIn
        }
        return try await withCheckedThrowingContinuation { continuation in
            user.getIDToken { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: AuthError.notSignedIn)
                }
            }
        }
    }
}
