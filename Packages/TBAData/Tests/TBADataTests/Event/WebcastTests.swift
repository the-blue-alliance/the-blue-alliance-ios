import CoreData
import TBAKit
import XCTest
@testable import TBAData

class WebcastTestCase: TBADataTestCase {

    func test_channel() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        webcast.channelRaw = "channel"
        XCTAssertEqual(webcast.channel, "channel")
    }

    func test_file() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(webcast.file)
        webcast.fileRaw = "file"
        XCTAssertEqual(webcast.file, "file")
    }

    func test_type() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        webcast.typeRaw = "type"
        XCTAssertEqual(webcast.type, "type")
    }

    func test_events() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(webcast.events, [])
        let event = insertEvent()
        webcast.eventsRaw = NSSet(array: [event])
        XCTAssertEqual(webcast.events, [event])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Webcast> = Webcast.fetchRequest()
        XCTAssertEqual(fr.entityName, Webcast.entityName)
    }

    func test_insert() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor")
        let webcast = Webcast.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(webcast.type, "twitch")
        XCTAssertEqual(webcast.channel, "firstinmichigan")
        XCTAssertEqual(webcast.file, "filezor")

        // Should fail - Webcasts need to be associated with at least one Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let event = insertDistrictEvent()
        event.addToWebcastsRaw(webcast)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcastOne = Webcast.insert(modelOne, in: persistentContainer.viewContext)

        let modelTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan", file: "filezor")
        let webcastTwo = Webcast.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(webcastOne, webcastTwo)

        // Ensure our values got updated properly
        XCTAssertEqual(webcastOne.file, "filezor")
    }

    func test_delete() {
        let model = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let webcast = Webcast.insert(model, in: persistentContainer.viewContext)

        let event = insertDistrictEvent()
        event.addToWebcastsRaw(webcast)

        persistentContainer.viewContext.delete(webcast)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(event.webcasts.count, 0)

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

        let eventOne = insertDistrictEvent()
        eventOne.addToWebcastsRaw(Set([webcastOne, webcastTwo]) as NSSet)

        let eventTwo = insertDistrictEvent(eventKey: "2018mike2")
        eventTwo.addToWebcastsRaw(webcastTwo)

        persistentContainer.viewContext.delete(eventOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our models handled their relationships properly
        XCTAssertEqual(eventTwo.webcasts.count, 1)
        XCTAssertEqual(webcastTwo.events.count, 1)

        // Webcast One should be deleted
        XCTAssertNil(webcastOne.managedObjectContext)

        // Webcast Two should not be deleted
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let webcast = Webcast.init(entity: Webcast.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(webcast.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToWebcastsRaw(webcast)
        // Attached to Event - should not be orphaned
        XCTAssertFalse(webcast.isOrphaned)

        event.removeFromWebcastsRaw(webcast)
        // Not attached to Event - should be orphaned
        XCTAssert(webcast.isOrphaned)
    }

}
