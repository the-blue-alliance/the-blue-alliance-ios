import Foundation
import MyTBAKit
import Testing

@testable import The_Blue_Alliance

@MainActor
final class MockFirebasePush: FirebasePushRegistering {

    var installationIDResult: String? = "fid-1"
    var unregisterError: (any Error)?
    var deleteInstallationError: (any Error)?
    /// Stands in for Firebase calling back `messaging(_:didReceiveRegistration:)`.
    var onRegister: (() -> Void)?
    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0
    private(set) var deleteInstallationCallCount = 0

    func installationID() async throws -> String {
        guard let installationIDResult else {
            throw MockError.boom
        }
        return installationIDResult
    }

    func register() async throws {
        registerCallCount += 1
        onRegister?()
    }

    func unregister() async throws {
        unregisterCallCount += 1
        if let unregisterError {
            throw unregisterError
        }
    }

    func deleteInstallation() async throws {
        deleteInstallationCallCount += 1
        if let deleteInstallationError {
            throw deleteInstallationError
        }
    }

}

final class MockRemoteNotificationRegistrar: RemoteNotificationRegistering {
    func registerForRemoteNotifications(completion: (((any Error)?) -> Void)?) {}
}

@MainActor
struct PushServiceTests {

    let authService = MockAuthService()
    let myTBA = MockSessionMyTBA()
    let firebase = MockFirebasePush()
    let reporter = MockReporter()

    /// A PushService whose Firebase registration calls back with "fid-1", as Firebase does.
    func makePushService() -> PushService {
        let pushService = PushService(
            reporter: reporter,
            authService: authService,
            myTBA: myTBA,
            registrar: MockRemoteNotificationRegistrar(),
            firebase: firebase
        )
        firebase.onRegister = { [weak pushService] in
            pushService?.didReceiveRegistration("fid-1")
        }
        return pushService
    }

    /// PushService reacts to sign-in and Firebase asynchronously.
    func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<200 where !condition() {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test func loadsFIDFromFirebaseAtLaunch() async {
        let pushService = makePushService()

        await waitUntil { pushService.fid != nil }

        #expect(pushService.fid == "fid-1")
    }

    // The upgrade path: a restored sign-in can't register until the APNs token arrives.
    @Test func registersOnceTheAPNSTokenArrivesWhenSignedIn() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        #expect(firebase.registerCallCount == 0)

        pushService.didReceiveAPNSToken()
        await waitUntil { myTBA.registerCallCount == 1 }

        #expect(firebase.registerCallCount == 1)
        #expect(myTBA.registerCallCount == 1)
        #expect(reporter.errors.isEmpty)
    }

    @Test func doesNotRegisterWhenSignedOut() async {
        let pushService = makePushService()

        pushService.didReceiveAPNSToken()
        pushService.didReceiveRegistration("fid-1")
        await pushService.registerTask?.value

        #expect(firebase.registerCallCount == 0)
        #expect(myTBA.registerCallCount == 0)
    }

    @Test func signingInRegistersWhenTheAPNSTokenIsKnown() async {
        let pushService = makePushService()
        pushService.didReceiveAPNSToken()

        authService.isSignedIn = true
        await waitUntil { myTBA.registerCallCount == 1 }

        #expect(firebase.registerCallCount == 1)
        #expect(myTBA.registerCallCount == 1)
    }

    // Firebase reports nil when an unregister finishes, even one that failed.
    @Test func nilRegistrationKeepsFIDAndSkipsTBA() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }

        pushService.didReceiveRegistration(nil)
        await pushService.registerTask?.value

        #expect(pushService.fid == "fid-1")
        #expect(myTBA.registerCallCount == 0)
        #expect(reporter.errors.isEmpty)
    }

    @Test func pausingStopsTBARegistrationUntilResumed() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        pushService.didReceiveAPNSToken()
        await waitUntil { myTBA.registerCallCount >= 1 }

        await pushService.pauseRegistration()
        let registrations = myTBA.registerCallCount
        pushService.didReceiveRegistration("fid-1")
        await pushService.registerTask?.value
        #expect(myTBA.registerCallCount == registrations)

        pushService.resumeRegistration()
        await waitUntil { myTBA.registerCallCount == registrations + 1 }

        #expect(myTBA.registerCallCount == registrations + 1)
    }

    // Unregistering doesn't change the installation's FID.
    @Test func unregisteringFromFirebaseKeepsFID() async throws {
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }

        try await pushService.unregisterFromFirebase()

        #expect(firebase.unregisterCallCount == 1)
        #expect(pushService.fid == "fid-1")
    }

    @Test func deletingInstallationForgetsFID() async throws {
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }

        try await pushService.deleteFirebaseInstallation()

        #expect(firebase.deleteInstallationCallCount == 1)
        #expect(pushService.fid == nil)
    }

    @Test func failedInstallationDeleteKeepsFID() async {
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        firebase.deleteInstallationError = MockError.boom

        await #expect(throws: MockError.boom) {
            try await pushService.deleteFirebaseInstallation()
        }
        #expect(pushService.fid == "fid-1")
    }

}
