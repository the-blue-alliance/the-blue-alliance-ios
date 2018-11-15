import CoreData
import Crashlytics
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import UIKit
import UserNotifications

class MyTBAViewController: ContainerViewController, GIDSignInUIDelegate {

    private let signInViewController: MyTBASignInViewController
    private let favoritesViewController: MyTBATableViewController<Favorite, MyTBAFavorite>
    private let subscriptionsViewController: MyTBATableViewController<Subscription, MyTBASubscription>

    @IBOutlet internal var signInView: UIView!
    @IBOutlet internal var signOutBarButtonItem: UIBarButtonItem!
    private var signOutActivityIndicatorBarButtonItem: UIBarButtonItem = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }()

    private var isLoggingOut: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    private var isLoggedIn: Bool {
        return MyTBA.shared.isAuthenticated
    }

    init(persistentContainer: NSPersistentContainer) {
        signInViewController = MyTBASignInViewController()

        favoritesViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(persistentContainer: persistentContainer)
        subscriptionsViewController = MyTBATableViewController<Subscription, MyTBASubscription>(persistentContainer: persistentContainer)

        super.init(viewControllers: [favoritesViewController, subscriptionsViewController],
                   segmentedControlTitles: ["Favorites", "Subscriptions"],
                   persistentContainer: persistentContainer)
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

        GIDSignIn.sharedInstance().uiDelegate = self
        MyTBA.shared.authenticationProvider.add(observer: self)

        styleInterface()
    }

    // MARK: - Private Methods

    private func styleInterface() {
        signInView.isHidden = isLoggedIn

        updateInterface()
    }

    private func updateInterface() {
        // Make sure observers don't setup our interface before our VC is initialized
        if view == nil {
            return
        }

        if isLoggingOut {
            navigationItem.rightBarButtonItem = signOutActivityIndicatorBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = isLoggedIn ? signOutBarButtonItem : nil
        }
        signInView.isHidden = isLoggedIn
    }

    private func logout() {
        guard let fcmToken = Messaging.messaging().fcmToken else {
            // No FCM token to unregister
            return
        }

        let signOutOperation = MyTBASignOutOperation(myTBA: MyTBA.shared, pushToken: fcmToken)
        signOutOperation.completionBlock = { [unowned signOutOperation] in
            self.isLoggingOut = false

            if let error = signOutOperation.completionError {
                Crashlytics.sharedInstance().recordError(error)
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

    private func removeMyTBAData() {
        persistentContainer.viewContext.deleteAllObjectsForEntity(entity: Favorite.entity())
        persistentContainer.viewContext.deleteAllObjectsForEntity(entity: Subscription.entity())

        // Clear notifications
        persistentContainer.viewContext.performSaveOrRollback()
    }

    private func pushMyTBAObject(_ myTBAObject: MyTBAEntity) {
        /*
        switch myTBAObject.modelType {
        case .event:
            performSegue(withIdentifier: EventSegue, sender: myTBAObject.modelKey!)
        case .team:
            performSegue(withIdentifier: TeamSegue, sender: myTBAObject.modelKey!)
        case .match:
            performSegue(withIdentifier: MatchSegue, sender: myTBAObject.modelKey!)
        }
        */
    }

    // MARK: - Interface Methods

    @IBAction func logoutTapped() {
        let signOutAlertController = UIAlertController(title: "Log Out?", message: "Are you sure you want to sign out of myTBA?", preferredStyle: .alert)
        signOutAlertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (_) in
            self.logout()
        }))
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(signOutAlertController, animated: true, completion: nil)
    }

    // MARK: - Navigation

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let key = sender as? String ?? ""
        let predicate = NSPredicate(format: "key == %@", key)

        if segue.identifier == EventSegue {
            let eventViewController = segue.destination as! EventViewController
            if let event = Event.findOrFetch(in: persistentContainer.viewContext, matching: predicate) {
                eventViewController.event = event
            }
            eventViewController.persistentContainer = persistentContainer
            // TODO: Handle passing a key
            // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/177
        } else if segue.identifier == TeamSegue {
            let teamViewController = segue.destination as! TeamViewController
            if let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: predicate) {
                teamViewController.team = team
            }
            teamViewController.persistentContainer = persistentContainer
            // TODO: Handle passing a key
        } else if segue.identifier == MatchSegue {
            let matchViewController = segue.destination as! MatchViewController
            if let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: predicate) {
                matchViewController.match = match
            }
            matchViewController.persistentContainer = persistentContainer
            // TODO: Handle passing a key
        }
    }
    */

}

extension MyTBAViewController: MyTBAAuthenticationObservable {

    func authenticated() {
        if let viewController = currentViewController() {
            viewController.refresh()
        }
        updateInterfaceMain()
    }

    func unauthenticated() {
        updateInterfaceMain()
    }

    func updateInterfaceMain() {
        DispatchQueue.main.async { [unowned self] in
            self.updateInterface()
        }
    }

}
