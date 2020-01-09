import CoreData
import Firebase
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private(set) var team: Team?
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Event, team: Team? = nil, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.team = team
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let awardsViewController = EventAwardsViewController(event: event, team: team, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        let navigationSubtitle: String = {
            if let team = team {
                return "\(team.teamNumberNickname) @ \(event.friendlyNameWithYear)"
            } else {
                return "@ \(event.friendlyNameWithYear)"
            }
        }()

        super.init(viewControllers: [awardsViewController],
                   navigationTitle: "Awards",
                   navigationSubtitle: navigationSubtitle,
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var parameters = [
            "event": event.key,
        ]
        if let team = team {
            parameters["team"] = team.key
        }
        Analytics.logEvent("event_awards", parameters: parameters)
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        if team == self.team {
            return
        }
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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

    init(event: Event, team: Team? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.team = team

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AwardTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, Award>(tableView: tableView) { (tableView, indexPath, award) -> UITableViewCell? in
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
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

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
        operation = tbaKit.fetchEventAwards(key: event.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let awards = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(awards)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}

extension EventAwardsViewController: Stateful {

    var noDataText: String {
        return "No awards for \(team != nil ? "team at event" : "event")"
    }

}
