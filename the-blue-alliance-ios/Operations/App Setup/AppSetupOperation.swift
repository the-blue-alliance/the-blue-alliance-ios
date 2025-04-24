import CoreData
import Foundation
import UIKit

struct AppSetupOperation {

    var destroyPersistentStoreOperation: DestroyPersistentStoreOperation
    var persistentContainerOperation: PersistentContainerOperation

    init(persistentContainer: NSPersistentContainer, userDefaults: UserDefaults) {
        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.destroyPersistentStoreOperation = DestroyPersistentStoreOperation(persistentContainer: persistentContainer, userDefaults: userDefaults)
    }

    func execute() async throws {
        _ = try await persistentContainerOperation.execute()
        try await destroyPersistentStoreOperation.execute()
    }

}
