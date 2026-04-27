import Foundation
import TBAAPI
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBATableViewController, Refreshable, Stateful {

    weak var delegate: DistrictsViewControllerDelegate?
    var year: Int {
        didSet {
            refresh()
        }
    }

    private var districts: [District] = []
    private var dataSource: TableViewDataSource<String, District>!

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

        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let district = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        dataSource = TableViewDataSource<String, District>(tableView: tableView) {
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
            self.apply(try await self.dependencies.api.districtsByYear(self.year))
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No districts for year" }
}
