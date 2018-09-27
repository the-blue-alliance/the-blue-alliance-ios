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

    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistricts(year: year, completion: { (districts, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh districts - \(error.localizedDescription)")
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                districts?.forEach({ (modelDistrict) in
                    District.insert(with: modelDistrict, in: backgroundContext)
                })

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let districts = dataSource.fetchedResultsController.fetchedObjects, districts.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let district = dataSource.object(at: indexPath)
        delegate?.districtSelected(district)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: basicCellReuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<District>) {
        request.predicate = NSPredicate(format: "year == %ld", year)
    }

}

extension DistrictsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: District, at indexPath: IndexPath) {
        cell.textLabel?.text = object.name
        cell.accessoryType = .disclosureIndicator
        // TODO: Convert to some custom cell... show # of events if non-zero
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load districts")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
