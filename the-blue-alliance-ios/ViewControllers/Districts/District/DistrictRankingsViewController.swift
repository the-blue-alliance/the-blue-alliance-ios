import TBAModels
import TBAAPI
import Foundation
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBAFakeSearchableTableViewController, UICollectionViewDataSourcePrefetching {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    private let district: District
    @SortedKeyPath(comparator: KeyPathComparator(\DistrictRanking.rank)) private var districtRankings: [DistrictRanking]? = nil {
        didSet {
            updateDataSource()
        }
    }
    private var teams: [String: Team] = [:]

    private var dataSource: CollectionViewDataSource<String, DistrictRanking>!

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
        guard let ranking = dataSource.itemIdentifier(for: indexPath) else {
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
                self.fetchTeam(for: districtRanking)
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
        dataSource.statefulDelegate = self
        // dataSource.delegate = self
    }

    @MainActor override func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("district_rankings", atIndex: 0)
        if let districtRankings {
            snapshot.appendItems(districtRankings)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - SimpleRefreshable

    override func performRefresh() async throws {
        self.districtRankings = try await api.getDistrictRankings(districtKey: district.key)
    }

    // MARK: - Team Fetching

    private func fetchTeam(for districtRanking: DistrictRanking) {
        let teamKey = districtRanking.teamKey
        guard teams[teamKey] == nil, ongoingTeamFetchTasks[teamKey] == nil else {
            return
        }

        print("Starting new fetch task for team: \(teamKey)")

        // Create a new Task for the asynchronous work.
        // Since this is called from a @MainActor context, the Task inherits
        // the MainActor's executor. The UI updates inside the Task are implicitly
        // happening on the main actor.
        let task = Task { [weak self] in
            do {
                // Await the asynchronous API call from the actor.
                let team = try await self?.api.getTeamSimple(teamKey: teamKey)

                // Check for cancellation after await
                try Task.checkCancellation()

                // UI updates and data source modifications happen here.
                // Since this Task block was started on the MainActor, these operations
                // are safe (implicitly on the main actor).
                if let team = team, let self = self {
                    // Store the fetched team data
                    // Accessing teams dictionary is safe
                    self.teams[team.key] = team

                    // Find all visible/prefetched rankings associated with this teamKey
                    // and reconfigure their cells.
                    var snapshot = self.dataSource.snapshot()

                    // Find items (DistrictRankings) in the current snapshot
                    // that match the fetched teamKey
                    let rankingsToReconfigure = snapshot.itemIdentifiers.filter { $0.teamKey == team.key }

                    // If the ranking exists in the snapshot, reconfigure its item(s).
                    // Applying the snapshot updates the UI, requires MainActor
                    if !rankingsToReconfigure.isEmpty {
                        snapshot.reconfigureItems(rankingsToReconfigure)
                        await dataSource.apply(snapshot, animatingDifferences: true)
                        print("Fetched team data and updated cell(s) for team: \(team.key)")
                    } else {
                        print("Fetched team data for \(team.key), but no corresponding ranking found in snapshot.")
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

            // Remove the task from tracking upon completion (success or failure)
            // Accessing ongoingTeamFetchTasks is safe
            self?.ongoingTeamFetchTasks[teamKey] = nil
        }

        // Store the task handle. Accessing ongoingTeamFetchTasks is safe.
        ongoingTeamFetchTasks[teamKey] = task
    }

    private func cancelFetchingTask(for teamKey: String) {
        ongoingTeamFetchTasks[teamKey]?.cancel()
        ongoingTeamFetchTasks[teamKey] = nil
    }

    // MARK: - UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let districtRanking = dataSource.itemIdentifier(for: indexPath) {
                // Start the fetch task. The method checks if details are needed/task is ongoing.
                fetchTeam(for: districtRanking)
            }
        }
    }

    // Called by the collection view to indicate that data prefetching for these index paths should be cancelled
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let districtRanking = dataSource.itemIdentifier(for: indexPath) {
                // Cancel the fetch task for this item
                cancelFetchingTask(for: districtRanking.teamKey)
            }
        }
    }

}

extension DistrictRankingsViewController: Stateful {
    var noDataText: String? {
        return "No rankings for district"
    }
}
