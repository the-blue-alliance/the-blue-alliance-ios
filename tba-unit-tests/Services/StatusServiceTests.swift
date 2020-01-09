import XCTest
@testable import TBAData
@testable import The_Blue_Alliance

class StatusServiceTests: TBATestCase {

    func test_status_fromMOC() {
        let status = insertStatus()
        XCTAssertEqual(statusService.currentSeason, status.currentSeason)
    }

    func test_status_fromPlist() {
        XCTAssertEqual(statusService.currentSeason, 2015)
    }

    func test_currentSeason() {
        XCTAssertEqual(statusService.currentSeason, 2015)
    }

    func test_maxSeason() {
        XCTAssertEqual(statusService.maxSeason, 2016)
    }

    func test_setupStatusObservers_ignoreInserts() {
        _ = insertStatus()

        statusService.setupStatusObservers()

        let insertExpectation = expectation(description: "status inserted")
        insertExpectation.isInverted = true

        let statusSubscribable = MockStatusSubscribable(statusService: statusService)
        statusSubscribable.statusChangedExpectation = insertExpectation
        statusSubscribable.registerForStatusChanges()

        try! persistentContainer.viewContext.save()
        wait(for: [insertExpectation], timeout: 1.0)
    }

    func test_setupStatusObservers_ignoreDeletions() {
        let status = insertStatus()
        try! persistentContainer.viewContext.save()

        statusService.setupStatusObservers()

        let deletionExpectation = expectation(description: "status deleted")
        deletionExpectation.isInverted = true

        let statusSubscribable = MockStatusSubscribable(statusService: statusService)
        statusSubscribable.statusChangedExpectation = deletionExpectation
        statusSubscribable.registerForStatusChanges()

        persistentContainer.viewContext.delete(status)
        try! persistentContainer.viewContext.save()
        wait(for: [deletionExpectation], timeout: 1.0)
    }

    func test_setupStatusObservers_handleUpdates() {
        let status = insertStatus()
        try! persistentContainer.viewContext.save()

        statusService.setupStatusObservers()

        let updateExpectation = expectation(description: "status updated")

        let statusSubscribable = MockStatusSubscribable(statusService: statusService)
        statusSubscribable.statusChangedExpectation = updateExpectation
        statusSubscribable.registerForStatusChanges()

        status.isDatafeedDownRaw = NSNumber(value: true)
        try! persistentContainer.viewContext.save()
        wait(for: [updateExpectation], timeout: 1.0)
    }

    func test_setupStatusObservers_handleRefreshes() {
        let status = insertStatus()
        try! persistentContainer.viewContext.save()

        statusService.setupStatusObservers()

        let refreshExpectation = expectation(description: "status refreshed")

        let statusSubscribable = MockStatusSubscribable(statusService: statusService)
        statusSubscribable.statusChangedExpectation = refreshExpectation
        statusSubscribable.registerForStatusChanges()

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        persistentContainer.performBackgroundTask { (backgroundContext) in
            let backgroundStatus = backgroundContext.object(with: status.objectID) as! Status
            backgroundStatus.isDatafeedDownRaw = NSNumber(value: true)
            try! backgroundContext.save()
        }
        wait(for: [backgroundSaveExpectation], timeout: 1.0)

        persistentContainer.viewContext.refresh(status, mergeChanges: true)
        wait(for: [refreshExpectation], timeout: 1.0)
    }

    func test_fetchStatus() {
        // Sanity check - no Status yet
        XCTAssertNil(Status.status(in: persistentContainer.viewContext))

        let backgroundSaveExpectation = backgroundContextSaveExpectation()
        let ex = expectation(description: "fetchStatus completion block called")
        let task = statusService.fetchStatus { (error) in
            XCTAssertNil(error)
            ex.fulfill()
        }
        tbaKit.sendSuccessStub(for: task)
        wait(for: [ex, backgroundSaveExpectation], timeout: 1.0)

        XCTAssertNotNil(Status.status(in: persistentContainer.viewContext))
    }

}

class StatusSubscribableTests: TBATestCase {

    fileprivate var subscribable: MockStatusSubscribable!

    override func setUp() {
        super.setUp()

        subscribable = MockStatusSubscribable(statusService: statusService)
    }

    override func tearDown() {
        subscribable = nil

        super.tearDown()
    }

    func test_registerForStatusChanges() {
        let ex = expectation(description: "Status changes dispatch")
        subscribable.statusChangedExpectation = ex

        subscribable.registerForStatusChanges()
        statusService.dispatchStatusChanged(Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext))

