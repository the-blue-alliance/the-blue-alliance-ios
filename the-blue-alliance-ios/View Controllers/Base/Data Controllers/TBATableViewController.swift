import Foundation
import UIKit
import CoreData

class TBATableViewController: UITableViewController, DataController {
    
    let basicCellReuseIdentifier = "BasicCell"
    
    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return tableView
    }
    var refreshView: UIScrollView {
        return tableView
    }
    var noDataView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = .backgroundGray
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: basicCellReuseIdentifier)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
    
}
