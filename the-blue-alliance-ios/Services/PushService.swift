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

/// The FCM registration calls PushService makes, so tests can stand in for Firebase.
protocol FirebaseMessagingRegistering: AnyObject {
    func register() async throws
    func unregister() async throws
}

final class FirebaseMessagingRegistrar: FirebaseMessagingRegistering {

    func register() async throws {
        try await Messaging.messaging().register()
    }

    func unregister() async throws {
        try await Messaging.messaging().unregister()
    }

}

protocol PushServiceProtocol: AnyObject {
    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?)
    @discardableResult func requestAuthorizationForNotifications() async throws -> Bool
    /// Unregisters this device's FID from FCM so pushes to it fail at Firebase.
    /// Needs no TBA auth, which is what makes sign-out safe to finish offline.
    func unregisterFromFirebase() async throws
}

// PushService handles registering this device's FID with Firebase and TBA, and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject, PushServiceProtocol {

    private static let registeredFIDKey = "kRegisteredFID"

    private let reporter: any Reporter
    private let authService: any AuthServiceProtocol
    private let myTBA: any MyTBAProtocol
    private let registrar: any RemoteNotificationRegistering
    private let firebaseMessaging: any FirebaseMessagingRegistering
    private let defaults: UserDefaults
    weak var router: (any PushNotificationRouting)?

    private(set) var registerTask: Task<Void, Never>?
    private var signInObservation: Task<Void, Never>?

    /// The Firebase Installation ID FCM delivers this device's pushes to. Firebase only
    /// reports it to the Messaging delegate, so it's kept from the last launch until
    /// that callback arrives.
    private(set) var registeredFID: String? {
        didSet { defaults.set(registeredFID, forKey: Self.registeredFIDKey) }
    }

    init(
        reporter: any Reporter,
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        registrar: any RemoteNotificationRegistering,
        firebaseMessaging: any FirebaseMessagingRegistering = FirebaseMessagingRegistrar(),
        defaults: UserDefaults = .standard
    ) {
        self.reporter = reporter
        self.authService = authService
        self.myTBA = myTBA
        self.registrar = registrar
        self.firebaseMessaging = firebaseMessaging
        self.defaults = defaults
        self.registeredFID = defaults.string(forKey: Self.registeredFIDKey)

        super.init()

        observeSignIn()
    }

    isolated deinit {
        signInObservation?.cancel()
    }

    // Both triggers (auth state, FCM registration) land here and either can come first.
    // Restarting an in-flight attempt is deliberate: a changed FID must win.
    fileprivate func registerWithTBA() {
        registerTask?.cancel()
        guard authService.isSignedIn else {
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

    func registerForRemoteNotifications(_ completion: (((any Error)?) -> Void)?) {
        registrar.registerForRemoteNotifications(completion: completion)
    }

}

extension PushService {

    @discardableResult
    func requestAuthorizationForNotifications() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    func unregisterFromFirebase() async throws {
        // Firebase looks up the FID itself, so this works even before the delegate
        // has reported it this launch.
        try await firebaseMessaging.unregister()
        registeredFID = nil
    }

}

extension PushService {

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
                    registerWithFirebase()
                    registerWithTBA()
                } else {
                    registerTask?.cancel()
                }
            }
        }
    }

    // Sign-out unregisters the FID from FCM, and auto-init only registers it again on
    // the next launch. Registering calls back `messaging(_:didReceiveRegistration:)`,
    // even when the FID is already registered.
    private func registerWithFirebase() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await firebaseMessaging.register()
            } catch {
                reporter.record(error)
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
        registeredFID = fid
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
