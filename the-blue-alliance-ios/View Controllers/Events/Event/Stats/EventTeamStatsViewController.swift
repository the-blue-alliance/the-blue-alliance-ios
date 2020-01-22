import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

protocol EventTeamStatsSelectionDelegate: AnyObject {
    func filterSelected()
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

    weak var delegate: EventTeamStatsSelectionDelegate?

    private let event: Event

    private var tableViewDataSource: TableViewDataSource<String, EventTeamStat>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<EventTeamStat>!

    var filter: EventTeamStatFilter {
        didSet {
            userDefaults.set(filter.rawValue, forKey: "EventTeamStatFilter")
            userDefaults.synchronize()

            updateDataSource()
        }
    }

    lazy private var filerBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage.sortFilterIcon,
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [filerBarButtonItem]
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)

        setupDataSource()
        tableView.dataSource = tableViewDataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let eventTeamStats = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.eventTeamStatSelected(eventTeamStats)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, EventTeamStat>(tableView: tableView) { (tableView, indexPath, eventTeamStat) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(eventTeamStat: eventTeamStat)
            return cell
        }
        self.tableViewDataSource = TableViewDataSource(dataSource: dataSource)
        self.tableViewDataSource.delegate = self
        self.tableViewDataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<EventTeamStat> = EventTeamStat.fetchRequest()
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    private func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))

        if shouldRefresh() {
            refresh()
        }
    }

    private func setupFetchRequest(_ request: NSFetchRequest<EventTeamStat>) {
        request.predicate = EventTeamStat.eventPredicate(eventKey: event.key)

        // Switch based on user prefs
        var sortDescriptor: NSSortDescriptor?
        switch filter {
        case .opr:
            sortDescriptor = EventTeamStat.oprSortDescriptor()
        case .dpr:
            sortDescriptor = EventTeamStat.dprSortDescriptor()
        case .ccwm:
            sortDescriptor = EventTeamStat.ccwmSortDescriptor()
        // TODO: Add back in sorting by Team Number
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/279
        }
        request.sortDescriptors = [sortDescriptor!]
    }

    // MARK: - Interface Actions

    @objc private func showFilter() {
        delegate?.filterSelected()
    }

}

extension EventTeamStatsTableViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_team_stats"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team stats until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventTeamStats(key: event.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let stats = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(stats)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}

extension EventTeamStatsTableViewController: Stateful {

    var noDataText: String? {
        return "No team stats for event"
    }

}
