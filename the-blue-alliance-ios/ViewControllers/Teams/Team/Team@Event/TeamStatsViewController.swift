import Foundation
import TBAAPI
import UIKit

nonisolated private struct StatRow: Hashable {
    let name: String
    let value: Float?
}

class TeamStatsViewController: TBATableViewController, Refreshable {

    private let teamKey: String
    private let eventKey: EventKey

    private var stats: TeamStats?
    private lazy var dataSource: TableViewDataSource<String, StatRow> = makeDataSource()

    // MARK: - Init

    init(teamKey: String, eventKey: EventKey, dependencies: Dependencies) {
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
        tableView.dataSource = dataSource
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, StatRow> {
        let dataSource = TableViewDataSource<String, StatRow>(tableView: tableView) {
            tableView,
            indexPath,
            row in
            let cell =
                tableView.dequeueReusableCell(indexPath: indexPath) as EventTeamStatTableViewCell
            cell.selectionStyle = .none
            cell.viewModel = EventTeamStatCellViewModel(statName: row.name, value: row.value)
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func applyStats(_ stats: TeamStats?) {
        self.stats = stats

        var snapshot = NSDiffableDataSourceSnapshot<String, StatRow>()
        snapshot.appendSections([""])
        if let stats {
            snapshot.appendItems(
                [
                    StatRow(name: "OPR", value: stats.opr),
                    StatRow(name: "DPR", value: stats.dpr),
                    StatRow(name: "CCWM", value: stats.ccwm),
                ],
                toSection: ""
            )
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { stats == nil }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let oprs = try await self.dependencies.api.eventOPRs(key: self.eventKey)
            self.applyStats(TeamStats(teamKey: self.teamKey, oprs: oprs))
        }
    }

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
