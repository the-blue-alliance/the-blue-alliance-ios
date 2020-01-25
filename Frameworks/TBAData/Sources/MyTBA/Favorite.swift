import CoreData
import Foundation
import MyTBAKit

@objc(Favorite)
public class Favorite: MyTBAEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: Favorite.entityName)
    }

}

extension Favorite {

    /**
     Insert Favorites with values from myTBA Favorite models in to the managed object context.

     This method manages deleting old Favorites.

     - Parameter favories: The myTBA Favorite representations to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The array of inserted Favorites.
     */
    @discardableResult
    public static func insert(_ favories: [MyTBAFavorite], in context: NSManagedObjectContext) -> [Favorite] {
        // Fetch all of the previous Favorites
        let oldFavorites = Favorite.fetch(in: context)

        // Insert new Favorites
        let favories = favories.map({
            return Favorite.insert($0, in: context)
        })

        // Delete orphaned Favorites
        Set(oldFavorites).subtracting(Set(favories)).forEach({
            context.delete($0)
        })

        return favories
    }

    /**
     Insert a Favorite with values from a myTBA Favorite model in to the managed object context.

     - Parameter model: The myTBA Favorite representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Favorite.
     */
    @discardableResult
    public static func insert(_ model: MyTBAFavorite, in context: NSManagedObjectContext) -> Favorite {
        return insert(modelKey: model.modelKey, modelType: model.modelType, in: context)
    }

    @discardableResult
    public static func insert(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Favorite {
        let predicate = favoritePredicate(modelKey: modelKey, modelType: modelType)

        return findOrCreate(in: context, matching: predicate) { (favorite) in
            // Required: key, type
            favorite.modelKeyRaw = modelKey
            favorite.modelTypeRaw = NSNumber(value: modelType.rawValue)
        }
    }

}

extension Favorite {

    static func favoritePredicate(modelKey: String, modelType: MyTBAModelType) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %ld",
                           #keyPath(Favorite.modelKeyRaw), modelKey,
                           #keyPath(Favorite.modelTypeRaw), modelType.rawValue)
    }

    public static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Favorite? {
        let predicate = favoritePredicate(modelKey: modelKey, modelType: modelType)
        return findOrFetch(in: context, matching: predicate)
    }

    public static func favoriteTeamKeys(in context: NSManagedObjectContext) -> [String] {
        return Favorite.fetch(in: context, configurationBlock: { (fetchRequest) in
            fetchRequest.predicate = NSPredicate(format: "%K == %ld",
                                                 #keyPath(Favorite.modelTypeRaw), MyTBAModelType.team.rawValue)
        }).compactMap({ $0.modelKey })
    }

}

extension Favorite: MyTBAManaged {}
