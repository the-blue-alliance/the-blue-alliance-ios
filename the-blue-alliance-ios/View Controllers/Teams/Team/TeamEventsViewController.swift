import CoreData
import Foundation
import UIKit

class TeamEventsViewController: EventsViewController {

    private let team: Team
    var year: Int? {
        didSet {
            updateDataSource()
        }
    }

    init(team: Team, year: Int? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.team = team
        self.year = year

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(team.key!)_events"
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
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchTeamEvents(key: team.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let events = events {
                    let team = backgroundContext.object(with: self.team.objectID) as! Team
                    team.insert(events)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: - Stateful

    override var noDataText: String {
        return "No events for team"
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
