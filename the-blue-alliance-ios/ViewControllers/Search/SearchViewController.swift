import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit
import TBAAPI

enum SearchScope: String, CaseIterable {
    case all, events, teams

    var shouldShowTeams: Bool {
        return self == .all || self == .teams
    }

    var shouldShowEvents: Bool {
        return self == .all || self == .events
    }
}

enum SearchSection: String {
    case teams = "Teams"
    case events = "Events"
}

private struct SearchItem: Hashable {
    enum SearchItemType {
        case event, team
    }
    let type: SearchItemType
    let key: String
    let name: String
}

protocol SearchViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
    func teamSelected(_ team: Team)
}

class SearchViewController: TBATableViewController {

    weak var delegate: SearchViewControllerDelegate?

    private var events: [SearchItem] {
        guard let searchIndex = searchService.searchIndex else {
            return []
        }
        let searchItems = searchIndex.events.map { SearchItem(type: .event, key: $0.key, name: $0.name) }
        guard let searchText else {
            return searchItems
        }
        return searchItems.filter { event in
            return event.name.contains(searchText)
        }
    }

    private var teams: [SearchItem] {
        guard let searchIndex = searchService.searchIndex else {
            return []
        }
        let searchItems = searchIndex.teams.map { SearchItem(type: .team, key: $0.key, name: $0.nickname) }
        guard let searchText else {
            return searchItems
        }
        return searchItems.filter { team in
            return team.key.trimPrefix("frc").starts(with: searchText) || team.name.contains(searchText)
        }
    }

    var scope = SearchScope.all {
        didSet {
            updateDataSource()
        }
    }
    var searchText: String? = nil {
        didSet {
            search()
        }
    }

    private var dataSource: TableViewDataSource<SearchSection, SearchItem>!

    let searchService: SearchService

    init(searchService: SearchService, dependencies: Dependencies) {
        self.searchService = searchService

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        enableRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
    }

    // MARK: Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<SearchSection, SearchItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier.type {
            case .event:
                let name = itemIdentifier.name
                let vm = EventCellViewModel(name: name, location: nil, dateString: nil)
                return SearchViewController.tableView(tableView, cellForEventModel: vm, at: indexPath)
            case .team:
                let teamNumber = itemIdentifier.key.trimPrefix("frc")
                let vm = TeamCellViewModel(teamNumber: teamNumber, nickname: itemIdentifier.name, location: nil)
                return SearchViewController.tableView(tableView, cellForTeamModel: vm, at: indexPath)
            }
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func search() {
        if let searchText = searchText, !searchText.isEmpty {
            updateDataSource()
        } else {
            clearDataSource()
        }
    }

    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        if scope.shouldShowTeams, !teams.isEmpty {
            snapshot.appendSections([.teams])
            snapshot.appendItems(teams.sorted(using: KeyPathComparator(\.key)), toSection: .teams)
        }

        if scope.shouldShowEvents, !events.isEmpty {
            snapshot.appendSections([.events])
            snapshot.appendItems(events.sorted(using: KeyPathComparator(\.key)), toSection: .events)
        }

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    private func clearDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    // MARK: - Cell Methods

    private static func tableView(_ tableView: UITableView, cellForEventModel vm: EventCellViewModel, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
        cell.viewModel = vm
        return cell
    }

    private static func tableView(_ tableView: UITableView, cellForTeamModel vm: TeamCellViewModel, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
        cell.viewModel = vm
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Push
    }

    // MARK: - TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]
        return section.rawValue.capitalized
    }
}

extension SearchViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        searchService.refreshTask?.cancel()
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
        guard selectedScope < cases.count else {
            return
        }
        scope = SearchScope.allCases[selectedScope]
    }

}

extension SearchViewController: Refreshable {

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        Task {
            defer {
                updateRefresh()
                updateDataSource()
            }
            await searchService.fetchSearchIndex()
        }
    }

}

extension SearchViewController: Stateful {

    var noDataText: String? {
        // If we have no search text - don't show a no data view
        guard let searchText = searchText, !searchText.isEmpty else {
            return nil
        }
        return "No results found"
    }

}
