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
    
    func event(type eventType: EventType) -> Event {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventType = Int16(eventType.rawValue)
        return event
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
        let dcmp = event(type: EventType.districtChampionship)
        XCTAssert(dcmp.isDistrictChampionshipEvent)
        XCTAssert(dcmp.isDistrictChampionship)

        let dcmpDivision = event(type: EventType.districtChampionshipDivision)
        XCTAssert(dcmpDivision.isDistrictChampionshipEvent)
        XCTAssertFalse(dcmpDivision.isDistrictChampionship)
    }

    func test_hybridType_regional() {
        let eventType = EventType.regional
        let regional = event(type: eventType)
        XCTAssertEqual(regional.calculateHybridType(), "0")
    }

    func test_hybridType_district() {
        let eventType = EventType.district
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtEvent = event(type: eventType)
        districtEvent.district = district

        XCTAssertEqual(districtEvent.calculateHybridType(), "1.fim")
    }

    func test_hybridType_districtChampionship() {
        let eventType = EventType.districtChampionship
        let districtChampionship = event(type: eventType)
        XCTAssertEqual(districtChampionship.calculateHybridType(), "2.dcmp")
    }

    func test_hybridType_championshipDivision() {
        let eventType = EventType.championshipDivision
        let championshipDivision = event(type: eventType)
        XCTAssertEqual(championshipDivision.calculateHybridType(), "3")
    }

    func test_hybridType_championshipFinals() {
        let eventType = EventType.championshipFinals
        let championshipFinals = event(type: eventType)
        XCTAssertEqual(championshipFinals.calculateHybridType(), "4")
    }

    func test_hybridType_districtChampionshipDivision() {
        let eventType = EventType.districtChampionshipDivision
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtChampionshipDivision = event(type: eventType)
        districtChampionshipDivision.district = district

        XCTAssertEqual(districtChampionshipDivision.calculateHybridType(), "2..fim.dcmpd")

        let districtChampionship = event(type: EventType.districtChampionship)
        // Ensure district championship divisions appear before district championships
        XCTAssert(districtChampionshipDivision.calculateHybridType() < districtChampionship.calculateHybridType())
    }

    func test_hybridType_festivalOfChampions() {
        let eventType = EventType.festivalOfChampions
        let festivalOfChampions = event(type: eventType)
        XCTAssertEqual(festivalOfChampions.calculateHybridType(), "6")
    }

    func test_hybridType_offseason() {
        let eventType = EventType.offseason

        let novermberOffseason = event(type: eventType)
        novermberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 11, day: 1))
        XCTAssertEqual(novermberOffseason.calculateHybridType(), "99.11")

        let septemberOffseason = event(type: eventType)
        septemberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 9, day: 1))
        XCTAssertEqual(septemberOffseason.calculateHybridType(), "99.9")

        // Ensure single-digit month offseason events show up before double-digit month offseason events
        XCTAssert(septemberOffseason.calculateHybridType() > novermberOffseason.calculateHybridType())
    }

    func test_hybridType_preseason() {
        let eventType = EventType.preseason
        let preseason = event(type: eventType)
        XCTAssertEqual(preseason.calculateHybridType(), "100")
    }

    func test_hybridType_unlabeled() {
        let eventType = EventType.unlabeled
        let unlabeled = event(type: eventType)
        XCTAssertEqual(unlabeled.calculateHybridType(), "-1")
    }

}
