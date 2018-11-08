import Foundation
import UIKit
import CoreData
import TBAKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBATableViewController {

    var year: Int {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }

    weak var delegate: DistrictsViewControllerDelegate?
    private var dataSource: TableViewDataSource<District, DistrictsViewController>!

    // MARK: - Init

    init(year: Int, persistentContainer: NSPersistentContainer) {
        self.year = year

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let district = dataSource.object(at: indexPath)
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func setupDataSource () {
        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<District>) {
        request.predicate = NSPredicate(format: "year == %ld", year)
    }

}

extension DistrictsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: BasicTableViewCell, for object: District, at indexPath: IndexPath) {
        cell.textLabel?.text = object.name
        cell.accessoryType = .disclosureIndicator
        // TODO: Convert to some custom cell... show # of events if non-zero
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
        if let districts = dataSource.fetchedResultsController.fetchedObjects, districts.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistricts(year: year, completion: { (districts, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh districts - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let districts = districts {
                    District.insert(districts, year: self.year, in: backgroundContext)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}

extension DistrictsViewController: Stateful {

    var noDataText: String {
        return "No districts for year"
    }

}
