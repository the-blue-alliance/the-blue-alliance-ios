import CoreData
import Crashlytics
import TBAData
import TBAKit
import UIKit

private enum TeamInfoSection: Int {
    case info
    case link
}

private enum TeamInfoItem {
    case location
    case sponsors
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class TeamInfoViewController: TBATableViewController, Observable {

    private var team: Team
    private let urlOpener: URLOpener

    private var tableViewDataSource: TableViewDataSource<TeamInfoSection, TeamInfoItem>!

    private var sponsorsExpanded: Bool = false

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(team: Team, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.urlOpener = urlOpener

        super.init(style: .grouped, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)

        setupDataSource()
        tableView.dataSource = tableViewDataSource

        updateTeamInfo()

        // TODO: Add support for Pits
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/163

        contextObserver.observeObject(object: team, state: .updated) { [weak self] (_, _) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateTeamInfo()
            }
        }
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<TeamInfoSection, TeamInfoItem>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            switch item {
            case .location:
                return self.tableView(tableView, locationCellForRowAt: indexPath)
            case .sponsors:
                return self.tableView(tableView, sponsorCellForRowAt: indexPath)
            case .website:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View team's website"
                return cell
            case .twitter:
                let cell = self.tableView(tableView, linkCellForRowAt: indexPath)
                cell.textLabel?.text = "View #\(self.team.key) on Twitter"
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
        tableViewDataSource = TableViewDataSource(dataSource: dataSource)
    }

    private func updateTeamInfo() {
        var snapshot = tableViewDataSource.dataSource.snapshot()

        snapshot.deleteAllItems()

        // Info
        var infoItems: [TeamInfoItem] = []
        if team.hasLocation {
            infoItems.append(.location)
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

        tableViewDataSource.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func reloadSponsors() {
        var snapshot = tableViewDataSource.dataSource.snapshot()
        snapshot.reloadItems([.sponsors])
        tableViewDataSource.dataSource.apply(snapshot, animatingDifferences: true)
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

        guard let item = tableViewDataSource.dataSource.itemIdentifier(for: indexPath) else {
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
        infoOperation = tbaKit.fetchTeam(key: team.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let team):
                    if let team = team {
                        Team.insert(team, in: context)
                    } else if !notModified {
                        // TODO: Delete team, move back up our hiearchy
                    }
                default:
                    break
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: infoOperation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }

        var yearsOperation: TBAKitOperation!
        yearsOperation = tbaKit.fetchTeamYearsParticipated(key: team.key) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let years = try? result.get() {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.setYearsParticipated(years)
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(yearsOperation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }

        addRefreshOperations([infoOperation, yearsOperation])
    }

}
