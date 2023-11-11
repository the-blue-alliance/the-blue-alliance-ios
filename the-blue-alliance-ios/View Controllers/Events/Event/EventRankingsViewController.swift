import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

protocol EventRankingsViewControllerDelegate: AnyObject {
    func rankingSelected(_ ranking: EventRanking)
}

class EventRankingsViewController: TBATableViewController {

    weak var delegate: EventRankingsViewControllerDelegate?

    private let event: Event

    private var dataSource: TableViewDataSource<String, EventRanking>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<EventRanking>!

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.event = event

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ranking = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.rankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, EventRanking>(tableView: tableView) { (tableView, indexPath, eventRanking) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(eventRanking: eventRanking)
            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()
        fetchRequest.sortDescriptors = [
            EventRanking.rankSortDescriptor()
        ]
        fetchRequest.predicate = EventRanking.eventPredicate(eventKey: event.key)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
    }

}

extension EventRankingsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event rankings until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventRankings(key: event.key) { [self] (result, notModified) in
            guard case .success((let rankings, let sortOrder, let extraStats)) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(rankings, sortOrderInfo: sortOrder, extraStatsInfo: extraStats)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension EventRankingsViewController: Stateful {

    var noDataText: String? {
        return "No rankings for event"
    }

}
