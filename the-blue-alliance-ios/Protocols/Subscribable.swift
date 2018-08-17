import Foundation
import UIKit

// Subscribable is a protocol view controllers can conform to if they want to have
// the UI to allow users to subscribe to notifications for models
// Ex: The 'Event' view controller conforms to Subscribable, which shows the subscribe UI

protocol Subscribable {
    var favoriteBarButtonItem: UIBarButtonItem! { get }
}

extension Subscribable where Self: UIViewController, Self: Persistable {

    func presentMyTBAPreferences(modelKey: String, modelType: MyTBAModelType) {
        let myTBAPreferencesViewController = MyTBAPreferenceViewController(modelKey: modelKey,
                                                                           modelType: modelType,
                                                                           persistentContainer: persistentContainer,
                                                                           myTBA: MyTBA.shared)
        let navController = UINavigationController(rootViewController: myTBAPreferencesViewController)

        present(navController, animated: true, completion: nil)
    }

}
