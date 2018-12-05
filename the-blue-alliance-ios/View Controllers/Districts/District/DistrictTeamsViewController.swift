import CoreData
import Foundation

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
        return "\(district.key!)_teams"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    override var automaticRefreshEndDate: Date? {
        // Automatically refresh district teams during the year before the selected year (when teams are rolling in)
        // Ex: Districts for 2019 will stop automatically refreshing on January 1st, 2019 (should all be set by then)
        return Calendar.current.date(from: DateComponents(year: district.year!.intValue))
    }

    @objc override func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchDistrictTeams(key: district.key!, completion: { (teams, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let teams = teams {
                    let district = context.object(with: self.district.objectID) as! District
                    district.insert(teams)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
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
