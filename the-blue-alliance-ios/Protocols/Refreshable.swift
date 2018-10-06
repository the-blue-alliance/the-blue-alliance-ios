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

    /**
     Identifier that reflects type of data used during refresh, and if we've fetched it before - used to calculate if we should refresh.
     */
    var refreshKey: String { get }

    /**
     DateComponents to be added to the last refresh date to determine if we should refresh stale data now.

     Return nil if we should not automatically refresh for stale date.
     */
    var automaticRefreshInterval: DateComponents? { get }
    
    /**
     The last day we should check if a view should automatically refresh.

     Return nil if we should always automatically refresh the data after automaticRefreshInterval has ellapsed.
     */
    var automaticRefreshEndDate: Date? { get }

    /**
     If the data source for the given view controller is empty - used to calculate if we should refresh.
     */
    var isDataSourceEmpty: Bool { get }

    func refresh()

    func updateRefresh()
    func noDataReload()
}

extension Refreshable {

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    /**
     WARNING: This method should not be called directly - exposed for testing, used internally
     */
    var lastRefresh: Date? {
        get {
            return UserDefaults.standard.object(forKey: refreshKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: refreshKey)
            UserDefaults.standard.synchronize()
        }
    }

    var isRefreshing: Bool {
        // We're not refreshing if our requests array is empty
        return !requests.isEmpty
    }

    func shouldRefresh() -> Bool {
        let hasDataBeenRefreshed = lastRefresh != nil

        var isDataStale = false
        if let lastRefresh = lastRefresh, let automaticRefreshInterval = automaticRefreshInterval {
            let now = Date()
            let nextRefresh = Calendar.current.date(byAdding: automaticRefreshInterval, to: lastRefresh)!

            if nextRefresh.isBetween(date: lastRefresh, andDate: now) {
                if let automaticRefreshEndDate = automaticRefreshEndDate {
                    // Respect end refresh date
                    if now < automaticRefreshEndDate {
                        // If the given amount of time has ellapsed since we refreshed last,
                        // but we haven't hit our automaticRefreshEndDate
                        isDataStale = true
                    } else if now > automaticRefreshEndDate, lastRefresh < automaticRefreshEndDate {
                        // If the last time we refreshed was before our automaticRefreshEndDate
                        // but it's currently past our automaticRefreshEndDate
                        isDataStale = true
                    }
                } else {
                    // End refresh date not set - reload stale data
                    isDataStale = true
                }
            }
        }

        return (!hasDataBeenRefreshed || isDataStale || isDataSourceEmpty) && !isRefreshing
    }

    func markRefreshSuccessful() {
        lastRefresh = Date()
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
            noDataReload()
        }
    }

    /**
     WARNING: This method should not be called directly - exposed for testing, used internally
     */
    func updateRefresh() {
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

    func enableRefreshing() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refresh")), for: .valueChanged)

        self.refreshControl = refreshControl
    }

    func disableRefreshing() {
        refreshControl = nil
    }

}
