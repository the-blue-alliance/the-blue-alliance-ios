import CoreData
import FirebaseMessaging
import Foundation
import MyTBAKit
import TBAKit
import UIKit

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    let messaging: Messaging
    let myTBA: MyTBA

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_star"), style: .plain, target: self, action: #selector(myTBAPreferencesTapped))
    }()

    var subscribableModel: MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    // MARK: - Init

    init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, messaging: Messaging, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.messaging = messaging
        self.myTBA = myTBA

        super.init(viewControllers: viewControllers, navigationTitle: navigationTitle, navigationSubtitle: navigationSubtitle, segmentedControlTitles: segmentedControlTitles, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        updateFavoriteButton()

        myTBA.authenticationProvider.add(observer: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface Methods

    func updateFavoriteButton() {
        if myTBA.isAuthenticated {
            rightBarButtonItems = [favoriteBarButtonItem]
        } else {
            rightBarButtonItems = []
        }
    }

    @objc func myTBAPreferencesTapped() {
        presentMyTBAPreferences()
    }

}

extension MyTBAContainerViewController: MyTBAAuthenticationObservable {

    func authenticated() {
        updateFavoriteButton()
    }

    func unauthenticated() {
        updateFavoriteButton()
    }

}
