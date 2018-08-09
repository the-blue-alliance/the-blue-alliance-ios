import Foundation
import CoreData
import Crashlytics

extension NSManagedObjectContext {

    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    public func saveContext() {
        try! save()
    }

    public func performSaveContext() {
        perform {
            self.saveContext()
        }
    }

    public func performChanges(block: @escaping () -> Void) {
        perform {
            block()
            self.saveContext()
        }
    }

}
