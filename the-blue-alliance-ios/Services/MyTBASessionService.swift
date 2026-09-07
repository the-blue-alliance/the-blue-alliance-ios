import Foundation
import MyTBAKit
import TBAAuth
import TBAUtils
import UIKit

enum MyTBASessionError: LocalizedError {
    case signIn(Error)
    case pushAuthorization(Error)
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
@MainActor
final class MyTBASessionService {

    private let authService: any AuthServiceProtocol
    private let myTBA: any MyTBAProtocol
    private let myTBAStores: MyTBAStores
    private let pushService: any PushServiceProtocol
    private let reporter: any Reporter
    private let applicationState: @MainActor () -> UIApplication.State

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
