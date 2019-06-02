import CoreData
import MyTBAKit

protocol MyTBAManaged: Managed {
    associatedtype MyType: NSManagedObject
    associatedtype RemoteType: MyTBAModel

    @discardableResult
    static func insert(_ models: [RemoteType], in context: NSManagedObjectContext) -> [MyType]
    static func fetch(modelKey: String, modelType: MyTBAModelType, in context: NSManagedObjectContext) -> MyType?

    func toRemoteModel() -> RemoteType
}

extension MyTBAEntity: Managed {

    var modelType: MyTBAModelType {
        get {
            return MyTBAModelType(rawValue: modelTypeRaw!.intValue)!
        }
        set {
            modelTypeRaw = newValue.rawValue as NSNumber
        }
    }

    /**
     Get the corresponding object for this myTBA Entity, if it exists locally - a Event, Team, or Match
     */
    var tbaObject: Managed? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }

        switch modelType {
        case .event:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Event.key), modelKey!)
            return Event.findOrFetch(in: managedObjectContext, matching: predicate)
        case .team:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Team.key), modelKey!)
            return Team.findOrFetch(in: managedObjectContext, matching: predicate)
        case .match:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Match.key), modelKey!)
            return Match.findOrFetch(in: managedObjectContext, matching: predicate)
        default:
            return nil
        }
    }

    var isOrphaned: Bool {
        return false
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        guard let managedObjectContext = managedObjectContext else {
            return
        }

        if let modelTypeRaw = modelTypeRaw, modelTypeRaw.intValue == MyTBAModelType.match.rawValue,
            let modelKey = modelKey {
            let matchObjects = MyTBAEntity.fetch(in: managedObjectContext) {
                $0.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                           #keyPath(MyTBAEntity.modelKey), modelKey,
                                           #keyPath(MyTBAEntity.modelTypeRaw), modelTypeRaw)
            }
            if matchObjects.isEmpty, let match = Match.findOrFetch(in: managedObjectContext, matching: Match.matchPredicate(key: modelKey)), match.event == nil {
                // Match will become an orphan - delete
                managedObjectContext.delete(match)
            }
        }
    }

}
