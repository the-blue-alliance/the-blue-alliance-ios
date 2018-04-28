import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol TableViewDataSourceDelegate: class {
    associatedtype Object
    associatedtype Cell: UITableViewCell
    func configure(_ cell: Cell, for object: Object, at indexPath: IndexPath)
    func title(for section: Int) -> String?
    
    func showNoDataView()
    func hideNoDataView()
}

extension TableViewDataSourceDelegate {
    func title(for section: Int) -> String? {
        return nil
    }
}

class TableViewDataSource<Result: NSFetchRequestResult, Delegate: TableViewDataSourceDelegate & Refreshable>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell
    
    required init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()

        DispatchQueue.main.async {
            tableView.dataSource = self
            tableView.reloadData()
        }
    }
    
    var selectedObject: Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return object(at: indexPath)
    }
    
    func object(at indexPath: IndexPath) -> Object {
        return (fetchedResultsController.object(at: indexPath) as! Object)
    }
    
    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Result>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        if let fetchedCount = fetchedResultsController.fetchedObjects?.count, fetchedCount == 0, delegate.shouldRefresh() {
            delegate.refresh()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: Private

    fileprivate let tableView: UITableView
    public let fetchedResultsController: NSFetchedResultsController<Result>
    fileprivate weak var delegate: Delegate!
    fileprivate let cellIdentifier: String

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsController.sections?.count ?? 0
        if sections == 0 {
            delegate.showNoDataView()
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        if let sections = fetchedResultsController.sections {
            rows = sections[section].numberOfObjects
            if rows == 0 {
                delegate.showNoDataView()
            } else {
                delegate.hideNoDataView()
            }
        } else {
            delegate.showNoDataView()
        }
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell
            else { fatalError("Unexpected cell type at \(indexPath)") }
        delegate.configure(cell, for: object, at: indexPath)
        return cell
    }

    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate.title(for: section)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
    
}

