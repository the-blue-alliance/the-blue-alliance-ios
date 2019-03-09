import XCTest
@testable import TBA

class TeamMediaTestCase: CoreDataTestCase {

    func test_insert() {
        let model = TBAMedia(key: "key", type: "youtube", foreignKey: "foreign_key", details: ["detail": "here"], preferred: true)
        let media = TeamMedia.insert(model, year: 2010, in: persistentContainer.viewContext)

        XCTAssertEqual(media.key, "key")
        XCTAssertEqual(media.type, "youtube")
        XCTAssertEqual(media.foreignKey, "foreign_key")
        XCTAssertEqual(media.details as! [String: String], ["detail": "here"])
        XCTAssertEqual(media.preferred, true)

        // Team Media needs to be related to a Team
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)
        team.addToMedia(media)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update_key() {
        let modelOne = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: ["detail": "here"], preferred: true)
        let mediaOne = TeamMedia.insert(modelOne, year: 2010, in: persistentContainer.viewContext)

        let modelTwo = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        let mediaTwo = TeamMedia.insert(modelTwo, year: 2010, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(mediaOne, mediaTwo)

        // Ensure our model got updated properly
        XCTAssertNil(mediaOne.details)
        XCTAssertFalse(mediaOne.preferred)
    }

    func test_update_foreignKey() {
        let modelOne = TBAMedia(key: nil, type: "youtube", foreignKey: "foreign_key", details: ["detail": "here"], preferred: true)
        let mediaOne = TeamMedia.insert(modelOne, year: 2010, in: persistentContainer.viewContext)

        let modelTwo = TBAMedia(key: nil, type: "youtube", foreignKey: "foreign_key", details: nil, preferred: false)
        let mediaTwo = TeamMedia.insert(modelTwo, year: 2010, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(mediaOne, mediaTwo)

        // Ensure our model got updated properly
        XCTAssertNil(mediaOne.details)
        XCTAssertFalse(mediaOne.preferred)
    }

    func test_delete() {
        let model = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: nil)
        let media = TeamMedia.insert(model, year: 2010, in: persistentContainer.viewContext)

        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)
        team.addToMedia(media)

        // Sanity check
        XCTAssertEqual(team.media!.count, 1)

        persistentContainer.viewContext.delete(media)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Team updated it's relationship properly
        XCTAssertEqual(team.media!.count, 0)

        // Our Team shouldn't be deleted
        XCTAssertNotNil(team.managedObjectContext)
    }

    func test_isOrphaned() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(media.isOrphaned)

        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.addToMedia(media)
        XCTAssertFalse(media.isOrphaned)

        team.removeFromMedia(media)
        XCTAssert(media.isOrphaned)
    }

    func test_image() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        let image = UIImage(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAIAAAADnC86AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwQAADsEBuJFr7QAAABl0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMC4yMfEgaZUAAAEYSURBVFhH7ZVLD8IgEIRXoxf//w/07Emj8eZj2qkbHraFhaoxfJkYspQZNlgqjV9j+9IjEutLcZ/TIgQZE6pJYJ2iCqjXRWTXDw5OnWOCWTwD8eEi6K5GDCasx/CZsdlUuN6wffPCjpLF9rUlqYDnTZM8SlKVFpwCUqsEW0wKg9c1tv5ZeELUTeQkcu5/j/7UhIwd411UAkdIufp1N8x1yAAWq2HoWVNKUNdgrDV2jC+Pbjlwh5SgjuNQ3G9XHjAirjWlBPX9UO7GdnQx714q7kOnIKVOsIGiYHRg/Gf63VuwrS9NJbkudVIJvDbDcIaaqSDd7l+CQcrrUfQKjfG1YDB999pv5hTQU3yKKC7Vq4t7b1ONxjtEngWF2v3/EmI7AAAAAElFTkSuQmCC")!)

        XCTAssertNil(media.image)

        media.image = image
        XCTAssertNotNil(media.image?.pngData())
        XCTAssertEqual(image?.pngData(), media.image?.pngData())

        media.image = nil
        XCTAssertNil(media.image)
    }

    func test_imageError() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        let error = MediaError.error("Some media error")

        XCTAssertNil(media.mediaError)

        media.mediaError = error
        XCTAssertNotNil(media.mediaError?.localizedDescription)
        XCTAssertEqual(error.localizedDescription, media.mediaError?.localizedDescription)

        media.mediaError = nil
        XCTAssertNil(media.mediaError)
    }

    func test_youtubeKey() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        let foreignKey = "foreign_key"
        media.foreignKey = foreignKey

        XCTAssertNil(media.youtubeKey)

        media.type = MediaType.youtubeVideo.rawValue
        XCTAssertNotNil(media.youtubeKey)
        XCTAssertEqual(media.youtubeKey, foreignKey)
    }

    func test_viewImageURL() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)

        // No url - nil
        XCTAssertNil(media.viewImageURL)

        // cdPhotoThread
        media.viewURL = "http://www.chiefdelphi.com/media/photos/foreign_key"
        XCTAssertEqual(media.viewImageURL?.absoluteString, "http://www.chiefdelphi.com/media/photos/foreign_key")
    }

    func test_imageDirectURL() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)

        // No type - nil
        XCTAssertNil(media.imageDirectURL)

        // cdPhotoThread
        media.directURL = "http://www.chiefdelphi.com/media/img/test_m"
        XCTAssertEqual(media.imageDirectURL?.absoluteString, "http://www.chiefdelphi.com/media/img/test_m")
    }

}
