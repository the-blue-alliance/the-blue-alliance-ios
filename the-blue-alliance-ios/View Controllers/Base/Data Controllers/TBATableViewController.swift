import Foundation
import UIKit
import CoreData

class TBATableViewController: UITableViewController, DataController {

    var persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit

    // MARK: - Refreshable

    var requests: [URLSessionDataTask] = []

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Init

    init(style: UITableView.Style = .plain, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit

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

    var refreshView: UIScrollView {
        return tableView
    }

    func noDataReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
