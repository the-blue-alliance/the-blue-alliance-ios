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
