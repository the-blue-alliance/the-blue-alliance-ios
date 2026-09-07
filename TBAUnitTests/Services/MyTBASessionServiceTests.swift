import Foundation
import MyTBAKit
import TBAAuth
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MyTBASessionServiceTests {

    private struct Harness {
        let callLog: CallLog
        let authService: MockAuthService
        let myTBA: MockSessionMyTBA
        let pushService: MockPushService
        let reporter: MockReporter
        let stores: MyTBAStores
        let service: MyTBASessionService
        let directory: URL
    }

    private static func makeHarness(
        applicationState: UIApplication.State = .active
    ) -> Harness {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let callLog = CallLog()
        let authService = MockAuthService(callLog: callLog)
        let myTBA = MockSessionMyTBA(callLog: callLog)
        let pushService = MockPushService(callLog: callLog)
        let reporter = MockReporter()
        let stores = MyTBAStores(
            favorites: FavoritesStore(
                fileURL: directory.appendingPathComponent("favorites.json")
            ),
            subscriptions: SubscriptionsStore(
                fileURL: directory.appendingPathComponent("subscriptions.json")
            )
        )
        return Harness(
            callLog: callLog,
            authService: authService,
            myTBA: myTBA,
            pushService: pushService,
            reporter: reporter,
            stores: stores,
            service: MyTBASessionService(
                authService: authService,
                myTBA: myTBA,
                myTBAStores: stores,
                pushService: pushService,
                reporter: reporter,
                applicationState: { applicationState }
            ),
            directory: directory
        )
    }

    private static func seedStores(_ harness: Harness) {
        harness.stores.favorites.upsert(
            MyTBAFavorite(modelKey: "frc2337", modelType: .team)
        )
        harness.stores.subscriptions.upsert(
            MyTBASubscription(
                modelKey: "frc2337",
                modelType: .team,
                notifications: [.upcomingMatch]
            )
        )
    }

    // MARK: - Sign in

    @Test func signInRequestsPushAuthorizationForGoogle() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }

        try await harness.service.signIn(with: .google, presenting: UIViewController())

        #expect(harness.authService.signInKinds == [.google])
        #expect(harness.pushService.callCount == 1)
    }

    // Apple used to skip this entirely, so its subscriptions never displayed.
    @Test func signInRequestsPushAuthorizationForApple() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }

        try await harness.service.signIn(with: .apple, presenting: UIViewController())

        #expect(harness.authService.signInKinds == [.apple])
        #expect(harness.pushService.callCount == 1)
    }

    @Test func canceledSignInIsNotAnErrorAndSkipsPush() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.signInError = AuthError.canceled

        try await harness.service.signIn(with: .apple, presenting: UIViewController())

        #expect(harness.pushService.callCount == 0)
    }

    @Test func signInFailureIsWrapped() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.signInError = MockError.boom

        await #expect(throws: MyTBASessionError.self) {
            try await harness.service.signIn(with: .google, presenting: UIViewController())
        }
        #expect(harness.pushService.callCount == 0)
    }

    @Test func pushAuthorizationFailureIsWrappedSeparately() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.pushService.error = MockError.boom

        var caught: MyTBASessionError?
        do {
            try await harness.service.signIn(with: .google, presenting: UIViewController())
        } catch let error as MyTBASessionError {
            caught = error
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }

        guard case .pushAuthorization = caught else {
            Issue.record("Expected .pushAuthorization, got \(String(describing: caught))")
            return
        }
        // Sign in itself still succeeded.
        #expect(harness.authService.isSignedIn)
    }

    // MARK: - Sign out

    @Test func signOutUnregistersThenSignsOutThenClearsStores() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)

        try await harness.service.signOut()

        #expect(
            harness.callLog.entries == ["myTBA.unregister", "push.deleteToken", "auth.signOut"]
        )
        #expect(harness.stores.favorites.favorites.isEmpty)
        #expect(harness.stores.subscriptions.subscriptions.isEmpty)
    }

    @Test func signOutToleratesA404FromUnregister() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)
        harness.myTBA.unregisterError = MyTBAError.error(404, "Not found")
        harness.pushService.deleteTokenError = MockError.boom

        try await harness.service.signOut()

        #expect(harness.authService.signOutCallCount == 1)
        #expect(harness.stores.favorites.favorites.isEmpty)
        #expect(harness.reporter.errors.count == 1)
    }

    // Unregister needs the TBA API and can't be retried after Firebase sign-out,
    // so it's best-effort; deleting the FCM token is what stops pushes anyway.
    @Test func signOutContinuesWhenUnregisterFails() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)
        harness.myTBA.unregisterError = MyTBAError.error(500, "Server error")

        try await harness.service.signOut()

        #expect(harness.reporter.errors.count == 1)
        #expect(harness.pushService.deleteTokenCallCount == 1)
        #expect(harness.authService.signOutCallCount == 1)
        #expect(harness.stores.favorites.favorites.isEmpty)
    }

    // Neither server heard from us, so the device would keep receiving the old
    // user's pushes. Refuse, and leave everything as it was.
    @Test func signOutRefusesWhenNeitherServerIsReachable() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)
        harness.myTBA.unregisterError = MyTBAError.error(500, "Server error")
        harness.pushService.deleteTokenError = MockError.boom

        await #expect(throws: MyTBASessionError.self) {
            try await harness.service.signOut()
        }
        #expect(harness.reporter.errors.count == 2)
        #expect(harness.authService.signOutCallCount == 0)
        #expect(harness.stores.favorites.favorites.count == 1)
        #expect(harness.stores.subscriptions.subscriptions.count == 1)
    }

    @Test func signOutContinuesWhenDeleteTokenFails() async throws {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)
        harness.pushService.deleteTokenError = MockError.boom

        try await harness.service.signOut()

        #expect(harness.reporter.errors.count == 1)
        #expect(harness.authService.signOutCallCount == 1)
        #expect(harness.stores.favorites.favorites.isEmpty)
    }

    @Test func signOutLeavesStoresIntactWhenAuthSignOutFails() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        Self.seedStores(harness)
        harness.authService.signOutError = MockError.boom

        await #expect(throws: MockError.boom) {
            try await harness.service.signOut()
        }
        #expect(harness.stores.favorites.favorites.count == 1)
        #expect(harness.stores.subscriptions.subscriptions.count == 1)
    }

    // MARK: - Restore

    @Test func restoreRequestsPushOnlyWhenASessionCameBack() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.restoreResult = false

        await harness.service.restorePreviousSignIn()

        #expect(harness.pushService.callCount == 0)
    }

    @Test func restoreRequestsPushWhenASessionWasRestored() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.restoreResult = true

        await harness.service.restorePreviousSignIn()

        #expect(harness.pushService.callCount == 1)
    }

    // A silent push can launch the app straight into the background, where the
    // permission alert has no one to answer it.
    @Test func restoreSkipsPushPromptWhenLaunchedIntoTheBackground() async {
        let harness = Self.makeHarness(applicationState: .background)
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.restoreResult = true

        await harness.service.restorePreviousSignIn()

        #expect(harness.authService.restoreCallCount == 1)
        #expect(harness.pushService.callCount == 0)
    }

    @Test func restoreRequestsPushPromptWhenLaunchedIntoTheForeground() async {
        let harness = Self.makeHarness(applicationState: .active)
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.restoreResult = true

        await harness.service.restorePreviousSignIn()

        #expect(harness.pushService.callCount == 1)
    }

    @Test func restoreReportsPushFailureWithoutThrowing() async {
        let harness = Self.makeHarness()
        defer { try? FileManager.default.removeItem(at: harness.directory) }
        harness.authService.restoreResult = true
        harness.pushService.error = MockError.boom

        await harness.service.restorePreviousSignIn()

        #expect(harness.reporter.errors.count == 1)
    }
}
