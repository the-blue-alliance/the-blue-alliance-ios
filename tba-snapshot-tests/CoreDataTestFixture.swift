import CoreData
import Foundation
import TBAKit
import XCTest
@testable import The_Blue_Alliance

class CoreDataTestFixture {

    private static let managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModel(from: [Bundle.main])!
    } ()
    let persistentContainer: TBAPersistenceContainer = {
        let persistentContainer = TBAPersistenceContainer(name: "TBA", managedObjectModel: CoreDataTestFixture.managedObjectModel)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        description.configuration = "Default"
        persistentContainer.persistentStoreDescriptions = [description]

        let persistentContainerSetupExpectation = XCTestExpectation()
        persistentContainer.loadPersistentStores(completionHandler: { (_, _) in
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        })
        return persistentContainer
    }()

    private var saveNotificationCompleteHandler: ((Notification, NSManagedObjectContext)->())?

    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func contextSaved(notification: Notification) {
        saveNotificationCompleteHandler?(notification, notification.object as! NSManagedObjectContext)
    }

    func waitForSavedNotification(completeHandler: @escaping ((Notification, NSManagedObjectContext)->()) ) {
        saveNotificationCompleteHandler = completeHandler
    }

    func viewContextSaveExpectation() -> XCTestExpectation {
        let saveExpectation = XCTestExpectation(description: "View context saved")
        waitForSavedNotification { (notification, context) in
            // Check that we saved the view context
            guard context == self.persistentContainer.viewContext else {
                return
            }
            saveExpectation.fulfill()
        }
        return saveExpectation
    }

    func backgroundContextSaveExpectation() -> XCTestExpectation {
        let saveExpectation = XCTestExpectation(description: "Background context saved")
        waitForSavedNotification { (notification, context) in
            // Check that we saved the background context
            guard context.concurrencyType == .privateQueueConcurrencyType else {
                return
            }
            saveExpectation.fulfill()
        }
        return saveExpectation
    }

    // Insert Helpers

    func insertTeam() -> Team {
        let team = TBATeam(key: "frc7332",
                           teamNumber: 7332,
                           nickname: "The Rawrbotz",
                           name: "General Motors/Premier Tooling Systems/Microsoft/The Chrysler Foundation/Davison Tool & Engineering, L.L.C./The Robot Space/Michigan Department of Education/Kettering University/Taylor Steel/DXC Technology/Complete Scrap/ZF North America & Grand Blanc Community High School",
                           city: "Anytown",
                           stateProv: "MI",
                           country: "USA",
                           address: nil,
                           postalCode: nil,
                           gmapsPlaceID: nil,
                           gmapsURL: nil,
                           lat: nil,
                           lng: nil,
                           locationName: nil,
                           website: nil,
                           rookieYear: 2010,
                           homeChampionship: nil)
        return Team.insert(team, in: persistentContainer.viewContext)
    }

}
