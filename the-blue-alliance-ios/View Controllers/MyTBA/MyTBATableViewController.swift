import CoreData
import Crashlytics
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

public enum MyTBASection: String {
    case event = "Events"
    case team = "Teams"
    case match = "Matches"

    static func section(for modelType: MyTBAModelType) -> MyTBASection? {
        switch modelType {
        case .event:
            return .event
        case .team:
            return .team
        case .match:
            return .match
        default:
            return nil
        }
    }
}

protocol MyTBATableViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
    func teamSelected(_ team: Team)
    func matchSelected(_ match: Match)
}

/**
 MyTBATableViewController implements it's own NSFetchedResultsControllerDelegate, since we need to convert
 from a MyTBA model (Favorite, Subscription) in to a MyTBAEntity (Event, Team, Match)
 */
class MyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: TBATableViewController, NSFetchedResultsControllerDelegate {

    let myTBA: MyTBA
    weak var delegate: MyTBATableViewControllerDelegate?

    private var dataSource: UITableViewDiffableDataSource<MyTBASection, NSManagedObject>!
    private var _dataSource: TableViewDataSource<MyTBASection, NSManagedObject>!
    private var fetchedResultsController: NSFetchedResultsController<T>!

    // MARK: Init

    init(myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventTableViewCell.self)
        tableView.registerReusableCell(TeamTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)

