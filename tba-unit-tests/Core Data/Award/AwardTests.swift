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
        XCTAssertEqual(award.name, "The Fake Award")
        XCTAssertEqual(award.awardType, 2)
        XCTAssertEqual(award.year, 2018)
        XCTAssertEqual(award.recipients?.count, 1)
        XCTAssertNotNil(award.event)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()
        let award = self.award(event: event)
        let recipients = award.recipients!.allObjects as! [AwardRecipient]

        let modelNewRecipient = TBAAwardRecipient(teamKey: "frc3333")
        let duplicateModelAward = TBAAward(name: "The Duplicate Award",
                                           awardType: award.awardType!.intValue,
                                           eventKey: award.event!.key!,
                                           recipients: [modelNewRecipient],
                                           year: award.year!.intValue)

        let duplicateAward = Award.insert([duplicateModelAward], event: event, in: persistentContainer.viewContext).first!
        XCTAssertEqual(award, duplicateAward)

        // Check that the award updates it's values properly
        XCTAssertEqual(award.name, "The Duplicate Award")
        XCTAssertNotEqual(recipients, award.recipients!.allObjects as! [AwardRecipient])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update_orphans() {
        // When updating Awards for an Event, orphaned Award Recipients should be deleted
        let event = districtEvent()
        let award = self.award(event: event)
        let frc7332 = award.recipients!.allObjects.first! as! AwardRecipient

        let frc3333Model = TBAAwardRecipient(teamKey: "frc3333")
        let modelAward = TBAAward(name: "The Duplicate Award",
                                  awardType: award.awardType!.intValue,
                                  eventKey: award.event!.key!,
                                  recipients: [modelRecipient],
                                  year: award.year!.intValue)
        let award2 = Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
        let recipientTwo = award2.recipients!.allObjects.first! as! AwardRecipient

        // Sanity check - Awards should be qual
        XCTAssertEqual(award, award2)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // recipientOne should be deleted
        XCTAssertFalse(award.recipients!.contains(recipientOne))
        XCTAssertNil(recipientOne.managedObjectContext)

        // recipientTwo should not be deleted
        XCTAssert(award.recipients!.contains(recipientTwo))
        XCTAssertNotNil(recipientTwo.managedObjectContext)
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

        // TODO: DELETE FOR CHRIST'S SAKE
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Neither recipient should be deleted - they both refer to one award
        XCTAssert(awardOne.recipients!.contains(frc7332))
        XCTAssertFalse(awardOne.recipients!.contains(frc3333))
        XCTAssertNotNil(frc7332.managedObjectContext)

        XCTAssert(awardTwo.recipients!.contains(frc3333))
        XCTAssertFalse(awardTwo.recipients!.contains(frc7332))
        XCTAssertNotNil(frc3333.managedObjectContext)
    }

    func test_update_complexOrphans() {
        // Given one Award with two Teams, a second Award with one Team from the first set,
        // and then an update to the first Award to have the same Teams as the second Award,
        // the first Team shoul be deleted - since it's an orphan
        let event = districtEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let modelAwardRecipientOne = TBAAwardRecipient(teamKey: "frc7332")
        let modelAwardRecipientTwo = TBAAwardRecipient(teamKey: "frc2337")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key!,
                                     recipients: [modelAwardRecipientOne, modelAwardRecipientTwo],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [modelAwardRecipientTwo],
                                     year: 2018)

        let awards = Award.insert([modelAwardOne, modelAwardTwo], event: event, in: persistentContainer.viewContext)
        let awardOne = awards.first!
        let awardTwo = awards[1]
        let recipientOne = awardOne.recipients!.allObjects.first! as! AwardRecipient
        print(recipientOne)

        // Update our first Award to only have one of the two recipients
        let modelAwardOneUpdated = TBAAward(name: "The Fake Award",
                                            awardType: 2,
                                            eventKey: event.key!,
                                            recipients: [modelAwardRecipientTwo],
                                            year: 2018)
        let recipientTwo = awardTwo.recipients!.allObjects.first! as! AwardRecipient
        let awardsTwo = Award.insert([modelAwardOneUpdated, modelAwardTwo], event: event, in: persistentContainer.viewContext)
        let awardOneUpdated = awardsTwo.first!
        print(awardOneUpdated)

        // Sanity check
        XCTAssertEqual(awardOne, awardOneUpdated)
        XCTAssertNotEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // First recipient should be deleted
        XCTAssertFalse(awardOne.recipients!.contains(recipientOne))
        XCTAssert(awardOne.recipients!.contains(recipientTwo))
        XCTAssertNil(recipientOne.managedObjectContext)

        // Second recipient should not be deleted
        XCTAssert(awardTwo.recipients!.contains(recipientTwo))
        XCTAssertFalse(awardTwo.recipients!.contains(recipientOne))
        XCTAssertNotNil(recipientTwo.managedObjectContext)
    }

}
