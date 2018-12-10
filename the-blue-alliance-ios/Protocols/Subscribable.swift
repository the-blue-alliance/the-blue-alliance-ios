import Foundation
import UIKit

// Subscribable is a protocol view controllers can conform to if they want to have
// the UI to allow users to subscribe to notifications for models
// Ex: The 'Event' view controller conforms to Subscribable, which shows the subscribe UI

protocol Subscribable {
    var myTBA: MyTBA { get }
    var favoriteBarButtonItem: UIBarButtonItem { get }
    var subscribableModel: MyTBASubscribable { get }
}

extension Subscribable where Self: UIViewController, Self: Persistable {

    func presentMyTBAPreferences() {
        let myTBAPreferencesViewController = MyTBAPreferenceViewController(subscribableModel: subscribableModel,
                                                                           myTBA: myTBA,
                                                                           persistentContainer: persistentContainer)
        let navController = UINavigationController(rootViewController: myTBAPreferencesViewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

}
