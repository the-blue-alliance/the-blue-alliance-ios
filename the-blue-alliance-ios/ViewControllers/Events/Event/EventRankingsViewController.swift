import Foundation
import TBAAPI
import UIKit

protocol EventRankingsViewControllerDelegate: AnyObject {
    func rankingSelected(_ ranking: EventRanking.RankingsPayloadPayload)
}

class EventRankingsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventRankingsViewControllerDelegate?

    private let eventKey: String

    private var dataSource: TableViewDataSource<String, EventRanking.RankingsPayloadPayload>!
    private var rankings: [EventRanking.RankingsPayloadPayload] = []
    private var extraStatsInfo: [EventRanking.ExtraStatsInfoPayloadPayload] = []
    private var sortOrderInfo: [EventRanking.SortOrderInfoPayloadPayload] = []

    // MARK: - Init

    init(eventKey: String, dependencies: Dependencies) {
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
        guard let ranking = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.rankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, EventRanking.RankingsPayloadPayload>(tableView: tableView) { [weak self] tableView, indexPath, ranking in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            let detail = self?.rankingInfoString(for: ranking)
            cell.viewModel = RankingCellViewModel(apiRanking: ranking, detailText: detail)
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func applyRanking(_ response: EventRanking?) {
        let rankings = response?.rankings ?? []
        let sorted = rankings.sorted { $0.rank < $1.rank }
        self.rankings = sorted
        self.extraStatsInfo = response?.extraStatsInfo ?? []
        self.sortOrderInfo = response?.sortOrderInfo ?? []

        var snapshot = NSDiffableDataSourceSnapshot<String, EventRanking.RankingsPayloadPayload>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: Ranking info string

    private func rankingInfoString(for ranking: EventRanking.RankingsPayloadPayload) -> String? {
        var parts: [String] = []
        parts.append(contentsOf: Self.formattedPairs(values: ranking.extraStats, info: extraStatsInfo.map { (name: $0.name, precision: Int($0.precision)) }))
        parts.append(contentsOf: Self.formattedPairs(values: ranking.sortOrders ?? [], info: sortOrderInfo.map { (name: $0.name, precision: $0.precision) }))
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private static func formattedPairs(values: [Double], info: [(name: String, precision: Int)]) -> [String] {
        zip(info, values).compactMap { info, value in
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = info.precision
            formatter.minimumFractionDigits = info.precision
            guard let valueString = formatter.string(for: value) else { return nil }
            return "\(info.name): \(valueString)"
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { rankings.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let response = try await self.dependencies.api.eventRankings(key: self.eventKey)
            self.applyRanking(response)
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No rankings for event" }
}
