import CoreData
import XCTest
@testable import TBA

class MockMyTBAContainerViewController: MyTBAContainerViewController {

    override var subscribableModel: MyTBASubscribable {
        return _subscribableModel
    }
    let _subscribableModel: MyTBASubscribable

    var updateFavoriteButtonExpectation: XCTestExpectation?

    init(subscribableModel: MyTBASubscribable, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        _subscribableModel = subscribableModel

        super.init(viewControllers: [], myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateFavoriteButton() {
        updateFavoriteButtonExpectation?.fulfill()
        super.updateFavoriteButton()
    }

}

class MyTBAContainerViewControllerTests: TBATestCase {

    var subscribableModel: MyTBASubscribable!

    var tbaContainerViewController: MockMyTBAContainerViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        subscribableModel = insertDistrictEvent()

        tbaContainerViewController = MockMyTBAContainerViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: tbaContainerViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        tbaContainerViewController = nil
        subscribableModel = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(navigationController.navigationBar.layer, identifier: "unauthenticated")

        myTBA.authToken = "abcd123"
        waitOneSecond()

        verifyLayer(navigationController.navigationBar.layer, identifier: "authenticated")
    }

    func test_myTBAAuthenticationObservable_authenticated() {
        let ex = expectation(description: "myTBA authenticated updated buttons")
        tbaContainerViewController.updateFavoriteButtonExpectation = ex
        myTBA.authToken = "abcd123"
        wait(for: [ex], timeout: 1.0)
    }

    func test_myTBAAuthenticationObservable_unauthenticated() {
        myTBA.authToken = "abcd123"
        let ex = expectation(description: "myTBA unauthenticated updated buttons")
        tbaContainerViewController.updateFavoriteButtonExpectation = ex
        myTBA.authToken = nil
        wait(for: [ex], timeout: 1.0)
    }

}
