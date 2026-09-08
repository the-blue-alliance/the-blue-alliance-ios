import TBAAPI
import UIKit

protocol TeamsListViewControllerDelegate: AnyObject {
    func teamSelected(_ team: any TeamDisplayable)
}

class TeamsListViewController<APITeam: TeamDisplayable & Hashable & Sendable>:
    TBASearchableTableViewController,
    Refreshable, Stateful
{

    weak var delegate: TeamsListViewControllerDelegate?

    private(set) var teams: [APITeam] = []
    private var loadedTeams: [APITeam] = []
    private var filterTask: Task<Void, Never>?

    private var dataSource: TableViewDataSource<String, APITeam>!

    private let showSearch: Bool

    init(showSearch: Bool = true, dependencies: Dependencies) {
        self.showSearch = showSearch
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if showSearch {
            setupSearch()
        }

        tableView.registerReusableCell(TeamTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: - Subclass override points

    func loadTeams() async throws -> [APITeam] {
        fatalError("subclass must override")
    }

    func filter(_ teams: [APITeam]) -> [APITeam] { teams }

    func numberSubtitle(for team: APITeam) -> String? { nil }

    // MARK: - Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, APITeam>(tableView: tableView) {
            tableView,
            indexPath,
            team in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(
                teamNumber: "\(team.teamNumber)",
                nickname: team.displayNickname,
                location: team.locationString,
                numberSubtitle: self.numberSubtitle(for: team)
            )
            cell.accessibilityIdentifier = "team.\(team.key)"
            return cell
        }
        dataSource.statefulDelegate = self
    }

    private func applyTeams(_ loaded: [APITeam]) {
        loadedTeams = loaded
        updateDataSource()
    }

    private func show(_ narrowed: [APITeam]) {
        teams = narrowed

        var snapshot = NSDiffableDataSourceSnapshot<String, APITeam>()
        snapshot.appendSections([""])
        snapshot.appendItems(narrowed, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // `String.contains` over ~10k teams is tens of ms per keystroke; keep it off the main actor.
    @concurrent
    private nonisolated static func narrow(_ teams: [APITeam], matching query: String) async
        -> [APITeam]
    {
        let query = query.lowercased()
        return teams.filter { matches($0, query: query) }.sorted { $0.teamNumber < $1.teamNumber }
    }

    private nonisolated static func matches(_ team: APITeam, query: String) -> Bool {
        if "\(team.teamNumber)".contains(query) { return true }
        if team.nickname.lowercased().contains(query) { return true }
        if team.name.lowercased().contains(query) { return true }
        if let city = team.city?.lowercased(), city.contains(query) { return true }
        if let stateProv = team.stateProv?.lowercased(), stateProv.contains(query) { return true }
        if let country = team.country?.lowercased(), country.contains(query) { return true }
        return false
    }

    // MARK: - UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let team = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.teamSelected(team)
    }

    // MARK: - SearchableController

    override func updateDataSource() {
        filterTask?.cancel()
        let candidates = filter(loadedTeams)
        let query = showSearch ? (searchController.searchBar.text ?? "") : ""
        guard !query.isEmpty else {
            show(candidates.sorted { $0.teamNumber < $1.teamNumber })
            return
        }
        filterTask = Task {
            let narrowed = await Self.narrow(candidates, matching: query)
            guard !Task.isCancelled else { return }
            show(narrowed)
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { teams.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            self.applyTeams(try await self.loadTeams())
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No teams" }
}
