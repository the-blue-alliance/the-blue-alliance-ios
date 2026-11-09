import FirebaseInstallations
import FirebaseMessaging
import Foundation
import MyTBAKit
import Observation
import TBAAuth
import TBAUtils
import UserNotifications
import UIKit

protocol RemoteNotificationRegistering: AnyObject {
    func registerForRemoteNotifications(completion: (((any Error)?) -> Void)?)
}

/// The Firebase calls PushService makes, so tests can stand in for Firebase.
protocol FirebasePushRegistering: AnyObject {
    func installationID() async throws -> String
    func register() async throws
    func unregister() async throws
    func deleteInstallation() async throws
}

final class FirebasePushRegistrar: FirebasePushRegistering {

    func installationID() async throws -> String {
        try await Installations.installations().installationID()
    }

    func register() async throws {
        try await Messaging.messaging().register()
    }

    func unregister() async throws {
        try await Messaging.messaging().unregister()
    }

    func deleteInstallation() async throws {
        try await Installations.installations().delete()
    }

}

protocol PushServiceProtocol: AnyObject {
    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?)
    @discardableResult func requestAuthorizationForNotifications() async throws -> Bool
    /// Stops registering with TBA, waiting out any request in flight, so it can't re-add
    /// the device while sign-out removes it. Signing in again resumes it.
    func pauseRegistration() async
    /// Registers again after a sign-out that didn't go through.
    func resumeRegistration()
    /// Unregisters this install's FID from FCM. Not enough on its own to stop pushes for
    /// good: the FID survives, and auto-init registers it again at the next launch.
    func unregisterFromFirebase() async throws
    /// Deletes this install's Firebase installation, so its FID stops working for good,
    /// including any TBA registration still pointing at it. Needs no TBA auth, which is
    /// what lets sign-out finish when TBA can't be told.
    func deleteFirebaseInstallation() async throws
}

// PushService registers this install's FID with Firebase and TBA, and handles APNS messages.
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject, PushServiceProtocol {

    private let reporter: any Reporter
    private let authService: any AuthServiceProtocol
    private let myTBA: any MyTBAProtocol
    private let registrar: any RemoteNotificationRegistering
    private let firebase: any FirebasePushRegistering
    weak var router: (any PushNotificationRouting)?

    private(set) var registerTask: Task<Void, Never>?
    private var signInObservation: Task<Void, Never>?
    private var hasAPNSToken = false
    private var isRegistrationPaused = false

    /// This install's Firebase Installation ID, which FCM delivers its pushes to.
    private(set) var fid: String?

    init(
        reporter: any Reporter,
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        registrar: any RemoteNotificationRegistering,
        firebase: any FirebasePushRegistering = FirebasePushRegistrar()
    ) {
        self.reporter = reporter
        self.authService = authService
        self.myTBA = myTBA
        self.registrar = registrar
        self.firebase = firebase

        super.init()

        loadFID()
        observeSignIn()
    }

    isolated deinit {
        signInObservation?.cancel()
    }

    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?) {
        registrar.registerForRemoteNotifications(completion: completion)
    }

    /// Firebase can only register the FID once it has the APNs token, and it won't retry on
    /// its own when it already has a pre-FID token cached, as every upgraded install does.
    func didReceiveAPNSToken() {
        hasAPNSToken = true
        if authService.isSignedIn {
            registerWithFirebase()
        }
    }

}

extension PushService {

    @discardableResult
    func requestAuthorizationForNotifications() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    func pauseRegistration() async {
        isRegistrationPaused = true
        registerTask?.cancel()
        await registerTask?.value
    }

    func resumeRegistration() {
        isRegistrationPaused = false
        registerWithFirebase()
    }

    func unregisterFromFirebase() async throws {
        try await firebase.unregister()
    }

    func deleteFirebaseInstallation() async throws {
        try await firebase.deleteInstallation()
        fid = nil
    }

}

extension PushService {

    // Firebase keeps the FID in this device's keychain, so it's known at launch, before
    // Messaging reports its registration.
    private func loadFID() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let fid = try await firebase.installationID()
                if self.fid == nil {
                    self.fid = fid
                }
            } catch {
                reporter.record(error)
            }
        }
    }

    // Firebase re-reports the current state when it starts listening, so only a real change acts.
    private func observeSignIn() {
        let authService = authService
        signInObservation = Task { [weak self] in
            var wasSignedIn: Bool?
            for await isSignedIn in Observations({ authService.isSignedIn }) {
                guard let self else { return }
                guard isSignedIn != wasSignedIn else { continue }
                wasSignedIn = isSignedIn
                if isSignedIn {
                    isRegistrationPaused = false
                    registerWithFirebase()
                } else {
                    registerTask?.cancel()
                }
            }
        }
    }

    // Registering calls back `messaging(_:didReceiveRegistration:)`, even when the FID is
    // already registered, and that registers it with TBA. Without the APNs token it would
    // fail, so a sign-in restored at launch waits for `didReceiveAPNSToken()`.
    private func registerWithFirebase() {
        guard hasAPNSToken else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await firebase.register()
            } catch {
                reporter.record(error)
            }
        }
    }

    // Restarting an in-flight attempt is deliberate: a changed FID must win.
    private func registerWithTBA() {
        registerTask?.cancel()
        guard authService.isSignedIn, !isRegistrationPaused else {
            return
        }
        registerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                do {
                    _ = try await myTBA.register()
                    return
                } catch {
                    guard !Task.isCancelled else { return }
                    reporter.record(error)
                }
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }

}

extension PushService: MessagingDelegate {

    // Firebase delivers this on the main thread (-[FIRMessaging notifyDelegateOfFCMTokenAvailability]),
    // once per app start under auto-init and again after each `register()`.
    func messaging(_ messaging: Messaging, didReceiveRegistration installationId: String?) {
        didReceiveRegistration(installationId)
    }

    // Separate from the delegate method so tests don't need a `Messaging` instance.
    func didReceiveRegistration(_ fid: String?) {
        // Firebase also reports nil when an unregister finishes, even one that failed
        guard let fid else { return }
        self.fid = fid
        registerWithTBA()
    }

}

extension PushService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let payload = PushNotificationPayload.parse(notification.request.content.userInfo)
        if case .silentRefresh = payload {
            completionHandler([])
            return
        }
        completionHandler([.banner, .list, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let payload = PushNotificationPayload.parse(userInfo) else {
            completionHandler()
            return
        }
        router?.handleTap(payload)
        completionHandler()
    }

}
