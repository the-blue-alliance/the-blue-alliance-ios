import CoreData
import TBAKit
import UIKit

protocol EventInfoViewControllerDelegate: AnyObject {
    func showAlliances()
    func showAwards()
    func showDistrictPoints()
    func showStats()
}

private enum EventInfoSection: Int, CaseIterable {
    case title
    case detail
    case link
}

private enum EventDetailRow: Int, CaseIterable {
    case alliances
    case districtPoints
    case stats
    case awards
}

private enum EventLinkRow: Int, CaseIterable {
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class EventInfoViewController: TBATableViewController, Observable {

    private let event: Event
    private let urlOpener: URLOpener

    weak var delegate: EventInfoViewControllerDelegate?

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(event: Event, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.urlOpener = urlOpener

        super.init(style: .grouped, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        contextObserver.observeObject(object: event, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        return EventInfoSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = EventInfoSection(rawValue: section) else {
            return 0
        }

        switch section {
        case .title:
            return 1
        case .detail:
            // Only show Alliances, Stats, and Awards if event isn't a district
            let max = EventDetailRow.allCases.count
            return event.district != nil ? max : max - 1
        case .link:
            let max = EventLinkRow.allCases.count
            return event.hasWebsite ? max : max - 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let section = EventInfoSection(rawValue: indexPath.section) else {
                return UITableViewCell()
            }

            switch section {
            case .title:
                return self.tableView(tableView, titleCellForRowAt: indexPath)
            case .detail:
                return self.tableView(tableView, detailCellForRowAt: indexPath)
            case .link:
                return self.tableView(tableView, linkCellForRowAt: indexPath)
            }
        }()
        return cell
    }

    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        cell.viewModel = InfoCellViewModel(event: event)

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, detailCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        var row = indexPath.row
        if event.district == nil, row >= EventDetailRow.districtPoints.rawValue {
            row += 1
        }

        switch row {
        case EventDetailRow.alliances.rawValue:
            cell.textLabel?.text = "Alliances"
        case EventDetailRow.districtPoints.rawValue:
            cell.textLabel?.text = "District Points"
        case EventDetailRow.stats.rawValue:
            cell.textLabel?.text = "Stats"
        case EventDetailRow.awards.rawValue:
            cell.textLabel?.text = "Awards"
        default:
            break
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, linkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell

        var row = indexPath.row
        if !event.hasWebsite, row >= EventLinkRow.website.rawValue {
            row += 1
        }

        switch row {
        case EventLinkRow.website.rawValue:
            cell.textLabel?.text = "View event's website"
        case EventLinkRow.twitter.rawValue:
            cell.textLabel?.text = "View #\(event.key!) on Twitter"
        case EventLinkRow.youtube.rawValue:
            cell.textLabel?.text = "View \(event.key!) on YouTube"
        case EventLinkRow.chiefDelphi.rawValue:
            cell.textLabel?.text = "View photos on Chief Delphi"
        default:
            break
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == EventInfoSection.detail.rawValue {
            var row = indexPath.row
            if event.district == nil, row >= EventDetailRow.districtPoints.rawValue {
                row += 1
            }

            switch row {
            case EventDetailRow.alliances.rawValue:
                delegate?.showAlliances()
            case EventDetailRow.districtPoints.rawValue:
                delegate?.showDistrictPoints()
            case EventDetailRow.stats.rawValue:
                delegate?.showStats()
            case EventDetailRow.awards.rawValue:
                delegate?.showAwards()
            default:
                break
            }
        } else if indexPath.section == EventInfoSection.link.rawValue {
            var row = indexPath.row
            if !event.hasWebsite, row >= EventLinkRow.website.rawValue {
                row += 1
            }

            var urlString: String?
            switch row {
            case EventLinkRow.website.rawValue:
                urlString = event.website
            case EventLinkRow.twitter.rawValue:
                urlString = "https://twitter.com/search?q=%23\(event.key!)"
            case EventLinkRow.youtube.rawValue:
                urlString = "https://www.youtube.com/results?search_query=\(event.key!)"
            case EventLinkRow.chiefDelphi.rawValue:
                urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(event.key!)"
            default:
                break
            }

            if let urlString = urlString, let url = URL(string: urlString), urlOpener.canOpenURL(url) {
                urlOpener.open(url, options: [:], completionHandler: nil)
            }

            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

extension EventInfoViewController: Refreshable {

    var refreshKey: String? {
        return event.key
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return event.name == nil
    }

    @objc func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchEvent(key: event.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let event):
                    if let event = event {
                        Event.insert(event, in: context)
                    } else if !notModified {
                        // TODO: Delete event, bump back up navigation stack
                    }
                default:
                    break
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}
