import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventRankingTestCase: TBADataTestCase {

    func test_dq() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.dq)
        ranking.dqRaw = NSNumber(value: 1)
        XCTAssertEqual(ranking.dq, 1)
    }

    func test_matchesPlayed() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.matchesPlayed)
        ranking.matchesPlayedRaw = NSNumber(value: 1)
        XCTAssertEqual(ranking.matchesPlayed, 1)
    }

    func test_qualAverage() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.qualAverage)
        ranking.qualAverageRaw = NSNumber(value: 20.2)
        XCTAssertEqual(ranking.qualAverage, 20.2)
    }

    func test_rank() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.rankRaw = NSNumber(value: 1)
        XCTAssertEqual(ranking.rank, 1)
    }

    func test_record() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.recordRaw)
        let record = WLT(wins: 1, losses: 2, ties: 3)
        ranking.recordRaw = record
        XCTAssertEqual(ranking.record, record)
    }

    func test_event() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        ranking.eventRaw = event
        XCTAssertEqual(ranking.event, event)
    }

    func test_extraStats() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(ranking.extraStats.array as! [EventRankingStat], [])
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        ranking.extraStatsRaw = NSOrderedSet(array: [stat])
        XCTAssertEqual(ranking.extraStats.array as! [EventRankingStat], [stat])
    }

    func test_extraStatsInfo() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(ranking.extraStatsInfo.array as! [EventRankingStatInfo], [])
        let info = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        ranking.extraStatsInfoRaw = NSOrderedSet(array: [info])
        XCTAssertEqual(ranking.extraStatsInfo.array as! [EventRankingStatInfo], [info])
    }

    func test_qualStatus() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.qualStatus)
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        ranking.qualStatusRaw = status
        XCTAssertEqual(ranking.qualStatus, status)
    }

    func test_sortOrders() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(ranking.sortOrders.array as! [EventRankingStat], [])
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        ranking.sortOrdersRaw = NSOrderedSet(array: [stat])
        XCTAssertEqual(ranking.sortOrders.array as! [EventRankingStat], [stat])
    }

    func test_sortOrdersInfo() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(ranking.sortOrdersInfo.array as! [EventRankingStatInfo], [])
        let info = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        ranking.sortOrdersInfoRaw = NSOrderedSet(array: [info])
        XCTAssertEqual(ranking.sortOrdersInfo.array as! [EventRankingStatInfo], [info])
    }

    func test_team() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        ranking.teamRaw = team
        XCTAssertEqual(ranking.team, team)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()
        XCTAssertEqual(fr.entityName, EventRanking.entityName)
    }

    func test_eventPredicate() {
        let event = insertEvent()
        let predicate = EventRanking.eventPredicate(eventKey: event.key)
        XCTAssertEqual(predicate.predicateFormat, "eventRaw.keyRaw == \"2015qcmo\"")

        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.eventRaw = event
        _ = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)

        let results = EventRanking.fetch(in: persistentContainer.viewContext) { (fr) in
            fr.predicate = predicate
        }
        XCTAssertEqual(results, [ranking])
    }

    func test_rankSortDescriptor() {
        let sd = EventRanking.rankSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(EventRanking.rankRaw))
        XCTAssert(sd.ascending)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let extraStatsInfo = [TBAEventRankingSortOrder(name: "Total Ranking Points", precision: 0)]
        let sortOrderInfo = [
            TBAEventRankingSortOrder(name: "Ranking Score", precision: 2),
            TBAEventRankingSortOrder(name: "First Ranking", precision: 0),
            TBAEventRankingSortOrder(name: "Second Raking", precision: 0)
        ]
        let model = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25.0, 3], sortOrders: [2.08, 530.0, 3])
        let ranking = EventRanking.insert(model, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: event.key, in: persistentContainer.viewContext)

        XCTAssertEqual(ranking.team.key, "frc1")
        XCTAssertEqual(ranking.rank, 2)
        XCTAssertEqual(ranking.dq, 10)
        XCTAssertEqual(ranking.matchesPlayed, 6)
        XCTAssertEqual(ranking.qualAverage, 20)
        XCTAssertNotNil(ranking.record)

        XCTAssertEqual(ranking.extraStatsInfoArray.map({ $0.name }), ["Total Ranking Points"])
        XCTAssertEqual(ranking.extraStatsInfoArray.map({ $0.precision }), [0])

        XCTAssertEqual(ranking.extraStatsArray.map({ $0.value }), [25.0, 3])
        XCTAssertEqual(ranking.extraStatsArray.compactMap({ $0.extraStatsRanking }).count, 2)
        XCTAssertEqual(ranking.extraStatsArray.compactMap({ $0.sortOrderRanking }).count, 0)

        XCTAssertEqual(ranking.sortOrdersInfoArray.map({ $0.name }), ["Ranking Score", "First Ranking", "Second Raking"])
        XCTAssertEqual(ranking.sortOrdersInfoArray.map({ $0.precision }), [2, 0, 0])

        XCTAssertEqual(ranking.sortOrdersArray.map({ $0.value }), [2.08, 530.0, 3])
        XCTAssertEqual(ranking.sortOrdersArray.compactMap({ $0.extraStatsRanking }).count, 0)
        XCTAssertEqual(ranking.sortOrdersArray.compactMap({ $0.sortOrderRanking }).count, 3)

        // Since we've setup a complicated extraStats/sortOrder, we'll test the string
        XCTAssertEqual(ranking.rankingInfoString, "Total Ranking Points: 25, Ranking Score: 2.08, First Ranking: 530, Second Raking: 3")

        // Should throw an error - must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToRankingsRaw(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insertPredicate() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)

        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.teamRaw = Team.insert("frc1", in: persistentContainer.viewContext)

        // Test inserting a Ranking where EventRanking.qualStatus.eventStatus.event.key == eventKey
        let qualStatus = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        eventStatus.qualRaw = qualStatus
        eventStatus.eventRaw = event
        ranking.qualStatusRaw = qualStatus

        let qualStatusRanking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)
        XCTAssertEqual(qualStatusRanking, ranking)
        ranking.qualStatusRaw = nil

        // Test inserting a Ranking where EventRanking.event.key == eventKey
        ranking.eventRaw = event
        let eventRanking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)
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
        let modelOne = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25, 3.0], sortOrders: [2.08, 530.0, 2])
        let rankingOne = EventRanking.insert(modelOne, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToRankingsRaw(rankingOne)

        let modelTwo = TBAEventRanking(teamKey: "frc1", rank: 3, dq: 11, matchesPlayed: 7, qualAverage: 10, record: nil, extraStats: nil, sortOrders: nil)
        let rankingTwo = EventRanking.insert(modelTwo, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(rankingOne, rankingTwo)

        // Make sure our values updated properly
        XCTAssertEqual(rankingOne.rank, 3)
        XCTAssertEqual(rankingOne.dq, 11)
        XCTAssertEqual(rankingOne.matchesPlayed, 7)
        XCTAssertEqual(rankingOne.qualAverage, 10)
        XCTAssertNil(rankingOne.record)
        XCTAssertEqual(rankingOne.sortOrdersArray.count, 0)
        XCTAssertEqual(rankingOne.sortOrdersInfoArray.count, 0)
        XCTAssertEqual(rankingOne.extraStatsArray.count, 0)
        XCTAssertEqual(rankingOne.extraStatsInfoArray.count, 0)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete_orphan() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)
        let qualStatusModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)

        let ranking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToRankingsRaw(ranking)

        let team = ranking.team

        let qualStatus = EventStatusQual.insert(qualStatusModel, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)
        ranking.qualStatusRaw = qualStatus

        // Should be able to delete
        persistentContainer.viewContext.delete(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event and Team should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertNotNil(team.managedObjectContext)

        // QualStatus is an orphan and should be deleted
        XCTAssertNil(qualStatus.managedObjectContext)
    }

    func test_delete_orphan_statsInfo() {
        let event = insertDistrictEvent()

        let extraStatsInfoModel = [TBAEventRankingSortOrder(name: "Total Ranking Points", precision: 0)]
        let sortOrderInfoModel = [
            TBAEventRankingSortOrder(name: "Ranking Score", precision: 2),
            TBAEventRankingSortOrder(name: "Total Ranking Points", precision: 0)
        ]
        let model = TBAEventRanking(teamKey: "frc1", rank: 2, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25], sortOrders: [2.08])
        let ranking = EventRanking.insert(model, sortOrderInfo: sortOrderInfoModel, extraStatsInfo: extraStatsInfoModel, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToRankingsRaw(ranking)

        let extraStatsInfo = ranking.extraStatsInfoArray.first!
        let firstSortOrderInfo = ranking.sortOrdersInfoArray.first(where: { $0.name == "Ranking Score" })!
        let secondSortOrderInfo = ranking.sortOrdersInfoArray.first(where: { $0.name == "Total Ranking Points" })!

        // Sanity check
        XCTAssertEqual(secondSortOrderInfo.extraStatsRankings.count, 1)
        XCTAssertEqual(secondSortOrderInfo.sortOrdersRankings.count, 1)
        XCTAssertEqual(extraStatsInfo, secondSortOrderInfo)

        // Connect a second ranking to the same extra stats - should not be deleted
        let secondModel = TBAEventRanking(teamKey: "frc2", rank: 1, dq: 10, matchesPlayed: 6, qualAverage: 20, record: TBAWLT(wins: 1, losses: 2, ties: 3), extraStats: [25], sortOrders: nil)
        let secondRanking = EventRanking.insert(secondModel, sortOrderInfo: nil, extraStatsInfo: extraStatsInfoModel, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToRankingsRaw(secondRanking)

        // Sanity check
        XCTAssertEqual(event.rankings.count, 2)
        XCTAssertEqual(extraStatsInfo, secondSortOrderInfo)
        XCTAssertEqual(extraStatsInfo.extraStatsRankings.count, 2)
        XCTAssertEqual(extraStatsInfo.sortOrdersRankings.count, 1)
        XCTAssertEqual(firstSortOrderInfo.extraStatsRankings.count, 0)
        XCTAssertEqual(firstSortOrderInfo.sortOrdersRankings.count, 1)

        // Should be able to delete
        persistentContainer.viewContext.delete(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // extraStatsInfo and secondSortOrderInfo should not be deleted - both (same obj) connected to a different ranking
        XCTAssertNotNil(extraStatsInfo.managedObjectContext)
        XCTAssertNotNil(secondSortOrderInfo.managedObjectContext)

        XCTAssertEqual(extraStatsInfo, secondSortOrderInfo)
        XCTAssertEqual(extraStatsInfo.extraStatsRankings.count, 1)
        XCTAssertEqual(extraStatsInfo.sortOrdersRankings.count, 0)

        // firstSortOrderInfo is an orphan and should be deleted
        XCTAssertNil(firstSortOrderInfo.managedObjectContext)

        // Should be able to delete
        persistentContainer.viewContext.delete(secondRanking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // extraStatsInfo and secondSortOrderInfo are orphans and should be deleted
        XCTAssertNil(extraStatsInfo.managedObjectContext)
        XCTAssertNil(secondSortOrderInfo.managedObjectContext)
    }

    func test_delete_qualStatus() {
        let event = insertDistrictEvent()
        let model = TBAEventRanking(teamKey: "frc1", rank: 2)
        let eventStatusModel = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let qualStatusModel = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)

        let ranking = EventRanking.insert(model, sortOrderInfo: nil, extraStatsInfo: nil, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToRankingsRaw(ranking)

        let eventStatus = EventStatus.insert(eventStatusModel, in: persistentContainer.viewContext)
        let qualStatus = EventStatusQual.insert(qualStatusModel, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)
        eventStatus.qualRaw = qualStatus
        eventStatus.eventRaw = event
        ranking.qualStatusRaw = qualStatus

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
        event.addToRankingsRaw(ranking)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(ranking.isOrphaned)
        event.removeFromRankingsRaw(ranking)

        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        status.rankingRaw = ranking
        // Attached to a Status - should not be orphaned
        XCTAssertFalse(ranking.isOrphaned)
        status.rankingRaw = nil

        // Not attached to an Event or Status - should be orphaned
        XCTAssert(ranking.isOrphaned)
    }

    func test_tiebreakerInfoString() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(ranking.rankingInfoString)

        let extraStats = [("Value 4", 0), ("Value 6", 1), ("Value 5", 3), ("Value Extra", 4)]
        let extraStatsValues: [NSNumber] = [2, 3, 49.999]

        let sortOrders = [("Value 1", 0), ("Value 2", 1), ("Value 3", 2)]
        let sortOrderValues: [NSNumber] = [1.00, 2.2, 3.33, -1]

        // Needs both keys and values
        ranking.sortOrdersInfoRaw = NSOrderedSet(array: sortOrders.map {
            let (name, precision) = $0
            let info = EventRankingStatInfo(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
            info.nameRaw = name
            info.precisionRaw = NSNumber(value: precision)
            return info
        })
        XCTAssertNil(ranking.rankingInfoString)
        ranking.sortOrdersInfoRaw = nil

        ranking.sortOrdersRaw = NSOrderedSet(array: sortOrderValues.map {
            let stat = EventRankingStat(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
            stat.valueRaw = $0
            return stat
        })
        XCTAssertNil(ranking.rankingInfoString)
        ranking.sortOrdersRaw = nil

        ranking.extraStatsInfoRaw = NSOrderedSet(array: extraStats.map {
            let (name, precision) = $0
            let info = EventRankingStatInfo(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
            info.nameRaw = name
            info.precisionRaw = NSNumber(value: precision)
            return info
        })
        XCTAssertNil(ranking.rankingInfoString)
        ranking.extraStatsInfoRaw = nil

        ranking.extraStatsRaw = NSOrderedSet(array: extraStatsValues.map {
            let stat = EventRankingStat(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
            stat.valueRaw = $0
            return stat
        })
        XCTAssertNil(ranking.rankingInfoString)

        // Only with extra stats
        ranking.extraStatsInfoRaw = NSOrderedSet(array: extraStats.map {
            let (name, precision) = $0
            let info = EventRankingStatInfo(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
            info.nameRaw = name
            info.precisionRaw = NSNumber(value: precision)
            return info
        })
        XCTAssertEqual(ranking.rankingInfoString, "Value 4: 2, Value 6: 3.0, Value 5: 49.999")
        ranking.extraStatsRaw = nil
        ranking.extraStatsInfoRaw = nil

        // Only with tiebreaker info
        ranking.sortOrdersInfoRaw = NSOrderedSet(array: sortOrders.map {
            let (name, precision) = $0
            let info = EventRankingStatInfo(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
            info.nameRaw = name
            info.precisionRaw = NSNumber(value: precision)
            return info
        })
        ranking.sortOrdersRaw = NSOrderedSet(array: sortOrderValues.map {
            let stat = EventRankingStat(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
            stat.valueRaw = $0
            return stat
        })
        XCTAssertEqual(ranking.rankingInfoString, "Value 1: 1, Value 2: 2.2, Value 3: 3.33")

        // Show with both
        ranking.extraStatsInfoRaw = NSOrderedSet(array: extraStats.map {
            let (name, precision) = $0
            let info = EventRankingStatInfo(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
            info.nameRaw = name
            info.precisionRaw = NSNumber(value: precision)
            return info
        })
        ranking.extraStatsRaw = NSOrderedSet(array: extraStatsValues.map {
            let stat = EventRankingStat(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
            stat.valueRaw = $0
            return stat
        })
        XCTAssertEqual(ranking.rankingInfoString, "Value 4: 2, Value 6: 3.0, Value 5: 49.999, Value 1: 1, Value 2: 2.2, Value 3: 3.33")
    }

}
