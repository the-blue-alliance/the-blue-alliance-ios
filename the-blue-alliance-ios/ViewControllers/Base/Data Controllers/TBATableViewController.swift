import Foundation
import MyTBAKit
import TBAAPI
import UIKit

class TBATableViewController: UITableViewController, DataController, Navigatable {

    let dependencies: Dependencies

    var api: any TBAAPIProtocol { dependencies.api }
    var myTBA: any MyTBAProtocol { dependencies.myTBA }
    var myTBAStores: MyTBAStores { dependencies.myTBAStores }
    var statusService: any StatusServiceProtocol { dependencies.statusService }
    var urlOpener: any URLOpener { dependencies.urlOpener }

    // MARK: - Refreshable

    var currentRefreshTask: Task<Void, Never>?

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Init

    init(style: UITableView.Style = .plain, dependencies: Dependencies) {
        self.dependencies = dependencies

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

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if type(of: view) == UITableViewHeaderFooterView.self,
            let view = view as? UITableViewHeaderFooterView
        {
            // Setup text
            view.textLabel?.textColor = UIColor.white
            view.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)

            // Set custom background color
            let headerView = UIView()
            headerView.backgroundColor = UIColor.tableViewHeaderColor
            view.backgroundView = headerView
        }
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
