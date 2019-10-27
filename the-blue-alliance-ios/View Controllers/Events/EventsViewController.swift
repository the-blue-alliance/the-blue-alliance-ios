import CoreData
import TBAData
import TBAKit
import UIKit

protocol EventsViewControllerDelegate: AnyObject {
    func title(for event: Event) -> String?
    func eventSelected(_ event: Event)
}

protocol EventsViewControllerDataSourceConfiguration {
    var firstSortDescriptor: NSSortDescriptor { get }
    var sectionNameKeyPath: String { get }
    var fetchRequestPredicate: NSPredicate { get }
}

extension EventsViewControllerDelegate {

    func title(for event: Event) -> String? {
        return nil
    }

}

/**
 EventsViewController is an abstract view controller which should be subclassed by other view controllers
 that display a list of events, given a set of information. This view controller is not safe to be used by itself.

 See: TeamEventsViewController, DistrictEventsViewController, etc.
 */
class EventsViewController: TBATableViewController, Refreshable, Stateful, EventsViewControllerDataSourceConfiguration {

    weak var delegate: EventsViewControllerDelegate?

    private var dataSource: TableViewDataSource<String, Event>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Event>!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        fatalError("implement in subclass")
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

    func refresh() {
        fatalError("implement in subclass")
    }

    // MARK: - Stateful

    var noDataText: String {
        fatalError("Implement in a subclass")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.eventSelected(event)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, Event>(tableView: tableView) { (tableView, indexPath, event) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(event: event)
            return cell
        }
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.sortDescriptors = [firstSortDescriptor,
                                        NSSortDescriptor(key: #keyPath(Event.startDate), ascending: true),
                                        NSSortDescriptor(key: #keyPath(Event.name), ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Event>) {
        request.predicate = fetchRequestPredicate
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        guard let event = fetchedResultsController.dataSource.itemIdentifier(for: IndexPath(item: 0, section: section)) else {
            return "Events"
        }

        if let title = delegate?.title(for: event) {
            return title
        }

        let district = event.district
        let districtName = district?.name

        let eventType = event.eventType!.intValue
        let eventTypeString = event.eventTypeString

        if event.isDistrictChampionshipEvent {
            guard let districtName = districtName, let eventTypeString = eventTypeString else {
                return nil
            }
            return eventType == EventType.districtChampionshipDivision.rawValue ? "\(districtName) \(eventTypeString)s" : "\(eventTypeString)s"
        } else if event.isChampionship {
            guard let eventTypeString = eventTypeString else {
                return nil
            }
            // CMP Finals are already plural
            return eventType == EventType.championshipFinals.rawValue ? eventTypeString : "\(eventTypeString)s"
        } else if let districtName = districtName {
            return "\(districtName) District Events"
        } else if event.isFoC {
            return "Festival of Champions"
        } else if event.isOffseason {
            return "\(event.weekString) Events"
        } else if event.isPreseason {
            return "Preseason Events"
        } else {
            return "Regional Events"
        }
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    var firstSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.hybridType), ascending: true)
    }

    var sectionNameKeyPath: String {
        return #keyPath(Event.hybridType)
    }

    var fetchRequestPredicate: NSPredicate {
        fatalError("Implement in subclass")
    }

}
