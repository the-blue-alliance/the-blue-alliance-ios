import CoreData
import Foundation
import TBAData
import TBAKit

class DistrictTeamsViewController: TeamsViewController {

    let district: District

    // MARK: Init

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    @objc override func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchDistrictTeams(key: district.key) { (result, notModified) in
            guard case .success(let teams) = result, !notModified else {
                return
            }

            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let district = context.object(with: self.district.objectID) as! District
                district.insert(teams)
            }, errorRecorder: self.errorRecorder)
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No teams for district"
    }

    // MARK: - TeamsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate? {
        return Team.districtPredicate(districtKey: district.key)
    }

}
