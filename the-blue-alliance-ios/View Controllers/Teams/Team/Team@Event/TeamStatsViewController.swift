import CoreData
import Foundation
import TBAKit
import UIKit

class TeamStatsViewController: TBATableViewController, Observable {

    private let teamKey: TeamKey
    private let event: Event

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

    // MARK: - Observable

    typealias ManagedType = EventTeamStat
    lazy var contextObserver: CoreDataContextObserver<EventTeamStat> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventTeamStat.event), event,
                           #keyPath(EventTeamStat.teamKey), teamKey)
    }()

    // MARK: - Init

    init(teamKey: TeamKey, event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teamStat == nil {
            showNoDataView()
            return 0
        }
        removeNoDataView()
        return 3
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

extension TeamStatsViewController: Refreshable {

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
        return "\(key)_team_stats"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team stats until the event is over
        return event.getValue(\Event.endDate)?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return teamStat == nil
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventTeamStats(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let stats = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(stats)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension TeamStatsViewController: Stateful {

    var noDataText: String {
        return "No stats for team at event"
    }

}
