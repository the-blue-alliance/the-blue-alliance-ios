import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventRankingStatInfoTests: TBADataTestCase {

    func test_name() {
        let statInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        statInfo.nameRaw = "qual"
        XCTAssertEqual(statInfo.name, "qual")
    }

    func test_precision() {
        let statInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        statInfo.precisionRaw = NSNumber(value: 1)
        XCTAssertEqual(statInfo.precision, 1)
    }

    func test_extraStatsRankings() {
        let statInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(statInfo.extraStatsRankings, [])
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        statInfo.extraStatsRankingsRaw = NSSet(array: [ranking])
        XCTAssertEqual(statInfo.extraStatsRankings, [ranking])
    }

    func test_sortOrdersRankings() {
        let statInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(statInfo.sortOrdersRankings, [])
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        statInfo.sortOrdersRankingsRaw = NSSet(array: [ranking])
        XCTAssertEqual(statInfo.sortOrdersRankings, [ranking])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventRankingStatInfo> = EventRankingStatInfo.fetchRequest()
        XCTAssertEqual(fr.entityName, EventRankingStatInfo.entityName)
    }

    func test_insert_empty() {
        // Should throw an error - cannot save empty
        let emptySortOrderInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        emptySortOrderInfo.nameRaw = "some name"
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        emptySortOrderInfo.nameRaw = nil
        emptySortOrderInfo.precisionRaw = 2
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
    }

    func test_insert() {
        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)

        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(sortOrderInfo.name, "sort order")
        XCTAssertEqual(sortOrderInfo.precision, 2)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelOne = TBAEventRankingSortOrder(name: "sort order", precision: 2)
        let modelTwo = TBAEventRankingSortOrder(name: "sort order", precision: 3)

        let sortOrderOne = EventRankingStatInfo.insert(modelOne, in: persistentContainer.viewContext)
        let sortOrderTwo = EventRankingStatInfo.insert(modelTwo, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertNotEqual(sortOrderOne, sortOrderTwo)

        let sortOrderThree = EventRankingStatInfo.insert(modelOne, in: persistentContainer.viewContext)
        XCTAssertEqual(sortOrderOne, sortOrderThree)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let ranking = insertEventRaking()

        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)
        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Don't allow deletion with sortOrders
        sortOrderInfo.addToSortOrdersRankingsRaw(ranking)
        persistentContainer.viewContext.delete(sortOrderInfo)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        sortOrderInfo.removeFromSortOrdersRankingsRaw(ranking)

        sortOrderInfo.addToExtraStatsRankingsRaw(ranking)
        persistentContainer.viewContext.delete(sortOrderInfo)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        sortOrderInfo.removeFromExtraStatsRankingsRaw(ranking)

        persistentContainer.viewContext.delete(sortOrderInfo)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_isOrphaned() {
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)

        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)
        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssert(sortOrderInfo.isOrphaned)

        // Has sortOrders - is not an oprhan
        sortOrderInfo.addToSortOrdersRankingsRaw(ranking)
        XCTAssertFalse(sortOrderInfo.isOrphaned)
        sortOrderInfo.removeFromSortOrdersRankingsRaw(ranking)

        // Sanity check
        XCTAssert(sortOrderInfo.isOrphaned)

        // Has extraStats - is not an orphan
        sortOrderInfo.addToExtraStatsRankingsRaw(ranking)
        XCTAssertFalse(sortOrderInfo.isOrphaned)
        sortOrderInfo.removeFromExtraStatsRankingsRaw(ranking)

        // No sortOrders or extraStats - is an orphan
        XCTAssert(sortOrderInfo.isOrphaned)
    }

}
