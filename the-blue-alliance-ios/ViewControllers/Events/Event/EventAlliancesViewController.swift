import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import UIKit

class EventAlliancesContainerViewController: ContainerViewController {

    private(set) var event: Components.Schemas.Event
    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private var alliancesViewController: EventAlliancesViewController!

    // MARK: - Init

    init(event: Components.Schemas.Event, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

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

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event Alliances: %@", [event.key])
    }

}

extension EventAlliancesContainerViewController: EventAlliancesViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: team.key, eventKey: event.key, year: event.year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

private class EventAlliancesViewController: TBATableViewController, Refreshable, Stateful {

    private let eventKey: String
    private var alliances: [Components.Schemas.EliminationAlliance] = []

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
            // Team lookup is still managed — Phase 3 swaps this for an API-driven path.
            guard let context = self?.persistentContainer.viewContext else { return }
            let team = Team.insert(teamKey, in: context)
            self?.delegate?.teamSelected(team)
        }

        return cell
    }

    // MARK: - Refreshable

    var refreshKey: String? { "\(eventKey)_alliances" }
    var automaticRefreshInterval: DateComponents? { nil }
    var automaticRefreshEndDate: Date? { nil }
    var isDataSourceEmpty: Bool { alliances.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await dependencies.api.eventAlliances(key: eventKey)
                alliances = fetched ?? []
                tableView.reloadData()
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No alliances for event" }
}
