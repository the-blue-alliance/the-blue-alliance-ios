import Foundation
import UIKit

protocol Stateful: AnyObject {
    var noDataViewController: NoDataViewController? { get set }
}

extension Stateful where Self: UIViewController {

    func showNoDataView(with text: String?) {
        if noDataViewController == nil {
            guard let noDataVC = Bundle.main.loadNibNamed("NoDataViewController", owner: nil, options: nil)?.first as? NoDataViewController else {
                fatalError("Unable to load no data view controller")
            }
            noDataViewController = noDataVC
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
        if let tableView = view as? UITableView {
            tableView.backgroundView = noDataView
        } else if let collectionView = view as? UICollectionView {
            collectionView.backgroundView = noDataView
        } else if noDataViewController.view.superview == nil {
            view.insertSubview(noDataViewController.view, at: 0)
            DispatchQueue.main.async {
                noDataView.autoPinEdgesToSuperviewEdges()
            }
        }

        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
    }

    func removeNoDataView() {
        if let tableView = view as? UITableView {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        } else if let collectionView = view as? UICollectionView {
            DispatchQueue.main.async {
                collectionView.backgroundView = nil
            }
        } else {
            noDataViewController?.view.removeFromSuperview()
        }
    }

}
