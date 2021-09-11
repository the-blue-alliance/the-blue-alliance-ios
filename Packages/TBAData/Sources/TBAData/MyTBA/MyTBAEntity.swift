import CoreData
import Foundation
import Search
import MyTBAKit

extension MyTBAEntity {

    public var modelKey: String {
        guard let modelKey = getValue(\MyTBAEntity.modelKeyRaw) else {
            fatalError("Save MyTBAEntity before accessing modelKey")
        }
        return modelKey
    }

    public var modelType: MyTBAModelType? {
        guard let modelTypeInt = getValue(\MyTBAEntity.modelTypeRaw)?.intValue else {
            fatalError("Save MyTBAEntity before accessing modelType")
        }
        guard let modelType = MyTBAModelType(rawValue: modelTypeInt) else {
            return nil
        }
        return modelType
    }

    /**
     Get the corresponding object for this myTBA Entity, if it exists locally - a Event, Team, or Match
     */
    public var tbaObject: (NSManagedObject & Managed)? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }

        switch modelType {
        case .event:
            return Event.findOrFetch(in: managedObjectContext, matching: Event.predicate(key: modelKey))
        case .team:
            return Team.findOrFetch(in: managedObjectContext, matching: Team.predicate(key: modelKey))
        case .match:
            return Match.findOrFetch(in: managedObjectContext, matching: Match.predicate(key: modelKey))
        default:
            return nil
        }
    }

}

@objc(MyTBAEntity)
public class MyTBAEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTBAEntity> {
        return NSFetchRequest<MyTBAEntity>(entityName: MyTBAEntity.entityName)
    }

    @NSManaged var modelKeyRaw: String?
    @NSManaged var modelTypeRaw: NSNumber?

}

public protocol MyTBAManaged: Managed {
    associatedtype MyType: NSManagedObject
    associatedtype RemoteType: MyTBAModel

    @discardableResult
    static func insert(_ models: [RemoteType], in context: NSManagedObjectContext) -> [MyType]
    static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> MyType?
}

extension MyTBAEntity: Managed {

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        guard let managedObjectContext = managedObjectContext else {
            return
        }

        if modelType == .match {
            let matchObjects = MyTBAEntity.fetch(in: managedObjectContext) {
                $0.predicate = NSPredicate(format: "%K == %@ AND %K == %ld",
                                           #keyPath(MyTBAEntity.modelKeyRaw), modelKey,
                                           #keyPath(MyTBAEntity.modelTypeRaw), MyTBAModelType.match.rawValue)
            }
            if matchObjects.isEmpty, let match = Match.findOrFetch(in: managedObjectContext, matching: Match.predicate(key: modelKey)), match.event == nil {
                // Match will become an orphan - delete
                managedObjectContext.delete(match)
            }
        }
    }

}

extension Searchable where Self: NSManagedObject & MyTBASubscribable {

    public var userCurated: Bool {
        guard let managedObjectContext = managedObjectContext else {
            return false
        }
        return Favorite.findOrFetch(in: managedObjectContext, matching: Favorite.favoritePredicate(modelKey: modelKey, modelType: modelType)) != nil
    }

}

extension MyTBAEntity {

    public static func supportedModelTypePredicate() -> NSPredicate {
        return NSPredicate(format: "%K IN %@",
                           #keyPath(MyTBAEntity.modelTypeRaw),
                           [MyTBAModelType.event, MyTBAModelType.team, MyTBAModelType.match].map({ $0.rawValue }))
    }

    public static func sortDescriptors() -> [NSSortDescriptor] {
        return [
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelTypeRaw), ascending: true),
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelKeyRaw), ascending: true)
        ]
    }

    public static func modelTypeKeyPath() -> String {
        return #keyPath(MyTBAEntity.modelTypeRaw)
    }

    internal static func modelKeyPredicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(MyTBAEntity.modelKeyRaw), key)
    }

}
