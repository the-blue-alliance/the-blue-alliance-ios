import CoreData
import UIKit

/// CollectionViewDataSourceFetchedResultsController implements NSFetchedResultsControllerDelegate
/// and keeps the underlying data in sync with a UICollectionViewDiffableDataSource
class CollectionViewDataSourceFetchedResultsController<Result: NSFetchRequestResult & Hashable>: NSObject, NSFetchedResultsControllerDelegate {

    private(set) var dataSource: UICollectionViewDiffableDataSource<String, Result>
    let fetchedResultsController: NSFetchedResultsController<Result>

    init(dataSource: UICollectionViewDiffableDataSource<String, Result>, fetchedResultsController: NSFetchedResultsController<Result>) {
        self.dataSource = dataSource
        self.fetchedResultsController = fetchedResultsController

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    // MARK: Public Methods

    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Result>) -> Void) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        configure(fetchedResultsController.fetchRequest)
        try! fetchedResultsController.performFetch()
    }

    var isDataSourceEmpty: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return false
        }
        return fetchedObjects.count == 0
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var s = NSDiffableDataSourceSnapshot<String, Result>()
        for section in snapshot.sectionIdentifiers.compactMap({ $0 as? String }) {
            s.appendSections([section])
            s.appendItems(snapshot.itemIdentifiersInSection(withIdentifier: section)
                .compactMap { $0 as? NSManagedObjectID }
                .compactMap { fetchedResultsController.managedObjectContext.object(with: $0) }
                .compactMap { $0 as? Result },
                          toSection: section)
        }
        dataSource.apply(s, animatingDifferences: false)
    }

}
