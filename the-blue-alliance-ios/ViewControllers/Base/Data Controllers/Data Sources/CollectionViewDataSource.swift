import Foundation
import UIKit

class CollectionViewDataSource<Section: Hashable, Item: Hashable>: UICollectionViewDiffableDataSource<Section, Item> {

    // MARK: - Public Methods

    var isEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.numberOfItems == 0
    }

}
