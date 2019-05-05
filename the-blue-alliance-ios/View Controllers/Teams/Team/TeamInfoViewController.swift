import CoreData
import TBAKit
import UIKit

private enum TeamInfoSection: Int, CaseIterable {
    case title
    case link
}

private enum TeamTitleRow: Int, CaseIterable {
    // case nickname
    case sponsors
}

private enum TeamLinkRow: Int, CaseIterable {
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class TeamInfoViewController: TBATableViewController {

    private var team: Team
    private let urlOpener: URLOpener

    private var sponsorsExpanded: Bool = false

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
        tableView.registerReusableCell(InfoTableViewCell.self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return TeamInfoSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TeamInfoSection.title.rawValue:
            return TeamTitleRow.allCases.count
        case TeamInfoSection.link.rawValue:
            let max = TeamLinkRow.allCases.count
            return team.hasWebsite ? max : max - 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            switch indexPath.section {
            case TeamInfoSection.title.rawValue:
                switch indexPath.row {
//                case TeamTitleRow.nickname.rawValue:
//                    return self.tableView(tableView, titleCellForRowAt: indexPath)
                case TeamTitleRow.sponsors.rawValue:
                    return self.tableView(tableView, sponsorCellForRowAt: indexPath)
                default:
                    return UITableViewCell()
                }
            case TeamInfoSection.link.rawValue:
                return self.tableView(tableView, linkCellForRowAt: indexPath)
            default:
                return UITableViewCell()
            }
        }()
        return cell
    }

    private func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        cell.viewModel = InfoCellViewModel(team: team)

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    private func tableView(_ tableView: UITableView, sponsorCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        cell.textLabel?.text = team.name
        cell.textLabel?.textColor = .darkGray

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

        var row = indexPath.row
        if !team.hasWebsite, row >= TeamLinkRow.website.rawValue {
            row += 1
        }

        switch row {
        case TeamLinkRow.website.rawValue:
            cell.textLabel?.text = "View team's website"
        case TeamLinkRow.twitter.rawValue:
            cell.textLabel?.text = "View #\(team.key!) on Twitter"
        case TeamLinkRow.youtube.rawValue:
            cell.textLabel?.text = "View \(team.key!) on YouTube"
        case TeamLinkRow.chiefDelphi.rawValue:
            cell.textLabel?.text = "View photos on Chief Delphi"
        default:
            break
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == TeamInfoSection.title.rawValue, indexPath.row == TeamTitleRow.sponsors.rawValue, !sponsorsExpanded {
            sponsorsExpanded = true
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else if indexPath.section == TeamInfoSection.link.rawValue {
            var row = indexPath.row
            if !team.hasWebsite, row >= TeamLinkRow.website.rawValue {
                row += 1
            }

            var urlString: String?
            switch row {
            case TeamLinkRow.website.rawValue:
                urlString = team.website
            case TeamLinkRow.twitter.rawValue:
                urlString = "https://twitter.com/search?q=%23\(team.key!)"
            case TeamLinkRow.youtube.rawValue:
                urlString = "https://www.youtube.com/results?search_query=\(team.key!)"
            case TeamLinkRow.chiefDelphi.rawValue:
                urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(team.key!)"
            default:
                break
            }

            if let urlString = urlString {
                if let url = URL(string: urlString), urlOpener.canOpenURL(url) {
                    urlOpener.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

}

extension TeamInfoViewController: Refreshable {

    var refreshKey: String? {
        return team.key
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return team.name == nil
    }

    @objc func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchTeam(key: team.key!, completion: { (modelTeam, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                // TODO: Team never deleted
                if let modelTeam = modelTeam {
                    Team.insert(modelTeam, in: context)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)

        // TODO: Refresh years participated?
    }

}
