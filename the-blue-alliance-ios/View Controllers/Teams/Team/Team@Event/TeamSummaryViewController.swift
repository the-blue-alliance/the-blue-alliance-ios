import Foundation
import UIKit
import CoreData

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func awardsSelected()
    func matchSelected(_ match: Match)
}

private enum TeamSummaryRow: Int {
    case rank
    case awards
    case pit // only during CMP, and if they exist
    case record // don't show record for 2015, because no wins
    case alliance
    case status
    case breakdown
    case nextMatch
    case lastMatch
    case max
}

class TeamSummaryViewController: TBATableViewController {

    private let teamKey: TeamKey
    private let event: Event

    weak var delegate: TeamSummaryViewControllerDelegate?

    var teamAwards: Set<Award> {
        guard let awards = event.awards else {
            return []
        }
        return awards.filtered(using: NSPredicate(format: "event == %@ AND (ANY recipients.teamKey.key == %@)", event, teamKey.key!)) as? Set<Award> ?? []
    }

    private var eventStatus: EventStatus? {
        didSet {
            if let eventStatus = eventStatus {
                updateSummaryInfo()

                contextObserver.observeObject(object: eventStatus, state: .updated) { [unowned self] (_, _) in
                    self.updateSummaryInfo()
                }
            } else {
                contextObserver.observeInsertions { [unowned self] (eventStatuses) in
                    self.eventStatus = eventStatuses.first
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
                           #keyPath(EventStatus.event), event, #keyPath(EventStatus.teamKey), teamKey)
    }()

    private var backgroundFetchKeys: Set<String> = []
    private var summaryRows: [TeamSummaryRow] = []
    private var summaryValues: [Any] = []

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

        // TODO: Since we leverage didSet, we need to do this *after* initilization
        eventStatus = EventStatus.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)

        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.registerReusableCell(LoadingTableViewCell.self)
        tableView.registerReusableCell(MatchTableViewCell.self)
    }

    // MARK: - Private

    func updateSummaryInfo() {
        summaryRows = []
        summaryValues = []

        // Rank
        if let rank = eventStatus?.qual?.ranking?.rank {
            summaryRows.append(TeamSummaryRow.rank)
            summaryValues.append(rank)
        }

        // Awards
        if teamAwards.count > 0 {
            summaryRows.append(TeamSummaryRow.awards)
            summaryValues.append(teamAwards.count)
        }

        // TODO: Add support for Pits
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/163

        // Record
        if let record = eventStatus?.qual?.ranking?.record, event.year != 2015 {
            summaryRows.append(TeamSummaryRow.record)
            summaryValues.append(record)
        }

        // Alliance
        if let allianceStatusString = eventStatus?.allianceStatus {
            summaryRows.append(TeamSummaryRow.alliance)
            summaryValues.append(allianceStatusString)
        }

        // Team Status
        if let overallStatusString = eventStatus?.overallStatus {
            summaryRows.append(TeamSummaryRow.status)
            summaryValues.append(overallStatusString)
        }

        // Breakdown
        if let breakdown = eventStatus?.qual?.ranking?.tiebreakerInfoString {
            summaryRows.append(TeamSummaryRow.breakdown)
            summaryValues.append(breakdown)
        }

        // Only show next/last match if the event is happening now
        if event.isHappeningNow {
            for (type, key) in [(TeamSummaryRow.nextMatch, eventStatus?.nextMatchKey), (TeamSummaryRow.lastMatch, eventStatus?.lastMatchKey)] {
                guard let key = key else {
                    continue
                }
                summaryRows.append(type)
                let match = Match.findOrFetch(in: persistentContainer.viewContext, matching: NSPredicate(format: "%K == %@", #keyPath(Match.key), key))
                if let match = match {
                    summaryValues.append(match)
                } else {
                    summaryValues.append(key)
                    // TODO: Fetch Match
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
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
        let rowType = summaryRows[indexPath.row]
        let rowValue = summaryValues[indexPath.row]
        let cell: UITableViewCell = {
            switch rowType {
            case .rank:
                return self.tableView(tableView, rankCellForRowAt: indexPath)
            case .awards:
                return self.tableView(tableView, awardsCellForRowAt: indexPath)
            case .pit:
                return UITableViewCell()
            case .record:
                return self.tableView(tableView, recordCellForRowAt: indexPath)
            case .alliance:
                return self.tableView(tableView, allianceCellForRowAt: indexPath)
            case .status:
                return self.tableView(tableView, statusCellForRowAt: indexPath)
            case .breakdown:
                return self.tableView(tableView, breakdownCellForRowAt: indexPath)
            case .nextMatch:
                if rowValue is String {
                    return self.tableView(tableView, loadingCellAt: indexPath)
                }
                return self.tableView(tableView, matchCellForRowAt: indexPath)
            case .lastMatch:
                if rowValue is String {
                    return self.tableView(tableView, loadingCellAt: indexPath)
                }
                return self.tableView(tableView, matchCellForRowAt: indexPath)
            default:
                return UITableViewCell()
            }
        }()
        return cell
    }

    private func tableView(_ tableView: UITableView, rankCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rank = summaryValues[indexPath.row] as! NSNumber
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Rank", subtitle: "\(rank.stringValue)\(rank.intValue.suffix)", at: indexPath)
    }

    private func tableView(_ tableView: UITableView, awardsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let awardCount = summaryValues[indexPath.row] as! Int
        let recordString = "Won \(awardCount) award\(awardCount > 1 ? "s" : "")"
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Awards", subtitle: recordString, at: indexPath)

        // Allow us to push to what awards the team won
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default

        return cell
    }

    private func tableView(_ tableView: UITableView, recordCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = summaryValues[indexPath.row] as! WLT
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Qual Record", subtitle: record.displayString(), at: indexPath)
    }

    private func tableView(_ tableView: UITableView, allianceCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allianceStatusString = summaryValues[indexPath.row] as! String
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Alliance", subtitle: allianceStatusString, at: indexPath)
        cell.setHTMLSubtitle(text: allianceStatusString)
        return cell
    }

    private func tableView(_ tableView: UITableView, statusCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let overallStatusString = summaryValues[indexPath.row] as! String
        let cell = self.tableView(tableView, reverseSubtitleCellWithTitle: "Team Status", subtitle: overallStatusString, at: indexPath)
        cell.setHTMLSubtitle(text: overallStatusString)
        return cell
    }

    private func tableView(_ tableView: UITableView, breakdownCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let breakdown = summaryValues[indexPath.row] as! String
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Ranking Breakdown", subtitle: breakdown, at: indexPath)
    }

    private func tableView(_ tableView: UITableView, reverseSubtitleCellWithTitle title: String, subtitle: String, at indexPath: IndexPath) -> ReverseSubtitleTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        return cell
    }

    private func tableView(_ tableView: UITableView, loadingCellAt indexPath: IndexPath) -> LoadingTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LoadingTableViewCell
        cell.keyLabel.text = summaryValues[indexPath.row] as? String
        cell.backgroundFetchActivityIndicator.isHidden = false
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, matchCellForRowAt indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        let match = summaryValues[indexPath.row] as! Match
        cell.viewModel = MatchViewModel(match: match, teamKey: teamKey)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let rowType = summaryRows[indexPath.row]
        let rowValue = summaryValues[indexPath.row]
        switch rowType {
        case .awards:
            delegate?.awardsSelected()
        case .nextMatch, .lastMatch:
            if let match = rowValue as? Match {
                delegate?.matchSelected(match)
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = summaryRows[indexPath.row]
        let rowValue = summaryValues[indexPath.row]
        if (rowType == .nextMatch && rowValue is String) || (rowType == .lastMatch && rowValue is String) {
            return 44.0
        }
        return UITableView.automaticDimension
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
        teamStatusRequest = tbaKit.fetchTeamStatus(key: teamKey.key!, eventKey: event.key!, completion: { (status, error) in
            if error != nil {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                // TODO: We can never remove an Status
                if let status = status {
                    let event = backgroundContext.object(with: self.event.objectID) as! Event
                    event.insert(status)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: teamStatusRequest!)
                    }
                }
                self.removeRequest(request: teamStatusRequest!)
            })
        })
        addRequest(request: teamStatusRequest!)

        // Refresh awards
        var awardsRequest: URLSessionDataTask?
        awardsRequest = tbaKit.fetchTeamAwards(key: teamKey.key!, eventKey: event.key!, completion: { (awards, error) in
            if error != nil {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let awards = awards {
                    let event = backgroundContext.object(with: self.event.objectID) as! Event
                    event.insert(awards, teamKey: self.teamKey.key!)

                    self.updateSummaryInfo()

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: awardsRequest!)
                    }
                }
                self.removeRequest(request: awardsRequest!)
            })
        })
        addRequest(request: awardsRequest!)
    }

}

extension TeamSummaryViewController: Stateful {

    var noDataText: String {
        return "No status for team at event"
    }

}
