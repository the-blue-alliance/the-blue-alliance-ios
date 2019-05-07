import Foundation
import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol CollectionViewDataSourceDelegate: class {

    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UICollectionViewCell, Reusable

    var collectionView: UICollectionView! { get }

    func configure(_ cell: Cell, for object: Object, at indexPath: IndexPath)
}

fileprivate enum Update<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
}

class CollectionViewDataSource<Result: NSFetchRequestResult, Delegate: CollectionViewDataSourceDelegate & Stateful & Refreshable>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    required init(fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate

        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()

        DispatchQueue.main.async {
            delegate.collectionView.registerReusableCell(Cell.self)
            delegate.collectionView.dataSource = self
            delegate.collectionView.reloadData()
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
            self.delegate.collectionView.reloadData()
        }
    }

    // MARK: Private

    public let fetchedResultsController: NSFetchedResultsController<Result>
    fileprivate weak var delegate: Delegate!
    fileprivate var updates: [Update<Object>] = []

    fileprivate func processUpdates(_ updates: [Update<Object>]?) {
        guard let updates = updates else { return delegate.collectionView.reloadData() }
        delegate.collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case .insert(let indexPath):
                    self.delegate.collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    guard let cell = self.delegate.collectionView.cellForItem(at: indexPath) as? Cell else { fatalError("wrong cell type") }
                    self.delegate.configure(cell, for: object, at: indexPath)
                case .move(let indexPath, let newIndexPath):
                    self.delegate.collectionView.deleteItems(at: [indexPath])
                    self.delegate.collectionView.insertItems(at: [newIndexPath])
                case .delete(let indexPath):
                    self.delegate.collectionView.deleteItems(at: [indexPath])
                }
            }
        }, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = fetchedResultsController.sections?.count ?? 0
        if sections == 0 {
            delegate.showNoDataView()
        }
        return sections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as Cell
        let object = self.object(at: indexPath)
        delegate.configure(cell, for: object, at: indexPath)
        return cell

    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(indexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = self.object(at: indexPath)
            updates.append(.update(indexPath, object))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        processUpdates(updates)
    }

}
