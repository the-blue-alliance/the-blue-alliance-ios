import TBAKit
import XCTest
@testable import The_Blue_Alliance

class EventTestCase: CoreDataTestCase {

    let calendar: Calendar = Calendar.current

    func test_insert_alliances() {
        let event = districtEvent()

        let modelAllianceOne = TBAAlliance(name: "Alliance 1", picks: ["frc1"])
        let modelAllianceTwo = TBAAlliance(name: "Alliance 2", picks: ["frc2"])

        event.insert([modelAllianceOne, modelAllianceTwo])

        let alliances = event.alliances!.array as! [EventAlliance]
        let allianceOne = alliances.first(where: { $0.name == "Alliance 1" })!
        let allianceTwo = alliances.first(where: { $0.name == "Alliance 2" })!

        // Sanity check
        XCTAssertEqual(event.alliances?.count, 2)
        XCTAssertNotEqual(allianceOne, allianceTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAllianceTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let alliancesSet = NSSet(array: event.alliances!.array)

        // Ensure our Event has managed it's Alliance relationships properly
        XCTAssert(alliancesSet.onlyObject(allianceTwo))

        // First alliance should be deleted
        XCTAssertNil(allianceOne.managedObjectContext)
        // Second alliance should not be deleted
        XCTAssertNotNil(allianceTwo.managedObjectContext)
    }

    func test_insert_awards() {
        // Orphaned Awards and their relationships should be cleaned up
        // We're going to assume this tests `insert` and `prepareForDeletion`
        let event = districtEvent()

        // Insert Two Awards - one with two Award Recipients, one with one Award Recipient
        let frc1Model = TBAAwardRecipient(teamKey: "frc1")
        let frc2Model = TBAAwardRecipient(teamKey: "frc2")
        let modelAwardOne = TBAAward(name: "The Fake Award",
                                     awardType: 2,
                                     eventKey: event.key!,
                                     recipients: [frc1Model, frc2Model],
                                     year: 2018)
        let modelAwardTwo = TBAAward(name: "The Fake Award Two",
                                     awardType: 3,
                                     eventKey: event.key!,
                                     recipients: [frc2Model],
                                     year: 2018)

        event.insert([modelAwardOne, modelAwardTwo])

        let awards = event.awards!.allObjects as! [Award]
        let awardOne = awards.first(where: { $0.awardType?.intValue == 2 })!
        let awardTwo = awards.first(where: { $0.awardType?.intValue == 3 })!
        let frc1 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc1" })!
        let frc2 = (awardOne.recipients!.allObjects as! [AwardRecipient]).first(where: { $0.teamKey?.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.awards?.count, 2)
        XCTAssertNotEqual(awardOne, awardTwo)

        // Remove the first Award from the Event - this should orphan the first Award and Award Recipient frc1
        event.insert([modelAwardTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event has managed it's Award relationships properly
        XCTAssert(event.awards!.onlyObject(awardTwo))

        // First award should be deleted
        XCTAssertNil(awardOne.managedObjectContext)
        // Second award should not be deleted
        XCTAssertNotNil(awardTwo.managedObjectContext)

        // Ensure our Award has managed it's Award Recipient relationships properly
        XCTAssert(awardTwo.recipients!.onlyObject(frc2))

        // frc7332 recipient should be deleted
        XCTAssertNil(frc1.managedObjectContext)
        // frc3333 recipient should not be deleted
        XCTAssertNotNil(frc2.managedObjectContext)
    }

    func test_insert_matches() {
        let event = districtEvent()

        let redAlliance = TBAMatchAlliance(score: 200, teams: ["frc7332"])
        let blueAlliance = TBAMatchAlliance(score: 300, teams: ["frc3333"])
        let modelOne = TBAMatch(key: "\(event.key!)_sf2m3",
            compLevel: "sf",
            setNumber: 2,
            matchNumber: 3,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key!,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        let modelTwo = TBAMatch(key: "\(event.key!)_f1m1",
            compLevel: "f",
            setNumber: 1,
            matchNumber: 1,
            alliances: ["red": redAlliance, "blue": blueAlliance],
            winningAlliance: "blue",
            eventKey: event.key!,
            time: 1520109780,
            actualTime: 1520090745,
            predictedTime: 1520109780,
            postResultTime: 1520090929,
            breakdown: ["red": [:], "blue": [:]],
            videos: [TBAMatchVideo(key: "G-pq01gqMTw", type: "youtube")])

        event.insert([modelOne, modelTwo])

        let matches = event.matches!.allObjects as! [Match]
        let matchOne = matches.first(where: { $0.key == "2018miket_sf2m3" })!
        let matchTwo = matches.first(where: { $0.key == "2018miket_f1m1" })!

        // Sanity check
        XCTAssertEqual(event.matches?.count, 2)
        XCTAssertNotEqual(matchOne, matchTwo)

        event.insert([modelTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.matches!.onlyObject(matchTwo))

        // MatchOne should be deleted
        XCTAssertNil(matchOne.managedObjectContext)

        // MatchTwo should not be deleted
        XCTAssertNotNil(matchTwo.managedObjectContext)
    }

    func test_insert_teams() {
        let event = districtEvent()

        let modelTeamOne = TBATeam(key: "frc1", teamNumber: 1, name: "One", rookieYear: 2000)
        let modelTeamTwo = TBATeam(key: "frc2", teamNumber: 2, name: "Two", rookieYear: 2001)

        event.insert([modelTeamOne, modelTeamTwo])

        let teams = event.teams!.allObjects as! [Team]
        let teamOne = teams.first(where: { $0.key == "frc1" })!
        let teamTwo = teams.first(where: { $0.key == "frc2" })!

        // Sanity check
        XCTAssertEqual(event.teams?.count, 2)
        XCTAssertNotEqual(teamOne, teamTwo)

        event.insert([modelTeamTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Match updates it's relationships properly
        XCTAssert(event.teams!.onlyObject(teamTwo))

        // Neither team should be deleted
        XCTAssertNotNil(teamOne.managedObjectContext)
        XCTAssertNotNil(teamTwo.managedObjectContext)
    }

    func test_insert_webcasts() {
        let event = districtEvent()

        let modelWebcastOne = TBAWebcast(type: "twitch", channel: "firstinmichigan")
        let modelWebcastTwo = TBAWebcast(type: "twitch", channel: "firstinmichigan2")

        event.insert([modelWebcastOne, modelWebcastTwo])

        let webcasts = event.webcasts!.allObjects as! [Webcast]
        let webcastOne = webcasts.first(where: { $0.channel == "firstinmichigan" })!
        let webcastTwo = webcasts.first(where: { $0.channel == "firstinmichigan2" })!

        // Sanity check
        XCTAssertEqual(event.webcasts?.count, 2)
        XCTAssertNotEqual(webcastOne, webcastTwo)

        event.insert([modelWebcastTwo])

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event/Webcast updates it's relationships properly
        XCTAssert(event.webcasts!.onlyObject(webcastTwo))

        // Webcast One should be deleted, since it's an orphan. Webcast Two should not be deleted.
        XCTAssertNil(webcastOne.managedObjectContext)
        XCTAssertNotNil(webcastTwo.managedObjectContext)
    }

    func test_isOrphaned() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        // Event should never be orphaned
        XCTAssertFalse(event.isOrphaned)
    }

    func event(type eventType: EventType) -> Event {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.eventType = Int16(eventType.rawValue)
        return event
    }

    func test_isHappeningNow() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started two days ago, ends today
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -2), to: today)
        event.endDate = today
        XCTAssert(event.isHappeningNow)
    }

    func test_isHappeningNow_isNotHappening() {
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)

        // Event started three days ago, ended yesterday
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        event.startDate = calendar.date(byAdding: DateComponents(day: -3), to: today)
        event.endDate = calendar.date(byAdding: DateComponents(day: -1), to: today)
        XCTAssertFalse(event.isHappeningNow)
    }

    func test_isDistrictChampionshipEvent() {
        let dcmp = event(type: EventType.districtChampionship)
        XCTAssert(dcmp.isDistrictChampionshipEvent)
        XCTAssert(dcmp.isDistrictChampionship)

        let dcmpDivision = event(type: EventType.districtChampionshipDivision)
        XCTAssert(dcmpDivision.isDistrictChampionshipEvent)
        XCTAssertFalse(dcmpDivision.isDistrictChampionship)
    }

    func test_hybridType_regional() {
        let eventType = EventType.regional
        let regional = event(type: eventType)
        XCTAssertEqual(regional.calculateHybridType(), "0")
    }

    func test_hybridType_district() {
        let eventType = EventType.district
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtEvent = event(type: eventType)
        districtEvent.district = district

        XCTAssertEqual(districtEvent.calculateHybridType(), "1.fim")
    }

    func test_hybridType_districtChampionship() {
        let eventType = EventType.districtChampionship
        let districtChampionship = event(type: eventType)
        XCTAssertEqual(districtChampionship.calculateHybridType(), "2.dcmp")
    }

    func test_hybridType_championshipDivision() {
        let eventType = EventType.championshipDivision
        let championshipDivision = event(type: eventType)
        XCTAssertEqual(championshipDivision.calculateHybridType(), "3")
    }

    func test_hybridType_championshipFinals() {
        let eventType = EventType.championshipFinals
        let championshipFinals = event(type: eventType)
        XCTAssertEqual(championshipFinals.calculateHybridType(), "4")
    }

    func test_hybridType_districtChampionshipDivision() {
        let eventType = EventType.districtChampionshipDivision
        let districtAbbreviation = "fim"

        let district = District(entity: District.entity(), insertInto: persistentContainer.viewContext)
        district.abbreviation = districtAbbreviation

        let districtChampionshipDivision = event(type: eventType)
        districtChampionshipDivision.district = district

        XCTAssertEqual(districtChampionshipDivision.calculateHybridType(), "2..fim.dcmpd")

        let districtChampionship = event(type: EventType.districtChampionship)
        // Ensure district championship divisions appear before district championships
        XCTAssert(districtChampionshipDivision.calculateHybridType() < districtChampionship.calculateHybridType())
    }

    func test_hybridType_festivalOfChampions() {
        let eventType = EventType.festivalOfChampions
        let festivalOfChampions = event(type: eventType)
        XCTAssertEqual(festivalOfChampions.calculateHybridType(), "6")
    }

    func test_hybridType_offseason() {
        let eventType = EventType.offseason

        let novermberOffseason = event(type: eventType)
        novermberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 11, day: 1))
        XCTAssertEqual(novermberOffseason.calculateHybridType(), "99.11")

        let septemberOffseason = event(type: eventType)
        septemberOffseason.startDate = Calendar.current.date(from: DateComponents(year: 2015, month: 9, day: 1))
        XCTAssertEqual(septemberOffseason.calculateHybridType(), "99.9")

        // Ensure single-digit month offseason events show up before double-digit month offseason events
        XCTAssert(septemberOffseason.calculateHybridType() > novermberOffseason.calculateHybridType())
    }

    func test_hybridType_preseason() {
        let eventType = EventType.preseason
        let preseason = event(type: eventType)
        XCTAssertEqual(preseason.calculateHybridType(), "100")
    }

    func test_hybridType_unlabeled() {
        let eventType = EventType.unlabeled
        let unlabeled = event(type: eventType)
        XCTAssertEqual(unlabeled.calculateHybridType(), "-1")
    }

}
