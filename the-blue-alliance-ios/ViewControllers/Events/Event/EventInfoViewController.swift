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

    private let eventKey: String

    // Loaded from TBAAPI in `refresh()`. Until it's loaded the only row we
    // can render is the title placeholder.
    private var event: Event?

    // Name-only hint (e.g. from search), used for the title cell until the
    // full event loads.
    private var partialName: String?

    private var dataSource: TableViewDataSource<EventInfoSection, EventInfoItem>!

    weak var delegate: EventInfoViewControllerDelegate?

    // MARK: - Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(style: .grouped, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - External

    func apply(event: Event) {
        self.event = event
        if isViewLoaded {
            updateEventInfo()
        }
    }

    func applyPartial(name: String?) {
        partialName = name
        if isViewLoaded, event == nil {
            updateEventInfo()
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = 0
        tableView.registerReusableCell(InfoTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()

        if event != nil || partialName != nil {
            updateEventInfo()
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
                cell.textLabel?.text = "View \(self.eventKey) on Twitter"
                return cell
            case .youtube:
                let cell = self.tableView(tableView, detailCellForRowAtIndexPath: indexPath)
                cell.textLabel?.text = "View \(self.eventKey) on YouTube"
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

        guard let event else {
            dataSource.apply(snapshot, animatingDifferences: false)
            return
        }

        // Webcasts
        let webcasts = event.webcasts
            .sorted { $0.channel > $1.channel } // Sort by name lexicographically
            .filter { $0.urlString != nil } // Only show linkable webcasts
            // Only show webcasts with dates on the specified day
            .filter { webcast in
                // If webcast is date-less, we can display it
                guard let date = webcast.dateParsed else { return true }
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
        if let event {
            cell.viewModel = InfoCellViewModel(event: event)
        } else if let partialName, !partialName.isEmpty {
            let year = String(eventKey.prefix(4))
            let name = year.allSatisfy(\.isNumber) ? "\(year) \(partialName)" : partialName
            cell.viewModel = InfoCellViewModel(nameString: name, subtitleStrings: [])
        } else {
            cell.viewModel = InfoCellViewModel(nameString: eventKey, subtitleStrings: [])
        }

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
            urlString = event?.website
        case .twitter:
            urlString = "https://twitter.com/search?q=%23\(eventKey)"
        case .youtube:
            urlString = "https://www.youtube.com/results?search_query=\(eventKey)"
        case .chiefDelphi:
            urlString = "https://www.chiefdelphi.com/search?q=category%3A11%20tags%3A\(eventKey)"
        default:
            break
        }

        if let urlString, let url = URL(string: urlString), urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { event == nil }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let fetched = try await self.dependencies.api.event(key: self.eventKey)
            self.event = fetched
            self.updateEventInfo()
        }
    }

    // MARK: - Stateful

    var noDataText: String? { nil }
}
