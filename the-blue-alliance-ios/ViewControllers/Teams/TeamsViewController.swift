import Foundation
import TBAAPI

class TeamsViewController: TeamsListViewController<TeamSimple>, TeamsList {

    func loadTeams() async throws -> [TeamSimple] {
        try await dependencies.api.allTeamsSimple()
    }
}
