import Foundation
import CoreData
import UIKit

class MyTBAContainerViewController: ContainerViewController, Subscribable {

    let myTBA: MyTBA

    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_star"), style: .plain, target: self, action: #selector(myTBAPreferencesTapped))
    }()

    var subscribableModel: MyTBASubscribable {
        fatalError("Implement subscribableModel in subclass")
    }

    // MARK: - Init

    init(viewControllers: [ContainableViewController], segmentedControlTitles: [String]?, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.myTBA = myTBA

        super.init(viewControllers: viewControllers, segmentedControlTitles: segmentedControlTitles, persistentContainer: persistentContainer, tbaKit: tbaKit)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateFavoriteButton()
        myTBA.authenticationProvider.add(observer: self)
    }

    // MARK: - Interface Methods

    func updateFavoriteButton() {
        if myTBA.isAuthenticated, navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = favoriteBarButtonItem
        } else if !myTBA.isAuthenticated, navigationItem.rightBarButtonItem != nil {
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
