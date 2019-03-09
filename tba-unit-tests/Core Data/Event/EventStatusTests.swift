import XCTest
@testable import TBA

class EventStatusTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let qual = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)
        let alliance = TBAEventStatusAlliance(number: 1, pick: 1)
        let playoff = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let model = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: qual, alliance: alliance, playoff: playoff, allianceStatusString: "Alliance string", playoffStatusString: "Playoff string", overallStatusString: "Overall string", nextMatchKey: "2018miket_qm1", lastMatchKey: "2018miket_qm80")
        let status = EventStatus.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(status.teamKey?.key, "frc1")
        XCTAssertEqual(status.allianceStatus, "Alliance string")
        XCTAssertEqual(status.playoffStatus, "Playoff string")
        XCTAssertEqual(status.overallStatus, "Overall string")
        XCTAssertEqual(status.nextMatchKey, "2018miket_qm1")
        XCTAssertEqual(status.lastMatchKey, "2018miket_qm80")
        XCTAssertNotNil(status.qual)
        XCTAssertNotNil(status.alliance)
        XCTAssertNotNil(status.playoff)

        // Should throw an error - cannot save without Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        status.event = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let qualModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)
        let allianceModel = TBAEventStatusAlliance(number: 1, pick: 1)
        let playoffModel = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let modelOne = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: qualModel, alliance: allianceModel, playoff: playoffModel, allianceStatusString: "Alliance string", playoffStatusString: "Playoff string", overallStatusString: "Overall string", nextMatchKey: "2018miket_qm1", lastMatchKey: "2018miket_qm80")
        let statusOne = EventStatus.insert(modelOne, in: persistentContainer.viewContext)
        statusOne.event = event

        let qual = statusOne.qual!
        let alliance = statusOne.alliance!
        let playoff = statusOne.playoff!

        let modelTwo = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let statusTwo = EventStatus.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)

        // Make sure our values got updated properly
        XCTAssertEqual(statusOne.teamKey?.key, "frc1")
        XCTAssertNil(statusOne.allianceStatus)
        XCTAssertNil(statusOne.playoffStatus)
        XCTAssertNil(statusOne.overallStatus)
        XCTAssertNil(statusOne.nextMatchKey)
        XCTAssertNil(statusOne.lastMatchKey)
        XCTAssertNil(statusOne.qual)
        XCTAssertNil(statusOne.alliance)
        XCTAssertNil(statusOne.playoff)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Qual, Alliance, and Playoff should all be deleted
        XCTAssertNil(qual.managedObjectContext)
        XCTAssertNil(alliance.managedObjectContext)
        XCTAssertNil(playoff.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let qualModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)
        let allianceModel = TBAEventStatusAlliance(number: 1, pick: 1)
        let playoffModel = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let model = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: qualModel, alliance: allianceModel, playoff: playoffModel, allianceStatusString: nil, playoffStatusString: nil, overallStatusString: nil, nextMatchKey: nil, lastMatchKey: nil)
        let status = EventStatus.insert(model, in: persistentContainer.viewContext)

        let qual = status.qual!
        let alliance = status.alliance!
        let playoff = status.playoff!

        status.event = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        persistentContainer.viewContext.delete(status)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Event updated it's relationship properly
        XCTAssertEqual(event.statuses?.count, 0)

        // Qual, Alliance, and Playoff should all be deleted
        XCTAssertNil(qual.managedObjectContext)
        XCTAssertNil(alliance.managedObjectContext)
        XCTAssertNil(playoff.managedObjectContext)
    }

    func test_delete_qual() {
        let event = insertDistrictEvent()

        let qualModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)

        let modelStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: qualModel, alliance: nil, playoff: nil, allianceStatusString: nil, playoffStatusString: nil, overallStatusString: nil, nextMatchKey: nil, lastMatchKey: nil)
        let status = EventStatus.insert(modelStatus, in: persistentContainer.viewContext)

        let qual = status.qual!

        status.event = event

        let modelRanking = TBAEventRanking(teamKey: "frc1", rank: 2, dq: nil, matchesPlayed: nil, qualAverage: nil, record: nil, extraStats: nil, sortOrders: nil)
        let ranking = EventRanking.insert(modelRanking, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)
        ranking.qualStatus = qual
        ranking.event = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        persistentContainer.viewContext.delete(status)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Event updated it's relationship properly
        XCTAssertEqual(event.statuses?.count, 0)
        XCTAssertNotNil(ranking.qualStatus)

        // Qual should not be deleted
        XCTAssertNotNil(qual.managedObjectContext)
    }

    func test_delete_playoff() {
        let event = insertDistrictEvent()

        let playoffModel = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let modelStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!, qual: nil, alliance: nil, playoff: playoffModel, allianceStatusString: nil, playoffStatusString: nil, overallStatusString: nil, nextMatchKey: nil, lastMatchKey: nil)
        let status = EventStatus.insert(modelStatus, in: persistentContainer.viewContext)

        let playoff = status.playoff!

        status.event = event

        let modelAlliance = TBAAlliance(picks: ["frc1"])
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key!, in: persistentContainer.viewContext)
        alliance.status = playoff
        alliance.event = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        persistentContainer.viewContext.delete(status)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Make sure our Event updated it's relationship properly
        XCTAssertEqual(event.statuses?.count, 0)
        XCTAssertNotNil(alliance.status)

        // Qual should not be deleted
        XCTAssertNotNil(playoff.managedObjectContext)
    }

}
