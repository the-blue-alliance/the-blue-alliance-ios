import Foundation
import UIKit

/// CollectionViewDataSource is a wrapper around a UICollectionViewDiffableDataSource that implements
/// UICollectionViewDataSource for TBA where we manage no data states and whatnot for table views
class CollectionViewDataSource<Section: Hashable, Item: Hashable>: NSObject, UICollectionViewDataSource {

    private weak var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    weak var delegate: (Stateful & Refreshable)?

    init(dataSource: UICollectionViewDiffableDataSource<Section, Item>) {
        self.dataSource = dataSource

        super.init()
    }

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        guard let snapshot = dataSource?.snapshot() else {
            return true
        }
        return snapshot.numberOfSections == 0 && snapshot.numberOfItems == 0
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = dataSource?.numberOfSections(in: collectionView) ?? 0
        if sections == 0 {
            delegate?.showNoDataView()
        }
        return sections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        if items == 0 {
            delegate?.showNoDataView()
        } else {
            delegate?.removeNoDataView()
        }
        return items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dataSource?.collectionView(collectionView, cellForItemAt: indexPath) else {
            fatalError("dataSource must not be nil")
        }
        return cell
    }

}
