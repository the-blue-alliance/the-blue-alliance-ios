import Foundation
import UIKit

// Refreshable describes a class that has some data that can be refreshed from the server.
protocol Refreshable: AnyObject {
    var currentRefreshTask: Task<Void, Never>? { get set }

    var refreshControl: UIRefreshControl? { get set }
    var refreshView: UIScrollView { get }

    /// If the data source for the given view controller is empty - used to drive the no-data view.
    var isDataSourceEmpty: Bool { get }
    /// False when the screen has nothing to fetch, so containers don't attach a refresh control.
    var supportsRefreshing: Bool { get }
    /// Shown behind the list when it's empty. `nil` shows nothing.
    var noDataText: String? { get }

    func refresh()

    func updateRefresh()
}

extension Refreshable {

    var supportsRefreshing: Bool { true }

    var noDataText: String? { nil }

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
        currentRefreshTask = Task { [weak self] in
            guard let self else { return }
            self.updateRefresh()
            try? await body()
            // A newer refresh cancelled this one and now owns the task handle
            // and the indicator - clearing them here would stop the spinner
            // and flash the no-data view while that refresh is still loading.
            guard !Task.isCancelled else { return }
            self.currentRefreshTask = nil
            self.updateRefresh()
        }
    }

    func updateRefresh() {
        if isRefreshing {
            removeNoDataView()

            showRefreshControl()
        } else {
            refreshControl?.endRefreshing()

            noDataReload()
        }
    }

    /// Spins the refresh control and scrolls it into view.
    ///
    /// UIKit ignores `beginRefreshing()` while the scroll view is offscreen, and refreshes
    /// start from `viewWillAppear` - before the view is in a window. `viewDidAppear` calls
    /// `updateRefresh()` again to pick up anything still in flight.
    func showRefreshControl() {
        guard refreshView.window != nil else {
            return
        }

        let refreshControlHeight = refreshControl?.frame.size.height ?? 0
        refreshView.setContentOffset(
            CGPoint(x: 0, y: -refreshControlHeight),
            animated: true
        )
        refreshControl?.beginRefreshing()
    }

    /// Shows the indicator for a refresh that started while we were offscreen.
    func updateRefreshOnAppear() {
        guard isRefreshing else {
            return
        }
        updateRefresh()
    }

    func enableRefreshing() {
        guard supportsRefreshing else {
            return
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(
            UIAction { [weak self] _ in
                self?.refresh()
            },
            for: .valueChanged
        )

        self.refreshControl = refreshControl
    }

    func disableRefreshing() {
        refreshControl = nil
    }

    // MARK: - No Data

    func noDataReload() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            removeNoDataView()
        }
    }

    /// Skipped mid-refresh so it doesn't flash before the data lands.
    func showNoDataView() {
        guard !isRefreshing else {
            return
        }
        guard let noDataText else {
            removeNoDataView()
            return
        }

        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = noDataText

        if let noDataView = listBackgroundView as? UIContentUnavailableView {
            noDataView.configuration = configuration
            return
        }

        let noDataView = UIContentUnavailableView(configuration: configuration)
        noDataView.alpha = 0
        listBackgroundView = noDataView
        UIView.animate(withDuration: 0.25) {
            noDataView.alpha = 1
        }
    }

    func removeNoDataView() {
        if listBackgroundView is UIContentUnavailableView {
            listBackgroundView = nil
        }
    }

    // Behind the cells, where it can't intercept the pull-to-refresh drag.
    private var listBackgroundView: UIView? {
        get {
            switch refreshView {
            case let tableView as UITableView: tableView.backgroundView
            case let collectionView as UICollectionView: collectionView.backgroundView
            default: nil
            }
        }
        set {
            switch refreshView {
            case let tableView as UITableView: tableView.backgroundView = newValue
            case let collectionView as UICollectionView: collectionView.backgroundView = newValue
            default: break
            }
        }
    }

}
