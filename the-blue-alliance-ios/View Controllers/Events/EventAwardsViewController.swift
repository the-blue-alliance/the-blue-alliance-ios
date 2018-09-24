import UIKit
import CoreData
import TBAKit

class EventAwardsViewController: ContainerViewController {

    let event: Event
    let team: Team?

    init(event: Event, team: Team?, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team

        super.init(persistentContainer: persistentContainer)

        // TODO: Think about... making these factories. These inline blocks blow
        let awardsViewController = EventAwardsTableViewController(event: event, team: team, teamSelected: { (selectedTeam) in
            if team == selectedTeam {
                return
            }
            let teamAtEventViewController = TeamAtEventViewController(team: selectedTeam,
                                                                      event: self.event,
                                                                      persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
        }, persistentContainer: persistentContainer)

        viewControllers = [awardsViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "Awards"
        if let team = team {
            navigationDetailLabel.text = "Team \(team.teamNumber) @ \(event.friendlyNameWithYear)"
        } else {
            navigationDetailLabel.text = "@ \(event.friendlyNameWithYear)"
        }
    }

}

class EventAwardsTableViewController: TBATableViewController {

    let event: Event
    let team: Team?
    let teamSelected: ((Team) -> ())?

    override var persistentContainer: NSPersistentContainer {
        didSet {
            updateDataSource()
        }
    }

    // MARK: - View Lifecycle

    init(event: Event, team: Team? = nil, teamSelected: ((Team) -> ())? = nil, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team
        self.teamSelected = teamSelected

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        if let awards = dataSource?.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<Award, EventAwardsTableViewController>?

    fileprivate func setupDataSource() {
        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "awardType", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: AwardTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Award>) {
        if let team = team {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY recipients.team == %@)", event, team)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

}

extension EventAwardsTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: AwardTableViewCell, for object: Award, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.award = object
        cell.teamSelected = teamSelected
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
