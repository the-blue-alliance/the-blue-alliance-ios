import CoreData
import Foundation
import MyTBAKit
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
        fallbackCell.textLabel?.text = obj.modelKey

        // TODO: All Cell subclasses need gear icons
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/179

        switch obj.modelType {
        case .event:
            guard let event = obj.tbaObject as? Event else {
                return fallbackCell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: event)
        case .team:
            guard let team = obj.tbaObject as? Team else {
                return fallbackCell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: team)
        case .match:
            guard let match = obj.tbaObject as? Match else {
                return fallbackCell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: match)
        default:
            return fallbackCell
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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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

        var finalOperation: Operation!

        var operation: MyTBAOperation!
        operation = J.fetch(myTBA)() { [unowned self] (models, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let models = models as? [T.RemoteType] {
                    T.insert(models, in: context)
                    // Kickoff fetch for myTBA objects that don't exist
                    let operations = models.compactMap({ (myTBAObject) -> TBAKitOperation? in
                        let key = myTBAObject.modelKey
                        switch myTBAObject.modelType {
                        case .event:
                            return self.fetchEvent(key)
                        case .team:
                            return self.fetchTeam(key)
                        case .match:
                            return self.fetchMatch(key)
                        default:
                            return nil
                        }
                    })
                    for op in operations {
                        finalOperation.addDependency(op)
                    }
                    self.refreshOperationQueue.addOperations(operations, waitUntilFinished: false)
                } else if error == nil {
                    // If we don't get any models and we don't have an error, we probably don't have any models upstream
                    context.deleteAllObjectsForEntity(entity: T.entity())
                }
            }, saved: {
                self.markRefreshSuccessful()
            })
        }
        finalOperation = addRefreshOperations([operation])
    }

    @discardableResult
    func fetchEvent(_ key: String) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvent(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let event = try? result.get() {
                    Event.insert(event, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            })
        }
        return operation
    }

    @discardableResult
    func fetchTeam(_ key: String) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeam(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let team = try? result.get() {
                    Team.insert(team, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            })
        }
        return operation
    }

    @discardableResult
    func fetchMatch(_ key: String) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            })
        }
        return operation
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
