import Foundation
import MyTBAKit
import PureLayout
import TBAAPI
import UIKit

public enum MyTBASection: Int {
    case event
    case team

    var headerTitle: String {
        switch self {
        case .event: return "Events"
        case .team: return "Teams"
        }
    }
}

protocol MyTBATableViewControllerDelegate: AnyObject {
    func eventSelected(eventKey: String)
    func teamSelected(teamKey: String)
}

enum MyTBAItem: Hashable {
    case event(key: String)
    case team(key: String)

    init?(modelType: MyTBAModelType, key: String) {
        switch modelType {
        case .event: self = .event(key: key)
        case .team: self = .team(key: key)
        default: return nil
        }
    }

    var section: MyTBASection {
        switch self {
        case .event: return .event
        case .team: return .team
        }
    }

    var modelKey: String {
        switch self {
        case .event(let key), .team(let key):
            return key
        }
    }
}

// Abstract base. Two concrete subclasses below bind to FavoritesStore or
// SubscriptionsStore, then pass their entries through the common rendering
// pipeline. Owns the loaded-model cache, failure tracking, and the pinned
// failure banner that sits above the table.
class MyTBATableViewController: UIViewController, NotificationObservable,
    TableViewDataSourceDelegate, DataController, Navigatable
{

    let dependencies: Dependencies
    weak var delegate: MyTBATableViewControllerDelegate?

    var api: any TBAAPIProtocol { dependencies.api }
    var myTBA: any MyTBAProtocol { dependencies.myTBA }
    var myTBAStores: MyTBAStores { dependencies.myTBAStores }
    var statusService: any StatusServiceProtocol { dependencies.statusService }
    var urlOpener: any URLOpener { dependencies.urlOpener }

    // MARK: - Refreshable

    var currentRefreshTask: Task<Void, Never>?

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Views

    private(set) var tableView: UITableView!
    private var failureBannerView: FailureBannerView!
    private var failureBannerContainer: UIView!
    private var failureBannerHeightConstraint: NSLayoutConstraint!
    private var dataSource: TableViewDataSource<MyTBASection, MyTBAItem>!

    // MARK: - State

    private enum LoadedModel {
        case event(Event)
        case team(Team)
    }
    private var loadedModels: [MyTBAItem: LoadedModel] = [:]
    private var failedKeys: Set<MyTBAItem> = []
    /// When true, failed items render inline as key-only placeholder cells and
    /// the banner stays hidden until the next refresh repopulates `failedKeys`.
    private var inlineFailedKeys: Bool = false

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground

        failureBannerView = FailureBannerView()
        failureBannerView.addAction(
            UIAction { [weak self] _ in self?.bannerTapped() },
            for: .touchUpInside
        )
        failureBannerView.translatesAutoresizingMaskIntoConstraints = false

        // Clipping wrapper so the banner can slide up behind the segmented
        // control instead of being scrunched. Banner is pinned to the wrapper's
        // bottom; animating the wrapper's height 0 ↔ bannerHeight produces the
        // slide effect without resizing the banner content itself.
        failureBannerContainer = UIView()
        failureBannerContainer.clipsToBounds = true
        failureBannerContainer.translatesAutoresizingMaskIntoConstraints = false
        failureBannerContainer.addSubview(failureBannerView)
        NSLayoutConstraint.activate([
            failureBannerView.leadingAnchor.constraint(
                equalTo: failureBannerContainer.leadingAnchor
            ),
            failureBannerView.trailingAnchor.constraint(
                equalTo: failureBannerContainer.trailingAnchor
            ),
            failureBannerView.bottomAnchor.constraint(
                equalTo: failureBannerContainer.bottomAnchor
            ),
        ])
        failureBannerHeightConstraint = failureBannerContainer.heightAnchor.constraint(
            equalToConstant: 0
        )
        failureBannerHeightConstraint.isActive = true

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.registerReusableCell(BasicTableViewCell.self)
        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
            tableView.contentInsetAdjustmentBehavior = .never
        }

        let stack = UIStackView(arrangedSubviews: [failureBannerContainer, tableView])
        stack.axis = .vertical
        view.addSubview(stack)
        stack.autoPinEdge(toSuperviewSafeArea: .top)
        stack.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        setupDataSource()
        tableView.dataSource = dataSource

        registerForStoreChanges()
        rebuildSnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
    }

    // MARK: Subclass Hooks

    /// The entries to display, grouped by `MyTBASection` order.
    var currentItems: [MyTBAItem] {
        fatalError("Subclasses must override currentItems")
    }

    /// Kicks off a remote refresh, writes the result into the backing store.
    func performRemoteRefresh() async throws {
        fatalError("Subclasses must override performRemoteRefresh()")
    }

    /// Registers for the NotificationCenter name that the backing store posts on change.
    func registerForStoreChanges() {
        fatalError("Subclasses must override registerForStoreChanges()")
    }

    // MARK: - Refreshable default

    func refresh() {
        guard myTBA.isAuthenticated else { return }
        refreshFromRemote()
    }

    // MARK: - Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<MyTBASection, MyTBAItem>(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                if let model = self.loadedModels[item] {
                    return self.makeCell(for: model, in: tableView, at: indexPath)
                }
                if self.inlineFailedKeys, self.failedKeys.contains(item) {
                    return self.makePlaceholderCell(for: item, in: tableView, at: indexPath)
                }
                return UITableViewCell()
            }
        )
        dataSource.delegate = self
    }

    private func makeCell(
        for model: LoadedModel,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        switch model {
        case .event(let event):
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(
                name: event.safeShortName,
                location: event.locationString,
                dateString: event.dateString
            )
            return cell
        case .team(let team):
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(
                teamNumber: "\(team.teamNumber)",
                nickname: team.displayNickname,
                location: team.locationString
            )
            return cell
        }
    }

    private func makePlaceholderCell(
        for item: MyTBAItem,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        switch item {
        case .event(let key):
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(name: key, location: nil, dateString: nil)
            return cell
        case .team(let key):
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(
                teamNumber: key.trimPrefix,
                nickname: "Team \(key.trimPrefix)",
                location: nil
            )
            return cell
        }
    }

    private func rebuildSnapshot() {
        let validItems = Set(currentItems)
        loadedModels = loadedModels.filter { validItems.contains($0.key) }
        failedKeys.formIntersection(validItems)

        var snapshot = NSDiffableDataSourceSnapshot<MyTBASection, MyTBAItem>()
        let visible = currentItems.filter { item in
            if loadedModels[item] != nil { return true }
            if inlineFailedKeys, failedKeys.contains(item) { return true }
            return false
        }
        let grouped = Dictionary(grouping: visible, by: { $0.section })
        for section in [MyTBASection.event, .team] {
            guard let sectionItems = grouped[section], !sectionItems.isEmpty else { continue }
            let sorted = sortItems(sectionItems, in: section)
            snapshot.appendSections([section])
            snapshot.appendItems(sorted, toSection: section)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)

        updateFailureBanner()
    }

    private func sortItems(_ items: [MyTBAItem], in section: MyTBASection) -> [MyTBAItem] {
        switch section {
        case .event:
            return items.sorted { lhs, rhs in
                guard case .event(let l) = loadedModels[lhs],
                    case .event(let r) = loadedModels[rhs]
                else {
                    return lhs.modelKey < rhs.modelKey
                }
                let lYear = Int(l.key.prefix(4)) ?? 0
                let rYear = Int(r.key.prefix(4)) ?? 0
                if lYear != rYear { return lYear > rYear }
                return Event.sectionAscending(l, r)
            }
        case .team:
            return items.sorted { lhs, rhs in
                guard case .team(let l) = loadedModels[lhs],
                    case .team(let r) = loadedModels[rhs]
                else {
                    return lhs.modelKey < rhs.modelKey
                }
                return l.teamNumber < r.teamNumber
            }
        }
    }

    // MARK: - TableViewDataSourceDelegate

    func title(forSection sectionIndex: Int) -> String? {
        let sections = dataSource.snapshot().sectionIdentifiers
        guard sectionIndex < sections.count else { return nil }
        return sections[sectionIndex].headerTitle
    }

    // MARK: - Stateful wiring

    /// Concrete subclasses call this from `viewDidLoad` (after `super`) to
    /// hook the no-data view into the data source. Walked via an Obj-C cast so
    /// the base doesn't have to conform.
    func attachStatefulDelegate() {
        dataSource.statefulDelegate = self as? (Refreshable & Stateful)
    }

    // MARK: - Refresh

    func storeDidChange() {
        rebuildSnapshot()
        // Locally added favorites/subscriptions need their backing models loaded
        // even when the user hasn't pulled to refresh.
        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.fetchMissingItems()
            self.rebuildSnapshot()
        }
    }

    func refreshFromRemote() {
        (self as? Refreshable)?.runRefresh { [weak self] in
            guard let self else { return }
            self.failedKeys.removeAll()
            self.inlineFailedKeys = false
            self.updateFailureBanner()
            try await self.performRemoteRefresh()
            await self.fetchMissingItems()
            self.rebuildSnapshot()
        }
    }

    private func fetchMissingItems() async {
        let items = currentItems
        await withTaskGroup(of: Void.self) { group in
            for item in items where loadedModels[item] == nil {
                group.addTask { [weak self] in
                    guard let self = self else { return }
                    do {
                        let model = try await self.loadModel(for: item)
                        await MainActor.run {
                            self.loadedModels[item] = model
                            self.failedKeys.remove(item)
                            self.rebuildSnapshot()
                        }
                    } catch is CancellationError {
                        // Refresh was cancelled; leave state untouched.
                    } catch {
                        await MainActor.run {
                            self.failedKeys.insert(item)
                            self.updateFailureBanner()
                        }
                    }
                }
            }
        }
    }

    private func loadModel(for item: MyTBAItem) async throws -> LoadedModel {
        switch item {
        case .event(let key):
            return .event(try await dependencies.api.event(key: key))
        case .team(let key):
            return .team(try await dependencies.api.team(key: key))
        }
    }

    // MARK: - Failure Banner

    private func updateFailureBanner() {
        let events = failedKeys.filter { $0.section == .event }.count
        let teams = failedKeys.filter { $0.section == .team }.count
        let text = inlineFailedKeys ? nil : Self.failureBannerText(events: events, teams: teams)
        if let text { failureBannerView.text = text }

        let target: CGFloat
        if text != nil {
            let fitting = failureBannerView.systemLayoutSizeFitting(
                CGSize(
                    width: view.bounds.width,
                    height: UIView.layoutFittingCompressedSize.height
                ),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            target = fitting.height
        } else {
            target = 0
        }

        guard failureBannerHeightConstraint.constant != target else { return }
        failureBannerHeightConstraint.constant = target
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }

    static func failureBannerText(events: Int, teams: Int) -> String? {
        let parts: [String] = [
            (events > 0 ? "\(events) \(events == 1 ? "event" : "events")" : nil),
            (teams > 0 ? "\(teams) \(teams == 1 ? "team" : "teams")" : nil),
        ].compactMap { $0 }
        guard !parts.isEmpty else { return nil }
        return "Failed to load \(parts.joined(separator: ", "))"
    }

    private func bannerTapped() {
        guard !failedKeys.isEmpty else { return }
        inlineFailedKeys = true
        rebuildSnapshot()
    }
}

