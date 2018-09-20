import XCTest
@testable import The_Blue_Alliance

class MockRealtimeDatabaseService: RealtimeDatabaseService {

    var registerForFMSStatusChangesExpectation: XCTestExpectation?

    var registerForEventStatusChangesEventKey: String?
    var registerForEventStatusChangesExpectation: XCTestExpectation?

    internal override func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {
        registerForFMSStatusChangesExpectation?.fulfill()
    }

    internal override func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: String) {
        XCTAssertEqual(registerForEventStatusChangesEventKey, eventKey)
        registerForEventStatusChangesExpectation?.fulfill()
    }

}

class MockFMSStatusSubscribable: FMSStatusSubscribable {

    var realtimeDatabaseService: RealtimeDatabaseService

    var fmsStatusChangedValue: Bool?
    var fmsStatusChangedExpectation: XCTestExpectation?

    init(realtimeDatabaseService: RealtimeDatabaseService) {
        self.realtimeDatabaseService = realtimeDatabaseService
    }

    func fmsStatusChanged(isDatafeedDown: Bool) {
        XCTAssertEqual(fmsStatusChangedValue, isDatafeedDown)
        fmsStatusChangedExpectation?.fulfill()
    }

}

class MockEventStatusSubscribable: EventStatusSubscribable {

    var realtimeDatabaseService: RealtimeDatabaseService

    var eventOfflineValue: Bool?
    var eventStatusChangedExpectation: XCTestExpectation?

    init(realtimeDatabaseService: RealtimeDatabaseService) {
        self.realtimeDatabaseService = realtimeDatabaseService
    }

    func eventStatusChanged(isEventOffline: Bool) {
        XCTAssertEqual(eventOfflineValue, isEventOffline)
        eventStatusChangedExpectation?.fulfill()
    }

}
