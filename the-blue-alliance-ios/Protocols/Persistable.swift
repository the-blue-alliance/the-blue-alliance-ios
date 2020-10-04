import Foundation
import CoreData

// Persistable describes a class that uses a persistent data store
protocol Persistable: AnyObject {
    var persistentContainer: NSPersistentContainer { get }
}
