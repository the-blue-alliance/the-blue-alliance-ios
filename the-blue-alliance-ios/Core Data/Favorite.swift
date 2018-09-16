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

    static func favoritePredicate(modelKey: String, modelType: MyTBAModelType) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@",
                           #keyPath(Favorite.modelKey),
                           modelKey,
                           #keyPath(Favorite.modelTypeRaw),
                           modelType.rawValue)
    }

    @discardableResult
    static func insert(with model: MyTBAFavorite, in context: NSManagedObjectContext) -> Favorite {
        return insert(modelKey: model.modelKey, modelType: model.modelType, in: context)
    }

    @discardableResult
    static func insert(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> Favorite {
        let predicate = favoritePredicate(modelKey: modelKey, modelType: modelType)
        return findOrCreate(in: context, matching: predicate) { (favorite) in
            // Required: key, type
            favorite.modelKey = modelKey
            favorite.modelType = modelType
        }
    }

    func toRemoteModel() -> MyTBAFavorite {
        return MyTBAFavorite(modelKey: modelKey!, modelType: modelType)
    }
}
