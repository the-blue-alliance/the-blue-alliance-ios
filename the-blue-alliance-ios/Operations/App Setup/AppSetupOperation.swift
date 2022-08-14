import CoreData
import Foundation
import Search
import TBAKit

struct AppSetupOperation {

    private let destroyPersistentStoreOperation: DestroyPersistentStoreOperation
    private let persistentContainerOperation: PersistentContainerOperation

    init(indexDelegate: TBACoreDataCoreSpotlightDelegate, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.destroyPersistentStoreOperation = DestroyPersistentStoreOperation(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        self.persistentContainerOperation = PersistentContainerOperation(indexDelegate: indexDelegate, persistentContainer: persistentContainer)
    }

    func execute() async throws {
        try destroyPersistentStoreOperation.execute()
        _ = try await persistentContainerOperation.execute()
    }

}
