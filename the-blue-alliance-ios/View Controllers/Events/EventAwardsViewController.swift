import CoreData
import TBAKit
import UIKit

class EventAwardsContainerViewController: ContainerViewController {

    private let event: Event
    private let team: Team?

    // MARK: - Init

    init(event: Event, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team

        let awardsViewController = EventAwardsViewController(event: event, team: team, persistentContainer: persistentContainer)

        super.init(viewControllers: [awardsViewController],
                   persistentContainer: persistentContainer)

        awardsViewController.delegate = self
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

class EventAwardsViewController: TBATableViewController, Refreshable {

    private let event: Event
    private let team: Team?

    weak var delegate: EventAwardsViewControllerDelegate?
    private var dataSource: TableViewDataSource<Award, EventAwardsViewController>!

    // MARK: - Init

    init(event: Event, team: Team? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    var initialRefreshKey: String? {
        return "\(event.key!)_awards"
    }

    var isDataSourceEmpty: Bool {
        if let awards = dataSource.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }

    func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventAwards(key: event.key!, completion: { (awards, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event awards - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localAwards = awards?.map({ (modelAward) -> Award in
                    return Award.insert(with: modelAward, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.awards = Set(localAwards ?? []) as NSSet

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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
        cell.viewModel = AwardCellViewModel(award: object)
        cell.teamSelected = { [unowned self] (teamKey) in
            let team = Team.insert(withKey: teamKey, in: self.persistentContainer.viewContext)
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
