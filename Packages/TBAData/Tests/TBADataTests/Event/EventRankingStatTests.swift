import CoreData
import XCTest
@testable import TBAData

class EventRankingStatTests: TBADataTestCase {

    func test_value() {
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        stat.valueRaw = NSNumber(value: 20.2)
        XCTAssertEqual(stat.value, 20.2)
    }

    func test_extraStatsRanking() {
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(stat.extraStatsRanking)
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        stat.extraStatsRankingRaw = ranking
        XCTAssertEqual(stat.extraStatsRanking, ranking)
    }

    func test_sortOrderRanking() {
        let stat = EventRankingStat.init(entity: EventRankingStat.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(stat.sortOrderRanking)
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        stat.sortOrderRankingRaw = ranking
        XCTAssertEqual(stat.sortOrderRanking, ranking)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventRankingStat> = EventRankingStat.fetchRequest()
        XCTAssertEqual(fr.entityName, EventRankingStat.entityName)
    }

    func test_insert_extraStatsRanking() {
        let ranking = insertEventRaking()
        let stat = EventRankingStat.insert(value: 20.2, extraStatsRanking: ranking, in: persistentContainer.viewContext)

        XCTAssertEqual(stat.value, 20.2)
        XCTAssertEqual(stat.extraStatsRanking, ranking)
        XCTAssertNil(stat.sortOrderRanking)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_sortOrderRanking() {
        let ranking = insertEventRaking()
        let stat = EventRankingStat.insert(value: 19, sortOrderRanking: ranking, in: persistentContainer.viewContext)

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

        stat.extraStatsRankingRaw = ranking
        XCTAssertFalse(stat.isOrphaned)
        stat.extraStatsRankingRaw = nil

        stat.sortOrderRankingRaw = ranking
        XCTAssertFalse(stat.isOrphaned)

        stat.extraStatsRankingRaw = ranking
        XCTAssertFalse(stat.isOrphaned)

        stat.sortOrderRankingRaw = nil
        stat.extraStatsRankingRaw = nil
        XCTAssert(stat.isOrphaned)
    }

}
