import Foundation
import TBAAPI
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ ranking: DistrictRanking)
}

class DistrictRankingsViewController: TBATableViewController, Refreshable {

    weak var delegate: (any DistrictRankingsViewControllerDelegate)?

    private let districtKey: String

    private lazy var dataSource: TableViewDataSource<String, DistrictRanking> = makeDataSource()
    private var allRankings: [DistrictRanking] = []
    private var teamsByKey: [String: TeamSimple] = [:]

    private lazy var searchBar: ListFilterSearchBar = ListFilterSearchBar { [weak self] in
        self?.updateDataSource()
    }

    // The container pins it above the list, so it stays put while the list scrolls.
    override var containerAccessoryView: UIView? {
        return searchBar
    }

    // MARK: - Init

    init(districtKey: String, dependencies: Dependencies) {
        self.districtKey = districtKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)
        tableView.dataSource = dataSource
        tableView.keyboardDismissMode = .onDrag
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ranking = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, DistrictRanking> {
        let dataSource = TableViewDataSource<String, DistrictRanking>(tableView: tableView) {
            [weak self] tableView, indexPath, ranking in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            let team = self?.teamsByKey[ranking.teamKey]
            cell.viewModel = RankingCellViewModel(ranking: ranking, team: team)
            cell.accessibilityIdentifier = "ranking.\(ranking.teamKey)"
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func updateDataSource() {
        applyRankings(allRankings)
    }

    private func applyRankings(_ rankings: [DistrictRanking]) {
        let query = searchBar.text?.lowercased() ?? ""
        let filtered: [DistrictRanking]
        if query.isEmpty {
            filtered = rankings
        } else {
            filtered = rankings.filter { ranking in
                let number = ranking.teamKey.trimPrefix.lowercased()
                return number.contains(query) || ranking.teamKey.lowercased().contains(query)
            }
        }
        let sorted = filtered.sorted { $0.rank < $1.rank }

        var snapshot = NSDiffableDataSourceSnapshot<String, DistrictRanking>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { allRankings.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Task handles instead of async let, see #996.
            let rankingsHandle = Task {
                try await self.dependencies.api.districtRankings(key: self.districtKey)
            }
            let teamsHandle = Task {
                try? await self.dependencies.api.districtTeamsSimple(key: self.districtKey)
            }

            // Persist teams before awaiting rankings so a rankings failure
            // doesn't discard a successful teams response — the next refresh
            // that succeeds on rankings will render using this team map.
            let teams = await teamsHandle.value ?? []
            self.teamsByKey = Dictionary(uniqueKeysWithValues: teams.map { ($0.key, $0) })

            self.allRankings = try await rankingsHandle.value ?? []
            self.applyRankings(self.allRankings)
        }
    }

    var noDataText: String? { "No rankings for district" }
}
