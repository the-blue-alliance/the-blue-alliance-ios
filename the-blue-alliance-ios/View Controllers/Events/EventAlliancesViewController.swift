import Foundation
import TBAKit
import UIKit
import CoreData

class EventAlliancesContainerViewController: ContainerViewController {

    private let event: Event

    private var alliancesViewController: EventAlliancesViewController!

    override var viewControllers: [Refreshable & Stateful] {
        return [alliancesViewController]
    }

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(persistentContainer: persistentContainer)

        alliancesViewController = EventAlliancesViewController(event: event, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "Alliances"
        navigationDetailLabel.text = "@ \(event.friendlyNameWithYear)"
    }

}

extension EventAlliancesContainerViewController: EventAlliancesViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: self.event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

private class EventAlliancesViewController: TBATableViewController {

    private let event: Event
    private weak var delegate: EventAlliancesViewControllerDelegate?

    // MARK: - Init

    init(event: Event, delegate: EventAlliancesViewControllerDelegate, persistentContainer: NSPersistentContainer) {
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

        // Override automatic rowHeight - these will be smaller than 44 by default, and we want to open them up
        tableView.rowHeight = 44
        tableView.register(UINib(nibName: String(describing: EventAllianceTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventAllianceTableViewCell.reuseIdentifier)

        updateDataSource()
    }
    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var alliancesRequest: URLSessionDataTask?
        alliancesRequest = TBAKit.sharedKit.fetchEventAlliances(key: event.key!, completion: { (alliances, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event alliances - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localAlliances = alliances?.map({ (modelAlliance) -> EventAlliance in
                    return EventAlliance.insert(with: modelAlliance, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.alliances = Set(localAlliances ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: alliancesRequest!)
            })
        })
        self.addRequest(request: alliancesRequest!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let alliances = dataSource?.fetchedResultsController.fetchedObjects, alliances.isEmpty {
            return true
        }
        return false
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<EventAlliance, EventAlliancesViewController>?

    fileprivate func setupDataSource() {
        let fetchRequest: NSFetchRequest<EventAlliance> = EventAlliance.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: EventAllianceTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventAlliance>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventAlliancesViewController: TableViewDataSourceDelegate {

    func configure(_ cell: EventAllianceTableViewCell, for object: EventAlliance, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.alliance = object
        cell.teamSelected = { [unowned self] (team) in
            self.delegate?.teamSelected(team)
        }
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No alliances for event")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
