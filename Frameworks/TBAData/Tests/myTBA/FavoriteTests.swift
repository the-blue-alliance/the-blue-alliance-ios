import MyTBAKit
import TBAData
import XCTest

class FavoriteTestCase: TBADataTestCase {

    func test_predicate() {
        let predicate = Favorite.favoritePredicate(modelKey: "frc2337", modelType: .team)
        XCTAssertEqual(predicate.predicateFormat, "modelKey == \"frc2337\" AND modelTypeRaw == 1")
    }

    func test_insert_array() {
        let modelFavoriteOne = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let modelFavoriteTwo = MyTBAFavorite(modelKey: "2017miket", modelType: .event)

        Favorite.insert([modelFavoriteOne, modelFavoriteTwo], in: viewContext)
        let favories = Favorite.fetch(in: viewContext)

        let favoriteOne = favories.first(where: { $0.modelKey == "2018miket" })!
        let favoriteTwo = favories.first(where: { $0.modelKey == "2017miket" })!

        // Sanity check
        XCTAssertNotEqual(favoriteOne, favoriteTwo)

        Favorite.insert([modelFavoriteTwo], in: viewContext)
        let favoriesSecond = Favorite.fetch(in: viewContext)

        XCTAssertNoThrow(try viewContext.save())

        XCTAssertEqual(favoriesSecond, [favoriteTwo])

        // FavoriteOne should be deleted
        XCTAssertNil(favoriteOne.managedObjectContext)

        // FavoriteTwo should not be deleted
        XCTAssertNotNil(favoriteTwo.managedObjectContext)
    }

    func test_insert_model() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: viewContext)

        XCTAssertEqual(favorite.modelKey, "2018miket")
        XCTAssertEqual(favorite.modelType, .event)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insert_values() {
        let favorite = Favorite.insert(modelKey: "2018miket", modelType: .event, in: viewContext)

        XCTAssertEqual(favorite.modelKey, "2018miket")
        XCTAssertEqual(favorite.modelType, .event)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_update() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favoriteOne = Favorite.insert(model, in: viewContext)
        let favoriteTwo = Favorite.insert(modelKey: model.modelKey, modelType: model.modelType, in: viewContext)

        XCTAssertEqual(favoriteOne, favoriteTwo)

        XCTAssertNoThrow(try viewContext.save())
    }

    func test_delete() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: viewContext)

        viewContext.delete(favorite)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_toRemoteModel() {
        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        let favorite = Favorite.insert(model, in: viewContext)
        XCTAssertEqual(model, favorite.toRemoteModel())
    }

    func test_isOrphaned() {
        let favorite = Favorite.init(entity: Favorite.entity(), insertInto: viewContext)
        // Favorite should never be orphaned
        XCTAssertFalse(favorite.isOrphaned)
    }

}
