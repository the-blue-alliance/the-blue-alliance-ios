import FirebaseAuth
import UIKit

/// Vends Firebase credentials but never signs in with them, so `AuthService`
/// stays the only thing that talks to Firebase.
@MainActor
protocol IdentityProviding: AnyObject {
    var kind: AuthProviderKind { get }

    func credential(presenting viewController: UIViewController) async throws -> AuthCredential

    /// `nil` means there was nothing to restore, which isn't an error.
    func restoreCredential() async throws -> AuthCredential?

    func signOut()

    func handle(_ url: URL) -> Bool
}

extension IdentityProviding {
    func restoreCredential() async throws -> AuthCredential? { nil }
    func handle(_ url: URL) -> Bool { false }
}
