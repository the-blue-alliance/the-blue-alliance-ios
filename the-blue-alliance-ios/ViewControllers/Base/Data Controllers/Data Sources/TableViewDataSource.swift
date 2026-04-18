import Foundation
import UIKit

protocol TableViewDataSourceDelegate: AnyObject {
    func title(forSection section: Int) -> String?
}

/// TableViewDataSource is a wrapper around a UITableViewDiffableDataSource that implements
/// UITableViewDataSource for TBA where we manage no data states and whatnot for table views
class TableViewDataSource<Section: Hashable, Item: Hashable>: UITableViewDiffableDataSource<Section, Item> {

    weak var delegate: TableViewDataSourceDelegate?
    weak var statefulDelegate: (Stateful & Refreshable)?

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.itemIdentifiers.isEmpty
    }

    // MARK: - Snapshot apply

    override func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,
                        animatingDifferences: Bool = true,
                        completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            self?.updateEmptyState()
            completion?()
        }
    }

    override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,
                                                completion: (() -> Void)? = nil) {
        super.applySnapshotUsingReloadData(snapshot) { [weak self] in
            self?.updateEmptyState()
            completion?()
        }
    }

    private func updateEmptyState() {
        if isDataSourceEmpty {
            statefulDelegate?.showNoDataView()
        } else {
            statefulDelegate?.removeNoDataView()
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate?.title(forSection: section)
    }

}
