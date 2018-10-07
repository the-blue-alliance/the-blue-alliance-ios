import Foundation
import CoreData
import UIKit

/**
 MyTBATableViewController implements it's on FRC/TableViewDataSource logic, since the existing abstraction
 won't work for this case, since we need to show one of three different types of cells (as opposed to a single
 type of cell, which TableViewDataSource *will* do for us)
 */
class MyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: TBATableViewController, Refreshable, NSFetchedResultsControllerDelegate {

    // let myTBAObjectSelected: ((T) -> ())
    private var backgroundFetchKeys: Set<String> = []

    // MARK: - Init

    init(persistentContainer: NSPersistentContainer) {
        super.init(persistentContainer: persistentContainer)
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

        setupFetchedResultsController()
    }

    // MARK: - Public methods

    public func clearFRC() {
        fetchedResultsController = nil

        DispatchQueue.main.async {
            try! self.fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        }
    }

    // MARK: - Refreshable

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
        if MyTBA.shared.isAuthenticated, let objs = fetchedResultsController?.fetchedObjects, objs.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        // I'd love to use MyTBAManaged's RemoteType here, but it doesn't seem like I can get it
        var request: URLSessionDataTask?
        request = J.fetch { (models, error) in
            let modelName = T.entityName.lowercased()

            if let error = error {
                self.showErrorAlert(with: "Unable to refresh \(modelName) - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            let reloadTableViewCompletion = {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            self.persistentContainer.performBackgroundTask({ [weak self] (backgroundContext) in
                let models = models as? [T.RemoteType]
                let bgctx = backgroundContext
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

                backgroundContext.saveOrRollback()
                self?.removeRequest(request: request!)
            })
        }
        addRequest(request: request!)
    }

    // MARK: FRC

    fileprivate var fetchedResultsController: NSFetchedResultsController<T>?

    fileprivate func setupFetchedResultsController() {
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

        guard let obj = fetchedResultsController?.object(at: indexPath) else {
            return fallbackCell
        }

        let myTBACell = self.tableView(tableView, cellForRowAt: indexPath, for: obj)

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
            return self.tableView(tableView, cellForRowAt: indexPath, for: event)
        case .team:
            guard let team = Team.findOrFetch(in: persistentContainer.viewContext, matching: predicate) else {
                return myTBACell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: team)
        case .match:
            guard let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: predicate) else {
                return myTBACell
            }
            return self.tableView(tableView, cellForRowAt: indexPath, for: match)
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
        let obj = fetchedResultsController?.object(at: indexPath)
        /*
        if let obj = obj {
            myTBAObjectSelected(obj)
        }
        */
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
