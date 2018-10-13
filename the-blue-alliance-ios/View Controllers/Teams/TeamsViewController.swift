import Foundation
import TBAKit
import CoreData

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

    init(event: Event? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
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

    private func refreshTeams() {
        var request: URLSessionDataTask?
        request = Team.fetchAllTeams(taskChanged: { [unowned self] (task, teams) in
            self.addRequest(request: task)

            let previousRequest = request
            request = task

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                // TODO: Delete old teams for page? Kinda a problem but
                teams.forEach({ (modelTeam) in
                    Team.insert(with: modelTeam, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()
                self.removeRequest(request: previousRequest!)
            })
        }) { (error) in
            self.removeRequest(request: request!)

            if let error = error {
                self.showErrorAlert(with: "Unable to refresh teams - \(error.localizedDescription)")
            } else {
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
        request = TBAKit.sharedKit.fetchEventTeams(key: eventKey, completion: { (teams, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to teams events - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: event.objectID) as! Event
                if let teams = teams {
                    let localTeams = teams.map({ (modelTeam) -> Team in
                        return Team.insert(with: modelTeam, in: backgroundContext)
                    })
                    backgroundEvent.teams = Set(localTeams) as NSSet
                }

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}

extension TeamsViewController: Stateful {

    var noDataText: String {
        return "No teams"
    }

}
