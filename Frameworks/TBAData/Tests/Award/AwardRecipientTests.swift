import TBAData
import TBAKit
import XCTest

class AwardRecipientTestCase: TBADataTestCase {

    func test_insert_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        XCTAssertEqual(recipient.awardee, "Zachary Orr")
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_update_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_insert_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        XCTAssertNil(recipient.awardee)
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_insert_validate() {
        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let awardRecipient = AwardRecipient.insert(modelAwardRecipient, in: viewContext)

        // Our Award Recipient shouldn't be able to be saved without an Award Recipient
        XCTAssertThrowsError(try viewContext.save())

        let event = coreDataTestFixture.insertDistrictEvent()

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: viewContext)
        award.addToRecipients(awardRecipient)

        // Our Award shouldn't be able to be saved without an Event
        XCTAssertThrowsError(try viewContext.save())

        event.addToAwards(award)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_update_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_insert_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        XCTAssertNil(recipient.teamKey)
        XCTAssertEqual(recipient.awardee, "Zachary Orr")

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_insert_none() {
        let modelRecipient = TBAAwardRecipient(teamKey: nil, awardee: nil)
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        XCTAssertNil(recipient.teamKey)
        XCTAssertNil(recipient.awardee)

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_update_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try viewContext.save())
    }

    func test_delete() {
        let event = coreDataTestFixture.insertDistrictEvent()

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        let teamKey = recipient.teamKey!

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: viewContext)
        award.addToRecipients(recipient)

        // Recipient can't be deleted while it's attached to an Award
        viewContext.delete(recipient)
        XCTAssertThrowsError(try viewContext.save())

        // Our Award should fail validation, because it can't exist without Recipients
        award.removeFromRecipients(recipient)
        XCTAssertThrowsError(try viewContext.save())

        viewContext.delete(award)
        XCTAssertNoThrow(try viewContext.save())

        // Our award should be deleted
        XCTAssertNil(award.managedObjectContext)

        // Our team key shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertFalse(teamKey.awards!.contains(recipient))
    }

    func test_delete_deny() {
        let event = coreDataTestFixture.insertDistrictEvent()

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: viewContext)
        award.addToRecipients(recipient)

        viewContext.delete(recipient)
        XCTAssertThrowsError(try viewContext.save())
    }

    func test_isOrphaned() {
        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: viewContext)
        // No Award - should be orphaned
        XCTAssert(recipient.isOrphaned)

        let award = Award.init(entity: Award.entity(), insertInto: viewContext)
        award.addToRecipients(recipient)
        // Attached to an Award - should not be orphaned
        XCTAssertFalse(recipient.isOrphaned)

        award.removeFromRecipients(recipient)
        // Removed from an Award - should be orphaned
        XCTAssert(recipient.isOrphaned)
    }

    func test_awardText_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr", "Team 7332"])
    }

    func test_awardText_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr"])
    }

    func test_awardText_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)
        XCTAssertEqual(recipient.awardText, ["Team 7332"])

        let teamKey = recipient.teamKey!
        let team = Team.init(entity: Team.entity(), insertInto: viewContext)
        team.key = teamKey.key
        team.nickname = "The Rawrbotz"

        XCTAssertEqual(recipient.awardText, ["Team 7332", "The Rawrbotz"])
    }

    func test_awardText_none() {
        let modelRecipient = TBAAwardRecipient(teamKey: nil, awardee: nil)
        let recipient = AwardRecipient.insert(modelRecipient, in: viewContext)
        XCTAssertEqual(recipient.awardText, ["--"])
    }

}
