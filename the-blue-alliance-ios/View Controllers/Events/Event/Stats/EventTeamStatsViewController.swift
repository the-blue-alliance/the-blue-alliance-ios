import CoreData
import Foundation
import TBAKit
import UIKit

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
}

class EventTeamStatsTableViewController: TBATableViewController {

    private let event: Event

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

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        if let savedFilter = userDefaults.string(forKey: "EventTeamStatFilter"), !savedFilter.isEmpty, let filter = EventTeamStatFilter(rawValue: savedFilter) {
            self.filter = filter
        } else {
            self.filter = EventTeamStatFilter.opr
        }

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventTeamStats = dataSource.object(at: indexPath)
        delegate?.eventTeamStatSelected(eventTeamStats)
        tableView.deselectRow(at: indexPath, animated: true)
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
        // TODO: Add back in sorting by Team Number
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/279
        }
        request.sortDescriptors = [sortDescriptor!]
    }

}

extension EventTeamStatsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: EventTeamStat, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(eventTeamStat: object)
    }

}

extension EventTeamStatsTableViewController: Refreshable {

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
        request = tbaKit.fetchEventTeamStats(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let stats = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(stats)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension EventTeamStatsTableViewController: Stateful {

    var noDataText: String {
        return "No team stats for event"
    }

}
