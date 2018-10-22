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
        XCTAssertNil(recipient.award)
        XCTAssertNil(recipient.managedObjectContext)

        // Event should not be deleted
        XCTAssertEqual(event.awards?.count, 0)
        XCTAssertNotNil(event.managedObjectContext)
    }

}
