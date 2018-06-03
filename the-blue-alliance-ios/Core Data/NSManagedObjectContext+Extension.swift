import Foundation
import CoreData
import Crashlytics

extension NSManagedObjectContext {
    
    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            print(error)
            Crashlytics.sharedInstance().recordError(error)
            rollback()
            return false
        }
    }
    
    public func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }
    
    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
    
}
