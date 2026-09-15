import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

nonisolated private struct AllianceRow: Hashable {
    let number: Int
    let alliance: EliminationAlliance
}

class EventAlliancesViewController: TBATableViewController, Refreshable {

    private let eventKey: EventKey
    private var alliances: [EliminationAlliance] = []
    private lazy var dataSource: TableViewDataSource<String, AllianceRow> = makeDataSource()

    weak var delegate: (any EventAlliancesViewControllerDelegate)?

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.eventKey = event.key
        super.init(dependencies: dependencies)

        navigationItem.title = "Alliances"
        navigationItem.subtitle = "@ \(event.friendlyNameWithYear)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventAllianceTableViewCell.self)
        // Override automatic rowHeight - these will be smaller than 44 by default, and we want to open them up
        tableView.rowHeight = 44
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event Alliances: \(eventKey)")
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, AllianceRow> {
        let dataSource = TableViewDataSource<String, AllianceRow>(tableView: tableView) {
            [weak self] tableView, indexPath, row in
            let cell =
                tableView.dequeueReusableCell(indexPath: indexPath) as EventAllianceTableViewCell
            cell.viewModel = EventAllianceCellViewModel(
                alliance: row.alliance,
                allianceNumber: row.number
            )
            cell.teamKeySelected = { [weak self] (teamKey) in
                self?.delegate?.teamSelected(teamKey: teamKey)
            }
            return cell
        }
        dataSource.noDataDelegate = self
        return dataSource
    }

    private func applyAlliances(_ alliances: [EliminationAlliance]) {
        self.alliances = alliances

        var snapshot = NSDiffableDataSourceSnapshot<String, AllianceRow>()
        snapshot.appendSections([""])
        snapshot.appendItems(
            alliances.enumerated().map { AllianceRow(number: $0.offset + 1, alliance: $0.element) },
            toSection: ""
        )
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { alliances.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let alliances = try await self.dependencies.api.eventAlliances(key: self.eventKey)
            self.applyAlliances(alliances ?? [])
        }
    }

    var noDataText: String? { "No alliances for event" }
}
