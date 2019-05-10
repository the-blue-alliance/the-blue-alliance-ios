import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAKit
import UIKit

class EventAlliancesContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private var alliancesViewController: EventAlliancesViewController!

    // MARK: - Init

    init(event: Event, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let alliancesViewController = EventAlliancesViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [alliancesViewController],
                   navigationTitle: "Alliances",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        alliancesViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("event_alliances", parameters: ["event": event.key!])
    }

}

extension EventAlliancesContainerViewController: EventAlliancesViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, myTBA: myTBA, showDetailEvent: false, showDetailTeam: true, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamKeySelected(_ teamKey: TeamKey)
}

private class EventAlliancesViewController: TBATableViewController {

    private let event: Event

    weak var delegate: EventAlliancesViewControllerDelegate?
    private var dataSource: TableViewDataSource<EventAlliance, EventAlliancesViewController>!

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Override automatic rowHeight - these will be smaller than 44 by default, and we want to open them up
        tableView.rowHeight = 44
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<EventAlliance> = EventAlliance.fetchRequest()
        // This seems like a poor sort descriptor... since this could be nil
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(EventAlliance.name), ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func setupFetchRequest(_ request: NSFetchRequest<EventAlliance>) {
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(EventAlliance.event), event)
    }

}

extension EventAlliancesViewController: TableViewDataSourceDelegate {

    func configure(_ cell: EventAllianceTableViewCell, for object: EventAlliance, at indexPath: IndexPath) {
        cell.viewModel = EventAllianceCellViewModel(alliance: object, allianceNumber: indexPath.row + 1)
        cell.teamKeySelected = { [weak self] (teamKey) in
            guard let context = self?.persistentContainer.viewContext else {
                return
            }
            let teamKey = TeamKey.insert(withKey: teamKey, in: context)
            self?.delegate?.teamKeySelected(teamKey)
        }
    }

}

extension EventAlliancesViewController: Refreshable {

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
        return "\(eventKey!)_alliances"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        if let alliances = dataSource.fetchedResultsController.fetchedObjects, alliances.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventAlliances(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let alliances = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(alliances)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        self.addRequest(request: request!)
    }

}

extension EventAlliancesViewController: Stateful {

    var noDataText: String {
        return "No alliances for event"
    }

}
