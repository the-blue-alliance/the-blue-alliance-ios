import Foundation
import UIKit
import TBAKit
import CoreData

protocol MatchesViewControllerDelegate: AnyObject {
    func matchSelected(_ match: Match)
}

class MatchesViewController: TBATableViewController {

    private let event: Event
    private let team: Team?
    private weak var delegate: MatchesViewControllerDelegate?

    // MARK: - Init

    init(event: Event, team: Team? = nil, delegate: MatchesViewControllerDelegate, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.team = team
        self.delegate = delegate

        super.init(persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: MatchTableViewCell.reuseIdentifier)

        updateDataSource()
    }

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventMatches(key: event.key!, completion: { (matches, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event matches - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localMatches = matches?.map({ (modelMatch) -> Match in
                    return Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.matches = Set(localMatches ?? []) as NSSet

                backgroundContext.saveContext()
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

    fileprivate var dataSource: TableViewDataSource<Match, MatchesViewController>?

    fileprivate func setupDataSource() {
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
        if let match = match {
            delegate?.matchSelected(match)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

}

extension MatchesViewController: TableViewDataSourceDelegate {

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
