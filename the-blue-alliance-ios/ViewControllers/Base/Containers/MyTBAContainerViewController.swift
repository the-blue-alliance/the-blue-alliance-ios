import Foundation
import MyTBAKit
import UIKit
import TBAAuth

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage.starIcon,
            style: .plain,
            target: self,
            action: #selector(myTBAPreferencesTapped)
        )
    }()

    var subscribableModel: MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    // MARK: - Init

    override init(
        viewControllers: [ContainableViewController],
        navigationTitle: String? = nil,
        navigationSubtitle: String? = nil,
        segmentedControlTitles: [String]? = nil,
        dependencies: Dependencies
    ) {

        super.init(
            viewControllers: viewControllers,
            navigationTitle: navigationTitle,
            navigationSubtitle: navigationSubtitle,
            segmentedControlTitles: segmentedControlTitles,
            dependencies: dependencies
        )

        updateFavoriteButton()

        dependencies.authService.addStateObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface Methods

    func updateFavoriteButton() {
        if dependencies.authService.isSignedIn {
            rightBarButtonItems = [favoriteBarButtonItem]
        } else {
            rightBarButtonItems = []
        }
    }

    @objc func myTBAPreferencesTapped() {
        presentMyTBAPreferences()
    }

}

extension MyTBAContainerViewController: AuthStateObserving {

    func authStateChanged(isSignedIn: Bool) {
        updateFavoriteButton()
    }

}
