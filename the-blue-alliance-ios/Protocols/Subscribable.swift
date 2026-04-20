import Foundation
import MyTBAKit
import TBAUtils
import UIKit

protocol Subscribable {
    var dependencies: Dependencies { get }
    var favoriteBarButtonItem: UIBarButtonItem { get }
    var subscribableModel: MyTBASubscribable { get }
}

extension Subscribable where Self: UIViewController {

    func presentMyTBAPreferences() {
        let myTBAPreferencesViewController = MyTBAPreferenceViewController(
            subscribableModel: subscribableModel,
            dependencies: dependencies
        )
        let navigationController = UINavigationController(
            rootViewController: myTBAPreferencesViewController
        )
        navigationController.modalPresentationStyle = .formSheet
        navigationController.presentationController?.delegate = myTBAPreferencesViewController

        present(navigationController, animated: true, completion: nil)
    }

}
