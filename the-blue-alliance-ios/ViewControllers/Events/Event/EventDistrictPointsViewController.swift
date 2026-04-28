import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventDistrictPointsContainerViewController: ContainerViewController {

    private(set) var event: Event

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.event = event

        let districtPointsViewController = EventDistrictPointsViewController(
            eventKey: event.key,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [districtPointsViewController],
            navigationTitle: "District Points",
            navigationSubtitle: "@ \(event.friendlyNameWithYear)",
            dependencies: dependencies
        )

        districtPointsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event District Points: \(event.key)")
    }

}

extension EventDistrictPointsContainerViewController: EventDistrictPointsViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: event.key,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventDistrictPointsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

private struct TeamDistrictPointsRow: Hashable {
    let teamKey: String
    let total: Int
}

private class EventDistrictPointsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventDistrictPointsViewControllerDelegate?

    private let eventKey: EventKey

    private var dataSource: TableViewDataSource<String, TeamDistrictPointsRow>!
    private var rows: [TeamDistrictPointsRow] = []
    private var teamsByKey: [String: TeamSimple] = [:]

    // MARK: - Init

    init(eventKey: EventKey, dependencies: Dependencies) {
        self.eventKey = eventKey
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.teamSelected(teamKey: row.teamKey)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, TeamDistrictPointsRow>(tableView: tableView) {
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
        dataSource.statefulDelegate = self
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
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
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

    // MARK: - Stateful

    var noDataText: String? { "No district points for event" }
}
