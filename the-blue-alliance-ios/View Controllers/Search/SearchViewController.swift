import CoreData
import CoreSpotlight
import Foundation
import TBAData
import TBAKit
import UIKit

enum SearchScope: CaseIterable {
    case all
    case teams
    case events

    var title: String {
        switch self {
        case .all:
            return "All"
        case .events:
            return "Events"
        case .teams:
            return "Teams"
        }
    }

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

protocol SearchViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
    func teamSelected(_ team: Team)
}

class SearchViewController: TBATableViewController {

    private let searchService: SearchService

    weak var delegate: SearchViewControllerDelegate?

    var scope = SearchScope.all {
        didSet {
            updateQueue.addOperation {
                self.updateDataSource()
            }
        }
    }
    var searchText: String? = nil {
        didSet {
            search()
        }
    }
    var searchQuery: CSSearchQuery?

    var teams: Set<CSSearchableItem> = Set()
    var events: Set<CSSearchableItem> = Set()

    private let updateQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private var dataSource: TableViewDataSource<SearchSection, CSSearchableItem>!

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

        tableView.dataSource = tableViewDataSource
        setupDataSource()

        enableRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If our search service is refreshing, show our refresh indicator
        if let refreshOperation = searchService.refreshOperation {
            if refreshOperationQueue.operations.isEmpty {
                let operation = Operation()
                operation.addDependency(refreshOperation)
                addRefreshOperations([operation])
            } else {
                // Manually update our refresh control
                self.refreshControl?.endRefreshing()
                self.refreshControl?.beginRefreshing()
            }
        }
    }

    // MARK: Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<SearchSection, CSSearchableItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let contentType = item.attributeSet.contentType
            if contentType == Event.entityName {
                let name = item.attributeSet.displayName ?? item.attributeSet.alternateNames?.first ?? "---"
                let vm = EventCellViewModel(name: name, location: item.locationString, dateString: item.dateString)
                return SearchViewController.tableView(tableView, cellForEventModel: vm, at: indexPath)
            } else if contentType == Team.entityName {
                let teamNumber = item.attributeSet.teamNumber ?? item.attributeSet.alternateNames?.first ?? "---"
                let nickname = item.attributeSet.nickname ?? item.attributeSet.displayName ?? item.attributeSet.alternateNames?.last ?? "---"
                let vm = TeamCellViewModel(teamNumber: teamNumber, nickname: nickname, location: item.locationString)
                return SearchViewController.tableView(tableView, cellForTeamModel: vm, at: indexPath)
            }
            return UITableViewCell()
        })
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func search() {
        searchQuery?.cancel() // Cancel ongoing query
        updateQueue.cancelAllOperations()

        // If our search text is nil or empty, show an empty table view
        guard let searchText = searchText, !searchText.isEmpty else {
            updateQueue.addOperation {
                self.clearDataSource()
            }
            return
        }

        // Escape user query
        let escapedSearchText = searchText.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")

        // Basic attributes
        var attributes = [
            #keyPath(CSSearchableItemAttributeSet.displayName),
            #keyPath(CSSearchableItemAttributeSet.alternateNames)
        ]
        // Content type, so we can identify the searchablte item as an Event or Team
        attributes.append(#keyPath(CSSearchableItemAttributeSet.contentType))
        // Location-related information, for Event and Team
        attributes.append(contentsOf: [
            #keyPath(CSSearchableItemAttributeSet.city),
            #keyPath(CSSearchableItemAttributeSet.country),
            #keyPath(CSSearchableItemAttributeSet.stateOrProvince),
            #keyPath(CSSearchableItemAttributeSet.namedLocation)
        ])
        // Date-related information, for Event
        attributes.append(contentsOf: [
            #keyPath(CSSearchableItemAttributeSet.startDate),
            #keyPath(CSSearchableItemAttributeSet.endDate)
        ])
        // Custom keys for Team
        attributes.append(contentsOf: [
            #keyPath(CSSearchableItemAttributeSet.teamNumber),
            #keyPath(CSSearchableItemAttributeSet.nickname)
        ])

        // Teams
        let teamsQuery = [
            "\(#keyPath(CSSearchableItemAttributeSet.teamNumber)) == \"\(escapedSearchText)*\"", // team number begins with
            "\(#keyPath(CSSearchableItemAttributeSet.nickname)) == \"\(escapedSearchText)*\"cdwt",  // nickname contains
            "\(#keyPath(CSSearchableItemAttributeSet.city)) == \"\(escapedSearchText)*\"cdwt",      // city contains
        ]
        let teamsQueryString = "\(#keyPath(CSSearchableItemAttributeSet.contentType)) == '\(Team.entityName)' && (\(teamsQuery.joined(separator: " || ")))"

        // Events
        let eventsQuery = [
            "\(#keyPath(CSSearchableItemAttributeSet.alternateNames)) == \"\(escapedSearchText)*\"cdwt", // team key/short name/name contains
        ]
        let eventsQueryString = "\(#keyPath(CSSearchableItemAttributeSet.contentType)) == '\(Event.entityName)' && (\(eventsQuery.joined(separator: " || ")))"

        let queryString = "(\(teamsQueryString)) || (\(eventsQueryString))"
        let newQuery = CSSearchQuery(queryString: queryString, attributes: attributes)
        searchQuery = newQuery

        var teams: [CSSearchableItem] = []
        var events: [CSSearchableItem] = []

        newQuery.foundItemsHandler = { (items: [CSSearchableItem]) in
            teams.append(contentsOf: items.filter { $0.attributeSet.contentType == Team.entityName })
            events.append(contentsOf: items.filter { $0.attributeSet.contentType == Event.entityName })
        }

        newQuery.completionHandler = { (error: Error?) in
            self.teams = Set(teams)
            self.events = Set(events)

            self.updateQueue.addOperation {
                self.updateDataSource()
            }
        }

        newQuery.start()
    }

    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        if scope.shouldShowTeams, !teams.isEmpty {
            snapshot.appendSections([.teams])
            snapshot.appendItems(teams.sorted(by: { (lhs: CSSearchableItem, rhs: CSSearchableItem) -> Bool in
                guard let lhsTeamNumber = lhs.attributeSet.teamNumber, let lhsInt = Int(lhsTeamNumber) else {
                    return true
                }
                guard let rhsTeamNumber = rhs.attributeSet.teamNumber, let rhsInt = Int(rhsTeamNumber) else {
                    return true
                }
                return lhsInt < rhsInt
            }), toSection: .teams)
        }

        if scope.shouldShowEvents, !events.isEmpty {
            snapshot.appendSections([.events])
            snapshot.appendItems(events.sorted(by: { (lhs: CSSearchableItem, rhs: CSSearchableItem) -> Bool in
                guard let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate else {
                    return false
                }
                // Reverse sort events so newer events are at the start
                guard lhsStartDate.year == rhsStartDate.year else {
                    return lhsStartDate.year > rhsStartDate.year
                }
                guard lhsStartDate == rhsStartDate else {
                    return lhsStartDate < rhsStartDate
                }
                guard let lhsDisplayName = lhs.attributeSet.displayName, let rhsDisplayName = rhs.attributeSet.displayName else {
                    return false
                }
                return lhsDisplayName < rhsDisplayName
            }), toSection: .events)
        }

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    private func clearDataSource() {
        self.teams = Set()
        self.events = Set()

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

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        guard let uri = URL(string: item.uniqueIdentifier) else {
            return
        }

        guard let objectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uri) else {
            return
        }

        let object = persistentContainer.viewContext.object(with: objectID)
        if let team = object as? Team {
            delegate?.teamSelected(team)
        } else if let event = object as?  Event {
            delegate?.eventSelected(event)
        }
    }

    // MARK: - TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]
        return section.rawValue
    }

}

extension SearchViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        searchQuery?.cancel()
        updateQueue.cancelAllOperations()
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

    var refreshKey: String? {
        return nil
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        let refreshOperation = searchService.refresh(userInitiated: true)

        let operation = Operation()
        operation.addDependency(refreshOperation)

        addRefreshOperations([operation])
    }

}

extension SearchViewController: Stateful {

    var noDataText: String? {
        // If we have no search text - don't show a no data view
        guard let searchText = searchText, !searchText.isEmpty else {
            return nil
        }
        // If we're between states while searching, don't show a no data view
        guard let searchQuery = searchQuery, !searchQuery.isCancelled else {
            return nil
        }
        return "No results found"
    }

}
