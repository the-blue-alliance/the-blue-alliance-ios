import Foundation
import TBAAPI
import UIKit

struct BreakdownRow: Hashable {

    enum BreakdownRowType {
        case normal
        case subtotal
        case total
    }

    var title: String
    var red: [AnyHashable?] = []
    var blue: [AnyHashable?] = []
    var type: BreakdownRowType = .normal
    var offset: Int = 0  // Used so we can have rows with duplicate titles

    var redElements: [BreakdownElement] {
        return red.compactMap({ $0 as? BreakdownElement })
    }
    var blueElements: [BreakdownElement] {
        return blue.compactMap({ $0 as? BreakdownElement })
    }

}

class MatchBreakdownViewController: TBATableViewController, Refreshable, Stateful {

    private var state: MatchState
    private let year: Int
    private let breakdownConfigurator: MatchBreakdownConfigurator.Type?

    private var dataSource: TableViewDataSource<String?, BreakdownRow>!

    // MARK: - Init

    convenience init(matchKey: String, year: Int, dependencies: Dependencies) {
        self.init(state: .key(matchKey), year: year, dependencies: dependencies)
    }

    convenience init(match: Match, dependencies: Dependencies) {
        let year = match.year ?? MatchKey.year(from: match.key) ?? 0
        self.init(state: .match(match), year: year, dependencies: dependencies)
    }

    private init(state: MatchState, year: Int, dependencies: Dependencies) {
        self.state = state
        self.year = year

        switch year {
        case 2015: breakdownConfigurator = MatchBreakdownConfigurator2015.self
        case 2016: breakdownConfigurator = MatchBreakdownConfigurator2016.self
        case 2017: breakdownConfigurator = MatchBreakdownConfigurator2017.self
        case 2018: breakdownConfigurator = MatchBreakdownConfigurator2018.self
        case 2019: breakdownConfigurator = MatchBreakdownConfigurator2019.self
        case 2020, 2021: breakdownConfigurator = MatchBreakdownConfigurator2020.self
        case 2022: breakdownConfigurator = MatchBreakdownConfigurator2022.self
        case 2024: breakdownConfigurator = MatchBreakdownConfigurator2024.self
        case 2026: breakdownConfigurator = MatchBreakdownConfigurator2026.self
        default: breakdownConfigurator = nil
        }

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(MatchBreakdownTableViewCell.self)
        tableView.insetsContentViewsToSafeArea = false

        setupDataSource()
        tableView.dataSource = dataSource

        if breakdownConfigurator == nil {
            DispatchQueue.main.async {
                self.disableRefreshing()
            }
        }

        configureDataSource(state.match?.breakdownDict, state.match?.compLevel)
    }

    // MARK: - Methods

    func setupDataSource() {
        dataSource = TableViewDataSource<String?, BreakdownRow>(tableView: tableView) {
            (tableView, indexPath, row) -> UITableViewCell? in
            let cell =
                tableView.dequeueReusableCell(indexPath: indexPath) as MatchBreakdownTableViewCell
            cell.titleText = row.title
            cell.redElements = row.redElements
            cell.blueElements = row.blueElements
            cell.type = row.type
            return cell
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    func configureDataSource(
        _ breakdown: [String: Any]?,
        _ compLevel: Components.Schemas.CompLevel?
    ) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        let red = breakdown?["red"] as? [String: Any]
        let blue = breakdown?["blue"] as? [String: Any]

        if let breakdownConfigurator = breakdownConfigurator {
            breakdownConfigurator.configureDataSource(&snapshot, breakdown, red, blue, compLevel)
        }

        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { dataSource.isDataSourceEmpty }

    func refresh() {
        guard breakdownConfigurator != nil else { return }
        runRefresh { [weak self] in
            guard let self else { return }
            self.state = .match(try await self.dependencies.api.match(key: self.state.key))
            self.configureDataSource(
                self.state.match?.breakdownDict,
                self.state.match?.compLevel
            )
        }
    }

    // MARK: - Stateful

    var noDataText: String? {
        guard breakdownConfigurator == nil else {
            return "No breakdown for match"
        }
        return
            "\(year) Match Breakdowns are not supported - try updating your app via the App Store."
    }

}
