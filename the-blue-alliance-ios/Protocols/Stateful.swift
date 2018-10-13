import Foundation
import UIKit

protocol Stateful: AnyObject {
    var noDataViewController: NoDataViewController { get set }

    /**
     The string to dispaly in the no data view.
    */
    var noDataText: String { get }

    /**
     Add the no data view to the view hiearchy.
     */
    func addNoDataView(_ view: UIView)

    /**
     Remove the no data view from the view hiearchy.
     */
    func removeNoDataView(_ view: UIView)
}

extension Stateful where Self: Refreshable {

    /**
     Show the no data view in the view hiearchy.
     */
    func showNoDataView() {
        if isRefreshing {
            return
        }

        noDataViewController.textLabel?.text = noDataText

        let noDataView = noDataViewController.view as UIView

        // If the no data view is already in our view hiearchy, don't animate in
        if noDataView.superview != nil {
            return
        }

        noDataView.alpha = 0
        addNoDataView(noDataView)

        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
    }

    /**
     Remove the no data view from the view hiearchy.
     */
    func removeNoDataView() {
        removeNoDataView(noDataViewController.view)
    }

}
