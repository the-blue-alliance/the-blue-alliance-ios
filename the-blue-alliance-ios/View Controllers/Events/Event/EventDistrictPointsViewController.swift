import CoreData
import Firebase
import MyTBAKit
import TBAData
import TBAKit
import UIKit

// TODO: Eventually, this will be redundant, and will go away
class EventDistrictPointsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let messaging: Messaging
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Event, messaging: Messaging, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.messaging = messaging
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let districtPointsViewController = EventDistrictPointsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [districtPointsViewController],
                   navigationTitle: "District Points",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        districtPointsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("event_district_points", parameters: ["event": event.key!])
    }

}

extension EventDistrictPointsContainerViewController: EventDistrictPointsViewControllerDelegate {

    func districtEventPointsSelected(_ districtEventPoints: DistrictEventPoints) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: districtEventPoints.teamKey!, event: event, messaging: messaging, myTBA: myTBA, showDetailEvent: false, showDetailTeam: true, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventDistrictPointsViewControllerDelegate: AnyObject {
    func districtEventPointsSelected(_ districtEventPoints: DistrictEventPoints)
}

private class EventDistrictPointsViewController: TBATableViewController {

    weak var delegate: EventDistrictPointsViewControllerDelegate?

    private let event: Event

    private var dataSource: TableViewDataSource<String, DistrictEventPoints>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<DistrictEventPoints>!

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

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
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let eventPoints = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtEventPointsSelected(eventPoints)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, DistrictEventPoints>(tableView: tableView) { (tableView, indexPath, districtEventPoints) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(rank: "Rank \(indexPath.row + 1)", districtEventPoints: districtEventPoints)
            return cell
        }
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<DistrictEventPoints> = DistrictEventPoints.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(DistrictEventPoints.total), ascending: false)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    private func setupFetchRequest(_ request: NSFetchRequest<DistrictEventPoints>) {
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(DistrictEventPoints.eventKey.key), event.key!)
    }

}

extension EventDistrictPointsViewController: Refreshable {

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
        return "\(key)_district_points"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        let eventKey = event.key!

        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventDistrictPoints(key: eventKey, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let (eventPoints, _) = try? result.get() {
                    // This is a fucking PROBLEM
                    DistrictEventPoints.insert(eventPoints, eventKey: eventKey, in: context)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        })
        addRefreshOperations([operation])
    }

}

extension EventDistrictPointsViewController: Stateful {

    var noDataText: String {
        return "No district points for event"
    }

}
