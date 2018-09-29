import Foundation
import TBAKit
import UIKit
import CoreData

protocol EventRankingsViewControllerDelegate: AnyObject {
    func rankingSelected(_ ranking: EventRanking)
}

class EventRankingsViewController: TBATableViewController {

    private let event: Event

    weak var delegate: EventRankingsViewControllerDelegate?
    private lazy var dataSource: TableViewDataSource<EventRanking, EventRankingsViewController> = {
        let fetchRequest: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return TableViewDataSource(tableView: tableView, fetchedResultsController: frc, delegate: self)
    }()

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var rankingsRequest: URLSessionDataTask?
        rankingsRequest = TBAKit.sharedKit.fetchEventRankings(key: self.event.key!, completion: { (rankings, sortOrder, _, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event rankings - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localRankings = rankings?.compactMap({ (modelRanking) -> EventRanking? in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    return EventRanking.insert(with: modelRanking, for: backgroundEvent, for: backgroundTeam, for: sortOrder!, in: backgroundContext)
                })
                backgroundEvent.rankings = Set(localRankings ?? []) as NSSet

                backgroundContext.saveOrRollback()
                self.removeRequest(request: rankingsRequest!)
            })
        })

        self.addRequest(request: rankingsRequest!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let rankings = dataSource.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource.object(at: indexPath)
        delegate?.rankingSelected(ranking)
    }

    // MARK: Table View Data Source

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

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No rankings for event")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
