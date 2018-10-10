import Foundation
import UIKit
import CoreData
import TBAKit

class TeamStatsViewController: TBATableViewController, Refreshable, Observable {

    private let event: Event
    private let team: Team

    private var teamStat: EventTeamStat? {
        didSet {
            if let teamStat = teamStat {
                contextObserver.observeObject(object: teamStat, state: .updated) { [unowned self] (_, _) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                contextObserver.observeInsertions { [unowned self] (teamStats) in
                    self.teamStat = teamStats.first
                }
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = EventTeamStat
    lazy var contextObserver: CoreDataContextObserver<EventTeamStat> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventTeamStat.event), event, #keyPath(EventTeamStat.team), team)
    }()

    // MARK: - Init

    init(team: Team, event: Event, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.event = event

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Since we leverage didSet, we need to do this *after* initilization
        teamStat = EventTeamStat.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)
        tableView.registerReusableCell(EventTeamStatTableViewCell.self)
    }

    // MARK: - Refresh

    var refreshKey: String? {
        return "\(event.key!)_team_stats"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team stats until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return teamStat == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventTeamStats(key: event.key!, completion: { (stats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team stats - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                stats?.forEach({ (modelStat) in
                    EventTeamStat.insert(with: modelStat, for: backgroundEvent, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTeamStatTableViewCell
        cell.selectionStyle = .none

        let statName: String = {
            switch indexPath.row {
            case 0:
                return "opr"
            case 1:
                return "dpr"
            case 2:
                return "ccwm"
            default:
                return ""
            }
        }()
        cell.viewModel = EventTeamStatCellViewModel(eventTeamStat: teamStat, statName: statName)

        return cell
    }

}
