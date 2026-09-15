import Foundation
import TBAAPI
import UIKit

nonisolated private struct BreakdownSection: Hashable {
    let eventKey: String
    let title: String
}

extension BreakdownSection: TableSectionTitleProviding {
    var headerTitle: String? { title }
}

nonisolated private struct PointsRow: Hashable {
    let eventKey: String
    let title: String
    let points: Int
}

class DistrictBreakdownViewController: TBATableViewController, Refreshable {

    private let teamKey: String
    private let districtKey: String
    private var ranking: DistrictRanking
    private var eventsByKey: [String: Event] = [:]
    private lazy var dataSource: TableViewDataSource<BreakdownSection, PointsRow> =
        makeDataSource()

    // MARK: - Init

    init(ranking: DistrictRanking, districtKey: String, dependencies: Dependencies) {
        self.ranking = ranking
        self.teamKey = ranking.teamKey
        self.districtKey = districtKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.dataSource = dataSource
        applyRanking()
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<BreakdownSection, PointsRow> {
        let dataSource = TableViewDataSource<BreakdownSection, PointsRow>(tableView: tableView) {
            tableView,
            indexPath,
            row in
            let cell =
                tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
            cell.titleLabel.text = "\(row.title) Points"
            cell.subtitleLabel.text = "\(row.points) Points"
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func applyRanking() {
        var snapshot = NSDiffableDataSourceSnapshot<BreakdownSection, PointsRow>()
        for points in ranking.eventPoints {
            let eventKey = points.eventKey
            let section = BreakdownSection(
                eventKey: eventKey,
                title: eventsByKey[eventKey]?.safeShortName ?? eventKey
            )
            snapshot.appendSections([section])
            snapshot.appendItems(
                [
                    PointsRow(
                        eventKey: eventKey,
                        title: "Qualification",
                        points: points.qualPoints
                    ),
                    PointsRow(eventKey: eventKey, title: "Elimination", points: points.elimPoints),
                    PointsRow(eventKey: eventKey, title: "Alliance", points: points.alliancePoints),
                    PointsRow(eventKey: eventKey, title: "Award", points: points.awardPoints),
                    PointsRow(eventKey: eventKey, title: "Total", points: points.total),
                ],
                toSection: section
            )
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { ranking.eventPoints.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Task handles instead of async let, see #996.
            let rankingsHandle = Task {
                try await self.dependencies.api.districtRankings(key: self.districtKey)
            }
            let eventsHandle = Task {
                try? await self.dependencies.api.districtEvents(key: self.districtKey)
            }

            let events = await eventsHandle.value ?? []
            self.eventsByKey = Dictionary(uniqueKeysWithValues: events.map { ($0.key, $0) })

            let fetched = try await rankingsHandle.value
            if let updated = fetched?.first(where: { $0.teamKey == self.teamKey }) {
                self.ranking = updated
            }
            self.applyRanking()
        }
    }

    var noDataText: String? { "No district points for team" }
}
