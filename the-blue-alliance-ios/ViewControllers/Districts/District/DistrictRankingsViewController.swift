import TBAAPI
import Foundation
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: SearchContainerViewController, DistrictRankingsViewControllerDelegate {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    init(district: District, api: TBAAPI) {
        let districtRankingsCollectionViewController = DistrictRankingsCollectionViewController(
            district: district,
            api: api
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
    private let api: TBAAPI

    @SortedKeyPath(comparator: KeyPathComparator(\.rank))
    private var districtRankings: [DistrictRanking]? = nil
    private var teams: [String: Team] = [:]

    // TODO: Can there be a way for us to specify that we have multiple refreshing
    // tasks and just cancel all the refreshing tasks together in the super?

    private var districtTeamsFetchTask: Task<Void, Never>? {
        willSet {
            districtTeamsFetchTask?.cancel()
        }
    }
    private var teamFetchTasks: [String: Task<Void, Never>] = [:]

    // MARK: - Init

    init(district: District, api: TBAAPI) {
        self.district = district
        self.api = api

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cancelTeamFetchTasks()
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.prefetchDataSource = self
    }

    // MARK: Data Source

    override var cellRegistration: UICollectionView.CellRegistration<RankingCollectionViewListCell, DistrictRanking> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, districtRanking in
            guard let self else { return }

            var contentConfiguration = RankingListContentConfiguration(districtRanking: districtRanking)

            if let team = teams[districtRanking.teamKey] {
                contentConfiguration.teamName = team.displayName
            } else {
                fetchTeam(for: districtRanking.teamKey)
                contentConfiguration.teamName = "Loading..."
            }

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }
    }

    @MainActor
    private func updateDataSource() async {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("district_rankings", atIndex: 0)
        if let districtRankings {
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

    /*
    private func filterDistrictRankings(_ searchText: String?) {
        guard let searchText else {
            return
        }
        districtRankings = districtRankings?.filter { districtRanking in
            var matchesNickname = false
            if let team = teams[districtRanking.teamKey], let nickname = team.nickname {
                let range = nickname.range(
                    of: searchText,
                    options: [.caseInsensitive, .diacriticInsensitive]
                )
                matchesNickname = range != nil
            }
            return districtRanking.teamNumber.starts(with: searchText) || matchesNickname
        }
    }
    */

    // MARK: - Refresh

    override func performRefresh() async throws {
        districtRankings = try await api.getDistrictRankings(districtKey: district.key)

        let districtKey = district.key
        districtTeamsFetchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let districtTeams = try await api.getDistrictTeamsSimple(districtKey: districtKey)

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
        // TODO: Should this occur... someplace else?
        if !Task.isCancelled {
            await updateDataSource()
        }
    }

    private func fetchTeam(for teamKey: String) {
        guard teams[teamKey] == nil, teamFetchTasks[teamKey] == nil else {
            return
        }

        let task = Task { [weak self] in
            guard let self else { return }
            defer {
                teamFetchTasks[teamKey] = nil
            }
            do {
                let team = try await api.getTeamSimple(teamKey: teamKey)

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

    func performSearch(_ searchText: String?) async throws {
        print(searchText)
        /*
        if let searchText {
            _filteredDistrictRankings = _districtRankings?.filter {
                $0.teamNumber.starts(with: searchText)
            }
        } else {
            _filteredDistrictRankings = nil
        }
        if !Task.isCancelled {
            await updateDataSource()
        }
        */
    }

}