        // Disable subscriptions
        if T.self == Favorite.self {
            setupDataSource()
            tableView.dataSource = _dataSource
            setupFetchedResultsController()
        } else if T.self == Subscription.self {
            DispatchQueue.main.async {
                self.showNoDataView()
                self.disableRefreshing()
            }
        }
    }

    // MARK: Data Source

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<MyTBASection, NSManagedObject>(tableView: tableView, cellProvider: { (tableView, indexPath, obj) -> UITableViewCell? in
            let fallbackCell = UITableViewCell()
            fallbackCell.textLabel?.text = obj.description

            // TODO: All Cell subclasses need gear icons
            // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/179

            if let event = obj as? Event {
                return MyTBATableViewController.tableView(tableView, cellForEvent: event, at: indexPath)
            } else if let team = obj as? Team {
                return MyTBATableViewController.tableView(tableView, cellForTeam: team, at: indexPath)
            } else if let match = obj as? Match {
                return MyTBATableViewController.tableView(tableView, cellForMatch: match, at: indexPath)
            } else {
                return fallbackCell
            }
        })
        _dataSource = TableViewDataSource(dataSource: dataSource)
        _dataSource.delegate = self
    }

    // MARK: NSFetchedResultsController

    private func setupFetchedResultsController() {
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
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var s = NSDiffableDataSourceSnapshot<MyTBASection, NSManagedObject>()
        for section in snapshot.sectionIdentifiers.compactMap({ $0 as? String }) {
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section)
                .compactMap { $0 as? NSManagedObjectID }
                .compactMap { fetchedResultsController.managedObjectContext.object(with: $0) }
                .compactMap { $0 as? T }
                .compactMap { $0.tbaObject }
            // Only add our section if we have items in the section
            if items.isEmpty {
                continue
            }

            guard let modelTypeRaw = Int(section) else {
                continue
            }
            guard let modelType = MyTBAModelType(rawValue: modelTypeRaw) else {
                continue
            }
            guard let sectionType = MyTBASection.section(for: modelType) else {
                continue
            }

            s.appendSections([sectionType])
            s.appendItems(items, toSection: sectionType)
        }
        dataSource.apply(s, animatingDifferences: false)
    }

    // MARK: Table View Cells

    private static func tableView(_ tableView: UITableView, cellForEvent event: Event, at indexPath: IndexPath) -> EventTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
        cell.viewModel = EventCellViewModel(event: event)
        return cell
    }

    private static func tableView(_ tableView: UITableView, cellForTeam team: Team, at indexPath: IndexPath) -> TeamTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TeamTableViewCell
        cell.viewModel = TeamCellViewModel(team: team)
        return cell
    }

    private static func tableView(_ tableView: UITableView, cellForMatch match: Match, at indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        cell.viewModel = MatchViewModel(match: match)
        return cell
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection sectionIndex: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[sectionIndex]
        return section.rawValue
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let obj = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if let event = obj as? Event {
            delegate?.eventSelected(event)
        } else if let team = obj as? Team {
            delegate?.teamSelected(team)
        } else if let match = obj as? Match {
            delegate?.matchSelected(match)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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

        var finalOperation: Operation!

        var operation: MyTBAOperation!
        operation = J.fetch(myTBA)() { [unowned self] (models, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let models = models as? [T.RemoteType] {
                    T.insert(models, in: context)
                    // Kickoff fetch for myTBA objects that don't exist
                    models.forEach({
                        self.fetchMyTBAObject($0, finalOperation)
                    })
                } else if error == nil {
                    // If we don't get any models and we don't have an error, we probably don't have any models upstream
                    context.deleteAllObjectsForEntity(entity: T.entity())
                }
            }, saved: {
                self.markRefreshSuccessful()
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        finalOperation = addRefreshOperations([operation])
    }

    private func fetchMyTBAObject(_ myTBAModel: MyTBAModel, _ dependentOperation: Operation) {
        guard let tbaKitOperation: TBAKitOperation = {
            switch myTBAModel.modelType {
            case .event:
                return self.fetchEvent(myTBAModel)
            case .team:
                return self.fetchTeam(myTBAModel)
            case .match:
                return self.fetchMatch(myTBAModel)
            default:
                return nil
            }
        }() else { return }
        dependentOperation.addDependency(tbaKitOperation)
        refreshOperationQueue.addOperation(tbaKitOperation)
    }

    func fetchEvent(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvent(key: myTBAModel.modelKey) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let event = try? result.get() {
                    Event.insert(event, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        return operation
    }

    func fetchTeam(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeam(key: myTBAModel.modelKey) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let team = try? result.get() {
                    Team.insert(team, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        return operation
    }

    func fetchMatch(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: myTBAModel.modelKey) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        return operation
    }

    internal func executeUpdate(_ myTBAModel: MyTBAModel) {
        guard let updateOperation: Operation = {
            let key = myTBAModel.modelKey
            switch myTBAModel.modelType {
            case .event:
                guard let event = Event.findOrFetch(in: persistentContainer.viewContext, matching: Event.predicate(key: key)) else {
                    return nil
                }
                return self.updateObject(event, for: myTBAModel)
            case .team:
                guard let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: Team.predicate(key: key)) else {
                    return nil
                }
                return self.updateObject(team, for: myTBAModel)
            case .match:
                guard let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: Match.predicate(key: key)) else {
                    return nil
                }
                return self.updateObject(match, for: myTBAModel)
            default:
                return nil
            }
            }() else { return }

        OperationQueue.main.addOperation(updateOperation)
    }

    private func updateObject(_ object: NSManagedObject, for model: MyTBAModel) -> Operation? {
        guard let section = MyTBASection.section(for: model.modelType) else {
            return nil
        }
        return BlockOperation {
            var snapshot = self.dataSource.snapshot()

            snapshot.insertSection(section, atIndex: model.modelType.rawValue)
            // Insert the object so it's in the same order as it's MyTBAEntity
            guard let obj = self.fetchedResultsController.fetchedObjects?.first(where: { (o) -> Bool in
                guard let modelKey = o.modelKey else {
                    return false
                }
                return o.modelType == model.modelType && modelKey == model.modelKey
            }) else { return }
            if let indexPath = self.fetchedResultsController.indexPath(forObject: obj) {
                snapshot.insertItem(object, inSection: section, atIndex: indexPath.row)
            } else {
                snapshot.appendItems([object], toSection: section)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
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
        let snapshot = dataSource.snapshot()
        if myTBA.isAuthenticated, snapshot.itemIdentifiers.isEmpty {
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
