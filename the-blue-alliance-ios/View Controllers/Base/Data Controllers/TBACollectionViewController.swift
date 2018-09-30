import Foundation
import UIKit
import CoreData

class TBACollectionViewController: UICollectionViewController, DataController {

    var persistentContainer: NSPersistentContainer

    var requests: [URLSessionDataTask] = []

    var refreshView: UIScrollView {
        return collectionView
    }
    var noDataViewController: NoDataViewController?

    var refreshControl: UIRefreshControl? = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        super.init(collectionViewLayout: UICollectionViewFlowLayout())

        enableRefreshing()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .backgroundGray
        collectionView.delegate = self
        collectionView.registerReusableCell(BasicCollectionViewCell.self)
    }

    @objc func refresh() {
        fatalError("Implement this downstream")
    }

    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }

    func enableRefreshing() {
        collectionView.refreshControl = refreshControl
    }

    func disableRefreshing() {
        collectionView.refreshControl = nil
    }

}
