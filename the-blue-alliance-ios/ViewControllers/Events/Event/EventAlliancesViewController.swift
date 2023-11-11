import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class EventAlliancesContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private var alliancesViewController: EventAlliancesViewController!

    // MARK: - Init

    init(event: Event, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        let alliancesViewController = EventAlliancesViewController(event: event, dependencies: dependencies)

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
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAlliancesViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

private class EventAlliancesViewController: TBATableViewController {

    private let event: Event

    // MARK: - Observable

    typealias ManagedType = DistrictRanking
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    weak var delegate: EventAlliancesViewControllerDelegate?

    // MARK: - Init

    init(event: Event, dependencies: Dependencies) {
        self.event = event

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

        contextObserver.observeObject(object: event, state: .updated) { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = event.alliances.count
        if rows == 0 {
            showNoDataView()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EventAllianceTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventAllianceTableViewCell
        let alliance = event.alliances.object(at: indexPath.row) as! EventAlliance

        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: indexPath.row + 1)
        cell.teamKeySelected = { [weak self] (teamKey) in
            guard let context = self?.persistentContainer.viewContext else {
                return
            }
            let team = Team.insert(teamKey, in: context)
            self?.delegate?.teamSelected(team)
        }

        return cell
    }

}

extension EventAlliancesViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_alliances"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return event.alliances.count == 0
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventAlliances(key: event.key) { [self] (result, notModified) in
            guard case .success(let alliances) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(alliances)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension EventAlliancesViewController: Stateful {

    var noDataText: String? {
        return "No alliances for event"
    }

}
