import CoreData
import MyTBAKit

public protocol MyTBAManaged: Managed {
    associatedtype MyType: NSManagedObject
    associatedtype RemoteType: MyTBAModel

    @discardableResult
    static func insert(_ models: [RemoteType], in context: NSManagedObjectContext) -> [MyType]
    static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> MyType?

    func toRemoteModel() -> RemoteType
}

extension MyTBAEntity {

    /**
     Get the corresponding object for this myTBA Entity, if it exists locally - a Event, Team, or Match
     */
    public var tbaObject: (NSManagedObject & Managed)? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }

        switch modelType {
        case .event:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Event.key), modelKey)
            return Event.findOrFetch(in: managedObjectContext, matching: predicate)
        case .team:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Team.key), modelKey)
            return Team.findOrFetch(in: managedObjectContext, matching: predicate)
        case .match:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Match.key), modelKey)
            return Match.findOrFetch(in: managedObjectContext, matching: predicate)
        default:
            return nil
        }
    }

}

extension MyTBAEntity: Managed {

    public var isOrphaned: Bool {
        return false
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        guard let managedObjectContext = managedObjectContext else {
            return
        }

        if modelTypeRaw.intValue == MyTBAModelType.match.rawValue {
            let matchObjects = MyTBAEntity.fetch(in: managedObjectContext) {
                $0.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                           #keyPath(MyTBAEntity.modelKey), modelKey,
                                           #keyPath(MyTBAEntity.modelTypeRaw), modelTypeRaw)
            }
            if matchObjects.isEmpty, let match = Match.findOrFetch(in: managedObjectContext, matching: Match.predicate(key: modelKey)), match.event == nil {
                // Match will become an orphan - delete
                managedObjectContext.delete(match)
            }
        }
    }

}
