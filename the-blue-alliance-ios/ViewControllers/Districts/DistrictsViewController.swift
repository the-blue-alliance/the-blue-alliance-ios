import Foundation
import TBAAPI
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: (any DistrictsViewControllerDelegate)?
    var year: Int {
        didSet {
            if oldValue == year { return }
            apply([])
            refresh()
        }
    }

    private var districts: [District] = []
    private lazy var dataSource: TableViewDataSource<String, District> = makeDataSource()

    // MARK: - Init

    init(year: Int, dependencies: Dependencies) {
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let district = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func makeDataSource() -> TableViewDataSource<String, District> {
        let dataSource = TableViewDataSource<String, District>(tableView: tableView) {
            tableView,
            indexPath,
            district in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
            cell.textLabel?.text = district.displayName
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityIdentifier = "district.\(district.key)"
            return cell
        }
        dataSource.statefulDelegate = self
        return dataSource
    }

    private func apply(_ districts: [District]) {
        let sorted = districts.sorted { $0.displayName < $1.displayName }
        self.districts = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, District>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool { districts.isEmpty }

    func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let districts = try await self.dependencies.api.districtsByYear(self.year)
            guard !Task.isCancelled else { return }
            self.apply(districts)
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No districts for year" }
}
