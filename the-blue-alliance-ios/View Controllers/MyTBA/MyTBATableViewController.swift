import CoreData
import Foundation
import TBAKit
import UIKit

protocol MyTBATableViewControllerDelegate: AnyObject {
    func myTBAObjectSelected(_ myTBAObject: MyTBAEntity)
}

/**
 MyTBATableViewController implements it's on FRC/TableViewDataSource logic, since the existing abstraction
 won't work for this case, since we need to show one of three different types of cells (as opposed to a single
 type of cell, which TableViewDataSource *will* do for us)
 */
class MyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: TBATableViewController, NSFetchedResultsControllerDelegate {

    let myTBA: MyTBA
    weak var delegate: MyTBATableViewControllerDelegate?

    private(set) var backgroundFetchKeys: Set<String> = []

    // MARK: - Init

    init(myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(LoadingTableViewCell.self)
        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)

        // Disable subscriptions
        if T.self == Favorite.self {
            setupFetchedResultsController()
        } else if T.self == Subscription.self {
            DispatchQueue.main.async {
                self.showNoDataView()
                self.disableRefreshing()
            }
        }
    }

    // MARK: - Public methods

    public func clearFRC() {
        fetchedResultsController = nil

        DispatchQueue.main.async {
            try! self.fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
    }


    // MARK: FRC

    fileprivate var fetchedResultsController: NSFetchedResultsController<T>?

    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelTypeRaw), ascending: true),
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelKey), ascending: true)
        ]

        // Only show supported myTBA entities (basically, exclude team@event)
        fetchRequest.predicate = NSPredicate(format: "%K IN %@",
                                             #keyPath(MyTBAEntity.modelTypeRaw),
                                             [MyTBAModelType.event, MyTBAModelType.team, MyTBAModelType.match].map({ $0.rawValue }))

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: #keyPath(MyTBAEntity.modelTypeRaw), cacheName: nil)
        fetchedResultsController!.delegate = self
        try! fetchedResultsController!.performFetch()

        tableView.dataSource = self
        tableView.reloadData()
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fallbackCell = UITableViewCell()
        fallbackCell.textLabel?.text = "----"

        guard let obj = fetchedResultsController?.object(at: indexPath) else {
            return fallbackCell
        }

        let myTBACell = self.tableView(tableView, cellForRowAt: indexPath, for: obj)

        // TODO: All Cell subclasses need gear icons
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/179

        switch obj.modelType {
        case .event:
            guard let event = obj.tbaObject as? Event else {
                return myTBACell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: event)
        case .team:
            guard let team = obj.tbaObject as? Team else {
                return myTBACell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: team)
        case .match:
            guard let match = obj.tbaObject as? Match else {
                return myTBACell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: match)
        default:
            return myTBACell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsController?.sections?.count ?? 0
        if sections == 0 {
            showNoDataView()
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        if let sections = fetchedResultsController?.sections {
            rows = sections[section].numberOfObjects
            if rows == 0 {
                showNoDataView()
            } else {
                removeNoDataView()
            }
        } else {
            showNoDataView()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections, section < sections.count else {
            return nil
        }

        let rows = sections[section].numberOfObjects
        if rows == 0 {
            return nil
        }

        guard let obj = fetchedResultsController?.object(at: IndexPath(item: 0, section: section)) else {
            return nil
        }

        switch obj.modelType {
        case .event:
            return "Event"
        case .team:
            return "Team"
        case .match:
            return "Match"
        default:
            return "Other"
        }
    }

    // MARK: - Table Views

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, for myTBA: MyTBAEntity) -> LoadingTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LoadingTableViewCell
        cell.keyLabel.text = myTBA.modelKey
        cell.backgroundFetchActivityIndicator.isHidden = !backgroundFetchKeys.contains(myTBA.modelKey!)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, for event: Event) -> EventTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
        cell.viewModel = EventCellViewModel(event: event)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, for team: Team) -> TeamTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
        cell.viewModel = TeamCellViewModel(team: team)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, for match: Match) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        cell.viewModel = MatchViewModel(match: match)
        return cell
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let myTBAObject = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        delegate?.myTBAObjectSelected(myTBAObject)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }

    // MARK: - Fetch Methods

    @objc func refresh() {
        if !myTBA.isAuthenticated {
            return
        }

        // Disable subscription refresh
        if T.self == Subscription.self {
            return
        }

        removeNoDataView()

        var request: URLSessionDataTask?
        request = J.fetch(myTBA)() { (models, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let models = models as? [T.RemoteType] {
                    let myTBAObjects = T.insert(models, in: context) as! [T]
                    // Kickoff fetch for myTBA objects that don't exist
                    for myTBAObject in myTBAObjects {
                        let key = myTBAObject.modelKey!
                        switch myTBAObject.modelType {
                        case .event:
                            self.fetchEvent(key)
                        case .team:
                            self.fetchTeam(key)
                        case .match:
                            self.fetchMatch(key)
                        default:
                            break
                        }
                    }
                } else if error == nil {
                    // If we don't get any models and we don't have an error, we probably don't have any models upstream
                    context.deleteAllObjectsForEntity(entity: T.entity())
                }
            }, saved: {
                self.markRefreshSuccessful()
            })
            self.removeRequest(request: request!)
        }
        addRequest(request: request!)
    }

    @discardableResult
    func fetchEvent(_ key: String) -> URLSessionDataTask {
        var request: URLSessionDataTask?
        request = tbaKit.fetchEvent(key: key) { (event, error) in
            let context = self.persistentContainer.newBackgroundContext()

            context.performChangesAndWait({
                if let event = event {
                    Event.insert(event, in: context)
                }
            }, saved: {
                self.tbaKit.setLastModified(request!)
            })

            self.backgroundFetchKeys.remove(key)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        backgroundFetchKeys.insert(key)
        return request!
    }

    @discardableResult
    func fetchTeam(_ key: String) -> URLSessionDataTask {
        var request: URLSessionDataTask?
        request = tbaKit.fetchTeam(key: key) { (team, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let team = team {
                    Team.insert(team, in: context)
                }
            }, saved: {
                self.tbaKit.setLastModified(request!)
            })

            self.backgroundFetchKeys.remove(key)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        backgroundFetchKeys.insert(key)
        return request!
    }

    @discardableResult
    func fetchMatch(_ key: String) -> URLSessionDataTask {
        var request: URLSessionDataTask?
        request = tbaKit.fetchMatch(key: key) { (match, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = match {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.setLastModified(request!)
            })

            self.backgroundFetchKeys.remove(key)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        backgroundFetchKeys.insert(key)
        return request!
    }

}

extension MyTBATableViewController: Refreshable {

    var refreshKey: String? {
        return J.arrayKey
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        if myTBA.isAuthenticated, let objs = fetchedResultsController?.fetchedObjects, objs.isEmpty {
            return true
        }
        return false
    }

}

extension MyTBATableViewController: Stateful {

    var noDataText: String {
        if T.self == Favorite.self {
            return "No \(J.arrayKey)"
        } else {
            return "Subscriptions are not yet supported"
        }
    }

}
