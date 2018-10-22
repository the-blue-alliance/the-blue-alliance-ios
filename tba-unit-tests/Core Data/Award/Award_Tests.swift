import TBAKit
import XCTest
@testable import The_Blue_Alliance

class Award_TestCase: CoreDataTestCase {

    private func modelAward(eventKey: String) -> TBAAward {
        let modelAwardRecipientOne = TBAAwardRecipient(teamKey: "frc7332")
        let modelAwardRecipientTwo = TBAAwardRecipient(teamKey: "frc2337")
        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: eventKey,
                                  recipients: [modelAwardRecipientOne, modelAwardRecipientTwo],
                                  year: 2018)
        return modelAward
    }

    func test_insert() {
        let event = districtEvent()
        let modelAward = self.modelAward(eventKey: event.key!)

        let award = Award.insert(modelAward, event: event, in: persistentContainer.viewContext)
        XCTAssertEqual(award.name, "The Fake Award")
        XCTAssertEqual(award.awardType, 2)
        XCTAssertEqual(award.year, 2018)
        XCTAssertEqual(award.recipients?.count, 2)
        XCTAssertNotNil(award.event)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_update() {
        let event = districtEvent()
        let modelAward = self.modelAward(eventKey: event.key!)

        let award = Award.insert(modelAward, event: event, in: persistentContainer.viewContext)
        let recipients = award.recipients!.allObjects as! [AwardRecipient]

        let modelNewRecipient = TBAAwardRecipient(teamKey: "frc3333")
        let duplicateModelAward = TBAAward(name: "The Duplicate Award",
                                           awardType: modelAward.awardType,
                                           eventKey: modelAward.eventKey,
                                           recipients: [modelNewRecipient],
                                           year: modelAward.year)

        let duplicateAward = Award.insert(duplicateModelAward, event: event, in: persistentContainer.viewContext)
        XCTAssertEqual(award, duplicateAward)

        // Check that the award updates it's values properly
        XCTAssertEqual(award.name, "The Duplicate Award")
        XCTAssertNotEqual(recipients, award.recipients!.allObjects as! [AwardRecipient])
    }

    func test_delete_cascade() {
        let event = districtEvent()
        let modelAward = self.modelAward(eventKey: event.key!)

        let award = Award.insert(modelAward, event: event, in: persistentContainer.viewContext)
        let recipient = award.recipients?.anyObject() as! AwardRecipient

        persistentContainer.viewContext.delete(award)
        try! persistentContainer.viewContext.save()

        // Recipient should be deleted
        XCTAssertNil(recipient.awards)
        XCTAssertNil(recipient.managedObjectContext)

        // Event should not be deleted
        XCTAssertEqual(event.awards?.count, 0)
        XCTAssertNotNil(event.managedObjectContext)
    }

    func test_delete_orphans() {
        let event = districtEvent()

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
        let modelAwardOneUpdated = TBAAward(name: "The Fake Award",
                                            awardType: 2,
                                            eventKey: event.key!,
                                            recipients: [modelAwardRecipientOne],
                                            year: 2018)

        let awardOne = Award.insert(modelAwardOne, event: event, in: persistentContainer.viewContext)
        let awardTwo = Award.insert(modelAwardTwo, event: event, in: persistentContainer.viewContext)
        let recipientTwo = awardTwo.recipients!.allObjects.first! as! AwardRecipient
        let awardOneUpdated = Award.insert(modelAwardOneUpdated, event: event, in: persistentContainer.viewContext)
        let recipientOne = awardOneUpdated.recipients!.allObjects.first! as! AwardRecipient
        XCTAssertEqual(awardOne, awardOneUpdated)
        XCTAssertNotEqual(awardOne, awardTwo)

        // Neither recipient should be deleted - they both refer to one award
        XCTAssertEqual(awardOne.recipients?.count, 1)
        XCTAssert(awardOne.recipients!.contains(recipientOne))
        XCTAssertFalse(awardOne.recipients!.contains(recipientTwo))

        XCTAssertEqual(awardTwo.recipients?.count, 1)
        XCTAssert(awardTwo.recipients!.contains(recipientTwo))
        XCTAssertFalse(awardTwo.recipients!.contains(recipientOne))

        XCTAssertNotNil(recipientOne.managedObjectContext)
        XCTAssertNotNil(recipientTwo.managedObjectContext)

        // TODO: Add full delete - see how cascade works.... I don't think it will
    }

}
