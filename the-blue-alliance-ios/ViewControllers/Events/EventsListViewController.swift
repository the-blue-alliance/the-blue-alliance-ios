import TBAAPI
import UIKit

protocol EventsListViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
    func title(for event: Event) -> String?
}

extension EventsListViewControllerDelegate {
    func title(for event: Event) -> String? { nil }
}

// Lets the host VC overlay a per-event header title on top of the section's natural title.
private final class EventsListDataSource: TableViewDataSource<EventSection, Event> {
    var titleOverride: ((Event) -> String?)?

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        let firstItem = itemIdentifier(for: IndexPath(item: 0, section: section))
        guard let event = firstItem else { return "Events" }
        if let custom = titleOverride?(event) { return custom }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
}

class EventsListViewController: TBATableViewController, Refreshable, Stateful {

    typealias APIEvent = Event

    weak var delegate: EventsListViewControllerDelegate?

    private(set) var events: [APIEvent] = []
    private var dataSource: EventsListDataSource!

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
        dataSource = EventsListDataSource(tableView: tableView) {
            [weak self] tableView, indexPath, event in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(
                name: event.safeShortName,
                location: event.locationString,
                dateString: event.dateString
            )
            cell.accessibilityIdentifier = "event.\(event.key)"
            _ = self
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.titleOverride = { [weak self] event in self?.delegate?.title(for: event) }
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
