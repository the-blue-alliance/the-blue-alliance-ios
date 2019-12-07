import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func awardsSelected()
    func matchSelected(_ match: Match)
}

private enum TeamSummarySection: Int {
    case eventInfo
    case nextMatch
    case playoffInfo
    case qualInfo
    case lastMatch
}

private enum TeamSummaryItem: Hashable {
    case status(status: String)
    case awards(count: Int)
    case rank(rank: Int, total: Int)
    case record(wlt: WLT, dqs: Int? = nil)
    case average(average: NSNumber)
    case breakdown(rankingInfo: String)
    case alliance(allianceStatus: String)
    case match(match: Match, teamKey: TeamKey? = nil)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .status(let status):
            hasher.combine(status)
        case .awards(let count):
            hasher.combine(count)
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
        case .match(let match, let teamKey):
            hasher.combine(match)
            hasher.combine(teamKey)
        }
    }

    static func == (lhs: TeamSummaryItem, rhs: TeamSummaryItem) -> Bool {
        switch (lhs, rhs) {
        case (.status(let lhsStatus), .status(let rhsStatus)):
            return lhsStatus == rhsStatus
        case (.awards(let lhsCount), .awards(let rhsCount)):
            return lhsCount == rhsCount
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
        case (.match(let lhsMatch, let lhsTeamKey), .match(let rhsMatch, let rhsTeamKey)):
            return lhsMatch == rhsMatch && lhsTeamKey == rhsTeamKey
        default:
            return false
        }
    }
}

class TeamSummaryViewController: TBATableViewController {

    weak var delegate: TeamSummaryViewControllerDelegate?

    private let teamKey: TeamKey
    private let event: Event

    private var dataSource: UITableViewDiffableDataSource<TeamSummarySection, TeamSummaryItem>!
    private var _dataSource: TableViewDataSource<TeamSummarySection, TeamSummaryItem>!

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
    private var teamAwards: [Award] {
        return event.awards(for: teamKey)
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

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)

        setupDataSource()
        tableView.dataSource = _dataSource

        // Since we leverage didSet, we need to do this *after* initilization
        eventStatus = EventStatus.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)

        executeUpdate(updateEventStatusItems)
        executeUpdate(updateNextMatchItem)
        executeUpdate(updateLastMatchItem)
        executeUpdate(updateAwardsItem)
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<TeamSummarySection, TeamSummaryItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .awards(let count):
                return TeamSummaryViewController.tableView(tableView, cellForAwardCount: count, at: indexPath)
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
            case .match(let match, let teamKey):
                return TeamSummaryViewController.tableView(tableView, cellForMatch: match, teamKey: teamKey, at: indexPath)
            }
        })
        _dataSource = TableViewDataSource(dataSource: dataSource)
        _dataSource.delegate = self
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

        let eventInfoItems = snapshot.itemIdentifiers(inSection: .eventInfo)
        let existingTeamStatusSummaryItems = eventInfoItems.filter({ switch $0 { case .status(_): return true; default: return false } })
        snapshot.deleteItems(existingTeamStatusSummaryItems)

        if let teamStatusSummaryItem = teamStatusSummaryItem {
            snapshot.insertSection(.eventInfo, atIndex: TeamSummarySection.eventInfo.rawValue)
            snapshot.insertItem(teamStatusSummaryItem, inSection: .eventInfo, atIndex: 0)
        } else if snapshot.itemIdentifiers(inSection: .eventInfo).isEmpty {
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
            qualInfoItems.append(.rank(rank: rank.intValue, total: total.intValue))
        }

        // Record
        if let record = eventStatus?.qual?.ranking?.record {
            qualInfoItems.append(.record(wlt: record, dqs: eventStatus?.qual?.ranking?.dq?.intValue))
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

    private func updateAwardsItem() {
        var snapshot = dataSource.snapshot()

        let teamAwardsSummaryItem: TeamSummaryItem? = {
            return teamAwards.count > 0 ? .awards(count: teamAwards.count) : nil
        }()

        let items = snapshot.itemIdentifiers(inSection: .eventInfo)
        let existingTeamAwardsSummaryItems = items.filter({ switch $0 { case .awards(_): return true; default: return false } })
        snapshot.deleteItems(existingTeamAwardsSummaryItems)

        if let teamAwardsSummaryItem = teamAwardsSummaryItem {
            snapshot.insertSection(.eventInfo, atIndex: TeamSummarySection.eventInfo.rawValue)
            snapshot.insertItem(teamAwardsSummaryItem, inSection: .eventInfo, atIndex: 1)
        } else if snapshot.itemIdentifiers(inSection: .eventInfo).isEmpty {
            snapshot.deleteSections([.eventInfo])
        }

        dataSource.apply(snapshot, animatingDifferences: false)
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
                return .match(match: nextMatch, teamKey: teamKey)
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
                return .match(match: lastMatch, teamKey: teamKey)
            }
            return nil
        }()

        snapshot.deleteSections([.lastMatch])

        if let lastMatchItem = lastMatchItem {
            snapshot.insertSection(.lastMatch, atIndex: TeamSummarySection.lastMatch.rawValue)
            snapshot.appendItems([lastMatchItem], toSection: .nextMatch)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]
        if section == .nextMatch {
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

    private static func tableView(_ tableView: UITableView, cellForAwardCount awardCount: Int, at indexPath: IndexPath) -> UITableViewCell {
        let recordString = "Won \(awardCount) award\(awardCount > 1 ? "s" : "")"
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Awards", subtitle: recordString, at: indexPath)
        // Allow us to push to what awards the team won
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
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

    private static func tableView(_ tableView: UITableView, cellForAverage average: NSNumber, at indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(
            tableView,
            reverseSubtitleCellWithTitle: "Average",
            subtitle: average.stringValue,
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

    private static func tableView(_ tableView: UITableView, cellForMatch match: Match, teamKey: TeamKey?, at indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        cell.viewModel = MatchViewModel(match: match, teamKey: teamKey)
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .awards:
            delegate?.awardsSelected()
        case .match(let match, _):
            delegate?.matchSelected(match)
        default:
            break
        }
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
        teamStatusOperation = tbaKit.fetchTeamStatus(key: teamKey.key!, eventKey: event.key!) { (result, notModified) in
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
                    }, errorRecorder: Crashlytics.sharedInstance())
                } else if !notModified {
                    // TODO: Delete status, move back up our hiearchy
                }
            default:
                break
            }
        }

        // Refresh awards
        let teamKeyKey = teamKey.key!
        var awardsOperation: TBAKitOperation!
        awardsOperation = tbaKit.fetchTeamAwards(key: teamKeyKey, eventKey: event.key!) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let awards = try? result.get() {
                    let event = context.object(with: self.event.objectID) as! Event
                    event.insert(awards, teamKey: teamKeyKey)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(awardsOperation)
                self.executeUpdate(self.updateAwardsItem)
            }, errorRecorder: Crashlytics.sharedInstance())
        }

        finalOperation = addRefreshOperations([teamStatusOperation, awardsOperation])
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
        operation = tbaKit.fetchMatch(key: key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
                self.executeUpdate(update)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        return operation
    }

}

extension TeamSummaryViewController: Stateful {

    var noDataText: String {
        return "No status for team at event"
    }

}
