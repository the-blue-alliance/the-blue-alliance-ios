import CoreData
import TBAData
import TBAKit
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

class TeamInfoViewController: TBATableViewController, Observable {

    private var team: Team
    private let urlOpener: URLOpener

    private var dataSource: TableViewDataSource<TeamInfoSection, TeamInfoItem>!

    private var sponsorsExpanded: Bool = false

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(team: Team, urlOpener: URLOpener, dependencies: Dependencies) {
        self.team = team
        self.urlOpener = urlOpener

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

        updateTeamInfo()

        contextObserver.observeObject(object: team, state: .updated) { [weak self] (_, _) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateTeamInfo()
            }
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
                cell.textLabel?.text = "View \(self.team.key) on Twitter"
                return cell
            case .youtube:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View \(self.team.key) on YouTube"
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

        // Info
        var infoItems: [TeamInfoItem] = []
        if team.hasLocation {
            infoItems.append(.location)
        }
        if team.rookieYear != nil {
            infoItems.append(.rookieYear)
        }
        if team.name != nil {
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
        cell.subtitleLabel?.text = team.locationString

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }
    
    private func tableView(_ tableView: UITableView, rookieYearCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell

        cell.titleLabel?.text = "Rookie Year"
        if let rookieYear = team.rookieYear {
            cell.subtitleLabel?.text = String(rookieYear)
        } else {
            cell.subtitleLabel?.text = "Unknown"
        }

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    private func tableView(_ tableView: UITableView, sponsorCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        cell.textLabel?.text = team.name
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
            urlString = team.website
        case .twitter:
            urlString = "https://twitter.com/search?q=%23\(team.key)"
        case .youtube:
            urlString = "https://www.youtube.com/results?search_query=\(team.key)"
        case .chiefDelphi:
            urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(team.key)"
        default:
            break
        }

        if let urlString = urlString,
            let url = URL(string: urlString), urlOpener.canOpenURL(url) {
                urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

}

extension TeamInfoViewController: Refreshable {

    var refreshKey: String? {
        return team.key
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 7)
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        let years = team.yearsParticipated ?? []
        return team.name == nil || years.isEmpty
    }

    @objc func refresh() {
        var infoOperation: TBAKitOperation!
        infoOperation = tbaKit.fetchTeam(key: team.key) { [self] (result, notModified) in
            guard case .success(let object) = result, let team = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Team.insert(team, in: context)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: infoOperation)
            }, errorRecorder: errorRecorder)
        }

        var yearsOperation: TBAKitOperation!
        yearsOperation = tbaKit.fetchTeamYearsParticipated(key: team.key) { [self] (result, notModified) in
            guard case .success(let years) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let team = context.object(with: self.team.objectID) as! Team
                team.setYearsParticipated(years)
            }, saved: { [unowned self] in
                self.tbaKit.storeCacheHeaders(yearsOperation)
            }, errorRecorder: errorRecorder)
        }

        addRefreshOperations([infoOperation, yearsOperation])
    }

}
