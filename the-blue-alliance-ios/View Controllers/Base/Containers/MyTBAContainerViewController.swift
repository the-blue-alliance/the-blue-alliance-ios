import CoreData
import Foundation
import MyTBAKit
import TBAKit
import UIKit

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    let myTBA: MyTBA

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage.starIcon, style: .plain, target: self, action: #selector(myTBAPreferencesTapped))
    }()

    var subscribableModel: MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    // MARK: - Init

    init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, myTBA: MyTBA, dependencies: Dependencies) {
        self.myTBA = myTBA

        super.init(viewControllers: viewControllers, navigationTitle: navigationTitle, navigationSubtitle: navigationSubtitle, segmentedControlTitles: segmentedControlTitles, dependencies: dependencies)

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
