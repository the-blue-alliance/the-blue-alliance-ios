import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class DistrictRanking_TestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()
        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, district: event.district!, in: persistentContainer.viewContext)
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
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, district: event.district!, in: persistentContainer.viewContext)
        let firstEventPoints = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        let eventNew = districtEvent(eventKey: "2018mike2")
        let eventPointsNew = TBADistrictEventPoints(teamKey: "frc7332", eventKey: eventNew.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let duplicateModelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 2, rookieBonus: 10, pointTotal: 40, eventPoints: [eventPointsNew])
        let duplicateDistrictRanking = DistrictRanking.insert(duplicateModelDistrictRanking, district: event.district!, in: persistentContainer.viewContext)
        let secondEventPoints = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        XCTAssertEqual(districtRanking, duplicateDistrictRanking)
        XCTAssertEqual(districtRanking.rank, 2)
        XCTAssertEqual(districtRanking.rookieBonus, 10)
        XCTAssertEqual(districtRanking.pointTotal, 40)
        XCTAssertEqual(districtRanking.eventPoints?.count, 1)

        XCTAssertNotEqual(firstEventPoints, secondEventPoints)
        XCTAssert(firstEventPoints.isDeleted)
        XCTAssertFalse(districtRanking.eventPoints!.contains(firstEventPoints))
        XCTAssertFalse(secondEventPoints.isDeleted)
        XCTAssert(districtRanking.eventPoints!.contains(secondEventPoints))
    }

    func test_delete() {
        let event = districtEvent()
        let district = event.district!

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, district: district, in: persistentContainer.viewContext)

        let points = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints
        let teamKey = districtRanking.teamKey!

        persistentContainer.viewContext.delete(districtRanking)
        try! persistentContainer.viewContext.save()

        // District points should delete
        XCTAssertNil(points.managedObjectContext)

        // District should not delete
        XCTAssertNotNil(district.managedObjectContext)
        XCTAssertFalse(district.rankings!.contains(districtRanking))

        // Team key should not delete
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertFalse(teamKey.districtRankings!.contains(districtRanking))
    }

}
