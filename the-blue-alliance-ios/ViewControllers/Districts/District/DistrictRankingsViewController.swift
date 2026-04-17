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
        dataSource = TableViewDataSource<String, DistrictRanking>(tableView: tableView) { tableView, indexPath, ranking in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(apiDistrictRanking: ranking)
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
                let number = TeamKey.trimFRCPrefix(ranking.teamKey).lowercased()
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
            let fetched = try await self.dependencies.api.districtRankings(key: self.districtKey) ?? []
            self.allRankings = fetched
            self.applyRankings(fetched)
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No rankings for district" }
}
