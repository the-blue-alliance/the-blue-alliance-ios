import XCTest
import Foundation
import CoreData
import The_Blue_Alliance

class CoreDataTestCase: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        managedObjectContext = setUpInMemoryManagedObjectContext()
    }

    override func tearDown() {
        managedObjectContext = nil

        super.tearDown()
    }

    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [.main])

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return managedObjectContext
    }

}

extension Managed where Self: NSManagedObject {

    public static func testInsert(in context: NSManagedObjectContext) -> Self {
        // TODO: This isn't great, but entity() is crashing and saying it's uninitlized
        let entityName = String(describing: Self.self)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }

}