// MARK: - UITableViewDelegate

extension MyTBATableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .event(let key): delegate?.eventSelected(eventKey: key)
        case .team(let key): delegate?.teamSelected(teamKey: key)
        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if type(of: view) == UITableViewHeaderFooterView.self,
            let view = view as? UITableViewHeaderFooterView
        {
            view.textLabel?.textColor = UIColor.white
            view.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)

            let headerView = UIView()
            headerView.backgroundColor = UIColor.tableViewHeaderColor
            view.backgroundView = headerView
        }
    }
}

// MARK: - Refreshable / Stateful

extension Refreshable where Self: MyTBATableViewController {

    var refreshControl: UIRefreshControl? {
        get { tableView.refreshControl }
        set { tableView.refreshControl = newValue }
    }

    var refreshView: UIScrollView { tableView }

    func hideNoData() {
        // Default no-op; the Stateful override handles the real case.
    }

    func noDataReload() {
        // Default no-op; the Stateful override handles the real case.
    }
}

extension Stateful where Self: MyTBATableViewController {

    func addNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = noDataView
        }
    }

    func removeNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = nil
        }
    }
}

extension Refreshable where Self: MyTBATableViewController & Stateful {

    func hideNoData() {
        removeNoDataView()
    }

    func noDataReload() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            removeNoDataView()
        }
    }
}

