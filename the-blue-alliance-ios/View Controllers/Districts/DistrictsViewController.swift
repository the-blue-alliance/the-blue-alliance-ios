import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBATableViewController {

    weak var delegate: DistrictsViewControllerDelegate?
    var year: Int {
        didSet {
            updateDataSource()
        }
    }

    private var dataSource: TableViewDataSource<String, District>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<District>!

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
        setupDataSource()
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let district = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func setupDataSource () {
        dataSource = TableViewDataSource<String, District>(tableView: tableView) { (tableView, indexPath, district) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BasicTableViewCell
            cell.textLabel?.text = district.name
            cell.accessoryType = .disclosureIndicator
            // TODO: Convert to some custom cell... show # of events if non-zero
            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()
        fetchRequest.sortDescriptors = [
            District.nameSortDescriptor()
        ]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
    }

    private func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))

        if shouldRefresh() {
            refresh()
        }
    }

    private func setupFetchRequest(_ request: NSFetchRequest<District>) {
        request.predicate = District.yearPredicate(year: year)
    }

}

extension DistrictsViewController: Refreshable {

    var refreshKey: String? {
        return "\(year)_districts"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 7)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh districts until the start of the year
        // Ex: 2019 Districts will automatically refresh until Jan 1st, 2019 (when districts should be all set)
        return Calendar.current.date(from: DateComponents(year: year))
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchDistricts(year: year) { [self] (result, notModified) in
            guard case .success(let districts) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({ [unowned self] in
                District.insert(districts, year: self.year, in: context)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension DistrictsViewController: Stateful {

    var noDataText: String? {
        return "No districts for year"
    }

}
