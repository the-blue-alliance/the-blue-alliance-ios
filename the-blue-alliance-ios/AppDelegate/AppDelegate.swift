import FirebaseAnalytics
import FirebaseAuth
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import MyTBAKit
import TBAAPI
import TBAUtils
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Owned services

    private let errorRecorder = TBAErrorRecorder()
    let favoritesStore = FavoritesStore()
    let subscriptionsStore = SubscriptionsStore()
    let urlOpener: URLOpener = UIApplication.shared
    let idTokenProvider = FirebaseIDTokenProvider()

    let appSettings = AppSettings()

    // Set in `application(_:didFinishLaunchingWithOptions:)` once `Secrets` are loaded.
    var api: TBAAPI!

    lazy var messaging: Messaging = .messaging()
    lazy var myTBAStores: MyTBAStores = MyTBAStores(
        favorites: favoritesStore,
        subscriptions: subscriptionsStore
    )
    lazy var myTBA: any MyTBAProtocol = MyTBA(
        uuid: UIDevice.current.identifierForVendor!.uuidString,
        deviceName: UIDevice.current.name,
        fcmTokenProvider: messaging,
        idTokenProvider: idTokenProvider
    )
    lazy var pushService: PushService = PushService(
        errorRecorder: errorRecorder,
        myTBA: myTBA,
        retryService: RetryService(),
        registrar: self
    )
    lazy var statusService: any StatusServiceProtocol = StatusService(
        errorRecorder: errorRecorder,
        api: api,
        retryService: RetryService()
    )

    lazy var dependencies = Dependencies(
        api: api,
        appSettings: appSettings,
        myTBA: myTBA,
        myTBAStores: myTBAStores,
        statusService: statusService,
        urlOpener: urlOpener
    )

    // MARK: - AppServicesProviding state

    var pendingAlerts: [PendingAlert] = []

    // MARK: - Push registration callback

    // Holds the completion passed to `registerForRemoteNotifications` until
    // APNS calls back into one of our `application(_:didRegister...)` methods.
    var registerForRemoteNotificationsCompletion: ((Error?) -> ())?

    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        runLegacyCleanup()
        Self.setupAppearance()

        configureFirebase()
        configureAPI()
        configurePushNotifications()
        configureAuth()
        configureStatusService()

        return true
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        registerForRemoteNotificationsCompletion?(error)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        registerForRemoteNotificationsCompletion?(nil)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("Remote notification: \(userInfo)")
        completionHandler(.noData)
    }

}

// MARK: - Launch setup

private extension AppDelegate {

    func runLegacyCleanup() {
        LegacyCoreDataCleanup.run()
        // Old Refreshable cache key, no longer used.
        UserDefaults.standard.removeObject(forKey: "successful_refresh_keys")
    }

    func configureFirebase() {
        FirebaseApp.configure()
        #if DEBUG
            Analytics.setAnalyticsCollectionEnabled(false)
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
            Analytics.setAnalyticsCollectionEnabled(appSettings.firebaseCollection.analyticsEnabled)
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(
                appSettings.firebaseCollection.crashlyticsEnabled
            )
        #endif
    }

    func configureAPI() {
        let secrets = Secrets()
        api = TBAAPI(apiKey: secrets.tbaAPIKey, cachePolicy: appSettings.cachePolicy.current)
    }

    func configurePushNotifications() {
        messaging.delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        // PushService self-subscribes to myTBA auth-state changes in its init.
        // Best-effort registration; failures will surface later.
        pushService.registerForRemoteNotifications(nil)
    }

