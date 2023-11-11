import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchVideoTestCase: TBADataTestCase {

    func test_key() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
        video.keyRaw = "2018miket_f1m1"
        XCTAssertEqual(video.key, "2018miket_f1m1")
    }

    func test_type() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
        video.typeRaw = "youtube"
        XCTAssertEqual(video.type, .youtube)
    }

    func test_matches() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(video.matches, [])
        let match = insertMatch()
        video.matchesRaw = NSSet(array: [match])
        XCTAssertEqual(video.matches, [match])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MatchVideo> = MatchVideo.fetchRequest()
        XCTAssertEqual(fr.entityName, MatchVideo.entityName)
    }

    func test_insert() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.type, .youtube)

        // Should fail - needs to be related to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let match = Match.insert(matchModel, in: persistentContainer.viewContext)
        match.addToVideosRaw(video)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_multiple() {
        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        let matchModelOne = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")
        let matchModelTwo = TBAMatch(key: "2018miket_f1m2", compLevel: "f", setNumber: 1, matchNumber: 2, eventKey: "2018miket")
        let matchOne = Match.insert(matchModelOne, in: persistentContainer.viewContext)
        let matchTwo = Match.insert(matchModelTwo, in: persistentContainer.viewContext)
        matchOne.addToVideosRaw(video)
        matchTwo.addToVideosRaw(video)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(video.matches.count, 2)
    }

    func test_delete() {
        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")
        let match = Match.insert(matchModel, in: persistentContainer.viewContext)
        match.addToVideosRaw(video)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.type, .youtube)

        persistentContainer.viewContext.delete(video)
        // Should fail - cannot delete if it's attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        match.removeFromVideosRaw(video)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_youtubeKey() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)

        let youtubeKey = "test_youtubeKey"
        video.keyRaw = youtubeKey

        // Wrong type - no youtubeKey
        video.typeRaw = MatchVideoType.tba.rawValue
        XCTAssertNil(video.youtubeKey)

        // Right type - should have key
        video.typeRaw = MatchVideoType.youtube.rawValue
        XCTAssertEqual(video.youtubeKey, youtubeKey)
    }

    func test_isOrphaned() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(video.isOrphaned)

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.addToVideosRaw(video)
        XCTAssertFalse(video.isOrphaned)

        match.removeFromVideosRaw(video)
        XCTAssert(video.isOrphaned)
    }

}
