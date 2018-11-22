import CoreData
import Foundation
import UIKit

// Two sections are a single no-title section for "Favorite" cell,
// and a "Notification Settings" section with option cells
class MyTBAPreferenceViewController: UITableViewController {

    var subscribableModel: MyTBASubscribable

    lazy var notificationTypes: [NotificationType] = {
        let subscribableModelClass = type(of: subscribableModel)
        return subscribableModelClass.notificationTypes
    }()

    var favorite: Favorite?
    var isFavorite: Bool = false

    var subscription: Subscription?
    var notifications: [NotificationType] = []

    let myTBA: MyTBA
    let persistentContainer: NSPersistentContainer

    var preferencesRequest: URLSessionDataTask?

    private var isSaving: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    internal lazy var saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save",
                                                                           style: .done,
                                                                           target: self,
                                                                           action: #selector(save))

    internal var saveActivityIndicatorBarButtonItem: UIBarButtonItem = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }()

    init(subscribableModel: MyTBASubscribable, myTBA: MyTBA, persistentContainer: NSPersistentContainer) {
        self.subscribableModel = subscribableModel
        self.myTBA = myTBA
        self.persistentContainer = persistentContainer

        let favoritePredicate = Favorite.favoritePredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        if let favorite = Favorite.findOrFetch(in: persistentContainer.viewContext, matching: favoritePredicate) {
            self.favorite = favorite
            self.isFavorite = true
        }

        let subscriptionPredicate = Subscription.subscriptionPredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        if let subscription = Subscription.findOrFetch(in: persistentContainer.viewContext, matching: subscriptionPredicate) {
            self.subscription = subscription
            self.notifications = subscription.notifications
        }

        super.init(style: .plain)
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

        preferencesRequest?.cancel()
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

        if let removeIndex = notifications.index(of: notificationType) {
            notifications.remove(at: removeIndex)
        } else {
            notifications.append(notificationType)
        }
    }

    // MARK: Navigation Methods

    @objc func save() {
        isSaving = true

        print("isFavorite: \(isFavorite ? "YES" : "NO") | notifications: \(notifications)")
        preferencesRequest = myTBA.updatePreferences(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, favorite: isFavorite, notifications: notifications, completion: { [unowned self] (favoriteResponse, subscriptionResponse, error) in

            if let favoriteResponse = favoriteResponse, favoriteResponse.code < 400 {
                if !self.isFavorite, let fav = self.favorite {
                    // Delete
                    self.persistentContainer.viewContext.delete(fav)
                } else if self.isFavorite, self.favorite == nil {
                    // Insert
                    Favorite.insert(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, in: self.persistentContainer.viewContext)
                }
            }

            if let subscriptionResponse = subscriptionResponse, subscriptionResponse.code < 400 {
                let hasNotifications = !self.notifications.isEmpty
                if !hasNotifications, let subscription = self.subscription {
                    // Delete
                    self.persistentContainer.viewContext.delete(subscription)
                } else if hasNotifications {
                    if let subscription = self.subscription {
                        // Update
                        print("subscription.notifications: \(subscription.notifications)")
                        print("self.notifications: \(self.notifications)")
                        subscription.notifications = self.notifications
                    } else {
                        // Insert
                        Subscription.insert(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, notifications: self.notifications, in: self.persistentContainer.viewContext)
                    }
                }
            }

            _ = self.persistentContainer.viewContext.saveOrRollback()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let switchView = UISwitch(frame: .zero)
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
        return 2
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
