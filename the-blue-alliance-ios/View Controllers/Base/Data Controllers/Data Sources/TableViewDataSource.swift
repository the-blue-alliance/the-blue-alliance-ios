import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol TableViewDataSourceDelegate: class {

    associatedtype Object
    associatedtype Cell: UITableViewCell, Reusable

    var tableView: UITableView! { get }

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

class TableViewDataSource<Result: NSFetchRequestResult, Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    required init(fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()

        DispatchQueue.main.async {
            delegate.tableView.registerReusableCell(Cell.self)
            delegate.tableView.dataSource = self
            delegate.tableView.reloadData()
        }
    }

    func object(at indexPath: IndexPath) -> Object {
        return (fetchedResultsController.object(at: indexPath) as! Object)
    }

    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Result>) -> Void) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        try! fetchedResultsController.performFetch()
        DispatchQueue.main.async {
            self.delegate.tableView.reloadData()
        }
    }

    // MARK: Private

    public let fetchedResultsController: NSFetchedResultsController<Result>
    fileprivate weak var delegate: Delegate!

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
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as Cell
        let object = self.object(at: indexPath)
        delegate.configure(cell, for: object, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate.title(for: section)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.tableView.reloadData()
    }

}
