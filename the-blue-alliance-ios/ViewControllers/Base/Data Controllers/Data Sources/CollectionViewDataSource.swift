import Foundation
import UIKit

class CollectionViewDataSource<Section: Hashable, Item: Hashable>: UICollectionViewDiffableDataSource<Section, Item> {

    // TODO: Could override our init here to manage supplementaryViewProvider

    // MARK: - Public Methods

    var isEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.numberOfItems == 0
    }

}
