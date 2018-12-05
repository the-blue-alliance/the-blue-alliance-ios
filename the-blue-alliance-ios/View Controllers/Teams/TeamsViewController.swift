import Foundation
import CoreData
import UIKit

protocol TeamsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

class TeamsViewController: TBATableViewController {

    private let event: Event?

    var delegate: TeamsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Team, TeamsViewController>!

    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()

    // MARK: - Init

    init(event: Event? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

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

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "teamNumber", ascending: true)]
        setupFetchRequest(fetchRequest)
        fetchRequest.fetchBatchSize = 50

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Team>) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            if let event = event {
                request.predicate = NSPredicate(format: "ANY events = %@ AND (nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", event, searchText, searchText)
            } else {
                request.predicate = NSPredicate(format: "(nickname contains[cd] %@ OR teamNumber.stringValue beginswith[cd] %@)", searchText, searchText)
            }
        } else if let event = event {
            request.predicate = NSPredicate(format: "ANY events = %@", event)
        } else {
            request.predicate = nil
        }
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

extension TeamsViewController: Refreshable {

    var refreshKey: String? {
        if let event = event {
            return "\(event.key!)_teams"
        }
        return "teams"
    }

    var automaticRefreshInterval: DateComponents? {
        if event != nil {
            return DateComponents(day: 1)
        }
        return DateComponents(month: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Refresh event teams until the event is over
        if let event = event {
            return event.endDate?.endOfDay()
        }
        // Always periodically refresh teams
        return nil
    }

    var isDataSourceEmpty: Bool {
        if let teams = dataSource.fetchedResultsController.fetchedObjects, teams.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        if event != nil {
            refreshEventTeams()
        } else {
            refreshTeams()
        }
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

    private func refreshTeams() {
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

    private func refreshEventTeams() {
        guard let event = event, let eventKey = event.key else {
            return
        }

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventTeams(key: eventKey, completion: { (teams, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let teams = teams {
                    let event = context.object(with: event.objectID) as! Event
                    event.insert(teams)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension TeamsViewController: Stateful {

    var noDataText: String {
        return "No teams"
    }

}
