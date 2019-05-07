import Foundation
import CoreData

public class TBAPersistenceContainer: NSPersistentContainer {

    public override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }

    public init() {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil) else {
            fatalError("Could not load model")
        }
        super.init(name: "TBA", managedObjectModel: managedObjectModel)
    }

    public override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return context
    }

}
