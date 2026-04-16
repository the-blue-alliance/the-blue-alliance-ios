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
        dataSource = TableViewDataSource<String, District>(tableView: tableView) { tableView, indexPath, district in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
            cell.textLabel?.text = district.displayName
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        dataSource.statefulDelegate = self
        dataSource.delegate = self
    }

    private func apply(_ districts: [District]) {
        let sorted = districts.sorted { $0.displayName < $1.displayName }
        self.districts = sorted

        var snapshot = NSDiffableDataSourceSnapshot<String, District>()
        snapshot.appendSections([""])
        snapshot.appendItems(sorted, toSection: "")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Refreshable

    var refreshKey: String? { "\(year)_districts" }
    var automaticRefreshInterval: DateComponents? { DateComponents(day: 7) }
    var automaticRefreshEndDate: Date? {
        Calendar.current.date(from: DateComponents(year: year))
    }
    var isDataSourceEmpty: Bool { districts.isEmpty }

    @objc func refresh() {
        Task { @MainActor in
            do {
                let fetched = try await dependencies.api.districtsByYear(year)
                apply(fetched)
            } catch {
                errorRecorder.record(error)
            }
        }
    }

    // MARK: - Stateful

    var noDataText: String? { "No districts for year" }
}
