import UIKit

@MainActor
public protocol AuthServiceProtocol: AnyObject {
    /// Observable: reads inside `updateProperties()` or `Observations` update on sign-in and sign-out.
    var isSignedIn: Bool { get }
    var currentProviderKind: AuthProviderKind? { get }

    /// Call once, after Firebase is configured.
    func start()

    func signIn(
        with kind: AuthProviderKind,
        presenting viewController: UIViewController
    ) async throws
    func signOut() throws

    /// Returns whether a session was established.
    @discardableResult func restorePreviousSignIn() async -> Bool

    @discardableResult func handle(_ url: URL) -> Bool
}
