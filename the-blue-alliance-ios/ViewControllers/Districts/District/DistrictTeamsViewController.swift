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

    override var refreshKey: String? {
        return "\(district.key)_teams"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    override var automaticRefreshEndDate: Date? {
        // Automatically refresh district teams during the year before the selected year (when teams are rolling in)
        // Ex: Districts for 2019 will stop automatically refreshing on January 1st, 2019 (should all be set by then)
        return Calendar.current.date(from: DateComponents(year: Int(district.year)))
    }

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
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
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
