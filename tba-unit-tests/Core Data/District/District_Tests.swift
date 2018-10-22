import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class District_TestCase: CoreDataTestCase {

    func test_insert() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)
        XCTAssertEqual(district.abbreviation, "fim")
        XCTAssertEqual(district.name, "FIRST In Michigan")
        XCTAssertEqual(district.key, "2018fim")
        XCTAssertEqual(district.year, 2018)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        let duplicateModelDistrict = TBADistrict(abbreviation: "fim", name: "Michigan FIRST", key: "2018fim", year: 2018)
        let duplicateDistrict = District.insert(duplicateModelDistrict, in: persistentContainer.viewContext)

        XCTAssertEqual(district, duplicateDistrict)
        XCTAssertEqual(district.name, "Michigan FIRST")
    }

    func test_delete() {
        let event = districtEvent()
        let district = event.district!

        let ranking = DistrictRanking(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.district = event.district

        persistentContainer.viewContext.delete(district)
        try! persistentContainer.viewContext.save()

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertNil(event.district)

        // Ranking should be deleted
        XCTAssertNil(ranking.managedObjectContext)
        XCTAssertNil(ranking.district)
    }

    func test_abbreviationWithYear() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.year = 2009
        district.abbreviation = "fim"

        XCTAssertEqual(district.abbreviationWithYear, "2009 FIM")
    }

    func test_isHappeningNow_notCurrentYear() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.year = 2011

        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventType = Int16(EventType.districtChampionship.rawValue)
        district.addToEvents(dcmp)

        XCTAssertFalse(district.isHappeningNow)
    }

    func test_isHappeningNow_noDCMP() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.year = Calendar.current.year as NSNumber
        XCTAssertFalse(district.isHappeningNow)
    }

    func test_districtChampionship() {
        let calendar = Calendar.current

        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.year = calendar.year as NSNumber

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
