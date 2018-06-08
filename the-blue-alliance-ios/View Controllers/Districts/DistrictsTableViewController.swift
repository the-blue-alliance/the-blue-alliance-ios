import UIKit
import CoreData
import TBAKit

class DistrictsTableViewController: TBATableViewController {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }

    internal var year: Int! {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }

    var districtSelected: ((District) -> Void)?

    // MARK: View's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register controller for previewing
        registerController()
    }
    
    // MARK: - Refreshing

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchDistricts(year: year, completion: { (districts, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh districts - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                districts?.forEach({ (modelDistrict) in
                    _ = District.insert(with: modelDistrict, in: backgroundContext)
                })

                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh districts - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let districts = dataSource?.fetchedResultsController.fetchedObjects, districts.isEmpty {
            return true
        }
        return false
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let district = dataSource?.object(at: indexPath)
        if let district = district, let districtSelected = districtSelected {
            districtSelected(district)
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: TableViewDataSource<District, DistrictsTableViewController>?

    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }

        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: basicCellReuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<District>) {
        guard let year = year else {
            return
        }
        request.predicate = NSPredicate(format: "year == %ld", year)
    }

}

extension DistrictsTableViewController: TableViewDataSourceDelegate {

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

extension DistrictsTableViewController: UIViewControllerPreviewingDelegate {
    
    private func registerController() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.registerController()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        // Instantiate Team detail view controller and set its properties
        let districtDetailViewController = storyboard!.instantiateViewController(withIdentifier: "DistrictViewController") as! DistrictViewController
        
        if dataSource?.fetchedResultsController.fetchedObjects != nil {
            districtDetailViewController.district = dataSource?.fetchedResultsController.fetchedObjects![(indexPath as NSIndexPath).row]
        } else {
            return nil
        }
        
        // Configure the source rect to blur surrounding elements
        previewingContext.sourceRect = cell.frame
        
        return districtDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
