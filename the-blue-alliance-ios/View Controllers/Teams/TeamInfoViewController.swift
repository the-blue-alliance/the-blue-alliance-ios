import UIKit
import TBAKit
import CoreData

private enum TeamInfoSection: Int {
    case title
    case link
    case max
}

private enum TeamTitleRow: Int {
    case nickname
    case sponsors
    case max
}

private enum TeamLinkRow: Int {
    case website
    case twitter
    case youtube
    case chiefDelphi
    case max
}

class TeamInfoViewController: TBATableViewController, Refreshable {

    private var team: Team
    private let urlOpener: URLOpener

    private var sponsorsExpanded: Bool = false

    // MARK: - Init

    init(team: Team, urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.urlOpener = urlOpener

        super.init(style: .grouped, persistentContainer: persistentContainer)
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

    // MARK: - Refresh

    var initialRefreshKey: String? {
        return team.key!
    }

    var isDataSourceEmpty: Bool {
        return team.name == nil
    }

    func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeam(key: team.key!, completion: { (modelTeam, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                if let modelTeam = modelTeam {
                    Team.insert(with: modelTeam, in: backgroundContext)
                }

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return TeamInfoSection.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TeamInfoSection.title.rawValue:
            return TeamTitleRow.max.rawValue
        case TeamInfoSection.link.rawValue:
            let max = TeamLinkRow.max.rawValue
            return team.website != nil ? max : max - 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            switch indexPath.section {
            case TeamInfoSection.title.rawValue:
                switch indexPath.row {
                case TeamTitleRow.nickname.rawValue:
                    return self.tableView(tableView, titleCellForRowAt: indexPath)
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
        if team.website == nil, row >= TeamLinkRow.website.rawValue {
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
            if team.website == nil, row >= TeamLinkRow.website.rawValue {
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
                urlString = "http://www.chiefdelphi.com/media/photos/tags/\(team.key!)"
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
