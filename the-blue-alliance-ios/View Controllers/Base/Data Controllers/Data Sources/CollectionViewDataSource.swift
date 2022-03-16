import Foundation
import UIKit

/// CollectionViewDataSource is a wrapper around a UICollectionViewDiffableDataSource that implements
/// UICollectionViewDataSource for TBA where we manage no data states and whatnot for table views
class CollectionViewDataSource<Section: Hashable, Item: Hashable>: UICollectionViewDiffableDataSource<Section, Item> {

    weak var delegate: (Stateful & Refreshable)?

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.numberOfSections == 0 && snapshot.numberOfItems == 0
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = super.numberOfSections(in: collectionView)
        if sections == 0 {
            delegate?.showNoDataView()
        }
        return sections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = super.collectionView(collectionView, numberOfItemsInSection: section)
        if items == 0 {
            delegate?.showNoDataView()
        } else {
            delegate?.removeNoDataView()
        }
        return items
    }

}
