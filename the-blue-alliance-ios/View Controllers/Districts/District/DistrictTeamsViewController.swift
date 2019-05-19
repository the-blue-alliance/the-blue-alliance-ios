import CoreData
import Foundation
import TBAKit

class DistrictTeamsViewController: TeamsViewController {

    let district: District

    // MARK: Init

    init(district: District, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        let key = district.getValue(\District.key!)
        return "\(key)_teams"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    override var automaticRefreshEndDate: Date? {
        // Automatically refresh district teams during the year before the selected year (when teams are rolling in)
        // Ex: Districts for 2019 will stop automatically refreshing on January 1st, 2019 (should all be set by then)
        let year = district.getValue(\District.year!.intValue)
        return Calendar.current.date(from: DateComponents(year: year))
    }

    @objc override func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchDistrictTeams(key: district.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let teams = try? result.get() {
                    let district = context.object(with: self.district.objectID) as! District
                    district.insert(teams)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            })
        })
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No teams for district"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate? {
        return NSPredicate(format: "ANY %K = %@",
                           #keyPath(Team.districts), district)
    }

}
