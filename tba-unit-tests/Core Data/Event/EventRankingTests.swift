import XCTest
@testable import TBA

class EventRankingTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let extraStatsInfo = [TBAEventRankingSortOrder(name: "Total Ranking Points", precision: 0)]
        let sortOrderInfo = [
            TBAEventRankingSortOrder(name: "Ranking Score", precision: 2),
            TBAEventRankingSortOrder(name: "First Ranking", precision: 0),
            TBAEventRankingSortOrder(name: "Second Raking", precision: 0)
        ]
        let model = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25], sortOrders: [2.08, 530.0, 0.0])
        let ranking = EventRanking.insert(model, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(ranking.teamKey?.key, "frc1")
        XCTAssertEqual(ranking.rank, 2)
        XCTAssertEqual(ranking.dq, 10)
        XCTAssertEqual(ranking.matchesPlayed, 6)
        XCTAssertEqual(ranking.qualAverage, 20)
        XCTAssertNotNil(ranking.record)
        XCTAssertEqual(ranking.tiebreakerValues, [2.08, 530.0, 0.0])
        XCTAssertEqual(ranking.tiebreakerNames, ["Ranking Score", "First Ranking", "Second Raking"])
        XCTAssertEqual(ranking.extraStatsValues, [25])
        XCTAssertEqual(ranking.extraStatsNames, ["Total Ranking Points"])

        // Should throw an error - must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToRankings(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insertPredicate() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)

        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.teamKey = TeamKey.insert(withKey: "frc1", in: persistentContainer.viewContext)

        // Test inserting a Ranking where EventRanking.qualStatus.eventStatus.event.key == eventKey
        let qualStatus = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        eventStatus.qual = qualStatus
        eventStatus.event = event
        ranking.qualStatus = qualStatus

        let qualStatusRanking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)
        XCTAssertEqual(qualStatusRanking, ranking)
        ranking.qualStatus = nil

        // Test inserting a Ranking where EventRanking.event.key == eventKey
        ranking.event = event
        let eventRanking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)
        XCTAssertEqual(eventRanking, ranking)
    }

    func test_update() {
        let event = insertDistrictEvent()

        let extraStatsInfo = [TBAEventRankingSortOrder(name: "Total Ranking Points", precision: 0)]
        let sortOrderInfo = [
            TBAEventRankingSortOrder(name: "Ranking Score", precision: 2),
            TBAEventRankingSortOrder(name: "First Ranking", precision: 0),
            TBAEventRankingSortOrder(name: "Second Raking", precision: 0)
        ]
        let modelOne = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25], sortOrders: [2.08, 530.0, 0.0])
        let rankingOne = EventRanking.insert(modelOne, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToRankings(rankingOne)

        let modelTwo = TBAEventRanking(teamKey: "frc1", rank: 3, dq: 11, matchesPlayed: 7, qualAverage: 10, record: nil, extraStats: nil, sortOrders: nil)
        let rankingTwo = EventRanking.insert(modelTwo, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(rankingOne, rankingTwo)

        // Make sure our values updated properly
        XCTAssertEqual(rankingOne.rank, 3)
        XCTAssertEqual(rankingOne.dq, 11)
        XCTAssertEqual(rankingOne.matchesPlayed, 7)
        XCTAssertEqual(rankingOne.qualAverage, 10)
        XCTAssertNil(rankingOne.record)
        XCTAssertNil(rankingOne.tiebreakerValues)
        XCTAssertNil(rankingOne.tiebreakerNames)
        // extraStatsInfo should not be removed
        XCTAssertNotNil(rankingOne.extraStatsValues)
        XCTAssertNotNil(rankingOne.extraStatsNames)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete_orphan() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)
        let qualStatusModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)

        let ranking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToRankings(ranking)

        let teamKey = ranking.teamKey!

        let qualStatus = EventStatusQual.insert(qualStatusModel, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)
        ranking.qualStatus = qualStatus

        // Should be able to delete
        persistentContainer.viewContext.delete(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event and TeamKey should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertNotNil(teamKey.managedObjectContext)

        // QualStatus is an orphan and should be deleted
        XCTAssertNil(qualStatus.managedObjectContext)
    }

    func test_delete_qualStatus() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)
        let eventStatusModel = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let qualStatusModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)

        let ranking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToRankings(ranking)

        let eventStatus = EventStatus.insert(eventStatusModel, in: persistentContainer.viewContext)
        let qualStatus = EventStatusQual.insert(qualStatusModel, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)
        eventStatus.qual = qualStatus
        eventStatus.event = event
        ranking.qualStatus = qualStatus

        // Should be able to delete
        persistentContainer.viewContext.delete(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // QualStatus should not be deleted, since it is not an orphan
        XCTAssertNotNil(qualStatus.managedObjectContext)
    }

    func test_isOrphaned() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        // No Event or Status - should be orphaned
        XCTAssert(ranking.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToRankings(ranking)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(ranking.isOrphaned)
        event.removeFromRankings(ranking)

        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        status.ranking = ranking
        // Attached to a Status - should not be orphaned
        XCTAssertFalse(ranking.isOrphaned)
        status.ranking = nil

        // Not attached to an Event or Status - should be orphaned
        XCTAssert(ranking.isOrphaned)
    }

    func test_tiebreakerInfoString() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.tiebreakerInfoString)

        let tiebreakerNames = ["Value 1", "Value 2", "Value 3"]
        let tiebreakerValues = [1.00, 2.2, 3.33]

        // Needs both keys and values
        ranking.tiebreakerNames = tiebreakerNames
        XCTAssertNil(ranking.tiebreakerInfoString)
        ranking.tiebreakerNames = nil

        ranking.tiebreakerValues = tiebreakerValues
        XCTAssertNil(ranking.tiebreakerInfoString)

        ranking.tiebreakerNames = tiebreakerNames
        XCTAssertEqual(ranking.tiebreakerInfoString, "Value 1: 1.0, Value 2: 2.2, Value 3: 3.33")
    }

}
