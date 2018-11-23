import Foundation
import CoreData

class TBAPersistenceContainer: NSPersistentContainer {

    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }

    init() {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil) else {
            fatalError("Could not load model")
        }
        super.init(name: "TBA", managedObjectModel: managedObjectModel)
    }

    override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return context
    }

}
