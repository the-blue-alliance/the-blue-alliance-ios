import CoreData
import Foundation
import TBAKit
import UIKit

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func awardsSelected()
    func matchSelected(_ match: Match)
}

private enum TeamSummarySections: Int, CaseIterable {
    case eventInfo
    case nextMatch
    case playoffInfo
    case qualInfo
    case lastMatch
}

private enum EventInfoRow {
    case status(status: String)
    case awards(count: Int)
}

private enum QualInfoRow {
    case rank(rank: Int, total: Int)
    case record(wlt: WLT, dqs: Int?)
    case average(average: NSNumber)
    case breakdown(rankingInfo: String)
}

private enum PlayoffInfoRow {
    case alliance(allianceStatus: String)
    case record(wlt: WLT)
    case average(average: NSNumber)
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
                reloadData()

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

    fileprivate var eventInfoRows: [EventInfoRow] = []
    fileprivate var qualInfoRows: [QualInfoRow] = []
    fileprivate var playoffInfoRows: [PlayoffInfoRow] = []

    var nextMatch: Match? {
        if let nextMatchKey = eventStatus?.nextMatchKey, let match = Match.forKey(nextMatchKey, in: persistentContainer.viewContext) {
            return match
        }
        return nil
    }

    var lastMatch: Match? {
        if let lastMatchKey = eventStatus?.lastMatchKey, let match = Match.forKey(lastMatchKey, in: persistentContainer.viewContext) {
            return match
        }
        return nil
    }

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = TeamSummarySections.allCases.count
        if eventInfoRows.count == 0 {
            sections -= 1
        }
        if !shouldShowNextMatch {
            sections -= 1
        }
        if playoffInfoRows.count == 0 {
            sections -= 1
        }
        if qualInfoRows.count == 0 {
            sections -= 1
        }
        if !shouldShowLastMatch {
            sections -= 1
        }

