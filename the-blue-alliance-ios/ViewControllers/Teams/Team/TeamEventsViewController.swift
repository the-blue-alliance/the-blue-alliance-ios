import Foundation
import TBAAPI

class TeamEventsViewController: EventsListViewController, EventsList {

    private let teamKey: String
    var year: Int? {
        didSet {
            if oldValue == year { return }
            applyEvents([])
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

    // MARK: - EventsList

    func loadEvents() async throws -> [APIEvent] {
        guard let year else { return [] }
        return try await dependencies.api.teamEventsByYear(key: teamKey, year: year)
    }

    var noDataText: String? { "No events for team" }
}
