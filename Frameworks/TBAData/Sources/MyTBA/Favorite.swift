import CoreData
import Foundation
import MyTBAKit

@objc(Favorite)
public class Favorite: MyTBAEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

}

extension Favorite {

    @discardableResult
    public static func insert(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Favorite {
        let predicate = favoritePredicate(modelKey: modelKey, modelType: modelType)

        return findOrCreate(in: context, matching: predicate) { (favorite) in
            // Required: key, type
            favorite.modelKey = modelKey
            favorite.modelType = modelType
        }
    }

}
