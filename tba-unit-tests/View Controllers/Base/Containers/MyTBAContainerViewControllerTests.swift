import CoreData
import FirebaseMessaging
import TBAKit
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MockMyTBAContainerViewController: MyTBAContainerViewController {

    override var subscribableModel: MyTBASubscribable {
        return _subscribableModel
    }
    let _subscribableModel: MyTBASubscribable

    var updateFavoriteButtonExpectation: XCTestExpectation?

    init(subscribableModel: MyTBASubscribable, messaging: Messaging, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        _subscribableModel = subscribableModel

        super.init(viewControllers: [], messaging: messaging, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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

    override func setUp() {
        super.setUp()

        subscribableModel = insertDistrictEvent()

        tbaContainerViewController = MockMyTBAContainerViewController(subscribableModel: subscribableModel, messaging: messaging, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    override func tearDown() {
        tbaContainerViewController = nil
        subscribableModel = nil

        super.tearDown()
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
