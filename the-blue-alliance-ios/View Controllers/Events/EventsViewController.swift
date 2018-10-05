import UIKit
import TBAKit
import CoreData

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
class EventsViewController: TBATableViewController, Refreshable, EventsViewControllerDataSourceConfiguration {

    weak var delegate: EventsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Event, EventsViewController>!

    // MARK: Init

    init(persistentContainer: NSPersistentContainer) {
        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)
    }

    // MARK: - Refreshable

    var initialRefreshKey: String? {
        fatalError("implement in subclass")
    }

    var isDataSourceEmpty: Bool {
        if let events = dataSource.fetchedResultsController.fetchedObjects, events.isEmpty {
            return true
        }
        return false
    }

    func refresh() {
        fatalError("implement in subclass")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = dataSource.object(at: indexPath)
        delegate?.eventSelected(event)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.sortDescriptors = [firstSortDescriptor,
                                        NSSortDescriptor(key: "startDate", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: sectionNameKeyPath,
                                             cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Event>) {
        request.predicate = fetchRequestPredicate
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    var firstSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: "hybridType", ascending: true)
    }

    var sectionNameKeyPath: String {
        return "hybridType"
    }

    var fetchRequestPredicate: NSPredicate {
        fatalError("Implement in subclass")
    }

}

extension EventsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: EventTableViewCell, for object: Event, at indexPath: IndexPath) {
        cell.viewModel = EventCellViewModel(event: object)
    }

    func title(for section: Int) -> String? {
        let event = dataSource.object(at: IndexPath(item: 0, section: section))

        if let title = delegate?.title(for: event) {
            return title
        }

        if event.isDistrictChampionship {
            guard let district = event.district, let eventTypeString = event.eventTypeString else {
                return nil
            }
            return Int(event.eventType) == EventType.districtChampionshipDivision.rawValue ? "\(district.name!) \(eventTypeString)s" : "\(eventTypeString)s"
        } else if event.isChampionship {
            guard let eventTypeString = event.eventTypeString else {
                return nil
            }
            // CMP Finals are already plural
            return Int(event.eventType) == EventType.championshipFinals.rawValue ? eventTypeString : "\(eventTypeString)s"
        } else if let district = event.district {
            return "\(district.name ?? "") District Events"
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

    func showNoDataView() {
        // Only show no data if we've loaded data once
        if isRefreshing {
            return
        }
        showNoDataView(with: "No events (Pull to refresh)")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
