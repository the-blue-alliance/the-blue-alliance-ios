import Foundation
import MyTBAKit
import TBAAuth
import TBAUtils
import UIKit

enum MyTBASessionError: LocalizedError {
    case signIn(any Error)
    case pushAuthorization(any Error)
    case offline

    var errorDescription: String? {
        switch self {
        case .signIn(let error):
            return error.localizedDescription
        case .pushAuthorization(let error):
            return error.localizedDescription
        case .offline:
            return "Sign out needs a connection so this device stops receiving notifications."
        }
    }
}

/// A myTBA session is more than the Firebase identity behind it: it's also this
/// device's push registration, notification permission, and cached favorites.
/// This sequences those around sign-in and sign-out, so Google and Apple share
/// one flow and `AuthService` never has to know myTBA exists.
final class MyTBASessionService {

    private let authService: any AuthServiceProtocol
    private let myTBA: any MyTBAProtocol
    private let myTBAStores: MyTBAStores
    private let pushService: any PushServiceProtocol
    private let reporter: any Reporter
    private let applicationState: @MainActor () -> UIApplication.State
    private var foregroundObserver: NotificationCenter.ObservationToken?

    init(
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        myTBAStores: MyTBAStores,
        pushService: any PushServiceProtocol,
        reporter: any Reporter,
        applicationState: @escaping @MainActor () -> UIApplication.State = {
            UIApplication.shared.applicationState
        }
    ) {
        self.authService = authService
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pushService = pushService
        self.reporter = reporter
        self.applicationState = applicationState
    }

    /// Refreshes favorites and subscriptions each time the app comes back to the foreground, so
    /// a change made on the web or another device shows up without a silent push.
    func start() {
        foregroundObserver = NotificationCenter.default.addForegroundObserver { [weak self] in
            try? await self?.refresh()
        }
    }

    // MARK: - Refresh
    //
    // The only place favorites and subscriptions are fetched and saved. The foreground, sign-in,
    // silent pushes, and the myTBA screens all ask for a refresh here, and stars and lists update
    // from the stores.

    func refresh() async throws {
        // Task handles instead of async let, see #996.
        let favorites = Task { try await refreshFavorites() }
        let subscriptions = Task { try await refreshSubscriptions() }
        try await favorites.value
        try await subscriptions.value
    }

    func refreshFavorites() async throws {
        guard authService.isSignedIn else { return }
        let favorites = try await myTBA.fetchFavorites()
        // A sign-out while this was loading has already cleared the store.
        guard authService.isSignedIn else { return }
        myTBAStores.favorites.replaceAll(with: favorites)
    }

    func refreshSubscriptions() async throws {
        guard authService.isSignedIn else { return }
        let subscriptions = try await myTBA.fetchSubscriptions()
        guard authService.isSignedIn else { return }
        myTBAStores.subscriptions.replaceAll(with: subscriptions)
    }

    func signIn(
        with kind: AuthProviderKind,
        presenting viewController: UIViewController
    ) async throws {
        do {
            try await authService.signIn(with: kind, presenting: viewController)
        } catch AuthError.canceled {
            return
        } catch {
            throw MyTBASessionError.signIn(error)
        }
        // Not awaited, so it doesn't wait on the notification prompt below.
        Task { try? await refresh() }

        // The auth state change already kicked PushService into registering the
        // device. Without this prompt those pushes never display.
        do {
            try await pushService.requestAuthorizationForNotifications()
        } catch {
            throw MyTBASessionError.pushAuthorization(error)
        }
    }

    func signOut() async throws {
        // Two independent ways to stop pushes: TBA forgetting the device, or FCM
        // invalidating its token. Either is enough; at least one has to reach a
        // server before local state goes, or a signed-out phone keeps getting
        // the old user's notifications. Unregister has to go first, for two
        // reasons: it needs an ID token, so it can't follow Firebase sign-out,
        // and it needs the FCM token, which deleteToken drops from Firebase's
        // local cache before it even reaches the network.
        var stoppedPushes = false
        do {
            _ = try await myTBA.unregister()
            stoppedPushes = true
        } catch let error as MyTBAError where error.code == 404 {
            // Already unregistered server-side.
            stoppedPushes = true
        } catch MyTBAError.missingFCMToken {
            // Never registered, so there's nothing to stop.
            stoppedPushes = true
        } catch {
            reporter.record(error)
        }
        do {
            try await pushService.deletePushToken()
            stoppedPushes = true
        } catch {
            reporter.record(error)
        }
        // Safe to bail here: FCM already dropped its cached token, so it fetches
        // a fresh one, and PushService re-registers it since we're still signed in.
        guard stoppedPushes else {
            throw MyTBASessionError.offline
        }

        try authService.signOut()

        // After sign-out succeeds, so a failure can't strand us signed in with
        // the cached data already gone.
        myTBAStores.favorites.clear()
        myTBAStores.subscriptions.clear()
    }

    func restorePreviousSignIn() async {
        guard await authService.restorePreviousSignIn() else {
            return
        }
        // At launch the first foreground refresh runs before the session is back, so it skips.
        Task { try? await refresh() }
        // A silent push can launch us straight into the background, where
        // there's no one to answer a permission alert and a tight time budget
        // to spend. Registering the device doesn't depend on this - the
        // auth-state change drives that - so only the prompt waits.
        guard applicationState() != .background else {
            return
        }
        // Recorded rather than thrown, unlike signIn: nobody tapped anything, so
        // there's no action to attach an alert to.
        do {
            try await pushService.requestAuthorizationForNotifications()
        } catch {
            reporter.record(error)
        }
    }
}
