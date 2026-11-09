import Foundation
import MyTBAKit
import Testing

@testable import The_Blue_Alliance

@MainActor
final class MockFirebaseMessaging: FirebaseMessagingRegistering {

    var unregisterError: (any Error)?
    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0

    func register() async throws {
        registerCallCount += 1
    }

    func unregister() async throws {
        unregisterCallCount += 1
        if let unregisterError {
            throw unregisterError
        }
    }

}

final class MockRemoteNotificationRegistrar: RemoteNotificationRegistering {
    func registerForRemoteNotifications(completion: (((any Error)?) -> Void)?) {}
}

@MainActor
struct PushServiceTests {

    let defaults = UserDefaults(suiteName: UUID().uuidString)!
    let authService = MockAuthService()
    let myTBA = MockSessionMyTBA()
    let firebaseMessaging = MockFirebaseMessaging()
    let reporter = MockReporter()

    func makePushService() -> PushService {
        PushService(
            reporter: reporter,
            authService: authService,
            myTBA: myTBA,
            registrar: MockRemoteNotificationRegistrar(),
            firebaseMessaging: firebaseMessaging,
            defaults: defaults
        )
    }

    /// Sign-in changes reach PushService through an async observation.
    func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<200 where !condition() {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test func reportedFIDSurvivesRelaunch() {
        makePushService().didReceiveRegistration("fid-1")

        #expect(makePushService().registeredFID == "fid-1")
        #expect(defaults.string(forKey: "kRegisteredFID") == "fid-1")
    }

    @Test func reportedFIDIsRegisteredWithTBA() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        // Signing in registers once on its own
        await waitUntil { myTBA.registerCallCount == 1 }

        pushService.didReceiveRegistration("fid-1")
        await pushService.registerTask?.value

        #expect(pushService.registeredFID == "fid-1")
        #expect(myTBA.registerCallCount == 2)
        #expect(reporter.errors.isEmpty)
    }

    @Test func reportedFIDIsNotRegisteredWithTBAWhenSignedOut() async {
        let pushService = makePushService()

        pushService.didReceiveRegistration("fid-1")
        await pushService.registerTask?.value

        #expect(pushService.registeredFID == "fid-1")
        #expect(myTBA.registerCallCount == 0)
    }

    @Test func signingInRegistersWithFirebase() async {
        let pushService = makePushService()

        authService.isSignedIn = true
        await waitUntil { firebaseMessaging.registerCallCount == 1 }

        #expect(firebaseMessaging.registerCallCount == 1)
        #expect(pushService.registerTask != nil)
    }

    @Test func unregisteringFromFirebaseForgetsFID() async throws {
        let pushService = makePushService()
        pushService.didReceiveRegistration("fid-1")

        try await pushService.unregisterFromFirebase()

        #expect(firebaseMessaging.unregisterCallCount == 1)
        #expect(pushService.registeredFID == nil)
        #expect(makePushService().registeredFID == nil)
    }

    @Test func failedUnregisterKeepsFID() async {
        let pushService = makePushService()
        pushService.didReceiveRegistration("fid-1")
        firebaseMessaging.unregisterError = MockError.boom

        await #expect(throws: MockError.boom) {
            try await pushService.unregisterFromFirebase()
        }
        #expect(pushService.registeredFID == "fid-1")
    }

}
