import Foundation
import UIKit

protocol TableSectionTitleProviding {
    var headerTitle: String? { get }
}

class TableViewDataSource<Section: Hashable, Item: Hashable>: UITableViewDiffableDataSource<
    Section, Item
>
{

    weak var statefulDelegate: (Stateful & Refreshable)?

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        let snapshot = snapshot()
        return snapshot.itemIdentifiers.isEmpty
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
            statefulDelegate?.showNoDataView()
        } else {
            statefulDelegate?.removeNoDataView()
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        let identifiers = snapshot().sectionIdentifiers
        guard section >= 0, section < identifiers.count else { return nil }
        return (identifiers[section] as? TableSectionTitleProviding)?.headerTitle
    }

}
