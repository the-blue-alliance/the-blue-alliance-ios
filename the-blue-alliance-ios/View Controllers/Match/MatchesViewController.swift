import CoreData
import Foundation
import TBAData
import TBAKit
import MyTBAKit
import UIKit

protocol MatchesViewControllerDelegate: AnyObject {
    func showFilter()
    func matchSelected(_ match: Match)
}

class MatchesViewController: TBATableViewController {

    weak var delegate: MatchesViewControllerDelegate?
    var query: MatchQueryOptions = MatchQueryOptions.defaultQuery()

    private let event: Event
    private let team: Team?
    private var myTBA: MyTBA

    private var dataSource: TableViewDataSource<String, Match>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<Match>!

    private var favoriteTeamKeys: [String] = []

    lazy var matchQueryBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage.sortFilterIcon, style: .plain, target: self, action: #selector(showFilter))
    }()
    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [matchQueryBarButtonItem]
    }

    // MARK: - Init

    init(event: Event, team: Team? = nil, myTBA: MyTBA, dependencies: Dependencies) {
        self.event = event
        self.team = team
        self.myTBA = myTBA

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(MatchTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        updateInterface()
    }

    private func updateInterface() {
        if query.isDefault {
            matchQueryBarButtonItem.image = UIImage.sortFilterIcon
        } else {
            matchQueryBarButtonItem.image = UIImage.sortFilterIconActive
        }
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, Match>(tableView: tableView) { [weak self] (tableView, indexPath, match) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell

            var baseTeamKeys: Set<String> = Set()
            if let team = self?.team {
                baseTeamKeys.insert(team.key)
            }
            if let query = self?.query, query.filter.favorites, let favoriteTeamKeys = self?.favoriteTeamKeys {
                baseTeamKeys.formUnion(favoriteTeamKeys)
            }
            cell.viewModel = MatchViewModel(match: match, baseTeamKeys: Array(baseTeamKeys))

            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<Match> = Match.fetchRequest()
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: Match.compLevelSortOrderKeyPath(), cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
    }

    private func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Match>) {
        let ascending = !query.sort.reverse
        request.sortDescriptors = Match.sortDescriptors(ascending: ascending)

        let matchPredicate: NSPredicate = {
            if let team = team {
                return Match.eventTeamPredicate(eventKey: event.key, teamKey: team.key)
            } else {
                return Match.eventPredicate(eventKey: event.key)
            }
        }()

        // Filter for only Matches with myTBA Favorites
        let myTBAFavoritesPredicate: NSPredicate? = {
            guard query.filter.favorites else {
                return nil
            }
            return Match.teamKeysPredicate(teamKeys: favoriteTeamKeys)
        }()

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchPredicate, myTBAFavoritesPredicate].compactMap({ $0 }))
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        guard let firstMatch = fetchedResultsController.dataSource.itemIdentifier(for: IndexPath(row: 0, section: section)) else {
            return "Matches"
        }
        return "\(firstMatch.compLevel?.level ?? firstMatch.compLevelString) Matches"
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let match = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.matchSelected(match)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: - Public Methods

    func updateWithQuery(query: MatchQueryOptions) {
        self.query = query
        // Save favoriteTeamKeys when query changes - since this can be expensive
        favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)

        updateInterface()
        updateDataSource()
    }

    // MARK: - Interface Methods

    @objc func showFilter(_ sender: UIBarButtonItem) {
        delegate?.showFilter()
    }

}

extension MatchesViewController: Refreshable {

    // MARK: - Refreshable

    var refreshKey: String? {
        return "\(event.key)_matches"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event matches until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        // If we've changed our `filter` query option, an empty list is a valid state
        if !query.filter.isDefault {
            return false
        }
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventMatches(key: event.key) { [self] (result, notModified) in
            guard case .success(let matches) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(matches)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension MatchesViewController: Stateful {

    var noDataText: String? {
        if query.isDefault {
            return "No matches for event"
        } else {
            return "No matches matching filter options"
        }
    }

}

protocol MatchesViewControllerQueryable: ContainerViewController, MatchQueryOptionsDelegate {
    var myTBA: MyTBA { get }
    var matchesViewController: MatchesViewController { get }

    func showFilter()
}

extension MatchesViewControllerQueryable {

    func showFilter() {
        let queryViewController = MatchQueryOptionsViewController(query: matchesViewController.query, myTBA: myTBA, dependencies: dependencies)
        queryViewController.delegate = self

        let nav = UINavigationController(rootViewController: queryViewController)
        nav.modalPresentationStyle = .formSheet

        navigationController?.present(nav, animated: true, completion: nil)
    }

    func updateQuery(query: MatchQueryOptions) {
        matchesViewController.updateWithQuery(query: query)
    }

}
