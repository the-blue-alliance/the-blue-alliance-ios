import Foundation
import CoreData
import UIKit

/**
 MyTBATableViewController implements it's on FRC/TableViewDataSource logic, since the existing abstraction
 won't work for this case, since we need to show one of three different types of cells (as opposed to a single
 type of cell, which TableViewDataSource *will* do for us)
 */
class MyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: TBATableViewController, NSFetchedResultsControllerDelegate {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            setupFetchedResultsController()
        }
    }
    var backgroundFetchKeys: Set<String> = []
    var myTBAObjectSelected: ((T) -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: LoadingTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: MatchTableViewCell.reuseIdentifier)
    }

    // MARK: - Public methods

    public func clearFRC() {
        fetchedResultsController = nil

        DispatchQueue.main.async {
            try! self.fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        // I'd love to use MyTBAManaged's RemoteType here, but it doesn't seem like I can get it
        var request: URLSessionDataTask?
        request = J.fetch { (models, error) in
            let modelName = T.entityName.lowercased()

            if let error = error {
                self.showErrorAlert(with: "Unable to refresh \(modelName) - \(error.localizedDescription)")
            }

            let reloadTableViewCompletion = {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            self.persistentContainer?.performBackgroundTask({ [weak self] (backgroundContext) in
                let models = models as? [T.RemoteType]
                let modelKeys = models?.map({ (model) -> String in
                    return model.modelKey
                }) ?? []
                let bgctx = backgroundContext

                // Find all keys to delete from current DB, since our refresh says they don't exist anymore upstream
                let deleteFetchRequest: NSFetchRequest = T.MyType.fetchRequest()
                deleteFetchRequest.predicate = NSPredicate(format: "NOT (modelKey IN %@)", modelKeys)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                print(deleteFetchRequest)

                for model in models ?? [] {
                    if self?.backgroundFetchKeys.contains(model.modelKey) ?? false {
                        continue
                    }

                    T.insert(with: model, in: bgctx)

                    let predicate = NSPredicate(format: "key == %@", model.modelKey)
                    switch model.modelType {
                    case .event:
                        if Event.findOrFetch(in: backgroundContext, matching: predicate) == nil {
                            self?.backgroundFetchKeys.insert(model.modelKey)
                            TBABackgroundService.backgroundFetchEvent(model.modelKey, in: backgroundContext, completion: { (_, _) in
                                self?.backgroundFetchKeys.remove(model.modelKey)
                                reloadTableViewCompletion()
                            })
                        }
                    case .team:
                        if Team.findOrFetch(in: backgroundContext, matching: predicate) == nil {
                            self?.backgroundFetchKeys.insert(model.modelKey)
                            TBABackgroundService.backgroundFetchTeam(model.modelKey, in: backgroundContext, completion: { (_, _) in
                                self?.backgroundFetchKeys.remove(model.modelKey)
                                reloadTableViewCompletion()
                            })
                        }
                    case .match:
                        let match = Match.findOrFetch(in: backgroundContext, matching: predicate)
                        // Fetch our match if it doesn't exist or we don't have scores
                        if match?.redScore == nil || match?.blueScore == nil {
                            self?.backgroundFetchKeys.insert(model.modelKey)
                            TBABackgroundService.backgroundFetchMatch(model.modelKey, in: backgroundContext, completion: { (_, _) in
                                self?.backgroundFetchKeys.remove(model.modelKey)
                                reloadTableViewCompletion()
                            })
                        }
                    }
                }

                // Delete old models from DB
                let result = try! self?.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: backgroundContext) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID] ?? []
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self!.persistentContainer.viewContext])

                backgroundContext.saveContext()
                self?.removeRequest(request: request!)
            })
        }
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if MyTBA.shared.isAuthenticated, let objs = fetchedResultsController?.fetchedObjects, objs.isEmpty {
            return true
        }
        return false
    }

    // MARK: FRC

    fileprivate var fetchedResultsController: NSFetchedResultsController<T>?

    fileprivate func setupFetchedResultsController() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modelType", ascending: true), NSSortDescriptor(key: "modelKey", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "modelType", cacheName: nil)
        fetchedResultsController!.delegate = self
        try! fetchedResultsController!.performFetch()

        DispatchQueue.main.async {
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fallbackCell = UITableViewCell()
        fallbackCell.textLabel?.text = "----"
        fallbackCell.selectionStyle = .none

        guard let obj = fetchedResultsController?.object(at: indexPath) else {
            return fallbackCell
        }

        let myTBACell = self.tableView(tableView, for: obj)

        guard let modelType = MyTBAModelType(rawValue: obj.modelType!) else {
            return myTBACell
        }

        let predicate = NSPredicate(format: "key == %@", obj.modelKey!)

        // TODO: All Cell subclasses need gear icons
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/179

        switch modelType {
        case .event:
            guard let event = Event.findOrFetch(in: persistentContainer.viewContext, matching: predicate) else {
                return myTBACell
            }
            return self.tableView(tableView, for: event)
        case .team:
            guard let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: predicate) else {
                return myTBACell
            }
            return self.tableView(tableView, for: team)
        case .match:
            guard let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: predicate) else {
                return myTBACell
            }
            return self.tableView(tableView, for: match)
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
                hideNoDataView()
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

        guard let modelType = MyTBAModelType(rawValue: obj.modelType!) else {
            return nil
        }
        switch modelType {
        case .event:
            return "Event"
        case .team:
            return "Team"
        case .match:
            return "Match"
        }
    }

    // MARK: - Table Views

    func tableView(_ tableView: UITableView, for myTBA: MyTBAEntity) -> LoadingTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.reuseIdentifier) as? LoadingTableViewCell ?? LoadingTableViewCell(style: .default, reuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        cell.keyLabel.text = myTBA.modelKey
        cell.backgroundFetchActivityIndicator.isHidden = !backgroundFetchKeys.contains(myTBA.modelKey!)
        return cell
    }

    func tableView(_ tableView: UITableView, for event: Event) -> EventTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier) as? EventTableViewCell ?? EventTableViewCell(style: .default, reuseIdentifier: EventTableViewCell.reuseIdentifier)
        cell.event = event
        return cell
    }

    func tableView(_ tableView: UITableView, for team: Team) -> TeamTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.reuseIdentifier) as? TeamTableViewCell ?? TeamTableViewCell(style: .default, reuseIdentifier: TeamTableViewCell.reuseIdentifier)
        cell.team = team
        return cell
    }

    func tableView(_ tableView: UITableView, for match: Match) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.reuseIdentifier) as? MatchTableViewCell ?? MatchTableViewCell(style: .default, reuseIdentifier: MatchTableViewCell.reuseIdentifier)
        cell.match = match
        return cell
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = fetchedResultsController?.object(at: indexPath)
        if let obj = obj, let myTBAObjectSelected = myTBAObjectSelected {
            myTBAObjectSelected(obj)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }

    // MARK: No Data methods

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No myTBA \(J.arrayKey)")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
