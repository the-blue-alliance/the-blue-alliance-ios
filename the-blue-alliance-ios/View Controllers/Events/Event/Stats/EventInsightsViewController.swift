import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

struct InsightRow: Hashable {
    var title: String
    var qual: String?
    var playoff: String?
}

class EventInsightsViewController: TBATableViewController, Observable {

    private let event: Event
    private let eventStatsConfigurator: EventInsightsConfigurator.Type?

    private var dataSource: TableViewDataSource<String, InsightRow>!

    // MARK: - Observable

    typealias ManagedType = Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    init(event: Event, dependencies: Dependencies) {
        self.event = event

        // Supported event insights is 2016 to 2020
        if event.year == 2016 {
            eventStatsConfigurator = EventInsightsConfigurator2016.self
        } else if event.year == 2017 {
            eventStatsConfigurator = EventInsightsConfigurator2017.self
        } else if event.year == 2018 {
            eventStatsConfigurator = EventInsightsConfigurator2018.self
        } else if event.year == 2019 {
            eventStatsConfigurator = EventInsightsConfigurator2019.self
        } else if event.year == 2020 {
            eventStatsConfigurator = EventInsightsConfigurator2020.self
        } else if event.year == 2021 {
            eventStatsConfigurator = EventInsightsConfigurator2020.self
        } else if event.year == 2022 {
            eventStatsConfigurator = EventInsightsConfigurator2022.self
        } else {
            eventStatsConfigurator = nil
        }

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(EventInsightsTableViewCell.self)
        tableView.registerReusableHeaderFooterView(EventInsightsHeaderView.self)
        tableView.registerReusableCell(ReverseSubtitleTableViewCell.self)
        tableView.insetsContentViewsToSafeArea = false

        tableView.dataSource = dataSource
        setupDataSource()

        let eventStatsSupported = (eventStatsConfigurator != nil)
        if eventStatsSupported {
            configureDataSource(event.insights)

            contextObserver.observeObject(object: event, state: .updated) { (event, _) in
                DispatchQueue.main.async {
                    self.configureDataSource(event.insights)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.disableRefreshing()
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return UITableViewHeaderFooterView()
        }
        guard let headerView: EventInsightsHeaderView = tableView.dequeueReusableHeaderFooterView() else {
            return nil
        }

        let snapshot = dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[section]

        headerView.title = section
        headerView.leftTitle = "Quals"
        headerView.rightTitle = "Playoffs"

        return headerView
    }

    // MARK: - TableViewDataSourceDelegate

    override func title(forSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let snapshot = dataSource.snapshot()
        let title = snapshot.sectionIdentifiers[section]
        return title
    }

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, InsightRow>(tableView: tableView) { (tableView, indexPath, row) -> UITableViewCell? in
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as EventInsightsTableViewCell
                cell.title = row.title
                cell.leftTitle = row.qual ?? "----"
                cell.rightTitle = row.playoff ?? "----"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReverseSubtitleTableViewCell
                cell.titleLabel.text = row.title
                let subtitle: [String] = [
                    "Quals: \(row.qual ?? "----")",
                    "Playoffs: \(row.playoff ?? "----")"
                ]
                cell.subtitleLabel.text = subtitle.joined(separator: "\n")
                return cell
            }
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func configureDataSource(_ insights: EventInsights?) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        let qual = insights?.qual
        let playoff = insights?.playoff

        if let eventStatsConfigurator = eventStatsConfigurator {
            eventStatsConfigurator.configureDataSource(&snapshot, qual, playoff)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

extension EventInsightsViewController: Refreshable {

    var refreshKey: String? {
        if eventStatsConfigurator == nil {
            return nil
        }
        return "\(event.key)_insights"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(hour: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh event insights until the event is over
        return event.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEventInsights(key: event.key) { [self] (result, notModified) in
            guard case .success(let object) = result, let insights = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let event = context.object(with: self.event.objectID) as! Event
                event.insert(insights)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension EventInsightsViewController: Stateful {

    var noDataText: String? {
        guard eventStatsConfigurator == nil else {
            return "No insights for event"
        }
        return "\(event.year) Event Insights are not supported - try updating your app via the App Store."
    }

}
