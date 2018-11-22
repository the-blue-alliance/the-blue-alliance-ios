import Foundation
import UIKit
import CoreData

class TBACollectionViewController: UICollectionViewController, DataController {

    var persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit

    // MARK: - Refreshable

    var requests: [URLSessionDataTask] = []
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

    func noDataReload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
