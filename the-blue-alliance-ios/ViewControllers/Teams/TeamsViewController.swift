import Foundation
import TBAAPI

class TeamsViewController: TeamsListViewController<TeamSimple> {

    override func loadTeams() async throws -> [TeamSimple] {
        try await dependencies.api.allTeamsSimple()
    }
}
