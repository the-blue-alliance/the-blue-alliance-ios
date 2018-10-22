import Foundation
import CoreData
import TBAKit

protocol MyTBAManaged: Managed {
    associatedtype MyType: NSManagedObject
    associatedtype RemoteType: MyTBAModel

    @discardableResult static func insert(with model: RemoteType, in context: NSManagedObjectContext) -> MyType
    func toRemoteModel() -> RemoteType
}

extension Favorite: MyTBAManaged {

    @discardableResult
    static func insert(with model: MyTBAFavorite, in context: NSManagedObjectContext) -> Favorite {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@", #keyPath(Favorite.modelKey), model.modelKey, #keyPath(Favorite.modelType), model.modelType.rawValue)
        return findOrCreate(in: context, matching: predicate) { (favorite) in
            // Required: key, type
            favorite.modelKey = model.modelKey
            favorite.modelType = model.modelType.rawValue
        }
    }

    func toRemoteModel() -> MyTBAFavorite {
        return MyTBAFavorite(modelKey: modelKey!, modelType: MyTBAModelType(rawValue: modelType!)!)
    }
}
