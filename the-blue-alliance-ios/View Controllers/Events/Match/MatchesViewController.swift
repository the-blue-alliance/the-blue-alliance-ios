import Foundation
import UIKit
import TBAKit
import CoreData

class MatchesTableViewController: TBATableViewController {

    var event: Event!
    var team: Team?

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var matchSelected: ((Match) -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: MatchTableViewCell.reuseIdentifier)
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventMatches(key: event.key!, completion: { (matches, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event matches - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localMatches = matches?.map({ (modelMatch) -> Match in
                    return Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.matches = Set(localMatches ?? []) as NSSet

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event matches - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let matches = dataSource?.fetchedResultsController.fetchedObjects, matches.isEmpty {
            return true
        }
        return false
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<Match, MatchesTableViewController>?

    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<Match> = Match.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "compLevelInt", ascending: true),
                                        NSSortDescriptor(key: "setNumber", ascending: true),
                                        NSSortDescriptor(key: "matchNumber", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "compLevelInt", cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: MatchTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Match>) {
        if let team = team {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY redAlliance == %@ OR ANY blueAlliance == %@)", event, team, team)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = dataSource?.object(at: indexPath)
        if let match = match, let matchSelected = matchSelected {
            matchSelected(match)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

}

extension MatchesTableViewController: TableViewDataSourceDelegate {

    func title(for section: Int) -> String? {
        guard let dataSource = dataSource else {
            return nil
        }
        let firstMatch = dataSource.object(at: IndexPath(row: 0, section: section))
        return "\(firstMatch.compLevelString) Matches"
    }

    func configure(_ cell: MatchTableViewCell, for object: Match, at indexPath: IndexPath) {
        cell.team = team
        cell.match = object
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No matches for event")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
