import Foundation
import TBAAPI

class DistrictTeamsViewController: TeamsListViewController {

    let districtKey: String
    let year: Int

    init(districtKey: String, year: Int, dependencies: Dependencies) {
        self.districtKey = districtKey
        self.year = year

        super.init(showSearch: false, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadTeams() async throws -> [APITeam] {
        try await dependencies.api.districtTeams(key: districtKey)
    }

    override var noDataText: String? { "No teams for district" }
}
