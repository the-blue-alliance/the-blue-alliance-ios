import Foundation
import CoreData

protocol MyTBAManaged: Managed {
    associatedtype MyType: NSManagedObject
    associatedtype RemoteType: MyTBAModel

    @discardableResult
    static func insert(_ models: [RemoteType], in context: NSManagedObjectContext) -> [MyType]

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

    var isOrphaned: Bool {
        return false
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        guard let managedObjectContext = managedObjectContext else {
            return
        }

        if modelType == .match {
            let matchObjects = MyTBAEntity.fetch(in: managedObjectContext) {
                $0.predicate = NSPredicate(format: "%K == %@ AND %K == %ld",
                                           #keyPath(MyTBAEntity.modelKey), modelKey!,
                                           #keyPath(MyTBAEntity.modelTypeRaw), modelType.rawValue)
            }
            if matchObjects.isEmpty, let match = Match.findOrFetch(in: managedObjectContext, matching: Match.matchPredicate(key: modelKey!)), match.event == nil {
                // Match will become an orphan - delete
                managedObjectContext.delete(match)
            }
        }
    }

}
