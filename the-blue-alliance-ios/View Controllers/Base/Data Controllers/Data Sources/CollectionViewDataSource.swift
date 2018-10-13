import Foundation
import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol CollectionViewDataSourceDelegate: class {

    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UICollectionViewCell, Reusable

    var collectionView: UICollectionView! { get }

    func configure(_ cell: Cell, for object: Object, at indexPath: IndexPath)

    func showNoDataView()
    func hideNoDataView()
}

class CollectionViewDataSource<Result: NSFetchRequestResult, Delegate: CollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

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
                delegate.hideNoDataView()
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let deleteIndexPath = indexPath {
                delegate.collectionView.deleteItems(at: [deleteIndexPath])
            }
        case .insert:
            if let insertIndexPath = newIndexPath {
                delegate.collectionView.insertItems(at: [insertIndexPath])
            }
        case .move:
            if let old = indexPath, let new = newIndexPath {
                delegate.collectionView.deleteItems(at: [old])
                delegate.collectionView.insertItems(at: [new])
            }
        case .update:
            if let indexPath = indexPath {
                delegate.collectionView.reloadItems(at: [indexPath])
            }
        }
    }

}
