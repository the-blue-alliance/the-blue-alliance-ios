import CoreData
import FirebaseAuth
import GoogleSignIn
import MyTBAKit
import Photos
import PureLayout
import TBAData
import TBAKit
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
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

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        favoritesViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, dependencies: dependencies)
        subscriptionsViewController = MyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, dependencies: dependencies)

        super.init(viewControllers: [favoritesViewController, subscriptionsViewController],
                   segmentedControlTitles: ["Favorites", "Subscriptions"],
                   dependencies: dependencies)

        title = RootType.myTBA.title
        tabBarItem.image = RootType.myTBA.icon

        favoritesViewController.delegate = self
        subscriptionsViewController.delegate = self

        signInViewController.delegate = self
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

        myTBA.authenticationProvider.add(observer: self)
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
                self?.errorRecorder.record(error)
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
        GIDSignIn.sharedInstance.signOut()
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
        persistentContainer.viewContext.performSaveOrRollback(errorRecorder: errorRecorder)
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
        let viewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func teamSelected(_ team: Team) {
        let viewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func matchSelected(_ match: Match) {
        let viewController = MatchViewController(match: match, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
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

extension MyTBAViewController: SignInViewControllerDelegate {

    func signInError(error: Error) {
         errorRecorder.record(error)
         showErrorAlert(with: "Error signing in to Google - \(error.localizedDescription)")
    }

    func pushRegistrationError(error: Error) {
        errorRecorder.record(error)
    }

}
