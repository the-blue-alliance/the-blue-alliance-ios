import Foundation
import TBAAPI
import UIKit

class PhoneRootViewController: UITabBarController, RootController {

    weak var dependencyProvider: (any DependencyProvider)!

    init(dependencyProvider: DependencyProvider) {
        self.dependencyProvider = dependencyProvider

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let itemsGroup = UITabGroup(
            title: "Items",
            image: UIImage(systemName: "folder"),
            identifier: "itemsGroup",
            children: [
                UITab(
                    title: "All Items",
                    image: UIImage(systemName: "list.bullet"),
                    identifier: "allItemsTab"
                ) { _ in
                    return UIViewController()
                },
                UITab(
                    title: "Favorite Items",
                    image: UIImage(systemName: "heart"),
                    identifier: "favoriteItemsTab"
                ) { _ in
                    return UIViewController()
                }
            ]
        ) { _ in
            // Provide a view controller for the group if it's selectable in the tab bar
            return UIViewController()
        }

        // TODO: Search tab as well?
        var tabs = RootType.allCases.map { rootType in
            let viewController = rootType.viewController(
                dependencyProvider: dependencyProvider
            )
            return UITab(
                title: rootType.title,
                image: rootType.icon,
                identifier: rootType.rawValue,
                viewControllerProvider: { _ in
                    viewController
                })
        }
        tabs.append(itemsGroup)

        self.tabs = tabs

        #if os(iPadOS)
        if #available(iOS 18.0, *) {
            self.mode = .tabSidebar
        }
        #endif
    }
}
