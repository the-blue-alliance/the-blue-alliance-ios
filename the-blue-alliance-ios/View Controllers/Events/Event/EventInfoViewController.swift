import CoreData
import Crashlytics
import TBAData
import TBAKit
import UIKit

protocol EventInfoViewControllerDelegate: AnyObject {
    func showAlliances()
    func showAwards()
    func showDistrictPoints()
    func showStats()
}

private enum EventInfoSection: Int {
    case title
    case detail
    case link
}

private enum EventInfoItem {
    case title
    case alliances
    case districtPoints
    case stats
    case awards
    case website
    case twitter
    case youtube
    case chiefDelphi
}

class EventInfoViewController: TBATableViewController, Observable {

    private let event: Event
    private let urlOpener: URLOpener

    private var dataSource: UITableViewDiffableDataSource<EventInfoSection, EventInfoItem>!
    private var _dataSource: TableViewDataSource<EventInfoSection, EventInfoItem>!

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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.registerReusableCell(InfoTableViewCell.self)

        setupDataSource()
        updateEventInfo()

        contextObserver.observeObject(object: event, state: .updated) { (_, _) in
            DispatchQueue.main.async {
                self.updateEventInfo()
            }
        }
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<EventInfoSection, EventInfoItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .title:
                return self.tableView(tableView, titleCellForRowAt: indexPath)
            case .alliances:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "Alliances"
                return cell
            case .districtPoints:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "District Points"
                return cell
            case .stats:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "Stats"
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
                cell.textLabel?.text = "View #\(self.event.key) on Twitter"
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
        _dataSource = TableViewDataSource(dataSource: dataSource)
    }

    private func updateEventInfo() {
        var snapshot = dataSource.snapshot()

        snapshot.deleteAllItems()

        // Info
        snapshot.appendSections([.title])
        snapshot.appendItems([.title], toSection: .title)

        // Details
        var detailItems: [EventInfoItem] = [.alliances, .stats, .awards]
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
        case .stats:
            delegate?.showStats()
        case .awards:
            delegate?.showAwards()
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
        operation = tbaKit.fetchEvent(key: event.key) { (result, notModified) in
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
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}
