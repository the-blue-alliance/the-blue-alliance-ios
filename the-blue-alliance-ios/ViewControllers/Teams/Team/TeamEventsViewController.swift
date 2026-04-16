import Foundation
import TBAAPI

class TeamEventsViewController: EventsListViewController {

    private let teamKey: String
    var year: Int? {
        didSet {
            if oldValue == year { return }
            refresh()
        }
    }

    init(teamKey: String, year: Int? = nil, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - EventsListViewController

    override func loadEvents() async throws -> [APIEvent] {
        guard let year else { return [] }
        return try await dependencies.api.teamEventsByYear(key: teamKey, year: year)
    }

    // MARK: - Refreshable

    override var refreshKey: String? { "\(teamKey)_events" }
    override var automaticRefreshInterval: DateComponents? { DateComponents(day: 7) }
    override var automaticRefreshEndDate: Date? {
        guard let year else { return nil }
        // Keep refreshing this team's events until the year rolls over.
        return Calendar.current.date(from: DateComponents(year: year + 1))
    }

    // MARK: - Stateful

    override var noDataText: String? { "No events for team" }
}
