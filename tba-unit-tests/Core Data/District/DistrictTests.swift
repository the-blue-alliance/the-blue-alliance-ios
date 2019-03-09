import XCTest
@testable import TBA

class DistrictTestCase: CoreDataTestCase {

    func test_insert_year() {
        let modelDistrictOne = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let modelDistrictTwo = TBADistrict(abbreviation: "zor", name: "FIRST In Zor", key: "2018zor", year: 2018)

        District.insert([modelDistrictOne, modelDistrictTwo], year: 2018, in: persistentContainer.viewContext)
        let districtsFirst = District.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(District.year), 2018)
        }

        let districtOne = districtsFirst.first(where: { $0.key == "2018fim" })!
        let districtTwo = districtsFirst.first(where: { $0.key == "2018zor" })!

        // Sanity check
        XCTAssertNotEqual(districtOne, districtTwo)

        District.insert([modelDistrictTwo], year: 2018, in: persistentContainer.viewContext)
        let districtsSecond = District.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(District.year), 2018)
        }

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(districtsSecond, [districtTwo])

        // DistrictOne should be deleted
        XCTAssertNil(districtOne.managedObjectContext)

        // DistrictTwo should not be deleted
        XCTAssertNotNil(districtTwo.managedObjectContext)
    }

    func test_insert() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        XCTAssertEqual(district.abbreviation, "fim")
        XCTAssertEqual(district.name, "FIRST In Michigan")
        XCTAssertEqual(district.key, "2018fim")
        XCTAssertEqual(district.year, 2018)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_events() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        let modelEventOne = TBAEvent(key: "2018miket", name: "Event 1", eventCode: "miket", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])
        let modelEventTwo = TBAEvent(key: "2018mike2", name: "Event 2", eventCode: "mike2", eventType: 1, startDate: Event.dateFormatter.date(from: "2018-03-01")!, endDate: Event.dateFormatter.date(from: "2018-03-03")!, year: 2018, eventTypeString: "District", divisionKeys: [])

        district.insert([modelEventOne, modelEventTwo])

        let events = district.events!.allObjects as! [Event]
        let eventOne = events.first(where: { $0.key == "2018miket" })!
        let eventTwo = events.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertEqual(district.events?.count, 2)
        XCTAssertNotEqual(eventOne, eventTwo)

        district.insert([modelEventTwo])

        // Sanity check
        XCTAssert(district.events!.onlyObject(eventTwo))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // No events, including orphans, should be deleted
        XCTAssertNotNil(eventOne.managedObjectContext)
        XCTAssertNotNil(eventTwo.managedObjectContext)
    }

    func test_insert_teams() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        let modelTeamOne = TBATeam(key: "frc1", teamNumber: 1, name: "Team 1", rookieYear: 2001)
        let modelTeamTwo = TBATeam(key: "frc2", teamNumber: 2, name: "Team 2", rookieYear: 2002)

        district.insert([modelTeamOne, modelTeamTwo])

        let teams = district.teams!.allObjects as! [Team]
        let teamOne = teams.first(where: { $0.key == "frc1" })!
        let teamTwo = teams.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(district.teams?.count, 2)
        XCTAssertNotEqual(teamOne, teamTwo)

        district.insert([modelTeamTwo])

        // Sanity check
        XCTAssert(district.teams!.onlyObject(teamTwo))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // No teams, including orphans, should be deleted
        XCTAssertNotNil(teamOne.managedObjectContext)
        XCTAssertNotNil(teamTwo.managedObjectContext)
    }

    func test_insert_rankings() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        let modelRankingOne = TBADistrictRanking(teamKey: "frc1", rank: 1, pointTotal: 70, eventPoints: [])
        let modelRankingTwo = TBADistrictRanking(teamKey: "frc2", rank: 2, pointTotal: 66, eventPoints: [])

        district.insert([modelRankingOne, modelRankingTwo])

        let rankings = district.rankings!.allObjects as! [DistrictRanking]
        let rankingOne = rankings.first(where: { $0.teamKey?.key == "frc1" })!
        let rankingTwo = rankings.first(where: { $0.teamKey?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(district.rankings?.count, 2)
        XCTAssertNotEqual(rankingOne, rankingTwo)

        district.insert([modelRankingTwo])

        // Sanity check
        XCTAssert(district.rankings!.onlyObject(rankingTwo))

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ranking One is an orphan, and should be deleted. Ranking Two should still exist.
        XCTAssertNil(rankingOne.managedObjectContext)
        XCTAssertNotNil(rankingTwo.managedObjectContext)
    }

    func test_update() {
        let modelDistrict = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let district = District.insert(modelDistrict, in: persistentContainer.viewContext)

        let duplicateModelDistrict = TBADistrict(abbreviation: "fim", name: "Michigan FIRST", key: "2018fim", year: 2018)
        let duplicateDistrict = District.insert(duplicateModelDistrict, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(district, duplicateDistrict)

        // Check that our District updates its values properly
        XCTAssertEqual(district.name, "Michigan FIRST")

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let event = insertDistrictEvent()
        let district = event.district!

        let ranking = DistrictRanking(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.district = event.district

        persistentContainer.viewContext.delete(district)
        try! persistentContainer.viewContext.save()

        // Check that our District handles its relationships properly
        XCTAssertNil(ranking.district)
        XCTAssertNil(event.district)

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)

        // Ranking should be deleted
        XCTAssertNil(ranking.managedObjectContext)
    }

    func test_isOrphaned() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        // Should always be false
        XCTAssertFalse(district.isOrphaned)
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
        dcmp.eventType = EventType.districtChampionship.rawValue as NSNumber
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
        dcmp.eventType = EventType.districtChampionship.rawValue as NSNumber
        if stopBuildDay > today {
            dcmp.endDate = calendar.date(byAdding: DateComponents(day: -1), to: today)
        } else {
            dcmp.endDate = calendar.date(byAdding: DateComponents(day: 1), to: today)
        }
        district.addToEvents(dcmp)

        XCTAssert(district.isHappeningNow)
    }

}
