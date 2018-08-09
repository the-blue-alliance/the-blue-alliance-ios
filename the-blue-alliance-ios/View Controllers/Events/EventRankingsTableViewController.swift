import Foundation
import TBAKit
import UIKit
import CoreData

class EventRankingsTableViewController: TBATableViewController {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var event: Event!
    var rankingSelected: ((EventRanking) -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil), forCellReuseIdentifier: RankingTableViewCell.reuseIdentifier)
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var rankingsRequest: URLSessionDataTask?
        rankingsRequest = TBAKit.sharedKit.fetchEventRankings(key: self.event.key!, completion: { (rankings, sortOrder, _, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event rankings - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localRankings = rankings?.compactMap({ (modelRanking) -> EventRanking? in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    return EventRanking.insert(with: modelRanking, for: backgroundEvent, for: backgroundTeam, for: sortOrder!, in: backgroundContext)
                })
                backgroundEvent.rankings = Set(localRankings ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: rankingsRequest!)
            })
        })

        self.addRequest(request: rankingsRequest!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let rankings = dataSource?.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource?.object(at: indexPath)
        if let ranking = ranking, let rankingSelected = rankingSelected {
            rankingSelected(ranking)
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<EventRanking, EventRankingsTableViewController>?

    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]

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

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventRanking>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventRankingsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: EventRanking, at indexPath: IndexPath) {
        cell.eventRanking = object
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
