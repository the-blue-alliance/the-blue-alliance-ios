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
    private var dataSource: TableViewDataSource<String, APIEvent>!

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

    func sectionKey(for event: APIEvent) -> String { event.hybridTypeSortKey }

    // MARK: - Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, APIEvent>(tableView: tableView) { [weak self] tableView, indexPath, event in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
            cell.viewModel = EventCellViewModel(name: event.safeShortName,
                                                location: event.locationString,
                                                dateString: event.dateString)
            if indexPath.section == 0 && indexPath.row == 0 {
                cell.accessibilityIdentifier = "cell.event.first"
            } else {
                cell.accessibilityIdentifier = nil
            }
            _ = self
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
        tableView.dataSource = dataSource
    }

    func applyEvents(_ apiEvents: [APIEvent]) {
        let sorted = filter(apiEvents).sorted()
        events = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, APIEvent>()
        // Preserve the order in which sections first appear in the sorted list —
        // the sort is the "right" section ordering (preseason → weeks → CMP → …).
        var sectionOrder: [String] = []
        var grouped: [String: [APIEvent]] = [:]
        for event in sorted {
            let key = sectionKey(for: event)
            if grouped[key] == nil {
                sectionOrder.append(key)
                grouped[key] = []
            }
            grouped[key]?.append(event)
        }

        for section in sectionOrder {
            snapshot.appendSections([section])
            snapshot.appendItems(grouped[section] ?? [], toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
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

        if let customTitle = delegate?.title(for: event) {
            return customTitle
        }

        let districtName = event.district?.displayName

        if event.isDistrictChampionshipEvent {
            guard let districtName, !event.eventTypeString.isEmpty else { return nil }
            return event.isDistrictChampionshipDivision
                ? "\(districtName) \(event.eventTypeString)s"
                : "\(event.eventTypeString)s"
        } else if event.isChampionshipEvent {
            guard !event.eventTypeString.isEmpty else { return nil }
            // CMP Finals is already plural.
            return event.isChampionshipFinals
                ? event.eventTypeString
                : "\(event.eventTypeString)s"
        } else if let districtName {
            return "\(districtName) District Events"
        } else if event.isFoC {
            return "Festival of Champions"
        } else if event.isOffseason {
            return "\(event.weekString) Events"
        } else if event.isPreseason {
            return "Preseason Events"
        } else if event.isRegional {
            return "Regional Events"
        }
        return "Unknown Events"
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
