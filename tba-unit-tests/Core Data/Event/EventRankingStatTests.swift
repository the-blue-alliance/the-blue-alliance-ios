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
