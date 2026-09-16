import Foundation
import MyTBAKit
import Observation
import TBAAPI
import TBAUtils
import UIKit

protocol DashboardViewControllerDelegate: AnyObject {
    func phaseUpdated(_ phase: DashboardPhase)
    func teamAtEventSelected(teamKey: String, eventKey: EventKey)
    func eventSelected(_ event: Event)
    func matchSelected(_ match: Match, teamKey: String?)
    func tabSelected(_ type: RootType)
}

nonisolated struct DashboardSection: Hashable {
    let id: String
    let title: String?
}

nonisolated enum DashboardItem: Hashable {
    case summary(DashboardSeasonViewModel, action: DashboardAction?)
    case teamHeader(TeamAtEventCard)
    case row(DashboardRow)
    case upNext(event: Event, teamKeys: [String], DashboardUpNextViewModel)
    case tiles(id: String, [DashboardTile])
}

class DashboardViewController: TBATableViewController, Refreshable {

    weak var delegate: (any DashboardViewControllerDelegate)?

    #if DEBUG
        let debugOverrides = DashboardDebugOverrides(arguments: ProcessInfo.processInfo.arguments)
    #endif

    private lazy var dataSource: TableViewDataSource<DashboardSection, DashboardItem> =
        makeDataSource()
    private var statusObservation: Task<Void, Never>?
    private var favoritesObservation: Task<Void, Never>?
    private var foregroundObserver: NotificationCenter.ObservationToken?

    init(dependencies: Dependencies) {
        super.init(style: .insetGrouped, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(DashboardSeasonTableViewCell.self)
        tableView.registerReusableCell(DashboardTeamHeaderTableViewCell.self)
        tableView.registerReusableCell(DashboardListTableViewCell.self)
        tableView.registerReusableCell(DashboardUpNextTableViewCell.self)
        tableView.registerReusableCell(DashboardTilesTableViewCell.self)
        tableView.registerReusableHeaderFooterView(DashboardSectionHeaderView.self)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 44

        tableView.dataSource = dataSource

        observeRefreshTriggers()
    }

    isolated deinit {
        statusObservation?.cancel()
        favoritesObservation?.cancel()
    }

    // MARK: - Navigatable

    #if DEBUG
        override var additionalRightBarButtonItems: [UIBarButtonItem] {
            [
                UIBarButtonItem(
                    image: UIImage(systemName: "ladybug"),
                    primaryAction: UIAction { [weak self] _ in self?.presentDebugInspector() }
                )
            ]
        }

        private func presentDebugInspector() {
            let inspector = DashboardDebugViewController(
                overrides: debugOverrides,
                onChange: { [weak self] in self?.refresh() },
                dependencies: dependencies
            )
            present(UINavigationController(rootViewController: inspector), animated: true)
        }
    #endif

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { dataSource.isDataSourceEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let now = now
            let result = await DashboardFeedBuilder(api: dependencies.api).load(
                follows: follows,
                status: statusService.status,
                isSignedIn: isSignedIn,
                now: now
            )
            delegate?.phaseUpdated(result.phase)
            apply(result.cards, now: now)
        }
    }

    private var follows: DashboardFeedBuilder.Follows {
        #if DEBUG
            return debugOverrides.effectiveFollows(favorites: myTBAStores.favorites)
        #else
            return .init(favorites: myTBAStores.favorites.favorites)
        #endif
    }

    private var isSignedIn: Bool {
        #if DEBUG
            return debugOverrides.effectiveSignedIn(authService: dependencies.authService)
        #else
            return dependencies.authService.isSignedIn
        #endif
    }

    private var now: Date {
        #if DEBUG
            return debugOverrides.effectiveNow()
        #else
            return Date()
        #endif
    }

