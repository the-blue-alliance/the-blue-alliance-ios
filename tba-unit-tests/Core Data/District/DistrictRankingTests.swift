import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class DistrictRankingTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(districtRanking.teamKey?.key, "frc7332")
        XCTAssertEqual(districtRanking.pointTotal, 30)
        XCTAssertEqual(districtRanking.rank, 1)
        XCTAssertEqual(districtRanking.eventPoints?.count, 1)

        // Should throw an error - District Ranking must be associated with a District
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.district!.addToRankings(districtRanking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key!, in: persistentContainer.viewContext)
        let firstEventPoints = districtRanking.eventPoints!.allObjects.first! as! DistrictEventPoints

        // Attach to a District so we can save
        event.district!.addToRankings(districtRanking)

        let eventNew = districtEvent(eventKey: "2018mike2")

        let eventPointsNew = TBADistrictEventPoints(teamKey: "frc7332", eventKey: eventNew.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let duplicateModelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 2, rookieBonus: 10, pointTotal: 40, eventPoints: [eventPointsNew])
        let duplicateDistrictRanking = DistrictRanking.insert(duplicateModelDistrictRanking, districtKey: event.district!.key!, in: persistentContainer.viewContext)
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

        // First District Event Points is still attached to an Event - shouldn't be deleted
        XCTAssertNotNil(firstEventPoints.managedObjectContext)

        // Not-orphaned District Event Points should not be deleted
        XCTAssertNotNil(secondEventPoints.managedObjectContext)
    }

    func test_delete() {
        let event = districtEvent()
        let district = event.district!

        let eventPoints = TBADistrictEventPoints(teamKey: "frc7332", eventKey: event.key!, alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelDistrictRanking = TBADistrictRanking(teamKey: "frc7332", rank: 1, rookieBonus: 10, pointTotal: 30, eventPoints: [eventPoints])
        let districtRanking = DistrictRanking.insert(modelDistrictRanking, districtKey: event.district!.key!, in: persistentContainer.viewContext)

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

    func test_sortedEventPoints() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Three Events that all start at different dates
        let eventOne = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventOne.startDate = dateFormatter.date(from: "2018-03-01")!
        eventOne.key = "2018miket"

        let eventTwo = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventTwo.startDate = dateFormatter.date(from: "2018-03-02")!
        eventTwo.key = "2018mike2"

        let eventThree = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        eventThree.startDate = dateFormatter.date(from: "2018-03-03")!
        eventThree.key = "2018mike3"

        let ranking = DistrictRanking.init(entity: DistrictRanking.entity(), insertInto: persistentContainer.viewContext)

        let modelEventPointsOne = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018miket", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelEventPointsTwo = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018mike2", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)
        let modelEventPointsThree = TBADistrictEventPoints(teamKey: "frc1", eventKey: "2018mike3", alliancePoints: 10, awardPoints: 20, qualPoints: 30, elimPoints: 40, total: 50)

        // Insert DistrictEventPoints in not the same order
        ranking.addToEventPoints(NSSet(array: [modelEventPointsTwo, modelEventPointsThree, modelEventPointsOne].map({
            return DistrictEventPoints.insert($0, in: persistentContainer.viewContext)
        })))

        // Sanity check - make sure points aren't necessairly coming back in the right order
        let unsortedEventPoints = ranking.eventPoints!.allObjects as! [DistrictEventPoints]
        XCTAssertNotEqual(unsortedEventPoints.map({ $0.eventKey!.key! }), ["2018miket", "2018mike2", "2018mike3"])

        let sortedEventPoints = ranking.sortedEventPoints
        XCTAssertEqual(sortedEventPoints.map({ $0.eventKey!.key! }), ["2018miket", "2018mike2", "2018mike3"])
    }

}
