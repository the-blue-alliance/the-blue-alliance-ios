import Foundation
import UIKit
import TBAKit
import CoreData

protocol EventTeamStatsSelectionDelegate: AnyObject {
    func eventTeamStatSelected(_ eventTeamStat: EventTeamStat)
}

enum EventTeamStatFilter: String, Comparable, CaseIterable {

    static func < (lhs: EventTeamStatFilter, rhs: EventTeamStatFilter) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case opr = "OPR"
    case dpr = "DPR"
    case ccwm = "CCWM"
    case teamNumber = "Team Number"
}

class EventTeamStatsTableViewController: TBATableViewController, Refreshable {

    private let event: Event
    private let userDefaults: UserDefaults

    weak var delegate: EventTeamStatsSelectionDelegate?
    private var dataSource: TableViewDataSource<EventTeamStat, EventTeamStatsTableViewController>!

    var filter: EventTeamStatFilter {
        didSet {
            userDefaults.set(filter.rawValue, forKey: "EventTeamStatFilter")
            userDefaults.synchronize()

            updateDataSource()
        }
    }

    // MARK: - Init

    init(event: Event, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.userDefaults = userDefaults

        if let savedFilter = userDefaults.string(forKey: "EventTeamStatFilter"), !savedFilter.isEmpty, let filter = EventTeamStatFilter(rawValue: savedFilter) {
            self.filter = filter
        } else {
            self.filter = EventTeamStatFilter.opr
        }

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return "\(event.key!)_team_stats"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team stats until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        if let stats = dataSource.fetchedResultsController.fetchedObjects, stats.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventTeamStats(key: event.key!, completion: { (stats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event team stats - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localStats = stats?.map({ (modelStat) -> EventTeamStat in
                    return EventTeamStat.insert(with: modelStat, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.stats = Set(localStats ?? []) as NSSet

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventTeamStats = dataSource.object(at: indexPath)
        delegate?.eventTeamStatSelected(eventTeamStats)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<EventTeamStat> = EventTeamStat.fetchRequest()
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<EventTeamStat>) {
        request.predicate = NSPredicate(format: "event == %@", event)

        // Switch based on user prefs
        var sortDescriptor: NSSortDescriptor?
        switch filter {
        case .opr:
            sortDescriptor = NSSortDescriptor(key: "opr", ascending: false)
        case .dpr:
            sortDescriptor = NSSortDescriptor(key: "dpr", ascending: false)
        case .ccwm:
            sortDescriptor = NSSortDescriptor(key: "ccwm", ascending: false)
        case .teamNumber:
            sortDescriptor = NSSortDescriptor(key: "team.teamNumber", ascending: true)
        }
        request.sortDescriptors = [sortDescriptor!]
    }

}

extension EventTeamStatsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: EventTeamStat, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(eventTeamStat: object)
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
