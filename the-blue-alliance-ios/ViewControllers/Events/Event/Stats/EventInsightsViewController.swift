import Foundation
import OpenAPIRuntime
import TBAAPI
import UIKit

struct InsightRow: Hashable {
    var title: String
    var qual: String?
    var playoff: String?
}

class EventInsightsViewController: TBATableViewController, Refreshable, Stateful {

    private let eventKey: String
    private let year: Int
    private let eventStatsConfigurator: EventInsightsConfigurator.Type?

    private var dataSource: TableViewDataSource<String, InsightRow>!

    init(eventKey: String, year: Int, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.year = year

        // Supported event insights is 2016 through 2022 (2021 falls back to 2020).
        switch year {
        case 2016: eventStatsConfigurator = EventInsightsConfigurator2016.self
        case 2017: eventStatsConfigurator = EventInsightsConfigurator2017.self
        case 2018: eventStatsConfigurator = EventInsightsConfigurator2018.self
        case 2019: eventStatsConfigurator = EventInsightsConfigurator2019.self
        case 2020, 2021: eventStatsConfigurator = EventInsightsConfigurator2020.self
        case 2022: eventStatsConfigurator = EventInsightsConfigurator2022.self
        default: eventStatsConfigurator = nil
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

        if eventStatsConfigurator == nil {
            DispatchQueue.main.async {
                self.disableRefreshing()
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
        -> UIView?
    {
        guard section == 0 else {
            return UITableViewHeaderFooterView()
        }
        guard let headerView: EventInsightsHeaderView = tableView.dequeueReusableHeaderFooterView()
        else {
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
        dataSource = TableViewDataSource<String, InsightRow>(tableView: tableView) {
            (tableView, indexPath, row) -> UITableViewCell? in
            if indexPath.section == 0 {
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as EventInsightsTableViewCell
                cell.title = row.title
                cell.leftTitle = row.qual ?? "----"
                cell.rightTitle = row.playoff ?? "----"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as ReverseSubtitleTableViewCell
                cell.titleLabel.text = row.title
                let subtitle: [String] = [
                    "Quals: \(row.qual ?? "----")",
                    "Playoffs: \(row.playoff ?? "----")",
                ]
                cell.subtitleLabel.text = subtitle.joined(separator: "\n")
                return cell
            }
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    private func configureDataSource(qual: [String: Any]?, playoff: [String: Any]?) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        if let eventStatsConfigurator {
            eventStatsConfigurator.configureDataSource(&snapshot, qual, playoff)
        }

        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { dataSource.isDataSourceEmpty }

    func refresh() {
        guard eventStatsConfigurator != nil else { return }
        runRefresh { [weak self] in
            guard let self else { return }
            let insights = try await self.dependencies.api.eventInsights(key: self.eventKey)
            self.configureDataSource(
                qual: Self.toAnyDict(insights.qual),
                playoff: Self.toAnyDict(insights.playoff)
            )
        }
    }

    private static func toAnyDict(_ container: OpenAPIObjectContainer?) -> [String: Any]? {
        guard let container else { return nil }
        var out: [String: Any] = [:]
        for (key, value) in container.value {
            if let value {
                out[key] = value
            }
        }
        return out
    }

    // MARK: - Stateful

    var noDataText: String? {
        guard eventStatsConfigurator == nil else {
            return "No insights for event"
        }
        return "\(year) Event Insights are not supported - try updating your app via the App Store."
    }
}
