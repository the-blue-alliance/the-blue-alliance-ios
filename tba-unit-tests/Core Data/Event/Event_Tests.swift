import XCTest
@testable import The_Blue_Alliance

class Event_TestCase: CoreDataTestCase {

    let calendar: Calendar = Calendar.current
    var event: Event!

    override func setUp() {
        super.setUp()

        event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        event = nil

        super.tearDown()
    }

    func test_isHappeningNow() {
        // Event started two days ago, ends today
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -2), to: today)
        event.endDate = today
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        // Event started three days ago, ended yesterday
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -3), to: today)
        event.endDate = calendar.date(byAdding: DateComponents(day: -1), to: today)
        XCTAssertFalse(event.isHappeningNow)
    }

    func test_isDistrictChampionshipEvent() {
        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventType = Int16(EventType.districtChampionship.rawValue)
        XCTAssert(dcmp.isDistrictChampionshipEvent)

        let dcmpDivision = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmpDivision.eventType = Int16(EventType.districtChampionshipDivision.rawValue)
        XCTAssert(dcmpDivision.isDistrictChampionshipEvent)
    }

    func test_isDistrictChampionship() {
        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventType = Int16(EventType.districtChampionship.rawValue)
        XCTAssert(dcmp.isDistrictChampionship)

        let dcmpDivision = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmpDivision.eventType = Int16(EventType.districtChampionshipDivision.rawValue)
        XCTAssertFalse(dcmpDivision.isDistrictChampionship)
    }

}
