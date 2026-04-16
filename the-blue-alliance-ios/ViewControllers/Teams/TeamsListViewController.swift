import TBAAPI
import UIKit

protocol TeamsListViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

class TeamsListViewController: TBASearchableTableViewController, Refreshable, Stateful {

    typealias APITeam = Team

    weak var delegate: TeamsListViewControllerDelegate?

    private(set) var teams: [APITeam] = []

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

    // MARK: - Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, APITeam>(tableView: tableView) { tableView, indexPath, team in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
            cell.viewModel = TeamCellViewModel(teamNumber: "\(team.teamNumber)",
                                               nickname: team.displayNickname,
                                               location: team.locationString)
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func applyTeams(_ teams: [APITeam]) {
        let narrowed = filter(teams).filter { match in
            searchMatch(team: match)
        }.sorted { $0.teamNumber < $1.teamNumber }
        self.teams = narrowed

        var snapshot = NSDiffableDataSourceSnapshot<String, APITeam>()
        snapshot.appendSections([""])
        snapshot.appendItems(narrowed, toSection: "")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func searchMatch(team: APITeam) -> Bool {
        guard showSearch,
              let query = searchController.searchBar.text?.lowercased(),
              !query.isEmpty else {
            return true
        }
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
        delegate?.teamSelected(teamKey: team.key)
    }

    // MARK: - SearchableController

    override func updateDataSource() {
        applyTeams(teams)
    }

    // MARK: - Refreshable

    var refreshKey: String? { fatalError("subclass must override") }
    var automaticRefreshInterval: DateComponents? { nil }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { teams.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await loadTeams()
                applyTeams(fetched)
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No teams" }
}
