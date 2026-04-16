import Foundation
import TBAAPI
import UIKit

class TeamStatsViewController: TBATableViewController, Refreshable, Stateful {

    private let teamKey: String
    private let eventKey: String

    private var stats: TeamStats?

    // MARK: - Init

    init(teamKey: String, eventKey: String, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.eventKey = eventKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTeamStatTableViewCell.self)
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stats == nil {
            showNoDataView()
            return 0
        }
        removeNoDataView()
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventTeamStatTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTeamStatTableViewCell
        cell.selectionStyle = .none

        let (statName, statValue): (String, Float?) = {
            switch indexPath.row {
            case 0: return ("OPR", stats?.opr)
            case 1: return ("DPR", stats?.dpr)
            case 2: return ("CCWM", stats?.ccwm)
            default: return ("", nil)
            }
        }()
        cell.viewModel = EventTeamStatCellViewModel(statName: statName, value: statValue)
        return cell
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { stats == nil }

    @objc func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let oprs = try await self.dependencies.api.eventOPRs(key: self.eventKey)
            self.stats = TeamStats(teamKey: self.teamKey, oprs: oprs)
            self.tableView.reloadData()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No stats for team at event" }
}

private struct TeamStats {
    let opr: Float?
    let dpr: Float?
    let ccwm: Float?

    init?(teamKey: String, oprs: EventOPRs?) {
        guard let oprs else { return nil }
        let o = oprs.oprs?.additionalProperties[teamKey]
        let d = oprs.dprs?.additionalProperties[teamKey]
        let c = oprs.ccwms?.additionalProperties[teamKey]
        if o == nil && d == nil && c == nil { return nil }
        self.opr = o
        self.dpr = d
        self.ccwm = c
    }
}
