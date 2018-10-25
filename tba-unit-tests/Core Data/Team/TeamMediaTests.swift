import TBAKit
import XCTest
@testable import The_Blue_Alliance

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

    func test_insert_team_orphans() {
        let teamModel = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(teamModel, in: persistentContainer.viewContext)

        let modelOne = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        let modelTwo = TBAMedia(key: "key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        TeamMedia.insert([modelOne], team: team, year: 2010, in: persistentContainer.viewContext)
        TeamMedia.insert([modelTwo], team: team, year: 2011, in: persistentContainer.viewContext)
        let mediaOne = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.year == 2010 })!
        let mediaTwo = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.year == 2011 })!

        // Sanity check
        XCTAssertNotEqual(mediaOne, mediaTwo)

        let modelThree = TBAMedia(key: "new_key", type: "youtube", foreignKey: nil, details: nil, preferred: false)
        TeamMedia.insert([modelThree], team: team, year: 2010, in: persistentContainer.viewContext)
        let mediaThree = (team.media!.allObjects as! [TeamMedia]).first(where: { $0.key == "new_key" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that our Team manged it's Media properly
        XCTAssertEqual(team.media?.count, 2)

        // Check that our Media One was deleted (since it was an orphan)
        XCTAssertNil(mediaOne.managedObjectContext)

        // Check that Media Two and Media Three weren't deleted, since they're not orphans
        XCTAssertNotNil(mediaTwo.managedObjectContext)
        XCTAssertNotNil(mediaThree.managedObjectContext)
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

    func test_imageTypes_hasURL() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        media.foreignKey = "foreign_key"
        // Setup details so we can get images
        media.details = [
            "image_partial": "test",
            "model_image": "test"
        ]

        for imageType in MediaType.imageTypes {
            media.type = imageType
            XCTAssertNotNil(media.viewImageURL)
            XCTAssertNotNil(media.imageDirectURL)
        }
    }

    func test_viewImageURL() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        media.foreignKey = "foreign_key"

        // No type - nil
        XCTAssertNil(media.viewImageURL)

        // cdPhotoThread
        media.type = MediaType.cdPhotoThread.rawValue
        XCTAssertEqual(media.viewImageURL?.absoluteString, "http://www.chiefdelphi.com/media/photos/foreign_key")

        // imgur
        media.type = MediaType.imgur.rawValue
        XCTAssertEqual(media.viewImageURL?.absoluteString, "https://imgur.com/foreign_key")

        // instagramImage
        media.type = MediaType.instagramImage.rawValue
        XCTAssertEqual(media.viewImageURL?.absoluteString, "https://www.instagram.com/p/foreign_key")

        // grabcad
        media.type = MediaType.grabcad.rawValue
        XCTAssertEqual(media.viewImageURL?.absoluteString, "https://grabcad.com/library/foreign_key")
    }

    func test_imageDirectURL() {
        let media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        media.foreignKey = "foreign_key"

        // No type - nil
        XCTAssertNil(media.viewImageURL)

        // cdPhotoThread
        media.type = MediaType.cdPhotoThread.rawValue
        media.details = [
            "image_partial": "test_l"
        ]
        XCTAssertEqual(media.imageDirectURL?.absoluteString, "http://www.chiefdelphi.com/media/img/test_m")

        // imgur
        media.type = MediaType.imgur.rawValue
        media.details = nil
        XCTAssertEqual(media.imageDirectURL?.absoluteString, "https://i.imgur.com/foreign_keyh.jpg")

        // instagramImage
        media.type = MediaType.instagramImage.rawValue
        media.details = nil
        XCTAssertEqual(media.imageDirectURL?.absoluteString, "https://www.instagram.com/p/foreign_key/media/?size=l")

        // grabcad
        media.type = MediaType.grabcad.rawValue
        media.details = [
            "model_image": "https://test.test.net/screenshots/pics/2850f4cfb0ca7a196d00e100c6bdd91b/card.jpg"
        ]
        XCTAssertEqual(media.imageDirectURL?.absoluteString, "https://test.test.net/screenshots/pics/2850f4cfb0ca7a196d00e100c6bdd91b/large.png")
    }

}
