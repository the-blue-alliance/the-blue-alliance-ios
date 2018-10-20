import XCTest
@testable import The_Blue_Alliance

class MatchVideo_TestCase: CoreDataTestCase {

    var video: MatchVideo!

    override func setUp() {
        super.setUp()

        video = MatchVideo.init(entity: MatchVideo.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        video = nil

        super.tearDown()
    }

    func test_youtubeKey() {
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
