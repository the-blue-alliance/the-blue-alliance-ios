import Foundation
import TBAKit
import UIKit
import CoreData

class EventAlliancesViewController: ContainerViewController {

    public var event: Event!

    internal var alliancesViewController: EventAlliancesTableViewController!
    @IBOutlet internal var alliancesView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel?.text = "Alliances"
        navigationDetailLabel?.text = "@ \(event.friendlyNameWithYear)"

        viewControllers = [alliancesViewController]
        containerViews = [alliancesView]
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventAlliancesEmbed" {
            alliancesViewController = segue.destination as! EventAlliancesTableViewController
            alliancesViewController.event = event
            alliancesViewController.persistentContainer = persistentContainer
            alliancesViewController.teamSelected = { [weak self] team in
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: team)
            }
        } else if segue.identifier == "TeamAtEventSegue" {
            let team = sender as! Team
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }

}

class EventAlliancesTableViewController: TBATableViewController {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var event: Event!
    var teamSelected: ((Team) -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Override automatic rowHeight - these will be smaller than 44 by default, and we want to open them up
        tableView.rowHeight = 44
        tableView.register(UINib(nibName: String(describing: EventAllianceTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventAllianceTableViewCell.reuseIdentifier)
    }
    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var alliancesRequest: URLSessionDataTask?
        alliancesRequest = TBAKit.sharedKit.fetchEventAlliances(key: event.key!, completion: { (alliances, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event alliances - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localAlliances = alliances?.map({ (modelAlliance) -> EventAlliance in
                    return EventAlliance.insert(with: modelAlliance, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.alliances = Set(localAlliances ?? []) as NSSet

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event alliances - database error")
                }
                self.removeRequest(request: alliancesRequest!)
            })
        })
        self.addRequest(request: alliancesRequest!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let alliances = dataSource?.fetchedResultsController.fetchedObjects, alliances.isEmpty {
            return true
        }
        return false
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<EventAlliance, EventAlliancesTableViewController>?

    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<EventAlliance> = EventAlliance.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: EventAllianceTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventAlliance>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }

}

extension EventAlliancesTableViewController: TableViewDataSourceDelegate {

    func configure(_ cell: EventAllianceTableViewCell, for object: EventAlliance, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.alliance = object
        cell.teamSelected = teamSelected
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No alliances for event")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
