import Foundation
import UIKit
import TBAKit
import CoreData

public enum EventTeamStatFilter: Int {
    case opr
    case dpr
    case ccwm
    case teamNumber
    case max
}

class EventTeamStatsTableViewController: TBATableViewController {

    var event: Event!
    public var filter: EventTeamStatFilter {
        didSet {
            UserDefaults.standard.set(filter.rawValue, forKey: "EventTeamStatFilter")
            UserDefaults.standard.synchronize()

            updateDataSource()
        }
    }
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var teamSelected: ((Team) -> Void)?

    // MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        filter = EventTeamStatFilter(rawValue: UserDefaults.standard.integer(forKey: "EventTeamStatFilter"))!

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil), forCellReuseIdentifier: RankingTableViewCell.reuseIdentifier)
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventTeamStats(key: event.key!, completion: { (stats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event team stats - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localStats = stats?.map({ (modelStat) -> EventTeamStat in
                    return EventTeamStat.insert(with: modelStat, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.stats = Set(localStats ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let stats = dataSource?.fetchedResultsController.fetchedObjects, stats.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventTeamStats = dataSource?.object(at: indexPath)
        if let team = eventTeamStats?.team, let teamSelected = teamSelected {
            teamSelected(team)
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<EventTeamStat, EventTeamStatsTableViewController>?

    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<EventTeamStat> = EventTeamStat.fetchRequest()

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: RankingTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventTeamStat>) {
        request.predicate = NSPredicate(format: "event == %@", event)

        // Switch based on user prefs
        var sortDescriptor: NSSortDescriptor?
        switch filter {
        case .opr:
            sortDescriptor = NSSortDescriptor(key: "opr", ascending: true)
        case .dpr:
            sortDescriptor = NSSortDescriptor(key: "dpr", ascending: true)
        case .ccwm:
            sortDescriptor = NSSortDescriptor(key: "ccwm", ascending: true)
        case .teamNumber:
            sortDescriptor = NSSortDescriptor(key: "team.teamNumber", ascending: true)
        default:
            sortDescriptor = nil
        }
        request.sortDescriptors = [sortDescriptor!]
    }

}

extension EventTeamStatsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: EventTeamStat, at indexPath: IndexPath) {
        cell.teamStat = object
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load event team stats")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
