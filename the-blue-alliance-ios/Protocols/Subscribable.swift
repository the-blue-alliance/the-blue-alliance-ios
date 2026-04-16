import Foundation
import MyTBAKit
import TBAUtils
import UIKit

protocol Subscribable {
    var errorRecorder: ErrorRecorder { get }
    var myTBA: MyTBA { get }
    var favoriteBarButtonItem: UIBarButtonItem { get }
    var subscribableModel: MyTBASubscribable { get }
    var myTBAStores: MyTBAStores { get }
}

extension Subscribable where Self: UIViewController {

    func presentMyTBAPreferences() {
        let myTBAPreferencesViewController = MyTBAPreferenceViewController(errorRecorder: errorRecorder,
                                                                           subscribableModel: subscribableModel,
                                                                           myTBA: myTBA,
                                                                           myTBAStores: myTBAStores)
        let navigationController = UINavigationController(rootViewController: myTBAPreferencesViewController)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.presentationController?.delegate = myTBAPreferencesViewController

        present(navigationController, animated: true, completion: nil)
    }

}
