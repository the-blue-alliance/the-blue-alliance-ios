import XCTest
import CoreData
@testable import The_Blue_Alliance

class District_TestCase: CoreDataTestCase {

    var district: District!

    override func setUp() {
        super.setUp()

        district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        district = nil

        super.tearDown()
    }

    func test_abbreviationWithYear() {
        district.year = Int16(2009)
        district.abbreviation = "fim"

        XCTAssertEqual(district.abbreviationWithYear, "2009 FIM")
    }

    func test_isHappeningNow_notCurrentYear() {
        district.year = Int16(2011)

        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventType = Int16(EventType.districtChampionship.rawValue)
        district.addToEvents(dcmp)

        XCTAssertFalse(district.isHappeningNow)
    }

    func test_isHappeningNow_noDCMP() {
        district.year = Int16(Calendar.current.year)
        XCTAssertFalse(district.isHappeningNow)
    }

    func test_districtChampionship() {
        let calendar = Calendar.current
        district.year = Int16(calendar.year)

        let stopBuildDay = calendar.stopBuildDay()
        let today = Date()
        // To get our test to pass, we're going to set our districtChampionship.endDate to make sure it inclues today
        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventType = Int16(EventType.districtChampionship.rawValue)
        if stopBuildDay > today {
            dcmp.endDate = calendar.date(byAdding: DateComponents(day: -1), to: today)
        } else {
            dcmp.endDate = calendar.date(byAdding: DateComponents(day: 1), to: today)
        }
        district.addToEvents(dcmp)

        XCTAssert(district.isHappeningNow)
    }

}
