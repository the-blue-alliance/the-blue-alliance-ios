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

    // MARK: - Window

    var window: UIWindow?

    // MARK: - Owned services

    private let errorRecorder = TBAErrorRecorder()
    let favoritesStore = FavoritesStore()
    let subscriptionsStore = SubscriptionsStore()
    let urlOpener: URLOpener = UIApplication.shared

    // Set in `application(_:didFinishLaunchingWithOptions:)` once `Secrets`
    // are loaded.
    var api: TBAAPI!

    lazy var messaging: Messaging = .messaging()
    lazy var myTBAStores: MyTBAStores = MyTBAStores(favorites: favoritesStore,
                                                    subscriptions: subscriptionsStore)
    lazy var myTBA: any MyTBAProtocol = MyTBA(uuid: UIDevice.current.identifierForVendor!.uuidString,
                                              deviceName: UIDevice.current.name,
                                              fcmTokenProvider: messaging)
    lazy var pushService: PushService = PushService(errorRecorder: errorRecorder,
                                                    myTBA: myTBA,
                                                    retryService: RetryService(),
                                                    registrar: self)
    lazy var statusService: any StatusServiceProtocol = StatusService(errorRecorder: errorRecorder,
                                                                      api: api,
                                                                      retryService: RetryService())

    // MARK: - View hierarchy

    private lazy var dependencies = Dependencies(api: api,
                                                 myTBA: myTBA,
                                                 myTBAStores: myTBAStores,
                                                 statusService: statusService,
                                                 urlOpener: urlOpener)

    private lazy var rootViewController = PhoneRootViewController(fcmTokenProvider: messaging,
                                                                  pushService: pushService,
                                                                  dependencies: dependencies)

    private var launchViewController: UIViewController {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return vc
    }

    // MARK: - Push registration callback

    // Holds the completion passed to `registerForRemoteNotifications` until
    // APNS calls back into one of our `application(_:didRegister...)` methods.
    var registerForRemoteNotificationsCompletion: ((Error?) -> ())?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        runLegacyCleanup()
        Self.setupAppearance()
        showLaunchScreen()

        configureFirebase()
        configureAPI()
        configurePushNotifications()
        configureAuth()
        configureStatusService()

        guard isMinimumAppVersionSupported else {
            showMinimumAppVersionAlert(currentAppVersion: statusService.status.latestAppVersion)
            return true
        }

        installRootViewController()
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        registerForRemoteNotificationsCompletion?(error)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerForRemoteNotificationsCompletion?(nil)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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

    func showLaunchScreen() {
        let window = UIWindow()
        self.window = window
        window.rootViewController = launchViewController
        window.makeKeyAndVisible()
    }

    func configureFirebase() {
        FirebaseApp.configure()
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }

    func configureAPI() {
        let secrets = Secrets()
        api = TBAAPI(apiKey: secrets.tbaAPIKey)
    }

    func configurePushNotifications() {
        messaging.delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        myTBA.authenticationProvider.add(observer: pushService)
        // Best-effort registration; failures will surface later.
        pushService.registerForRemoteNotifications(nil)
    }

    func configureAuth() {
        Auth.auth().addIDTokenDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if let user = user {
                user.getIDToken { token, _ in
                    self.myTBA.authToken = token
                }
            } else {
                self.myTBA.authToken = nil
            }
        }
        restorePreviousSignIn()
    }

    func configureStatusService() {
        registerForFMSStatusChanges()
        registerForStatusChanges()
        statusService.registerRetryable(initiallyRetry: true)
    }

    func installRootViewController() {
        guard let window = window,
              let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            fatalError("Unable to snapshot launch screen")
        }
        rootViewController.view.addSubview(snapshot)
        window.rootViewController = rootViewController

        // 0.35 is an iOS animation magic number... for now
        UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
            snapshot.layer.opacity = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
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

private extension AppDelegate {

    var isMinimumAppVersionSupported: Bool {
        Self.isAppVersionSupported(minimumAppVersion: statusService.status.minAppVersion)
    }

    static func isAppVersionSupported(minimumAppVersion: Int) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("-testUnsupportedVersion") {
            return true
        }
        return Bundle.main.buildVersionNumber >= minimumAppVersion
    }

    func showMinimumAppVersionAlert(currentAppVersion: Int) {
        guard let window = window else { return }
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Unsupported App Version",
                message: "Your version (\(currentAppVersion)) of The Blue Alliance for iOS is no longer supported - please visit the App Store to update to the latest version",
                preferredStyle: .alert
            )
            window.rootViewController?.present(alert, animated: true)
        }
    }

}

// MARK: - Status subscriptions

extension AppDelegate: StatusSubscribable {

    func statusChanged(status: AppStatus) {
        if !Self.isAppVersionSupported(minimumAppVersion: status.minAppVersion) {
            showMinimumAppVersionAlert(currentAppVersion: statusService.status.latestAppVersion)
        }
    }

}

extension AppDelegate: FMSStatusSubscribable {

    func fmsStatusChanged(isDatafeedDown: Bool) {
        guard isDatafeedDown else { return }

        let alert = UIAlertController(
            title: "FIRST's servers are down",
            message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are broken right now, so we can't get the latest updates. The information you see here may be out of date.",
            preferredStyle: .alert
        )
        window?.rootViewController?.present(alert, animated: true)
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

extension Messaging: FCMTokenProvider {}

// MARK: - Appearance

extension AppDelegate {

    static func setupAppearance() {
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
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
        segmentedControlAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControlAppearance.setTitleTextAttributes([.foregroundColor: UIColor.segmentedControlSelectedColor], for: .selected)
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
