import Foundation
import OpenAPIRuntime
import TBAAPI
import UIKit

struct InsightRow: Hashable {
    var title: String
    var value: InsightValue

    enum InsightValue: Hashable {
        case paired(qual: String?, playoff: String?)
        case columns(qual: [String], playoff: [String])
    }
}

// Section 0 renders a custom EventInsightsHeaderView; suppress its default title.
private final class EventInsightsDataSource: TableViewDataSource<String, InsightRow> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        guard section > 0 else { return nil }
        let identifiers = snapshot().sectionIdentifiers
        guard section < identifiers.count else { return nil }
        return identifiers[section]
    }
}

class EventInsightsViewController: TBATableViewController, Refreshable, Stateful {

    private let eventKey: EventKey
    private let year: Int
    private let eventStatsConfigurator: EventInsightsConfigurator.Type?

    private var dataSource: EventInsightsDataSource!

    init(eventKey: EventKey, year: Int, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.year = year

        // Supported event insights is 2016 through 2026 (2021 falls back to 2020).
        switch year {
        case 2016: eventStatsConfigurator = EventInsightsConfigurator2016.self
        case 2017: eventStatsConfigurator = EventInsightsConfigurator2017.self
        case 2018: eventStatsConfigurator = EventInsightsConfigurator2018.self
        case 2019: eventStatsConfigurator = EventInsightsConfigurator2019.self
        case 2020, 2021: eventStatsConfigurator = EventInsightsConfigurator2020.self
        case 2022: eventStatsConfigurator = EventInsightsConfigurator2022.self
        case 2023: eventStatsConfigurator = EventInsightsConfigurator2023.self
        case 2024: eventStatsConfigurator = EventInsightsConfigurator2024.self
        case 2025: eventStatsConfigurator = EventInsightsConfigurator2025.self
        case 2026: eventStatsConfigurator = EventInsightsConfigurator2026.self
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
        tableView.register(
            FourColumnTableViewCell.self,
            forCellReuseIdentifier: FourColumnTableViewCell.reuseIdentifier
        )
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

    // MARK: - Private Methods

    private func setupDataSource() {
        dataSource = EventInsightsDataSource(tableView: tableView) {
            (tableView, indexPath, row) -> UITableViewCell? in
            if indexPath.section == 0 {
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath)
                    as EventInsightsTableViewCell

                cell.title = row.title

                switch row.value {
                case .paired(let qual, let playoff):
                    cell.leftTitle = qual ?? "----"
                    cell.rightTitle = playoff ?? "----"
                default:
                    cell.leftTitle = "----"
                    cell.rightTitle = "----"
                }

                cell.selectionStyle = .none
                return cell
            } else {
                let cell =
                    tableView.dequeueReusableCell(indexPath: indexPath) as FourColumnTableViewCell

                cell.title = row.title

                switch row.value {
                case .columns(let qual, let playoff):
                    cell.qualValues = qual
                    cell.playoffValues = playoff
                default:
                    cell.qualValues = []
                    cell.playoffValues = []
                }
                cell.selectionStyle = .none
                return cell
            }
        }
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
