import TBAAPI
import UIKit

protocol TeamsListViewControllerDelegate: AnyObject {
    func teamSelected(_ team: any TeamDisplayable)
}

class TeamsListViewController<APITeam: TeamDisplayable & Hashable & Sendable>:
    TBATableViewController
{

    weak var delegate: (any TeamsListViewControllerDelegate)?

    private(set) var teams: [APITeam] = []
    private var loadedTeams: [APITeam] = []
    private var filterTask: Task<Void, Never>?

    private lazy var dataSource: TableViewDataSource<String, APITeam> = makeDataSource()

    private(set) lazy var searchBar: ListFilterSearchBar = ListFilterSearchBar { [weak self] in
        self?.updateDataSource()
    }

    // The container pins it above the list, so it stays put while the list scrolls.
    override var containerAccessoryView: UIView? {
        return searchBar
    }

    init(dependencies: Dependencies) {
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "Search Teams"
        tableView.keyboardDismissMode = .onDrag
        tableView.registerReusableCell(TeamTableViewCell.self)
        tableView.dataSource = dataSource
    }

    // MARK: - Subclass override points

    func filter(_ teams: [APITeam]) -> [APITeam] { teams }

    func numberSubtitle(for team: APITeam) -> String? { nil }

    // MARK: - Data Source

    private func makeDataSource() -> TableViewDataSource<String, APITeam> {
        let dataSource = TableViewDataSource<String, APITeam>(tableView: tableView) {
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
        dataSource.noDataDelegate = self as? any Refreshable
        return dataSource
    }

    func applyTeams(_ loaded: [APITeam]) {
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

    // ~10k teams per keystroke; keep it off the main actor.
    @concurrent
    private nonisolated static func narrow(_ teams: [APITeam], matching query: String) async
        -> [APITeam]
    {
        teams.filter { matches($0, query: query) }.sorted { $0.teamNumber < $1.teamNumber }
    }

    // Only fields the row shows; the official name is a long sponsor list.
    private nonisolated static func matches(_ team: APITeam, query: String) -> Bool {
        if "\(team.teamNumber)".hasPrefix(query) { return true }
        return [team.nickname, team.city, team.stateProv, team.country].contains {
            $0?.localizedStandardContains(query) == true
        }
    }

    // MARK: - UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let team = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.teamSelected(team)
    }

    // MARK: - Filtering

    func updateDataSource() {
        filterTask?.cancel()
        let candidates = filter(loadedTeams)
        let query = (searchBar.text ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        )
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

    var noDataText: String? { "No teams" }
}

/// A team list loads its teams. Conforming is what makes it refreshable.
protocol TeamsList: Refreshable {
    associatedtype ListedTeam

    func loadTeams() async throws -> [ListedTeam]
    // Provided by TeamsListViewController.
    func applyTeams(_ loaded: [ListedTeam])
}

extension TeamsList {

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            self.applyTeams(try await self.loadTeams())
        }
    }

}
