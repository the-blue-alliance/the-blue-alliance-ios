import Foundation
import UIKit

extension UINavigationController {

    func setupSplitViewLeftBarButtonItem(viewController: UIViewController) {
        if viewControllers.firstIndex(of: viewController) == 0 {
            viewController.navigationItem.leftBarButtonItem = viewController.splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
        } else {
            viewController.navigationItem.leftBarButtonItem = nil
            viewController.navigationItem.leftItemsSupplementBackButton = false
        }
    }

}
