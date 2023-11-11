import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

class TeamEventsViewController: EventsViewController {

    private let team: Team
    var year: Int? {
        didSet {
            if oldValue == year {
                return
            }
            updateDataSource()
        }
    }

    init(team: Team, year: Int? = nil, dependencies: Dependencies) {
        self.team = team
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(team.key)_events"
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
        operation = tbaKit.fetchTeamEvents(key: team.key) { [self] (result, notModified) in
            guard case .success(let events) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let team = context.object(with: self.team.objectID) as! Team
                team.insert(events)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No events for team"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate {
        if let year = year {
            return Event.teamYearPredicate(teamKey: team.key, year: year)
        } else {
            return Event.teamYearNonePredicate(teamKey: team.key)
        }
    }

}
