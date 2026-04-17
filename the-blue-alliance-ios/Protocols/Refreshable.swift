import Foundation
import UIKit

protocol RefreshView {
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
}

// Refreshable describes a class that has some data that can be refreshed from the server.
protocol Refreshable: AnyObject {
    var currentRefreshTask: Task<Void, Never>? { get set }

    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    /// If the data source for the given view controller is empty - used to drive the no-data view.
    var isDataSourceEmpty: Bool { get }

    func refresh()

    func updateRefresh()

    func hideNoData()
    func noDataReload()
}

extension Refreshable {

    var isRefreshing: Bool {
        guard let task = currentRefreshTask else { return false }
        return !task.isCancelled
    }

    func cancelRefresh() {
        currentRefreshTask?.cancel()
        currentRefreshTask = nil
        updateRefresh()
    }

    /// Kick off an async refresh. Cancels any in-flight refresh first, updates the
    /// refresh indicator, runs the body on the main actor, and surfaces errors
    /// silently — transient API failures aren't worth recording.
    func runRefresh(_ body: @escaping @MainActor () async throws -> Void) {
        currentRefreshTask?.cancel()
        currentRefreshTask = Task { @MainActor [weak self] in
            guard let self else { return }
            self.updateRefresh()
            defer {
                self.currentRefreshTask = nil
                self.updateRefresh()
            }
            try? await body()
        }
    }

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
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.refresh()
        }, for: .valueChanged)

        self.refreshControl = refreshControl
    }

    func disableRefreshing() {
        refreshControl = nil
    }

}
