import Foundation
import TBAAPI
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

class EventInfoViewController: TBATableViewController, Refreshable, Stateful {

    private var state: EventState
    private let eventName: String?

    private var dataSource: TableViewDataSource<EventInfoSection, EventInfoItem>!

    weak var delegate: EventInfoViewControllerDelegate?

    // MARK: - Init

    convenience init(eventKey: String, name: String? = nil, dependencies: Dependencies) {
        self.init(state: .key(eventKey), eventName: name, dependencies: dependencies)
    }

    convenience init(event: Event, dependencies: Dependencies) {
        self.init(state: .event(event), eventName: nil, dependencies: dependencies)
    }

    private init(state: EventState, eventName: String?, dependencies: Dependencies) {
        self.state = state
        self.eventName = eventName

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
    }

    private func setupDataSource() {
        dataSource = TableViewDataSource<EventInfoSection, EventInfoItem>(
            tableView: tableView,
            cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
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
                    cell.textLabel?.text = "View \(self.state.key) on Twitter"
                    return cell
                case .youtube:
                    let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                    cell.textLabel?.text = "View \(self.state.key) on YouTube"
                    return cell
                case .chiefDelphi:
                    let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                    cell.textLabel?.text = "View photos on Chief Delphi"
                    return cell
                }
            }
        )
    }

    private func updateEventInfo() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        snapshot.appendSections([.title])
        snapshot.appendItems([.title], toSection: .title)

        if let event = state.event {
            let webcasts = event.webcasts
                .sorted { $0.channel > $1.channel }
                .filter { $0.urlString != nil }
                .map { EventInfoItem.webcast($0) }
            if !webcasts.isEmpty, event.isHappeningThisWeek {
                snapshot.appendSections([.webcast])
                snapshot.appendItems(webcasts, toSection: .webcast)
            }
        }

        // Detail rows render even before the event loads so the view isn't
        // a single-row ghost during push. districtPoints is event-dependent
        // so it only appears once we know the event has a district.
        var detailItems: [EventInfoItem] = [.alliances, .insights, .awards]
        if state.event?.district != nil {
            detailItems.insert(.districtPoints, at: 1)
        }
        snapshot.appendSections([.detail])
        snapshot.appendItems(detailItems, toSection: .detail)

        var linkItems: [EventInfoItem] = [.twitter, .youtube, .chiefDelphi]
        if state.event?.hasWebsite == true {
            linkItems.insert(.website, at: 0)
        }
        snapshot.appendSections([.link])
        snapshot.appendItems(linkItems, toSection: .link)

        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Table View Methods

    func tableView(_ tableView: UITableView, titleCellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InfoTableViewCell
        if let event = state.event {
            cell.viewModel = InfoCellViewModel(event: event)
        } else if let eventName, !eventName.isEmpty {
            let year = String(state.key.prefix(4))
            let name = year.allSatisfy(\.isNumber) ? "\(year) \(eventName)" : eventName
            cell.viewModel = InfoCellViewModel(nameString: name, subtitleStrings: [])
        } else {
            cell.viewModel = InfoCellViewModel(nameString: state.key, subtitleStrings: [])
        }

        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, detailCellForRowAtIndexPath indexPath: IndexPath)
        -> UITableViewCell
    {
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
            urlString = state.event?.website
        case .twitter:
            urlString = "https://twitter.com/search?q=%23\(state.key)"
        case .youtube:
            urlString = "https://www.youtube.com/results?search_query=\(state.key)"
        case .chiefDelphi:
            urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(state.key)"
        default:
            break
        }

        if let urlString, let url = URL(string: urlString), urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { state.event == nil }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            self.state = .event(try await self.api.event(key: self.state.key))
            self.updateEventInfo()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { nil }
}
