import CoreData
import TBAKit
import XCTest
@testable import TBAData

class DistrictRankingTestCase: TBADataTestCase {

    func test_pointTotal() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        rankings.pointTotalRaw = NSNumber(value: 10)
        XCTAssertEqual(rankings.pointTotal, 10)
    }

    func test_rank() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        rankings.rankRaw = NSNumber(value: 10)
        XCTAssertEqual(rankings.rank, 10)
    }

    func test_rookieBonus() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(rankings.rookieBonus)
        rankings.rookieBonusRaw = NSNumber(value: 10)
        XCTAssertEqual(rankings.rookieBonus, 10)
    }

    func test_district() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        rankings.districtRaw = district
        XCTAssertEqual(rankings.district, district)
    }

    func test_eventPoints() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        rankings.eventPointsRaw = NSSet(array: [eventPoints])
        XCTAssertEqual(rankings.eventPoints, [eventPoints])
    }

    func test_team() {
        let rankings = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        rankings.teamRaw = team
        XCTAssertEqual(rankings.team, team)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        XCTAssertEqual(fr.entityName, DistrictRanking.entityName)
    }

    func test_districtPredicate() {
        let district = insertDistrict()
        let predicate = DistrictRanking.districtPredicate(districtKey: district.key)
        XCTAssertEqual(predicate.predicateFormat, "districtRaw.keyRaw == \"2018fim\"")

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        _ = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.districtRaw = district

        let results = DistrictRanking.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [ranking])
    }

    func test_teamSearchPredicate() {
        let predicate = DistrictRanking.teamSearchPredicate(searchText: "abc")
        XCTAssertEqual(predicate.predicateFormat, "teamRaw.nicknameRaw CONTAINS[cd] \"abc\" OR teamRaw.teamNumberRaw.stringValue BEGINSWITH[cd] \"abc\" OR teamRaw.cityRaw CONTAINS[cd] \"abc\"")
    }

    func test_rankSortDescriptor() {
        let sd = DistrictRanking.rankSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(DistrictRanking.rankRaw))
        XCTAssert(sd.ascending)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key, in: persistentContainer.viewContext)

        XCTAssertEqual(districtRanking.team.key, "frc7332")
        XCTAssertEqual(districtRanking.pointTotal, 30)
        XCTAssertEqual(districtRanking.rank, 1)
        XCTAssertEqual(districtRanking.eventPoints.count, 1)

        // Should throw an error - District Ranking must be associated with a District
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.district!.addToRankingsRaw(districtRanking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key, in: persistentContainer.viewContext)
        let firstEventPoints = districtRanking.eventPoints.first!

        // Attach to a District so we can save
        event.district!.addToRankingsRaw(districtRanking)

        let eventNew = insertDistrictEvent(eventKey: "2018mike2")

        let eventPointsNew = TBADistrictEventPoints(teamKey: "frc7332", eventKey: eventNew.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let duplicateModelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 2, rookieBonus: 10, pointTotal: 40, eventPoints: [eventPointsNew])
        let duplicateDistrictRanking = DistrictRanking.insert(duplicateModelDistrictRanking, districtKey: event.district!.key, in: persistentContainer.viewContext)
        let secondEventPoints = districtRanking.eventPoints.first!

        // Sanity check
        XCTAssertEqual(districtRanking, duplicateDistrictRanking)
        XCTAssertNotEqual(firstEventPoints, secondEventPoints)

        // Check our District Ranking got updated properly
        XCTAssertEqual(districtRanking.rank, 2)
        XCTAssertEqual(districtRanking.rookieBonus, 10)
        XCTAssertEqual(districtRanking.pointTotal, 40)
        XCTAssertEqual(districtRanking.eventPoints.count, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that our District Ranking handles its relationships properly
        XCTAssertFalse(districtRanking.eventPoints.contains(firstEventPoints))
        XCTAssert(districtRanking.eventPoints.contains(secondEventPoints))

        // First District Event Points is still attached to an Event - shouldn't be deleted
        XCTAssertNotNil(firstEventPoints.managedObjectContext)

        // Not-orphaned District Event Points should not be deleted
        XCTAssertNotNil(secondEventPoints.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()
        let district = event.district!

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key, in: persistentContainer.viewContext)

        let points = districtRanking.eventPoints.first!
        let team = districtRanking.team

        persistentContainer.viewContext.delete(districtRanking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that District Ranking handles it's relationships properly
        XCTAssertNil(points.districtRankingRaw)
        XCTAssertFalse(district.rankings.contains(districtRanking))
        XCTAssertFalse(team.districtRankings.contains(districtRanking))

        // Ranking should be deleted
        XCTAssertNil(districtRanking.managedObjectContext)

        // District points should delete
        XCTAssertNil(points.managedObjectContext)

        // District should not delete
        XCTAssertNotNil(district.managedObjectContext)

        // Team key should not delete
        XCTAssertNotNil(team.managedObjectContext)
    }

    func test_sortedEventPoints() {
        // Three Events that all start at different dates
        let eventOne = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventOne.startDateRaw = Event.dateFormatter.date(from: "2018-03-01")!
        eventOne.keyRaw = "2018miket"

        let eventTwo = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventTwo.startDateRaw = Event.dateFormatter.date(from: "2018-03-02")!
        eventTwo.keyRaw = "2018mike2"

        let eventThree = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventThree.startDateRaw = Event.dateFormatter.date(from: "2018-03-03")!
        eventThree.keyRaw = "2018mike3"

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)

        let modelEventPointsOne = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018miket", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelEventPointsTwo = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018mike2", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelEventPointsThree = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018mike3", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)

        // Insert DistrictEventPoints in not the same order
        ranking.addToEventPointsRaw(NSSet(array: [modelEventPointsTwo, modelEventPointsThree, modelEventPointsOne].map({
            return DistrictEventPoints.insert($0, in: persistentContainer.viewContext)
        })))

        let sortedEventPoints = ranking.sortedEventPoints
        XCTAssertEqual(sortedEventPoints.map({ $0.event.key }), ["2018miket", "2018mike2", "2018mike3"])
    }

    func test_isOrphaned() {
        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        // No District - should be orphaned
        XCTAssert(ranking.isOrphaned)

        let district = District.init(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.addToRankingsRaw(ranking)
        // Attached to a District - should not be orphaned
        XCTAssertFalse(ranking.isOrphaned)

        district.removeFromRankingsRaw(ranking)
        // No District - should be orphaned
        XCTAssert(ranking.isOrphaned)
    }

}
