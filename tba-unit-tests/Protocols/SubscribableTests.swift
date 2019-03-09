import CoreData
import XCTest
@testable import TBA

class MockSubscribableViewController: UIViewController, Persistable, Subscribable {

    var myTBA: MyTBA {
        return MockMyTBA()
    }
    var favoriteBarButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: "Button", style: .plain, target: nil, action: nil)
    }
    var subscribableModel: MyTBASubscribable
    var persistentContainer: NSPersistentContainer

    var presentCalled: ((UIViewController) -> ())?

    init(subscribableModel: MyTBASubscribable, persistentContainer: NSPersistentContainer) {
        self.subscribableModel = subscribableModel
        self.persistentContainer = persistentContainer

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCalled?(viewControllerToPresent)
    }

}

class SubscribableTests: TBATestCase {

    var subscribableModel: MyTBASubscribable!
    var subscribableViewController: MockSubscribableViewController!

    override func setUp() {
        super.setUp()

        subscribableModel = insertDistrictEvent()
        subscribableViewController = MockSubscribableViewController(subscribableModel: subscribableModel, persistentContainer: persistentContainer)
    }

    override func tearDown() {
        subscribableViewController = nil
        subscribableModel = nil

        super.tearDown()
    }

    func test_presentMyTBAPreferences() {
        let preferencesPresentedExpectation = expectation(description: "MyTBA Preferences Presented")
        subscribableViewController.presentCalled = { (viewController) in
            let navigationController = viewController as! UINavigationController
            let preferenceViewController = navigationController.viewControllers.first as! MyTBAPreferenceViewController
            XCTAssertEqual(preferenceViewController.subscribableModel.modelKey, self.subscribableModel.modelKey)

            preferencesPresentedExpectation.fulfill()
        }
        subscribableViewController.presentMyTBAPreferences()
        wait(for: [preferencesPresentedExpectation], timeout: 1.0)
    }

}
