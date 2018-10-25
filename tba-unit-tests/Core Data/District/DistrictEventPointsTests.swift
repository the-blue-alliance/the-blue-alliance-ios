import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class DistrictEventPointsTestCase: CoreDataTestCase {

    func test_insert() {
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, in: persistentContainer.viewContext)

        XCTAssertEqual(eventPoints.teamKey?.key, "frc7332")
        XCTAssertEqual(eventPoints.eventKey?.key!, "2018miket")
        XCTAssertEqual(eventPoints.alliancePoints, 10)
        XCTAssertEqual(eventPoints.awardPoints, 20)
        XCTAssertNil(eventPoints.districtCMP)
        XCTAssertEqual(eventPoints.qualPoints, 30)
        XCTAssertEqual(eventPoints.elimPoints, 40)
        XCTAssertEqual(eventPoints.total, 50)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_event() {
        let event = districtEvent()
        let modelEventPointsOne = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPointsOne = DistrictEventPoints.insert([modelEventPointsOne], eventKey: event.key!, in: persistentContainer.viewContext)
        let one = eventPointsOne.first!

        XCTAssertFalse(one.isDeleted)

        let modelEventPointsTwo = TBADistrictEventPoints(teamKey: "frc1", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPointsTwo = DistrictEventPoints.insert([modelEventPointsTwo], eventKey: event.key!, in: persistentContainer.viewContext)
        let two = eventPointsTwo.first!

        // Sanity check
        XCTAssertNotEqual(one, two)

        XCTAssert(one.isDeleted)
        XCTAssertFalse(two.isDeleted)
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
        let event = districtEvent()
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [modelEventPoints])
        let districtRanking = DistrictRanking.insert([modelDistrictRanking], district: event.district!, in: persistentContainer.viewContext).first!

        let points = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints
        let teamKey = points.teamKey!
        let eventKey = points.eventKey!

        // Manually remove our District Ranking -> District relationship so we can save
        points.districtRanking = nil

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

    func test_delete_deny() {
        let event = districtEvent()
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [modelEventPoints])
        let districtRanking = DistrictRanking.insert([modelDistrictRanking], district: event.district!, in: persistentContainer.viewContext).first!

        let points = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        persistentContainer.viewContext.delete(points)
        // District Event Points should not be able to save while still attached to a District Ranking
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

}
