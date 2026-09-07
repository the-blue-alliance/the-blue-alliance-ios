import FirebaseAuth
import Foundation

/// Resolves `Auth.auth()` per call rather than holding it - `AuthService` can be
/// built before `FirebaseApp.configure()` returns.
@MainActor
final class FirebaseAuthenticator: FirebaseAuthenticating {

    private var listenerHandle: NSObjectProtocol?

    var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var currentProviderID: String? {
        Auth.auth().currentUser?.providerData.first?.providerID
    }

    func signIn(with credential: AuthCredential) async throws {
        _ = try await Auth.auth().signIn(with: credential)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func startListening(_ listener: @escaping (Bool) -> Void) {
        stopListening()
        // Firebase documents that this fires on the main thread, but its API
        // isn't annotated, so say so where the compiler can check it.
        listenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            MainActor.assumeIsolated {
                listener(user != nil)
            }
        }
    }

    func stopListening() {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
        listenerHandle = nil
    }
}
