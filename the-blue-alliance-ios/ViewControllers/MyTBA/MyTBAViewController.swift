import MyTBAKit
import Observation
import Photos
import PureLayout
import TBAAPI
import UIKit
import UserNotifications
import TBAAuth
import TBAUtils

class MyTBAViewController: ContainerViewController {

    private(set) var signInViewController: MyTBASignInViewController
    private(set) var favoritesViewController: MyTBAFavoritesViewController
    private(set) var subscriptionsViewController: MyTBASubscriptionsViewController

    private var signInView: UIView! {
        return signInViewController.view
    }
    private lazy var signOutBarButtonItem = UIBarButtonItem(
        title: "Sign Out",
        primaryAction: UIAction { [weak self] _ in
            self?.confirmLogout()
        }
    )
    private var signOutActivityIndicatorBarButtonItem =
        UIBarButtonItem.activityIndicatorBarButtonItem()
    private var signInObservation: Task<Void, Never>?

    var isLoggingOut: Bool = false {
        didSet {
            setNeedsUpdateProperties()
        }
    }
    private var isLoggedIn: Bool {
        return dependencies.authService.isSignedIn
    }

    init(dependencies: Dependencies) {

        signInViewController = MyTBASignInViewController(dependencies: dependencies)
        favoritesViewController = MyTBAFavoritesViewController(dependencies: dependencies)
        subscriptionsViewController = MyTBASubscriptionsViewController(dependencies: dependencies)

        super.init(
            viewControllers: [favoritesViewController, subscriptionsViewController],
            segmentedControlTitles: ["Favorites", "Subscriptions"],
            dependencies: dependencies
        )

        title = RootType.myTBA.title
        tabBarItem.image = RootType.myTBA.icon

        favoritesViewController.delegate = self
        subscriptionsViewController.delegate = self

        signInViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    isolated deinit {
        signInObservation?.cancel()
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()

        observeSignIn()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("MyTBA")
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
        signInViewController.didMove(toParent: self)
    }

    override var currentRightBarButtonItems: [UIBarButtonItem] {
        if isLoggingOut {
            return [signOutActivityIndicatorBarButtonItem]
        }
        return isLoggedIn ? [signOutBarButtonItem] : []
    }

    override func updateProperties() {
        super.updateProperties()

        // Disable interaction with our view while logging out
        view.isUserInteractionEnabled = !isLoggingOut

        signInView.isHidden = isLoggedIn
    }

    // The rest of the screen follows `isSignedIn` through `updateProperties()`; this refreshes the
    // current tab when someone signs in.
    private func observeSignIn() {
        let authService = dependencies.authService
        signInObservation = Task { [weak self] in
            var wasSignedIn = authService.isSignedIn
            for await isSignedIn in Observations({ authService.isSignedIn }) {
                guard let self else { return }
                if isSignedIn, !wasSignedIn {
                    currentViewController()?.refresh()
                }
                wasSignedIn = isSignedIn
            }
        }
    }

    private func logout() {
        isLoggingOut = true
        Task {
            defer { isLoggingOut = false }
            for vc in [favoritesViewController, subscriptionsViewController] as [any Refreshable] {
                vc.cancelRefresh()
            }
            do {
                try await dependencies.myTBASession.signOut()
            } catch {
                showErrorAlert(
                    with: "Unable to sign out of myTBA - \(error.localizedDescription)"
                )
            }
        }
    }

    // MARK: - Interface Methods

    private func confirmLogout() {
        let signOutAlertController = UIAlertController(
            title: "Log Out?",
            message: "Are you sure you want to sign out of myTBA?",
            preferredStyle: .alert
        )
        signOutAlertController.addAction(
            UIAlertAction(
                title: "Log Out",
                style: .default,
                handler: { [weak self] _ in
                    self?.logout()
                }
            )
        )
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(signOutAlertController, animated: true)
    }

}

extension MyTBAViewController: MyTBATableViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let viewController = EventViewController(event: event, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func teamSelected(_ team: Team) {
        let viewController = TeamViewController(team: team, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func eventSelected(eventKey: EventKey) {
        let viewController = EventViewController(eventKey: eventKey, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func teamSelected(teamKey: TeamKey) {
        let viewController = TeamViewController(teamKey: teamKey, dependencies: dependencies)
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension MyTBAViewController: SignInViewControllerDelegate {

    func signInViewController(
        _ controller: MyTBASignInViewController,
        didFailWith error: any Error
    ) {
        if case MyTBASessionError.pushAuthorization = error {
            showErrorAlert(
                with: "Error registering for push notifications - \(error.localizedDescription)"
            )
        } else {
            showErrorAlert(with: "Error signing in to myTBA - \(error.localizedDescription)")
        }
    }

}
