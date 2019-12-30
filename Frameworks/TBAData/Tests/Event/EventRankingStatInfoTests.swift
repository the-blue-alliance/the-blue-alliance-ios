//import TBAData
//import TBADataTesting
//import TBAKit
//import XCTest
//
//class EventRankingStatInfoTests: TBADataTestCase {
//
//    func test_insert_empty() {
//        // Should throw an error - cannot save empty
//        let emptySortOrderInfo = EventRankingStatInfo.init(entity: EventRankingStatInfo.entity(), insertInto: persistentContainer.viewContext)
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//
//        emptySortOrderInfo.name = "some name"
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//
//        emptySortOrderInfo.name = nil
//        emptySortOrderInfo.precision = 2
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//    }
//
//    func test_insert() {
//        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)
//
//        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)
//
//        XCTAssertEqual(sortOrderInfo.name, "sort order")
//        XCTAssertEqual(sortOrderInfo.precision, 2)
//
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//    }
//
//    func test_update() {
//        let modelOne = TBAEventRankingSortOrder(name: "sort order", precision: 2)
//        let modelTwo = TBAEventRankingSortOrder(name: "sort order", precision: 3)
//
//        let sortOrderOne = EventRankingStatInfo.insert(modelOne, in: persistentContainer.viewContext)
//        let sortOrderTwo = EventRankingStatInfo.insert(modelTwo, in: persistentContainer.viewContext)
//
//        // Sanity check
//        XCTAssertNotEqual(sortOrderOne, sortOrderTwo)
//
//        let sortOrderThree = EventRankingStatInfo.insert(modelOne, in: persistentContainer.viewContext)
//        XCTAssertEqual(sortOrderOne, sortOrderThree)
//
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//    }
//
//    func test_delete() {
//        let ranking = insertEventRaking()
//
//        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)
//        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)
//
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//
//        // Don't allow deletion with sortOrders
//        sortOrderInfo.addToSortOrdersRankings(ranking)
//        persistentContainer.viewContext.delete(sortOrderInfo)
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//        sortOrderInfo.removeFromSortOrdersRankings(ranking)
//
//        sortOrderInfo.addToExtraStatsRankings(ranking)
//        persistentContainer.viewContext.delete(sortOrderInfo)
//        XCTAssertThrowsError(try persistentContainer.viewContext.save())
//        sortOrderInfo.removeFromExtraStatsRankings(ranking)
//
//        persistentContainer.viewContext.delete(sortOrderInfo)
//        XCTAssertNoThrow(try persistentContainer.viewContext.save())
//    }
//
//    func test_isOrphaned() {
//        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
//
//        let model = TBAEventRankingSortOrder(name: "sort order", precision: 2)
//        let sortOrderInfo = EventRankingStatInfo.insert(model, in: persistentContainer.viewContext)
//
//        // Sanity check
//        XCTAssert(sortOrderInfo.isOrphaned)
//
//        // Has sortOrders - is not an oprhan
//        sortOrderInfo.addToSortOrdersRankings(ranking)
//        XCTAssertFalse(sortOrderInfo.isOrphaned)
//        sortOrderInfo.removeFromSortOrdersRankings(ranking)
//
//        // Sanity check
//        XCTAssert(sortOrderInfo.isOrphaned)
//
//        // Has extraStats - is not an orphan
//        sortOrderInfo.addToExtraStatsRankings(ranking)
//        XCTAssertFalse(sortOrderInfo.isOrphaned)
//        sortOrderInfo.removeFromExtraStatsRankings(ranking)
//
//        // No sortOrders or extraStats - is an orphan
//        XCTAssert(sortOrderInfo.isOrphaned)
//    }
//
//}
