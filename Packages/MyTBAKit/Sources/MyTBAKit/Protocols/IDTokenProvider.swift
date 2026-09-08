public protocol IDTokenProvider: AnyObject, Sendable {
    /// A fresh ID token for the signed-in user, or nil if there isn't one.
    /// Implementations are expected to silently refresh expired tokens
    /// (Firebase's `getIDToken(completion:)` does this).
    func idToken() async throws -> String?
}
