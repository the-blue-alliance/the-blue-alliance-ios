import XCTest
@testable import The_Blue_Alliance

class TeamMediaTestCase: CoreDataTestCase {

    var media: TeamMedia!

    override func setUp() {
        super.setUp()

        media = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        media = nil

        super.tearDown()
    }

    func test_image() {
        let image = UIImage(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAIAAAADnC86AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwQAADsEBuJFr7QAAABl0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMC4yMfEgaZUAAAEYSURBVFhH7ZVLD8IgEIRXoxf//w/07Emj8eZj2qkbHraFhaoxfJkYspQZNlgqjV9j+9IjEutLcZ/TIgQZE6pJYJ2iCqjXRWTXDw5OnWOCWTwD8eEi6K5GDCasx/CZsdlUuN6wffPCjpLF9rUlqYDnTZM8SlKVFpwCUqsEW0wKg9c1tv5ZeELUTeQkcu5/j/7UhIwd411UAkdIufp1N8x1yAAWq2HoWVNKUNdgrDV2jC+Pbjlwh5SgjuNQ3G9XHjAirjWlBPX9UO7GdnQx714q7kOnIKVOsIGiYHRg/Gf63VuwrS9NJbkudVIJvDbDcIaaqSDd7l+CQcrrUfQKjfG1YDB999pv5hTQU3yKKC7Vq4t7b1ONxjtEngWF2v3/EmI7AAAAAElFTkSuQmCC")!)

        XCTAssertNil(media.image)

        media.image = image
        XCTAssertNotNil(media.image?.pngData())
        XCTAssertEqual(image?.pngData(), media.image?.pngData())

        media.image = nil
        XCTAssertNil(media.image)
    }

    func test_imageError() {
        let error = MediaError.error("Some media error")

        XCTAssertNil(media.mediaError)

        media.mediaError = error
        XCTAssertNotNil(media.mediaError?.localizedDescription)
        XCTAssertEqual(error.localizedDescription, media.mediaError?.localizedDescription)

        media.mediaError = nil
        XCTAssertNil(media.mediaError)
    }

    func test_youtubeKey() {
        let foreignKey = "foreign_key"
        media.foreignKey = foreignKey

        XCTAssertNil(media.youtubeKey)

        media.type = MediaType.youtubeVideo.rawValue
        XCTAssertNotNil(media.youtubeKey)
        XCTAssertEqual(media.youtubeKey, foreignKey)
    }

    func test_imageTypes_hasURL() {
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
