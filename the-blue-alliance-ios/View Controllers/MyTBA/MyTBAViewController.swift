import UIKit
import UserNotifications
import GoogleSignIn
import CoreData
import Crashlytics

private let MyTBAFavoritesEmbed = "MyTBAFavoritesEmbed"
private let MyTBASubscriptionsEmbed = "MyTBASubscriptionsEmbed"

private let EventSegue = "EventSegue"
private let TeamSegue = "TeamSegue"
private let MatchSegue = "MatchSegue"

class MyTBAViewController: ContainerViewController, GIDSignInUIDelegate {
    
    internal var signInViewController: MyTBASignInViewController!
    @IBOutlet internal var signInView: UIView!
    @IBOutlet internal var signOutBarButtonItem: UIBarButtonItem!
    
    internal var favoritesViewController: MyTBATableViewController<Favorite, MyTBAFavorite>
    internal var favoritesView: UIView

    internal var subscriptionsViewController: MyTBATableViewController<Subscription, MyTBASubscription>
    internal var subscriptionsView: UIView

    required init?(coder aDecoder: NSCoder) {
        favoritesViewController = MyTBATableViewController<Favorite, MyTBAFavorite>()
        favoritesView = favoritesViewController.view
        
        subscriptionsViewController = MyTBATableViewController<Subscription, MyTBASubscription>()
        subscriptionsView = subscriptionsViewController.view

        super.init(coder: aDecoder)

        favoritesViewController.myTBAObjectSelected = { [weak self] (myTBAObj) in
            self?.pushMyTBAObject(myTBAObj)
        }
        subscriptionsViewController.myTBAObjectSelected = { [weak self] (myTBAObj) in
            self?.pushMyTBAObject(myTBAObj)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Fix the white status bar/white UINavigationController during sign in
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/180
        // modalPresentationCapturesStatusBarAppearance = true

        viewControllers = [favoritesViewController, subscriptionsViewController]
        containerViews = [favoritesView, subscriptionsView]
        
        GIDSignIn.sharedInstance().uiDelegate = self
        MyTBA.shared.authenticationProvider.add(observer: self)

        styleInterface()
    }
    
    // MARK: - Private Methods
    
    private func styleInterface() {
        for dataView in [favoritesView, subscriptionsView] {
            view.insertSubview(dataView, belowSubview: signInView)
            dataView.autoPinEdge(toSuperviewEdge: .leading)
            dataView.autoPinEdge(toSuperviewEdge: .trailing)
            dataView.autoPin(toBottomLayoutGuideOf: self, withInset: 0)
            dataView.autoPinEdge(.top, to: .bottom, of: segmentedControlView!)
        }
        
        let isLoggedIn = (MyTBA.shared.authentication != nil)
        signInView.isHidden = isLoggedIn
        
        updateInterface()
    }

    private func updateInterface() {
        // Make sure observers don't setup our interface before our VC is initialized
        if view == nil {
            return
        }

        let isLoggedIn = (MyTBA.shared.authentication != nil)

        navigationItem.rightBarButtonItem = isLoggedIn ? signOutBarButtonItem : nil
        signInView.isHidden = isLoggedIn
    }
    
    private func logout() {
        // Remove auth for myTBA
        MyTBA.shared.authentication = nil
        GIDSignIn.sharedInstance().signOut()
        
        // Cancel any ongoing requests
        for vc in [favoritesViewController, subscriptionsViewController] {
            vc.cancelRefresh()
        }
        
        // Remove all locally stored myTBA data
        removeMyTBAData()
    }
    
    private func removeMyTBAData() {
        let favoritesFetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let deleteFavorites = NSBatchDeleteRequest(fetchRequest: favoritesFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        deleteFavorites.resultType = .resultTypeObjectIDs
        
        let subscriptionsFetchRequest: NSFetchRequest<Subscription> = Subscription.fetchRequest()
        let deleteSubscriptions = NSBatchDeleteRequest(fetchRequest: subscriptionsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        deleteSubscriptions.resultType = .resultTypeObjectIDs
        
        for (viewController, deleteRequest) in zip([favoritesViewController, subscriptionsViewController], [deleteFavorites, deleteSubscriptions]) {
            do {
                let result = try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID] ?? []
                let changes = [NSDeletedObjectsKey : objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [persistentContainer.viewContext])
            } catch {
                // TODO: Mark these for deletion later...
                Crashlytics.sharedInstance().recordError(error)
            }
            
            _ = persistentContainer.viewContext.saveOrRollback()
            
            DispatchQueue.main.async {
                viewController.tableView.reloadData()
            }
        }

        // Clear notifications
    }
    
    private func pushMyTBAObject(_ myTBAObject: MyTBAEntity) {
        guard let modelType = MyTBAModelType(rawValue: myTBAObject.modelType!) else {
            return
        }

        switch modelType {
        case .event:
            performSegue(withIdentifier: EventSegue, sender: myTBAObject.modelKey!)
        case .team:
            performSegue(withIdentifier: TeamSegue, sender: myTBAObject.modelKey!)
        case .match:
            performSegue(withIdentifier: MatchSegue, sender: myTBAObject.modelKey!)
        }
    }
    
    // MARK: - Interface Methods
    
    @IBAction func logoutTapped() {
        let signOutAlertController = UIAlertController(title: "Log Out?", message: "Are you sure you want to sign out of myTBA?", preferredStyle: .alert)
        signOutAlertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { [weak self] (_) in
            self?.logout()
        }))
        signOutAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(signOutAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
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
}

extension MyTBAViewController: MyTBAAuthenticationObservable {
    
    func authenticated() {
        if let segmentedControl = segmentedControl, segmentedControl.selectedSegmentIndex < viewControllers.count {
            viewControllers[segmentedControl.selectedSegmentIndex].refresh()
        }

        updateInterfaceMain()
    }
    
    func unauthenticated() {
        updateInterfaceMain()
    }
    
    func updateInterfaceMain() {
        DispatchQueue.main.async { [weak self] in
            self?.updateInterface()
        }
    }
    
}
