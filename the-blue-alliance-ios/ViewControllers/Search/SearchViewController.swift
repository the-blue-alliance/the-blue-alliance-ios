import Foundation
import TBAAPI
import UIKit

enum SearchScope: CaseIterable {
    case all
    case teams
    case events

    var title: String {
        switch self {
        case .all: return "All"
        case .events: return "Events"
        case .teams: return "Teams"
        }
    }

    var shouldShowTeams: Bool { self == .all || self == .teams }
    var shouldShowEvents: Bool { self == .all || self == .events }
}

enum SearchSection: String {
    case teams = "Teams"
    case events = "Events"
}

protocol SearchViewControllerDelegate: AnyObject {
    func eventSelected(eventKey: String, name: String?)
    func teamSelected(teamKey: String, nickname: String?)
}

enum SearchItem: Hashable {
    case event(key: String, name: String)
    case team(key: String, nickname: String)
}

class SearchViewController: TBATableViewController {

    weak var delegate: SearchViewControllerDelegate?

    var scope = SearchScope.all {
        didSet { updateSnapshot() }
    }
    var searchText: String? = nil {
        didSet { updateSnapshot() }
    }

    private var index: SearchIndex?
    private var dataSource: TableViewDataSource<SearchSection, SearchItem>!

    init(dependencies: Dependencies) {
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.navigationBarTintColor
        tableView.backgroundColor = .systemGroupedBackground

        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource

        enableRefreshing()

        loadIndex()
    }

    // MARK: Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<SearchSection, SearchItem>(tableView: tableView) {
            tableView,
            indexPath,
            item in
            switch item {
            case .event(let key, let name):
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
                cell.viewModel = EventCellViewModel(
                    name: SearchViewController.eventDisplayName(key: key, name: name),
                    location: nil,
                    dateString: nil
                )
                return cell
            case .team(let key, let nickname):
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
                let teamNumber = key.trimFRCPrefix
                cell.viewModel = TeamCellViewModel(
                    teamNumber: teamNumber,
                    nickname: nickname.isEmpty ? "Team \(teamNumber)" : nickname,
                    location: nil
                )
                return cell
            }
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    // MARK: - Search

    private func loadIndex() {
        runRefresh { [weak self] in
            guard let self else { return }
            self.index = try await self.dependencies.api.getSearchIndex()
            self.updateSnapshot()
        }
    }

    private func updateSnapshot() {
        let query = (searchText ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()

        guard !query.isEmpty, let index else {
            dataSource.applySnapshotUsingReloadData(snapshot)
            return
        }

        if scope.shouldShowTeams {
            let teams = index.teams
                .filter { matches(team: $0, query: query) }
                .sorted { lhs, rhs in
                    let l = lhs.key.teamNumber ?? .max
                    let r = rhs.key.teamNumber ?? .max
                    return l < r
                }
                .map { SearchItem.team(key: $0.key, nickname: $0.nickname) }
            if !teams.isEmpty {
                snapshot.appendSections([.teams])
                snapshot.appendItems(teams, toSection: .teams)
            }
        }

        if scope.shouldShowEvents {
            let events = index.events
                .filter { matches(event: $0, query: query) }
                .sorted { lhs, rhs in
                    let lYear = Int(lhs.key.prefix(4)) ?? 0
                    let rYear = Int(rhs.key.prefix(4)) ?? 0
                    if lYear != rYear { return lYear > rYear }
                    return lhs.name < rhs.name
                }
                .map { SearchItem.event(key: $0.key, name: $0.name) }
            if !events.isEmpty {
                snapshot.appendSections([.events])
                snapshot.appendItems(events, toSection: .events)
            }
        }

        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    private func matches(team: SearchIndex.TeamsPayloadPayload, query: String) -> Bool {
        let number = team.key.trimFRCPrefix
        return number.hasPrefix(query) || team.nickname.lowercased().contains(query)
            || team.key.lowercased().contains(query)
    }

    private func matches(event: SearchIndex.EventsPayloadPayload, query: String) -> Bool {
        let display = SearchViewController.eventDisplayName(key: event.key, name: event.name)
        return display.lowercased().contains(query) || event.key.lowercased().contains(query)
    }

    // Single source of truth for event row text so the search matcher operates on what the user sees —
    // event names from the API don't include the year, so without this typing "2026 michigan" wouldn't hit.
    private static func eventDisplayName(key: String, name: String) -> String {
        guard !name.isEmpty else { return key }
        return "\(key.prefix(4)) \(name)"
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .event(let key, let name): delegate?.eventSelected(eventKey: key, name: name)
        case .team(let key, let nickname): delegate?.teamSelected(teamKey: key, nickname: nickname)
        }
    }

    override func title(forSection section: Int) -> String? {
        dataSource.snapshot().sectionIdentifiers[section].rawValue
    }

}

extension SearchViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchText = nil
    }
}

extension SearchViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let cases = SearchScope.allCases
        guard selectedScope < cases.count else { return }
        scope = cases[selectedScope]
    }
}

extension SearchViewController: Refreshable {
    var isDataSourceEmpty: Bool { dataSource.isDataSourceEmpty }

    func refresh() {
        loadIndex()
    }
}

extension SearchViewController: Stateful {
    var noDataText: String? {
        guard let searchText = searchText, !searchText.isEmpty else { return nil }
        return "No results found"
    }
}
