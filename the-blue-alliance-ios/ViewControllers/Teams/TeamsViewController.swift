import CoreData
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
class TeamsViewController: TBASearchableTableViewController, Refreshable, Stateful, TeamsViewControllerDataSourceConfiguration {

    private let showSearch: Bool

    weak var delegate: TeamsViewControllerDelegate?

    private var dataSource: TableViewDataSource<String, Team>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Team>!

    init(showSearch: Bool = true, dependencies: Dependencies) {
        self.showSearch = showSearch

        super.init(dependencies: dependencies)
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

        tableView.dataSource = dataSource
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

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeams() { [unowned self] (result, notModified) in
            guard case .success(let teams) = result, !notModified else {
                return
            }

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(teams, in: context)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    var noDataText: String? {
        return "No teams"
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, Team>(tableView: tableView) { (tableView, indexPath, team) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(team: team)
            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [
            Team.teamNumberSortDescriptor()
        ]
        fetchRequest.fetchBatchSize = 50
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
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
