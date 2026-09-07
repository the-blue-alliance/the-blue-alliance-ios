import FirebaseAuth
import TBAUtils
import UIKit

@MainActor
public final class AuthService: AuthServiceProtocol {

    private let firebase: any FirebaseAuthenticating
    private let providers: [any IdentityProviding]
    private let reporter: any Reporter

    private var isListening = false
    private let observers = NSHashTable<AnyObject>.weakObjects()

    public convenience init(reporter: any Reporter) {
        self.init(
            firebase: FirebaseAuthenticator(),
            providers: [GoogleIdentityProvider(), AppleIdentityProvider()],
            reporter: reporter
        )
    }

    init(
        firebase: any FirebaseAuthenticating,
        providers: [any IdentityProviding],
        reporter: any Reporter
    ) {
        self.firebase = firebase
        self.providers = providers
        self.reporter = reporter
    }

    isolated deinit {
        firebase.stopListening()
    }

    // MARK: - State

    public var isSignedIn: Bool {
        firebase.isSignedIn
    }

    public var currentProviderKind: AuthProviderKind? {
        firebase.currentProviderID.flatMap(AuthProviderKind.init(firebaseProviderID:))
    }

    public func start() {
        guard !isListening else {
            return
        }
        isListening = true
        firebase.startListening { [weak self] isSignedIn in
            guard let self else { return }
            for case let observer as any AuthStateObserving in self.observers.allObjects {
                observer.authStateChanged(isSignedIn: isSignedIn)
            }
        }
    }

    public func addStateObserver(_ observer: any AuthStateObserving) {
        observers.add(observer)
    }

    public func removeStateObserver(_ observer: any AuthStateObserving) {
        observers.remove(observer)
    }

    // MARK: - Sign in / out

    public func signIn(
        with kind: AuthProviderKind,
        presenting viewController: UIViewController
    ) async throws {
        guard let provider = providers.first(where: { $0.kind == kind }) else {
            throw AuthError.unsupportedProvider(kind)
        }
        let credential = try await provider.credential(presenting: viewController)
        try await firebase.signIn(with: credential)
    }

    public func signOut() throws {
        try firebase.signOut()
        // Every provider, not just the current one. Signing out of a provider
        // whose SDK has no session is a no-op, while missing one leaves a
        // session `restorePreviousSignIn` would silently revive on next launch.
        for provider in providers {
            provider.signOut()
        }
    }

    @discardableResult
    public func restorePreviousSignIn() async -> Bool {
        // Firebase persists its own session; this only revives a provider SDK
        // session that outlived it.
        guard !firebase.isSignedIn else {
            return false
        }
        for provider in providers {
            do {
                guard let credential = try await provider.restoreCredential() else {
                    continue
                }
                try await firebase.signIn(with: credential)
                return true
            } catch {
                // TODO :I really hate this - we should look into an alternative
                reporter.record(error)
            }
        }
        return false
    }

    @discardableResult
    public func handle(_ url: URL) -> Bool {
        return providers.contains { $0.handle(url) }
    }
}
