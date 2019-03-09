import XCTest
@testable import TBA

class MyTBAPreferenceViewControllerTests: TBATestCase {

    var subscribableModel: MyTBASubscribable!

    var myTBAPreferencesViewController: MyTBAPreferenceViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        subscribableModel = insertDistrictEvent()

        myTBAPreferencesViewController = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        navigationController = MockNavigationController(rootViewController: myTBAPreferencesViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        myTBAPreferencesViewController = nil
        subscribableModel = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)

        // Turn our Favorite switch on
        myTBAPreferencesViewController.isFavorite = true
        myTBAPreferencesViewController.tableView.reloadData()
        verifyLayer(viewControllerTester.window.layer, identifier: "is_favorite")
        myTBAPreferencesViewController.isFavorite = false

        // Turn some of our Notifications switches on
        myTBAPreferencesViewController.notifications = [.upcomingMatch, .awards]
        myTBAPreferencesViewController.tableView.reloadData()
        verifyLayer(viewControllerTester.window.layer, identifier: "notifications")

        // Kickoff a Save
        myTBAPreferencesViewController.save()
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "saving")
    }

    func test_init_fetchFavorite() {
        XCTAssertNil(myTBAPreferencesViewController.favorite)
        XCTAssertFalse(myTBAPreferencesViewController.isFavorite)
        XCTAssertFalse(myTBAPreferencesViewController.isFavoriteInitially)

        // Insert a Favorite
        Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
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
        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        XCTAssertNotNil(newPreferences.subscription)
        XCTAssertFalse(newPreferences.notifications.isEmpty)
        XCTAssertFalse(newPreferences.notificationsInitial.isEmpty)
    }

    func test_disappear_cancelsRequest() {
        let cancelExpectation = expectation(description: "Cancel called")
        let mockRequest = MockURLSessionDataTask()
        mockRequest.cancelExpectation = cancelExpectation

        myTBAPreferencesViewController.preferencesRequest = mockRequest
        myTBAPreferencesViewController.viewWillDisappear(false)
        wait(for: [cancelExpectation], timeout: 1.0)
    }

    func test_favoriteSwitchToggled() {
        let testSwitch = UISwitch(frame: .zero)
        testSwitch.isOn = true

        XCTAssertFalse(myTBAPreferencesViewController.isFavorite)
        myTBAPreferencesViewController.favoriteSwitchToggled(testSwitch)
        XCTAssert(myTBAPreferencesViewController.isFavorite)
    }

    func test_notificationSwitchToggled() {
        let testSwitch = UISwitch(frame: .zero)
        testSwitch.tag = 0

        XCTAssert(myTBAPreferencesViewController.notifications.isEmpty)
        myTBAPreferencesViewController.notificationSwitchToggled(testSwitch)
        XCTAssertEqual(myTBAPreferencesViewController.notifications.count, 1)
        myTBAPreferencesViewController.notificationSwitchToggled(testSwitch)
        XCTAssert(myTBAPreferencesViewController.notifications.isEmpty)
    }

    func test_preferencesHaveChanged() {
        XCTAssertFalse(myTBAPreferencesViewController.preferencesHaveChanged)
        myTBAPreferencesViewController.isFavorite = true
        XCTAssert(myTBAPreferencesViewController.preferencesHaveChanged)
        myTBAPreferencesViewController.isFavorite = false
        XCTAssertFalse(myTBAPreferencesViewController.preferencesHaveChanged)
        myTBAPreferencesViewController.notifications = [.awards]
        XCTAssert(myTBAPreferencesViewController.preferencesHaveChanged)
        myTBAPreferencesViewController.isFavorite = true
        XCTAssert(myTBAPreferencesViewController.preferencesHaveChanged)
    }

    func test_save_noChanges() {
        let dismissExpectation = expectation(description: "Dismiss called")
        navigationController.dismissExpectation = dismissExpectation
        myTBAPreferencesViewController.save()
        wait(for: [dismissExpectation], timeout: 1.0)
    }

    func test_save_hasChanges() {
        myTBAPreferencesViewController.isFavorite = true
        myTBAPreferencesViewController.save()

        // Dismiss should be called at the end
        let dismissExpectation = expectation(description: "Dismiss called")
        navigationController.dismissExpectation = dismissExpectation

        // Save should be called at the end
        let saveExpectation = backgroundContextSaveExpectation()

        myTBA.sendStub(for: myTBAPreferencesViewController.preferencesRequest!)
        wait(for: [saveExpectation, dismissExpectation], timeout: 1.0, enforceOrder: true)
    }

    func test_save_hasChanges_favorite_delete() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = false

        let deletionExpectation = expectation(description: "Favorite deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: favorite, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesRequest!)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)
    }

    func test_save_hasChanges_favorite_insert() {
        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.isFavorite = true

        // Sanity check
        let favoritePredicate = Favorite.favoritePredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        XCTAssertNil(Favorite.findOrFetch(in: persistentContainer.viewContext, matching: favoritePredicate))

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesRequest!)
        wait(for: [saveExpectation], timeout: 1.0)

        XCTAssertNotNil(Favorite.findOrFetch(in: persistentContainer.viewContext, matching: favoritePredicate))
    }

    func test_save_hasChanges_subscription_delete() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = []

        let deletionExpectation = expectation(description: "Subscription deleted")
        let observer = CoreDataContextObserver(context: persistentContainer.viewContext)
        observer.observeObject(object: subscription, state: .deleted) { (_, _) in
            deletionExpectation.fulfill()
        }

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesRequest!)
        wait(for: [saveExpectation, deletionExpectation], timeout: 1.0)
    }

    func test_save_hasChanges_subscription_update() {
        let subscription = Subscription.insert(MyTBASubscription(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType, notifications: [.awards, .upcomingMatch]), in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        // Sanity check
        XCTAssertEqual(subscription.notifications, [.awards, .upcomingMatch])

        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.upcomingMatch]

        newPreferences.save()

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesRequest!)
        wait(for: [backgroundSaveExpectation], timeout: 1.0)

        persistentContainer.viewContext.refresh(subscription, mergeChanges: true)
        XCTAssertEqual(subscription.notifications, [.upcomingMatch])
    }

    func test_save_hasChanges_subscription_insert() {
        let newPreferences = MyTBAPreferenceViewController(subscribableModel: subscribableModel, myTBA: myTBA, persistentContainer: persistentContainer)
        newPreferences.notifications = [.awards, .upcomingMatch]

        // Sanity check
        let subscriptionPredicate = Subscription.subscriptionPredicate(modelKey: subscribableModel.modelKey, modelType: subscribableModel.modelType)
        XCTAssertNil(Subscription.findOrFetch(in: persistentContainer.viewContext, matching: subscriptionPredicate))

        newPreferences.save()

        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: newPreferences.preferencesRequest!)
        wait(for: [saveExpectation], timeout: 1.0)

        XCTAssertNotNil(Subscription.findOrFetch(in: persistentContainer.viewContext, matching: subscriptionPredicate))
    }

    func test_close() {
        let dismissExpectation = expectation(description: "Dismiss called")
        navigationController.dismissExpectation = dismissExpectation
        myTBAPreferencesViewController.close()
        wait(for: [dismissExpectation], timeout: 1.0)
    }

}
