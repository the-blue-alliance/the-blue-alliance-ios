import UIKit
import TBAKit
import CoreData

enum EventInfoSection: Int {
    case title
    case detail
    case link
    case max
}

enum EventDetailRow: Int {
    case alliances
    case districtPoints
    case stats
    case awards
    case max
}

enum EventLinkRow: Int {
    case website
    case twitter
    case youtube
    case chiefDelphi
    case max
}

class EventInfoTableViewController: TBATableViewController, Observable {

    public var event: Event!

    public var showAlliances: (() -> Void)?
    public var showDistrictPoints: (() -> Void)?
    public var showStats: (() -> Void)?
    public var showAwards: (() -> Void)?

    // MARK: - Persistable

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            contextObserver.observeObject(object: event, state: .updated) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.register(UINib(nibName: String(describing: InfoTableViewCell.self), bundle: nil), forCellReuseIdentifier: InfoTableViewCell.reuseIdentifier)
    }

    // MARK: - Refresh

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEvent(key: event.key!, completion: { (modelEvent, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                if let modelEvent = modelEvent {
                    _ = Event.insert(with: modelEvent, in: backgroundContext)
                }

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        return event.name == nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventInfoSection.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EventInfoSection.title.rawValue:
            return 1
        case EventInfoSection.detail.rawValue:
            // Only show Alliances, Stats, and Awards if event isn't a district
            let max = EventDetailRow.max.rawValue
            return event.district != nil ? max : max - 1
        case EventInfoSection.link.rawValue:
            let max = EventLinkRow.max.rawValue
            return event.website != nil ? max : max - 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            switch indexPath.section {
            case EventInfoSection.title.rawValue:
                return self.tableView(tableView, titleCellForRowAt: indexPath)
            case EventInfoSection.detail.rawValue:
                return self.tableView(tableView, detailCellForRowAt: indexPath)
            case EventInfoSection.link.rawValue:
                return self.tableView(tableView, linkCellForRowAt: indexPath)
            default:
                return UITableViewCell()
            }
        }()
        return cell
    }

    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIdentifier, for: indexPath) as! InfoTableViewCell

        cell.event = event

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, detailCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier, for: indexPath)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier, for: indexPath)

        var row = indexPath.row
        if event.website == nil, row >= EventLinkRow.website.rawValue {
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
                if let showAlliances = showAlliances {
                    showAlliances()
                }
            case EventDetailRow.districtPoints.rawValue:
                if let showDistrictPoints = showDistrictPoints {
                    showDistrictPoints()
                }
            case EventDetailRow.stats.rawValue:
                if let showStats = showStats {
                    showStats()
                }
            case EventDetailRow.awards.rawValue:
                if let showAwards = showAwards {
                    showAwards()
                }
            default:
                break
            }
        } else if indexPath.section == EventInfoSection.link.rawValue {
            var row = indexPath.row
            if event.website == nil, row >= EventLinkRow.website.rawValue {
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
                urlString = "http://www.chiefdelphi.com/media/photos/tags/\(event.key!)"
            default:
                break
            }

            if let urlString = urlString {
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }

            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
