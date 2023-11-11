import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func teamInfoSelected(_ team: Team)
    func matchSelected(_ match: Match)
}

private enum TeamSummarySection: Int {
    case teamInfo
    case eventInfo
    case nextMatch
    case playoffInfo
    case qualInfo
    case lastMatch
}

private enum TeamSummaryItem: Hashable {
    case teamInfo(team: Team)
    case status(status: String)
    case rank(rank: Int, total: Int)
    case record(wlt: WLT, dqs: Int? = nil)
    case average(average: Double)
    case breakdown(rankingInfo: String)
    case alliance(allianceStatus: String)
    case match(match: Match, team: Team? = nil)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .teamInfo(let team):
            hasher.combine(team)
        case .status(let status):
            hasher.combine(status)
        case .rank(let rank, let total):
            hasher.combine(rank)
            hasher.combine(total)
        case .record(let wlt, let dqs):
            hasher.combine(wlt)
            hasher.combine(dqs)
        case .average(let average):
            hasher.combine(average)
        case .breakdown(let rankingInfo):
            hasher.combine(rankingInfo)
        case .alliance(let allianceStatus):
            hasher.combine(allianceStatus)
        case .match(let match, let team):
            hasher.combine(match)
            hasher.combine(team)
        }
    }

    static func == (lhs: TeamSummaryItem, rhs: TeamSummaryItem) -> Bool {
        switch (lhs, rhs) {
        case (.teamInfo(let lhsTeam), .teamInfo(let rhsTeam)):
            return lhsTeam == rhsTeam
        case (.status(let lhsStatus), .status(let rhsStatus)):
            return lhsStatus == rhsStatus
        case (.rank(let lhsRank, let lhsTotal), .rank(let rhsRank, let rhsTotal)):
            return lhsRank == rhsRank && lhsTotal == rhsTotal
        case (.record(let lhsWlt, let lhsDqs), .record(let rhsWlt, let rhsDqs)):
            return lhsWlt.wins == rhsWlt.wins && lhsWlt.losses == rhsWlt.losses && lhsWlt.ties == rhsWlt.ties && lhsDqs == rhsDqs
        case (.average(let lhsAverage), .average(let rhsAverage)):
            return lhsAverage == rhsAverage
        case (.breakdown(let lhsRankingInfo), .breakdown(let rhsRankingInfo)):
            return lhsRankingInfo == rhsRankingInfo
        case (.alliance(let lhsAllianceStatus), .alliance(let rhsAllianceStatus)):
            return lhsAllianceStatus == rhsAllianceStatus
        case (.match(let lhsMatch, let lhsTeam), .match(let rhsMatch, let rhsTeam)):
            return lhsMatch == rhsMatch && lhsTeam == rhsTeam
        default:
            return false
        }
    }
}

class TeamSummaryViewController: TBATableViewController {

    weak var delegate: TeamSummaryViewControllerDelegate?

    private let team: Team
    private let event: Event

    private var dataSource: TableViewDataSource<TeamSummarySection, TeamSummaryItem>!

    private var eventStatus: EventStatus? {
        didSet {
            if let eventStatus = eventStatus {
                contextObserver.observeObject(object: eventStatus, state: .updated) { (_, _) in
                    self.executeUpdate(self.updateEventStatusItems)
                }
            } else {
                contextObserver.observeInsertions { (eventStatuses) in
                    self.eventStatus = eventStatuses.first
                    self.executeUpdate(self.updateEventStatusItems)
                }
            }
        }
    }

    private func executeUpdate(_ update: @escaping () -> ()) {
        OperationQueue.main.addOperation {
            update()
        }
    }

    // MARK: - Observable

    typealias ManagedType = EventStatus
    lazy var contextObserver: CoreDataContextObserver<EventStatus> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    lazy var observerPredicate: NSPredicate = {
        return EventStatus.predicate(eventKey: event.key, teamKey: team.key)
    }()

