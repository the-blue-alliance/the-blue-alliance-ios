import TBAKit
import XCTest
@testable import The_Blue_Alliance

class AwardRecipientTestCase: AwardTestCase {

    func test_insert_awardee_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(recipient.awardee, "Zachary Orr")
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")
    }

    func test_update_awardee_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNil(recipient.awardee)
        XCTAssertEqual(recipient.teamKey?.key, "frc7332")
    }

    func test_update_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipientOne = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_awardee() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertNil(recipient.teamKey)
        XCTAssertEqual(recipient.awardee, "Zachary Orr")
    }

    func test_update_awardee() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipientOne = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        let recipientTwo = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(recipientOne, recipientTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        XCTAssert(award.recipients!.contains(recipient))

        let teamKey = recipient.teamKey!

        // Manually clear our Award Recipient -> Award relationship so we can save
        recipient.removeFromAwards(award)

        persistentContainer.viewContext.delete(recipient)
        try! persistentContainer.viewContext.save()

        // Our award shouldn't be deleted
        XCTAssertNotNil(award.managedObjectContext)
        XCTAssertFalse(award.recipients!.contains(recipient))

        // Our team key shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)
        XCTAssertFalse(teamKey.awards!.contains(recipient))
    }

    func test_delete_deny() {
        let award = self.award(event: districtEvent())
        let recipient = award.recipients!.allObjects.first! as! AwardRecipient

        // Sanity check
        XCTAssert(award.recipients!.contains(recipient))

        persistentContainer.viewContext.delete(recipient)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_awardText_awardee_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332", awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr", "Team 7332"])
    }

    func test_awardText_awardee() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(awardee: "Zachary Orr")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Zachary Orr"])
    }

    func test_awardText_team() {
        let award = self.award(event: districtEvent())

        let modelRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let recipient = AwardRecipient.insert(modelRecipient, award: award, in: persistentContainer.viewContext)
        XCTAssertEqual(recipient.awardText, ["Team 7332"])

        let teamKey = recipient.teamKey!
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.key = teamKey.key
        team.nickname = "The Rawrbotz"

        XCTAssertEqual(recipient.awardText, ["Team 7332", "The Rawrbotz"])
    }

}
