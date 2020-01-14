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

    func insertAvatar() -> TeamMedia {
        let avatarData = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEgAACxIB0t1+/AAAAXxJREFUWEft1sFOwzAQRdGCYMP/fyBrVlQgdlA8VSZ6mVwntuNIXhTpiOZ5Yk+sNOkl/d0Gh+FIMBwJhpteRQqQj9P5lTDc9FeBzq+EYRY1UYLmKoQhooVr0bw7MFzRRb6Tt+nzR6LjfuyszuqNn6vjBTBc8MV1AW8w1vhx5PV7dQDDBZ+04epXGubCcNazOdO1wd7NGb8nfW6qCTC8692cejR4VJcGrbkzGyycG8PZGQ0+JxXzYjgSDGd+r7jf5Jp8Tf8/k1hTotsO2nNLj2kxozU/U6ZiQ3HeDRjObOInOY4LOz2HxrVBm6/bDtqvE71aWtzoOTRut4TWxF89GzBcsAX0M4n10Xui41q/A8MFndDfpS63E1pjdOzUBnvo3qDtQMW3blfc0R0YrlROmtUwD4boaJON52OYZYu8hKzEgYvDMKt1oUeDqvaxc/AxheGm4Rs0pe/SinduDoZFbGdy95aNHdw5h2Gx+G52VNsIw5FgOBIMR4LhIC63f5+pFSb1yhjZAAAAAElFTkSuQmCC"
        let modelMedia = TBAMedia(
            key: "avatar_2018_frc7332",
            type: "avatar",
            foreignKey: nil,
            details: ["base64Image": avatarData],
            preferred: false,
            directURL: "",
            viewURL: ""
        )
        return TeamMedia.insert(modelMedia, year: 2018, in: persistentContainer.viewContext)
    }

}
