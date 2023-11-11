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

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = super.numberOfSections(in: tableView)
        if sections == 0 {
            statefulDelegate?.showNoDataView()
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        if rows == 0 {
            statefulDelegate?.showNoDataView()
        } else {
            statefulDelegate?.removeNoDataView()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate?.title(forSection: section)
    }

}
