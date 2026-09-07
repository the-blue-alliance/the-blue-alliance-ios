import FirebaseAuth
import Foundation

/// The slice of FirebaseAuth `AuthService` needs, so its sequencing is testable
/// without a configured `FirebaseApp`.
@MainActor
protocol FirebaseAuthenticating: AnyObject {
    var isSignedIn: Bool { get }
    var currentProviderID: String? { get }

    func signIn(with credential: AuthCredential) async throws
    func signOut() throws

    /// One listener at a time; a second call replaces the first.
    func startListening(_ listener: @escaping (Bool) -> Void)
    func stopListening()
}
