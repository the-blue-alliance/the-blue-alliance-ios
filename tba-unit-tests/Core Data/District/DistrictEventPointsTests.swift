import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class DistrictEventPointsTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, event: event, in: persistentContainer.viewContext)

        XCTAssertEqual(eventPoints.teamKey?.key, "frc7332")
        XCTAssertEqual(eventPoints.event, event)
        XCTAssertEqual(eventPoints.alliancePoints, 10)
        XCTAssertEqual(eventPoints.awardPoints, 20)
        XCTAssertNil(eventPoints.districtCMP)
        XCTAssertEqual(eventPoints.qualPoints, 30)
        XCTAssertEqual(eventPoints.elimPoints, 40)
        XCTAssertEqual(eventPoints.total, 50)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()
        let modelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let eventPoints = DistrictEventPoints.insert(modelEventPoints, event: event, in: persistentContainer.viewContext)

        let duplicateModelEventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 50, awardPoints: 40, qualPoints: 30, elimPoints: 20, total: 10)
        let duplicateEventPoints = DistrictEventPoints.insert(duplicateModelEventPoints, event: event, in: persistentContainer.viewContext)

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

        // Team key should not be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertEqual(teamKey.eventPoints!.count, 0)
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
