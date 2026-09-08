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

nonisolated enum SearchSection: String {
    case teams = "Teams"
    case events = "Events"
}

extension SearchSection: TableSectionTitleProviding {
    var headerTitle: String? { rawValue }
}

protocol SearchViewControllerDelegate: AnyObject {
    func eventSelected(eventKey: EventKey, name: String?)
    func teamSelected(teamKey: String, nickname: String?)
}

nonisolated enum SearchItem: Hashable {
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
    private var searchTask: Task<Void, Never>?
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
                let teamNumber = key.trimPrefix
                cell.viewModel = TeamCellViewModel(
                    teamNumber: teamNumber,
                    nickname: nickname.isEmpty ? "Team \(teamNumber)" : nickname,
                    location: nil
                )
                return cell
            }
        }
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
        searchTask?.cancel()
        let query = (searchText ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !query.isEmpty, let index else {
            dataSource.applySnapshotUsingReloadData(NSDiffableDataSourceSnapshot())
            return
        }

        let showTeams = scope.shouldShowTeams
        let showEvents = scope.shouldShowEvents
        searchTask = Task {
            let (teams, events) = await Self.results(
                in: index,
                query: query,
                teams: showTeams,
                events: showEvents
            )
            guard !Task.isCancelled else { return }
            show(teams: teams, events: events)
        }
    }

    private func show(teams: [SearchItem], events: [SearchItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        if !teams.isEmpty {
            snapshot.appendSections([.teams])
            snapshot.appendItems(teams, toSection: .teams)
        }
        if !events.isEmpty {
            snapshot.appendSections([.events])
            snapshot.appendItems(events, toSection: .events)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // `String.contains` across every team and event ever is tens of ms per keystroke; keep it
    // off the main actor.
    @concurrent
    private nonisolated static func results(
        in index: SearchIndex,
        query: String,
        teams showTeams: Bool,
        events showEvents: Bool
    ) async -> (teams: [SearchItem], events: [SearchItem]) {
        let teams =
            showTeams
            ? index.teams
                .filter { matches(team: $0, query: query) }
                .sorted { lhs, rhs in
                    let l = lhs.key.teamNumber ?? .max
                    let r = rhs.key.teamNumber ?? .max
                    return l < r
                }
                .map { SearchItem.team(key: $0.key, nickname: $0.nickname) }
            : []
        let events =
            showEvents
            ? index.events
                .filter { matches(event: $0, query: query) }
                .sorted { lhs, rhs in
                    let lYear = lhs.key.year ?? 0
                    let rYear = rhs.key.year ?? 0
                    if lYear != rYear { return lYear > rYear }
                    return lhs.name < rhs.name
                }
                .map { SearchItem.event(key: $0.key, name: $0.name) }
            : []
        return (teams, events)
    }

    private nonisolated static func matches(team: SearchIndex.TeamsPayloadPayload, query: String)
        -> Bool
    {
        let number = team.key.trimPrefix
        return number.hasPrefix(query) || team.nickname.lowercased().contains(query)
            || team.key.lowercased().contains(query)
    }

    private nonisolated static func matches(event: SearchIndex.EventsPayloadPayload, query: String)
        -> Bool
    {
        let display = eventDisplayName(key: event.key, name: event.name)
        return display.lowercased().contains(query) || event.key.lowercased().contains(query)
    }

    // Single source of truth for event row text so the search matcher operates on what the user sees —
    // event names from the API don't include the year, so without this typing "2026 michigan" wouldn't hit.
    private nonisolated static func eventDisplayName(key: EventKey, name: String) -> String {
        guard !name.isEmpty else { return key }
        guard let year = key.year else { return name }
        return "\(year) \(name)"
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

}

extension SearchViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchText = nil
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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
