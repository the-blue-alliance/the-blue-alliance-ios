import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

class TeamEventsViewController: EventsViewController {

    private let team: Team
    var year: Int? {
        didSet {
            updateDataSource()
        }
    }

    init(team: Team, year: Int? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.year = year

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        let key = team.getValue(\Team.key!)
        return "\(key)_events"
    }

    override var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 7)
    }

    override var automaticRefreshEndDate: Date? {
        guard let year = year else {
            return nil
        }
        // Automatically refresh team events until the year is over
        // Ex: Team events for 2018 will stop refreshing on Jan 1st, 2019
        return Calendar.current.date(from: DateComponents(year: year + 1))
    }

    @objc override func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeamEvents(key: team.key!) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let events = try? result.get() {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.insert(events)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No events for team"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate {
        if let year = year {
            return NSPredicate(format: "%K == %ld AND ANY %K == %@",
                               #keyPath(Event.year), year,
                               #keyPath(Event.teams), team)
        } else {
            return NSPredicate(format: "%K == -1 AND ANY %K == %@",
                               #keyPath(Event.year),
                               #keyPath(Event.teams), team)
        }
    }

}
