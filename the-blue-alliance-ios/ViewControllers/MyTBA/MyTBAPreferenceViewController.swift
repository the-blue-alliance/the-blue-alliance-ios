import MyTBAKit
import TBAUtils
import UIKit

class MyTBAPreferenceViewController: TBATableViewController, UIAdaptivePresentationControllerDelegate {

    var subscribableModel: MyTBASubscribable

    lazy var notificationTypes: [NotificationType] = {
        let subscribableModelClass = type(of: subscribableModel)
        return subscribableModelClass.notificationTypes
    }()

    let isFavoriteInitially: Bool
    var isFavorite: Bool {
        didSet {
            updateInterface()
        }
    }

    let notificationsInitial: [NotificationType]
    var notifications: [NotificationType] {
        didSet {
            updateInterface()
        }
    }

    private var favoritesStore: FavoritesStore { myTBAStores.favorites }
    private var subscriptionsStore: SubscriptionsStore { myTBAStores.subscriptions }

    private var preferencesTask: Task<Void, Never>?

    var hasChanges: Bool {
        return (notifications != notificationsInitial) || (isFavorite != isFavoriteInitially)
    }

    private var isSaving: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
                self.tableView.reloadData()
            }
        }
    }
    internal lazy var closeBarButtonItem = UIBarButtonItem(title: "Close", primaryAction: UIAction { [weak self] _ in
        self?.close()
    })
    internal lazy var saveBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Save", primaryAction: UIAction { [weak self] _ in
            self?.save()
        })
        item.style = .prominent
        return item
    }()
    internal var saveActivityIndicatorBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()

    init(subscribableModel: MyTBASubscribable, dependencies: Dependencies) {
        self.subscribableModel = subscribableModel

        let existingFavorite = dependencies.myTBAStores.favorites.favorites.first { $0.modelKey == subscribableModel.modelKey && $0.modelType == subscribableModel.modelType }
        isFavorite = (existingFavorite != nil)
        isFavoriteInitially = isFavorite

        let existingSubscription = dependencies.myTBAStores.subscriptions.subscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        notifications = existingSubscription?.notifications ?? []
        notificationsInitial = notifications

        super.init(style: .grouped, dependencies: dependencies)

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

        preferencesTask?.cancel()
    }

    // MARK: - Interface Methods

    func styleInterface() {
        navigationItem.leftBarButtonItem = closeBarButtonItem
        updateInterface()
    }

    func updateInterface() {
        saveBarButtonItem.isEnabled = hasChanges
        isModalInPresentation = hasChanges

        if isSaving {
            navigationItem.rightBarButtonItem = saveActivityIndicatorBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = saveBarButtonItem
        }
    }

    // MARK: Navigation Methods

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if isSaving {
            return
        }
        confirmClose()
    }

    func save() {
        isSaving = true
        preferencesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response = try await self.myTBA.updatePreferences(modelKey: self.subscribableModel.modelKey,
                                                                      modelType: self.subscribableModel.modelType,
                                                                      favorite: self.isFavorite,
                                                                      notifications: self.notifications)
                if response.favorite.code < 500 {
                    if self.isFavorite {
                        self.favoritesStore.upsert(MyTBAFavorite(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType))
                    } else {
                        self.favoritesStore.remove(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType)
                    }
                }
                if response.subscription.code < 500 {
                    if self.notifications.isEmpty {
                        self.subscriptionsStore.remove(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType)
                    } else {
                        self.subscriptionsStore.upsert(MyTBASubscription(modelKey: self.subscribableModel.modelKey, modelType: self.subscribableModel.modelType, notifications: self.notifications))
                    }
                }
                self.preferencesTask = nil
                self.isSaving = false
                self.dismiss(animated: true)
            } catch {
                self.preferencesTask = nil
                self.isSaving = false
                self.showErrorAlert(with: "Unable to save myTBA preferences - \(error.localizedDescription)")
            }
        }
    }

    func close() {
        dismiss(animated: true)
    }

    func confirmClose() {
        let alert = UIAlertController(title: "You have unsaved changes", message: "Do you want to save your myTBA preferences?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.save()
        })
        alert.addAction(UIAlertAction(title: "Close", style: .destructive) { [weak self] _ in
            self?.close()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.popoverPresentationController?.barButtonItem = closeBarButtonItem

        present(alert, animated: true, completion: nil)
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
