import CoreData
import Foundation
import TBAKit
import UIKit

class TBACollectionViewController: UICollectionViewController, DataController {

    var persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()
    var userDefaults: UserDefaults

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Init

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .backgroundGray
        collectionView.delegate = self
        collectionView.registerReusableCell(BasicCollectionViewCell.self)
    }

    // MARK: - TableViewDataSourceDelegate

    var shouldProcessUpdates: Bool {
        // Don't update our interface if we're in the background

        // Only respond to updates if we're the selected element in the tab bar
        guard let selectedViewController = tabBarController?.selectedViewController else {
            return false
        }
        guard let navigationController = navigationController else {
            return false
        }
        guard selectedViewController == navigationController else {
            return false
        }

        // Only respond to updates if we're the top item in the navigation stack
        if let topViewController = navigationController.topViewController {
            if let parent = parent, topViewController == parent {
                return true
            } else if topViewController == self {
                return true
            }
        }
        return false
    }

}

extension Refreshable where Self: TBACollectionViewController {

    var refreshControl: UIRefreshControl? {
        get {
            return collectionView.refreshControl
        }
        set {
            collectionView.refreshControl = newValue
        }
    }

    var refreshView: UIScrollView {
        return collectionView
    }

    func hideNoData() {
        // Does not conform to Stateful - probably no no data view
    }

    func noDataReload() {
        // Does not conform to Stateful - probably no no data view
    }

}

extension Stateful where Self: TBACollectionViewController {

    func addNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.collectionView.backgroundView = noDataView
        }
    }

    func removeNoDataView(_ view: UIView) {
        DispatchQueue.main.async {
            self.collectionView.backgroundView = nil
        }
    }

}

extension Refreshable where Self: TBACollectionViewController & Stateful {

    func hideNoData() {
        removeNoDataView()
    }

    func noDataReload() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            removeNoDataView()
        }
    }

}
