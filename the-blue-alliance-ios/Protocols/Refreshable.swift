import Foundation
import TBAKit
import UIKit

protocol RefreshView {
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

// Refreshable describes a class that has some data that can be refreshed from the server
protocol Refreshable: AnyObject {
    var refreshOperationQueue: OperationQueue { get set }

    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    /// Needed to store lastRefresh information
    var userDefaults: UserDefaults { get }

    /**
     Identifier that reflects type of data used during refresh, and if we've fetched it before - used to calculate if we should refresh.

     Should return nil if the view cannot be refreshed.
     */
    var refreshKey: String? { get }

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

    func hideNoData()
    func noDataReload()
}

private let kSuccessfulRefreshKeys = "successful_refresh_keys"

extension Refreshable {

    private var lastRefresh: Date? {
        get {
            guard let refreshKey = refreshKey else {
                return nil
            }
            let successfulRefreshes = userDefaults.dictionary(forKey: kSuccessfulRefreshKeys) ?? [:]
            if let lastRefreshDate = successfulRefreshes[refreshKey] as? Date {
                return lastRefreshDate
            }
            return nil
        }
        set {
            guard let refreshKey = refreshKey else {
                return
            }
            var successfulRefreshes = userDefaults.dictionary(forKey: kSuccessfulRefreshKeys) ?? [:]
            successfulRefreshes[refreshKey] = newValue

            userDefaults.set(successfulRefreshes, forKey: kSuccessfulRefreshKeys)
            userDefaults.synchronize()
        }
    }

    var isRefreshing: Bool {
        // We're not refreshing if our operation queue is empty
        return !refreshOperationQueue.operations.isEmpty
    }

    func shouldRefresh() -> Bool {
        // If there's no refresh key we should never refresh
        if refreshKey == nil {
            return false
        }

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
        return (!hasSuccessfullyRefreshed || isDataStale || isDataSourceEmpty) && !isRefreshing
    }

    /**
     Set our LastModified in TBAKit as well as setting our last successful refresh data for Refreshable.
     */
    func markTBARefreshSuccessful(_ tbaKit: TBAKit, operation: TBAKitOperation, lastRefresh: Date = Date()) {
        tbaKit.storeCacheHeaders(operation)
        markRefreshSuccessful()
    }

    /**
     Set our lastRefresh date - will be used when deciding if we should automatically refresh for new data.
     */
    func markRefreshSuccessful(_ lastRefresh: Date = Date()) {
        self.lastRefresh = lastRefresh
    }

    var hasSuccessfullyRefreshed: Bool {
        return lastRefresh != nil
    }

    // TODO: Add a method to add an observer on a single core data object for changes

    /**
     * Add several operations to be executed in parallel. This method will return the last operation to be executed,
     * which reloads a view and updates the refresh indicator.
     */
    @discardableResult
    func addRefreshOperations(_ operations: [Operation]) -> Operation {
        // Create an operation to update our refresh indicator - should happen last.
        let updateRefreshOperation = BlockOperation {
            self.updateRefresh()
        }
        for op in operations {
            updateRefreshOperation.addDependency(op)
        }

        OperationQueue.main.addOperations([updateRefreshOperation], waitUntilFinished: false)
        refreshOperationQueue.addOperations(operations, waitUntilFinished: false)

        updateRefresh()

        return updateRefreshOperation
    }

    func cancelRefresh() {
        if !refreshOperationQueue.operations.isEmpty {
            refreshOperationQueue.cancelAllOperations()
        }
        updateRefresh()
    }

    /**
     WARNING: This method should not be called directly - exposed for testing, used internally
     */
    func updateRefresh() {
        OperationQueue.main.addOperation {
            if self.isRefreshing {
                self.hideNoData()

                let refreshControlHeight = self.refreshControl?.frame.size.height ?? 0
                self.refreshView.setContentOffset(CGPoint(x: 0, y: -refreshControlHeight), animated: true)
                self.refreshControl?.beginRefreshing()
            } else {
                self.refreshControl?.endRefreshing()

                self.noDataReload()
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

extension UserDefaults {

    func clearSuccessfulRefreshes() {
        removeObject(forKey: kSuccessfulRefreshKeys)
        synchronize()
    }

}
