import Foundation
import TBAAPI

class TeamsViewController: TeamsListViewController {

    override func loadTeams() async throws -> [APITeam] {
        try await dependencies.api.allTeams()
    }
}
