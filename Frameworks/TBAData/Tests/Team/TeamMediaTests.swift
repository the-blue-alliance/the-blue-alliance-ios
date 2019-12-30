////import TBAData
//import TBADataTesting
//import TBAKit
//import XCTest
//
//class TeamMediaTestCase: TBADataTestCase {
//
//    func test_insert() {
//        let model = TBAMedia(key: "key", type: "youtube", foreignKey: "foreign_key", details: ["detail": "here"], preferred: true)
//        let media = TeamMedia.insert(model, year: 2010, in: persistentContainer.viewContext)
//
//        XCTAssertEqual(media.key, "key")
//        XCTAssertEqual(media.type, "youtube")
//        XCTAssertEqual(media.foreignKey, "foreign_key")
//        XCTAssertEqual(media.details as! [String: String], ["detail": "here"])
//        XCTAssertEqual(media.preferred, true)
//
//        // Team Media needs to be related to a Team
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//
//        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
//        let team = Team.insert(teamModel, in: persistentContainer.viewContext)
//        team.addToMedia(media)
//
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//    }
//
//    func test_update_key() {
//        let modelOne = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: ["detail": "here"], preferred: true)
//        let mediaOne = TeamMedia.insert(modelOne, year: 2010, in: persistentContainer.viewContext)
//
//        let modelTwo = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
//        let mediaTwo = TeamMedia.insert(modelTwo, year: 2010, in: persistentContainer.viewContext)
//
//        // Sanity check
//        XCTAssertEqual(mediaOne, mediaTwo)
//
//        // Ensure our model got updated properly
//        XCTAssertNil(mediaOne.details)
//        XCTAssertFalse(mediaOne.preferred)
//    }
//
//    func test_update_foreignKey() {
//        let modelOne = TBAMedia(key: nil, type: "youtube", foreignKey: "foreign_key", details: ["detail": "here"], preferred: true)
//        let mediaOne = TeamMedia.insert(modelOne, year: 2010, in: persistentContainer.viewContext)
//
//        let modelTwo = TBAMedia(key: nil, type: "youtube", foreignKey: "foreign_key", details: nil, preferred: false)
//        let mediaTwo = TeamMedia.insert(modelTwo, year: 2010, in: persistentContainer.viewContext)
//
//        // Sanity check
//        XCTAssertEqual(mediaOne, mediaTwo)
//
//        // Ensure our model got updated properly
//        XCTAssertNil(mediaOne.details)
//        XCTAssertFalse(mediaOne.preferred)
//    }
//
//    func test_delete() {
//        let model = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: nil)
//        let media = TeamMedia.insert(model, year: 2010, in: persistentContainer.viewContext)
//
//        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
//        let team = Team.insert(teamModel, in: persistentContainer.viewContext)
//        team.addToMedia(media)
//
//        // Sanity check
//        XCTAssertEqual(team.media!.count, 1)
//
//        persistentContainer.viewContext.delete(media)
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//
//        // Make sure our Team updated it's relationship properly
//        XCTAssertEqual(team.media!.count, 0)
//
//        // Our Team shouldn't be deleted
//        XCTAssertNotNil(team.managedObjectContext)
//    }
//
//    func test_isOrphaned() {
//        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
//        XCTAssert(media.isOrphaned)
//
//        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
//        team.addToMedia(media)
//        XCTAssertFalse(media.isOrphaned)
//
//        team.removeFromMedia(media)
//        XCTAssert(media.isOrphaned)
//    }
//
//    func test_image() {
//        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
//        let image = UIImage(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAIAAAADnC86AAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKKADAAQAAAABAAAAKAAAAAB65masAAAAHGlET1QAAAACAAAAAAAAABQAAAAoAAAAFAAAABQAAAD0gcgdnQAAAMBJREFUWAnsU8sOgzAMs5B24f+/ktOmTdwGM7UWZW1BUyjTDkRRFfKwg6HAaX+mwAWQz0Dmyh+17wRs+yHE25S+2pLe434ZN6A3pgfQJ7WHhKq8YtGwyh46Szx3mWclkIiFqFKJrp61atlfz2g+sH54cNljz3B8Nj6ZtNP3FkhdzLUsZwIKZ2gncSZI9ZE6N5E6AhKZcS/RtVjd4f0g1D+p8wncgHs6r+8r7huqcVAz3kWzEtdK4+censwjWL8FLwAAAP//3Xi2hgAAAMtJREFU7VRBDsIwDAsSJ/7/QM5c4YwwqpJZ7jqZbtxWVVob23HSqY0YjFfEJaF3hMxENA5VG9DWOmPe9xFxS6a4YltDoGcBEcgwOcpAslcceQW6pxVzMmZ/S4zWcW5t9n0UxGdbWtuNiHvEe7TfFus3Uz3Wkru3BEKa08+pxPrnW3GMa6sCua5az/r+SFc4+Ol85nrhEvXT+UyxGG6d6+FwhgYjwEnqcEb5t+L9m8XsbZSZM2v01P9FBP/VK9eItwzePBk91+cJLCfwAQWF2v1LrRd3AAAAAElFTkSuQmCC")!)
//
//        XCTAssertNil(media.image)
//
//        media.image = image
//        XCTAssertNotNil(media.image?.pngData())
//        XCTAssertEqual(image?.pngData(), media.image?.pngData())
//
//        media.image = nil
//        XCTAssertNil(media.image)
//    }
//
//    func test_imageError() {
//        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
//        let error = MediaError.error("Some media error")
//
//        XCTAssertNil(media.mediaError)
//
//        media.mediaError = error
//        XCTAssertNotNil(media.mediaError?.localizedDescription)
//        XCTAssertEqual(error.localizedDescription, media.mediaError?.localizedDescription)
//
//        media.mediaError = nil
//        XCTAssertNil(media.mediaError)
//    }
//
//    func test_youtubeKey() {
//        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
//        let foreignKey = "foreign_key"
//        media.foreignKey = foreignKey
//
//        XCTAssertNil(media.youtubeKey)
//
//        media.type = MediaType.youtubeVideo.rawValue
//        XCTAssertNotNil(media.youtubeKey)
//        XCTAssertEqual(media.youtubeKey, foreignKey)
//    }
//
//    func test_imageDirectURL() {
//        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
//
//        // No type - nil
//        XCTAssertNil(media.imageDirectURL)
//
//        // cdPhotoThread
//        media.directURL = "http://www.chiefdelphi.com/media/img/test_m"
//        XCTAssertEqual(media.imageDirectURL?.absoluteString, "http://www.chiefdelphi.com/media/img/test_m")
//    }
//
//}
