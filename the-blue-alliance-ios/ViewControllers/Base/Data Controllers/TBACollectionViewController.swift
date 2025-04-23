import TBAAPI
import CoreData
import Foundation
import TBAKit
import TBAUtils
import UIKit

class TBACollectionViewController<Section: Hashable, Item: Hashable>: UICollectionViewController, Stateful {

    let dependencies: Dependencies

    var api: TBAAPI {
        return dependencies.api
    }

    var dataSource: CollectionViewDataSource<Section, Item>!

    // MARK: - Private Properties

    private var hasViewWillAppeared = false

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    var noDataText: String? {
        fatalError("Should implement in subclass")
    }

    @MainActor
    func addNoDataView(_ noDataView: UIView) {
        collectionView.backgroundView = noDataView
    }

    @MainActor
    func removeNoDataView(_ noDataView: UIView) {
        collectionView.backgroundView = nil
    }

    // MARK: - Init

    init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout(), dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.systemGroupedBackground
        // collectionView.delegate = self

        enableRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !hasViewWillAppeared, dataSource.isEmpty {
            refresh()
        }
        hasViewWillAppeared = true
    }

    // MARK: - Refresh

    private var refreshTask: Task<Void, any Error>?

    var isRefreshing: Bool {
        guard let refreshTask else {
            return false
        }
        return !refreshTask.isCancelled
    }

    func refresh() {
        guard !isRefreshing else {
            return
        }

        refreshTask = Task {
            await MainActor.run {
                refreshDidStart()
            }

            var refreshError: Error?
            do {
                try await performRefresh()
            } catch is CancellationError {
                // Do not show error if request cancelled
            } catch {
                refreshError = error
            }

            await MainActor.run {
                refreshDidEnd(error: refreshError)
                refreshTask = nil
            }
        }
    }

    func cancelRefresh() {
        refreshTask?.cancel()
    }

    @MainActor
    func refreshDidStart() {
        hideNoDataView()
    }

    @MainActor
    func refreshDidEnd(error: (any Error)?) {
        collectionView.refreshControl?.endRefreshing()

        noDataReload(error: error)
    }

    @MainActor
    func noDataReload(error: (any Error)?) {
        if let error {
            noDataViewController.noDataText = error.localizedDescription
            showNoDataView()
        } else if dataSource.isEmpty {
            showNoDataView()
        } else {
            hideNoDataView()
        }
    }

    @MainActor
    func enableRefreshing() {
        guard collectionView.refreshControl == nil else {
            return
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControlTrigger(_:)), for: .valueChanged)

        collectionView.refreshControl = refreshControl
    }

    @MainActor
    func disableRefreshing() {
        collectionView.refreshControl = nil

        cancelRefresh()
    }

    @MainActor
    @objc private func handleRefreshControlTrigger(_ sender: UIRefreshControl) {
        Task {
            refresh()
        }
    }

    func performRefresh() async throws {
        fatalError("Should implement performRefresh in sublcass")
    }

}
