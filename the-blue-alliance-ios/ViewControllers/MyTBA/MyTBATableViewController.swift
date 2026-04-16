import Foundation
import MyTBAKit
import TBAAPI
import UIKit

public enum MyTBASection: Int {
    case event
    case team
    case match

    static func section(for modelType: MyTBAModelType) -> MyTBASection? {
        switch modelType {
        case .event: return .event
        case .team: return .team
        case .match: return .match
        default: return nil
        }
    }

    var headerTitle: String {
        switch self {
        case .event: return "Events"
        case .team: return "Teams"
        case .match: return "Matches"
        }
    }
}

protocol MyTBATableViewControllerDelegate: AnyObject {
    func eventSelected(eventKey: String)
    func teamSelected(teamKey: String)
    func matchSelected(matchKey: String)
}

enum MyTBAItem: Hashable {
    case event(key: String)
    case team(key: String)
    case match(key: String)

    var section: MyTBASection {
        switch self {
        case .event: return .event
        case .team: return .team
        case .match: return .match
        }
    }

    var modelKey: String {
        switch self {
        case .event(let key), .team(let key), .match(let key):
            return key
        }
    }
}

// Abstract base. Two concrete subclasses below bind to FavoritesStore or
// SubscriptionsStore, then pass their entries through the common rendering
// pipeline (per-type caches populated lazily from TBAAPI).
class MyTBATableViewController: TBATableViewController, NotificationObservable {

    let myTBA: MyTBA
    weak var delegate: MyTBATableViewControllerDelegate?

    private var dataSource: TableViewDataSource<MyTBASection, MyTBAItem>!

    private var eventsCache: [String: Components.Schemas.Event] = [:]
    private var teamsCache: [String: Components.Schemas.Team] = [:]
    private var matchesCache: [String: Components.Schemas.Match] = [:]

    // MARK: Init

    init(myTBA: MyTBA, dependencies: Dependencies) {
        self.myTBA = myTBA

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource

        registerForStoreChanges()

        rebuildSnapshot()
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

    // MARK: Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<MyTBASection, MyTBAItem>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            switch item {
            case .event(let key):
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
                if let event = self.eventsCache[key] {
                    cell.viewModel = EventCellViewModel(name: event.safeShortName, location: event.locationString, dateString: event.dateString)
                } else {
                    cell.viewModel = EventCellViewModel(name: key, location: nil, dateString: nil)
                }
                return cell
            case .team(let key):
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
                if let team = self.teamsCache[key] {
                    cell.viewModel = TeamCellViewModel(teamNumber: "\(team.teamNumber)", nickname: team.displayNickname, location: team.locationString)
                } else {
                    cell.viewModel = TeamCellViewModel(teamNumber: TeamKey.trimFRCPrefix(key), nickname: "Team \(TeamKey.trimFRCPrefix(key))", location: nil)
                }
                return cell
            case .match(let key):
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
                if let match = self.matchesCache[key] {
                    cell.viewModel = MatchViewModel(apiMatch: match)
                } else {
                    cell.textLabel?.text = key
                }
                return cell
            }
        })
        dataSource.delegate = self
    }

    private func rebuildSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MyTBASection, MyTBAItem>()
        let items = currentItems
        let grouped = Dictionary(grouping: items, by: { $0.section })
        for section in [MyTBASection.event, .team, .match] {
            guard let sectionItems = grouped[section], !sectionItems.isEmpty else { continue }
            let sorted = sortItems(sectionItems, in: section)
            snapshot.appendSections([section])
            snapshot.appendItems(sorted, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func sortItems(_ items: [MyTBAItem], in section: MyTBASection) -> [MyTBAItem] {
        switch section {
        case .event:
            return items.sorted { lhs, rhs in
                let lEvent = eventsCache[lhs.modelKey]
                let rEvent = eventsCache[rhs.modelKey]
                let lYear = lEvent.flatMap { Int($0.key.prefix(4)) } ?? 0
                let rYear = rEvent.flatMap { Int($0.key.prefix(4)) } ?? 0
                if lYear != rYear { return lYear > rYear }
                if let l = lEvent, let r = rEvent { return l < r }
                return lhs.modelKey < rhs.modelKey
            }
        case .team:
            return items.sorted { lhs, rhs in
                let l = teamsCache[lhs.modelKey].map { $0.teamNumber } ?? Int(TeamKey.trimFRCPrefix(lhs.modelKey)) ?? 0
                let r = teamsCache[rhs.modelKey].map { $0.teamNumber } ?? Int(TeamKey.trimFRCPrefix(rhs.modelKey)) ?? 0
                return l < r
            }
        case .match:
            return items.sorted { lhs, rhs in
                if let l = matchesCache[lhs.modelKey], let r = matchesCache[rhs.modelKey] {
                    if l.compLevelSortOrder != r.compLevelSortOrder { return l.compLevelSortOrder < r.compLevelSortOrder }
                    if l.setNumber != r.setNumber { return l.setNumber < r.setNumber }
                    return l.matchNumber < r.matchNumber
                }
                return lhs.modelKey < rhs.modelKey
            }
        }
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection sectionIndex: Int) -> String? {
        let sections = dataSource.snapshot().sectionIdentifiers
        guard sectionIndex < sections.count else { return nil }
        return sections[sectionIndex].headerTitle
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .event(let key): delegate?.eventSelected(eventKey: key)
        case .team(let key): delegate?.teamSelected(teamKey: key)
        case .match(let key): delegate?.matchSelected(matchKey: key)
        }
    }

    // MARK: Stateful wiring

    /// Concrete subclasses call this from `viewDidLoad` (after `super`) to
    /// hook the no-data view into the data source. Declared on the base but
    /// walked via an Obj-C cast so the base doesn't have to conform.
    func attachStatefulDelegate() {
        dataSource.statefulDelegate = self as? (Refreshable & Stateful)
    }

    // MARK: Refresh

    func storeDidChange() {
        rebuildSnapshot()
    }

    func refreshFromRemote(onSuccess: @escaping () -> Void) {
        Task { @MainActor in
            do {
                try await performRemoteRefresh()
                await fetchMissingItems()
                rebuildSnapshot()
                onSuccess()
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    private func fetchMissingItems() async {
        let items = currentItems
        await withTaskGroup(of: Void.self) { group in
            for item in items {
                switch item {
                case .event(let key) where eventsCache[key] == nil:
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        if let event = try? await self.dependencies.api.event(key: key) {
                            await MainActor.run { self.eventsCache[key] = event }
                        }
                    }
                case .team(let key) where teamsCache[key] == nil:
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        if let team = try? await self.dependencies.api.team(key: key) ?? nil {
                            await MainActor.run { self.teamsCache[key] = team }
                        }
                    }
                case .match(let key) where matchesCache[key] == nil:
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        if let match = try? await self.dependencies.api.match(key: key) ?? nil {
                            await MainActor.run { self.matchesCache[key] = match }
                        }
                    }
                default: break
                }
            }
        }
    }
}

