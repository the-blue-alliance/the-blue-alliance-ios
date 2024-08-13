import CoreData
import FirebaseAnalytics
import TBAData
import TBAKit
import UIKit

protocol EventInfoViewControllerDelegate: AnyObject {
    func showAlliances()
    func showAwards()
    func showDistrictPoints()
    func showInsights()
}

private enum EventInfoSection: Int {
    case title
    case detail
    case webcast
    case link
}

private enum EventInfoItem: Hashable {
    case title
    case webcast(Webcast)
    case alliances
    case districtPoints
    case insights
    case awards
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class EventInfoViewController: TBATableViewController, Observable {

    private let event: Event
    private let urlOpener: URLOpener

    private var dataSource: TableViewDataSource<EventInfoSection, EventInfoItem>!

    weak var delegate: EventInfoViewControllerDelegate?

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(event: Event, urlOpener: URLOpener, dependencies: Dependencies) {
        self.event = event
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
        tableView.registerReusableCell(InfoTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        updateEventInfo()

        contextObserver.observeObject(object: event, state: .updated) { (_, _) in
            DispatchQueue.main.async {
                self.updateEventInfo()
            }
        }
    }

    private func setupDataSource() {
        dataSource = TableViewDataSource<EventInfoSection, EventInfoItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .title:
                return self.tableView(tableView, titleCellForRowAt: indexPath)
            case .webcast(let webcast):
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = "Watch on \(webcast.displayName)"
                cell.detailTextLabel?.text = webcast.channel
                cell.accessoryType = .disclosureIndicator
                return cell
            case .alliances:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "Alliances"
                return cell
            case .districtPoints:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "District Points"
                return cell
            case .insights:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "Insights"
                return cell
            case .awards:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "Awards"
                return cell
            case .website:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "View event's website"
                return cell
            case .twitter:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "View \(self.event.key) on Twitter"
                return cell
            case .youtube:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "View \(self.event.key) on YouTube"
                return cell
            case .chiefDelphi:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "View photos on Chief Delphi"
                return cell
            }
        })
    }

    private func updateEventInfo() {
        var snapshot = dataSource.snapshot()

        snapshot.deleteAllItems()

        // Info
        snapshot.appendSections([.title])
        snapshot.appendItems([.title], toSection: .title)

        // Webcasts
        let webcasts = event.webcasts
            .sorted { $0.channel > $1.channel } // Sort by name lexicographically
            .filter { $0.urlString != nil } // Only show linkable webcasts
            // Only show webcasts with dates on the specified day
            .filter { (webcast) -> Bool in
                // If webcast is date-less, we can display it
                guard let date = webcast.date else {
                    return true
                }
                return Calendar.current.isDateInToday(date)
            }
            .map { EventInfoItem.webcast($0) }
        if !webcasts.isEmpty, event.isHappeningThisWeek {
            snapshot.appendSections([.webcast])
            snapshot.appendItems(webcasts, toSection: .webcast)
        }

        // Details
        var detailItems: [EventInfoItem] = [.alliances, .insights, .awards]
        if event.district != nil {
            detailItems.insert(.districtPoints, at: 1)
        }
        snapshot.appendSections([.detail])
        snapshot.appendItems(detailItems, toSection: .detail)

        // Links
        var linkItems: [EventInfoItem] = [.twitter, .youtube, .chiefDelphi]
        if event.hasWebsite {
            linkItems.insert(.website, at: 0)
        }
        snapshot.appendSections([.link])
        snapshot.appendItems(linkItems, toSection: .link)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Table View Methods

    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        cell.viewModel = InfoCellViewModel(event: event)

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, detailCellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        var urlString: String?
        switch item {
        case .alliances:
            delegate?.showAlliances()
        case .districtPoints:
            delegate?.showDistrictPoints()
        case .insights:
            delegate?.showInsights()
        case .awards:
            delegate?.showAwards()
        case .webcast(let webcast):
            urlString = webcast.urlString
        case .website:
            urlString = event.website
        case .twitter:
            urlString = "https://twitter.com/search?q=%23\(event.key)"
        case .youtube:
            urlString = "https://www.youtube.com/results?search_query=\(event.key)"
        case .chiefDelphi:
            urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(event.key)"
        default:
            break
        }

        if let urlString = urlString, let url = URL(string: urlString), urlOpener.canOpenURL(url) {
            switch item {
            case .webcast(let webcast):
                Analytics.logEvent("watch_webcast", parameters: [
                    "event": event.key,
                    "webcast_channel": webcast.channel,
                    "webcast_type": webcast.type
                ])
            default:
                break
            }
            urlOpener.open(url, options: [:], completionHandler: nil)
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
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvent(key: event.key) { [self] (result, notModified) in
            guard case .success(let object) = result, let event = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Event.insert(event, in: context)
            }, saved: { [unowned self] in
                self.markTBARefreshSuccessful(tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}
