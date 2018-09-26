import CoreData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private let event: Event
    private let team: Team?

    private var awardsViewController: EventAwardsViewController!

    override var viewControllers: [ContainableViewController] {
        return [awardsViewController]
    }

    // MARK: - Init

    init(event: Event, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team

        super.init(persistentContainer: persistentContainer)

        awardsViewController = EventAwardsViewController(event: event, team: team, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "Awards"
        if let team = team {
            navigationSubtitle = "Team \(team.teamNumber) @ \(event.friendlyNameWithYear)"
        } else {
            navigationSubtitle = "@ \(event.friendlyNameWithYear)"
        }
    }

}

extension EventAwardsContainerViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        if team == self.team {
            return
        }
        let teamAtEventViewController = TeamAtEventViewController(team: team,
                                                                  event: event,
                                                                  persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

protocol EventAwardsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

class EventAwardsViewController: TBATableViewController {

    private let event: Event
    private let team: Team?
    private weak var delegate: EventAwardsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Award, EventAwardsViewController>!

    // MARK: - Init

    init(event: Event, team: Team? = nil, delegate: EventAwardsViewControllerDelegate, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team
        self.delegate = delegate

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: AwardTableViewCell.self), bundle: nil), forCellReuseIdentifier: AwardTableViewCell.reuseIdentifier)
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventAwards(key: event.key!, completion: { (awards, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event awards - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localAwards = awards?.map({ (modelAward) -> Award in
                    return Award.insert(with: modelAward, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.awards = Set(localAwards ?? []) as NSSet

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let awards = dataSource.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "awardType", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: AwardTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Award>) {
        if let team = team {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY recipients.team == %@)", event, team)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

}

extension EventAwardsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: AwardTableViewCell, for object: Award, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.award = object
        cell.teamSelected = { [unowned self] (team) in
            self.delegate?.teamSelected(team)
        }
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: String(format: "No awards for %@", team != nil ? "team at event" : "event"))
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