    func configureAuth() {
        // Coarse-grained auth state — fires on sign-in / sign-out only.
        // The actual ID token is fetched per-request via `FirebaseIDTokenProvider`,
        // so we no longer listen for (or care about) token refreshes here.
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { [myTBA = self.myTBA] in
                await myTBA.notifyAuthStateChanged(isAuthenticated: user != nil)
            }
        }
        restorePreviousSignIn()
    }

    func configureStatusService() {
        registerForFMSStatusChanges()
        registerForStatusChanges()
        statusService.registerRetryable(initiallyRetry: true)
    }

    func restorePreviousSignIn() {
        guard Auth.auth().currentUser == nil, GIDSignIn.sharedInstance.hasPreviousSignIn() else {
            return
        }
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            if let error = error {
                errorRecorder.record(error)
                return
            }

            AuthHelper.signInToGoogle(user: user) { [unowned self] success, error in
                if let error = error {
                    errorRecorder.record(error)
                }
                guard success else { return }
                PushService.requestAuthorizationForNotifications { [unowned self] _, error in
                    if let error = error {
                        errorRecorder.record(error)
                    }
                }
            }
        }
    }

}

// MARK: - Minimum app version

extension AppDelegate {

    static func isAppVersionSupported(minimumAppVersion: Int) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("-testUnsupportedVersion") {
            return true
        }
        return Bundle.main.buildVersionNumber >= minimumAppVersion
    }

}

// MARK: - Status subscriptions

extension AppDelegate: StatusSubscribable {

    func statusChanged(status: AppStatus) {
        if !Self.isAppVersionSupported(minimumAppVersion: status.minAppVersion) {
            showAlert(.minVersion(currentAppVersion: statusService.status.latestAppVersion))
        }
    }

}

extension AppDelegate: FMSStatusSubscribable {

    func fmsStatusChanged(isDatafeedDown: Bool) {
        if isDatafeedDown {
            showAlert(.fmsStatus(isDatafeedDown: isDatafeedDown))
        }
    }

}

// MARK: - AppServicesProviding

extension AppDelegate: AppServicesProviding {

    var fcmTokenProvider: any FCMTokenProvider { messaging }

}

private extension AppDelegate {

    func showAlert(_ alert: PendingAlert) {
        let presenter = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.delegate as? SceneAlertPresenting }
            .first
        if let presenter {
            presenter.present(alert)
        } else {
            pendingAlerts.append(alert)
        }
    }

}

// MARK: - Remote notification registration

extension AppDelegate: RemoteNotificationRegistering {

    func registerForRemoteNotifications(completion: ((Error?) -> Void)?) {
        registerForRemoteNotificationsCompletion = completion
        UIApplication.shared.registerForRemoteNotifications()
    }

}

// MARK: - FCMTokenProvider conformance for Firebase Messaging

// `@unchecked Sendable` because `Messaging` is Firebase-controlled; per their
// docs the instance is safe to access from any thread.
extension Messaging: @retroactive @unchecked Sendable {}
extension Messaging: @retroactive FCMTokenProvider {}

// MARK: - IDTokenProvider

// Wraps Firebase Auth's `currentUser.getIDToken(completion:)`, which returns
// a cached token if it's still fresh and silently refreshes if it's expired.
// Called on every myTBA request, so stale tokens never pile up.
//
// Structurally Sendable — no stored state, just forwards to Firebase Auth
// (which is documented thread-safe for reads).
final class FirebaseIDTokenProvider: IDTokenProvider {

    var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    func idToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw MyTBAError.error(401, "Not signed in")
        }
        return try await withCheckedThrowingContinuation { continuation in
            user.getIDToken { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(
                        throwing: MyTBAError.error(401, "Firebase returned no ID token")
                    )
                }
            }
        }
    }
}

// MARK: - Appearance

extension AppDelegate {

    static func setupAppearance() {
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = UIColor.navigationBarTintColor
            navigationBarAppearance.shadowColor = nil
            navigationBarAppearance.shadowImage = UIImage()
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.navigationBarTintColor
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.selectionIndicatorTintColor = UIColor.tabBarTintColor

            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.isTranslucent = false
        tabBarAppearance.tintColor = UIColor.tabBarTintColor

        let segmentedControlAppearance = UISegmentedControl.appearance()
        segmentedControlAppearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
        segmentedControlAppearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.segmentedControlSelectedColor],
            for: .selected
        )
    }

}

// MARK: - Error recorder

private class TBAErrorRecorder: ErrorRecorder {

    func record(_ error: Error) {
        #if DEBUG
            print(error)
        #else
            Crashlytics.crashlytics().record(error: error)
        #endif
    }

}
