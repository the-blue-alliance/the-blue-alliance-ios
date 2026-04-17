import Foundation
import TBAAPI
import UIKit

protocol EventTeamStatsSelectionDelegate: AnyObject {
    func filterSelected()
    func eventTeamStatSelected(teamKey: String)
}

enum EventTeamStatFilter: String, Comparable, CaseIterable {

    static func < (lhs: EventTeamStatFilter, rhs: EventTeamStatFilter) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case opr = "OPR"
    case dpr = "DPR"
    case ccwm = "CCWM"
}

struct TeamStatRow: Hashable {
    let teamKey: String
    let opr: Float
    let dpr: Float
    let ccwm: Float
}

class EventTeamStatsTableViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: EventTeamStatsSelectionDelegate?

    private let eventKey: String

    private var dataSource: TableViewDataSource<String, TeamStatRow>!
    private var rows: [TeamStatRow] = []

    var filter: EventTeamStatFilter = .opr {
        didSet {
            applyRows(rows)
        }
    }

    lazy private var filerBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage.sortFilterIcon,
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    override var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [filerBarButtonItem]
    }

    // MARK: - Init

    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)
        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.eventTeamStatSelected(teamKey: row.teamKey)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, TeamStatRow>(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(apiTeamKey: row.teamKey, opr: row.opr, dpr: row.dpr, ccwm: row.ccwm)
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func apply(oprs response: EventOPRs?) {
        let oprs = response?.oprs?.additionalProperties ?? [:]
        let dprs = response?.dprs?.additionalProperties ?? [:]
        let ccwms = response?.ccwms?.additionalProperties ?? [:]

        let teamKeys = Set(oprs.keys).union(dprs.keys).union(ccwms.keys)
        let unsorted = teamKeys.map { key in
            TeamStatRow(teamKey: key, opr: oprs[key] ?? 0, dpr: dprs[key] ?? 0, ccwm: ccwms[key] ?? 0)
        }
        applyRows(unsorted)
    }

    private func applyRows(_ unsorted: [TeamStatRow]) {
        let sorted: [TeamStatRow]
        switch filter {
        case .opr:  sorted = unsorted.sorted { $0.opr > $1.opr }
        case .dpr:  sorted = unsorted.sorted { $0.dpr > $1.dpr }
        case .ccwm: sorted = unsorted.sorted { $0.ccwm > $1.ccwm }
        }
        self.rows = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, TeamStatRow>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Interface Actions

    @objc private func showFilter() {
        delegate?.filterSelected()
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { rows.isEmpty }

    @objc func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let response = try await self.dependencies.api.eventOPRs(key: self.eventKey)
            self.apply(oprs: response)
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No team stats for event" }
}
