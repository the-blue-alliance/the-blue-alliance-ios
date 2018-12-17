import Foundation
import CoreData
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
    private var dataSource: TableViewDataSource<Team, TeamsViewController>!

    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()

    // MARK: Init

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
        updateInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = searchController.searchBar

        tableView.registerReusableCell(TeamTableViewCell.self)

        // Used to make sure the UISearchBar stays in our root VC (this VC) when presented and doesn't overlay in push
        definesPresentationContext = true
    }

    // MARK: - Interface Methods

    func updateInterface() {
        searchController.searchBar.placeholder = {
            guard let numberOfTeams = dataSource.fetchedResultsController.fetchedObjects?.count else {
                return nil
            }
            return "Search \(numberOfTeams) Teams"
        }()
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = dataSource.object(at: indexPath)
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
        if let teams = dataSource.fetchedResultsController.fetchedObjects, teams.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        var request: URLSessionDataTask?
        request = fetchAllTeams(taskChanged: { [unowned self] (task, page, teams) in
            self.addRequest(request: task)

            let previousRequest = request
            request = task

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(teams, page: page, in: context)
            }, saved: {
                self.tbaKit.setLastModified(previousRequest!)
            })
            self.removeRequest(request: previousRequest!)
        }) { (error) in
            self.removeRequest(request: request!)
            if error == nil {
                self.markRefreshSuccessful()
            }
        }
        addRequest(request: request!)
    }

    func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, Int, [TBATeam]) -> Void, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return fetchAllTeams(taskChanged: taskChanged, page: 0, completion: completion)
    }

    private func fetchAllTeams(taskChanged: @escaping (URLSessionDataTask, Int, [TBATeam]) -> Void, page: Int, completion: @escaping (Error?) -> Void) -> URLSessionDataTask {
        // TODO: This is problematic, and doesn't handle 304's properly
        return tbaKit.fetchTeams(page: page, completion: { (teams, error) in
            if let error = error {
                completion(error)
                return
            }

            guard let teams = teams else {
                completion(nil)
                return
            }

            if teams.isEmpty {
                completion(nil)
            } else {
                taskChanged(self.fetchAllTeams(taskChanged: taskChanged, page: page + 1, completion: completion), page, teams)
            }
        })
    }

    // MARK: - Stateful

    var noDataText: String {
        return "No teams"
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "teamNumber", ascending: true)]
        fetchRequest.fetchBatchSize = 50
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Team>) {
        let searchPredicate: NSPredicate? = {
            guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
                return nil
            }
            return NSPredicate(format: "(%K contains[cd] %@ OR %K beginswith[cd] %@)",
                               #keyPath(Team.nickname), searchText,
                               #keyPath(Team.teamNumber.stringValue), searchText)
        }()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, fetchRequestPredicate].compactMap({ $0 }))
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    var fetchRequestPredicate: NSPredicate? {
        return nil
    }

}

extension TeamsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: TeamTableViewCell, for object: Team, at indexPath: IndexPath) {
        cell.viewModel = TeamCellViewModel(team: object)
    }

    func controllerDidChangeContent() {
        updateInterface()
    }

}


extension TeamsViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        updateDataSource()
    }

}
