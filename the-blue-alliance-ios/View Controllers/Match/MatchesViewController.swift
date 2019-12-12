import CoreData
import Crashlytics
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

    init(event: Event, team: Team? = nil, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.team = team
        self.myTBA = myTBA

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(MatchTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource

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
        let dataSource = UITableViewDiffableDataSource<String, Match>(tableView: tableView) { [weak self] (tableView, indexPath, match) -> UITableViewCell? in
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
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<Match> = Match.fetchRequest()
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "compLevelSortOrder", cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    private func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Match>) {
        let ascending = !query.sort.reverse
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Match.compLevelSortOrder), ascending: ascending),
                                        NSSortDescriptor(key: #keyPath(Match.setNumber), ascending: ascending),
                                        NSSortDescriptor(key: #keyPath(Match.matchNumber), ascending: ascending)]

        let matchPredicate: NSPredicate = {
            if let team = team {
                // TODO: Use KeyPath https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/162
                return NSPredicate(format: "%K == %@ AND SUBQUERY(%K, $a, ANY $a.teams.key == %@).@count > 0",
                                   #keyPath(Match.event), event,
                                   #keyPath(Match.alliances), team.key)
            } else {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(Match.event), event)
            }
        }()

        // Filter for only Matches with myTBA Favorites
        let myTBAFavoritesPredicate: NSPredicate? = {
            guard query.filter.favorites else {
                return nil
            }
            return NSPredicate(format: "SUBQUERY(%K, $a, ANY $a.teams.key IN %@).@count > 0",
                               #keyPath(Match.alliances), favoriteTeamKeys)
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
        let key = event.getValue(\Event.key)
        return "\(key)_matches"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event matches until the event is over
        return event.getValue(\Event.endDate)?.endOfDay()
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
        operation = tbaKit.fetchEventMatches(key: event.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let matches = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(matches)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}

extension MatchesViewController: Stateful {

    var noDataText: String {
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
        let queryViewController = MatchQueryOptionsViewController(query: matchesViewController.query, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        queryViewController.delegate = self

        let nav = UINavigationController(rootViewController: queryViewController)
        nav.modalPresentationStyle = .formSheet

        navigationController?.present(nav, animated: true, completion: nil)
    }

    func updateQuery(query: MatchQueryOptions) {
        matchesViewController.updateWithQuery(query: query)
    }

}