// MARK: - Favorites

class MyTBAFavoritesViewController: MyTBATableViewController, Refreshable, Stateful {

    private let favoritesStore: FavoritesStore

    init(myTBA: MyTBA, favoritesStore: FavoritesStore, dependencies: Dependencies) {
        self.favoritesStore = favoritesStore
        super.init(myTBA: myTBA, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachStatefulDelegate()
    }

    override var currentItems: [MyTBAItem] {
        favoritesStore.favorites.compactMap { Self.item(for: $0.modelType, key: $0.modelKey) }
    }

    override func registerForStoreChanges() {
        observeNotification(name: .favoritesStoreDidChange) { [weak self] _ in
            Task { @MainActor in self?.storeDidChange() }
        }
    }

    override func performRemoteRefresh() async throws {
        let favorites: [MyTBAFavorite] = try await withCheckedThrowingContinuation { continuation in
            let operation = myTBA.fetchFavorites { models, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: models ?? [])
            }
            refreshOperationQueue.addOperation(operation)
        }
        await MainActor.run { favoritesStore.replaceAll(with: favorites) }
    }

    @objc func refresh() {
        guard myTBA.isAuthenticated else { return }
        refreshFromRemote { [weak self] in self?.markRefreshSuccessful() }
    }

    // MARK: - Refreshable

    var refreshKey: String? { MyTBAFavorite.arrayKey }
    var automaticRefreshInterval: DateComponents? { DateComponents(day: 1) }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { myTBA.isAuthenticated && favoritesStore.favorites.isEmpty }

    // MARK: - Stateful

    var noDataText: String? { "No favorites" }

    private static func item(for type: MyTBAModelType, key: String) -> MyTBAItem? {
        switch type {
        case .event: return .event(key: key)
        case .team: return .team(key: key)
        case .match: return .match(key: key)
        default: return nil
        }
    }
}

// MARK: - Subscriptions

class MyTBASubscriptionsViewController: MyTBATableViewController, Refreshable, Stateful {

    private let subscriptionsStore: SubscriptionsStore

    init(myTBA: MyTBA, subscriptionsStore: SubscriptionsStore, dependencies: Dependencies) {
        self.subscriptionsStore = subscriptionsStore
        super.init(myTBA: myTBA, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachStatefulDelegate()
    }

    override var currentItems: [MyTBAItem] {
        subscriptionsStore.subscriptions.compactMap { Self.item(for: $0.modelType, key: $0.modelKey) }
    }

    override func registerForStoreChanges() {
        observeNotification(name: .subscriptionsStoreDidChange) { [weak self] _ in
            Task { @MainActor in self?.storeDidChange() }
        }
    }

    override func performRemoteRefresh() async throws {
        let subs: [MyTBASubscription] = try await withCheckedThrowingContinuation { continuation in
            let operation = myTBA.fetchSubscriptions { models, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: models ?? [])
            }
            refreshOperationQueue.addOperation(operation)
        }
        await MainActor.run { subscriptionsStore.replaceAll(with: subs) }
    }

    @objc func refresh() {
        guard myTBA.isAuthenticated else { return }
        refreshFromRemote { [weak self] in self?.markRefreshSuccessful() }
    }

    // MARK: - Refreshable

    var refreshKey: String? { MyTBASubscription.arrayKey }
    var automaticRefreshInterval: DateComponents? { DateComponents(day: 1) }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { myTBA.isAuthenticated && subscriptionsStore.subscriptions.isEmpty }

    // MARK: - Stateful

    var noDataText: String? { "No subscriptions" }

    private static func item(for type: MyTBAModelType, key: String) -> MyTBAItem? {
        switch type {
        case .event: return .event(key: key)
        case .team: return .team(key: key)
        case .match: return .match(key: key)
        default: return nil
        }
    }
}

// MARK: - NotificationObservable helper

protocol NotificationObservable: AnyObject {}

extension NotificationObservable {
    func observeNotification(name: Notification.Name, handler: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: handler)
    }
}
