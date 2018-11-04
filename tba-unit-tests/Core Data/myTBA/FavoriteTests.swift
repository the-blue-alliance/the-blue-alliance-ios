import Foundation
import XCTest
@testable import The_Blue_Alliance

class FavoriteTestCase: CoreDataTestCase {

    func test_insert() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(favorite.modelKey, "2018miket")
        XCTAssertEqual(favorite.modelType, "0")

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favoriteOne = Favorite.insert(model, in: persistentContainer.viewContext)
        let favoriteTwo = Favorite.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(favoriteOne, favoriteTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: persistentContainer.viewContext)

        persistentContainer.viewContext.delete(favorite)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_toRemoteModel() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: persistentContainer.viewContext)
        XCTAssertEqual(model, favorite.toRemoteModel())
    }

    func test_isOrphaned() {
        let favorite = Favorite.init(entity: Favorite.entity(), insertInto: persistentContainer.viewContext)
        // Favorite should never be orphaned
        XCTAssertFalse(favorite.isOrphaned)
    }

}
