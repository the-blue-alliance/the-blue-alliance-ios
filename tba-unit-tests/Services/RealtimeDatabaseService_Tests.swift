/*
import XCTest
@testable import The_Blue_Alliance

class FMSStatusSubscribable_Tests: XCTestCase {

    var mockRealtimeDatabaseService: MockRealtimeDatabaseService!
    var fmsSubscribable: MockFMSStatusSubscribable!

    override func setUp() {
        super.setUp()

        mockRealtimeDatabaseService = MockRealtimeDatabaseService(databaseReference: DatabaseReference())
        fmsSubscribable = MockFMSStatusSubscribable(realtimeDatabaseService: mockRealtimeDatabaseService)
    }

    override func tearDown() {
        fmsSubscribable = nil
        mockRealtimeDatabaseService = nil

        super.tearDown()
    }

    func test_registerForFMSStatusChanges() {
        let registerForFMSStatusChangesExpectation = XCTestExpectation(description: "registerForFMSStatusChanges called")
        mockRealtimeDatabaseService.registerForFMSStatusChangesExpectation = registerForFMSStatusChangesExpectation

        fmsSubscribable.registerForFMSStatusChanges()
        wait(for: [registerForFMSStatusChangesExpectation], timeout: 1.0)
    }

}

class EventStatusSubscribable_Tests: XCTestCase {

    var mockRealtimeDatabaseService: MockRealtimeDatabaseService!
    var eventSubscribable: MockEventStatusSubscribable!

    override func setUp() {
        super.setUp()

        mockRealtimeDatabaseService = MockRealtimeDatabaseService(databaseReference: DatabaseReference())
        eventSubscribable = MockEventStatusSubscribable(realtimeDatabaseService: mockRealtimeDatabaseService)
    }

    override func tearDown() {
        eventSubscribable = nil
        mockRealtimeDatabaseService = nil

        super.tearDown()
    }

    func test_registerForFMSStatusChanges() {
        let testEventKey = "2018miket"

        let registerForEventStatusChangesExpectation = XCTestExpectation(description: "registerForEventStatusChanges called")
        mockRealtimeDatabaseService.registerForEventStatusChangesEventKey = testEventKey
        mockRealtimeDatabaseService.registerForEventStatusChangesExpectation = registerForEventStatusChangesExpectation

        eventSubscribable.registerForEventStatusChanges(eventKey: testEventKey)
        wait(for: [registerForEventStatusChangesExpectation], timeout: 1.0)
    }

}

class RealtimeDatabaseService_Tests: XCTestCase {

    var realtimeDatabaseService: RealtimeDatabaseService!

    override func setUp() {
        super.setUp()

        realtimeDatabaseService = RealtimeDatabaseService(databaseReference: DatabaseReference())
    }

    override func tearDown() {
        realtimeDatabaseService = nil

        super.tearDown()
    }

    func test_notifiesFMSSubscribers() {
        let fmsStatusChangedExpectation = XCTestExpectation(description: "fms status subscriber notified")

        let mockFMSSubscriber = MockFMSStatusSubscribable(realtimeDatabaseService: realtimeDatabaseService)
        mockFMSSubscriber.fmsStatusChangedValue = true
        mockFMSSubscriber.fmsStatusChangedExpectation = fmsStatusChangedExpectation
        mockFMSSubscriber.registerForFMSStatusChanges()

        // Fake our data changing
        realtimeDatabaseService.updateFMSSubscribers(isDatafeedDown: true)

        wait(for: [fmsStatusChangedExpectation], timeout: 1.0)
    }

    func test_notifiesEventSubscribers() {
        let testEventKey = "2018miket"
        let eventStatusChangedExpectation = XCTestExpectation(description: "event status subscriber notified")

        let mockEventSubscriber = MockEventStatusSubscribable(realtimeDatabaseService: realtimeDatabaseService)
        mockEventSubscriber.eventOfflineValue = true
        mockEventSubscriber.eventStatusChangedExpectation = eventStatusChangedExpectation
        mockEventSubscriber.registerForEventStatusChanges(eventKey: testEventKey)

        // Fake our data changing
        realtimeDatabaseService.updateEventSubscribers(eventKey: testEventKey, isEventOffline: true)

        wait(for: [eventStatusChangedExpectation], timeout: 1.0)
    }

}
*/
