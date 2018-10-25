import TBAKit
import XCTest
@testable import The_Blue_Alliance

class MatchVideoTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: event.key!)

        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.typeString, "youtube")

        // Should fail - needs to be related to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let match = Match.insert(matchModel, event: event, in: persistentContainer.viewContext)
        match.addToVideos(video)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_multiple() {
        let event = districtEvent()
        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        let matchModelOne = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: event.key!)
        let matchModelTwo = TBAMatch(key: "2018miket_f1m2", compLevel: "f", setNumber: 1, matchNumber: 2, eventKey: event.key!)
        let matchOne = Match.insert(matchModelOne, event: event, in: persistentContainer.viewContext)
        let matchTwo = Match.insert(matchModelTwo, event: event, in: persistentContainer.viewContext)
        matchOne.addToVideos(video)
        matchTwo.addToVideos(video)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(video.matches?.count, 2)
    }

    func test_delete() {
        let event = districtEvent()

        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: persistentContainer.viewContext)

        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: event.key!)
        let match = Match.insert(matchModel, event: event, in: persistentContainer.viewContext)
        match.addToVideos(video)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.typeString, "youtube")

        persistentContainer.viewContext.delete(video)
        // Should fail - cannot delete if it's attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        match.removeFromVideos(video)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_youtubeKey() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)

        let youtubeKey = "test_youtubeKey"
        video.key = youtubeKey

        // No type - no youtubeKey
        XCTAssertNil(video.youtubeKey)

        // Wrong type - no youtubeKey
        video.typeString = MatchVideoType.tba.rawValue
        XCTAssertNil(video.youtubeKey)

        // Right type - should have key
        video.typeString = MatchVideoType.youtube.rawValue
        XCTAssertEqual(video.youtubeKey, youtubeKey)
    }

}
