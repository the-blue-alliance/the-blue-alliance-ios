import CoreData
import Foundation
import TBAKit
import TBAUtils
import UIKit

class TBACollectionViewController: UICollectionViewController, DataController, Navigatable {

    private let dependencies: Dependencies

    var errorRecorder: ErrorRecorder {
        return dependencies.errorRecorder
    }
    var persistentContainer: NSPersistentContainer {
        return dependencies.persistentContainer
    }
    var tbaKit: TBAKit {
        return dependencies.tbaKit
    }
    var userDefaults: UserDefaults {
        return dependencies.userDefaults
    }

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
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
        collectionView.delegate = self
        collectionView.registerReusableCell(BasicCollectionViewCell.self)
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
