import UIKit
import TBAKit
import CoreData

enum TeamInfoSection: Int {
    case title
    case link
    case max
}

enum TeamTitleRow: Int {
    case nickname
    case sponsors
    case max
}

enum TeamLinkRow: Int {
    case website
    case twitter
    case youtube
    case chiefDelphi
    case max
}

class TeamInfoTableViewController: TBATableViewController {

    var team: Team!
    var sponsorsExpanded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.register(UINib(nibName: String(describing: InfoTableViewCell.self), bundle: nil), forCellReuseIdentifier: InfoTableViewCell.reuseIdentifier)
    }

    // MARK: - Refresh

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeam(key: team.key!, completion: { (modelTeam, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                if let modelTeam = modelTeam {
                    Team.insert(with: modelTeam, in: backgroundContext)
                }

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        // TODO: This is always goign to exist... check on something else?
        return team.name == nil
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

    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIdentifier, for: indexPath) as! InfoTableViewCell

        cell.team = team

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, sponsorCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier, for: indexPath)

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

    func tableView(_ tableView: UITableView, linkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier, for: indexPath)

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
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

}
