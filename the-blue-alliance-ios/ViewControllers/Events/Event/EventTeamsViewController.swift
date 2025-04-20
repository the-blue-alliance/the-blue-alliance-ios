import CoreData
import TBAData
import Foundation
import TBAKit

class EventTeamsViewController: TeamsViewController {

    let event: Event

    // MARK: Init

    init(event: Event, dependencies: Dependencies) {
        self.event = event

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    @objc override func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventTeams(key: event.key) { [self] (result, notModified) in
            guard case .success(let teams) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(teams)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No teams for event"
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate? {
        return Team.eventPredicate(eventKey: event.key)
    }

}