    init(team: Team, event: Event, dependencies: Dependencies) {
        self.team = team
        self.event = event

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.registerReusableCell(InfoTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        // Since we leverage didSet, we need to do this *after* initilization
        eventStatus = EventStatus.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)

        executeUpdate(updateTeamInfo)
        executeUpdate(updateEventStatusItems)
        executeUpdate(updateNextMatchItem)
        executeUpdate(updateLastMatchItem)
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<TeamSummarySection, TeamSummaryItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .teamInfo(let team):
                return TeamSummaryViewController.tableView(tableView, cellForTeam: team, at: indexPath)
            case .status(let status):
                return TeamSummaryViewController.tableView(tableView, reverseSubtitleCellWithTitle: "Status", subtitle: status, at: indexPath)
            case .rank(let rank, let total):
                return TeamSummaryViewController.tableView(tableView, cellForRank: rank, totalTeams: total, at: indexPath)
            case .record(let record, let dqs):
                return TeamSummaryViewController.tableView(tableView, cellForRecord: record, dqs: dqs, at: indexPath)
            case .average(let average):
                return TeamSummaryViewController.tableView(tableView, cellForAverage: average, at: indexPath)
            case .breakdown(let breakdown):
                return TeamSummaryViewController.tableView(tableView, cellForBreakdown: breakdown, at: indexPath)
            case .alliance(let allianceStatus):
                return TeamSummaryViewController.tableView(tableView, cellForAllianceStatus: allianceStatus, at: indexPath)
            case .match(let match, let team):
                return TeamSummaryViewController.tableView(tableView, cellForMatch: match, team: team, at: indexPath)
            }
        })
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func updateTeamInfo() {
        var snapshot = dataSource.snapshot()

        let teamInfoSummaryItem = TeamSummaryItem.teamInfo(team: team)

        snapshot.deleteSections([.teamInfo])
        snapshot.insertSection(.teamInfo, atIndex: TeamSummarySection.teamInfo.rawValue)
        snapshot.appendItems([teamInfoSummaryItem], toSection: .teamInfo)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateEventStatusItems() {
        var snapshot = dataSource.snapshot()

        // MARK: - Summary

        let teamStatusSummaryItem: TeamSummaryItem? = {
            // https://github.com/the-blue-alliance/the-blue-alliance/blob/5337b3b7767f909e251f7aff04d6a0f73b5820f0/helpers/event_team_status_helper.py#L36
            if let status = eventStatus?.playoff?.status, let level = eventStatus?.playoff?.level {
                let compLevel = MatchCompLevel(rawValue: level)?.level ?? level
                if status == "playing", let record = eventStatus?.playoff?.currentRecord {
                    return .status(status: "Currently \(record.stringValue) in the \(compLevel)")
                } else if status == "eliminated" {
                    return .status(status: "Eliminated in the \(compLevel)")
                } else if status == "won" {
                    if level == "f" {
                        return .status(status: "Won the event")
                    } else {
                        return .status(status: "Won the \(compLevel)")
                    }
                }
            }
            return nil
        }()

        let hasEventInfoSection = snapshot.indexOfSection(.eventInfo) != nil
        let eventInfoItems = hasEventInfoSection ? snapshot.itemIdentifiers(inSection: .eventInfo) : []
        let existingTeamStatusSummaryItems = eventInfoItems.filter({ switch $0 { case .status(_): return true; default: return false } })
        snapshot.deleteItems(existingTeamStatusSummaryItems)

        if let teamStatusSummaryItem = teamStatusSummaryItem {
            snapshot.insertSection(.eventInfo, atIndex: TeamSummarySection.eventInfo.rawValue)
            snapshot.insertItem(teamStatusSummaryItem, inSection: .eventInfo, atIndex: 0)
        } else if hasEventInfoSection, eventInfoItems.isEmpty {
            snapshot.deleteSections([.eventInfo])
        }

        // MARK: - Playoff Info

        var playoffInfoItems: [TeamSummaryItem] = []

        // Alliance
        if let allianceStatus = eventStatus?.allianceStatus, allianceStatus != "--" {
            playoffInfoItems.append(.alliance(allianceStatus: allianceStatus))
        }

        // Record
        if let record = eventStatus?.playoff?.record {
            playoffInfoItems.append(.record(wlt: record))
        }

        // Average
        if let average = eventStatus?.playoff?.playoffAverage {
            playoffInfoItems.append(.average(average: average))
        }

        snapshot.deleteSections([.playoffInfo])

        if !playoffInfoItems.isEmpty {
            snapshot.insertSection(.playoffInfo, atIndex: TeamSummarySection.playoffInfo.rawValue)
            snapshot.appendItems(playoffInfoItems, toSection: .playoffInfo)
        }

        // MARK: - Qual Info

        var qualInfoItems: [TeamSummaryItem] = []

        // Rank
        if let rank = eventStatus?.qual?.ranking?.rank, let total = eventStatus?.qual?.numTeams {
            qualInfoItems.append(.rank(rank: rank, total: total))
        }

        // Record
        if let record = eventStatus?.qual?.ranking?.record {
            qualInfoItems.append(.record(wlt: record, dqs: eventStatus?.qual?.ranking?.dq))
        }

        // Average
        if let average = eventStatus?.qual?.ranking?.qualAverage {
            qualInfoItems.append(.average(average: average))
        }

        // Breakdown
        if let rankingInfo = eventStatus?.qual?.ranking?.rankingInfoString {
            qualInfoItems.append(.breakdown(rankingInfo: rankingInfo))
        }

        snapshot.deleteSections([.qualInfo])

        if !qualInfoItems.isEmpty {
            snapshot.insertSection(.qualInfo, atIndex: TeamSummarySection.qualInfo.rawValue)
            snapshot.appendItems(qualInfoItems, toSection: .qualInfo)
        }

        dataSource.apply(snapshot, animatingDifferences: false)

        executeUpdate(updateNextMatchItem)
        executeUpdate(updateLastMatchItem)
    }

    private func updateNextMatchItem() {
        var snapshot = dataSource.snapshot()

        let nextMatch: Match? = {
            if let nextMatchKey = eventStatus?.nextMatchKey, let match = Match.forKey(nextMatchKey, in: persistentContainer.viewContext) {
                return match
            }
            return nil
        }()

        let nextMatchItem: TeamSummaryItem? = {
            if let nextMatch = nextMatch, event.isHappeningNow {
                return .match(match: nextMatch, team: team)
            }
            return nil
        }()

        snapshot.deleteSections([.nextMatch])

        if let nextMatchItem = nextMatchItem {
            snapshot.insertSection(.nextMatch, atIndex: TeamSummarySection.nextMatch.rawValue)
            snapshot.appendItems([nextMatchItem], toSection: .nextMatch)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateLastMatchItem() {
        var snapshot = dataSource.snapshot()

        let lastMatch: Match? = {
            if let lastMatchKey = eventStatus?.lastMatchKey, let match = Match.forKey(lastMatchKey, in: persistentContainer.viewContext) {
                return match
            }
            return nil
        }()

        let lastMatchItem: TeamSummaryItem? = {
            if let lastMatch = lastMatch, event.isHappeningNow {
                return .match(match: lastMatch, team: team)
            }
            return nil
        }()

        snapshot.deleteSections([.lastMatch])

        if let lastMatchItem = lastMatchItem {
            snapshot.insertSection(.lastMatch, atIndex: TeamSummarySection.lastMatch.rawValue)
            snapshot.appendItems([lastMatchItem], toSection: .lastMatch)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]
        if section == .eventInfo {
            return "Summary"
        } else if section == .nextMatch {
            return "Next Match"
        } else if section == .playoffInfo {
            return "Playoffs"
        } else if section == .qualInfo {
            return "Qualifications"
        } else if section == .lastMatch {
            return "Most Recent Match"
        }
        return nil
    }

    // MARK: - Table View Cells

    private static func tableView(_ tableView: UITableView, cellForTeam team: Team, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        cell.viewModel = InfoCellViewModel(team: team)

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        return cell
    }

    private static func tableView(_ tableView: UITableView, cellForRank rank: Int, totalTeams total: Int, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Rank",
            subtitle: "\(rank)\(rank.suffix) (of \(total))",
            at: indexPath
        )
    }

    private static func tableView(_ tableView: UITableView, cellForRecord record: WLT, dqs: Int?, at indexPath: IndexPath) -> UITableViewCell {
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

    private static func tableView(_ tableView: UITableView, cellForAverage average: Double, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Average",
            subtitle: "\(average)",
            at: indexPath
        )
    }

    private static func tableView(_ tableView: UITableView, cellForAllianceStatus allianceStatus: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Alliance", subtitle: allianceStatus, at: indexPath)
    }

    private static func tableView(_ tableView: UITableView, cellForBreakdown breakdown: String, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Ranking Breakdown", subtitle: breakdown, at: indexPath)
    }

    private static func tableView(_ tableView: UITableView, reverseSubtitleCellWithTitle title: String, subtitle: String, at indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel.text = title

        // Strip our subtitle string of HTML tags - they're expensive to render and useless.
        let sanitizedSubtitle = subtitle.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        cell.subtitleLabel.text = sanitizedSubtitle

        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private static func tableView(_ tableView: UITableView, cellForMatch match: Match, team: Team?, at indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        cell.viewModel = MatchViewModel(match: match, team: team)
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .teamInfo(let team):
            delegate?.teamInfoSelected(team)
        case .match(let match, _):
            delegate?.matchSelected(match)
        default:
            break
        }
    }

}

extension TeamSummaryViewController: Refreshable {

    var refreshKey: String? {
        return "\(team.key)@\(event.key)_status"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh team summary until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        var finalOperation: Operation!

        var eventOperation: TBAKitOperation?
        if event.name == nil {
            eventOperation = tbaKit.fetchEvent(key: event.key, completion: { [self] (result, notModified) in
                guard case .success(let object) = result, let event = object, !notModified else {
                    return
                }

                let context = persistentContainer.newBackgroundContext()
                context.performChangesAndWait({
                    Event.insert(event, in: context)
                }, saved: { [unowned self] in
                    self.markTBARefreshSuccessful(self.tbaKit, operation: eventOperation!)
                }, errorRecorder: errorRecorder)
            })
        }

        let teamKey = team.key

        // Refresh Team@Event status
        var teamStatusOperation: TBAKitOperation!
        teamStatusOperation = tbaKit.fetchTeamStatus(key: teamKey, eventKey: event.key) { [self] (result, notModified) in
            guard case .success(let object) = result, let status = object, !notModified else {
                return
            }

            // Kickoff refreshes for our Match objects, add them as dependents for reloading data
            refreshStatusMatches(status, finalOperation)

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(status)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: teamStatusOperation)
            }, errorRecorder: errorRecorder)
        }

        finalOperation = addRefreshOperations([eventOperation, teamStatusOperation].compactMap({ $0 }))
    }

    func refreshStatusMatches(_ status: TBAEventStatus, _ dependentOperation: Operation) {
        let callSets = zip([status.lastMatchKey, status.nextMatchKey].compactMap({ $0 }), [updateLastMatchItem, updateNextMatchItem])
        let ops = callSets.compactMap { [weak self] in
            return self?.fetchMatch($0, $1)
        }
        ops.forEach {
            dependentOperation.addDependency($0)
        }
        refreshOperationQueue.addOperations(ops, waitUntilFinished: false)
    }

    func fetchMatch(_ key: String, _ update: @escaping () -> ()) -> TBAKitOperation? {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: key) { [self] (result, notModified) in
            guard case .success(let object) = result, let match = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Match.insert(match, in: context)
            }, saved: { [unowned self] in
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(update)
            }, errorRecorder: errorRecorder)
        }
        return operation
    }

}

extension TeamSummaryViewController: Stateful {

    var noDataText: String? {
        return "No status for team at event"
    }

}
