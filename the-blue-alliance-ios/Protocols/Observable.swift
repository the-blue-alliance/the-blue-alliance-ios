import Foundation
import CoreData

// Observable describes a class that observes changes to Core Data object(s)
// If you're looking to observe changes to a set of Core Data objects, use a Data Controllers
protocol Observable: Persistable {
    associatedtype ManagedType: NSManagedObject
    
    var contextObserver: CoreDataContextObserver<ManagedType> { get }
    var observerPredicate: NSPredicate { get }
}

extension Observable {
    
    // Make observerPredicate optional
    var observerPredicate: NSPredicate {
        return NSPredicate()
    }
}
