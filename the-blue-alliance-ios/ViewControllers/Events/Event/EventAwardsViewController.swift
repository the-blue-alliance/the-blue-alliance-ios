import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

class EventAwardsViewController: TBATableViewController, Refreshable {

    weak var delegate: (any EventAwardsViewControllerDelegate)?

    private let eventKey: EventKey
    private let teamKey: String?

    private lazy var dataSource: TableViewDataSource<String, Award> = makeDataSource()
    private var awards: [Award] = []
    private var teamsByKey: [String: TeamSimple] = [:]

    // MARK: - Init

    init(eventKey: EventKey, teamKey: String? = nil, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.teamKey = teamKey

        super.init(dependencies: dependencies)
    }

    /// The event's awards as their own screen, rather than a team's awards as a Team@Event tab.
    convenience init(event: Event, dependencies: Dependencies) {
        self.init(eventKey: event.key, dependencies: dependencies)

        navigationItem.title = "Awards"
        navigationItem.subtitle = "@ \(event.friendlyNameWithYear)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AwardTableViewCell.self)
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if teamKey == nil {
            dependencies.reporter.log("Event Awards: \(eventKey)")
        }
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, Award> {
        let dataSource = TableViewDataSource<String, Award>(tableView: tableView) {
            [weak self] tableView, indexPath, award in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AwardTableViewCell
            cell.selectionStyle = .none
            cell.viewModel = AwardCellViewModel(award: award, teamsByKey: self?.teamsByKey ?? [:])
            cell.teamKeySelected = { [weak self] (teamKey) in
                self?.delegate?.teamSelected(teamKey: teamKey)
            }
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func applyAwards(_ awards: [Award]) {
        let filtered: [Award]
        if let teamKey {
            filtered = awards.filter { $0.recipientList.contains(where: { $0.teamKey == teamKey }) }
        } else {
            filtered = awards
        }
        let sorted = filtered.sorted { $0.awardType < $1.awardType }
        self.awards = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, Award>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { awards.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Task handles instead of async let, see #996.
            let awardsHandle = Task {
                try await self.dependencies.api.eventAwards(key: self.eventKey)
            }
            let teamsHandle = Task {
                try? await self.dependencies.api.eventTeamsSimple(key: self.eventKey)
            }

            let teams = await teamsHandle.value ?? []
            self.teamsByKey = Dictionary(uniqueKeysWithValues: teams.map { ($0.key, $0) })

            self.applyAwards(try await awardsHandle.value)
        }
    }

    var noDataText: String? {
        "No awards for \(teamKey != nil ? "team at event" : "event")"
    }
}
