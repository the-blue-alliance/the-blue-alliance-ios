import Foundation
import TBAAPI
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ ranking: DistrictRanking)
}

class DistrictRankingsViewController: TBASearchableTableViewController, Refreshable, Stateful {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    private let districtKey: String

    private var dataSource: TableViewDataSource<String, DistrictRanking>!
    private var allRankings: [DistrictRanking] = []
    private var teamsByKey: [String: TeamSimple] = [:]

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

        setupSearch()

        tableView.registerReusableCell(RankingTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ranking = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, DistrictRanking>(tableView: tableView) {
            [weak self] tableView, indexPath, ranking in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            let team = self?.teamsByKey[ranking.teamKey]
            cell.viewModel = RankingCellViewModel(ranking: ranking, team: team)
            cell.accessibilityIdentifier = "ranking.\(ranking.teamKey)"
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    override func updateDataSource() {
        applyRankings(allRankings)
    }

    private func applyRankings(_ rankings: [DistrictRanking]) {
        let query = searchController.searchBar.text?.lowercased() ?? ""
        let filtered: [DistrictRanking]
        if query.isEmpty {
            filtered = rankings
        } else {
            filtered = rankings.filter { ranking in
                let number = ranking.teamKey.trimFRCPrefix.lowercased()
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
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
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

    // MARK: - Stateful

    var noDataText: String? { "No rankings for district" }
}
