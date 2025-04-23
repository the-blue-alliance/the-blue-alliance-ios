import TBAModels
import TBAAPI
import Foundation
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBAFakeSearchableTableViewController<String, DistrictRanking>, UICollectionViewDataSourcePrefetching {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    private let district: District

    @SortedKeyPath(comparator: KeyPathComparator(\.rank))
    private var districtRankings: [DistrictRanking]? = nil {
        didSet {
            updateDataSource()
        }
    }
    private var teams: [String: Team] = [:]

    // TODO: Void, Never ? Or should it be Team, Never ?
    private var ongoingTeamFetchTasks: [String: Task<Void, Never>] = [:]

    // MARK: - Init

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cancelAllOngoingTasks()
    }

    private func cancelAllOngoingTasks() {
        ongoingTeamFetchTasks.values.forEach { $0.cancel() }
        ongoingTeamFetchTasks.removeAll()
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Basic list for now...
        // tableView.registerReusableCell(RankingTableViewCell.self)

        collectionView.dataSource = dataSource
        setupDataSource()

        collectionView.prefetchDataSource = self
    }

    // MARK: Collection View Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let dataSource, let ranking = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Collection View Data Source

    private func setupDataSource() {
        dataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, districtRanking in
            let team = self.teams[districtRanking.teamKey]

            let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as ListCollectionViewCell

            if team == nil {
                self.fetchTeam(for: districtRanking.teamKey)
            }

            // Configure the cell's content
            var content = cell.defaultContentConfiguration()
            content.text = "Rank \(districtRanking.rank)" // Primary text is the rank

            // Secondary text is team name and city if team data is loaded
            if let team = team {
                content.secondaryText = team.displayName
                content.secondaryTextProperties.color = .secondaryLabel
            } else {
                content.secondaryText = "Loading team data..."
                content.secondaryTextProperties.color = .systemGray // Indicate loading
            }
            
            // contentConfig.secondaryText = "\(districtRanking.pointTotal) Points"
            cell.contentConfiguration = content
            return cell
        })
        // TODO: Generalize this
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let headerView = collectionView.dequeueReusableSupplementaryView(elementKind: UICollectionView.elementKindSectionHeader, indexPath: indexPath) as SearchHeaderView

            // Add the search bar to the header view
            if self.searchBar.superview == nil {
                headerView.addSubview(self.searchBar)
                self.searchBar.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.searchBar.topAnchor.constraint(equalTo: headerView.topAnchor),
                    self.searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                    self.searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                    self.searchBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
                ])
            }
            return headerView
        }
    }

    @MainActor override func updateDataSource() {
        guard let dataSource else {
            showNoDataView()
            return
        }

        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("district_rankings", atIndex: 0)
        if let districtRankings {
            snapshot.appendItems(districtRankings)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        districtRankings = try await api.getDistrictRankings(districtKey: district.key)
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No rankings for district"
    }

    // MARK: - Team Fetching

    private func fetchTeam(for teamKey: String) {
        guard teams[teamKey] == nil, ongoingTeamFetchTasks[teamKey] == nil else {
            return
        }

        let task = Task { [weak self] in
            do {
                let team = try await self?.api.getTeamSimple(teamKey: teamKey)

                // Check for cancellation after await
                try Task.checkCancellation()

                if let self, let team {
                    teams[team.key] = team

                    if let dataSource {
                        var snapshot = dataSource.snapshot()
                        let rankingsToReconfigure = snapshot.itemIdentifiers.filter { $0.teamKey == team.key }

                        if !rankingsToReconfigure.isEmpty {
                            snapshot.reconfigureItems(rankingsToReconfigure)
                            await dataSource.apply(snapshot, animatingDifferences: true)
                        }
                    }
                }
            } catch is CancellationError {
                // Handle explicit task cancellation
                print("Team fetch task was cancelled for team: \(teamKey)")
            } catch {
                // Handle other errors
                print("Team fetch task failed for team \(teamKey): \(error.localizedDescription)")
                // TODO: Handle error state, maybe update the ranking item to show error
            }

            self?.ongoingTeamFetchTasks[teamKey] = nil
        }

        ongoingTeamFetchTasks[teamKey] = task
    }

    private func cancelFetchingTask(for teamKey: String) {
        ongoingTeamFetchTasks[teamKey]?.cancel()
        ongoingTeamFetchTasks[teamKey] = nil
    }

    // MARK: - UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let dataSource else {
            return
        }

        for indexPath in indexPaths {
            guard let districtRanking = dataSource.itemIdentifier(for: indexPath) else {
                continue
            }
            fetchTeam(for: districtRanking.teamKey)
        }
    }

    // Called by the collection view to indicate that data prefetching for these index paths should be cancelled
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let dataSource else {
            return
        }

        for indexPath in indexPaths {
            guard let districtRanking = dataSource.itemIdentifier(for: indexPath) else {
                continue
            }
            cancelFetchingTask(for: districtRanking.teamKey)
        }
    }

}
