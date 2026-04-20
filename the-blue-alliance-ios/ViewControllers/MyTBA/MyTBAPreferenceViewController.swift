import MyTBAKit
import TBAUtils
import UIKit

class MyTBAPreferenceViewController: TBATableViewController,
    UIAdaptivePresentationControllerDelegate
{

    var subscribableModel: MyTBASubscribable

    lazy var notificationTypes: [NotificationType] = {
        let subscribableModelClass = type(of: subscribableModel)
        return subscribableModelClass.notificationTypes
    }()

    private(set) var isFavoriteInitially: Bool
    var isFavorite: Bool {
        didSet {
            updateInterface()
        }
    }

    private(set) var notificationsInitial: [NotificationType]
    var notifications: [NotificationType] {
        didSet {
            updateInterface()
        }
    }

    private var favoritesStore: FavoritesStore { myTBAStores.favorites }
    private var subscriptionsStore: SubscriptionsStore { myTBAStores.subscriptions }

    private var preferencesTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    // Set while fetching current state from the server on sheet open. If the
    // fetch fails we keep Save disabled so a stale empty toggle set can't
    // silently wipe the user's real server-side subscriptions.
    private var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    private var loadFailed: Bool = false

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
    internal lazy var closeBarButtonItem = UIBarButtonItem(
        title: "Close",
        primaryAction: UIAction { [weak self] _ in
            self?.close()
        }
    )
    internal lazy var saveBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            title: "Save",
            primaryAction: UIAction { [weak self] _ in
                self?.save()
            }
        )
        item.style = .prominent
        return item
    }()
    internal var saveActivityIndicatorBarButtonItem =
        UIBarButtonItem.activityIndicatorBarButtonItem()

    init(subscribableModel: MyTBASubscribable, dependencies: Dependencies) {
        self.subscribableModel = subscribableModel

        let existingFavorite = dependencies.myTBAStores.favorites.favorites.first {
            $0.modelKey == subscribableModel.modelKey && $0.modelType == subscribableModel.modelType
        }
        isFavorite = (existingFavorite != nil)
        isFavoriteInitially = isFavorite

        let existingSubscription = dependencies.myTBAStores.subscriptions.subscription(
            modelKey: subscribableModel.modelKey,
            modelType: subscribableModel.modelType
        )
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
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        preferencesTask?.cancel()
        loadTask?.cancel()
    }

    // MARK: - Interface Methods

    func styleInterface() {
        navigationItem.leftBarButtonItem = closeBarButtonItem
        updateInterface()
    }

    func updateInterface() {
        saveBarButtonItem.isEnabled = hasChanges && !isLoading && !loadFailed
        isModalInPresentation = hasChanges

        if isSaving || isLoading {
            navigationItem.rightBarButtonItem = saveActivityIndicatorBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = saveBarButtonItem
        }
    }

    // The local myTBA stores are only populated when the user visits the
    // corresponding tab in myTBA. Since this sheet can be opened directly from
    // a team/event/match screen, pull the authoritative state from the server
    // before letting the user edit — otherwise empty toggles could overwrite
    // real subscriptions on Save.
    private func refresh() {
        guard myTBA.isAuthenticated else { return }

        isLoading = true
        loadFailed = false
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                async let favorites = self.myTBA.fetchFavorites()
                async let subscriptions = self.myTBA.fetchSubscriptions()
                let (fetchedFavorites, fetchedSubscriptions) = try await (favorites, subscriptions)

                self.favoritesStore.replaceAll(with: fetchedFavorites)
                self.subscriptionsStore.replaceAll(with: fetchedSubscriptions)

                let existingFavorite = fetchedFavorites.first {
                    $0.modelKey == self.subscribableModel.modelKey
                        && $0.modelType == self.subscribableModel.modelType
                }
                self.isFavorite = (existingFavorite != nil)
                self.isFavoriteInitially = self.isFavorite

                let existingSubscription = fetchedSubscriptions.first {
                    $0.modelKey == self.subscribableModel.modelKey
                        && $0.modelType == self.subscribableModel.modelType
                }
                self.notifications = existingSubscription?.notifications ?? []
                self.notificationsInitial = self.notifications

                self.loadTask = nil
                self.isLoading = false
                self.tableView.reloadData()
            } catch is CancellationError {
                self.loadTask = nil
                self.isLoading = false
            } catch {
                self.loadTask = nil
                self.loadFailed = true
                self.isLoading = false
                self.showErrorAlert(
                    with: "Unable to load myTBA preferences - \(error.localizedDescription)"
                )
            }
        }
    }

    // MARK: Navigation Methods

    func presentationControllerDidAttemptToDismiss(
        _ presentationController: UIPresentationController
    ) {
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
                let response = try await self.myTBA.updatePreferences(
                    modelKey: self.subscribableModel.modelKey,
                    modelType: self.subscribableModel.modelType,
                    favorite: self.isFavorite,
                    notifications: self.notifications
                )
                if response.favorite.code < 500 {
                    if self.isFavorite {
                        self.favoritesStore.upsert(
                            MyTBAFavorite(
                                modelKey: self.subscribableModel.modelKey,
                                modelType: self.subscribableModel.modelType
                            )
                        )
                    } else {
                        self.favoritesStore.remove(
                            modelKey: self.subscribableModel.modelKey,
                            modelType: self.subscribableModel.modelType
                        )
                    }
                }
                if response.subscription.code < 500 {
                    if self.notifications.isEmpty {
                        self.subscriptionsStore.remove(
                            modelKey: self.subscribableModel.modelKey,
                            modelType: self.subscribableModel.modelType
                        )
                    } else {
                        self.subscriptionsStore.upsert(
                            MyTBASubscription(
                                modelKey: self.subscribableModel.modelKey,
                                modelType: self.subscribableModel.modelType,
                                notifications: self.notifications
                            )
                        )
                    }
                }
                self.preferencesTask = nil
                self.isSaving = false
                self.dismiss(animated: true)
            } catch {
                self.preferencesTask = nil
                self.isSaving = false
                self.showErrorAlert(
                    with: "Unable to save myTBA preferences - \(error.localizedDescription)"
                )
            }
        }
    }

    func close() {
        dismiss(animated: true)
    }

    func confirmClose() {
        let alert = UIAlertController(
            title: "You have unsaved changes",
            message: "Do you want to save your myTBA preferences?",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                self?.save()
            }
        )
        alert.addAction(
            UIAlertAction(title: "Close", style: .destructive) { [weak self] _ in
                self?.close()
            }
        )
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell: SwitchTableViewCell = {
            if indexPath.section == 0 {
                let switchCell = SwitchTableViewCell(switchToggled: {
                    [weak self] (_ sender: UISwitch) in
                    self?.isFavorite = sender.isOn
                })
                switchCell.textLabel?.text = "Favorite"
                switchCell.detailTextLabel?.text =
                    "You can save teams, events, and matches for easy access in the myTBA tab by marking them as favorites"
                switchCell.detailTextLabel?.numberOfLines = 0
                switchCell.switchView.isOn = isFavorite
                return switchCell
            } else {
                let switchCell = SwitchTableViewCell(switchToggled: {
                    [weak self] (_ sender: UISwitch) in
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

        cell.switchView.isEnabled = !isSaving && !isLoading
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        if section == 1 {
            return "Notification Settings"
        }
        return nil
    }

    // Modal grouped sheet — fall back to the iOS default header rendering
    // instead of TBATableViewController's navy-on-white tab chrome.
    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        // Intentionally not calling super.
    }

}
