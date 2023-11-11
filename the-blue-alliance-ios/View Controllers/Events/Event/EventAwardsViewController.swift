import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Event, team: Team? = nil, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        let awardsViewController = EventAwardsViewController(event: event, team: team, dependencies: dependencies)

        super.init(viewControllers: [awardsViewController],
                   navigationTitle: "Awards",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   dependencies: dependencies)

        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event Awards: %@", [event.key])
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

class EventAwardsViewController: TBATableViewController {

    weak var delegate: EventAwardsViewControllerDelegate?

    private let event: Event
    private let team: Team?

    private var dataSource: TableViewDataSource<String, Award>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Award>!

    // MARK: - Init

    init(event: Event, team: Team? = nil, dependencies: Dependencies) {
        self.event = event
        self.team = team

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AwardTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, Award>(tableView: tableView) { (tableView, indexPath, award) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AwardTableViewCell
            cell.selectionStyle = .none
            cell.viewModel = AwardCellViewModel(award: award)
            cell.teamKeySelected = { [weak self] (teamKey) in
                guard let context = self?.persistentContainer.viewContext else {
                    return
                }
                let team = Team.insert(teamKey, in: context)
                self?.delegate?.teamSelected(team)
            }
            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()
        fetchRequest.sortDescriptors = [
            Award.typeSortDescriptor()
        ]
        if let team = team {
            fetchRequest.predicate = Award.teamEventPredicate(teamKey: team.key, eventKey: event.key)
        } else {
            fetchRequest.predicate = Award.eventPredicate(eventKey: event.key)
        }

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
    }

}

extension EventAwardsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key)_awards"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventAwards(key: event.key) { [self] (result, notModified) in
            guard case .success(let awards) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(awards)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension EventAwardsViewController: Stateful {

    var noDataText: String? {
        return "No awards for \(team != nil ? "team at event" : "event")"
    }

}
