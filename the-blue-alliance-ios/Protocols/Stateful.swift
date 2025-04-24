import Foundation
import UIKit

protocol Stateful: AnyObject {
    var noDataViewController: NoDataViewController { get set }

    /**
     The string to dispaly in the no data view.
     */
    var noDataText: String? { get }

    /**
     Add the no data view to the view hierarchy. This method should not be called directly - you probably want showNoDataView.
     */
    @MainActor func addNoDataView(_ noDataView: UIView)

    /**
     Remove the no data view from the view hierarchy. This method should not be called directly - you probably want removeNoDataView.
     */
    @MainActor func removeNoDataView(_ noDataView: UIView)
}

extension Stateful where Self: UIViewController {

    @MainActor
    func showNoDataView() {
        // If the no data view is already in our view hierarchy, don't animate in
        guard noDataViewController.parent == nil else {
            return
        }

        noDataViewController.noDataText = noDataText

        addChild(noDataViewController)

        noDataViewController.view.alpha = 0
        addNoDataView(noDataViewController.view)

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.noDataViewController.view.alpha = 1.0
        })

        noDataViewController.didMove(toParent: self)
    }

    @MainActor
    func hideNoDataView() {
        guard noDataViewController.parent != nil else {
            return
        }

        noDataViewController.willMove(toParent: nil)
        removeNoDataView(noDataViewController.view)
        noDataViewController.removeFromParent()
    }

}

extension Stateful where Self: UICollectionViewController {

    @MainActor
    func addNoDataView(_ noDataView: UIView) {
        collectionView.backgroundView = noDataView
    }

    @MainActor
    func removeNoDataView(_ noDataView: UIView) {
        collectionView.backgroundView = nil
    }

}
