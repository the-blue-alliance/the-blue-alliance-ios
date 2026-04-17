import Foundation
import TBAAPI
import UIKit

private enum TeamInfoSection: Int {
    case info
    case link
}

private enum TeamInfoItem {
    case location
    case rookieYear
    case sponsors
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class TeamInfoViewController: TBATableViewController, Refreshable, Stateful {

    private let teamKey: String

    private var team: Team?

    private var dataSource: TableViewDataSource<TeamInfoSection, TeamInfoItem>!

    private var sponsorsExpanded: Bool = false

    // MARK: - Init

    init(teamKey: String, team: Team? = nil, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.team = team

        super.init(style: .grouped, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        if team != nil {
            updateTeamInfo()
        }
    }

    // MARK: - External

    func apply(team: Team) {
        self.team = team
        if isViewLoaded {
            updateTeamInfo()
        }
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<TeamInfoSection, TeamInfoItem>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            switch item {
            case .location:
                return self.tableView(tableView, locationCellForRowAt: indexPath)
            case .rookieYear:
                return self.tableView(tableView, rookieYearCellForRowAt: indexPath)
            case .sponsors:
                return self.tableView(tableView, sponsorCellForRowAt: indexPath)
            case .website:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View team's website"
                return cell
            case .twitter:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View \(self.teamKey) on Twitter"
                return cell
            case .youtube:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View \(self.teamKey) on YouTube"
                return cell
            case .chiefDelphi:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View photos on Chief Delphi"
                return cell
            }
        })
    }

    private func updateTeamInfo() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        guard let team else {
            dataSource.apply(snapshot, animatingDifferences: false)
            return
        }

        // Info
        var infoItems: [TeamInfoItem] = []
        if team.locationString != nil {
            infoItems.append(.location)
        }
        if !team.name.isEmpty {
            infoItems.append(.rookieYear)
            infoItems.append(.sponsors)
        }
        if !infoItems.isEmpty {
            snapshot.appendSections([.info])
            snapshot.appendItems(infoItems, toSection: .info)
        }

        // Links
        var linkItems: [TeamInfoItem] = [.twitter, .youtube, .chiefDelphi]
        if team.hasWebsite {
            linkItems.insert(.website, at: 0)
        }
        snapshot.appendSections([.link])
        snapshot.appendItems(linkItems, toSection: .link)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func reloadSponsors() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([.sponsors])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Table View Methods

    private func tableView(_ tableView: UITableView, locationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel?.text = "Location"
        cell.subtitleLabel?.text = team?.locationString
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, rookieYearCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
        cell.titleLabel?.text = "Rookie Year"
        cell.subtitleLabel?.text = team?.rookieYear.map(String.init) ?? ""
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }

    private func tableView(_ tableView: UITableView, sponsorCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        cell.textLabel?.text = team?.name
        cell.textLabel?.textColor = UIColor.secondaryLabel

        if sponsorsExpanded {
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.numberOfLines = 3
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }

        return cell
    }

    private func tableView(_ tableView: UITableView, linkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        var urlString: String?
        switch item {
        case .sponsors:
            sponsorsExpanded = true
            reloadSponsors()
        case .website:
            urlString = team?.website
        case .twitter:
            urlString = "https://twitter.com/search?q=%23\(teamKey)"
        case .youtube:
            urlString = "https://www.youtube.com/results?search_query=\(teamKey)"
        case .chiefDelphi:
            urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(teamKey)"
        default:
            break
        }

        if let urlString, let url = URL(string: urlString), urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { team == nil }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            if let fetched = try await self.api.team(key: self.teamKey) {
                self.apply(team: fetched)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { nil }
}
