import Foundation
import UIKit
import CoreData

class TBACollectionViewController: UICollectionViewController, DataController {

    var persistentContainer: NSPersistentContainer

    let basicCellReuseIdentifier = "BasicCell"
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return collectionView!
    }
    var refreshView: UIScrollView {
        return collectionView!
    }
    var noDataViewController: NoDataViewController?
    var refreshControl: UIRefreshControl?

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .backgroundGray
        collectionView?.delegate = self
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: basicCellReuseIdentifier)

        enableRefreshing()
    }

    @objc func refresh() {
        fatalError("Implement this downstream")
    }

    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }

    func enableRefreshing() {
        collectionView!.refreshControl = UIRefreshControl()
        collectionView!.refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = collectionView!.refreshControl
    }
    func disableRefreshing() {
        refreshControl = nil
    }

}
