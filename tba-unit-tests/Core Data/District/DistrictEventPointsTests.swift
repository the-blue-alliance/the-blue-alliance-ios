import XCTest
@testable import TBA

class DistrictEventPointsTestCase: CoreDataTestCase {

    func test_insert() {
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", districtCMP: true, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, in: persistentContainer.viewContext)

        XCTAssertEqual(eventPoints.teamKey?.key, "frc7332")
        XCTAssertEqual(eventPoints.eventKey?.key!, "2018miket")
        XCTAssertEqual(eventPoints.alliancePoints, 10)
        XCTAssertEqual(eventPoints.awardPoints, 20)
        XCTAssert(eventPoints.districtCMP!.boolValue)
        XCTAssertEqual(eventPoints.qualPoints, 30)
        XCTAssertEqual(eventPoints.elimPoints, 40)
        XCTAssertEqual(eventPoints.total, 50)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_event() {
        let event = insertDistrictEvent()

        let modelPointsOne = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        DistrictEventPoints.insert([modelPointsOne], eventKey: event.key!, in: persistentContainer.viewContext)
        let pointsOne = DistrictEventPoints.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %@",
                                       #keyPath(DistrictEventPoints.eventKey.key), event.key!)
        }.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
        XCTAssertNotNil(pointsOne.managedObjectContext)

        let modelPointsTwo = TBADistrictEventPoints(teamKey: "frc1", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        DistrictEventPoints.insert([modelPointsTwo], eventKey: event.key!, in: persistentContainer.viewContext)
        let pointsTwo = DistrictEventPoints.fetch(in: persistentContainer.viewContext) {
            $0.predicate = NSPredicate(format: "%K == %@",
                                       #keyPath(DistrictEventPoints.eventKey.key), event.key!)
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
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [modelEventPoints])
        event.district!.insert([modelDistrictRanking])
        let districtRanking = event.district!.rankings!.allObjects.first as! DistrictRanking

        let points = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints
        let teamKey = points.teamKey!
        let eventKey = points.eventKey!

        // Should throw an error - cannot deleted District Event Points when attached to a District Ranking
        persistentContainer.viewContext.delete(points)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        // Manually remove our District Ranking -> District relationship so we can save
        districtRanking.removeFromEventPoints(points)
        persistentContainer.viewContext.delete(points)
        try! persistentContainer.viewContext.save()

        // Ranking should not be deleted
        XCTAssertNotNil(districtRanking.managedObjectContext)
        XCTAssertEqual(districtRanking.eventPoints!.count, 0)

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertEqual(event.rankings!.count, 0)

        // TeamKey should not be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertEqual(teamKey.eventPoints!.count, 0)

        // EventKey should not be deleted
        XCTAssertNotNil(eventKey.managedObjectContext)
        XCTAssertEqual(eventKey.points!.count, 0)
    }

    func test_isOrphaned() {
        let eventPoints = DistrictEventPoints.init(entity: DistrictEventPoints.entity(), insertInto: persistentContainer.viewContext)
        // No Event or Ranking - should be orphaned
        XCTAssert(eventPoints.isOrphaned)

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.addToEventPoints(eventPoints)
        // Attached to a Ranking - should not be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)

        ranking.removeFromEventPoints(eventPoints)

        let key = "2018miket"
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.key = key
        let eventKey = EventKey.insert(withKey: key, in: persistentContainer.viewContext)
        eventPoints.eventKey = eventKey
        // Attached to a Event - should not be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)

        persistentContainer.viewContext.delete(event)

        // Not attached to either a Ranking or an Event - should be orphaned
        XCTAssertFalse(eventPoints.isOrphaned)
    }

}
