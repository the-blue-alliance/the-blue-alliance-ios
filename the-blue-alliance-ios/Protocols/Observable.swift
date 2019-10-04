import CoreData
import Foundation
import TBAData

// Observable describes a class that observes changes to Core Data object(s)
// If you're looking to observe changes to a set of Core Data objects, use a Data Controllers
protocol Observable: Persistable {
    associatedtype ManagedType: NSManagedObject

    var contextObserver: CoreDataContextObserver<ManagedType> { get }
}
