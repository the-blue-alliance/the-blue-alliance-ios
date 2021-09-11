import CoreData
import MyTBAKit
import XCTest
@testable import TBAData

class FavoriteTestCase: TBADataTestCase {

    func test_fetchRequest() {
        let fr: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        XCTAssertEqual(fr.entityName, Favorite.entityName)
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

    func test_fetch() {
        let modelKey = "2018miket"
        let modelType = MyTBAModelType.event

        var favorite = Favorite.fetch(modelKey: modelKey, modelType: modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)

        let model = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        _ = Favorite.insert(model, in: persistentContainer.viewContext)

        favorite = Favorite.fetch(modelKey: modelKey, modelType: modelType, in: persistentContainer.viewContext)
        XCTAssertNotNil(favorite)

        persistentContainer.viewContext.delete(favorite!)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        favorite = Favorite.fetch(modelKey: modelKey, modelType: modelType, in: persistentContainer.viewContext)
        XCTAssertNil(favorite)
    }

    func test_favoriteTeamKeys() {
        var favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)
        XCTAssertEqual(favoriteTeamKeys, [])

        let favoriteEventModel = MyTBAFavorite(modelKey: "2018miket", modelType: .event)
        _ = Favorite.insert(favoriteEventModel, in: persistentContainer.viewContext)
        favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)
        XCTAssertEqual(favoriteTeamKeys, [])

        let favoriteTeamModel = MyTBAFavorite(modelKey: "frc7332", modelType: .team)
        _ = Favorite.insert(favoriteTeamModel, in: persistentContainer.viewContext)
        favoriteTeamKeys = Favorite.favoriteTeamKeys(in: persistentContainer.viewContext)
        XCTAssertEqual(favoriteTeamKeys, ["frc7332"])
    }

}
