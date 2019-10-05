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

    private let event: Event
    private let teamKey: TeamKey?
    private var myTBA: MyTBA

    var query: MatchQueryOptions = MatchQueryOptions(sort: MatchQueryOptions.MatchSortOptions(reverse: false), filter: MatchQueryOptions.MatchFilterOptions(favorites: false))

    weak var delegate: MatchesViewControllerDelegate?
    private var dataSource: TableViewDataSource<Match, MatchesViewController>!

    lazy var matchQueryBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_filter"), style: .plain, target: self, action: #selector(showFilter))
    }()
    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [matchQueryBarButtonItem]
    }

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.teamKey = teamKey
        self.myTBA = myTBA

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Match> = Match.fetchRequest()

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "compLevelSortOrder", cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Match>) {
        let ascending = !query.sort.reverse
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Match.compLevelSortOrder), ascending: ascending),
                                        NSSortDescriptor(key: #keyPath(Match.setNumber), ascending: ascending),
                                        NSSortDescriptor(key: #keyPath(Match.matchNumber), ascending: ascending)]

        let matchPredicate: NSPredicate = {
            if let teamKey = teamKey {
                // TODO: Use KeyPath https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/162
                return NSPredicate(format: "%K == %@ AND SUBQUERY(%K, $a, ANY $a.teams.key == %@).@count > 0",
                                   #keyPath(Match.event), event,
                                   #keyPath(Match.alliances), teamKey.key!)
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
            let favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)
            return NSPredicate(format: "SUBQUERY(%K, $a, ANY $a.teams.key IN %@).@count > 0",
                               #keyPath(Match.alliances), favoriteTeamKeys)
        }()

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchPredicate, myTBAFavoritesPredicate].compactMap({ $0 }))
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = dataSource.object(at: indexPath)
        delegate?.matchSelected(match)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: - Public Methods

    func updateWithQuery(query: MatchQueryOptions) {
        self.query = query
        updateDataSource()
    }

    // MARK: - Interface Methods

    @objc func showFilter(_ sender: UIBarButtonItem) {
        delegate?.showFilter()
    }

}

extension MatchesViewController: TableViewDataSourceDelegate {

    func title(for section: Int) -> String? {
        let firstMatch = dataSource.object(at: IndexPath(row: 0, section: section))
        return "\(firstMatch.compLevel?.level ?? firstMatch.compLevelString!) Matches"
    }

    func configure(_ cell: MatchTableViewCell, for object: Match, at indexPath: IndexPath) {
        var baseTeamKeys: Set<String> = Set()
        if let teamKey = teamKey {
            baseTeamKeys.insert(teamKey.key!)
        }
        if query.filter.favorites {
            // TODO: Fetching this is EXPENSIVE - we should probably fetch/set when our query changes
            let favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)
            baseTeamKeys.formUnion(favoriteTeamKeys)
        }
        cell.viewModel = MatchViewModel(match: object, baseTeamKeys: Array(baseTeamKeys))
    }

}

extension MatchesViewController: Refreshable {

    // MARK: - Refreshable

    var refreshKey: String? {
        let key = event.getValue(\Event.key!)
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
        if let matches = dataSource.fetchedResultsController.fetchedObjects, matches.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventMatches(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let matches = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(matches)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        })
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
