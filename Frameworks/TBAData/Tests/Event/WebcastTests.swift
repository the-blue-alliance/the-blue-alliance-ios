import TBAData
import TBAKit
import XCTest

class WebcastTestCase: TBADataTestCase {

    func test_insert() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor")
        let webcast = Webcast.insert(model, in: viewContext)

        XCTAssertEqual(webcast.type, "twitch")
        XCTAssertEqual(webcast.channel, "firstinmichigan")
        XCTAssertEqual(webcast.file, "filezor")

        // Should fail - Webcasts need to be associated with at least one Event
        XCTAssertThrowsError(try viewContext.save())

        let event = coreDataTestFixture.insertDistrictEvent()
        event.addToWebcasts(webcast)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_update() {
        let modelOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcastOne = Webcast.insert(modelOne, in: viewContext)

        let modelTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor")
        let webcastTwo = Webcast.insert(modelTwo, in: viewContext)

        // Sanity check
        XCTAssertEqual(webcastOne, webcastTwo)

        // Ensure our values got updated properly
        XCTAssertEqual(webcastOne.file, "filezor")
    }

    func test_delete() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcast = Webcast.insert(model, in: viewContext)

        let event = coreDataTestFixture.insertDistrictEvent()
        event.addToWebcasts(webcast)

        viewContext.delete(webcast)
        XCTAssertNoThrow(try viewContext.save())

        XCTAssertEqual(event.webcasts?.count, 0)

        // Webcast should be deleted, Event should not
        XCTAssertNil(webcast.managedObjectContext)
        XCTAssertNotNil(event.managedObjectContext)
    }

    func test_delete_event() {
        let modelOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let modelTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan2")
        let webcastOne = Webcast.insert(modelOne, in: viewContext)
        let webcastTwo = Webcast.insert(modelTwo, in: viewContext)

        // Sanity check
        XCTAssertNotEqual(webcastOne, webcastTwo)

        let eventOne = coreDataTestFixture.insertDistrictEvent()
        eventOne.addToWebcasts(Set([webcastOne, webcastTwo]) as NSSet)

        let eventTwo = coreDataTestFixture.insertDistrictEvent(eventKey: "2018mike2")
        eventTwo.addToWebcasts(webcastTwo)

        viewContext.delete(eventOne)
        XCTAssertNoThrow(try viewContext.save())

        // Ensure our models handled their relationships properly
        XCTAssertEqual(eventTwo.webcasts?.count, 1)
        XCTAssertEqual(webcastTwo.events?.count, 1)

        // Webcast One should be deleted
        XCTAssertNil(webcastOne.managedObjectContext)

        // Webcast Two should not be deleted
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: viewContext)
        XCTAssert(webcast.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: viewContext)
        event.addToWebcasts(webcast)
        // Attached to Event - should not be orphaned
        XCTAssertFalse(webcast.isOrphaned)

        event.removeFromWebcasts(webcast)
        // Not attached to Event - should be orphaned
        XCTAssert(webcast.isOrphaned)
    }

}