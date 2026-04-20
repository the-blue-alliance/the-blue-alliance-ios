import Foundation
import UIKit

/// CollectionViewDataSource is a wrapper around a UICollectionViewDiffableDataSource that implements
/// UICollectionViewDataSource for TBA where we manage no data states and whatnot for table views
class CollectionViewDataSource<Section: Hashable, Item: Hashable>:
    UICollectionViewDiffableDataSource<Section, Item>
{

    weak var delegate: (Stateful & Refreshable)?

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.numberOfSections == 0 && snapshot.numberOfItems == 0
    }

    // MARK: - Snapshot apply

    override func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        super.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            self?.updateEmptyState()
            completion?()
        }
    }

    override func applySnapshotUsingReloadData(
        _ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,
        completion: (() -> Void)? = nil
    ) {
        super.applySnapshotUsingReloadData(snapshot) { [weak self] in
            self?.updateEmptyState()
            completion?()
        }
    }

    private func updateEmptyState() {
        if isDataSourceEmpty {
            delegate?.showNoDataView()
        } else {
            delegate?.removeNoDataView()
        }
    }

}
