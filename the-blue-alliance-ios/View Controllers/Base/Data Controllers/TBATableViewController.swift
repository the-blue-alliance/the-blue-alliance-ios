import Foundation
import UIKit
import CoreData

class TBATableViewController: UITableViewController, DataController {

    var persistentContainer: NSPersistentContainer
    var noDataViewController: NoDataViewController?

    var requestsArray: [URLSessionDataTask] = []

    // MARK: - Init

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

    var requests: [URLSessionDataTask] {
        get {
            return requestsArray
        }
        set {
            requestsArray = newValue
        }
    }

    var refreshView: UIScrollView {
        return tableView
    }

    func noDataReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
