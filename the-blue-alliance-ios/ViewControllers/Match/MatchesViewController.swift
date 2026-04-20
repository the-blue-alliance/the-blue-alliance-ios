import Foundation
import MyTBAKit
import TBAAPI
import UIKit

protocol MatchesViewControllerDelegate: AnyObject {
    func showFilter()
    func matchSelected(matchKey: String)
}

class MatchesViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: MatchesViewControllerDelegate?
    var query: MatchQueryOptions = MatchQueryOptions.defaultQuery()

    private let eventKey: String
    private let teamKey: String?

    private var dataSource: TableViewDataSource<String, Match>!

    private var allMatches: [Match] = []
    private var favoriteTeamKeys: [String] = []

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

    init(eventKey: String, teamKey: String? = nil, dependencies: Dependencies) {
        self.eventKey = eventKey
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
        dataSource = TableViewDataSource<String, Match>(tableView: tableView) {
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
            cell.viewModel = MatchViewModel(apiMatch: match, baseTeamKeys: Array(baseTeamKeys))
            cell.accessibilityIdentifier = "match.\(match.key)"
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func applyMatches(_ matches: [Match]) {
        let filtered = matches.filter(
            for: teamKey,
            favoriteTeamKeys: query.filter.favorites ? favoriteTeamKeys : nil
        )
        let sorted = filtered.sorted(ascending: !query.sort.reverse)

        var snapshot = NSDiffableDataSourceSnapshot<String, Match>()
        // Group by comp-level string so sections mirror the old FRC behavior.
        var sectionOrder: [String] = []
        var grouped: [String: [Match]] = [:]
        for match in sorted {
            let key = match.compLevelString
            if grouped[key] == nil {
                sectionOrder.append(key)
                grouped[key] = []
            }
            grouped[key]?.append(match)
        }
        for section in sectionOrder {
            snapshot.appendSections([section])
            snapshot.appendItems(grouped[section] ?? [], toSection: section)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        guard let firstMatch = dataSource.itemIdentifier(for: IndexPath(row: 0, section: section))
        else {
            return "Matches"
        }
        return "\(firstMatch.compLevel.level) Matches"
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let match = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.matchSelected(matchKey: match.key)
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
            let fetched = try await self.dependencies.api.eventMatches(key: self.eventKey)
            self.allMatches = fetched
            self.applyMatches(fetched)
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