        // Show/hide no data
        if sections == 0 {
            showNoDataView()
        } else {
            removeNoDataView()
        }

        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = normalizedSection(section)
        if section == TeamSummarySections.eventInfo {
            return eventInfoRows.count
        } else if section == TeamSummarySections.qualInfo {
            return qualInfoRows.count
        } else if section == TeamSummarySections.playoffInfo {
            return playoffInfoRows.count
        }
        return 1 // 1 cell for next/last match
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = normalizedSection(indexPath.section)
        if section == TeamSummarySections.eventInfo {
            let row = eventInfoRows[indexPath.row]
            let cell: UITableViewCell = {
                switch row {
                case .status(let status):
                    return self.tableView(
                        tableView,
                        reverseSubtitleCellWithTitle: "Status",
                        subtitle: status,
                        at: indexPath
                    )
                case .awards(let count):
                    return self.tableView(tableView, cellForAwardCount: count, at: indexPath)
                }
            }()
            return cell
        } else if section == TeamSummarySections.qualInfo {
            let row = qualInfoRows[indexPath.row]
            let cell: UITableViewCell = {
                switch row {
                case .rank(let rank, let total):
                    return self.tableView(tableView, cellForRank: rank, totalTeams: total, at: indexPath)
                case .record(let record, let dqs):
                    return self.tableView(tableView, cellForRecord: record, dqs: dqs, at: indexPath)
                case .average(let average):
                    return self.tableView(tableView, cellForAverage: average, at: indexPath)
                case .breakdown(let breakdown):
                    return self.tableView(tableView, cellForBreakdown: breakdown, at: indexPath)
                }
            }()
            return cell
        } else if section == TeamSummarySections.playoffInfo {
            let row = playoffInfoRows[indexPath.row]
            let cell: UITableViewCell = {
                switch row {
                case .alliance(let allianceStatus):
                    return self.tableView(tableView, cellForAllianceStatus: allianceStatus, at: indexPath)
                case .record(let record):
                    return self.tableView(tableView, cellForRecord: record, dqs: nil, at: indexPath)
                case .average(let average):
                    return self.tableView(tableView, cellForAverage: average, at: indexPath)
                }
            }()
            return cell
        } else if section == TeamSummarySections.nextMatch, let match = nextMatch {
            return self.tableView(tableView, cellForMatch: match, at: indexPath)
        } else if section == TeamSummarySections.lastMatch, let match = lastMatch {
            return self.tableView(tableView, cellForMatch: match, at: indexPath)
        }
        return UITableViewCell()
    }

    private func tableView(_ tableView: UITableView, cellForAwardCount awardCount: Int, at indexPath: IndexPath) -> UITableViewCell {
        let recordString = "Won \(awardCount) award\(awardCount > 1 ? "s" : "")"
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Awards", subtitle: recordString, at: indexPath)
        // Allow us to push to what awards the team won
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        return cell
    }

    private func tableView(_ tableView: UITableView, cellForRank rank: Int, totalTeams total: Int, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Rank",
            subtitle: "\(rank)\(rank.suffix) (of \(total))",
            at: indexPath
        )
    }

    private func tableView(_ tableView: UITableView, cellForRecord record: WLT, dqs: Int?, at indexPath: IndexPath) -> UITableViewCell {
        let subtitle: String = {
            if let dqs = dqs, dqs > 0 {
                return "\(record.stringValue) (\(dqs) DQ)"
            }
            return record.stringValue
        }()
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Record",
            subtitle: subtitle,
            at: indexPath
        )
    }

    private func tableView(_ tableView: UITableView, cellForAverage average: NSNumber, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Average",
            subtitle: average.stringValue,
            at: indexPath
        )
    }

    private func tableView(_ tableView: UITableView, cellForAllianceStatus allianceStatus: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Alliance", subtitle: allianceStatus, at: indexPath)
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

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = normalizedSection(section)
        if section == TeamSummarySections.nextMatch {
            return "Next Match"
        } else if section == TeamSummarySections.playoffInfo {
            return "Playoffs"
        } else if section == TeamSummarySections.qualInfo {
            return "Qualifications"
        } else if section == TeamSummarySections.lastMatch {
            return "Most Recent Match"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = normalizedSection(indexPath.section)
        if section == TeamSummarySections.eventInfo {
            let rowType = eventInfoRows[indexPath.row]
            switch rowType {
            case .awards:
                delegate?.awardsSelected()
            default:
                break
            }
        } else if section == TeamSummarySections.nextMatch, let match = nextMatch {
            delegate?.matchSelected(match)
        } else if section == TeamSummarySections.lastMatch, let match = lastMatch {
            delegate?.matchSelected(match)
        }
    }

    // MARK: Private Methods

    private func reloadData() {
        // Event Info
        var eventInfoRows: [EventInfoRow] = []

        // https://github.com/the-blue-alliance/the-blue-alliance/blob/5337b3b7767f909e251f7aff04d6a0f73b5820f0/helpers/event_team_status_helper.py#L36
        if let status = eventStatus?.playoff?.status, let level = eventStatus?.playoff?.level {
            let compLevel = MatchCompLevel(rawValue: level)?.level ?? level
            if status == "playing", let record = eventStatus?.playoff?.currentRecord {
                eventInfoRows.append(EventInfoRow.status(status: "Currently \(record.stringValue) in the \(compLevel)"))
            } else if status == "eliminated" {
                eventInfoRows.append(EventInfoRow.status(status: "Eliminated in the \(compLevel)"))
            } else if status == "won" {
                if level == "f" {
                    eventInfoRows.append(EventInfoRow.status(status: "Won the event"))
                } else {
                    eventInfoRows.append(EventInfoRow.status(status: "Won the \(compLevel)"))
                }
            }
        }

        // Awards
        if teamAwards.count > 0 {
            eventInfoRows.append(EventInfoRow.awards(count: teamAwards.count))
        }

        self.eventInfoRows = eventInfoRows

        // Qual Status
        var qualInfoRows: [QualInfoRow] = []

        // Rank
        if let rank = eventStatus?.qual?.ranking?.rank, let total = eventStatus?.qual?.numTeams {
            qualInfoRows.append(QualInfoRow.rank(rank: rank.intValue, total: total.intValue))
        }

        // Record
        if let record = eventStatus?.qual?.ranking?.record {
            qualInfoRows.append(QualInfoRow.record(wlt: record, dqs: eventStatus?.qual?.ranking?.dq?.intValue))
        }

        // Average
        if let average = eventStatus?.qual?.ranking?.qualAverage {
            qualInfoRows.append(QualInfoRow.average(average: average))
        }

        // Breakdown
        if let rankingInfo = eventStatus?.qual?.ranking?.rankingInfoString {
            qualInfoRows.append(QualInfoRow.breakdown(rankingInfo: rankingInfo))
        }

        self.qualInfoRows = qualInfoRows

        // Playoff Status
        var playoffInfoRows: [PlayoffInfoRow] = []

        // Alliance
        if let allianceStatus = eventStatus?.allianceStatus, allianceStatus != "--" {
            playoffInfoRows.append(PlayoffInfoRow.alliance(allianceStatus: allianceStatus))
        }

        // Record
        if let record = eventStatus?.playoff?.record {
            playoffInfoRows.append(PlayoffInfoRow.record(wlt: record))
        }

        // Average
        if let average = eventStatus?.playoff?.playoffAverage {
            playoffInfoRows.append(PlayoffInfoRow.average(average: average))
        }

        self.playoffInfoRows = playoffInfoRows

        self.tableView.reloadData()
    }

    private func normalizedSection(_ section: Int) -> TeamSummarySections {
        var section = section
        if eventInfoRows.count == 0, section >= TeamSummarySections.eventInfo.rawValue {
            section += 1
        }
        if !shouldShowNextMatch, section >= TeamSummarySections.nextMatch.rawValue {
            section += 1
        }
        if playoffInfoRows.count == 0, section >= TeamSummarySections.playoffInfo.rawValue {
            section += 1
        }
        if qualInfoRows.count == 0, section >= TeamSummarySections.qualInfo.rawValue {
            section += 1
        }
        if !shouldShowLastMatch, section >= TeamSummarySections.lastMatch.rawValue {
            section += 1
        }
        return TeamSummarySections(rawValue: section)!
    }

    private var shouldShowNextMatch: Bool {
        // Only show next match if the event is currently being played
        return nextMatch != nil && event.isHappeningNow
    }

    private var shouldShowLastMatch: Bool {
        // Only show last match if the event is currently being played
        return lastMatch != nil && event.isHappeningNow
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

        // Refresh Team@Event status
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
