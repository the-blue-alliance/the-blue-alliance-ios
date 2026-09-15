import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

class EventAlliancesViewController: TBATableViewController, Refreshable {

    private let eventKey: EventKey
    private var alliances: [EliminationAlliance] = []

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event Alliances: \(eventKey)")
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = alliances.count
        if rows == 0 {
            showNoDataView()
        } else {
            removeNoDataView()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> EventAllianceTableViewCell
    {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventAllianceTableViewCell
        let alliance = alliances[indexPath.row]

        cell.viewModel = EventAllianceCellViewModel(
            alliance: alliance,
            allianceNumber: indexPath.row + 1
        )
        cell.teamKeySelected = { [weak self] (teamKey) in
            self?.delegate?.teamSelected(teamKey: teamKey)
        }

        return cell
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { alliances.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            self.alliances =
                try await self.dependencies.api.eventAlliances(key: self.eventKey) ?? []
            self.tableView.reloadData()
        }
    }

    var noDataText: String? { "No alliances for event" }
}
