import Foundation
import MyTBAKit
import TBAUtils
import UIKit

// Subscribable is a protocol view controllers can conform to if they want to have
// the UI to allow users to subscribe to notifications for models
// Ex: The 'Event' view controller conforms to Subscribable, which shows the subscribe UI

protocol Subscribable {
    var errorRecorder: ErrorRecorder { get }
    var myTBA: MyTBA { get }
    var favoriteBarButtonItem: UIBarButtonItem { get }
    var subscribableModel: MyTBASubscribable { get }
}

extension Subscribable where Self: UIViewController, Self: Persistable {

    func presentMyTBAPreferences() {
        let myTBAPreferencesViewController = MyTBAPreferenceViewController(errorRecorder: errorRecorder,
                                                                           subscribableModel: subscribableModel,
                                                                           myTBA: myTBA,
                                                                           persistentContainer: persistentContainer)
        let navigationController = UINavigationController(rootViewController: myTBAPreferencesViewController)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.presentationController?.delegate = myTBAPreferencesViewController

        present(navigationController, animated: true, completion: nil)
    }

}
