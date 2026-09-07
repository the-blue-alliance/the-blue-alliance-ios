import UIKit

@MainActor
public protocol AuthServiceProtocol: AnyObject {
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

    func addStateObserver(_ observer: any AuthStateObserving)
    func removeStateObserver(_ observer: any AuthStateObserving)
}

@MainActor
public protocol AuthStateObserving: AnyObject {
    func authStateChanged(isSignedIn: Bool)
}
