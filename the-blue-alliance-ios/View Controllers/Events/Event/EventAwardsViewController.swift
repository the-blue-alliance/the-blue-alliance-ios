import CoreData
import Firebase
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private(set) var teamKey: TeamKey?
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.teamKey = teamKey
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let awardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        let navigationSubtitle: String = {
            if let teamKey = teamKey {
                return "Team \(teamKey.teamNumber) @ \(event.friendlyNameWithYear)"
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
            "event": event.key!,
        ]
        if let teamKey = teamKey {
            parameters["team"] = teamKey.key!
        }
        Analytics.logEvent("event_awards", parameters: parameters)
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        if teamKey == self.teamKey {
            return
        }
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, myTBA: myTBA, showDetailEvent: false, showDetailTeam: true, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamKeySelected(_ teamKey: TeamKey)
}

class EventAwardsViewController: TBATableViewController {

    weak var delegate: EventAwardsViewControllerDelegate?

    private let event: Event
    private let teamKey: TeamKey?

    private var dataSource: TableViewDataSource<String, Award>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Award>!

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.teamKey = teamKey

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
                let teamKey = TeamKey.insert(withKey: teamKey, in: context)
                self?.delegate?.teamKeySelected(teamKey)
            }
            return cell
        }
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Award.awardType), ascending: true)]
        if let teamKey = teamKey {
            // TODO: Use KeyPath https://github.com/the-blue-alliance/the-blue-alliance-ios/pull/169
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND (ANY recipients.teamKey.key == %@)",
                                                 #keyPath(Award.event), event,
                                                 teamKey.key!)
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@",
                                                 #keyPath(Award.event), event)
        }

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

}

extension EventAwardsViewController: Refreshable {

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
        return "\(key)_awards"
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
        operation = tbaKit.fetchEventAwards(key: event.key!) { (result, notModified) in
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
        return "No awards for \(teamKey != nil ? "team at event" : "event")"
    }

}
