import Foundation
import UIKit
import CoreData

// Persistable describes a class that uses a persistent data store
// The class must have a persistent container, a data view, and a no data view
protocol Persistable: AnyObject {
    var persistentContainer: NSPersistentContainer! { get set }
    
    var dataView: UIView { get }
    var noDataView: UIView? { get set }
}

extension Persistable {
    
    func showNoDataView(with text: String?) {
        // TODO: Fix this so we update an old no data view if one already exists
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let noDataViewController = mainStoryboard.instantiateViewController(withIdentifier: "NoDataViewController") as! NoDataViewController
        guard let noDataView = noDataViewController.view else {
            fatalError("Failed to get no data view")
        }
        noDataView.backgroundColor = .backgroundGray
        
        if let text = text {
            noDataViewController.textLabel?.text = text
        } else {
            noDataViewController.textLabel?.text = "No data to display"
        }
        
        noDataView.alpha = 0
        if let tableView = dataView as? UITableView {
            tableView.backgroundView = noDataView
        } else if let collectionView = dataView as? UICollectionView {
            collectionView.backgroundView = noDataView
        } else {
            dataView.insertSubview(noDataView, at: 0)
            DispatchQueue.main.async {
                noDataView.autoPinEdgesToSuperviewEdges()
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
        self.noDataView = noDataView
    }
    
    func removeNoDataView() {
        if let tableView = dataView as? UITableView {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        } else if let collectionView = dataView as? UICollectionView {
            DispatchQueue.main.async {
                collectionView.backgroundView = nil
            }
        } else {
            noDataView?.removeFromSuperview()
        }
    }
    
}
