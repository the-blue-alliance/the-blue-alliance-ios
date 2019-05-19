import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol TableViewDataSourceDelegate: class {

    associatedtype Object
    associatedtype Cell: UITableViewCell, Reusable

    var tableView: UITableView! { get }

    var shouldProcessUpdates: Bool { get }

    func configure(_ cell: Cell, for object: Object, at indexPath: IndexPath)
    func title(for section: Int) -> String?
    func controllerDidChangeContent()
}

extension TableViewDataSourceDelegate {

    func title(for section: Int) -> String? {
        return nil
    }

    func controllerDidChangeContent() {
        // NOP
    }

}

class TableViewDataSource<Result: NSFetchRequestResult, Delegate: TableViewDataSourceDelegate & Stateful & Refreshable>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

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

    fileprivate var sectionUpdates: [SectionUpdate] = []
    fileprivate var rowUpdates: [RowUpdate<Object>] = []

    fileprivate func processUpdates(sections sectionUpdates: [SectionUpdate]?, rows rowUpdates: [RowUpdate<Object>]?) {
        guard let sectionUpdates = sectionUpdates else { return delegate.tableView.reloadData() }
        guard let rowUpdates = rowUpdates else { return delegate.tableView.reloadData() }
        if sectionUpdates.isEmpty, rowUpdates.isEmpty {
            return
        }
        delegate.tableView.performBatchUpdates({
            for update in sectionUpdates {
                switch update {
                case .insert(let indexSet):
                    self.delegate.tableView.insertSections(indexSet, with: .fade)
                case .delete(let indexSet):
                    self.delegate.tableView.deleteSections(indexSet, with: .fade)
                }
            }
            for update in rowUpdates {
                switch update {
                case .insert(let indexPath):
                    self.delegate.tableView.insertRows(at: [indexPath], with: .fade)
                case .update(let indexPath, let object):
                    let cell = self.delegate.tableView.dequeueReusableCell(indexPath: indexPath) as Cell
                    self.delegate.configure(cell, for: object, at: indexPath)
                case .move(let indexPath, let newIndexPath):
                    self.delegate.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.delegate.tableView.insertRows(at: [newIndexPath], with: .fade)
                case .delete(let indexPath):
                    self.delegate.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }, completion: nil)
    }

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
                delegate.removeNoDataView()
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

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionUpdates = []
        rowUpdates = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            sectionUpdates.append(.insert(IndexSet(integer: sectionIndex)))
        case .delete:
            sectionUpdates.append(.delete(IndexSet(integer: sectionIndex)))
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            rowUpdates.append(.insert(indexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = self.object(at: indexPath)
            rowUpdates.append(.update(indexPath, object))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            if indexPath == newIndexPath { return }
            rowUpdates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            rowUpdates.append(.delete(indexPath))
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if delegate.shouldProcessUpdates {
            processUpdates(sections: sectionUpdates, rows: rowUpdates)
            delegate.controllerDidChangeContent()
        }
    }

}
