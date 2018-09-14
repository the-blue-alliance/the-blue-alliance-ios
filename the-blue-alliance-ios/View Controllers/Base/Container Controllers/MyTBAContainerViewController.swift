import Foundation
import UIKit

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_star"), style: .plain, target: self, action: #selector(myTBAPreferencesTapped))
    }()

    var subscribableModel: MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateFavoriteButton()

        MyTBA.shared.authenticationProvider.add(observer: self)
    }


    // MARK: - Interface Methods

    func updateFavoriteButton() {
        if MyTBA.shared.isAuthenticated, navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = favoriteBarButtonItem
        } else if !MyTBA.shared.isAuthenticated, navigationItem.rightBarButtonItem != nil {
            navigationItem.rightBarButtonItem = nil
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
