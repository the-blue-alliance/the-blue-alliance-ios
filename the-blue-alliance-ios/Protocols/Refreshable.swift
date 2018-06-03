import Foundation
import UIKit
import GTMSessionFetcher

protocol RefreshView {
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

// Refreshable describes a class that has some data that can be refreshed from the server
protocol Refreshable: AnyObject {
    var requests: [URLSessionDataTask] { get set }
    var fetches: [GTMSessionFetcher] { get set }
    
    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    func refresh()
    func shouldNoDataRefresh() -> Bool    
}

extension Refreshable {
    
    var isRefreshing: Bool {
        // We're not refreshing if our requests array is empty
        return !requests.isEmpty || !fetches.isEmpty
    }
    
    func shouldRefresh() -> Bool {
        return shouldNoDataRefresh() && !isRefreshing
    }
    
    // TODO: Add a method to add an observer on a single core data object for changes
    
    func cancelRefresh() {
        if requests.isEmpty && fetches.isEmpty {
            return
        }
        
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
        
        for fetch in fetches {
            fetch.stopFetching()
        }
        fetches.removeAll()
        
        updateRefresh()
    }
    
    func addRequest(request: URLSessionDataTask) {
        if requests.contains(request) {
            return
        }
        requests.append(request)
        updateRefresh()
    }
    
    func addFetch(fetch: GTMSessionFetcher) {
        if fetches.contains(fetch) {
            return
        }
        fetches.append(fetch)
        updateRefresh()
    }
    
    func removeRequest(request: URLSessionDataTask) {
        guard let index = requests.index(of: request) else {
            return
        }
        requests.remove(at: index)
        updateRefresh()
        
        if requests.isEmpty {
            noDataReload()
        }
    }
    
    func removeFetch(fetch: GTMSessionFetcher) {
        guard let index = fetches.index(of: fetch) else {
            return
        }
        fetches.remove(at: index)
        updateRefresh()
        
        if fetches.isEmpty {
            noDataReload()
        }
    }
    
    private func noDataReload() {
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
    
}
