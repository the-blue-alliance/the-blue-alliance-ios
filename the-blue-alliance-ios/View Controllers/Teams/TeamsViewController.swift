import Foundation
import TBAKit
import CoreData

protocol TeamsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

class TeamsViewController: TBATableViewController {

    private let event: Event?

    var delegate: TeamsViewControllerDelegate?
    private lazy var dataSource: TableViewDataSource<Team, TeamsViewController> = {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "teamNumber", ascending: true)]
        setupFetchRequest(fetchRequest)
        fetchRequest.fetchBatchSize = 50

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return TableViewDataSource(tableView: tableView, cellIdentifier: TeamTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }()

    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()

    // MARK: - Init

    init(event: Event? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)
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

        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        if event != nil {
            refreshEventTeams()
        } else {
            refreshTeams()
        }
    }

    override func shouldNoDataRefresh() -> Bool {
        if let teams = dataSource.fetchedResultsController.fetchedObjects, teams.isEmpty {
            return true
        }
        return false
    }

    private func refreshTeams() {
        var request: URLSessionDataTask?
        request = Team.fetchAllTeams(taskChanged: { (task, teams) in
            self.addRequest(request: task)

            let previousRequest = request
            request = task

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                teams.forEach({ (modelTeam) in
                    Team.insert(with: modelTeam, in: backgroundContext)
                })

                backgroundContext.saveContext()
                self.removeRequest(request: previousRequest!)
            })
        }) { (error) in
            self.removeRequest(request: request!)

            if let error = error {
                self.showErrorAlert(with: "Unable to refresh teams - \(error.localizedDescription)")
            }
        }
        addRequest(request: request!)
    }

    private func refreshEventTeams() {
        guard let event = event, let eventKey = event.key else {
            return
        }

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventTeams(key: eventKey, completion: { (teams, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to teams events - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: event.objectID) as! Event
                let localTeams = teams?.map({ (modelTeam) -> Team in
                    return Team.insert(with: modelTeam, in: backgroundContext)
                })
                backgroundEvent.teams = Set(localTeams ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No teams found")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}

extension TeamsViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        updateDataSource()
    }

}
