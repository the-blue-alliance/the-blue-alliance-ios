import CoreData
import TBAData
import MyTBAKit

extension Searchable where Self: NSManagedObject & MyTBASubscribable {

    public var userCurated: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return false
        }
        return Favorite.findOrFetch(in: managedObjectContext, matching: Favorite.favoritePredicate(modelKey: modelKey, modelType: modelType)) != nil
    }

}
