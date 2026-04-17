import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventAlliancesContainerViewController: ContainerViewController {

    private(set) var event: Event

    private var alliancesViewController: EventAlliancesViewController!

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.event = event

        let alliancesViewController = EventAlliancesViewController(eventKey: event.key, dependencies: dependencies)

        super.init(viewControllers: [alliancesViewController],
                   navigationTitle: "Alliances",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   dependencies: dependencies)

        alliancesViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EventAlliancesContainerViewController: EventAlliancesViewControllerDelegate {

    func teamSelected(teamKey: String) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(teamKey: String)
}

private class EventAlliancesViewController: TBATableViewController, Refreshable, Stateful {

    private let eventKey: String
    private var alliances: [EliminationAlliance] = []

    weak var delegate: EventAlliancesViewControllerDelegate?

    // MARK: - Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey
        super.init(dependencies: dependencies)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventAllianceTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventAllianceTableViewCell
        let alliance = alliances[indexPath.row]

        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: indexPath.row + 1)
        cell.teamKeySelected = { [weak self] (teamKey) in
            self?.delegate?.teamSelected(teamKey: teamKey)
        }

        return cell
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { alliances.isEmpty }

    @objc func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let fetched = try await self.dependencies.api.eventAlliances(key: self.eventKey)
            self.alliances = fetched ?? []
            self.tableView.reloadData()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No alliances for event" }
}