// MARK: - Favorites

class MyTBAFavoritesViewController: MyTBATableViewController, Refreshable, Stateful {

    private var favoritesStore: FavoritesStore { myTBAStores.favorites }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachStatefulDelegate()
    }

    override var currentItems: [MyTBAItem] {
        favoritesStore.favorites.compactMap {
            MyTBAItem(modelType: $0.modelType, key: $0.modelKey)
        }
    }

    override func registerForStoreChanges() {
        observeNotification(name: .favoritesStoreDidChange) { [weak self] _ in
            Task { @MainActor in self?.storeDidChange() }
        }
    }

    override func performRemoteRefresh() async throws {
        let favorites = try await myTBA.fetchFavorites()
        await MainActor.run { favoritesStore.replaceAll(with: favorites) }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { myTBA.isAuthenticated && favoritesStore.favorites.isEmpty }

    // MARK: - Stateful

    var noDataText: String? { "No favorites" }
}

// MARK: - Subscriptions

class MyTBASubscriptionsViewController: MyTBATableViewController, Refreshable, Stateful {

    private var subscriptionsStore: SubscriptionsStore { myTBAStores.subscriptions }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachStatefulDelegate()
    }

    override var currentItems: [MyTBAItem] {
        subscriptionsStore.subscriptions.compactMap {
            MyTBAItem(modelType: $0.modelType, key: $0.modelKey)
        }
    }

    override func registerForStoreChanges() {
        observeNotification(name: .subscriptionsStoreDidChange) { [weak self] _ in
            Task { @MainActor in self?.storeDidChange() }
        }
    }

    override func performRemoteRefresh() async throws {
        let subs = try await myTBA.fetchSubscriptions()
        await MainActor.run { subscriptionsStore.replaceAll(with: subs) }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool {
        myTBA.isAuthenticated && subscriptionsStore.subscriptions.isEmpty
    }

    // MARK: - Stateful

    var noDataText: String? { "No subscriptions" }
}

// MARK: - NotificationObservable helper

protocol NotificationObservable: AnyObject {}

extension NotificationObservable {
    func observeNotification(name: Notification.Name, handler: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main,
            using: handler
        )
    }
}

// MARK: - Failure Banner View

private final class FailureBannerView: UIControl {

    private let label = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.isUserInteractionEnabled = false

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .white
        chevron.contentMode = .scaleAspectFit
        chevron.isUserInteractionEnabled = false
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [label, chevron])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        )

        accessibilityTraits = .button
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var accessibilityLabel: String? {
        get { label.text }
        set { super.accessibilityLabel = newValue }
    }
}
