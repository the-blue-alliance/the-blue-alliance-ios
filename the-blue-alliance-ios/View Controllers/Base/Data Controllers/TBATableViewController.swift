import Foundation
import UIKit
import CoreData

class TBATableViewController: UITableViewController, DataController {

    var persistentContainer: NSPersistentContainer

    let basicCellReuseIdentifier = "BasicCell"

    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return tableView
    }
    var refreshView: UIScrollView {
        return tableView
    }
    var noDataViewController: NoDataViewController?

    init(style: UITableView.Style = .plain, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

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
        tableView.backgroundColor = .backgroundGray
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: basicCellReuseIdentifier)

        enableRefreshing()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.primaryDarkBlue
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
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
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    func disableRefreshing() {
        refreshControl = nil
    }

}
