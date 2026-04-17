import Foundation
import TBAAPI

class EventTeamsViewController: TeamsListViewController<Team> {

    let eventKey: String

    // MARK: Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(showSearch: false, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadTeams() async throws -> [Team] {
        try await dependencies.api.eventTeams(key: eventKey)
    }

    override var noDataText: String? { "No teams for event" }
}
