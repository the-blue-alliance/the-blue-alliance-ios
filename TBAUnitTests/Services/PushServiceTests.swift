import Foundation
import MyTBAKit
import Testing

@testable import The_Blue_Alliance

@MainActor
final class MockFirebasePush: FirebasePushRegistering {

    var installationIDResult: String? = "fid-1"
    var deleteInstallationError: (any Error)?
    /// Stands in for Firebase calling back `messaging(_:didReceiveRegistration:)`.
    var onRegister: (() -> Void)?
    private(set) var registerCallCount = 0
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

    @Test func nilRegistrationKeepsFIDAndSkipsTBA() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }

        pushService.didReceiveRegistration(nil)
        await pushService.registerTask?.value

        #expect(pushService.fid == "fid-1")
        #expect(!pushService.isRegisteredWithFirebase)
        #expect(myTBA.registerCallCount == 0)
        #expect(reporter.errors.isEmpty)
    }

    // Firebase 12.18.0 calls back without the FID when `register()` finds it already
    // registered but hasn't loaded it yet this launch.
    @Test func registersWhenFirebaseCallsBackWithoutTheFID() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        firebase.onRegister = { [weak pushService] in
            pushService?.didReceiveRegistration(nil)
        }

        pushService.didReceiveAPNSToken()
        await waitUntil { myTBA.registerCallCount == 1 }

        #expect(pushService.isRegisteredWithFirebase)
        #expect(myTBA.registerCallCount == 1)
        #expect(reporter.errors.isEmpty)
    }

    // Resuming doesn't need Firebase again, which may be what failed: it's still registered.
    @Test func pausingStopsTBARegistrationUntilResumed() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        pushService.didReceiveAPNSToken()
        await waitUntil { myTBA.registerCallCount >= 1 }

        await pushService.pauseRegistration()
        let registrations = myTBA.registerCallCount
        let firebaseRegistrations = firebase.registerCallCount
        pushService.didReceiveRegistration("fid-1")
        await pushService.registerTask?.value
        await #expect(throws: PushServiceError.registrationPaused) {
            _ = try await pushService.registerWithTBA()
        }
        #expect(myTBA.registerCallCount == registrations)

        pushService.resumeRegistration()
        await waitUntil { myTBA.registerCallCount == registrations + 1 }

        #expect(myTBA.registerCallCount == registrations + 1)
        #expect(firebase.registerCallCount == firebaseRegistrations)
    }

    // Cancelling a request wouldn't stop TBA handling it, and one landing after sign-out's
    // unregister would re-add the device.
    @Test func pausingWaitsOutARegistrationTBAIsHandling() async {
        authService.isSignedIn = true
        myTBA.holdsRegister = true
        let pushService = makePushService()
        pushService.didReceiveRegistration("fid-1")
        await waitUntil { myTBA.registerCallCount == 1 }

        // TBA answers once the pause is already waiting on it.
        let myTBA = myTBA
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            myTBA.holdsRegister = false
        }
        await pushService.pauseRegistration()

        #expect(myTBA.finishedRegisterCount == 1)
        #expect(myTBA.cancelledRegisterCount == 0)
    }

    // Requests go one after another, so the last one finishing means they all have, which
    // is what pausing waits for.
    @Test func aNewFIDWaitsForTheRegistrationBeforeIt() async {
        authService.isSignedIn = true
        myTBA.holdsRegister = true
        let pushService = makePushService()
        pushService.didReceiveRegistration("fid-1")
        await waitUntil { myTBA.registerCallCount == 1 }

        pushService.didReceiveRegistration("fid-2")
        try? await Task.sleep(for: .milliseconds(50))
        #expect(myTBA.registerCallCount == 1)

        myTBA.holdsRegister = false
        await waitUntil { myTBA.finishedRegisterCount == 2 }

        #expect(myTBA.finishedRegisterCount == 2)
        #expect(myTBA.cancelledRegisterCount == 0)
    }

    // Registering a FID with TBA deletes the install's old FCM token, which until Firebase
    // registers the FID is the only way pushes reach it.
    @Test func tbaRegistrationWaitsForFirebaseToRegisterTheFID() async {
        authService.isSignedIn = true
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }

        await #expect(throws: PushServiceError.notRegisteredWithFirebase) {
            _ = try await pushService.registerWithTBA()
        }
        #expect(myTBA.registerCallCount == 0)
        #expect(!pushService.isRegisteredWithFirebase)

        pushService.didReceiveRegistration("fid-1")
        #expect(pushService.isRegisteredWithFirebase)
    }

    // Sign-out names the FID to TBA.
    @Test func pausingReadsTheFIDAgainWhenLaunchCouldNot() async {
        firebase.installationIDResult = nil
        let pushService = makePushService()
        await waitUntil { reporter.errors.count == 1 }
        #expect(pushService.fid == nil)

        firebase.installationIDResult = "fid-1"
        await pushService.pauseRegistration()

        #expect(pushService.fid == "fid-1")
    }

    @Test func deletingInstallationForgetsFID() async throws {
        let pushService = makePushService()
        await waitUntil { pushService.fid != nil }
        pushService.didReceiveRegistration("fid-1")

        try await pushService.deleteFirebaseInstallation()

        #expect(firebase.deleteInstallationCallCount == 1)
        #expect(pushService.fid == nil)
        #expect(!pushService.isRegisteredWithFirebase)
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
