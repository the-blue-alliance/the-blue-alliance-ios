import CoreData
import MyTBAKit
import UIKit

// Two sections are a single no-title section for "Favorite" cell,
// and a "Notification Settings" section with option cells
// This view assume it's bein
class MyTBAPreferenceViewController: UITableViewController {

    var subscribableModel: MyTBASubscribable

    lazy var notificationTypes: [NotificationType] = {
        let subscribableModelClass = type(of: subscribableModel)
        return subscribableModelClass.notificationTypes
    }()

    var favorite: Favorite?
    let isFavoriteInitially: Bool
    var isFavorite: Bool = false

    var subscription: Subscription?
    let notificationsInitial: [NotificationType]
    var notifications: [NotificationType] = []

    let myTBA: MyTBA
    let persistentContainer: NSPersistentContainer

    var preferencesOperation: MyTBAOperation?
    let operationQueue = OperationQueue()

    private var isSaving: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
                self.tableView.reloadData()
            }
        }
    }

    internal lazy var saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save",
                                                                           style: .done,
                                                                           target: self,
                                                                           action: #selector(save))
    internal var saveActivityIndicatorBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()

    init(subscribableModel: MyTBASubscribable, myTBA: MyTBA, persistentContainer: NSPersistentContainer) {
        self.subscribableModel = subscribableModel
        self.myTBA = myTBA
        self.persistentContainer = persistentContainer

        let favoritePredicate = Favorite.favoritePredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        if let favorite = Favorite.findOrFetch(in: persistentContainer.viewContext, matching: favoritePredicate) {
            self.favorite = favorite
            isFavorite = true
        }
        self.isFavoriteInitially = isFavorite

        let subscriptionPredicate = Subscription.subscriptionPredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        if let subscription = Subscription.findOrFetch(in: persistentContainer.viewContext, matching: subscriptionPredicate) {
            self.subscription = subscription
            notifications = subscription.notifications
        }
        self.notificationsInitial = notifications

        super.init(style: .grouped)

        title = "myTBA Preferences"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        operationQueue.cancelAllOperations()
    }

    // MARK: - Interface Methods

    func styleInterface() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))

        updateInterface()
    }

    func updateInterface() {
        if isSaving {
            navigationItem.rightBarButtonItem = saveActivityIndicatorBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = saveBarButtonItem
        }
    }

    @objc func favoriteSwitchToggled(_ sender: UISwitch) {
        isFavorite = sender.isOn
    }

    @objc func notificationSwitchToggled(_ sender: UISwitch) {
        let index = sender.tag
        let notificationType = notificationTypes[index]

        if let removeIndex = notifications.firstIndex(of: notificationType) {
            notifications.remove(at: removeIndex)
        } else {
            notifications.append(notificationType)
        }
    }

    // MARK: Navigation Methods

    var preferencesHaveChanged: Bool {
        return (notifications != notificationsInitial) || (isFavorite != isFavoriteInitially)
    }

    @objc func save() {
        // Nothing has changed - go ahead and dismiss without saving
        if !preferencesHaveChanged {
            self.dismiss(animated: true)
            return
        }

        isSaving = true

        preferencesOperation = myTBA.updatePreferences(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, favorite: isFavorite, notifications: notifications, completion: { [unowned self] (favoriteResponse, subscriptionResponse, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let favoriteResponse = favoriteResponse, favoriteResponse.code < 400 {
                    if !self.isFavorite, let fav = self.favorite {
                        // Delete
                        context.delete(context.object(with: fav.objectID))
                    } else if self.isFavorite, self.favorite == nil {
                        // Insert
                        Favorite.insert(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, in: context)
                    }
                }

                if let subscriptionResponse = subscriptionResponse, subscriptionResponse.code < 400 {
                    let hasNotifications = !self.notifications.isEmpty
                    if !hasNotifications, let subscription = self.subscription {
                        // Delete
                        context.delete(context.object(with: subscription.objectID))
                    } else if hasNotifications {
                        if let subscription = self.subscription {
                            // Update
                            let sub = context.object(with: subscription.objectID) as! Subscription
                            sub.notifications = self.notifications
                        } else {
                            // Insert
                            Subscription.insert(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, notifications: self.notifications, in: context)
                        }
                    }
                }
            })
        })

        let dismissOperation = BlockOperation(block: { [weak self] in
            self?.isSaving = false
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        })
        dismissOperation.addDependency(preferencesOperation!)

        operationQueue.addOperations([preferencesOperation!, dismissOperation], waitUntilFinished: false)
    }

    @objc func close() {
        dismiss(animated: true)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let switchView = UISwitch(frame: .zero)
        switchView.isEnabled = !isSaving
        cell.accessoryView = switchView

        if indexPath.section == 0 {
            cell.textLabel?.text = "Favorite"
            cell.detailTextLabel?.text = "You can save teams, events, and matches for easy access in the myTBA tab by marking them as favorites"
            cell.detailTextLabel?.numberOfLines = 0
            switchView.isOn = isFavorite
            switchView.addTarget(self, action: #selector(favoriteSwitchToggled(_:)), for: .valueChanged)
        } else {
            let notificationType = notificationTypes[indexPath.row]
            cell.textLabel?.text = notificationType.displayString()
            switchView.tag = indexPath.row
            switchView.isOn = notifications.contains(notificationType)
            switchView.addTarget(self, action: #selector(notificationSwitchToggled(_:)), for: .valueChanged)
        }

        cell.selectionStyle = .none

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Disable subscriptions
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        if section == 0 {
            rows = 1
        } else if section == 1 {
            rows = notificationTypes.count
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Notification Settings"
        }
        return nil
    }

}
