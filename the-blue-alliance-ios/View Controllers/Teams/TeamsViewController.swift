import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

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
class TeamsViewController: TBATableViewController, Refreshable, Stateful, TeamsViewControllerDataSourceConfiguration {

    weak var delegate: TeamsViewControllerDelegate?

    private var dataSource: TableViewDataSource<String, Team>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Team>!

    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.tabBarTintColor
        return searchController
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(TeamTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource

        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = UIView() // Hack to fix white background when refreshing in dark mode

        // Used to make sure the UISearchBar stays in our root VC (this VC) when presented and doesn't overlay in push
        definesPresentationContext = true
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let team = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.teamSelected(team)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let text = searchController.searchBar.text, text.isEmpty, searchController.isActive {
            searchController.isActive = false
        }
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
        var finalOperation: Operation!

        var op: TBAKitOperation!
        op = fetchAllTeams(operationChanged: { [unowned self] (operation, page, teams) in
            finalOperation.addDependency(operation)
            self.refreshOperationQueue.addOperations([operation], waitUntilFinished: false)

            let previousOperation = op
            op = operation

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(teams, page: page, in: context)
            }, saved: {
                self.tbaKit.storeCacheHeaders(previousOperation!)
            }, errorRecorder: Crashlytics.sharedInstance())
        }) { (error) in
            if error == nil {
                self.markRefreshSuccessful()
            }
        }
        finalOperation = addRefreshOperations([op])
    }

    func fetchAllTeams(operationChanged: @escaping (TBAKitOperation, Int, [TBATeam]) -> Void, completion: @escaping (Error?) -> Void) -> TBAKitOperation {
        return fetchAllTeams(operationChanged: operationChanged, page: 0, completion: completion)
    }

    private func fetchAllTeams(operationChanged: @escaping (TBAKitOperation, Int, [TBATeam]) -> Void, page: Int, completion: @escaping (Error?) -> Void) -> TBAKitOperation {
        return tbaKit.fetchTeams(page: page) { (result, notModified) in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let teams):
                if teams.isEmpty {
                    completion(nil)
                } else {
                    operationChanged(self.fetchAllTeams(operationChanged: operationChanged, page: page + 1, completion: completion), page, teams)
                }
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String {
        return "No teams"
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, Team>(tableView: tableView) { (tableView, indexPath, team) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(team: team)
            return cell
        }
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [
            Team.teamNumberSortDescriptor()
        ]
        fetchRequest.fetchBatchSize = 50
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    private func updateDataSource() {
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

extension TeamsViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        updateDataSource()
    }

}
