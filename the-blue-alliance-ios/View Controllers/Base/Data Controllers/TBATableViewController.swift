import CoreData
import Foundation
import TBAKit
import UIKit

class TBATableViewController: UITableViewController, TableViewDataSourceDelegate, DataController, Navigatable {

    var persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()
    var userDefaults: UserDefaults

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Init

    init(style: UITableView.Style = .plain, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.registerReusableCell(BasicTableViewCell.self)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            // Setup text
            view.textLabel?.textColor = UIColor.white
            view.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)

            // Set custom background color
            let headerView = UIView()
            headerView.backgroundColor = UIColor.tableViewHeaderColor
            view.backgroundView = headerView
        }
    }

    // MARK: TableViewDataSourceDelegate

    func title(forSection section: Int) -> String? {
        return nil
    }

}

extension Refreshable where Self: TBATableViewController {

    var refreshControl: UIRefreshControl? {
        get {
            return tableView.refreshControl
        }
        set {
            tableView.refreshControl = newValue
        }
    }

    var refreshView: UIScrollView {
        return tableView
    }

    func hideNoData() {
        // Does not conform to Stateful - probably no no data view
    }

    func noDataReload() {
        // Does not conform to Stateful - probably no no data view
    }

}

extension Stateful where Self: TBATableViewController {

    func addNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = noDataView
        }
    }

    func removeNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = nil
        }
    }

}

extension Refreshable where Self: TBATableViewController & Stateful {

    func hideNoData() {
        removeNoDataView()
    }

    func noDataReload() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            removeNoDataView()
        }
    }

}
