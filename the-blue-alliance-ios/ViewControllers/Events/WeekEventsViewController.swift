import CoreData
import Foundation
import TBAAPI
import TBAData
import TBAKit
import TBAUtils

/// Driven off `TBAAPI.eventsByYear` — the list state is fully in-memory.
/// Still kicks off the legacy `TBAKit + Event.insert` path so detail screens
/// (which haven't migrated yet) can find the tapped event in Core Data.
protocol WeekEventsDelegate: AnyObject {
    func weekEventUpdated()
}

class WeekEventsViewController: EventsListViewController {

    private let year: Int
    weak var weekEventsDelegate: WeekEventsDelegate?

    // Full year load — kept so changing `weekEvent` doesn't require a re-fetch.
    private var allEvents: [APIEvent] = []

    var weekEvent: APIEvent? {
        didSet {
            guard weekEvent != oldValue else { return }
            applyEvents(allEvents)
            weekEventsDelegate?.weekEventUpdated()
        }
    }

    init(year: Int, dependencies: Dependencies) {
        self.year = year
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - EventsListViewController

    override func filter(_ events: [APIEvent]) -> [APIEvent] {
        guard let weekEvent else { return [] }

        let sameYear = events.filter { $0.year == weekEvent.year }
        guard let weekEventType = weekEvent.eventTypeEnum else {
            // Selected week has an unknown event type — group all unknown-type events together.
            let valid = Set(APIEventType.allCases.map { $0.rawValue })
            return sameYear.filter { !valid.contains($0.eventType) }
        }

        if let week = weekEvent.week {
            return sameYear.filter { $0.week == week }
        }
        switch weekEventType {
        case .championshipFinals:
            // Group the CMP finals event together with its CMP divisions.
            return sameYear.filter {
                ($0.eventTypeEnum == .championshipFinals || $0.eventTypeEnum == .championshipDivision)
                    && ($0.key == weekEvent.key || $0.parentEventKey == weekEvent.key)
            }
        case .offseason:
            guard let start = weekEvent.startDateParsed, let end = weekEvent.endDateParsed else { return [] }
            let firstOfMonth = start.startOfMonth()
            let lastOfMonth = end.endOfMonth()
            return sameYear.filter {
                guard $0.eventTypeEnum == .offseason, let d = $0.startDateParsed else { return false }
                return d >= firstOfMonth && d <= lastOfMonth
            }
        default:
            return sameYear.filter { $0.eventTypeEnum == weekEventType }
        }
    }

    // MARK: - Refresh

    @objc override func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await dependencies.api.eventsByYear(currentYear)
                allEvents = fetched
                if weekEvent == nil {
                    weekEvent = WeekEventsViewController.initialWeekEvent(for: currentYear, from: fetched)
                } else {
                    applyEvents(allEvents)
                }
            } catch {
                errorRecorder.record(error)
            }
        }

        // Fire-and-forget TBAKit write-through — keeps Core Data warm for the
        // detail screens that still read from it in this interim phase.
        syncToCoreData(year: currentYear)
    }

    private var currentYear: Int {
        // If the user has switched to a different week-event (via the year/week
        // picker), follow that year. Otherwise fall back to the init'd year.
        weekEvent.map { $0.year } ?? year
    }

    // MARK: - Legacy Core Data sync

    private func syncToCoreData(year: Int) {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvents(year: year) { [unowned self] result, notModified in
            guard case .success(let events) = result, !notModified else { return }
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Event.insert(events, year: year, in: context)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: self.errorRecorder)
        }
        addRefreshOperations([operation])
    }

    // MARK: - Initial week-event selection

    private static func initialWeekEvent(for year: Int, from events: [APIEvent]) -> APIEvent? {
        if year == Calendar.current.component(.year, from: Date()) {
            if let current = currentSeasonWeekEvent(year: year, from: events) {
                return current
            }
        }
        return WeekEventsGrouping.weekEvents(for: year, from: events).first
    }

    private static func currentSeasonWeekEvent(year: Int, from events: [APIEvent]) -> APIEvent? {
        let today = Calendar.current.startOfDay(for: Date())
        // First non-finished event (endDate today or later) that's not a CMP division.
        let unplayed = events
            .filter { $0.year == year }
            .filter { $0.eventTypeEnum != .championshipDivision }
            .filter { ($0.endDateParsed ?? .distantPast) >= today }
            .sorted { ($0.endDateParsed ?? .distantPast) < ($1.endDateParsed ?? .distantPast) }
            .first
        if let unplayed { return unplayed }

        // Otherwise first overall event for the year.
        return events
            .filter { $0.year == year }
            .sorted { ($0.startDateParsed ?? .distantPast) < ($1.startDateParsed ?? .distantPast) }
            .first
    }

    // MARK: - Refreshable / Stateful

    override var refreshKey: String? { "\(year)_events" }

    override var automaticRefreshInterval: DateComponents? { DateComponents(day: 7) }

    override var automaticRefreshEndDate: Date? {
        Calendar.current.date(from: DateComponents(year: year + 1))
    }

    override var noDataText: String? { "No events for year" }
}

