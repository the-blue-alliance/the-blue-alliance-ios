import CoreData
import Foundation
import TBAKit
import UIKit

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func awardsSelected()
    func matchSelected(_ match: Match)
}

private enum TeamSummaryRow {
    case rank(rank: Int)
    case awards(count: Int)
    case pit // only during CMP, and if they exist
    case record(wlt: WLT) // don't show record for 2015, because no wins
    case alliance(allianceStatus: String)
    case status(overallStatus: String)
    case breakdown(rankingInfo: String)
    case nextMatch(match: Match)
    case lastMatch(match: Match)
}

class TeamSummaryViewController: TBATableViewController {

    private let teamKey: TeamKey
    private let event: Event

    weak var delegate: TeamSummaryViewControllerDelegate?

    var teamAwards: Set<Award> {
        guard let awards = event.awards else {
            return []
        }
        return awards.filtered(using: NSPredicate(format: "%K == %@ AND (ANY recipients.teamKey.key == %@)",
                                                  #keyPath(Award.event), event,
                                                  teamKey.key!)) as? Set<Award> ?? []
    }

    private var eventStatus: EventStatus? {
        didSet {
            if let eventStatus = eventStatus {
                contextObserver.observeObject(object: eventStatus, state: .updated) { [weak self] (_, _) in
                    self?.reloadData()
                }
            } else {
                contextObserver.observeInsertions { [weak self] (eventStatuses) in
                    self?.eventStatus = eventStatuses.first
                }
            }
        }
    }

    fileprivate var summaryRows: [TeamSummaryRow] = []

    // MARK: - Observable

    typealias ManagedType = EventStatus
    lazy var contextObserver: CoreDataContextObserver<EventStatus> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventStatus.event), event,
                           #keyPath(EventStatus.teamKey), teamKey)
    }()

    init(teamKey: TeamKey, event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Since we leverage didSet, we need to do this *after* initilization
        eventStatus = EventStatus.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows: Int = summaryRows.count
        if rows == 0 {
            showNoDataView()
        } else {
            removeNoDataView()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = summaryRows[indexPath.row]
        let cell: UITableViewCell = {
            switch row {
            case .rank(let rank):
                return self.tableView(tableView, cellForRank: rank, at: indexPath)
            case .awards(let count):
                return self.tableView(tableView, cellForAwardCount: count, at: indexPath)
            case .record(let record):
                return self.tableView(tableView, cellForRecord: record, at: indexPath)
            case .alliance(let allianceStatus):
                return self.tableView(tableView, cellForAllianceStatus: allianceStatus, at: indexPath)
            case .status(let status):
                return self.tableView(tableView, cellForStatus: status, at: indexPath)
            case .breakdown(let breakdown):
                return self.tableView(tableView, cellForBreakdown: breakdown, at: indexPath)
            case .nextMatch(let match):
                return self.tableView(tableView, cellForMatch: match, at: indexPath)
            case .lastMatch(let match):
                return self.tableView(tableView, cellForMatch: match, at: indexPath)
            default:
                return UITableViewCell()
            }
        }()
        return cell
    }

    private func tableView(_ tableView: UITableView, cellForRank rank: Int, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Rank", subtitle: "\(rank)\(rank.suffix)", at: indexPath)
    }

    private func tableView(_ tableView: UITableView, cellForAwardCount awardCount: Int, at indexPath: IndexPath) -> UITableViewCell {
        let recordString = "Won \(awardCount) award\(awardCount > 1 ? "s" : "")"
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Awards", subtitle: recordString, at: indexPath)
        // Allow us to push to what awards the team won
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        return cell
    }

    private func tableView(_ tableView: UITableView, cellForRecord record: WLT, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Qual Record", subtitle: record.stringValue, at: indexPath)
    }

    private func tableView(_ tableView: UITableView, cellForAllianceStatus allianceStatus: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Alliance", subtitle: allianceStatus, at: indexPath)
    }

    private func tableView(_ tableView: UITableView, cellForStatus status: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Team Status", subtitle: status, at: indexPath)
    }

    private func tableView(_ tableView: UITableView, cellForBreakdown breakdown: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Ranking Breakdown", subtitle: breakdown, at: indexPath)
    }

    private func tableView(_ tableView: UITableView, reverseSubtitleCellWithTitle title: String, subtitle: String, at indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel.text = title

        // Strip our subtitle string of HTML tags - they're expensive to render and useless.
        let sanitizedSubtitle = subtitle.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        cell.subtitleLabel.text = sanitizedSubtitle

        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, cellForMatch match: Match, at indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        cell.viewModel = MatchViewModel(match: match, teamKey: teamKey)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let rowType = summaryRows[indexPath.row]
        switch rowType {
        case .awards:
            delegate?.awardsSelected()
        case .nextMatch(let match), .lastMatch(let match):
            delegate?.matchSelected(match)
        default:
            break
        }
    }

    // MARK: Private Methods

    private func reloadData() {
        var summaryRows: [TeamSummaryRow] = []

        // Rank
        if let rank = eventStatus?.qual?.ranking?.rank {
            summaryRows.append(TeamSummaryRow.rank(rank: rank.intValue))
        }

        // Awards
        if teamAwards.count > 0 {
            summaryRows.append(TeamSummaryRow.awards(count: teamAwards.count))
        }

        // TODO: Add support for Pits
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/163

        // Record
        if let record = eventStatus?.qual?.ranking?.record, event.year != 2015 {
            summaryRows.append(TeamSummaryRow.record(wlt: record))
        }

        // Alliance
        if let allianceStatus = eventStatus?.allianceStatus {
            summaryRows.append(TeamSummaryRow.alliance(allianceStatus: allianceStatus))
        }

        // Team Status
        if let overallStatus = eventStatus?.overallStatus {
            summaryRows.append(TeamSummaryRow.status(overallStatus: overallStatus))
        }

        // Breakdown
        if let rankingInfo = eventStatus?.qual?.ranking?.rankingInfoString {
            summaryRows.append(TeamSummaryRow.breakdown(rankingInfo: rankingInfo))
        }

        // We only show this data if the event is currently happening
        if event.isHappeningNow {
            // Next Match
            if let nextMatchKey = eventStatus?.nextMatchKey,
                let match = Match.forKey(nextMatchKey, in: persistentContainer.viewContext) {
                summaryRows.append(TeamSummaryRow.nextMatch(match: match))
            }

            // Last Match
            if let lastMatchKey = eventStatus?.lastMatchKey,
                let match = Match.forKey(lastMatchKey, in: persistentContainer.viewContext) {
                summaryRows.append(TeamSummaryRow.lastMatch(match: match))
            }
        }

        self.summaryRows = summaryRows
        self.tableView.reloadData()
    }

}

