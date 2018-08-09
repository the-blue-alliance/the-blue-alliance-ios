import Foundation
import UIKit
import CoreData
import TBAKit

class TeamStatsTableViewController: TBATableViewController, Observable {

    var event: Event!
    var team: Team!

    private var teamStat: EventTeamStat? {
        didSet {
            if let teamStat = teamStat {
                contextObserver.observeObject(object: teamStat, state: .updated) { [weak self] (_, _) in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            } else {
                contextObserver.observeInsertions { [weak self] (teamStats) in
                    self?.teamStat = teamStats.first
                }
            }
        }
    }

    // MARK: - Persistable

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            teamStat = EventTeamStat.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)
        }
    }

    // MARK: - Observable

    typealias ManagedType = EventTeamStat
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventTeamStat.event), event, #keyPath(EventTeamStat.team), team)
    }()
    lazy var contextObserver: CoreDataContextObserver<EventTeamStat> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: EventTeamStatTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventTeamStatTableViewCell.reuseIdentifier)
    }

    // MARK: - Refresh

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventTeamStats(key: event.key!, completion: { (stats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team stats - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                let localStats = stats?.map({ (modelStat) -> EventTeamStat in
                    return EventTeamStat.insert(with: modelStat, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.stats = Set(localStats ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        return teamStat == nil
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teamStat == nil {
            showNoDataView(with: "No team stats for event")
            return 0
        } else {
            removeNoDataView()
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventTeamStatTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventTeamStatTableViewCell.reuseIdentifier, for: indexPath) as! EventTeamStatTableViewCell
        cell.selectionStyle = .none

        switch indexPath.row {
        case 0:
            cell.statName = "opr"
        case 1:
            cell.statName = "dpr"
        case 2:
            cell.statName = "ccwm"
        default: break
        }
        cell.eventTeamStat = teamStat

        return cell
    }

}
