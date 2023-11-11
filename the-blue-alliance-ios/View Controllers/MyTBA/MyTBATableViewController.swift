import CoreData
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

public enum MyTBASection {
    case event
    case team
    case match

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

    private var dataSource: TableViewDataSource<MyTBASection, NSManagedObject>!
    private var fetchedResultsController: NSFetchedResultsController<T>!

    // MARK: Init

    init(myTBA: MyTBA, dependencies: Dependencies) {
        self.myTBA = myTBA

        super.init(dependencies: dependencies)
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

        tableView.dataSource = dataSource
        setupDataSource()

        // Disable subscriptions
        setupFetchedResultsController()
    }

    // MARK: Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<MyTBASection, NSManagedObject>(tableView: tableView, cellProvider: { (tableView, indexPath, obj) -> UITableViewCell? in
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
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    // MARK: NSFetchedResultsController

    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)

        // Only show supported myTBA entities (basically, exclude team@event)
        fetchRequest.predicate = T.supportedModelTypePredicate()
        fetchRequest.sortDescriptors = T.sortDescriptors()

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistentContainer.viewContext,
                                                              sectionNameKeyPath: T.modelTypeKeyPath(),
                                                              cacheName: nil)
        fetchedResultsController!.delegate = self
        try! fetchedResultsController!.performFetch()
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var s = NSDiffableDataSourceSnapshot<MyTBASection, NSManagedObject>()
        for section in snapshot.sectionIdentifiers.compactMap({ $0 as? String }) {
            var items = snapshot.itemIdentifiersInSection(withIdentifier: section)
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

            // Sort our items before inserting
            if let events = items as? [Event] {
                items = events.sorted().sorted(by: { (lhs, rhs) -> Bool in
                    // Second pass - sort by years in reverse order
                    return lhs.year > rhs.year
                })
            } else if let teams = items as? [Team] {
                items = teams.sorted()
            } else if let matches = items as? [Match] {
                items = matches.sorted()
            }

            s.appendSections([sectionType])
            s.appendItems(items, toSection: sectionType)
        }
        dataSource.apply(s, animatingDifferences: false)
    }

    // MARK: Table View Cells

    private static func tableView(_ tableView: UITableView, cellForEvent event: Event, at indexPath: IndexPath) -> EventTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventTableViewCell
        cell.viewModel = EventCellViewModel(name: event.safeNameYear, location: event.locationString, dateString: event.dateString)
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
        let indexPath = IndexPath(item: 0, section: sectionIndex)
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        if item is Event {
            return "Events"
        } else if item is Team {
            return "Teams"
        } else if item is Match {
            return "Matches"
        } else {
            return nil
        }
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
            }, errorRecorder: errorRecorder)
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
        operation = tbaKit.fetchEvent(key: myTBAModel.modelKey) { [self] (result, notModified) in
            guard case .success(let object) = result, let event = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Event.insert(event, in: context)
            }, saved: { [unowned self] in
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: errorRecorder)
        }
        return operation
    }

    func fetchTeam(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeam(key: myTBAModel.modelKey) { [self] (result, notModified) in
            guard case .success(let object) = result, let team = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(team, in: context)
            }, saved: { [unowned self] in
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: errorRecorder)
        }
        return operation
    }

    func fetchMatch(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: myTBAModel.modelKey) { [self] (result, notModified) in
            guard case .success(let object) = result, let match = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Match.insert(match, in: context)
            }, saved: { [unowned self] in
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(myTBAModel)
            }, errorRecorder: errorRecorder)
        }
        return operation
    }

    internal func executeUpdate(_ myTBAModel: MyTBAModel) {
        let key = myTBAModel.modelKey
        guard let op: Operation = { [self] in
            switch myTBAModel.modelType {
            case .event:
                if let event = Event.findOrFetch(in: persistentContainer.viewContext, matching: Event.predicate(key: key)) {
                    return updateObject(event, for: myTBAModel)
                }
                return nil
            case .team:
                if let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: Team.predicate(key: key)) {
                    return updateObject(team, for: myTBAModel)
                }
                return nil
            case .match:
                if let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: Match.predicate(key: key)) {
                    return updateObject(match, for: myTBAModel)
                }
                return nil
            default:
                return nil
            }
        }() else { return }

        OperationQueue.main.addOperation(op)
    }

    private func updateObject(_ object: NSManagedObject, for model: MyTBAModel) -> Operation? {
        guard let section = MyTBASection.section(for: model.modelType) else {
            return nil
        }
        return BlockOperation {
            var snapshot = self.dataSource.snapshot()

            if !snapshot.sectionIdentifiers.contains(section) {
                if snapshot.numberOfSections <= model.modelType.rawValue {
                    snapshot.appendSections([section])
                } else {
                    let s = snapshot.sectionIdentifiers[model.modelType.rawValue]
                    snapshot.insertSections([section], beforeSection: s)
                }
            }

            if !snapshot.itemIdentifiers(inSection: section).contains(object) {
                snapshot.appendItems([object], toSection: section)
            }

            var items = snapshot.itemIdentifiers(inSection: section)
            // Sort our items before inserting
            if let events = items as? [Event] {
                items = events.sorted().sorted(by: { (lhs, rhs) -> Bool in
                    // Second pass - sort by years in reverse order
                    return lhs.year > rhs.year
                })
            } else if let teams = items as? [Team] {
                items = teams.sorted()
            } else if let matches = items as? [Match] {
                items = matches.sorted()
            }
            snapshot.deleteItems(items)
            snapshot.appendItems(items, toSection: section)

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
        if myTBA.isAuthenticated, dataSource.isDataSourceEmpty {
            return true
        }
        return false
    }

}

extension MyTBATableViewController: Stateful {

    var noDataText: String? {
        return "No \(J.arrayKey)"
    }

}
