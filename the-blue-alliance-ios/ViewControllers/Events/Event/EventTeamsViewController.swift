import Foundation
import TBAAPI

class EventTeamsViewController: TeamsListViewController<Team> {

    let eventKey: EventKey

    private var pitLocations: [String: String] = [:]

    // MARK: Init

    init(eventKey: EventKey, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(showSearch: false, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadTeams() async throws -> [Team] {
        async let teams = dependencies.api.eventTeams(key: eventKey)
        async let statuses = try? dependencies.api.eventTeamsStatuses(key: eventKey)

        let loadedTeams = try await teams
        let loadedStatuses = await statuses ?? [:]

        pitLocations = loadedStatuses.compactMapValues { $0.pitLocation }
        return loadedTeams
    }

    override func numberSubtitle(for team: Team) -> String? {
        pitLocations[team.key].map { "Pit \($0)" }
    }

    override var noDataText: String? { "No teams for event" }
}
