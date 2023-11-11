import CoreData
import MyTBAKit
import TBAKit
import XCTest
@testable import TBAData

class MyTBAEntityTestCase: TBADataTestCase {

    func test_modelKey() {
        let entity = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        entity.modelKeyRaw = "2018miket"
        XCTAssertEqual(entity.modelKey, "2018miket")
    }

    func test_modelType() {
        let entity = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)

        entity.modelTypeRaw = NSNumber(value: 1)
        XCTAssertEqual(entity.modelType, .team)

        entity.modelTypeRaw = NSNumber(value: MyTBAModelType.match.rawValue)
        XCTAssertEqual(entity.modelTypeRaw, 2)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MyTBAEntity> = MyTBAEntity.fetchRequest()
        XCTAssertEqual(fr.entityName, MyTBAEntity.entityName)
    }

    func test_supportedModelTypePredicate() {
        let predicate = MyTBAEntity.supportedModelTypePredicate()
        XCTAssertEqual(predicate.predicateFormat, "modelTypeRaw IN {0, 1, 2}")

        let one = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        one.modelTypeRaw = NSNumber(value: 0)
        let two = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        two.modelTypeRaw = NSNumber(value: 1)
        let three = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        three.modelTypeRaw = NSNumber(value: 2)
        let four = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        four.modelTypeRaw = NSNumber(value: 3)

        let results = MyTBAEntity.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results.count, 3)
        XCTAssertFalse(results.contains(four))
    }

    func test_sortDescriptors() {
        let sds = MyTBAEntity.sortDescriptors()
        XCTAssert(sds.reduce(true, { $0 && $1.ascending }))
        XCTAssert(sds.contains(where: { $0.key == #keyPath(MyTBAEntity.modelTypeRaw) }))
        XCTAssert(sds.contains(where: { $0.key == #keyPath(MyTBAEntity.modelKeyRaw) }))
    }

    func test_modelTypeKeyPath() {
        let kp = MyTBAEntity.modelTypeKeyPath()
        XCTAssertEqual(kp, #keyPath(MyTBAEntity.modelTypeRaw))
    }

    func test_modelKeyPredicate() {
        let predicate = MyTBAEntity.modelKeyPredicate(key: "frc7332")
        XCTAssertEqual(predicate.predicateFormat, "modelKeyRaw == \"frc7332\"")

        let model = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)
        model.modelKeyRaw = "frc7332"
        _ = MyTBAEntity.init(entity: MyTBAEntity.entity(), insertInto: persistentContainer.viewContext)

        let results = MyTBAEntity.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [model])
    }

    func test_tbaObject_event() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "2018miket", modelType: .event), in: persistentContainer.viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = insertDistrictEvent()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_tbaObject_team() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "frc7332", modelType: .team), in: persistentContainer.viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = insertTeam()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_tbaObject_match() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), in: persistentContainer.viewContext)
        XCTAssertNil(favorite.tbaObject)

        _ = insertMatch()
        XCTAssertNotNil(favorite.tbaObject)
    }

    func test_tbaObject_other() {
        let favorite = Favorite.insert(MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .eventTeam), in: persistentContainer.viewContext)
        XCTAssertNil(favorite.tbaObject)
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
        let match = Match.insert(modelMatch, in: persistentContainer.viewContext)

        let modelFavorite = MyTBAFavorite(modelKey: modelMatch.key, modelType: .match)
        let favorite = Favorite.insert(modelFavorite, in: persistentContainer.viewContext)

        let modelSubscription = MyTBASubscription(modelKey: modelMatch.key, modelType: .match, notifications: [.matchScore])
        let subscription = Subscription.insert(modelSubscription, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Delete Subscription - Match should not be deleted
        persistentContainer.viewContext.delete(subscription)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNotNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(subscription.managedObjectContext)
        XCTAssertNotNil(favorite.managedObjectContext)

        // Delete Favorite (and Event) - Match should be deleted
        persistentContainer.viewContext.delete(favorite)
        persistentContainer.viewContext.delete(match.event)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(favorite.managedObjectContext)
    }

    func test_prepareForDeletion_match_event() {
        let event = insertDistrictEvent()

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
        event.insert([modelMatch])
        let match = event.matches.first!

        let modelFavorite = MyTBAFavorite(modelKey: modelMatch.key, modelType: .match)
        let favorite = Favorite.insert(modelFavorite, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Delete Favorite - Match should not be deleted (still attached to an Event)
        persistentContainer.viewContext.delete(favorite)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNotNil(match.managedObjectContext)

        // Sanity check
        XCTAssertNil(favorite.managedObjectContext)
    }

}
