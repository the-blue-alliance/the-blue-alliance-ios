import Foundation
import TBAAPI

class EventTeamsViewController: TeamsListViewController {

    let eventKey: String

    // MARK: Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(showSearch: false, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadTeams() async throws -> [APITeam] {
        try await dependencies.api.eventTeams(key: eventKey)
    }

    override var refreshKey: String? { "\(eventKey)_teams" }
    override var automaticRefreshInterval: DateComponents? { DateComponents(day: 1) }
    // Phase 3: event.endDate isn't available without a separate fetch.
    override var automaticRefreshEndDate: Date? { nil }

    override var noDataText: String? { "No teams for event" }
}
