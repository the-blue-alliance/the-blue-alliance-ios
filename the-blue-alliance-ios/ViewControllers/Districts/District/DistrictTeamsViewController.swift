import TBAAPI
import Foundation

class DistrictTeamsViewController: TeamsViewController {

    init(district: District, dependencyProvider: DependencyProvider) {
        let teamsViewController = DistrictTeamsCollectionViewController(
            district: district,
            dependencyProvider: dependencyProvider
        )
        super.init(viewController: teamsViewController, dependencyProvider: dependencyProvider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DistrictTeamsCollectionViewController: TeamsCollectionViewController {

    private let district: District

    init(district: District, dependencyProvider: DependencyProvider) {
        self.district = district

        super.init(dependencyProvider: dependencyProvider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }
        let response = try await api.getDistrictTeamsSimple(path: .init(districtKey: district.key))
        teams = try response.ok.body.json
    }

    // MARK: - Stateful

    override var noDataText: String? {
        "No teams for district"
    }

}
