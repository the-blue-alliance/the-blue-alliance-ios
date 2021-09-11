import CoreData
import TBAKit
import XCTest
@testable import TBAData

class DistrictTestCase: TBADataTestCase {

    func test_abbreviation() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviationRaw = "zor"
        XCTAssertEqual(district.abbreviation, "zor")
    }

    func test_key() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.keyRaw = "2019zor"
        XCTAssertEqual(district.key, "2019zor")
    }

    func test_name() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.nameRaw = "Zor District"
        XCTAssertEqual(district.name, "Zor District")
    }

    func test_year() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = NSNumber(value: 2019)
        XCTAssertEqual(district.year, 2019)
    }

    func test_events() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(district.events, [])

        let event = insertEvent()
        district.eventsRaw = NSSet(array: [event])
        XCTAssertEqual(district.events, [event])
    }

    func test_rankings() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(district.rankings, [])

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        district.rankingsRaw = NSSet(array: [ranking])
        XCTAssertEqual(district.rankings, [ranking])
    }

    func test_teams() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(district.teams, [])

        let team = insertTeam()
        district.teamsRaw = NSSet(array: [team])
        XCTAssertEqual(district.teams, [team])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<District> = District.fetchRequest()
        XCTAssertEqual(fr.entityName, District.entityName)
    }

    func test_predicate() {
        let predicate = District.predicate(key: "2019zor")
        XCTAssertEqual(predicate.predicateFormat, "keyRaw == \"2019zor\"")

        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.keyRaw = "2019zor"
        let district2 = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district2.keyRaw = "2020zor"

        let results = District.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [district])
    }

    func test_yearPredicate() {
        let predicate = District.yearPredicate(year: 2019)
        XCTAssertEqual(predicate.predicateFormat, "yearRaw == 2019")

        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = NSNumber(value: 2019)
        let district2 = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district2.yearRaw = NSNumber(value: 2020)

        let results = District.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [district])
    }

    func test_nameSortDescriptor() {
        let sd = District.nameSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(District.nameRaw))
        XCTAssert(sd.ascending)
    }

    func test_insert_year() {
        let modelDistrictOne = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let modelDistrictTwo = TBADistrict(abbreviation: "zor", name: "FIRST In Zor", key: "2018zor", year: 2018)

        District.insert([modelDistrictOne, modelDistrictTwo], year: 2018, in: persistentContainer.viewContext)
        let districtsFirst = District.fetch(in: persistentContainer.viewContext) {
            $0.predicate = District.yearPredicate(year: 2018)
        }

        let districtOne = districtsFirst.first(where: { $0.key == "2018fim" })!
        let districtTwo = districtsFirst.first(where: { $0.key == "2018zor" })!

        // Sanity check
        XCTAssertNotEqual(districtOne, districtTwo)

        District.insert([modelDistrictTwo], year: 2018, in: persistentContainer.viewContext)
        let districtsSecond = District.fetch(in: persistentContainer.viewContext) {
            $0.predicate = District.yearPredicate(year: 2018)
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

        let events = district.events
        let eventOne = events.first(where: { $0.key == "2018miket" })!
        let eventTwo = events.first(where: { $0.key == "2018mike2" })!

        // Sanity check
        XCTAssertEqual(district.events.count, 2)
        XCTAssertNotEqual(eventOne, eventTwo)

        district.insert([modelEventTwo])

        // Sanity check
        XCTAssert(district.events.onlyObject(eventTwo))

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

        let teams = district.teams
        let teamOne = teams.first(where: { $0.key == "frc1" })!
        let teamTwo = teams.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(district.teams.count, 2)
        XCTAssertNotEqual(teamOne, teamTwo)

        district.insert([modelTeamTwo])

        // Sanity check
        XCTAssert(district.teams.onlyObject(teamTwo))

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

        let rankings = district.rankings
        let rankingOne = rankings.first(where: { $0.team.key == "frc1" })!
        let rankingTwo = rankings.first(where: { $0.team.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(district.rankings.count, 2)
        XCTAssertNotEqual(rankingOne, rankingTwo)

        district.insert([modelRankingTwo])

        // Sanity check
        XCTAssert(district.rankings.onlyObject(rankingTwo))

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
        ranking.districtRaw = event.district

        persistentContainer.viewContext.delete(district)
        try! persistentContainer.viewContext.save()

        // Check that our District handles its relationships properly
        XCTAssertNil(ranking.districtRaw)
        XCTAssertNil(event.district)

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)

        // Ranking should be deleted
        XCTAssertNil(ranking.managedObjectContext)
    }

    func test_abbreviationWithYear() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = 2009
        district.abbreviationRaw = "fim"

        XCTAssertEqual(district.abbreviationWithYear, "2009 FIM")
    }

    func test_isHappeningNow_notCurrentYear() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = 2011

        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventTypeRaw = EventType.districtChampionship.rawValue as NSNumber
        district.addToEventsRaw(dcmp)

        XCTAssertFalse(district.isHappeningNow)
    }

    func test_isHappeningNow_noDCMP() {
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = Calendar.current.year as NSNumber
        XCTAssertFalse(district.isHappeningNow)
    }

    func test_districtChampionship() {
        let calendar = Calendar.current

        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.yearRaw = calendar.year as NSNumber

        let stopBuildDay = calendar.stopBuildDay()
        let today = Date()
        // To get our test to pass, we're going to set our districtChampionship.endDate to make sure it inclues today
        let dcmp = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        dcmp.eventTypeRaw = EventType.districtChampionship.rawValue as NSNumber
        if stopBuildDay > today {
            dcmp.endDateRaw = calendar.date(byAdding: DateComponents(day: -1), to: today)
        } else {
            dcmp.endDateRaw = calendar.date(byAdding: DateComponents(day: 1), to: today)
        }
        district.addToEventsRaw(dcmp)

        XCTAssert(district.isHappeningNow)
    }

}
