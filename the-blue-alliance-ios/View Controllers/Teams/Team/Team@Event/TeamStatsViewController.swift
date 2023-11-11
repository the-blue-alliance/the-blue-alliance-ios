import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

class TeamStatsViewController: TBATableViewController, Observable {

    private let team: Team
    private let event: Event

    private var teamStat: EventTeamStat? {
        didSet {
            if let teamStat = teamStat {
                contextObserver.observeObject(object: teamStat, state: .updated) { [weak self] (_, _) in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
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
        return EventTeamStat.predicate(eventKey: event.key, teamKey: team.key)
    }()

    // MARK: - Init

    init(team: Team, event: Event, dependencies: Dependencies) {
        self.team = team
        self.event = event

        super.init(dependencies: dependencies)
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

        let (statName, statKey): (String, String) = {
            switch indexPath.row {
            case 0:
                return ("OPR", EventTeamStat.oprKeyPath())
            case 1:
                return ("DPR", EventTeamStat.dprKeyPath())
            case 2:
                return ("CCWM", EventTeamStat.ccwmKeyPath())
            default:
                return ("", "")
            }
        }()
        cell.viewModel = EventTeamStatCellViewModel(eventTeamStat: teamStat, statName: statName, statKey: statKey)

        return cell
    }

}

extension TeamStatsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_team_stats"
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
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventTeamStats(key: event.key) { [self] (result, notModified) in
            guard case .success(let stats) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(stats)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension TeamStatsViewController: Stateful {

    var noDataText: String? {
        return "No stats for team at event"
    }

}
