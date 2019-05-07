import TBAData
import TBAKit
import XCTest

class MatchVideoTestCase: TBADataTestCase {

    func test_insert() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: viewContext)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.typeString, "youtube")

        // Should fail - needs to be related to a Match
        XCTAssertThrowsError(try viewContext.save())

        let match = Match.insert(matchModel, in: viewContext)
        match.addToVideos(video)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insert_multiple() {
        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: viewContext)

        let matchModelOne = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")
        let matchModelTwo = TBAMatch(key: "2018miket_f1m2", compLevel: "f", setNumber: 1, matchNumber: 2, eventKey: "2018miket")
        let matchOne = Match.insert(matchModelOne, in: viewContext)
        let matchTwo = Match.insert(matchModelTwo, in: viewContext)
        matchOne.addToVideos(video)
        matchTwo.addToVideos(video)

        XCTAssertNoThrow(try viewContext.save())

        XCTAssertEqual(video.matches?.count, 2)
    }

    func test_delete() {
        let model = TBAMatchVideo(key: "key", type: "youtube")
        let video = MatchVideo.insert(model, in: viewContext)

        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")
        let match = Match.insert(matchModel, in: viewContext)
        match.addToVideos(video)

        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.typeString, "youtube")

        viewContext.delete(video)
        // Should fail - cannot delete if it's attached to a Match
        XCTAssertThrowsError(try viewContext.save())

        match.removeFromVideos(video)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_youtubeKey() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: viewContext)

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

    func test_isOrphaned() {
        let video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: viewContext)
        XCTAssert(video.isOrphaned)

        let match = Match.init(entity: Match.entity(), insertInto: viewContext)
        match.addToVideos(video)
        XCTAssertFalse(video.isOrphaned)

        match.removeFromVideos(video)
        XCTAssert(video.isOrphaned)
    }

}
