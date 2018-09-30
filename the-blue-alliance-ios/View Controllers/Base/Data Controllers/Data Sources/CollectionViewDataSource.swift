import Foundation
import UIKit
import CoreData

// Pattern from: https://github.com/objcio/core-data

protocol CollectionViewDataSourceDelegate: class {

    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UICollectionViewCell, Reusable

    func configure(_ cell: Cell, for object: Object, at indexPath: IndexPath)

    func showNoDataView()
    func hideNoDataView()
}

class CollectionViewDataSource<Result: NSFetchRequestResult, Delegate: CollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    required init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController<Result>, delegate: Delegate) {
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()

        DispatchQueue.main.async {
            collectionView.registerReusableCell(Cell.self)
            collectionView.dataSource = self
            self.collectionView.reloadData()
        }
    }

    var selectedObject: Object? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        return object(at: indexPath)
    }

    func object(at indexPath: IndexPath) -> Object {
        return (fetchedResultsController.object(at: indexPath) as! Object)
    }

    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Result>) -> Void) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        try! fetchedResultsController.performFetch()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: Private

    fileprivate let collectionView: UICollectionView
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
        collectionView.reloadData()
    }

}
