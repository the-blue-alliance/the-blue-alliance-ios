import Foundation
import TBAKit
import CoreData

class TeamsTableViewController: TBATableViewController {

    let event: Event?
    let teamSelected: ((Team) -> ())

    let searchController = UISearchController(searchResultsController: nil)

    init(teamSelected: @escaping ((Team) -> ()), event: Event? = nil, persistentContainer: NSPersistentContainer) {
        self.teamSelected = teamSelected
        self.event = event

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        tableView.tableHeaderView = searchController.searchBar

        // Used to make sure the UISearchBar stays in our root VC (this VC) when presented and doesn't overlay in push
        definesPresentationContext = true

        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)

        updateDataSource()
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
        if let teams = dataSource?.fetchedResultsController.fetchedObjects, teams.isEmpty {
            return true
        }
        return false
    }

    func refreshTeams() {
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

    func refreshEventTeams() {
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
        let team = dataSource?.object(at: indexPath)
        if let team = team {
            teamSelected(team)
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let text = searchController.searchBar.text, text.isEmpty, searchController.isActive {
            searchController.isActive = false
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<Team, TeamsTableViewController>?

    fileprivate func setupDataSource() {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "teamNumber", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: TeamTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Team>) {
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

extension TeamsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: TeamTableViewCell, for object: Team, at indexPath: IndexPath) {
        cell.team = object
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

extension TeamsTableViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        updateDataSource()
    }

}
