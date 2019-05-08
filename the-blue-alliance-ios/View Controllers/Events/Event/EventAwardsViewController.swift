import CoreData
import Firebase
import MyTBAKit
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
            "event": self.event.key!,
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

    private let event: Event
    private let teamKey: TeamKey?

    weak var delegate: EventAwardsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Award, EventAwardsViewController>!

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.teamKey = teamKey

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "awardType", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Award>) {
        if let teamKey = teamKey {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY recipients.teamKey.key == %@)", event, teamKey.key!)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

}

extension EventAwardsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: AwardTableViewCell, for object: Award, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.viewModel = AwardCellViewModel(award: object)
        cell.teamKeySelected = { [weak self] (teamKey) in
            guard let context = self?.persistentContainer.viewContext else {
                return
            }
            let teamKey = TeamKey.insert(withKey: teamKey, in: context)
            self?.delegate?.teamKeySelected(teamKey)
        }
    }

}

extension EventAwardsViewController: Refreshable {

    var refreshKey: String? {
        return "\(event.key!)_awards"
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        if let awards = dataSource.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventAwards(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let awards = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(awards)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension EventAwardsViewController: Stateful {

    var noDataText: String {
        return "No awards for \(teamKey != nil ? "team at event" : "event")"
    }

}
