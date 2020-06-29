import TBAData
import TBAKitTesting
import TBATestingMocks
import TBAOperationTesting
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MyTBAPreferenceViewControllerTests: TBATestCase {

    var subscribableModel: MyTBASubscribable!

    var navigationController: MockNavigationController!
    var myTBAPreferencesViewController: MyTBAPreferenceViewController!

    override func setUp() {
        super.setUp()

        subscribableModel = insertDistrictEvent()

        myTBAPreferencesViewController = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        navigationController = MockNavigationController(rootViewController: myTBAPreferencesViewController)
    }

    override func tearDown() {
        navigationController = nil
        myTBAPreferencesViewController = nil
        subscribableModel = nil

        super.tearDown()
    }

    func test_init_fetchFavorite() {
        XCTAssertNil(myTBAPreferencesViewController.favorite)
        XCTAssertFalse(myTBAPreferencesViewController.isFavorite)
        XCTAssertFalse(myTBAPreferencesViewController.isFavoriteInitially)

        // Insert a Favorite
        Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        XCTAssertNotNil(newPreferences.favorite)
        XCTAssert(newPreferences.isFavorite)
        XCTAssert(newPreferences.isFavoriteInitially)
    }

    func test_init_fetchSubscriptions() {
        XCTAssertNil(myTBAPreferencesViewController.subscription)
        XCTAssert(myTBAPreferencesViewController.notifications.isEmpty)
        XCTAssert(myTBAPreferencesViewController.notificationsInitial.isEmpty)

        // Insert a Subscription
        Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        XCTAssertNotNil(newPreferences.subscription)
        XCTAssertFalse(newPreferences.notifications.isEmpty)
        XCTAssertFalse(newPreferences.notificationsInitial.isEmpty)
    }

    func test_disappear_cancelsRequest() {
        let cancelExpectation = expectation(description: "Cancel called")
        let mockOperation = MockOperation()
        mockOperation.cancelExpectation = cancelExpectation
        myTBAPreferencesViewController.operationQueue.addOperations([mockOperation], waitUntilFinished: false)

        myTBAPreferencesViewController.viewWillDisappear(false)
        wait(for: [cancelExpectation], timeout: 1.0)
    }

    func test_favoriteSwitchToggled() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = myTBAPreferencesViewController.tableView(myTBAPreferencesViewController.tableView, cellForRowAt: indexPath) as? SwitchTableViewCell else {
            XCTFail("Unable to get SwitchTableViewCell from MyTBAPreferencesViewController")
            return
        }

        XCTAssertFalse(myTBAPreferencesViewController.isFavorite)
        cell.switchView.isOn = true
        cell.switchValueChanged(cell.switchView)
        XCTAssert(myTBAPreferencesViewController.isFavorite)
    }

    func test_notificationSwitchToggled() {
        let indexPath = IndexPath(row: 0, section: 1)
        guard let cell = myTBAPreferencesViewController.tableView(myTBAPreferencesViewController.tableView, cellForRowAt: indexPath) as? SwitchTableViewCell else {
            XCTFail("Unable to get SwitchTableViewCell from MyTBAPreferencesViewController")
            return
        }

        XCTAssert(myTBAPreferencesViewController.notifications.isEmpty)
        cell.switchView.isOn = true
        cell.switchValueChanged(cell.switchView)
        XCTAssertEqual(myTBAPreferencesViewController.notifications.count, 1)
        cell.switchView.isOn = false
        cell.switchValueChanged(cell.switchView)
        XCTAssert(myTBAPreferencesViewController.notifications.isEmpty)
    }

    func test_hasChanges() {
        XCTAssertFalse(myTBAPreferencesViewController.hasChanges)
        myTBAPreferencesViewController.isFavorite = true
        XCTAssert(myTBAPreferencesViewController.hasChanges)
        myTBAPreferencesViewController.isFavorite = false
        XCTAssertFalse(myTBAPreferencesViewController.hasChanges)
        myTBAPreferencesViewController.notifications = [.awards]
        XCTAssert(myTBAPreferencesViewController.hasChanges)
        myTBAPreferencesViewController.isFavorite = true
        XCTAssert(myTBAPreferencesViewController.hasChanges)
    }

    func test_save_hasChanges() {
        myTBAPreferencesViewController.isFavorite = true
        myTBAPreferencesViewController.save()

        // Dismiss should be called at the end
        let dismissExpectation = expectation(description: "Dismiss called")
        navigationController.dismissExpectation = dismissExpectation

        // Save should be called at the end
        let saveExpectation = backgroundContextSaveExpectation()

        myTBA.sendStub(for: myTBAPreferencesViewController.preferencesOperation!)
        wait(for: [saveExpectation, dismissExpectation], timeout: 1.0, enforceOrder: true)
    }

    func test_save_hasChanges_favorite_delete() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = false

        let deletionExpectation = expectation(description: "Favorite deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: favorite, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(favorite.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        XCTAssertTrue(favorite.isDeleted)
    }

    func test_save_hasChanges_favorite_delete_404() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = false

        let deletionExpectation = expectation(description: "Favorite deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: favorite, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(favorite.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 808)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        XCTAssertTrue(favorite.isDeleted)
    }

    func test_save_hasChanges_favorite_delete_500() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = false

        let deletionExpectation = expectation(description: "Favorite deleted")
        deletionExpectation.isInverted = true
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: favorite, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(favorite.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 1000)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        XCTAssertFalse(favorite.isDeleted)
    }

    func test_save_hasChanges_favorite_insert() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = true

        // Sanity check
        var favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!)
        wait(for: [saveExpectation], timeout: 1.0)

        favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNotNil(favorite)
    }

    func test_save_hasChanges_favorite_insert_304() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = true

        // Sanity check
        var favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 608)
        wait(for: [saveExpectation], timeout: 1.0)

        favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNotNil(favorite)
    }

    func test_save_hasChanges_favorite_insert_500() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = true

        // Sanity check
        var favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 1000)
        wait(for: [saveExpectation], timeout: 1.0)

        favorite = Favorite.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)
    }

    func test_save_hasChanges_subscription_delete() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = []

        let deletionExpectation = expectation(description: "Subscription deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(subscription.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertTrue(subscription.isDeleted)
    }

    func test_save_hasChanges_subscription_delete_404() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = []

        let deletionExpectation = expectation(description: "Subscription deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(subscription.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 608)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertTrue(subscription.isDeleted)
    }

    func test_save_hasChanges_subscription_delete_500() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = []

        let deletionExpectation = expectation(description: "Subscription deleted")
        deletionExpectation.isInverted = true
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        // Sanity check
        XCTAssertFalse(subscription.isDeleted)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 1000)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertFalse(subscription.isDeleted)
    }

    func test_save_hasChanges_subscription_update() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        // Sanity check
        XCTAssertEqual(subscription.notifications, [.awards, .upcomingMatch])

        let updateExpectation = expectation(description: "Subscription updated")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .updated) { (_, _) in
            updateExpectation.fulfill()
        }

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.upcomingMatch]

        newPreferences.save()

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!)
        wait(for: [backgroundSaveExpectation, updateExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertEqual(subscription.notifications, [.upcomingMatch])
    }

    func test_save_hasChanges_subscription_update_304() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        // Sanity check
        XCTAssertEqual(subscription.notifications, [.awards, .upcomingMatch])

        let updateExpectation = expectation(description: "Subscription updated")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .updated) { (_, _) in
            updateExpectation.fulfill()
        }

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.upcomingMatch]

        newPreferences.save()

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 608)
        wait(for: [backgroundSaveExpectation, updateExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertEqual(subscription.notifications, [.upcomingMatch])
    }

    func test_save_hasChanges_subscription_update_500() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        // Sanity check
        XCTAssertEqual(subscription.notifications, [.awards, .upcomingMatch])

        let updateExpectation = expectation(description: "Subscription updated")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .updated) { (_, _) in
            updateExpectation.fulfill()
        }

        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.upcomingMatch]

        newPreferences.save()

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 1000)
        wait(for: [backgroundSaveExpectation, updateExpectation], timeout: 1.0)

        // Wait for our dismissOperation to complete
        waitOneSecond()
        XCTAssertEqual(subscription.notifications, [.awards, .upcomingMatch])
    }

    func test_save_hasChanges_subscription_insert() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.awards, .upcomingMatch]

        // Sanity check
        var subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(subscription)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!)
        wait(for: [saveExpectation], timeout: 1.0)

        subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNotNil(subscription)
    }

    func test_save_hasChanges_subscription_insert_304() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.awards, .upcomingMatch]

        // Sanity check
        var subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(subscription)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 608)
        wait(for: [saveExpectation], timeout: 1.0)

        subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNotNil(subscription)
    }

    func test_save_hasChanges_subscription_insert_500() {
        let newPreferences = MyTBAPreferenceViewController(errorRecorder: errorRecorder, subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.awards, .upcomingMatch]

        // Sanity check
        var subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(subscription)

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesOperation!, code: 1000)
        wait(for: [saveExpectation], timeout: 1.0)

        subscription = Subscription.fetch(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, in: persistentContainer.viewContext)
        XCTAssertNil(subscription)
    }

    func test_close() {
        let dismissExpectation = expectation(description: "Dismiss called")
        navigationController.dismissExpectation = dismissExpectation
        myTBAPreferencesViewController.close()
        wait(for: [dismissExpectation], timeout: 1.0)
    }

}
