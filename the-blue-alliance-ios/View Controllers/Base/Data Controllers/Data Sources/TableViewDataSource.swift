import Foundation
import UIKit

protocol TableViewDataSourceDelegate: AnyObject {
    func title(forSection section: Int) -> String?
}

/// TableViewDataSource is a wrapper around a UITableViewDiffableDataSource that implements
/// UITableViewDataSource for TBA where we manage no data states and whatnot for table views
class TableViewDataSource<Section: Hashable, Item: Hashable>: NSObject, UITableViewDataSource {

    let dataSource: UITableViewDiffableDataSource<Section, Item>

    weak var delegate: TableViewDataSourceDelegate?
    weak var statefulDelegate: (Stateful & Refreshable)?

    init(dataSource: UITableViewDiffableDataSource<Section, Item>) {
        self.dataSource = dataSource

        super.init()
    }

    // MARK: - Public Methods

    var isDataSourceEmpty: Bool {
        let snapshot = dataSource.snapshot()
        return snapshot.itemIdentifiers.isEmpty
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = dataSource.numberOfSections(in: tableView)
        if sections == 0 {
            statefulDelegate?.showNoDataView()
        }
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = dataSource.tableView(tableView, numberOfRowsInSection: section)
        if rows == 0 {
            statefulDelegate?.showNoDataView()
        } else {
            statefulDelegate?.removeNoDataView()
        }
        return rows
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate?.title(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

}
