import CoreData
import Foundation
import MyTBAKit

@objc(MyTBAEntity)
public class MyTBAEntity: NSManagedObject {

    public var modelKey: String {
        guard let modelKey = modelKeyString else {
            fatalError("Save MyTBAEntity before accessing modelKey")
        }
        return modelKey
    }

    public var modelType: MyTBAModelType? {
        guard let modelTypeInt = modelTypeNumber?.intValue else {
            fatalError("Save MyTBAEntity before accessing modelType")
        }
        guard let modelType = MyTBAModelType(rawValue: modelTypeInt) else {
            return nil
        }
        return modelType
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTBAEntity> {
        return NSFetchRequest<MyTBAEntity>(entityName: MyTBAEntity.entityName)
    }

    @NSManaged internal var modelKeyString: String?
    @NSManaged internal var modelTypeNumber: NSNumber?

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
                                           #keyPath(MyTBAEntity.modelKeyString), modelKey,
                                           #keyPath(MyTBAEntity.modelTypeNumber), MyTBAModelType.match.rawValue)
            }
            if matchObjects.isEmpty, let match = Match.findOrFetch(in: managedObjectContext, matching: Match.predicate(key: modelKey)), match.event == nil {
                // Match will become an orphan - delete
                managedObjectContext.delete(match)
            }
        }
    }

}

extension MyTBAEntity {

    public static func supportedModelTypePredicate() -> NSPredicate {
        return NSPredicate(format: "%K IN %@",
                           #keyPath(MyTBAEntity.modelTypeNumber),
                           [MyTBAModelType.event, MyTBAModelType.team, MyTBAModelType.match].map({ $0.rawValue }))
    }

    public static func sortDescriptors() -> [NSSortDescriptor] {
        return [
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelTypeNumber), ascending: true),
            NSSortDescriptor(key: #keyPath(MyTBAEntity.modelKeyString), ascending: true)
        ]
    }

    public static func modelTypeKeyPath() -> String {
        return #keyPath(MyTBAEntity.modelTypeNumber)
    }

    internal static func modelKeyPredicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(MyTBAEntity.modelKeyString), key)
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
