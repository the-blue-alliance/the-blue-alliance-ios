import MyTBAKit
import TBAData
import TBAKit
import XCTest

class MyTBAEntityTestCase: TBADataTestCase {

    func test_modelType() {
        let entity = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: viewContext)

        entity.modelTypeRaw = NSNumber(value: 1)
        XCTAssertEqual(entity.modelType, .team)

        entity.modelType = .match
        XCTAssertEqual(entity.modelTypeRaw, 2)
    }

    func test_tbaObject_event() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "2018miket", modelType: .event), in: viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = coreDataTestFixture.insertDistrictEvent()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_tbaObject_team() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "frc7332", modelType: .team), in: viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = coreDataTestFixture.insertTeam()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_tbaObject_match() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), in: viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = coreDataTestFixture.insertMatch()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_isOrphaned() {
        let entity = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: viewContext)
        XCTAssertFalse(entity.isOrphaned)
    }

    func test_prepareForDeletion_match_noEvent() {
        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let modelMatch = TBAMatch(key: "2018miket_sf2m3",
                                  compLevel: "sf",
                                  setNumber: 2,
                                  matchNumber: 3,
                                  alliances: ["red": redAlliance, "blue": blueAlliance],
                                  winningAlliance: "blue",
                                  eventKey: "2018miket",
                                  time: 1520109780,
                                  actualTime: 1520090745,
                                  predictedTime: 1520109780,
                                  postResultTime: 1520090929,
                                  breakdown: ["red": [:], "blue": [:]],
                                  videos: [])
        let match = Match.insert(modelMatch, in: viewContext)

        let modelFavorite = MyTBAFavorite(modelKey: modelMatch.key, modelType: .match)
        let favorite = Favorite.insert(modelFavorite, in: viewContext)

        let modelSubscription = MyTBASubscription(modelKey: modelMatch.key, modelType: .match, notifications: [.matchScore])
        let subscription = Subscription.insert(modelSubscription, in: viewContext)

        XCTAssertNoThrow(try viewContext.save())

        // Delete Subscription - Match should not be deleted
        viewContext.delete(subscription)
        XCTAssertNoThrow(try viewContext.save())

        XCTAssertNotNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(subscription.managedObjectContext)
        XCTAssertNotNil(favorite.managedObjectContext)

        // Delete Favorite - Match should be deleted
        viewContext.delete(favorite)
        XCTAssertNoThrow(try viewContext.save())

        XCTAssertNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(favorite.managedObjectContext)
    }

    func test_prepareForDeletion_match_event() {
        let event = coreDataTestFixture.insertDistrictEvent()

        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let modelMatch = TBAMatch(key: "2018miket_sf2m3",
                                  compLevel: "sf",
                                  setNumber: 2,
                                  matchNumber: 3,
                                  alliances: ["red": redAlliance, "blue": blueAlliance],
                                  winningAlliance: "blue",
                                  eventKey: "2018miket",
                                  time: 1520109780,
                                  actualTime: 1520090745,
                                  predictedTime: 1520109780,
                                  postResultTime: 1520090929,
                                  breakdown: ["red": [:], "blue": [:]],
                                  videos: [])
        event.insert(modelMatch)
        let match = event.matches!.anyObject() as! Match

        let modelFavorite = MyTBAFavorite(modelKey: modelMatch.key, modelType: .match)
        let favorite = Favorite.insert(modelFavorite, in: viewContext)

        XCTAssertNoThrow(try viewContext.save())

        // Delete Favorite - Match should not be deleted (still attached to an Event)
        viewContext.delete(favorite)
        XCTAssertNoThrow(try viewContext.save())

        XCTAssertNotNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(favorite.managedObjectContext)
    }

}
