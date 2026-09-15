import Foundation
import TBAAPI
import UIKit

protocol DistrictTeamSummaryViewControllerDelegate: AnyObject {
    func eventPointsSelected(eventKey: EventKey)
}

nonisolated private enum SummaryRow: Hashable {
    case rank(Int)
    case eventPoints(DistrictRanking.EventPointsPayloadPayload)
    case totalPoints(Int)
}

class DistrictTeamSummaryViewController: TBATableViewController, Refreshable {

    private let teamKey: String
    private let districtKey: String
    private var ranking: DistrictRanking
    private var eventsByKey: [String: Event] = [:]
    private lazy var dataSource: TableViewDataSource<String, SummaryRow> = makeDataSource()

    weak var delegate: (any DistrictTeamSummaryViewControllerDelegate)?

    // MARK: Init

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

    // MARK: - Table view data source

    private func makeDataSource() -> TableViewDataSource<String, SummaryRow> {
        return TableViewDataSource<String, SummaryRow>(tableView: tableView) {
            [weak self] tableView, indexPath, row in
            let cell =
                tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
            switch row {
            case .rank(let rank):
                cell.titleLabel.text = "District Rank"
                cell.subtitleLabel.text = "\(rank)\(rank.suffix)"
                cell.selectionStyle = .none
                cell.accessoryType = .none
            case .eventPoints(let points):
                cell.titleLabel.text =
                    self?.eventsByKey[points.eventKey]?.safeShortName ?? points.eventKey
                cell.subtitleLabel.text = "\(points.total) Points"
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            case .totalPoints(let total):
                cell.titleLabel.text = "Total Points"
                cell.subtitleLabel.text = "\(total) Points"
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }
            return cell
        }
    }

    private func applyRanking() {
        var rows: [SummaryRow] = [.rank(ranking.rank)]
        rows += ranking.eventPoints.map { .eventPoints($0) }
        rows.append(.totalPoints(ranking.pointTotal))

        var snapshot = NSDiffableDataSourceSnapshot<String, SummaryRow>()
        snapshot.appendSections([""])
        snapshot.appendItems(rows, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .eventPoints(let points) = dataSource.itemIdentifier(for: indexPath) {
            delegate?.eventPointsSelected(eventKey: points.eventKey)
        }
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

            // Persist events before awaiting rankings so a rankings failure
            // doesn't discard a successful events response — the next refresh
            // that succeeds on rankings will render using this event map.
            let events = await eventsHandle.value ?? []
            self.eventsByKey = Dictionary(uniqueKeysWithValues: events.map { ($0.key, $0) })

            let fetched = try await rankingsHandle.value
            if let updated = fetched?.first(where: { $0.teamKey == self.teamKey }) {
                self.ranking = updated
            }
            self.applyRanking()
        }
    }

    var noDataText: String? { "No summary for team at district" }
}
