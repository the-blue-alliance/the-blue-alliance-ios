import Foundation
import UIKit
import CoreData
import GTMSessionFetcher

class TBACollectionViewController: UICollectionViewController, DataController {
    
    let basicCellReuseIdentifier = "BasicCell"
    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var fetches: [GTMSessionFetcher] = []
    var dataView: UIView {
        return collectionView!
    }
    var refreshView: UIScrollView {
        return collectionView!
    }
    var noDataViewController: NoDataViewController?
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .backgroundGray
        collectionView?.delegate = self
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: basicCellReuseIdentifier)
        
        collectionView!.refreshControl = UIRefreshControl()
        collectionView!.refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = collectionView!.refreshControl
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
    
}
