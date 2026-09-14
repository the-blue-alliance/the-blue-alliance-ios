import FirebaseAuth
import Observation
import TBAUtils
import UIKit

@MainActor
@Observable
public final class AuthService: AuthServiceProtocol {

    private let firebase: any FirebaseAuthenticating
    private let providers: [any IdentityProviding]
    private let reporter: any Reporter

    @ObservationIgnored private var isListening = false

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

    // Read straight from Firebase so it's never stale; the listener marks it changed for observers.
    public var isSignedIn: Bool {
        access(keyPath: \.isSignedIn)
        return firebase.isSignedIn
    }

    public var currentProviderKind: AuthProviderKind? {
        firebase.currentProviderID.flatMap(AuthProviderKind.init(firebaseProviderID:))
    }

    public func start() {
        guard !isListening else {
            return
        }
        isListening = true
        firebase.startListening { [weak self] _ in
            self?.withMutation(keyPath: \.isSignedIn) {}
        }
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
