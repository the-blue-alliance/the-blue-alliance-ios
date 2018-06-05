import Foundation
import UIKit

protocol Stateful: AnyObject {
    var dataView: UIView { get }
    var noDataViewController: NoDataViewController? { get set }
}

extension Stateful {

    func showNoDataView(with text: String?) {
        if noDataViewController == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            noDataViewController = mainStoryboard.instantiateViewController(withIdentifier: "NoDataViewController") as? NoDataViewController
        }
        guard let noDataViewController = noDataViewController, let noDataView = noDataViewController.view else {
            return
        }
        noDataView.backgroundColor = .clear

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
        } else if self is UIViewController, noDataViewController.view.superview == nil {
            dataView.insertSubview(noDataViewController.view, at: 0)
            DispatchQueue.main.async {
                noDataView.autoPinEdgesToSuperviewEdges()
            }
        }

        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
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
            noDataViewController?.view.removeFromSuperview()
        }
    }

}
