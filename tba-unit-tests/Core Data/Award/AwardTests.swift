import XCTest
@testable import TBA

class AwardTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [modelAwardRecipient],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)

        XCTAssertEqual(award.name, "The Fake Award")
        XCTAssertEqual(award.awardType, 2)
        XCTAssertEqual(award.year, 2018)
        XCTAssertEqual(award.recipients?.count, 1)

        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        // Award shouldn't be able to be saved without an Event
        event.addToAwards(award)
        XCTAssertNotNil(award.event)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_validate() {
        let event = insertDistrictEvent()

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        event.addToAwards(award)

        // Our Award shouldn't be able to be saved without an Award Recipient
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let awardRecipient = AwardRecipient.insert(modelAwardRecipient, in: persistentContainer.viewContext)
        award.addToRecipients(awardRecipient)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")
        let frc3Model = TBAAwardRecipient(teamKey: "frc3")

        let modelOne = TBAAward(name: "The Fake Award",
                                awardType: 2,
                                eventKey: event.key!,
                                recipients: [frc1Model, frc2Model, frc3Model],
                                year: 2018)
        let awardOne = Award.insert(modelOne, in: persistentContainer.viewContext)
        let recipients = awardOne.recipients!.allObjects as! [AwardRecipient]
        event.addToAwards(awardOne)

        let frc1 = recipients.first(where: { $0.teamKey?.key == "frc1" })!
        let frc2 = recipients.first(where: { $0.teamKey?.key == "frc2" })!
        let frc3 = recipients.first(where: { $0.teamKey?.key == "frc3" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelTwo = TBAAward(name: "Some New Award",
                                awardType: 3,
                                eventKey: event.key!,
                                recipients: [frc1Model],
                                year: 2018)
        let awardTwo = Award.insert(modelTwo, in: persistentContainer.viewContext)
        event.addToAwards(awardTwo)

        XCTAssertNotEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelThree = TBAAward(name: "The Duplicate Award",
                                  awardType: awardOne.awardType!.intValue,
                                  eventKey: event.key!,
                                  recipients: [frc2Model],
                                  year: awardOne.year!.intValue)
        let awardThree = Award.insert(modelThree, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(awardOne, awardThree)

        // Check that the award updates it's values properly
        XCTAssertEqual(awardOne.name, "The Duplicate Award")
        XCTAssertEqual(awardOne.recipients?.count, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check our Award's recipients look right
        XCTAssert(awardOne.recipients!.onlyObject(frc2))
        XCTAssert(awardTwo.recipients!.onlyObject(frc1))

        // frc1 and frc2 AwardRecipients should not be deleted - they're not orphans
        XCTAssertNotNil(frc1.managedObjectContext)
        XCTAssertNotNil(frc2.managedObjectContext)

        // frc3 AwardRecipient should be deleted - it's an orphan
        XCTAssertNil(frc3.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")

        let modelAwardOne = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [frc1Model, frc2Model],
                                  year: 2018)
        let awardOne = Award.insert(modelAwardOne, in: persistentContainer.viewContext)
        let recipients = awardOne.recipients!.allObjects as! [AwardRecipient]

        event.addToAwards(awardOne)

        let frc1 = recipients.first(where: { $0.teamKey?.key == "frc1" })!
        let frc2 = recipients.first(where: { $0.teamKey?.key == "frc2" })!

        let modelAwardTwo = TBAAward(name: "Some New Award",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc2Model],
                                     year: 2018)
        let awardTwo = Award.insert(modelAwardTwo, in: persistentContainer.viewContext)
        event.addToAwards(awardTwo)

        persistentContainer.viewContext.delete(awardOne)
        // Save should work fine - since Award propogates deletion of Award Recipients
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Event updated it's relationship properly
        XCTAssertEqual(event.awards?.count, 1)

        // Make sure our Awards look right
        XCTAssertNil(awardOne.managedObjectContext)
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Make sure our Award Recipients got deleted properly
        XCTAssert(awardTwo.recipients!.onlyObject(frc2))

        XCTAssertNil(frc1.managedObjectContext)
        XCTAssertNotNil(frc2.managedObjectContext)
    }

    func test_isOrphaned() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        // No Event - should be orphaned
        XCTAssert(award.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToAwards(award)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(award.isOrphaned)

        event.removeFromAwards(award)
        // Removed from an Event - should be orphaned
        XCTAssert(award.isOrphaned)
    }

}
