import XCTest
import Foundation
import CoreData
@testable import The_Blue_Alliance

class CoreDataTestCase: XCTestCase {

    private lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TBA")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            precondition( description.type == NSInMemoryStoreType )
            XCTAssertNil(error)
        }
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return mockPersistantContainer.viewContext
    }()
    
    func test_setUpInMemoryManagedObjectContext() {
        XCTAssertNotNil(managedObjectContext)
        XCTAssertNotNil(Event.insert(in: managedObjectContext))
    }

}

extension Managed where Self: NSManagedObject {

    public static func insert(in context: NSManagedObjectContext) -> Self {
        return context.insertObject()
    }
    
}
