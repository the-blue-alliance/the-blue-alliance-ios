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
    func addNoDataView(_ noDataView: UIView)

    /**
     Remove the no data view from the view hierarchy. This method should not be called directly - you probably want removeNoDataView.
     */
    func removeNoDataView(_ noDataView: UIView)
}

extension Stateful {

    /**
     Remove the no data view from the view hierarchy.
     */
    func removeNoDataView() {
        removeNoDataView(noDataViewController.view)
    }

}

extension Stateful where Self: Refreshable {

    /**
     Show the no data view in the view hierarchy.
     */
    func showNoDataView() {
        if isRefreshing {
            return
        }

        noDataViewController.textLabel?.text = noDataText

        let noDataView = noDataViewController.view as UIView

        // If the no data view is already in our view hierarchy, don't animate in
        if noDataView.superview != nil {
            return
        }

        noDataView.alpha = 0
        addNoDataView(noDataView)

        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
    }

}
