import CoreData
import TBAKit
import XCTest
@testable import TBAData

class DistrictEventPointsTestCase: TBADataTestCase {

    func test_alliancePoints() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.alliancePointsRaw = NSNumber(value: 10)
        XCTAssertEqual(eventPoints.alliancePoints, 10)
    }

    func test_awardPoints() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.awardPointsRaw = NSNumber(value: 10)
        XCTAssertEqual(eventPoints.awardPoints, 10)
    }

    func test_districtCMP() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.districtCMPRaw = NSNumber(booleanLiteral: true)
        XCTAssert(eventPoints.districtCMP!)
    }

    func test_elimPoints() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.elimPointsRaw = NSNumber(value: 10)
        XCTAssertEqual(eventPoints.elimPoints, 10)
    }

    func test_qualPoints() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.qualPointsRaw = NSNumber(value: 10)
        XCTAssertEqual(eventPoints.qualPoints, 10)
    }

    func test_total() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.totalRaw = NSNumber(value: 10)
        XCTAssertEqual(eventPoints.total, 10)
    }

    func test_districtRanking() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(eventPoints.districtRanking)

        let districtRanking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.districtRankingRaw = districtRanking
        XCTAssertEqual(eventPoints.districtRanking, districtRanking)
    }

    func test_event() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.eventRaw = event
        XCTAssertEqual(eventPoints.event, event)
    }

    func test_team() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.teamRaw = team
        XCTAssertEqual(eventPoints.team, team)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<DistrictEventPoints> = DistrictEventPoints.fetchRequest()
        XCTAssertEqual(fr.entityName, DistrictEventPoints.entityName)
    }

    func test_eventPredicate() {
        let event = insertEvent()
        let predicate = DistrictEventPoints.eventPredicate(eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\"")

        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        _ = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        eventPoints.eventRaw = event

        let results = DistrictEventPoints.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [eventPoints])
    }

    func test_totalSortDescriptor() {
        let sd = DistrictEventPoints.totalSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(DistrictEventPoints.totalRaw))
        XCTAssertFalse(sd.ascending)
    }

    func test_insert() {
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", districtCMP: true, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, in: persistentContainer.viewContext)

        XCTAssertEqual(eventPoints.team.key, "frc7332")
        XCTAssertEqual(eventPoints.event.key, "2018miket")
        XCTAssertEqual(eventPoints.alliancePoints, 10)
        XCTAssertEqual(eventPoints.awardPoints, 20)
        XCTAssert(eventPoints.districtCMP!)
        XCTAssertEqual(eventPoints.qualPoints, 30)
        XCTAssertEqual(eventPoints.elimPoints, 40)
        XCTAssertEqual(eventPoints.total, 50)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_event() {
        let event = insertDistrictEvent()

        let modelPointsOne = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        DistrictEventPoints.insert([modelPointsOne], eventKey: event.key, in: persistentContainer.viewContext)
        let pointsOne = DistrictEventPoints.fetch(in: persistentContainer.viewContext) {
            $0.predicate = DistrictEventPoints.eventPredicate(eventKey: event.key)
        }.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
        XCTAssertNotNil(pointsOne.managedObjectContext)

        let modelPointsTwo = TBADistrictEventPoints(teamKey: "frc1", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        DistrictEventPoints.insert([modelPointsTwo], eventKey: event.key, in: persistentContainer.viewContext)
        let pointsTwo = DistrictEventPoints.fetch(in: persistentContainer.viewContext) {
            $0.predicate = DistrictEventPoints.eventPredicate(eventKey: event.key)
        }.first!

        // Sanity check
        XCTAssertNotEqual(pointsOne, pointsTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNil(pointsOne.managedObjectContext)
        XCTAssertNotNil(pointsTwo.managedObjectContext)
    }

    func test_update() {
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, in: persistentContainer.viewContext)

        let duplicateModelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", alliancePoints: 50, awardPoints: 40, qualPoints: 30, elimPoints: 20, total: 10)
        let duplicateEventPoints = DistrictEventPoints.insert(duplicateModelEventPoints, in: persistentContainer.viewContext)

        XCTAssertEqual(eventPoints, duplicateEventPoints)
        XCTAssertEqual(eventPoints.alliancePoints, 50)
    }

    func test_delete() {
        let event = insertDistrictEvent()
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [modelEventPoints])
        event.district!.insert([modelDistrictRanking])
        let districtRanking = event.district!.rankings.first!

        let points = districtRanking.eventPoints.first!
        let team = points.team

        // Should throw an error - cannot deleted District Event Points when attached to a District Ranking
        persistentContainer.viewContext.delete(points)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        // Manually remove our District Ranking -> District relationship so we can save
        districtRanking.removeFromEventPointsRaw(points)
        persistentContainer.viewContext.delete(points)
        try! persistentContainer.viewContext.save()

        // Ranking should not be deleted
        XCTAssertNotNil(districtRanking.managedObjectContext)
        XCTAssertEqual(districtRanking.eventPoints.count, 0)

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertEqual(event.rankings.count, 0)

        // Team should not be deleted
        XCTAssertNotNil(team.managedObjectContext)
        XCTAssertEqual(team.eventPoints.count, 0)

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertEqual(event.points.count, 0)
    }

    func test_isOrphaned() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        // No Event or Ranking - should be orphaned
        XCTAssert(eventPoints.isOrphaned)

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.addToEventPointsRaw(eventPoints)
        // Attached to a Ranking - should not be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)

        ranking.removeFromEventPointsRaw(eventPoints)

        let key = "2018miket"
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.keyRaw = key
        eventPoints.eventRaw = event
        // Attached to a Event - should not be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)

        persistentContainer.viewContext.delete(event)

        // Not attached to either a Ranking or an Event - should be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)
    }

}
