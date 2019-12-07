import CoreData
import Crashlytics
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import MyTBAKit
import PureLayout
import TBAData
import TBAKit
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let statusService: StatusService
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
    private var signOutActivityIndicatorBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()

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

    init(myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        favoritesViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        subscriptionsViewController = MyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [favoritesViewController, subscriptionsViewController],
                   segmentedControlTitles: ["Favorites", "Subscriptions"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "myTBA"
        tabBarItem.image = UIImage.starIcon

        favoritesViewController.delegate = self
        subscriptionsViewController.delegate = self

        GIDSignIn.sharedInstance()?.presentingViewController = self
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("mytba", parameters: nil)
    }

    // MARK: - Private Methods

    private func styleInterface() {
        addChild(signInViewController)

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
            rightBarButtonItems = [signOutActivityIndicatorBarButtonItem]
        } else {
            rightBarButtonItems = isLoggedIn ? [signOutBarButtonItem] : []
        }

        // Disable interaction with our view while logging out
        view.isUserInteractionEnabled = !isLoggingOut

        signInView.isHidden = isLoggedIn
    }

    private func logout() {
        let signOutOperation = myTBA.unregister { [weak self] (_, error) in
            self?.isLoggingOut = false

            if let error = error as? MyTBAError, error.code != 404 {
                Crashlytics.sharedInstance().recordError(error)
                self?.showErrorAlert(with: "Unable to sign out of myTBA - \(error.localizedDescription)")
            } else {
                // Run on main thread, since we delete our Core Data objects on the main thread.
                DispatchQueue.main.async {
                    self?.logoutSuccessful()
                }
            }
        }
        guard let op = signOutOperation else { return }

        isLoggingOut = true
        OperationQueue.main.addOperation(op)
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
        persistentContainer.viewContext.performSaveOrRollback(errorRecorder: Crashlytics.sharedInstance())
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

    func eventSelected(_ event: Event) {
        let viewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController?.showDetailViewController(navigationController, sender: nil)
    }

    func teamSelected(_ team: Team) {
        let viewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController?.showDetailViewController(navigationController, sender: nil)
    }

    func matchSelected(_ match: Match) {
        let viewController = MatchViewController(match: match, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController?.showDetailViewController(navigationController, sender: nil)
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
