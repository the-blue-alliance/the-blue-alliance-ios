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
    /// This install's Firebase Installation ID, which FCM delivers its pushes to.
    var fid: String? { get }
    /// Whether FCM has confirmed it delivers to `fid`. TBA can't have the FID before then:
    /// registering it deletes the install's old FCM token, which may be the only way pushes
    /// still reach it.
    var isRegisteredWithFirebase: Bool { get }
    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?)
    @discardableResult func requestAuthorizationForNotifications() async throws -> Bool
    /// Registers this install's FID with TBA. Every registration goes through here, so
    /// pausing covers them all.
    func registerWithTBA() async throws -> MyTBABaseResponse
    /// Refuses new registrations with TBA and waits out the ones already asked for, so none
    /// can re-add the device after sign-out removes it. Also reads the FID again if that
    /// failed at launch, since sign-out names it to TBA. Signing in again resumes registration.
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
    /// The last /register request sent to TBA. Each waits for the one before it, so awaiting
    /// this waits them all out.
    private var lastTBARegistration: Task<MyTBABaseResponse, any Error>?
    private var signInObservation: Task<Void, Never>?
    private var hasAPNSToken = false
    private var isRegistrationPaused = false

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

    /// Firebase can't register the FID without the APNs token, and has to be asked: on its
    /// own it neither registers an install with a pre-FID token cached, as every upgrade has,
    /// nor reports a FID it registered at an earlier launch.
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
                // The callback comes without the FID when Firebase already had it registered
                // but hasn't loaded it yet this launch (firebase-ios-sdk 12.18.0).
                if !isRegisteredWithFirebase, let fid {
                    didReceiveRegistration(fid)
                }
            } catch {
                reporter.record(error)
            }
        }
    }

    // Retries every minute until TBA has the FID. A new FID restarts it.
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
    // after each `register()` and whenever it registers a FID on its own.
    func messaging(_ messaging: Messaging, didReceiveRegistration installationId: String?) {
        didReceiveRegistration(installationId)
    }

    // Separate from the delegate method so tests don't need a `Messaging` instance.
    func didReceiveRegistration(_ fid: String?) {
        // Firebase can report no FID for one it has registered. `registerWithFirebase()`
        // covers that.
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
