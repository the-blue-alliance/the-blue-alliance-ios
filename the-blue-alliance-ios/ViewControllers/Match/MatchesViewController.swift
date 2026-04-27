import Foundation
import MyTBAKit
import TBAAPI
import UIKit

protocol MatchesViewControllerDelegate: AnyObject {
    func showFilter()
    func matchSelected(_ match: Match)
}

class MatchesViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: MatchesViewControllerDelegate?
    var query: MatchQueryOptions = MatchQueryOptions.defaultQuery()

    private var state: EventState
    private let teamKey: String?

    private var dataSource: TableViewDataSource<MatchSection, Match>!

    private var allMatches: [Match] = []
    private var favoriteTeamKeys: [String] = []
    private var allianceLookup: AllianceLookup?

    lazy var matchQueryBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage.sortFilterIcon,
            style: .plain,
            target: self,
            action: #selector(showFilter)
        )
    }()
    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [matchQueryBarButtonItem]
    }

    // MARK: - Init

    convenience init(event: Event, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .event(event), teamKey: teamKey, dependencies: dependencies)
    }

    // For callers that only have the event key (e.g. TeamAtEventViewController).
    // refresh() upgrades state to `.event` so playoff-aware sectioning kicks in.
    convenience init(eventKey: EventKey, teamKey: String? = nil, dependencies: Dependencies) {
        self.init(state: .key(eventKey), teamKey: teamKey, dependencies: dependencies)
    }

    private init(state: EventState, teamKey: String?, dependencies: Dependencies) {
        self.state = state
        self.teamKey = teamKey

        super.init(dependencies: dependencies)
    }

    private var favoritesStore: FavoritesStore { myTBAStores.favorites }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(MatchTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource

        updateInterface()
    }

    private func updateInterface() {
        if query.isDefault {
            matchQueryBarButtonItem.image = UIImage.sortFilterIcon
        } else {
            matchQueryBarButtonItem.image = UIImage.sortFilterIconActive
        }
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<MatchSection, Match>(tableView: tableView) {
            [weak self] tableView, indexPath, match in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell

            var baseTeamKeys: Set<String> = Set()
            if let teamKey = self?.teamKey {
                baseTeamKeys.insert(teamKey)
            }
            if let query = self?.query, query.filter.favorites,
                let favoriteTeamKeys = self?.favoriteTeamKeys
            {
                baseTeamKeys.formUnion(favoriteTeamKeys)
            }
            if let event = self?.state.event {
                cell.viewModel = MatchViewModel(
                    match: match,
                    event: event,
                    allianceLookup: self?.allianceLookup,
                    baseTeamKeys: Array(baseTeamKeys)
                )
            } else {
                cell.viewModel = MatchViewModel(
                    withoutEventContextFor: match,
                    baseTeamKeys: Array(baseTeamKeys)
                )
            }
            cell.accessibilityIdentifier = "match.\(match.key)"
            return cell
        }
        dataSource.statefulDelegate = self
    }

    private func applyMatches(_ matches: [Match]) {
        let filtered = matches.filter(
            for: teamKey,
            favoriteTeamKeys: query.filter.favorites ? favoriteTeamKeys : nil
        )
        let sorted = filtered.sorted(ascending: !query.sort.reverse)

        var snapshot = NSDiffableDataSourceSnapshot<MatchSection, Match>()
        var grouped: [MatchSection: [Match]] = [:]
        let playoffType = state.event?.playoffTypeEnum
        for match in sorted {
            let section = MatchSection.section(for: match, playoffType: playoffType)
            grouped[section, default: []].append(match)
        }
        let sortedSections = grouped.keys.sorted(by: query.sort.reverse ? (>) : (<))
        for section in sortedSections {
            snapshot.appendSections([section])
            snapshot.appendItems(grouped[section] ?? [], toSection: section)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let match = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.matchSelected(match)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
        -> CGFloat
    {
        return 30.0
    }

    // MARK: - Public Methods

    func updateWithQuery(query: MatchQueryOptions) {
        self.query = query
        favoriteTeamKeys = favoritesStore.favoriteTeamKeys()

        updateInterface()
        applyMatches(allMatches)
    }

    // MARK: - Interface Methods

    @objc func showFilter(_ sender: UIBarButtonItem) {
        delegate?.showFilter()
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool {
        if !query.filter.isDefault { return false }
        return allMatches.isEmpty
    }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let key = self.state.key
            async let matchesTask = self.dependencies.api.eventMatches(key: key)
            async let alliancesTask: [EliminationAlliance]?? = {
                try? await self.dependencies.api.eventAlliances(key: key)
            }()
            async let eventTask: Event? = {
                try? await self.dependencies.api.event(key: key)
            }()
            self.allMatches = try await matchesTask
            if let alliancesResult = await alliancesTask {
                self.allianceLookup = alliancesResult.map(AllianceLookup.init)
            }
            if let event = await eventTask {
                self.state = .event(event)
            }
            self.applyMatches(self.allMatches)
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        if query.isDefault {
            return "No matches for event"
        } else {
            return "No matches matching filter options"
        }
    }
}

extension MatchesViewController {
    // Placeholder so `MatchesViewControllerQueryable`'s `showFilter()` still compiles.
}

private extension Array where Element == Match {
    func filter(for teamKey: String?, favoriteTeamKeys: [String]?) -> [Match] {
        var results = self
        if let teamKey {
            results = results.filter { $0.allTeamKeys.contains(teamKey) }
        }
        if let favoriteTeamKeys, !favoriteTeamKeys.isEmpty {
            let favSet = Set(favoriteTeamKeys)
            results = results.filter { match in
                match.allTeamKeys.contains(where: favSet.contains)
            }
        }
        return results
    }

    func sorted(ascending: Bool) -> [Match] {
        sorted { lhs, rhs in
            if lhs.compLevelSortOrder != rhs.compLevelSortOrder {
                return ascending
                    ? lhs.compLevelSortOrder < rhs.compLevelSortOrder
                    : lhs.compLevelSortOrder > rhs.compLevelSortOrder
            }
            if lhs.setNumber != rhs.setNumber {
                return ascending ? lhs.setNumber < rhs.setNumber : lhs.setNumber > rhs.setNumber
            }
            return ascending ? lhs.matchNumber < rhs.matchNumber : lhs.matchNumber > rhs.matchNumber
        }
    }
}

protocol MatchesViewControllerQueryable: ContainerViewController, MatchQueryOptionsDelegate {
    var myTBA: any MyTBAProtocol { get }
    var matchesViewController: MatchesViewController { get }

    func showFilter()
}

extension MatchesViewControllerQueryable {

    func showFilter() {
        let queryViewController = MatchQueryOptionsViewController(
            query: matchesViewController.query,
            dependencies: dependencies
        )
        queryViewController.delegate = self

        let nav = UINavigationController(rootViewController: queryViewController)
        nav.modalPresentationStyle = .formSheet

        navigationController?.present(nav, animated: true, completion: nil)
    }

    func updateQuery(query: MatchQueryOptions) {
        matchesViewController.updateWithQuery(query: query)
    }

}
