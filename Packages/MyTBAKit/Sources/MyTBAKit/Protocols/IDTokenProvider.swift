public protocol IDTokenProvider: AnyObject {
    // True when a user is signed in, independent of token freshness.
    var isSignedIn: Bool { get }

    // Returns a fresh ID token. Implementations are expected to silently
    // refresh expired tokens (Firebase's `getIDToken(completion:)` does this).
    func idToken() async throws -> String
}
