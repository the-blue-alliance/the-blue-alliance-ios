import Foundation
import UIKit
import CoreData

class TBATableViewController: UITableViewController, DataController {

    var persistentContainer: NSPersistentContainer

    var requests: [URLSessionDataTask] = []
    var refreshView: UIScrollView {
        return tableView
    }
    var noDataViewController: NoDataViewController?

    private var _refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    init(style: UITableView.Style = .plain, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        super.init(style: style)

        enableRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = .backgroundGray
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.registerReusableCell(BasicTableViewCell.self)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            headerView.backgroundView?.backgroundColor = .primaryDarkBlue
        }
    }

    // MARK: - Refreshable

    @objc func refresh() {
        fatalError("Implement this downstream")
    }

    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }

    func enableRefreshing() {
        tableView.refreshControl = _refreshControl
    }

    func disableRefreshing() {
        tableView.refreshControl = nil
    }

}
