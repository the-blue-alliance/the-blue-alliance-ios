import Foundation
import TBAAPI

class DistrictTeamsViewController: TeamsListViewController<TeamSimple>, TeamsList {

    let districtKey: String
    let year: Int

    init(districtKey: String, year: Int, dependencies: Dependencies) {
        self.districtKey = districtKey
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadTeams() async throws -> [TeamSimple] {
        try await dependencies.api.districtTeamsSimple(key: districtKey)
    }

    override var noDataText: String? { "No teams for district" }
}
