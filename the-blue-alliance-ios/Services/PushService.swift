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
    func deleteInstallation() async throws
}

final class FirebasePushRegistrar: FirebasePushRegistering {

    func installationID() async throws -> String {
        try await Installations.installations().installationID()
    }

    func register() async throws {
        try await Messaging.messaging().register()
    }

    func deleteInstallation() async throws {
        try await Installations.installations().delete()
    }

}

enum PushServiceError: LocalizedError {
    case registrationPaused
    case notRegisteredWithFirebase

    var errorDescription: String? {
        switch self {
        case .registrationPaused:
            return "Signing out of myTBA."
        case .notRegisteredWithFirebase:
            return "Firebase hasn't registered this device for notifications yet."
        }
    }
}

protocol PushServiceProtocol: AnyObject {
    /// Whether FCM has confirmed it delivers to this install's FID. TBA can't have the FID
    /// before then: registering it deletes the install's old FCM token, which may be the
    /// only way pushes still reach it.
    var isRegisteredWithFirebase: Bool { get }
    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?)
    @discardableResult func requestAuthorizationForNotifications() async throws -> Bool
    /// Registers this install's FID with TBA. Every registration goes through here, so
    /// pausing covers them all.
    func registerWithTBA() async throws -> MyTBABaseResponse
    /// Stops registering with TBA and waits out any request already sent, so none can re-add
    /// the device after sign-out removes it. Also reads the FID again if that failed at
    /// launch, since sign-out names it to TBA. Signing in again resumes registration.
    func pauseRegistration() async
    /// Picks registration back up, after signing in or a sign-out that didn't go through.
    func resumeRegistration()
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
    /// The last /register request sent to TBA. Each waits for the one before it, so a newer
    /// FID lands last, and awaiting this waits them all out.
    private var lastTBARegistration: Task<MyTBABaseResponse, any Error>?
    private var signInObservation: Task<Void, Never>?
    private var hasAPNSToken = false
    private var isRegistrationPaused = false

    /// This install's Firebase Installation ID, which FCM delivers its pushes to.
    private(set) var fid: String?
    private(set) var isRegisteredWithFirebase = false

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

        Task { [weak self] in await self?.loadFID() }
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

    func registerWithTBA() async throws -> MyTBABaseResponse {
        guard !isRegistrationPaused else {
            throw PushServiceError.registrationPaused
        }
        guard isRegisteredWithFirebase else {
            throw PushServiceError.notRegisteredWithFirebase
        }
        // Its own task, so cancelling the caller doesn't cancel it: TBA may already be
        // handling the request, and pausing has to wait for it to land.
        let previous = lastTBARegistration
        let registration = Task {
            _ = try? await previous?.value
            // Pausing waits out a request already sent, not one still queued behind it.
            guard !isRegistrationPaused else {
                throw PushServiceError.registrationPaused
            }
            return try await myTBA.register()
        }
        lastTBARegistration = registration
        return try await registration.value
    }

    func pauseRegistration() async {
        isRegistrationPaused = true
        registerTask?.cancel()
        _ = try? await lastTBARegistration?.value
        if fid == nil {
            await loadFID()
        }
    }

    func resumeRegistration() {
        isRegistrationPaused = false
        if isRegisteredWithFirebase {
            keepRegisteringWithTBA()
        } else {
            registerWithFirebase()
        }
    }

    func deleteFirebaseInstallation() async throws {
        try await firebase.deleteInstallation()
        fid = nil
        isRegisteredWithFirebase = false
    }

}

extension PushService {

    // Firebase keeps the FID in this device's keychain, so it's known at launch, before
    // Messaging reports its registration.
    private func loadFID() async {
        do {
            let fid = try await firebase.installationID()
            if self.fid == nil {
                self.fid = fid
            }
        } catch {
            reporter.record(error)
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
                    resumeRegistration()
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

    // Retries every minute until TBA has the FID. A new FID restarts it, and its request
    // waits for the old one's, so the new FID lands last.
    private func keepRegisteringWithTBA() {
        registerTask?.cancel()
        guard authService.isSignedIn, !isRegistrationPaused else {
            return
        }
        registerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                do {
                    _ = try await registerWithTBA()
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
        // Firebase reports nil when unregistering, which this app doesn't do.
        guard let fid else { return }
        self.fid = fid
        isRegisteredWithFirebase = true
        keepRegisteringWithTBA()
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
