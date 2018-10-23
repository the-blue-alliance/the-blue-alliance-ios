import TBAKit
import XCTest
import CoreData
@testable import The_Blue_Alliance

class AwardTestCase: CoreDataTestCase {

    func award(event: Event) -> Award {
        let modelAward = self.modelAward(eventKey: event.key!)
        return Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
    }

    private func modelAward(eventKey: String) -> TBAAward {
        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: eventKey,
                                  recipients: [modelAwardRecipient],
                                  year: 2018)
        return modelAward
    }

    func test_insert() {
        let event = districtEvent()
        let award = self.award(event: event)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(award.name, "The Fake Award")
        XCTAssertEqual(award.awardType, 2)
        XCTAssertEqual(award.year, 2018)
        XCTAssertEqual(award.recipients?.count, 1)
        XCTAssertNotNil(award.event)
    }

    func test_update() {
        let event = districtEvent()
        let award = self.award(event: event)
        let recipients = award.recipients!.allObjects as! [AwardRecipient]

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelNewRecipient = TBAAwardRecipient(teamKey: "frc3333")
        let duplicateModelAward = TBAAward(name: "The Duplicate Award",
                                           awardType: award.awardType!.intValue,
                                           eventKey: award.event!.key!,
                                           recipients: [modelNewRecipient],
                                           year: award.year!.intValue)

        let duplicateAward = Award.insert([duplicateModelAward], event: event, in: persistentContainer.viewContext).first!

        // Sanity check
        XCTAssertEqual(award, duplicateAward)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check that the award updates it's values properly
        XCTAssertEqual(award.name, "The Duplicate Award")
        XCTAssertNotEqual(recipients, award.recipients!.allObjects as! [AwardRecipient])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update_orphans() {
        // When updating Awards for an Event, orphaned Award Recipients should be deleted
        let event = districtEvent()
        let awardOne = self.award(event: event)
        let frc7332 = awardOne.recipients!.allObjects.first! as! AwardRecipient

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let frc3333Model = TBAAwardRecipient(teamKey: "frc3333")
        let modelAward = TBAAward(name: "The Duplicate Award",
                                  awardType: awardOne.awardType!.intValue,
                                  eventKey: awardOne.event!.key!,
                                  recipients: [frc3333Model],
                                  year: awardOne.year!.intValue)
        let awardTwo = Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
        let frc3333 = awardTwo.recipients!.allObjects.first! as! AwardRecipient

        // Sanity check - Awards should be qual
        XCTAssertEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssertFalse(awardOne.recipients!.contains(frc7332))
        XCTAssert(awardOne.recipients!.contains(frc3333))

        // frc7332 should be deleted
        XCTAssertNil(frc7332.managedObjectContext)

        // frc3333 should not be deleted
        XCTAssertNotNil(frc3333.managedObjectContext)
    }

    func test_update_no_orphans() {
        // Given one Award with two Teams, a second Award with one Team from the first set,
        // and then an update to the first Award which removes the other team from the first set,
        // neither team should be deleted, since neither Team is an orphan - they both refer to at least one award
        let event = districtEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let frc7332Model = TBAAwardRecipient(teamKey: "frc7332")
        let frc3333Model = TBAAwardRecipient(teamKey: "frc3333")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key!,
                                     recipients: [frc7332Model, frc3333Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc3333Model],
                                     year: 2018)

        let awards = Award.insert([modelAwardOne, modelAwardTwo], event: event, in: persistentContainer.viewContext)
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let frc3333 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc3333" })!
        let frc7332 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc7332" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Update our first Award to only have one of the two recipients
        let modelAwardOneUpdated = TBAAward(name: "The Fake Award",
                                            awardType: 2,
                                            eventKey: event.key!,
                                            recipients: [frc7332Model],
                                            year: 2018)
        let awardOneUpdated = Award.insert([modelAwardOneUpdated, modelAwardTwo], event: event, in: persistentContainer.viewContext).first(where: { $0.awardType?.intValue == 2 })

        // Sanity check
        XCTAssertEqual(awardOne, awardOneUpdated)
        XCTAssertNotEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssert(awardOne.recipients!.contains(frc7332))
        XCTAssertFalse(awardOne.recipients!.contains(frc3333))
        XCTAssert(awardTwo.recipients!.contains(frc3333))
        XCTAssertFalse(awardTwo.recipients!.contains(frc7332))

        // Neither recipient should be deleted - they both refer to one award
        XCTAssertNotNil(frc7332.managedObjectContext)
        XCTAssertNotNil(frc3333.managedObjectContext)
    }

    func test_update_complexOrphans() {
        // Given one Award with two Teams, a second Award with one Team from the first set,
        // and then an update to the first Award to have the same Teams as the second Award,
        // the first Team shoul be deleted - since it's an orphan
        let event = districtEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let frc7332Model = TBAAwardRecipient(teamKey: "frc7332")
        let frc3333Model = TBAAwardRecipient(teamKey: "frc3333")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key!,
                                     recipients: [frc7332Model, frc3333Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc3333Model],
                                     year: 2018)

        let awards = Award.insert([modelAwardOne, modelAwardTwo], event: event, in: persistentContainer.viewContext)
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let frc3333 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc3333" })!
        let frc7332 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc7332" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Update our first Award to only have one of the two recipients
        let modelAwardOneUpdated = TBAAward(name: "The Fake Award",
                                            awardType: 2,
                                            eventKey: event.key!,
                                            recipients: [frc3333Model],
                                            year: 2018)
        let awardOneUpdated = Award.insert([modelAwardOneUpdated, modelAwardTwo], event: event, in: persistentContainer.viewContext).first(where: { $0.awardType?.intValue == 2 })!

        // Sanity check
        XCTAssertEqual(awardOne, awardOneUpdated)
        XCTAssertNotEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssertFalse(awardOne.recipients!.contains(frc7332))
        XCTAssert(awardOne.recipients!.contains(frc3333))
        XCTAssertFalse(awardTwo.recipients!.contains(frc7332))
        XCTAssert(awardTwo.recipients!.contains(frc3333))

        // frc7332 recipient should be deleted
        XCTAssertNil(frc7332.managedObjectContext)

        // frc3333 recipient should not be deleted
        XCTAssertNotNil(frc3333.managedObjectContext)
    }

    func test_insert_orphans() {
        // Orphaned Awards and their relationships should be cleaned up
        // We're going to assume this tests `insert` and `prepareForDeletion`
        let event = districtEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let frc7332Model = TBAAwardRecipient(teamKey: "frc7332")
        let frc3333Model = TBAAwardRecipient(teamKey: "frc3333")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key!,
                                     recipients: [frc7332Model, frc3333Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc3333Model],
                                     year: 2018)

        let awards = Award.insert([modelAwardOne, modelAwardTwo], event: event, in: persistentContainer.viewContext)
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let frc3333 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc3333" })!
        let frc7332 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc7332" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc7332
        Award.insert([modelAwardTwo], event: event, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event has managed it's Award relationships properly
        XCTAssertFalse(event.awards!.contains(awardOne))
        XCTAssert(event.awards!.contains(awardTwo))

        // First award should be deleted
        XCTAssertNil(awardOne.managedObjectContext)
        // Second award should not be deleted
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssertFalse(awardTwo.recipients!.contains(frc7332))
        XCTAssert(awardTwo.recipients!.contains(frc3333))

        // frc7332 recipient should be deleted
        XCTAssertNil(frc7332.managedObjectContext)
        // frc3333 recipient should not be deleted
        XCTAssertNotNil(frc3333.managedObjectContext)
    }

}
