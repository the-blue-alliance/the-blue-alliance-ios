/*
import XCTest
@testable import The_Blue_Alliance

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
