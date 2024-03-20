import CoreData
import Foundation
import Search
import TBAKit
import TBAOperation
import UIKit

class AppSetupOperation: TBAOperation {

    var destroyPersistentStoreOperation: DestroyPersistentStoreOperation
    var persistentContainerOperation: PersistentContainerOperation

    let appSetupOperationQueue = OperationQueue()

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.destroyPersistentStoreOperation = DestroyPersistentStoreOperation(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.persistentContainerOperation.addDependency(self.destroyPersistentStoreOperation)

        super.init()
    }

    override func execute() {
        let blockOperation = BlockOperation { [unowned self] in
            self.completionError = [self.destroyPersistentStoreOperation, self.persistentContainerOperation].compactMap({ $0.completionError }).first
            self.finish()
        }

        let dependentOperations = [destroyPersistentStoreOperation, persistentContainerOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
