import Foundation
import MyTBAKit
import UIKit

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

    private var authStateTask: Task<Void, Never>?

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

        authStateTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await self.myTBA.authStateChanges()
            for await _ in stream {
                self.updateFavoriteButton()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        authStateTask?.cancel()
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
