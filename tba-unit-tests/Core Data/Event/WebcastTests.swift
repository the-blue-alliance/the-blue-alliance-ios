import TBAKit
import XCTest
@testable import The_Blue_Alliance

class WebcastTestCase: CoreDataTestCase {

    func test_insert() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor", date: nil)
        let webcast = Webcast.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(webcast.type, "twitch")
        XCTAssertEqual(webcast.channel, "firstinmichigan")
        XCTAssertEqual(webcast.file, "filezor")

        // Should fail - Webcasts need to be associated with at least one Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let event = districtEvent()
        event.addToWebcasts(webcast)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcastOne = Webcast.insert(modelOne, in: persistentContainer.viewContext)

        let modelTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor", date: nil)
        let webcastTwo = Webcast.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(webcastOne, webcastTwo)

        // Ensure our values got updated properly
        XCTAssertEqual(webcastOne.file, "filezor")
    }

    func test_delete() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcast = Webcast.insert(model, in: persistentContainer.viewContext)

        let event = districtEvent()
        event.addToWebcasts(webcast)

        // Webcast cannot be deleted when it is attached to an Event
        persistentContainer.viewContext.delete(webcast)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.removeFromWebcasts(webcast)
        persistentContainer.viewContext.delete(webcast)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(event.webcasts?.count, 0)

        // Webcast should be deleted, Event should not
        XCTAssertNil(webcast.managedObjectContext)
        XCTAssertNotNil(event.managedObjectContext)
    }

    func test_delete_event() {
        let modelOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let modelTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan2")
        let webcastOne = Webcast.insert(modelOne, in: persistentContainer.viewContext)
        let webcastTwo = Webcast.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertNotEqual(webcastOne, webcastTwo)

        let eventOne = districtEvent()
        eventOne.addToWebcasts(Set([webcastOne, webcastTwo]) as NSSet)

        let eventTwo = districtEvent(eventKey: "2018mike2")
        eventTwo.addToWebcasts(webcastTwo)

        persistentContainer.viewContext.delete(eventOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our models handled their relationships properly
        XCTAssertEqual(eventTwo.webcasts?.count, 1)
        XCTAssertEqual(webcastTwo.events?.count, 1)

        // Webcast One should be deleted
        XCTAssertNil(webcastOne.managedObjectContext)

        // Webcast Two should not be deleted
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

}
