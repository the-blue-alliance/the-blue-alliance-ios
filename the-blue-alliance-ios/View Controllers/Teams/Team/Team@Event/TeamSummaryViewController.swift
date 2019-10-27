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

private enum TeamSummaryItemType {
    case status(status: String)
    case awards(count: Int)
    case rank(rank: Int, total: Int)
    case record(wlt: WLT, dqs: Int? = nil)
    case average(average: NSNumber)
    case breakdown(rankingInfo: String)
    case alliance(allianceStatus: String)
    case match(match: Match, teamKey: TeamKey? = nil)
}

private struct TeamSummaryItem: Hashable {

    let identifier = UUID()
    let type: TeamSummaryItemType

    init(status: String) {
        type = .status(status: status)
    }

    init(awardsCount: Int) {
        type = .awards(count: awardsCount)
    }

    init(rank: Int, total: Int) {
        type = .rank(rank: rank, total: total)
    }

    init(wlt: WLT, dqs: Int? = nil) {
        type = .record(wlt: wlt, dqs: dqs)
    }

    init(average: NSNumber) {
        type = .average(average: average)
    }

    init(rankingInfo: String) {
        type = .breakdown(rankingInfo: rankingInfo)
    }

    init(allianceStatus: String) {
        type = .alliance(allianceStatus: allianceStatus)
    }

