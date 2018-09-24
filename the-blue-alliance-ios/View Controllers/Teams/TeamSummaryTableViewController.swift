import Foundation
import UIKit
import TBAKit
import CoreData

enum TeamSummaryRow: Int {
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

class TeamSummaryTableViewController: TBATableViewController {

    var team: Team
    var event: Event

    var teamAwards: Set<Award> {
        guard let awards = event.awards else {
            return []
        }
        return awards.filtered(using: NSPredicate(format: "event == %@ AND (ANY recipients.team == %@)", event, team)) as? Set<Award> ?? []
    }

    private var eventStatus: EventStatus? {
        didSet {
            if let eventStatus = eventStatus {
                updateSummaryInfo()

                contextObserver.observeObject(object: eventStatus, state: .updated) { [weak self] (_, _) in
                    self?.updateSummaryInfo()
                }
            } else {
                contextObserver.observeInsertions { [weak self] (eventStatuses) in
                    self?.eventStatus = eventStatuses.first
                }
            }
        }
    }

    var awardsSelected: (() -> ())?
    var matchSelected: ((Match) -> ())?

    // MARK: - Observable

    typealias ManagedType = EventStatus
    lazy var observerPredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@ AND %K == %@",
                           #keyPath(EventStatus.event), event, #keyPath(EventStatus.team), team)
    }()
    lazy var contextObserver: CoreDataContextObserver<EventStatus> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    var backgroundFetchKeys: Set<String> = []
    var summaryRows: [TeamSummaryRow] = []
    var summaryValues: [Any] = []

    init(team: Team, event: Event, awardsSelected: (() -> ())?, matchSelected: ((Match) -> ())?, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.event = event
        self.awardsSelected = awardsSelected
        self.matchSelected = matchSelected

        super.init(persistentContainer: persistentContainer)

        eventStatus = EventStatus.findOrFetch(in: persistentContainer.viewContext, matching: observerPredicate)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: ReverseSubtitleTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: LoadingTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: MatchTableViewCell.reuseIdentifier)
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
        if let breakdown = eventStatus?.qual?.ranking?.infoString {
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
                    if !backgroundFetchKeys.contains(key) {
                        backgroundFetchKeys.insert(key)
                        self.persistentContainer.performBackgroundTask({ [weak self] (backgroundContext) in
                            TBABackgroundService.backgroundFetchMatch(key, in: backgroundContext) { [weak self] (_, _) in
                                self?.backgroundFetchKeys.remove(key)
                                self?.updateSummaryInfo()
                            }
                        })
                    }
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Refresh

    override func refresh() {
        removeNoDataView()

        // Refresh team status
        var teamStatusRequest: URLSessionDataTask?
        teamStatusRequest = TBAKit.sharedKit.fetchTeamStatus(key: team.key!, eventKey: event.key!, completion: { (modelStatus, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                if let modelStatus = modelStatus {
                    EventStatus.insert(with: modelStatus, team: backgroundTeam, event: backgroundEvent, in: backgroundContext)
                }

                backgroundContext.saveContext()
                self.removeRequest(request: teamStatusRequest!)
            })
        })
        addRequest(request: teamStatusRequest!)

        // Refresh awards
        var awardsRequest: URLSessionDataTask?
        awardsRequest = TBAKit.sharedKit.fetchTeamAwards(key: team.key!, eventKey: event.key!, completion: { (awards, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event awards for \(self.team.key!) - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event

                let localAwards = awards?.map({ (modelAward) -> Award in
                    return Award.insert(with: modelAward, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.addToAwards(Set(localAwards ?? []) as NSSet)

                backgroundContext.saveContext()
                self.removeRequest(request: awardsRequest!)
            })
        })
        addRequest(request: awardsRequest!)
    }

    override func shouldNoDataRefresh() -> Bool {
        return eventStatus == nil || teamAwards.count == 0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows: Int = summaryRows.count
        if rows == 0 {
            showNoDataView(with: "No event status for Team \(team.teamNumber) at \(event.friendlyNameWithYear)")
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
        let rank = summaryValues[indexPath.row] as! Int16
        return self.tableView(tableView, reverseSubtitleCellWithTitle: "Rank", subtitle: "\(rank)\(rank.suffix())", at: indexPath)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier) as? ReverseSubtitleTableViewCell ?? ReverseSubtitleTableViewCell(style: .default, reuseIdentifier: ReverseSubtitleTableViewCell.reuseIdentifier)

        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle

        cell.selectionStyle = .none

        return cell
    }

    private func tableView(_ tableView: UITableView, loadingCellAt indexPath: IndexPath) -> LoadingTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.reuseIdentifier) as? LoadingTableViewCell ?? LoadingTableViewCell(style: .default, reuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        cell.keyLabel.text = summaryValues[indexPath.row] as? String
        cell.backgroundFetchActivityIndicator.isHidden = false
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, matchCellForRowAt indexPath: IndexPath) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.reuseIdentifier) as? MatchTableViewCell ?? MatchTableViewCell(style: .default, reuseIdentifier: MatchTableViewCell.reuseIdentifier)

        let match = summaryValues[indexPath.row] as! Match
        cell.match = match
        cell.team = team

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let rowType = summaryRows[indexPath.row]
        let rowValue = summaryValues[indexPath.row]
        switch rowType {
        case .awards:
            if let awardsSelected = awardsSelected {
                awardsSelected()
            }
        case .nextMatch, .lastMatch:
            if let matchSelected = matchSelected {
                matchSelected(rowValue as! Match)
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
