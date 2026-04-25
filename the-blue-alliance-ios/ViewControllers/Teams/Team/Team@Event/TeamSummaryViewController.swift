import Foundation
import TBAAPI
import UIKit

protocol TeamSummaryViewControllerDelegate: AnyObject {
    func teamInfoSelected(teamKey: String)
    func matchSelected(_ match: Match)
}

private enum TeamSummarySection: Int {
    case teamInfo
    case pitLocation
    case eventInfo
    case nextMatch
    case lastMatch
    case playoffInfo
    case qualInfo
}

private enum TeamSummaryItem: Hashable {
    case teamInfo(team: Team)
    case pitLocation(location: String)
    case status(status: String)
    case rank(rank: Int, total: Int)
    case record(wins: Int, losses: Int, ties: Int, dqs: Int? = nil)
    case average(average: Double)
    case breakdown(rankingInfo: String)
    case alliance(allianceStatus: String)
    case match(match: Match, baseTeamKey: String?)
}

class TeamSummaryViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: TeamSummaryViewControllerDelegate?

    private let teamKey: String
    private let eventKey: String

    private var team: Team?
    private var event: Event?
    private var eventStatus: TeamEventStatus?
    private var nextMatch: Match?
    private var lastMatch: Match?

    private var dataSource: TableViewDataSource<TeamSummarySection, TeamSummaryItem>!

    init(teamKey: String, eventKey: String, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.eventKey = eventKey

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
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<TeamSummarySection, TeamSummaryItem>(
            tableView: tableView,
            cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
                guard let self else { return nil }
                switch item {
                case .teamInfo(let team):
                    return self.cellForTeam(team, in: tableView, at: indexPath)
                case .pitLocation(let location):
                    let cell = Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Pit Location",
                        subtitle: "\(location) · via FRC Nexus",
                        at: indexPath
                    )
                    cell.accessoryType = .disclosureIndicator
                    cell.selectionStyle = .default
                    return cell
                case .status(let status):
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Status",
                        subtitle: status,
                        at: indexPath
                    )
                case .rank(let rank, let total):
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Rank",
                        subtitle: "\(rank)\(rank.suffix) (of \(total))",
                        at: indexPath
                    )
                case .record(let wins, let losses, let ties, let dqs):
                    let subtitle: String = {
                        let base = "\(wins)-\(losses)-\(ties)"
                        if let dqs, dqs > 0 { return "\(base) (\(dqs) DQ)" }
                        return base
                    }()
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Record",
                        subtitle: subtitle,
                        at: indexPath
                    )
                case .average(let average):
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Average",
                        subtitle: "\(average)",
                        at: indexPath
                    )
                case .breakdown(let breakdown):
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Ranking Breakdown",
                        subtitle: breakdown,
                        at: indexPath
                    )
                case .alliance(let allianceStatus):
                    return Self.reverseSubtitleCell(
                        in: tableView,
                        title: "Alliance",
                        subtitle: allianceStatus,
                        at: indexPath
                    )
                case .match(let match, let baseTeamKey):
                    return self.cellForMatch(
                        match,
                        baseTeamKey: baseTeamKey,
                        in: tableView,
                        at: indexPath
                    )
                }
            }
        )
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func rebuildSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TeamSummarySection, TeamSummaryItem>()

        // Team info
        if let team {
            snapshot.appendSections([.teamInfo])
            snapshot.appendItems([.teamInfo(team: team)], toSection: .teamInfo)
        }

        // Pit location
        if let pit = eventStatus?.pitLocation, !pit.isEmpty {
            snapshot.appendSections([.pitLocation])
            snapshot.appendItems([.pitLocation(location: pit)], toSection: .pitLocation)
        }

        // Status summary
        if let statusItem = self.statusItem() {
            snapshot.appendSections([.eventInfo])
            snapshot.appendItems([statusItem], toSection: .eventInfo)
        }

        // Next match
        if let nextMatch, event?.isHappeningNow == true {
            snapshot.appendSections([.nextMatch])
            snapshot.appendItems(
                [.match(match: nextMatch, baseTeamKey: teamKey)],
                toSection: .nextMatch
            )
        }

        // Last match
        if let lastMatch, event?.isHappeningNow == true {
            snapshot.appendSections([.lastMatch])
            snapshot.appendItems(
                [.match(match: lastMatch, baseTeamKey: teamKey)],
                toSection: .lastMatch
            )
        }

        // Playoff info
        let playoffItems = self.playoffItems()
        if !playoffItems.isEmpty {
            snapshot.appendSections([.playoffInfo])
            snapshot.appendItems(playoffItems, toSection: .playoffInfo)
        }

        // Qual info
        let qualItems = self.qualItems()
        if !qualItems.isEmpty {
            snapshot.appendSections([.qualInfo])
            snapshot.appendItems(qualItems, toSection: .qualInfo)
        }

        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    private func statusItem() -> TeamSummaryItem? {
        guard let playoff = eventStatus?.playoff, let level = playoff.level else { return nil }
        let compLevel: String = {
            // Map the playoff-level enum values to the human-readable level.
            switch level {
            case .qm: return "Qualification"
            case .ef: return "Octofinals"
            case .qf: return "Quarterfinals"
            case .sf: return "Semifinals"
            case .f: return "Finals"
            }
        }()
        switch playoff.status {
        case .playing:
            if let record = playoff.currentLevelRecord {
                return .status(
                    status:
                        "Currently \(record.wins)-\(record.losses)-\(record.ties) in the \(compLevel)"
                )
            }
            return nil
        case .eliminated:
            return .status(status: "Eliminated in the \(compLevel)")
        case .won:
            if level == .f {
                return .status(status: "Won the event")
            }
            return .status(status: "Won the \(compLevel)")
        default:
            return nil
        }
    }

    private func playoffItems() -> [TeamSummaryItem] {
        var items: [TeamSummaryItem] = []
        if let allianceStatus = eventStatus?.allianceStatusStr, allianceStatus != "--",
            !allianceStatus.isEmpty
        {
            items.append(.alliance(allianceStatus: allianceStatus))
        }
        if let record = eventStatus?.playoff?.record {
            items.append(.record(wins: record.wins, losses: record.losses, ties: record.ties))
        }
        if let average = eventStatus?.playoff?.playoffAverage {
            items.append(.average(average: average))
        }
        return items
    }

    private func qualItems() -> [TeamSummaryItem] {
        var items: [TeamSummaryItem] = []
        if let rank = eventStatus?.qual?.ranking?.rank, let total = eventStatus?.qual?.numTeams {
            items.append(.rank(rank: rank, total: total))
        }
        if let record = eventStatus?.qual?.ranking?.record {
            items.append(
                .record(
                    wins: record.wins,
                    losses: record.losses,
                    ties: record.ties,
                    dqs: eventStatus?.qual?.ranking?.dq
                )
            )
        }
        if let average = eventStatus?.qual?.ranking?.qualAverage {
            items.append(.average(average: average))
        }
        if let info = rankingInfoString() {
            items.append(.breakdown(rankingInfo: info))
        }
        return items
    }

    private func rankingInfoString() -> String? {
        guard let ranking = eventStatus?.qual?.ranking,
            let sortOrders = ranking.sortOrders,
            let info = eventStatus?.qual?.sortOrderInfo
        else { return nil }
        let parts: [String] = zip(info, sortOrders).compactMap { info, value in
            guard let name = info.name else { return nil }
            let precision = info.precision ?? 0
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = precision
            formatter.maximumFractionDigits = precision
            guard let valueString = formatter.string(for: value) else { return nil }
            return "\(name): \(valueString)"
        }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - Cells

    private func cellForTeam(_ team: Team, in tableView: UITableView, at indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        cell.viewModel = InfoCellViewModel(
            nameString: team.displayNickname,
            subtitleStrings: [team.locationString].compactMap { $0 }
        )
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    private static func reverseSubtitleCell(
        in tableView: UITableView,
        title: String,
        subtitle: String,
        at indexPath: IndexPath
    ) -> ReverseSubtitleTableViewCell {
        let cell =
            tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel.text = title
        // Strip HTML tags — the status strings from TBA often include `<b>` markers.
        let sanitized = subtitle.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(
            of: "</b>",
            with: ""
        )
        cell.subtitleLabel.text = sanitized
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private func cellForMatch(
        _ match: Match,
        baseTeamKey: String?,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> MatchTableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchTableViewCell
        let baseTeamKeys = baseTeamKey.map { [$0] } ?? []
        if let event {
            cell.viewModel = MatchViewModel(
                match: match,
                event: event,
                baseTeamKeys: baseTeamKeys
            )
        } else {
            cell.viewModel = MatchViewModel(
                withoutEventContextFor: match,
                baseTeamKeys: baseTeamKeys
            )
        }
        return cell
    }

    // MARK: TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]
        switch section {
        case .eventInfo: return "Summary"
        case .nextMatch: return "Next Match"
        case .playoffInfo: return "Playoffs"
        case .qualInfo: return "Qualifications"
        case .lastMatch: return "Most Recent Match"
        default: return nil
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .teamInfo:
            delegate?.teamInfoSelected(teamKey: teamKey)
        case .match(let match, _):
            delegate?.matchSelected(match)
        case .pitLocation:
            guard let event,
                let teamNumber = team?.teamNumber,
                let url = event.nexusTeamPitMapURL(teamNumber: teamNumber),
                urlOpener.canOpenURL(url)
            else { return }
            urlOpener.open(url, options: [:], completionHandler: nil)
        default:
            break
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { eventStatus == nil }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let teamHandle = Task { try? await self.dependencies.api.team(key: self.teamKey) }
            let eventHandle = Task { try? await self.dependencies.api.event(key: self.eventKey) }
            let statusHandle = Task {
                try? await self.dependencies.api.teamEventStatus(
                    teamKey: self.teamKey,
                    eventKey: self.eventKey
                )
            }

            if let team = await teamHandle.value { self.team = team }
            if let event = await eventHandle.value { self.event = event }
            if let status = await statusHandle.value { self.eventStatus = status }

            let nextHandle = Task { () -> Match? in
                guard let key = self.eventStatus?.nextMatchKey else { return nil }
                return try? await self.dependencies.api.match(key: key)
            }
            let lastHandle = Task { () -> Match? in
                guard let key = self.eventStatus?.lastMatchKey else { return nil }
                return try? await self.dependencies.api.match(key: key)
            }
            // Split "status says no key" (clear) from "fetch errored" (preserve).
            if self.eventStatus?.nextMatchKey == nil {
                self.nextMatch = nil
            } else if let match = await nextHandle.value {
                self.nextMatch = match
            }
            if self.eventStatus?.lastMatchKey == nil {
                self.lastMatch = nil
            } else if let match = await lastHandle.value {
                self.lastMatch = match
            }

            self.rebuildSnapshot()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No status for team at event" }
}