    init(match: Match, teamKey: TeamKey? = nil) {
        type = .match(match: match, teamKey: teamKey)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: TeamSummaryItem, rhs: TeamSummaryItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class TeamSummaryViewController: TBATableViewController {

    weak var delegate: TeamSummaryViewControllerDelegate?

    private let teamKey: TeamKey
    private let event: Event

    private var dataSource: UITableViewDiffableDataSource<TeamSummarySection, TeamSummaryItem>!
    private var _dataSource: TableViewDataSource<TeamSummarySection, TeamSummaryItem>!

    // TODO: Move in to Event
    private var teamAwards: Set<Award> {
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
                    DispatchQueue.main.async {
                        self?.updateEventStatusItems()
                        self?.updateNextMatchItem()
                        self?.updateLastMatchItem()
                    }
                }
            } else {
                contextObserver.observeInsertions { [weak self] (eventStatuses) in
                    self?.eventStatus = eventStatuses.first
                }
            }
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

        updateEventStatusItems()
        updateNextMatchItem()
        updateLastMatchItem()
        // updateAwardsItem()
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<TeamSummarySection, TeamSummaryItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item.type {
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
                    return TeamSummaryItem(status: "Currently \(record.stringValue) in the \(compLevel)")
                } else if status == "eliminated" {
                    return TeamSummaryItem(status: "Eliminated in the \(compLevel)")
                } else if status == "won" {
                    if level == "f" {
                        return TeamSummaryItem(status: "Won the event")
                    } else {
                        return TeamSummaryItem(status: "Won the \(compLevel)")
                    }
                }
            }
            return nil
        }()

        if let teamStatusSummaryItem = teamStatusSummaryItem {
            snapshot.insertSection(.eventInfo, atIndex: TeamSummarySection.eventInfo.rawValue)
            // TODO: Remove previous item, if it exists
            snapshot.insertItem(teamStatusSummaryItem, inSection: .eventInfo, atIndex: 0)
        } else {
            // TODO: Remove previous item
            // TODO: Remove previous section, if it's empty
        }

        // MARK: - Playoff Info

        var playoffInfoItems: [TeamSummaryItem] = []

        // Alliance
        if let allianceStatus = eventStatus?.allianceStatus, allianceStatus != "--" {
            playoffInfoItems.append(TeamSummaryItem(allianceStatus: allianceStatus))
        }

        // Record
        if let record = eventStatus?.playoff?.record {
            playoffInfoItems.append(TeamSummaryItem(wlt: record))
        }

        // Average
        if let average = eventStatus?.playoff?.playoffAverage {
            playoffInfoItems.append(TeamSummaryItem(average: average))
        }

        if !playoffInfoItems.isEmpty {
            snapshot.deleteSections([.playoffInfo])
            snapshot.insertSection(.playoffInfo, atIndex: TeamSummarySection.playoffInfo.rawValue)
            snapshot.appendItems(playoffInfoItems, toSection: .playoffInfo)
        } else {
            // TODO: Double check these deletes are safe if the section doesn't exist
            snapshot.deleteSections([.playoffInfo])
        }

        // MARK: - Qual Info

        var qualInfoItems: [TeamSummaryItem] = []

        // Rank
        if let rank = eventStatus?.qual?.ranking?.rank, let total = eventStatus?.qual?.numTeams {
            qualInfoItems.append(TeamSummaryItem(rank: rank.intValue, total: total.intValue))
        }

        // Record
        if let record = eventStatus?.qual?.ranking?.record {
            qualInfoItems.append(TeamSummaryItem(wlt: record, dqs: eventStatus?.qual?.ranking?.dq?.intValue))
        }

        // Average
        if let average = eventStatus?.qual?.ranking?.qualAverage {
            qualInfoItems.append(TeamSummaryItem(average: average))
        }

        // Breakdown
        if let rankingInfo = eventStatus?.qual?.ranking?.rankingInfoString {
            qualInfoItems.append(TeamSummaryItem(rankingInfo: rankingInfo))
        }

        if !qualInfoItems.isEmpty {
            snapshot.deleteSections([.qualInfo])
            snapshot.insertSection(.qualInfo, atIndex: TeamSummarySection.qualInfo.rawValue)
            snapshot.appendItems(qualInfoItems, toSection: .qualInfo)
        } else {
            // TODO: Double check these deletes are safe if the section doesn't exist
            snapshot.deleteSections([.qualInfo])
        }

        dataSource.apply(snapshot)
    }

    private func updateAwardsItem() {
        var snapshot = dataSource.snapshot()

        let teamAwardsSummaryItem: TeamSummaryItem? = {
            return teamAwards.count > 0 ? TeamSummaryItem(awardsCount: teamAwards.count) : nil
        }()

        if let teamAwardsSummaryItem = teamAwardsSummaryItem {
            snapshot.insertSection(.eventInfo, atIndex: TeamSummarySection.eventInfo.rawValue)

            // Remove existing awards item
            let items = snapshot.itemIdentifiers(inSection: .eventInfo)
            let existingTeamAwardsSummaryItem = items.first // TODO: Fix this - how do we filter for just Awards?
            if let existingTeamAwardsSummaryItem = existingTeamAwardsSummaryItem {
                snapshot.deleteItems([existingTeamAwardsSummaryItem])
            }

            snapshot.insertItem(teamAwardsSummaryItem, inSection: .eventInfo, atIndex: 1)
        } else if let item = snapshot.itemIdentifiers.first {
            // Remove our existing awards item
            snapshot.deleteItems([item])
            // If our event info section is empty, remove it
            let items = snapshot.itemIdentifiers(inSection: .eventInfo)
            if items.isEmpty {
                snapshot.deleteSections([.eventInfo])
            }
        }

        dataSource.apply(snapshot)
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
                return TeamSummaryItem(match: nextMatch, teamKey: teamKey)
            }
            return nil
        }()

        if let nextMatchItem = nextMatchItem {
            snapshot.insertSection(.nextMatch, atIndex: TeamSummarySection.nextMatch.rawValue)
            // TODO: Remove if the old one previously exists
            snapshot.appendItems([nextMatchItem], toSection: .nextMatch)
        } else {

        }

        dataSource.apply(snapshot)
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
                return TeamSummaryItem(match: lastMatch, teamKey: teamKey)
            }
            return nil
        }()

        if let lastMatchItem = lastMatchItem {
            snapshot.insertSection(.lastMatch, atIndex: TeamSummarySection.lastMatch.rawValue)
            // TODO: Remove if the old one previously exists
            snapshot.appendItems([lastMatchItem], toSection: .nextMatch)
        } else {

        }

        dataSource.apply(snapshot)
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

    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TeamSummarySection.nextMatch {
            return "Next Match"
        } else if section == TeamSummarySection.playoffInfo {
            return "Playoffs"
        } else if section == TeamSummarySection.qualInfo {
            return "Qualifications"
        } else if section == TeamSummarySection.lastMatch {
            return "Most Recent Match"
        }
        return nil
    }
    */

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // TODO: Do we need to deselect?
        tableView.deselectRow(at: indexPath, animated: true)

        switch item.type {
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
        // TODO: Probably change this yeah?
        return eventStatus == nil || teamAwards.count == 0
    }

    @objc func refresh() {
        // Refresh Team@Event status
        var teamStatusOperation: TBAKitOperation!
        teamStatusOperation = tbaKit.fetchTeamStatus(key: teamKey.key!, eventKey: event.key!, completion: { (result, notModified) in
            switch result {
            case .success(let status):
                if let status = status {
                    // Kickoff refreshes for our Match objects, add them as dependents for reloading data
                    self.refreshStatusMatches(status)

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
                DispatchQueue.main.async {
                    // self.updateAwardsItem()
                }
            }, errorRecorder: Crashlytics.sharedInstance())
        })

        addRefreshOperations([teamStatusOperation, awardsOperation])
    }

    func refreshStatusMatches(_ status: TBAEventStatus) {
        let callSets = zip([status.lastMatchKey, status.nextMatchKey].compactMap({ $0 }), [updateLastMatchItem, updateNextMatchItem])
        let ops = callSets.compactMap { [weak self] in
            return self?.fetchMatch($0, $1)
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
                DispatchQueue.main.async {
                    update()
                }
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

private extension NSDiffableDataSourceSnapshot {

    mutating func insertSection(_ identifier: SectionIdentifierType, atIndex index: Int) {
        if sectionIdentifiers.contains(identifier) {
            return
        }
        if sectionIdentifiers.count <= index {
            appendSections([identifier])
        } else {
            let section = sectionIdentifiers[index - 1]
            insertSections([identifier], beforeSection: section)
        }
    }

    mutating func insertItem(_ identifier: ItemIdentifierType, inSection section: SectionIdentifierType, atIndex index: Int) {
        let items = itemIdentifiers(inSection: section)
        if items.count <= index {
            appendItems([identifier])
        } else {
            let item = items[index - 1]
            insertItems([identifier], beforeItem: item)
        }
    }

}
