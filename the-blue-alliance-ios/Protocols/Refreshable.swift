import Foundation
import UIKit

protocol RefreshView {
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

// Refreshable describes a class that has some data that can be refreshed from the server
protocol Refreshable: AnyObject {
    var requests: [URLSessionDataTask] { get set }
    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    func refresh()
    func shouldNoDataRefresh() -> Bool
    
    var dataView: UIView { get }
    var noDataViewController: NoDataViewController? { get set }
}

extension Refreshable {
    
    var isRefreshing: Bool {
        // We're not refreshing if our requests array is empty
        return !requests.isEmpty
    }
    
    func shouldRefresh() -> Bool {
        return shouldNoDataRefresh() && !isRefreshing
    }
    
    // TODO: Add a method to add an observer on a single core data object for changes
    
    func cancelRefresh() {
        if requests.isEmpty {
            return
        }
        
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
        updateRefresh()
    }
    
    func addRequest(request: URLSessionDataTask) {
        if requests.contains(request) {
            return
        }
        requests.append(request)
        updateRefresh()
    }
    
    func removeRequest(request: URLSessionDataTask) {
        guard let index = requests.index(of: request) else {
            return
        }
        requests.remove(at: index)
        updateRefresh()
        
        if requests.isEmpty {
            DispatchQueue.main.async {
                if let tableViewController = self as? UITableViewController {
                    tableViewController.tableView.reloadData()
                } else if let collectionViewController = self as? UICollectionViewController {
                    collectionViewController.collectionView?.reloadData()
                } else if let viewController = self as? TBAViewController {
                    // TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/133
                    viewController.reloadViewAfterRefresh()
                }
            }
        }
    }
    
    private func updateRefresh() {
        DispatchQueue.main.async {
            if self.isRefreshing {
                let refreshControlHeight = self.refreshControl?.frame.size.height ?? 0
                self.refreshView.setContentOffset(CGPoint(x: 0, y: -refreshControlHeight), animated: true)
                self.refreshControl?.beginRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func showNoDataView(with text: String?) {
        if noDataViewController == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            noDataViewController = mainStoryboard.instantiateViewController(withIdentifier: "NoDataViewController") as? NoDataViewController
        }
        guard let noDataViewController = noDataViewController, let noDataView = noDataViewController.view else {
            return
        }
        noDataView.backgroundColor = .clear
        
        if let text = text {
            noDataViewController.textLabel?.text = text
        } else {
            noDataViewController.textLabel?.text = "No data to display"
        }
        
        noDataView.alpha = 0
        if let tableView = dataView as? UITableView {
            tableView.backgroundView = noDataView
        } else if let collectionView = dataView as? UICollectionView {
            collectionView.backgroundView = noDataView
        } else if self is UIViewController, noDataViewController.view.superview == nil {
            dataView.insertSubview(noDataViewController.view, at: 0)
            DispatchQueue.main.async {
                noDataView.autoPinEdgesToSuperviewEdges()
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
    }
    
    func removeNoDataView() {
        if let tableView = dataView as? UITableView {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        } else if let collectionView = dataView as? UICollectionView {
            DispatchQueue.main.async {
                collectionView.backgroundView = nil
            }
        } else {
            noDataViewController?.view.removeFromSuperview()
        }
    }
    
}
