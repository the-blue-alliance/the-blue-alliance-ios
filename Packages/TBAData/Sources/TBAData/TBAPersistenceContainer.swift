import Foundation
import CoreData

let AppGroupIdentifier = "group.com.the-blue-alliance.tba.tbadata"

public class TBAPersistenceContainer: NSPersistentContainer {

    override open class func defaultDirectoryURL() -> URL {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier) {
            return appGroupURL
        }
        return super.defaultDirectoryURL()
    }

    private static let managedObjectModel: NSManagedObjectModel? = {
        return NSManagedObjectModel.mergedModel(from: [Bundle.module])
    } ()

    override public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }

    public init() {
        guard let managedObjectModel = TBAPersistenceContainer.managedObjectModel else {
            fatalError("Could not load model")
        }
        super.init(name: "TBA", managedObjectModel: managedObjectModel)
    }

    override public func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return context
    }

}
