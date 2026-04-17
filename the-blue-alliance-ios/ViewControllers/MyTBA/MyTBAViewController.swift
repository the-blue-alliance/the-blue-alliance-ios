import FirebaseAuth
import GoogleSignIn
import MyTBAKit
import Photos
import PureLayout
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController {


    private(set) var signInViewController: MyTBASignInViewController = MyTBASignInViewController()
    private(set) var favoritesViewController: MyTBAFavoritesViewController
    private(set) var subscriptionsViewController: MyTBASubscriptionsViewController

    private var signInView: UIView! {
        return signInViewController.view
    }
    private lazy var signOutBarButtonItem = UIBarButtonItem(title: "Sign Out", primaryAction: UIAction { [weak self] _ in
        self?.confirmLogout()
    })
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

    init(dependencies: Dependencies) {

        favoritesViewController = MyTBAFavoritesViewController(dependencies: dependencies)
        subscriptionsViewController = MyTBASubscriptionsViewController(dependencies: dependencies)

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

    private func confirmLogout() {
        let signOutAlertController = UIAlertController(title: "Log Out?", message: "Are you sure you want to sign out of myTBA?", preferredStyle: .alert)
        signOutAlertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { [weak self] _ in
            self?.logout()
        }))
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(signOutAlertController, animated: true)
    }

}

extension MyTBAViewController: MyTBATableViewControllerDelegate {

    func eventSelected(eventKey: String) {
        let viewController = EventViewController(eventKey: eventKey, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func teamSelected(teamKey: String) {
        let viewController = TeamViewController(teamKey: teamKey, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func matchSelected(matchKey: String) {
        let viewController = MatchViewController(matchKey: matchKey, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
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
         showErrorAlert(with: "Error signing in to Google - \(error.localizedDescription)")
    }

    func pushRegistrationError(error: Error) {
        showErrorAlert(with: "Error registering for push notifications - \(error.localizedDescription)")
    }

}
