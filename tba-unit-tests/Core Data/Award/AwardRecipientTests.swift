import TBAKit
import XCTest
@testable import The_Blue_Alliance

class AwardRecipientTestCase: AwardTestCase {

    func test_insert_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        XCTAssertEqual(recipient.awardee, "Zachary Orr")
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_update_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_insert_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        XCTAssertNil(recipient.awardee)
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    override func test_insert_validate() {
        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let awardRecipient = AwardRecipient.insert(modelAwardRecipient, in: persistentContainer.viewContext)

        // Our Award Recipient shouldn't be able to be saved without an Award Recipient
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let event = districtEvent()

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
        award.addToRecipients(awardRecipient)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_insert_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        XCTAssertNil(recipient.teamKey)
        XCTAssertEqual(recipient.awardee, "Zachary Orr")

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_update_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    override func test_delete() {
        let event = districtEvent()

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        let teamKey = recipient.teamKey!

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
        award.addToRecipients(recipient)

        // Recipient can't be deleted while it's attached to an Award
        persistentContainer.viewContext.delete(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        // Our Award should fail validation, because it can't exist without Recipients
        award.removeFromRecipients(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        persistentContainer.viewContext.delete(award)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our award should be deleted
        XCTAssertNil(award.managedObjectContext)

        // Our team key shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertFalse(teamKey.awards!.contains(recipient))
    }

    func test_delete_deny() {
        let event = districtEvent()

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key!,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert([modelAward], event: event, in: persistentContainer.viewContext).first!
        award.addToRecipients(recipient)

        persistentContainer.viewContext.delete(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_awardText_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr", "Team 7332"])
    }

    func test_awardText_awardee() {
        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr"])
    }

    func test_awardText_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Team 7332"])

        let teamKey = recipient.teamKey!
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.key = teamKey.key
        team.nickname = "The Rawrbotz"

        XCTAssertEqual(recipient.awardText, ["Team 7332", "The Rawrbotz"])
    }

}