        wait(for: [ex], timeout: 1.0)
    }

    func test_registerForFMSStatusChanges_notRegistered() {
        let ex = expectation(description: "Status changes do not dispatch")
        ex.isInverted = true
        subscribable.statusChangedExpectation = ex

        statusService.dispatchStatusChanged(Status.init(entity: Status.entity(), insertInto: persistentContainer.viewContext))

        wait(for: [ex], timeout: 1.0)
    }

}


class FMSStatusSubscribableTests: TBATestCase {

    fileprivate var fmsSubscribable: MockFMSStatusSubscribable!

    override func setUp() {
        super.setUp()

        fmsSubscribable = MockFMSStatusSubscribable(statusService: statusService)
    }

    override func tearDown() {
        fmsSubscribable = nil

        super.tearDown()
    }

    func test_registerForFMSStatusChanges() {
        let ex = expectation(description: "FMS changes dispatch")
        fmsSubscribable.fmsStatusChangedExpectation = ex
        fmsSubscribable.fmsStatusChangedValue = true

        fmsSubscribable.registerForFMSStatusChanges()
        statusService.dispatchFMSDown(true)

        wait(for: [ex], timeout: 1.0)
    }

    func test_registerForFMSStatusChanges_notRegistered() {
        let ex = expectation(description: "FMS changes do not dispatch")
        ex.isInverted = true
        fmsSubscribable.fmsStatusChangedExpectation = ex

        statusService.dispatchFMSDown(true)

        wait(for: [ex], timeout: 1.0)
    }

}

class EventStatusSubscribableTests: TBATestCase {

    fileprivate var eventSubscribable: MockEventStatusSubscribable!

    override func setUp() {
        super.setUp()

        eventSubscribable = MockEventStatusSubscribable(statusService: statusService)
    }

    override func tearDown() {
        eventSubscribable = nil

        super.tearDown()
    }

    func test_registerForFMSStatusChanges() {
        let testEventKey = "2018miket"

        let ex = expectation(description: "Event offline changes dispatch")
        eventSubscribable.eventStatusChangedExpectation = ex
        eventSubscribable.eventOfflineValue = true

        eventSubscribable.registerForEventStatusChanges(eventKey: testEventKey)
        statusService.dispatchEvents(downEventKeys: [testEventKey])

        wait(for: [ex], timeout: 1.0)
    }

    func test_registerForFMSStatusChanges_notRegistered() {
        let testEventKey = "2018miket"

        let ex = expectation(description: "Event offline changes do not dispatch")
        ex.isInverted = true
        eventSubscribable.eventStatusChangedExpectation = ex
        eventSubscribable.eventOfflineValue = true

        statusService.dispatchEvents(downEventKeys: [testEventKey])

        wait(for: [ex], timeout: 1.0)
    }

    func test_isEventDown() {
        let testEventKey = "2018miket"

        let status = insertStatus()
        XCTAssertFalse(eventSubscribable.isEventDown(eventKey: testEventKey))
        status.downEventsRaw = NSSet(array: [Event.insert(testEventKey, in: persistentContainer.viewContext)])
        XCTAssert(eventSubscribable.isEventDown(eventKey: testEventKey))
    }

}

private class MockStatusSubscribable: StatusSubscribable {

    var statusService: StatusService

    var statusChangedExpectation: XCTestExpectation?

    init(statusService: StatusService) {
        self.statusService = statusService
    }

    func statusChanged(status: Status) {
        XCTAssertNotNil(status)
        statusChangedExpectation?.fulfill()
    }

}

private class MockFMSStatusSubscribable: FMSStatusSubscribable {

    var statusService: StatusService

    var fmsStatusChangedValue: Bool?
    var fmsStatusChangedExpectation: XCTestExpectation?

    init(statusService: StatusService) {
        self.statusService = statusService
    }

    func fmsStatusChanged(isDatafeedDown: Bool) {
        XCTAssertEqual(fmsStatusChangedValue, isDatafeedDown)
        fmsStatusChangedExpectation?.fulfill()
    }

}

private class MockEventStatusSubscribable: EventStatusSubscribable {

    var statusService: StatusService

    var eventOfflineValue: Bool?
    var eventStatusChangedExpectation: XCTestExpectation?

    init(statusService: StatusService) {
        self.statusService = statusService
    }

    func eventStatusChanged(isEventOffline: Bool) {
        XCTAssertEqual(eventOfflineValue, isEventOffline)
        eventStatusChangedExpectation?.fulfill()
    }

}
