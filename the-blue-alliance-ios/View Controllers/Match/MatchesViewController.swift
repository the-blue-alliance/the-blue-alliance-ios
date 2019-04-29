import CoreData
import Foundation
import TBAKit
import UIKit

protocol MatchesViewControllerDelegate: AnyObject {
    func matchSelected(_ match: Match)
}

class MatchesViewController: TBATableViewController {

    private let event: Event
    private let teamKey: TeamKey?

    weak var delegate: MatchesViewControllerDelegate?
    private var dataSource: TableViewDataSource<Match, MatchesViewController>!

    // MARK: - Init

    init(event: Event, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.teamKey = teamKey

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Match> = Match.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "compLevelSortOrder", ascending: true),
                                        NSSortDescriptor(key: "setNumber", ascending: true),
                                        NSSortDescriptor(key: "matchNumber", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "compLevelSortOrder", cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Match>) {
        if let teamKey = teamKey {
            request.predicate = NSPredicate(format: "event == %@ AND SUBQUERY(alliances, $a, ANY $a.teams.key == %@).@count > 0", event, teamKey.key!)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = dataSource.object(at: indexPath)
        delegate?.matchSelected(match)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
}

extension MatchesViewController: TableViewDataSourceDelegate {

    func title(for section: Int) -> String? {
        let firstMatch = dataSource.object(at: IndexPath(row: 0, section: section))
        return "\(firstMatch.compLevel?.level ?? firstMatch.compLevelString!) Matches"
    }

    func configure(_ cell: MatchTableViewCell, for object: Match, at indexPath: IndexPath) {
        cell.viewModel = MatchViewModel(match: object, teamKey: teamKey)
    }

}

extension MatchesViewController: Refreshable {

    // MARK: - Refreshable

    var refreshKey: String? {
        return "\(event.key!)_matches"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event matches until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        if let matches = dataSource.fetchedResultsController.fetchedObjects, matches.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchEventMatches(key: event.key!, completion: { (matches, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let matches = matches {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(matches)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension MatchesViewController: Stateful {

    var noDataText: String {
        return "No matches for event"
    }

}
