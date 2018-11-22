import Foundation
import UIKit
import CoreData

protocol EventRankingsViewControllerDelegate: AnyObject {
    func rankingSelected(_ ranking: EventRanking)
}

class EventRankingsViewController: TBATableViewController {

    private let event: Event

    weak var delegate: EventRankingsViewControllerDelegate?
    private var dataSource: TableViewDataSource<EventRanking, EventRankingsViewController>!

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource.object(at: indexPath)
        delegate?.rankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<EventRanking>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventRankingsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: EventRanking, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(eventRanking: object)
    }

}

extension EventRankingsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key!)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event rankings until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        if let rankings = dataSource.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventRankings(key: event.key!, completion: { (rankings, sortOrder, extraStats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event rankings - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let rankings = rankings {
                    let event = backgroundContext.object(with: self.event.objectID) as! Event
                    event.insert(rankings, sortOrderInfo: sortOrder, extraStatsInfo: extraStats)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        self.addRequest(request: request!)
    }

}

extension EventRankingsViewController: Stateful {

    var noDataText: String {
        return "No rankings for event"
    }

}
