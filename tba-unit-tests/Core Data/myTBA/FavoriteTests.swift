import Foundation
import XCTest
@testable import TBA

class FavoriteTestCase: CoreDataTestCase {

    func test_predicate() {
        let predicate = Favorite.favoritePredicate(modelKey: "frc2337", modelType: .team)
        XCTAssertEqual(predicate.predicateFormat, "modelKey == \"frc2337\" AND modelTypeRaw == 1")
    }

    func test_insert_array() {
        let modelFavoriteOne = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let modelFavoriteTwo = MyTBAFavorite(modelKey: "2017miket", modelType: .event)

        Favorite.insert([modelFavoriteOne, modelFavoriteTwo], in: persistentContainer.viewContext)
        let favories = Favorite.fetch(in: persistentContainer.viewContext)

        let favoriteOne = favories.first(where: { $0.modelKey == "2018miket" })!
        let favoriteTwo = favories.first(where: { $0.modelKey == "2017miket" })!

        // Sanity check
        XCTAssertNotEqual(favoriteOne, favoriteTwo)

        Favorite.insert([modelFavoriteTwo], in: persistentContainer.viewContext)
        let favoriesSecond = Favorite.fetch(in: persistentContainer.viewContext)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        XCTAssertEqual(favoriesSecond, [favoriteTwo])

        // FavoriteOne should be deleted
        XCTAssertNil(favoriteOne.managedObjectContext)

        // FavoriteTwo should not be deleted
        XCTAssertNotNil(favoriteTwo.managedObjectContext)
    }

    func test_insert_model() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: persistentContainer.viewContext)

        XCTAssertEqual(favorite.modelKey, "2018miket")
        XCTAssertEqual(favorite.modelType, .event)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_values() {
        let favorite = Favorite.insert(modelKey: "2018miket", modelType: .event, in: persistentContainer.viewContext)

        XCTAssertEqual(favorite.modelKey, "2018miket")
        XCTAssertEqual(favorite.modelType, .event)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favoriteOne = Favorite.insert(model, in: persistentContainer.viewContext)
        let favoriteTwo = Favorite.insert(modelKey: model.modelKey, modelType: model.modelType, in: persistentContainer.viewContext)

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
