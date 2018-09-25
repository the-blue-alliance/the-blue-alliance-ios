import UIKit
import CoreData
import TBAKit

// TODO: Eventually, this will be redundant, and will go away
class EventDistrictPointsContainerViewController: ContainerViewController {

    private var event: Event
    private var districtPointsViewController: EventDistrictPointsViewController!

    override var viewControllers: [Refreshable & Stateful] {
        return [districtPointsViewController]
    }

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)

        districtPointsViewController = EventDistrictPointsViewController(event: event, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "District Points"
        navigationDetailLabel.text = "@ \(event.friendlyNameWithYear)"
    }

}

extension EventDistrictPointsContainerViewController: EventDistrictPointsViewControllerDelegate {

    func districtEventPointsSelected(_ districtEventPoints: DistrictEventPoints) {
        let teamAtEventViewController = TeamAtEventViewController(team: districtEventPoints.team!, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventDistrictPointsViewControllerDelegate: AnyObject {
    func districtEventPointsSelected(_ districtEventPoints: DistrictEventPoints)
}

private class EventDistrictPointsViewController: TBATableViewController {

    private let event: Event
    private weak var delegate: EventDistrictPointsViewControllerDelegate?

    // MARK: - Init

    init(event: Event, delegate: EventDistrictPointsViewControllerDelegate, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.delegate = delegate

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil), forCellReuseIdentifier: RankingTableViewCell.reuseIdentifier)

        updateDataSource()
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventDistrictPoints(key: event.key!, completion: { (eventPoints, _, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event district points - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localPoints = eventPoints?.map({ (modelPoints) -> DistrictEventPoints in
                    return DistrictEventPoints.insert(with: modelPoints, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.points = Set(localPoints ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let points = dataSource?.fetchedResultsController.fetchedObjects, points.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventPoints = dataSource?.object(at: indexPath)
        if let eventPoints = eventPoints {
            delegate?.districtEventPointsSelected(eventPoints)
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<DistrictEventPoints, EventDistrictPointsViewController>?

    fileprivate func setupDataSource() {
        let fetchRequest: NSFetchRequest<DistrictEventPoints> = DistrictEventPoints.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "total", ascending: false)]

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

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<DistrictEventPoints>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventDistrictPointsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: DistrictEventPoints, at indexPath: IndexPath) {
        cell.points = object
        cell.rankLabel?.text = "Rank \(indexPath.row + 1)"
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load event district points")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