    // The first load usually races the launch-time /status fetch, and the season depends on it.
    // Favorites change when myTBA syncs on sign-in or foreground, and the day may have rolled over
    // while the app was in the background.
    private func observeRefreshTriggers() {
        let statusService = dependencies.statusService
        statusObservation = Task { [weak self] in
            for await _ in Observations({ statusService.status }) {
                self?.refresh()
            }
        }
        let favoritesStore = myTBAStores.favorites
        favoritesObservation = Task { [weak self] in
            for await _ in Observations({ favoritesStore.favorites }) {
                self?.refresh()
            }
        }
        foregroundObserver = NotificationCenter.default.addForegroundObserver { [weak self] in
            self?.refresh()
        }
    }

    var noDataText: String? { "Nothing here yet. Use Search to find teams and events." }

    // MARK: - Snapshot

    private func apply(_ cards: [DashboardCard], now: Date) {
        var snapshot = NSDiffableDataSourceSnapshot<DashboardSection, DashboardItem>()
        for (section, items) in DashboardRows.sections(for: cards, now: now) where !items.isEmpty {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Data Source

    private func makeDataSource() -> TableViewDataSource<DashboardSection, DashboardItem> {
        let dataSource = TableViewDataSource<DashboardSection, DashboardItem>(tableView: tableView)
        {
            [weak self] tableView, indexPath, item in
            switch item {
            case .summary(let viewModel, _):
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as DashboardSeasonTableViewCell
                cell.viewModel = viewModel
                return cell
            case .teamHeader(let hero):
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as DashboardTeamHeaderTableViewCell
                cell.viewModel = DashboardTeamHeaderViewModel(
                    teamNumber: hero.team.teamNumber,
                    nickname: hero.team.displayNickname,
                    eventName: hero.event.safeShortName,
                    eventDetail: [hero.event.dateString, hero.event.locationString]
                        .compactMap { $0 }.joined(separator: " · "),
                    avatar: hero.avatarBase64.flatMap { Data(base64Encoded: $0) }
                        .flatMap(UIImage.init(data:))
                )
                return cell
            case .row(let row):
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as DashboardListTableViewCell
                cell.configure(row)
                return cell
            case .upNext(_, _, let viewModel):
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as DashboardUpNextTableViewCell
                cell.viewModel = viewModel
                return cell
            case .tiles(_, let tiles):
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as DashboardTilesTableViewCell
                cell.tiles = tiles
                cell.tileTapped = { tile in self?.perform(.tab(tile.tab)) }
                return cell
            }
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
        -> UIView?
    {
        guard let dashboardSection = dataSource.sectionIdentifier(for: section),
            let title = dashboardSection.title
        else { return nil }
        let header: DashboardSectionHeaderView? = tableView.dequeueReusableHeaderFooterView()
        header?.title = title
        return header
    }

    // Keep the standard grouped headers; the base class paints the app's plain-table bands.
    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {}

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .summary(_, let action):
            if let action { perform(action) }
        case .teamHeader(let hero):
            perform(.teamAtEvent(teamKey: hero.team.key, eventKey: hero.event.key))
        case .row(let row):
            if let action = row.action { perform(action) }
        case .upNext(let event, let teamKeys, _):
            if teamKeys.count == 1, let teamKey = teamKeys.first {
                perform(.teamAtEvent(teamKey: teamKey, eventKey: event.key))
            } else {
                perform(.event(event))
            }
        case .tiles:
            break
        }
    }

    private func perform(_ action: DashboardAction) {
        switch action {
        case .teamAtEvent(let teamKey, let eventKey):
            delegate?.teamAtEventSelected(teamKey: teamKey, eventKey: eventKey)
        case .event(let event):
            delegate?.eventSelected(event)
        case .match(let match, let teamKey):
            delegate?.matchSelected(match, teamKey: teamKey)
        case .tab(let type):
            delegate?.tabSelected(type)
        }
    }

}

extension DashboardFeedBuilder.Follows {
    init(favorites: [MyTBAFavorite]) {
        self.init(
            teamKeys: favorites.filter { $0.modelType == .team }.map(\.modelKey),
            eventKeys: favorites.filter { $0.modelType == .event }.map(\.modelKey)
        )
    }
}
