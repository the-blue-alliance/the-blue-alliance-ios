import Foundation
import UIKit

class TBACollectionViewController<Cell: UICollectionViewCell & Reusable, Item: Sendable & Hashable>:
    UICollectionViewController, Stateful
{

    private(set) weak var dependencyProvider: DependencyProvider!

    var cellRegistration: UICollectionView.CellRegistration<Cell, Item> {
        fatalError("Subclasses must override cellRegistration and provide a concrete registration.")
    }
    private(set) var dataSource: CollectionViewDataSource<String, Item>!

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    var noDataText: String? {
        fatalError("Should implement in subclass")
    }
    
    // MARK: - Private Properties

    private var hasViewWillAppeared = false

    // MARK: - Init

    init(dependencyProvider: DependencyProvider, collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.dependencyProvider = dependencyProvider

        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        refreshTask = nil
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.systemGroupedBackground

        setupDataSource()
        enableRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !hasViewWillAppeared, dataSource.isEmpty {
            refresh()
        }
        hasViewWillAppeared = true
    }

    // MARK: - Data Source

    private func setupDataSource() {
        let cellRegistration = cellRegistration
        dataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        })
    }

    // MARK: - Refresh

    func performRefresh() async throws {
        fatalError("Should implement performRefresh in sublcass")
    }

    private var refreshTask: Task<Void, any Error>? {
        willSet {
            refreshTask?.cancel()
        }
    }

    private var isRefreshing: Bool {
        guard let refreshTask else {
            return false
        }
        return !refreshTask.isCancelled
    }

    @MainActor
    private func refreshDidStart() {
        assert(Thread.isMainThread, "Should be running on the main thread!!")

        hideNoDataView()
    }

    @MainActor
    private func refreshDidEnd(error: (any Error)?) {
        assert(Thread.isMainThread, "Should be running on the main thread!!")

        collectionView.refreshControl?.endRefreshing()

        if let error {
            noDataViewController.noDataText = error.localizedDescription
            showNoDataView()
        } else if dataSource.isEmpty {
            noDataViewController.noDataText = noDataText
            showNoDataView()
        } else {
            hideNoDataView()
        }
    }

    @MainActor
    private func enableRefreshing() {
        assert(Thread.isMainThread, "Should be running on the main thread!!")

        guard collectionView.refreshControl == nil else {
            return
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControlTrigger(_:)), for: .valueChanged)

        collectionView.refreshControl = refreshControl
    }

    @MainActor
    private func disableRefreshing() {
        assert(Thread.isMainThread, "Should be running on the main thread!!")

        collectionView.refreshControl = nil

        cancelRefresh()
    }

    @MainActor
    @objc private func handleRefreshControlTrigger(_ sender: UIRefreshControl) {
        Task { [weak self] in
            self?.refresh()
        }
    }

}

// MARK: - Refresh

extension TBACollectionViewController {

    func refresh() {
        guard !isRefreshing else {
            return
        }

        refreshTask = Task.detached { [weak self] in
            guard let self else { return }

            await refreshDidStart()

            var refreshError: Error?
            do {
                try await performRefresh()
            } catch is CancellationError {
                // Do not show error if request cancelled
            } catch {
                refreshError = error
            }

            await refreshDidEnd(error: refreshError)
            await clearRefreshTask()
        }
    }

    @MainActor func clearRefreshTask() {
        refreshTask = nil
    }

    func cancelRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

}
