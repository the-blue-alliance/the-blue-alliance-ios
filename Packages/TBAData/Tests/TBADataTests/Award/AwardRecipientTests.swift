import CoreData
import TBAKit
import XCTest
@testable import TBAData

class AwardRecipientTestCase: TBADataTestCase {

    func test_awardee() {
        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(recipient.awardee)
        recipient.awardeeRaw = "Test Awardee"
        XCTAssertEqual(recipient.awardee, "Test Awardee")
    }

    func test_awards() {
        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)

        let event = insertEvent()
        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        recipient.awardsRaw = NSSet(array: [award])

        XCTAssertEqual(recipient.awards, [award])
    }

    func test_team() {
        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(recipient.team)
        let team = insertTeam()
        recipient.teamRaw = team
        XCTAssertEqual(recipient.team, team)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<AwardRecipient> = AwardRecipient.fetchRequest()
        XCTAssertEqual(fr.entityName, AwardRecipient.entityName)
    }

    func test_insert_awardee_team() {
        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        XCTAssertEqual(recipient.awardee, "Zachary Orr")
        XCTAssertEqual(recipient.team?.key, "frc7332")

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
        XCTAssertEqual(recipient.team?.key, "frc7332")

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_insert_validate() {
        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let awardRecipient = AwardRecipient.insert(modelAwardRecipient, in: persistentContainer.viewContext)

        // Our Award Recipient shouldn't be able to be saved without an Award Recipient
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let event = insertDistrictEvent()

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        award.addToRecipientsRaw(awardRecipient)

        award.eventRaw = nil
        // Our Award shouldn't be able to be saved without an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToAwardsRaw(award)
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

        XCTAssertNil(recipient.team)
        XCTAssertEqual(recipient.awardee, "Zachary Orr")

        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_insert_none() {
        let modelRecipient = TBAAwardRecipient(teamKey: nil, awardee: nil)
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        XCTAssertNil(recipient.team)
        XCTAssertNil(recipient.awardee)

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

    func test_delete() {
        let event = insertDistrictEvent()

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        let team = recipient.team!

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        award.addToRecipientsRaw(recipient)

        // Recipient can't be deleted while it's attached to an Award
        persistentContainer.viewContext.delete(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        // Our Award should fail validation, because it can't exist without Recipients
        award.removeFromRecipientsRaw(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        persistentContainer.viewContext.delete(award)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our award should be deleted
        XCTAssertNil(award.managedObjectContext)

        // Our team key shouldn't be deleted
        XCTAssertNotNil(team.managedObjectContext)
        XCTAssertFalse(team.awards.contains(recipient))
    }

    func test_delete_deny() {
        let event = insertDistrictEvent()

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        award.addToRecipientsRaw(recipient)

        persistentContainer.viewContext.delete(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_isOrphaned() {
        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        // No Award - should be orphaned
        XCTAssert(recipient.isOrphaned)

        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.addToRecipientsRaw(recipient)
        // Attached to an Award - should not be orphaned
        XCTAssertFalse(recipient.isOrphaned)

        award.removeFromRecipientsRaw(recipient)
        // Removed from an Award - should be orphaned
        XCTAssert(recipient.isOrphaned)
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

        let team = Team.insert(modelRecipient.teamKey!, in: persistentContainer.viewContext)
        team.nicknameRaw = "The Rawrbotz"

        XCTAssertEqual(recipient.awardText, ["Team 7332", "The Rawrbotz"])
    }

    func test_awardText_none() {
        let modelRecipient = TBAAwardRecipient(teamKey: nil, awardee: nil)
        let recipient = AwardRecipient.insert(modelRecipient, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["--"])
    }

}
