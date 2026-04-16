import FirebaseAuth
import GoogleSignIn
import MyTBAKit
import Photos
import PureLayout
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var signInViewController: MyTBASignInViewController = MyTBASignInViewController()
    private(set) var favoritesViewController: MyTBAFavoritesViewController
    private(set) var subscriptionsViewController: MyTBASubscriptionsViewController

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

    init(myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        favoritesViewController = MyTBAFavoritesViewController(myTBA: myTBA, favoritesStore: myTBAStores.favorites, dependencies: dependencies)
        subscriptionsViewController = MyTBASubscriptionsViewController(myTBA: myTBA, subscriptionsStore: myTBAStores.subscriptions, dependencies: dependencies)

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
        isLoggingOut = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.isLoggingOut = false }
            do {
                _ = try await self.myTBA.unregister()
                self.logoutSuccessful()
            } catch let error as MyTBAError where error.code == 404 {
                self.logoutSuccessful()
            } catch {
                self.errorRecorder.record(error)
                self.showErrorAlert(with: "Unable to sign out of myTBA - \(error.localizedDescription)")
            }
        }
    }

    private func logoutSuccessful() {
        GIDSignIn.sharedInstance.signOut()
        try! Auth.auth().signOut()

        for vc in [favoritesViewController, subscriptionsViewController] as [Refreshable] {
            vc.cancelRefresh()
        }

        removeMyTBAData()
    }

    func removeMyTBAData() {
        myTBAStores.favorites.clear()
        myTBAStores.subscriptions.clear()
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

    func eventSelected(eventKey: String) {
        let viewController = EventViewController(eventKey: eventKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        pushOrShowDetail(viewController)
    }

    func teamSelected(teamKey: String) {
        let viewController = TeamViewController(teamKey: teamKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        pushOrShowDetail(viewController)
    }

    func matchSelected(matchKey: String) {
        let viewController = MatchViewController(matchKey: matchKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        pushOrShowDetail(viewController)
    }

    private func pushOrShowDetail(_ viewController: UIViewController) {
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
