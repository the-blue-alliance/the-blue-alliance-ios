import CoreData
import TBAKit
import XCTest
@testable import TBAData

class AwardTestCase: TBADataTestCase {

    func test_awardType() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.awardTypeRaw = NSNumber(value: 1)
        XCTAssertEqual(award.awardType, 1)
    }

    func test_name() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.nameRaw = "Test Award"
        XCTAssertEqual(award.name, "Test Award")
    }

    func test_year() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.yearRaw = NSNumber(value: 2020)
        XCTAssertEqual(award.year, 2020)
    }

    func test_event() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        let event = insertEvent()
        award.eventRaw = event
        XCTAssertEqual(award.event, event)
    }

    func test_recipients() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        let rm = TBAAwardRecipient(teamKey: "frc7332")
        let r = AwardRecipient.insert(rm, in: persistentContainer.viewContext)
        award.recipientsRaw = NSSet(array: [r])
        XCTAssertEqual(award.recipients, [r])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<Award> = Award.fetchRequest()
        XCTAssertEqual(fr.entityName, Award.entityName)
    }

    func test_eventPredicate() {
        let event = insertEvent()
        let predicate = Award.eventPredicate(eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\"")

        _ = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.eventRaw = event

        let results = Award.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [award])
    }

    func test_teamPredicate() {
        let team = insertTeam()
        let predicate = Award.teamPredicate(teamKey: team.key)
        XCTAssertEqual(predicate.predicateFormat, "ANY recipientsRaw.teamRaw.keyRaw == \"frc7332\"")

        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        recipient.teamRaw = team
        _ = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.recipientsRaw = NSSet(array: [recipient])

        let results = Award.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [award])
    }

    func test_teamEventPredicate() {
        let team = insertTeam()
        let event = insertEvent()
        let predicate = Award.teamEventPredicate(teamKey: team.key, eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\" AND ANY recipientsRaw.teamRaw.keyRaw == \"frc7332\"")

        let recipient = AwardRecipient.init(entity: AwardRecipient.entity(), insertInto: persistentContainer.viewContext)
        recipient.teamRaw = team
        let eventAward = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        eventAward.eventRaw = event
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        award.recipientsRaw = NSSet(array: [recipient])
        award.eventRaw = event
        let results = Award.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [award])
    }

    func test_typeSortDescriptor() {
        let sd = Award.typeSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(Award.awardTypeRaw))
        XCTAssert(sd.ascending)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [modelAwardRecipient],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)

        XCTAssertEqual(award.name, "The Fake Award")
        XCTAssertEqual(award.awardType, 2)
        XCTAssertEqual(award.year, 2018)
        XCTAssertEqual(award.recipients.count, 1)
        XCTAssertEqual(award.event, event)

        // Award shouldn't be able to be saved without an Event
        award.eventRaw = nil
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToAwardsRaw(award)
        XCTAssertNotNil(award.event)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_validate() {
        let event = insertDistrictEvent()

        let modelAward = TBAAward(name: "The Fake Award",
                                  awardType: 2,
                                  eventKey: event.key,
                                  recipients: [],
                                  year: 2018)
        let award = Award.insert(modelAward, in: persistentContainer.viewContext)
        event.addToAwardsRaw(award)

        // Our Award shouldn't be able to be saved without an Award Recipient
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let modelAwardRecipient = TBAAwardRecipient(teamKey: "frc7332")
        let awardRecipient = AwardRecipient.insert(modelAwardRecipient, in: persistentContainer.viewContext)
        award.addToRecipientsRaw(awardRecipient)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")
        let frc3Model = TBAAwardRecipient(teamKey: "frc3")

        let modelOne = TBAAward(name: "The Fake Award",
                                awardType: 2,
                                eventKey: event.key,
                                recipients: [frc1Model, frc2Model, frc3Model],
                                year: 2018)
        let awardOne = Award.insert(modelOne, in: persistentContainer.viewContext)
        let recipients = awardOne.recipients
        event.addToAwardsRaw(awardOne)

        let frc1 = recipients.first(where: { $0.team?.key == "frc1" })!
        let frc2 = recipients.first(where: { $0.team?.key == "frc2" })!
        let frc3 = recipients.first(where: { $0.team?.key == "frc3" })!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelTwo = TBAAward(name: "Some New Award",
                                awardType: 3,
                                eventKey: event.key,
                                recipients: [frc1Model],
                                year: 2018)
        let awardTwo = Award.insert(modelTwo, in: persistentContainer.viewContext)
        event.addToAwardsRaw(awardTwo)

        XCTAssertNotEqual(awardOne, awardTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelThree = TBAAward(name: "The Duplicate Award",
                                  awardType: awardOne.awardType,
                                  eventKey: event.key,
                                  recipients: [frc2Model],
                                  year: awardOne.year)
        let awardThree = Award.insert(modelThree, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(awardOne, awardThree)

        // Check that the award updates it's values properly
        XCTAssertEqual(awardOne.name, "The Duplicate Award")
        XCTAssertEqual(awardOne.recipients.count, 1)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Check our Award's recipients look right
        XCTAssert(awardOne.recipients.onlyObject(frc2))
        XCTAssert(awardTwo.recipients.onlyObject(frc1))

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
                                  eventKey: event.key,
                                  recipients: [frc1Model, frc2Model],
                                  year: 2018)
        let awardOne = Award.insert(modelAwardOne, in: persistentContainer.viewContext)
        let recipients = awardOne.recipients

        event.addToAwardsRaw(awardOne)

        let frc1 = recipients.first(where: { $0.team?.key == "frc1" })!
        let frc2 = recipients.first(where: { $0.team?.key == "frc2" })!

        let modelAwardTwo = TBAAward(name: "Some New Award",
                                     awardType: 3,
                                     eventKey: event.key,
                                     recipients: [frc2Model],
                                     year: 2018)
        let awardTwo = Award.insert(modelAwardTwo, in: persistentContainer.viewContext)
        event.addToAwardsRaw(awardTwo)

        persistentContainer.viewContext.delete(awardOne)
        // Save should work fine - since Award propogates deletion of Award Recipients
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Event updated it's relationship properly
        XCTAssertEqual(event.awards.count, 1)

        // Make sure our Awards look right
        XCTAssertNil(awardOne.managedObjectContext)
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Make sure our Award Recipients got deleted properly
        XCTAssert(awardTwo.recipients.onlyObject(frc2))

        XCTAssertNil(frc1.managedObjectContext)
        XCTAssertNotNil(frc2.managedObjectContext)
    }

    func test_isOrphaned() {
        let award = Award.init(entity: Award.entity(), insertInto: persistentContainer.viewContext)
        // No Event - should be orphaned
        XCTAssert(award.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToAwardsRaw(award)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(award.isOrphaned)

        event.removeFromAwardsRaw(award)
        // Removed from an Event - should be orphaned
        XCTAssert(award.isOrphaned)
    }

}
