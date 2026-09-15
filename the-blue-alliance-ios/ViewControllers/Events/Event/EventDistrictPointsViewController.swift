import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

protocol EventDistrictPointsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

nonisolated private struct TeamDistrictPointsRow: Hashable {
    let teamKey: String
    let total: Int
}

class EventDistrictPointsViewController: TBATableViewController, Refreshable {

    weak var delegate: (any EventDistrictPointsViewControllerDelegate)?

    private let eventKey: EventKey

    private lazy var dataSource: TableViewDataSource<String, TeamDistrictPointsRow> =
        makeDataSource()
    private var rows: [TeamDistrictPointsRow] = []
    private var teamsByKey: [String: TeamSimple] = [:]

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.eventKey = event.key
        super.init(dependencies: dependencies)

        navigationItem.title = "District Points"
        navigationItem.subtitle = "@ \(event.friendlyNameWithYear)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event District Points: \(eventKey)")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.teamSelected(teamKey: row.teamKey)
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, TeamDistrictPointsRow> {
        let dataSource = TableViewDataSource<String, TeamDistrictPointsRow>(tableView: tableView) {
            [weak self] tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            let team = self?.teamsByKey[row.teamKey]
            cell.viewModel = RankingCellViewModel(
                rank: "Rank \(indexPath.row + 1)",
                teamKey: row.teamKey,
                points: row.total,
                team: team
            )
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func apply(points: EventDistrictPoints?) {
        let sortedRows: [TeamDistrictPointsRow]
        if let dict = points?.points.additionalProperties {
            sortedRows =
                dict
                .map { TeamDistrictPointsRow(teamKey: $0.key, total: $0.value.total) }
                .sorted { $0.total > $1.total }
        } else {
            sortedRows = []
        }
        self.rows = sortedRows

        var snapshot = NSDiffableDataSourceSnapshot<String, TeamDistrictPointsRow>()
        snapshot.appendSections([""])
        snapshot.appendItems(sortedRows, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { rows.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Task handles instead of async let, see #996.
            let pointsHandle = Task {
                try await self.dependencies.api.eventDistrictPoints(key: self.eventKey)
            }
            let teamsHandle = Task {
                try? await self.dependencies.api.eventTeamsSimple(key: self.eventKey)
            }

            let teams = await teamsHandle.value ?? []
            self.teamsByKey = Dictionary(uniqueKeysWithValues: teams.map { ($0.key, $0) })

            let response = try await pointsHandle.value
            self.apply(points: response)
        }
    }

    var noDataText: String? { "No district points for event" }
}
