import TBAAPI
import Foundation
import UIKit

@MainActor protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: SearchContainerViewController, DistrictRankingsViewControllerDelegate {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    init(district: District, dependencyProvider: DependencyProvider) {
        let districtRankingsCollectionViewController = DistrictRankingsCollectionViewController(
            district: district,
            dependencyProvider: dependencyProvider
        )
        super.init(viewController: districtRankingsCollectionViewController)

        districtRankingsCollectionViewController.delegate = self
        searchDelegate = districtRankingsCollectionViewController
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Search

    override var searchPlaceholderText: String? {
        "Search district rankings"
    }

    // MARK: - DistrictRankingsViewControllerDelegate

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        delegate?.districtRankingSelected(districtRanking)
    }

}

class DistrictRankingsCollectionViewController: TBACollectionViewListController<RankingCollectionViewListCell, DistrictRanking> {

    /// TODO: We need to move this to use a more dedicated DistirctRanking cell,
    /// as opposed to trying to get the existing Ranking cell to work

    // MARK: - Public Properties

    weak var delegate: DistrictRankingsViewControllerDelegate?

    // MARK: - Private Properties

    private let district: District

    @SortedKeyPath(comparator: KeyPathComparator(\.rank))
    private var districtRankings: [DistrictRanking]? = nil
    private var teams: [String: Team] = [:]

    var searchText: String?

    // TODO: Can there be a way for us to specify that we have multiple refreshing
    // tasks and just cancel all the refreshing tasks together in the super?

    private var districtTeamsFetchTask: Task<Void, Never>? {
        willSet {
            districtTeamsFetchTask?.cancel()
        }
    }
    private var teamFetchTasks: [String: Task<Void, Never>] = [:]

    // MARK: - Init

    init(district: District, dependencyProvider: DependencyProvider) {
        self.district = district

        super.init(dependencyProvider: dependencyProvider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.prefetchDataSource = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cancelTeamFetchTasks()
    }

    // MARK: Data Source

    override var cellRegistration: UICollectionView.CellRegistration<RankingCollectionViewListCell, DistrictRanking> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, districtRanking in
            guard let self else { return }

            var contentConfiguration = RankingListContentConfiguration(districtRanking: districtRanking)

            if let team = teams[districtRanking.teamKey] {
                contentConfiguration.teamName = team.nickname
            } else {
                fetchTeam(for: districtRanking.teamKey)
                contentConfiguration.teamName = "Loading..."
            }

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }
    }

    // TODO: DRY

    @MainActor
    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["district_rankings"])
        if var districtRankings {
            if let searchText {
                districtRankings = filterDistrictRankings(districtRankings: districtRankings, searchText)
            }
            snapshot.appendItems(districtRankings)
        }
        dataSource.apply(snapshot)
        // TODO: Show No Data View
    }

    private func updateDataSource() async {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["district_rankings"])
        if var districtRankings {
            if let searchText {
                districtRankings = filterDistrictRankings(districtRankings: districtRankings, searchText)
            }
            snapshot.appendItems(districtRankings)
        }
        await dataSource.apply(snapshot)

        guard !Task.isCancelled else {
            return
        }
        // TODO: Show No Data View
    }

    @MainActor
    private func reconfigureItems(for teamKeys: Set<String>) async {
        var snapshot = dataSource.snapshot()
        let rankingsToReconfigure = snapshot.itemIdentifiers.filter { teamKeys.contains($0.teamKey) }

        if !rankingsToReconfigure.isEmpty {
            snapshot.reconfigureItems(rankingsToReconfigure)
            await dataSource.apply(snapshot)
        }
    }

    // MARK: - Search

    private func filterDistrictRankings(districtRankings: [DistrictRanking], _ searchText: String?) -> [DistrictRanking] {
        guard let searchText else {
            return districtRankings
        }
        return districtRankings.filter { districtRanking in
            var matchesNickname = false
            if let team = teams[districtRanking.teamKey] {
                let range = team.nickname.range(
                    of: searchText,
                    options: [.caseInsensitive, .diacriticInsensitive]
                )
                matchesNickname = range != nil
            }
            return districtRanking.teamNumber.starts(with: searchText) || matchesNickname
        }
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }

        let districtKey = district.key

        async let districtRankingsTask = try api.getDistrictRankings(path: .init(districtKey: districtKey))
        districtTeamsFetchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await api.getDistrictTeamsSimple(path: .init(districtKey: districtKey))
                let districtTeams = try response.ok.body.json

                // Check for cancellation after await
                try Task.checkCancellation()

                var teamKeys = Set<String>()
                for team in districtTeams {
                    teams[team.key] = team
                    teamKeys.insert(team.key)
                }

                await reconfigureItems(for: teamKeys)
            }
            catch is CancellationError {
                print("District teams fetch task was cancelled")
            } catch {
                // TODO: Search will be degraded, show error
                print("District teams fetch task failed")
            }
        }
        districtRankings = try await districtRankingsTask.ok.body.json
        // TODO: Should this occur... someplace else?
        if !Task.isCancelled {
            await updateDataSource()
        }
    }

    private func fetchTeam(for teamKey: String) {
        guard teams[teamKey] == nil, teamFetchTasks[teamKey] == nil else {
            return
        }

        // TODO: Should this be Task.detached?
        let task = Task { [weak self] in
            guard let self, let api = dependencyProvider?.api else { return }
            defer {
                teamFetchTasks[teamKey] = nil
            }
            do {
                let response = try await api.getTeamSimple(path: .init(teamKey: teamKey))
                let team = try response.ok.body.json

                // Check for cancellation after await
                try Task.checkCancellation()

                teams[team.key] = team

                await reconfigureItems(for: [team.key])
            } catch is CancellationError {
                print("Team fetch task was cancelled for team: \(teamKey)")
            } catch {
                print("Team fetch task failed for team \(teamKey): \(error.localizedDescription)")
            }
        }

        teamFetchTasks[teamKey] = task
    }

    private func cancelFetchingTask(for teamKey: String) {
        teamFetchTasks[teamKey]?.cancel()
        teamFetchTasks[teamKey] = nil
    }

    private func cancelTeamFetchTasks() {
        districtTeamsFetchTask?.cancel()
        districtTeamsFetchTask = nil

        teamFetchTasks.values.forEach { $0.cancel() }
        teamFetchTasks.removeAll()
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No rankings for district"
    }

    // MARK: Collection View Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let dataSource, let ranking = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtRankingSelected(ranking)
    }

}

extension DistrictRankingsCollectionViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let districtRanking = dataSource.itemIdentifier(for: indexPath) else {
                continue
            }
            fetchTeam(for: districtRanking.teamKey)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let districtRanking = dataSource.itemIdentifier(for: indexPath) else {
                continue
            }
            cancelFetchingTask(for: districtRanking.teamKey)
        }
    }

}

extension DistrictRankingsCollectionViewController: SearchDelegate {

    func performSearch(_ searchText: String?) -> Task<Void, Never> {
        // TODO: Remove this LOC, put it in the better spot
        self.searchText = searchText
        return Task.detached(priority: .userInitiated) { [weak self] in
            await self?.updateDataSource()
        }
    }

}
