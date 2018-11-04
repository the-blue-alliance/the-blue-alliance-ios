import CoreData
import Foundation

extension Favorite: MyTBAManaged {

    /**
     Insert a Favorite with values from a MyTBA Favorite model in to the managed object context.

     - Parameter model: The MyTBA Favorite representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Favorite.
     */
    @discardableResult
    static func insert(_ model: MyTBAFavorite, in context: NSManagedObjectContext) -> Favorite {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@",
                                    #keyPath(Favorite.modelKey), model.modelKey,
                                    #keyPath(Favorite.modelType), model.modelType.rawValue)

        return findOrCreate(in: context, matching: predicate) { (favorite) in
            // Required: key, type
            favorite.modelKey = model.modelKey
            favorite.modelType = model.modelType.rawValue
        }
    }

    func toRemoteModel() -> MyTBAFavorite {
        return MyTBAFavorite(modelKey: modelKey!, modelType: MyTBAModelType(rawValue: modelType!)!)
    }

    var isOrphaned: Bool {
        // We manage the deletion of these root objects ourselves
        return false
    }

}
