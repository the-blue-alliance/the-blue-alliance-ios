import TBAAPI
import UIKit

protocol EventsListViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
    func title(for event: Event) -> String?
}

extension EventsListViewControllerDelegate {
    func title(for event: Event) -> String? { nil }
}

class EventsListViewController: TBATableViewController, Refreshable, Stateful {

    typealias APIEvent = Event

    weak var delegate: EventsListViewControllerDelegate?

    private(set) var events: [APIEvent] = []
    private var dataSource: TableViewDataSource<EventSection, APIEvent>!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)
        setupDataSource()
    }

    // MARK: - Subclass override points

    func loadEvents() async throws -> [APIEvent] {
        fatalError("subclass must override")
    }

    func filter(_ events: [APIEvent]) -> [APIEvent] { events }

    // MARK: - Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<EventSection, APIEvent>(tableView: tableView) { [weak self] tableView, indexPath, event in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(name: event.safeShortName,
                                                location: event.locationString,
                                                dateString: event.dateString)
            cell.accessibilityIdentifier = "event.\(event.key)"
            _ = self
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
        tableView.dataSource = dataSource
    }

    func applyEvents(_ apiEvents: [APIEvent]) {
        events = filter(apiEvents)

        let grouped = Dictionary(grouping: events, by: \.section)
        var snapshot = NSDiffableDataSourceSnapshot<EventSection, APIEvent>()
        for section in grouped.keys.sorted() {
            snapshot.appendSections([section])
            snapshot.appendItems(
                (grouped[section] ?? []).sorted(by: Event.sectionAscending),
                toSection: section
            )
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.eventSelected(event)
    }

    // MARK: - TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        guard let event = dataSource.itemIdentifier(for: IndexPath(item: 0, section: section)) else {
            return "Events"
        }
        if let customTitle = delegate?.title(for: event) { return customTitle }
        return event.section.title
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { events.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let loaded = try await self.loadEvents()
            self.applyEvents(loaded)
        }
    }

    // MARK: - Stateful

    var noDataText: String? { fatalError("subclass must override") }
}