extension TeamSummaryViewController: Refreshable {

    var refreshKey: String? {
        return "\(teamKey.getValue(\TeamKey.key!))@\(event.getValue(\Event.key!))_status"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team summary until the event is over
        return event.getValue(\Event.endDate)?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return eventStatus == nil || teamAwards.count == 0
    }

    @objc func refresh() {
        var finalOperation: Operation!

        // Refresh team status
        var teamStatusOperation: TBAKitOperation!
        teamStatusOperation = tbaKit.fetchTeamStatus(key: teamKey.key!, eventKey: event.key!, completion: { (result, notModified) in
            switch result {
            case .success(let status):
                if let status = status {
                    // Kickoff refreshes for our Match objects, add them as dependents for reloading data
                    self.refreshStatusMatches(status, finalOperation)

                    let context = self.persistentContainer.newBackgroundContext()
                    context.performChangesAndWait({
                        let event = context.object(with: self.event.objectID) as! Event
                        event.insert(status)
                    }, saved: {
                        self.markTBARefreshSuccessful(self.tbaKit, operation: teamStatusOperation)
                    })
                } else if !notModified {
                    // TODO: Delete status, move back up our hiearchy
                }
            default:
                break
            }
        })

        // Refresh awards
        let teamKeyKey = teamKey.key!
        var awardsOperation: TBAKitOperation!
        awardsOperation = tbaKit.fetchTeamAwards(key: teamKeyKey, eventKey: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let awards = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(awards, teamKey: teamKeyKey)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(awardsOperation)
            })
        })

        let reloadOperation = BlockOperation { [weak self] in
            self?.reloadData()
        }
        finalOperation = addRefreshOperations([teamStatusOperation, awardsOperation])
        reloadOperation.addDependency(finalOperation)
        OperationQueue.main.addOperation(reloadOperation)
    }

    func refreshStatusMatches(_ status: TBAEventStatus, _ reloadOperation: Operation?) {
        let ops = [status.lastMatchKey, status.nextMatchKey].compactMap({ $0 }).compactMap { [weak self] in
            return self?.fetchMatch($0)
        }
        guard ops.count > 0 else {
            return
        }
        for op in ops {
            reloadOperation?.addDependency(op)
        }
        refreshOperationQueue.addOperations(ops, waitUntilFinished: false)
    }

    func fetchMatch(_ key: String) -> TBAKitOperation? {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            })
        }
        return operation
    }

}

extension TeamSummaryViewController: Stateful {

    var noDataText: String {
        return "No status for team at event"
    }

}
