import Foundation
import UIKit

@MainActor class CollectionViewDataSource<Section: Sendable & Hashable, Item: Sendable & Hashable>: UICollectionViewDiffableDataSource<Section, Item> {
    // MARK: - Public Methods

    var isEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.numberOfItems == 0
    }
}
