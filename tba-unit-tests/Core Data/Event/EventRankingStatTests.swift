import XCTest
@testable import The_Blue_Alliance

class EventRankingStatTests: CoreDataTestCase {

    func test_insert_extraStatsRanking() {
        let ranking = insertEventRaking()
        let stat = EventRankingStat.insert(value: NSNumber(value: 20.2), extraStatsRanking: ranking, in: persistentContainer.viewContext)

        XCTAssertEqual(stat.value, 20.2)
        XCTAssertEqual(stat.extraStatsRanking, ranking)
        XCTAssertNil(stat.sortOrderRanking)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_sortOrderRanking() {
        let ranking = insertEventRaking()
        let stat = EventRankingStat.insert(value: NSNumber(value: 19), sortOrderRanking: ranking, in: persistentContainer.viewContext)

        XCTAssertEqual(stat.value, 19)
        XCTAssertEqual(stat.sortOrderRanking, ranking)
        XCTAssertNil(stat.extraStatsRanking)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_extraStatsRanking_sortOrderRanking() {
        let ranking = insertEventRaking()
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        stat.value = NSNumber(value: 2.3232)
        stat.extraStatsRanking = ranking
        stat.sortOrderRanking = ranking

        // Can only have either extraStatsRanking or sortOrderRanking
        // NOTE: We're calling viewContext.save on a non-main thread because fatalError
        // will hang our main thread forever
        expectFatalError("EventRankingStat must not have a relationship to both an extraStat and sortOrder") {
            try? self.persistentContainer.viewContext.save()
        }
    }

    func test_insert_noStats() {
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        stat.value = NSNumber(value: -1)

        // Needs either an extraStatsRanking or sortOrderRanking
        // NOTE: We're calling viewContext.save on a non-main thread because fatalError
        // will hang our main thread forever
        expectFatalError("EventRankingStat must have a relationship to either an extraStat and sortOrder") {
            try? self.persistentContainer.viewContext.save()
        }
    }

    func test_insert() {
        let _ = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)

        // value is required
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_isOrphaned() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)

        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(stat.isOrphaned)

        stat.extraStatsRanking = ranking
        XCTAssertFalse(stat.isOrphaned)
        stat.extraStatsRanking = nil

        stat.sortOrderRanking = ranking
        XCTAssertFalse(stat.isOrphaned)

        stat.extraStatsRanking = ranking
        XCTAssertFalse(stat.isOrphaned)

        stat.sortOrderRanking = nil
        stat.extraStatsRanking = nil
        XCTAssert(stat.isOrphaned)
    }

}
