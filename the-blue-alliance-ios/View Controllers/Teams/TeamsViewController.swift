import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

protocol TeamsRefreshProvider {
    var operationQueue: OperationQueue { get }
    func refreshTeams(userInitiated: Bool) -> Operation?
}

protocol TeamsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

protocol TeamsViewControllerDataSourceConfiguration {
    var fetchRequestPredicate: NSPredicate? { get }
}

/**
 TeamsViewController is an abstract view controller which should be subclassed by other view controllers
 that display a list of teams, given a set of information.

 See: EventTeamsViewController, DistrictTeamsViewController
 */
class TeamsViewController: TBASearchableTableViewController, Refreshable, Stateful, TeamsViewControllerDataSourceConfiguration {

    private var refreshProvider: TeamsRefreshProvider!
    private let showSearch: Bool

    weak var delegate: TeamsViewControllerDelegate?

    private var tableViewDataSource: TableViewDataSource<String, Team>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Team>!

    init(refreshProvider: TeamsRefreshProvider? = nil, showSearch: Bool = true, dependencies: Dependencies) {
        self.showSearch = showSearch

        super.init(dependencies: dependencies)

        self.refreshProvider = refreshProvider ?? self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if showSearch {
            setupSearch()
        }

        tableView.registerReusableCell(TeamTableViewCell.self)

        tableView.dataSource = tableViewDataSource
        setupDataSource()
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let team = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.teamSelected(team)
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return "teams"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(month: 1)
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        guard let refreshOperation = refreshProvider.refreshTeams(userInitiated: true) else {
            #if DEBUG
            fatalError("refreshProvider.refreshTeams is not returning a refresh operation")
            #else
            return
            #endif
        }

        let operation = BlockOperation {
            self.markRefreshSuccessful()
        }
        operation.addDependency(refreshOperation)

        var operations: [Operation] = [operation]
        if !refreshProvider.operationQueue.operations.contains(refreshOperation) {
            operations.append(refreshOperation)
        }

        addRefreshOperations(operations)
    }

    // MARK: - Stateful

    var noDataText: String? {
        return "No teams"
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, Team>(tableView: tableView) { (tableView, indexPath, team) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(team: team)
            return cell
        }
        self.tableViewDataSource = TableViewDataSource(dataSource: dataSource)
        self.tableViewDataSource.delegate = self
        self.tableViewDataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [
            Team.teamNumberSortDescriptor()
        ]
        fetchRequest.fetchBatchSize = 50
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    override func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Team>) {
        let searchPredicate: NSPredicate? = {
            guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
                return nil
            }
            return Team.searchPredicate(searchText: searchText)
        }()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            searchPredicate,
            fetchRequestPredicate,
            Team.populatedTeamsPredicate()
        ].compactMap({ $0 }))
    }

    // MARK: - TeamsViewControllerDataSourceConfiguration

    var fetchRequestPredicate: NSPredicate? {
        return nil
    }

}

extension TBASearchableTableViewController: TeamsRefreshProvider {

    var operationQueue: OperationQueue {
        return refreshOperationQueue
    }

    func refreshTeams(userInitiated: Bool) -> Operation? {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeams() { [unowned self] (result, notModified) in
            guard case .success(let teams) = result, !notModified else {
                return
            }

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(teams, in: context)
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            }, errorRecorder: errorRecorder)
        }
        return operation
    }

}
