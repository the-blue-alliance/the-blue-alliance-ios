import CoreData
import Crashlytics
import FirebaseMessaging
import MyTBAKit
import TBAData
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
    var isFavorite: Bool

    var subscription: Subscription?
    let notificationsInitial: [NotificationType]
    var notifications: [NotificationType]

    let messaging: Messaging
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

    init(subscribableModel: MyTBASubscribable, messaging: Messaging, myTBA: MyTBA, persistentContainer: NSPersistentContainer) {
        self.subscribableModel = subscribableModel
        self.messaging = messaging
        self.myTBA = myTBA
        self.persistentContainer = persistentContainer

        favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        isFavorite = (favorite != nil)
        isFavoriteInitially = isFavorite

        subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        notifications = subscription?.notifications ?? []
        notificationsInitial = notifications

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

        let fcmToken = messaging.fcmToken
        preferencesOperation = myTBA.updatePreferences(deviceKey: fcmToken, modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, favorite: isFavorite, notifications: notifications, completion: { [weak self] (favoriteResponse, subscriptionResponse, error) in
            guard let self = self else { return }
            let context = self.persistentContainer.newBackgroundContext()

            context.performChangesAndWait({
                if let favoriteResponse = favoriteResponse, favoriteResponse.code < 500 {
                    if !self.isFavorite, let favorite = self.favorite {
                        // Delete
                        context.delete(context.object(with: favorite.objectID))
                    } else if self.isFavorite {
                        // Insert
                        Favorite.insert(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, in: context)
                    }
                }

                if let subscriptionResponse = subscriptionResponse, subscriptionResponse.code < 500 {
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
            }, errorRecorder: Crashlytics.sharedInstance())
        })

        let dismissOperation = BlockOperation(block: { [weak self] in
            guard let self = self else { return }

            self.isSaving = false
            DispatchQueue.main.async {
                if let favorite = self.favorite {
                    self.persistentContainer.viewContext.refresh(favorite, mergeChanges: true)
                }
                if let subscription = self.subscription {
                    self.persistentContainer.viewContext.refresh(subscription, mergeChanges: true)
                }
                self.dismiss(animated: true)
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
        let cell: SwitchTableViewCell = {
            if indexPath.section == 0 {
                let switchCell = SwitchTableViewCell(switchToggled: { [weak self] (_ sender: UISwitch) in
                    self?.isFavorite = sender.isOn
                })
                switchCell.textLabel?.text = "Favorite"
                switchCell.detailTextLabel?.text = "You can save teams, events, and matches for easy access in the myTBA tab by marking them as favorites"
                switchCell.detailTextLabel?.numberOfLines = 0
                switchCell.switchView.isOn = isFavorite
                return switchCell
            } else {
                let switchCell = SwitchTableViewCell(switchToggled: { [weak self] (_ sender: UISwitch) in
                    let index = sender.tag
                    guard let notificationType = self?.notificationTypes[index] else {
                        return
                    }

                    if let removeIndex = self?.notifications.firstIndex(of: notificationType) {
                        self?.notifications.remove(at: removeIndex)
                    } else {
                        self?.notifications.append(notificationType)
                    }
                })
                let notificationType = notificationTypes[indexPath.row]
                switchCell.textLabel?.text = notificationType.displayString()
                switchCell.switchView.tag = indexPath.row
                switchCell.switchView.isOn = notifications.contains(notificationType)
                return switchCell
            }

        }()

        cell.switchView.isEnabled = !isSaving
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
