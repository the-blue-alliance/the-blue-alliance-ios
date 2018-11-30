import CoreData
import Crashlytics
import FirebaseAuth
import FirebaseRemoteConfig
import FirebaseMessaging
import GoogleSignIn
import PureLayout
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController, GIDSignInUIDelegate {

    private let messaging: Messaging
    private let myTBA: MyTBA
    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener

    private(set) var signInViewController: MyTBASignInViewController = MyTBASignInViewController()
    private(set) var favoritesViewController: MyTBATableViewController<Favorite, MyTBAFavorite>
    private(set) var subscriptionsViewController: MyTBATableViewController<Subscription, MyTBASubscription>

    private var signInView: UIView! {
        return signInViewController.view
    }
    private lazy var signOutBarButtonItem: UIBarButtonItem = {
         return UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(logoutTapped))
    }()
    private var signOutActivityIndicatorBarButtonItem: UIBarButtonItem = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }()

    var isLoggingOut: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    private var isLoggedIn: Bool {
        return myTBA.isAuthenticated
    }

    init(messaging: Messaging, myTBA: MyTBA, remoteConfig: RemoteConfig, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.messaging = messaging
        self.myTBA = myTBA
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener

        favoritesViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        subscriptionsViewController = MyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [favoritesViewController, subscriptionsViewController],
                   segmentedControlTitles: ["Favorites", "Subscriptions"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "myTBA"
        tabBarItem.image = UIImage(named: "ic_star")

        favoritesViewController.delegate = self
        subscriptionsViewController.delegate = self

        GIDSignIn.sharedInstance().uiDelegate = self
        myTBA.authenticationProvider.add(observer: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Fix the white status bar/white UINavigationController during sign in
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/180
        // modalPresentationCapturesStatusBarAppearance = true

        styleInterface()
    }

    // MARK: - Private Methods

    private func styleInterface() {
        view.addSubview(signInView)
        for edge in [ALEdge.top, ALEdge.bottom] {
            signInView.autoPinEdge(toSuperviewSafeArea: edge)
        }
        for edge in [ALEdge.leading, ALEdge.trailing] {
            signInView.autoPinEdge(toSuperviewEdge: edge)
        }

        updateInterface()
    }

    private func updateInterface() {
        if isLoggingOut {
            navigationItem.rightBarButtonItem = signOutActivityIndicatorBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = isLoggedIn ? signOutBarButtonItem : nil
        }

        // Disable interaction with our view while logging out
        view.isUserInteractionEnabled = !isLoggingOut

        signInView.isHidden = isLoggedIn
    }

    private func logout() {
        guard let fcmToken = messaging.fcmToken else {
            // No FCM token to unregister
            return
        }

        let signOutOperation = MyTBASignOutOperation(myTBA: myTBA, pushToken: fcmToken)
        signOutOperation.completionBlock = { [unowned signOutOperation] in
            self.isLoggingOut = false

            if let error = signOutOperation.completionError {
                Crashlytics.sharedInstance().recordError(error)
                self.showErrorAlert(with: "Unable to sign out of myTBA - \(error.localizedDescription)")
            } else {
                self.logoutSuccessful()
            }
        }
        isLoggingOut = true
        OperationQueue.main.addOperation(signOutOperation)
    }

    private func logoutSuccessful() {
        GIDSignIn.sharedInstance().signOut()
        try! Auth.auth().signOut()

        // Cancel any ongoing requests
        for vc in [favoritesViewController, subscriptionsViewController] as! [Refreshable] {
            vc.cancelRefresh()
        }

        // Remove all locally stored myTBA data
        removeMyTBAData()
    }

    func removeMyTBAData() {
        persistentContainer.viewContext.deleteAllObjectsForEntity(entity: Favorite.entity())
        persistentContainer.viewContext.deleteAllObjectsForEntity(entity: Subscription.entity())

        // Clear notifications
        persistentContainer.viewContext.performSaveOrRollback()
    }

    // MARK: - Interface Methods

    @objc func logoutTapped() {
        let signOutAlertController = UIAlertController(title: "Log Out?", message: "Are you sure you want to sign out of myTBA?", preferredStyle: .alert)
        signOutAlertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (_) in
            self.logout()
        }))
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(signOutAlertController, animated: true, completion: nil)
    }

}

extension MyTBAViewController: MyTBATableViewControllerDelegate {

    func myTBAObjectSelected(_ myTBAObject: MyTBAEntity) {
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/177
        var viewController: UIViewController?

        switch myTBAObject.modelType {
        case .event:
            if let event = myTBAObject.tbaObject as? Event {
                viewController = EventViewController(event: event, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
            } else {
                // TODO: Push using just key
            }
        case .team:
            if let team = myTBAObject.tbaObject as? Team {
                viewController = TeamViewController(team: team, remoteConfig: remoteConfig, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
            } else {
                // TODO: Push using just key
            }
        case .match:
            if let match = myTBAObject.tbaObject as? Match {
                viewController = MatchViewController(match: match, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
            } else {
                // TODO: Push using just key
            }
        }

        guard let vc = viewController else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension MyTBAViewController: MyTBAAuthenticationObservable {

    @objc func authenticated() {
        if let viewController = currentViewController() {
            viewController.refresh()
        }
        updateInterfaceMain()
    }

    @objc func unauthenticated() {
        updateInterfaceMain()
    }

    func updateInterfaceMain() {
        DispatchQueue.main.async { [weak self] in
            self?.updateInterface()
        }
    }

}
