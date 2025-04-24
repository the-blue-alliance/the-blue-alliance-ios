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

    /**
     If the data source for the given view controller is empty - used to calculate if we should refresh.
     */
    var isDataSourceEmpty: Bool { get }

    func refresh()

    func updateRefresh()

    func hideNoData()
    func noDataReload()
}

extension Refreshable {

    var isRefreshing: Bool {
        // We're not refreshing if our operation queue is empty
        return !refreshOperationQueue.operations.isEmpty
    }

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
