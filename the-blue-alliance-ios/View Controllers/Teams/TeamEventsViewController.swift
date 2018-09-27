import CoreData
import Foundation
import TBAKit
import UIKit

class TeamEventsViewController: EventsViewController {

    private let team: Team
    var year: Int? {
        didSet {
            updateDataSource()
        }
    }

    init(team: Team, year: Int? = nil, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.year = year

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeamEvents(key: team.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team
                let localEvents = events?.map({ (modelEvent) -> Event in
                    return Event.insert(with: modelEvent, in: backgroundContext)
                })
                backgroundTeam.addToEvents(Set(localEvents ?? []) as NSSet)

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: - EventsViewControllerDataSourceConfiguration

    override var fetchRequestPredicate: NSPredicate {
        if let year = year {
            return NSPredicate(format: "year == %ld AND ANY teams == %@", year, team)
        } else {
            return NSPredicate(format: "year == -1 AND ANY teams == %@", team)
        }
    }

}
