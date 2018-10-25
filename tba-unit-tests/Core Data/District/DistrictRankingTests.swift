import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class DistrictRankingTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()
        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert([modelDistrictRanking], district: event.district!, in: persistentContainer.viewContext).first!

        XCTAssertEqual(districtRanking.district, event.district)
        XCTAssertEqual(districtRanking.teamKey?.key, "frc7332")
        XCTAssertEqual(districtRanking.pointTotal, 30)
        XCTAssertEqual(districtRanking.rank, 1)
        XCTAssertEqual(districtRanking.eventPoints?.count, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert([modelDistrictRanking], district: event.district!, in: persistentContainer.viewContext).first!
        let firstEventPoints = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        let eventNew = districtEvent(eventKey: "2018mike2")

        let eventPointsNew = TBADistrictEventPoints(teamKey: "frc7332", eventKey: eventNew.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let duplicateModelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 2, rookieBonus: 10, pointTotal: 40, eventPoints: [eventPointsNew])
        let duplicateDistrictRanking = DistrictRanking.insert([duplicateModelDistrictRanking], district: event.district!, in: persistentContainer.viewContext).first!
        let secondEventPoints = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        // Sanity check
        XCTAssertEqual(districtRanking, duplicateDistrictRanking)
        XCTAssertNotEqual(firstEventPoints, secondEventPoints)

        // Check our District Ranking got updated properly
        XCTAssertEqual(districtRanking.rank, 2)
        XCTAssertEqual(districtRanking.rookieBonus, 10)
        XCTAssertEqual(districtRanking.pointTotal, 40)
        XCTAssertEqual(districtRanking.eventPoints?.count, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that our District Ranking handles its relationships properly
        XCTAssertFalse(districtRanking.eventPoints!.contains(firstEventPoints))
        XCTAssert(districtRanking.eventPoints!.contains(secondEventPoints))

        // Orphaned District Event Points should be deleted
        XCTAssertNil(firstEventPoints.managedObjectContext)

        // Not-orphaned District Event Points should not be deleted
        XCTAssertNotNil(secondEventPoints.managedObjectContext)
    }

    func test_delete() {
        let event = districtEvent()
        let district = event.district!

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert([modelDistrictRanking], district: district, in: persistentContainer.viewContext).first!

        let points = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints
        let teamKey = districtRanking.teamKey!

        persistentContainer.viewContext.delete(districtRanking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that District Ranking handles it's relationships properly
        XCTAssertNil(points.districtRanking)
        XCTAssertFalse(district.rankings!.contains(districtRanking))
        XCTAssertFalse(teamKey.districtRankings!.contains(districtRanking))

        // District points should delete
        XCTAssertNil(points.managedObjectContext)

        // District should not delete
        XCTAssertNotNil(district.managedObjectContext)

        // Team key should not delete
        XCTAssertNotNil(teamKey.managedObjectContext)
    }

}
