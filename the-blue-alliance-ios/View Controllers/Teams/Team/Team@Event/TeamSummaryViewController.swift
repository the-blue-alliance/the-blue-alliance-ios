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
    case nextMatchKey(key: String)
    case nextMatch(match: Match)
    case lastMatchKey(key: String)
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
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }

                contextObserver.observeObject(object: eventStatus, state: .updated) { (_, _) in
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            } else {
                contextObserver.observeInsertions { [unowned self] (eventStatuses) in
                    self.eventStatus = eventStatuses.first
                }
            }
        }
    }

    fileprivate var summaryRows: [TeamSummaryRow] {
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

        // From here on, we only show this data if the event is currently happening
        guard event.isHappeningNow else {
            return summaryRows
        }

        // Next Match
        if let nextMatchKey = eventStatus?.nextMatchKey {
            if let match = Match.forKey(nextMatchKey, in: persistentContainer.viewContext) {
                summaryRows.append(TeamSummaryRow.nextMatch(match: match))
            } else {
                summaryRows.append(TeamSummaryRow.nextMatchKey(key: nextMatchKey))
                fetchMatch(nextMatchKey)
            }
        }

        // Last Match
        if let lastMatchKey = eventStatus?.lastMatchKey {
            if let match = Match.forKey(lastMatchKey, in: persistentContainer.viewContext) {
                summaryRows.append(TeamSummaryRow.lastMatch(match: match))
            } else {
                summaryRows.append(TeamSummaryRow.lastMatchKey(key: lastMatchKey))
                fetchMatch(lastMatchKey)
            }
        }

        return summaryRows
    }

    // MARK: - Observable

    typealias ManagedType = EventStatus
    lazy var contextObserver: CoreDataContextObserver<EventStatus> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventStatus.event), event, #keyPath(EventStatus.teamKey), teamKey)
    }()

    private var backgroundFetchKeys: Set<String> = []

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
        tableView.registerReusableCell(LoadingTableViewCell.self)
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
            case .nextMatchKey(let key):
                return self.tableView(tableView, loadingCellForKey: key, at: indexPath)
            case .nextMatch(let match):
                return self.tableView(tableView, cellForMatch: match, at: indexPath)
            case .lastMatchKey(let key):
                return self.tableView(tableView, loadingCellForKey: key, at: indexPath)
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
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Qual Record", subtitle: record.displayString(), at: indexPath)
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
        cell.setHTMLSubtitle(text: subtitle)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, loadingCellForKey key: String, at indexPath: IndexPath) -> LoadingTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LoadingTableViewCell
        cell.keyLabel.text = key
        cell.backgroundFetchActivityIndicator.isHidden = false
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = summaryRows[indexPath.row]
        switch row {
        case .nextMatchKey, .lastMatchKey:
            return 44.0
        default:
            return UITableView.automaticDimension
        }
    }

}

extension TeamSummaryViewController: Refreshable {

    var refreshKey: String? {
        return "\(teamKey.key!)@\(event.key!)_status"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team summary until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return eventStatus == nil || teamAwards.count == 0
    }

    @objc func refresh() {
        removeNoDataView()

        // Refresh team status
        var teamStatusRequest: URLSessionDataTask?
        teamStatusRequest = tbaKit.fetchTeamStatus(key: teamKey.key!, eventKey: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let status):
                    if let status = status {
                        let event = context.object(with: self.event.objectID) as! Event
                        event.insert(status)
                    } else if !notModified {
                        // TODO: Delete status, move back up our hiearchy
                    }
                default:
                    break
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: teamStatusRequest!)
            })
            self.removeRequest(request: teamStatusRequest!)
        })
        addRequest(request: teamStatusRequest!)

        // Refresh awards
        var awardsRequest: URLSessionDataTask?
        awardsRequest = tbaKit.fetchTeamAwards(key: teamKey.key!, eventKey: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let awards = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(awards, teamKey: self.teamKey.key!)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: awardsRequest!)
            })
            self.removeRequest(request: awardsRequest!)
        })
        addRequest(request: awardsRequest!)
    }

    func fetchMatch(_ key: String) {
        // Already fetching match key
        guard !backgroundFetchKeys.contains(key) else {
            return
        }

        var request: URLSessionDataTask?
        request = tbaKit.fetchMatch(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.setLastModified(request!)
            })

            self.backgroundFetchKeys.remove(key)

            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        backgroundFetchKeys.insert(key)
    }

}

extension TeamSummaryViewController: Stateful {

    var noDataText: String {
        return "No status for team at event"
    }

}
