import CoreData
import Foundation
import TBAKit

class EventTeamsViewController: TeamsViewController {

    let event: Event

    // MARK: Init

    init(event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(event.key!)_teams"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    override var automaticRefreshEndDate: Date? {
        // Refresh event teams until the event is over
        return event.endDate?.endOfDay()
    }

    @objc override func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchEventTeams(key: event.key!, completion: { (result) in
            let teams = try? result.get()
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let teams = teams {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(teams)
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
        return "No teams for event"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate? {
        return NSPredicate(format: "ANY %K = %@",
                           #keyPath(Team.events), event)
    }

}
