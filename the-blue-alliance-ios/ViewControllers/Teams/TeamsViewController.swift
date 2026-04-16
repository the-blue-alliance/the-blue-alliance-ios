import Foundation
import TBAAPI

class TeamsViewController: TeamsListViewController {

    override var refreshKey: String? { "teams" }

    override var automaticRefreshInterval: DateComponents? {
        DateComponents(month: 1)
    }

    override func loadTeams() async throws -> [APITeam] {
        try await dependencies.api.allTeams()
    }
}
