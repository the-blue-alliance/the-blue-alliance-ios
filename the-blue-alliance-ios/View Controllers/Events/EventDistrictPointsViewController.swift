import UIKit
import CoreData
import TBAKit

// TODO: Eventually, this will be redundant, and will go away
class EventDistrictPointsContainerViewController: ContainerViewController {

    private var event: Event

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        let districtPointsViewController = EventDistrictPointsViewController(event: event, persistentContainer: persistentContainer)

        super.init(viewControllers: [districtPointsViewController],
                   persistentContainer: persistentContainer)

        navigationTitle = "District Points"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"

        districtPointsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

private class EventDistrictPointsViewController: TBATableViewController, Refreshable {

    private let event: Event

    weak var delegate: EventDistrictPointsViewControllerDelegate?
    private var dataSource: TableViewDataSource<DistrictEventPoints, EventDistrictPointsViewController>!

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return "\(event.key!)_district_points"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        if let points = dataSource.fetchedResultsController.fetchedObjects, points.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventDistrictPoints(key: event.key!, completion: { (eventPoints, _, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event district points - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                eventPoints?.forEach({ (modelPoints) in
                    DistrictEventPoints.insert(with: modelPoints, for: backgroundEvent, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventPoints = dataSource.object(at: indexPath)
        delegate?.districtEventPointsSelected(eventPoints)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<DistrictEventPoints> = DistrictEventPoints.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "total", ascending: false)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<DistrictEventPoints>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventDistrictPointsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: DistrictEventPoints, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(rank: "Rank \(indexPath.row + 1)", districtEventPoints: object)
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
