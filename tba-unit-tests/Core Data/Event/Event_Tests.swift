import XCTest
import CoreData
@testable import The_Blue_Alliance

class EventTestCase: CoreDataTestCase {

    var event: Event!

    override func setUp() {
        super.setUp()

        event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        event = nil

        super.tearDown()
    }

    func test_isHappeningNow_isHappening() {
        // Event started an hour ago, ends in an hour
        event.startDate = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        event.endDate = Date(timeIntervalSinceNow: KDate.secondsInAnHour)
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        // Event started 2 hours ago, ended an hour ago
        event.startDate = Date(timeIntervalSinceNow: (-2 * KDate.secondsInAnHour))
        event.endDate = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        XCTAssertFalse(event.isHappeningNow)
    }

}
