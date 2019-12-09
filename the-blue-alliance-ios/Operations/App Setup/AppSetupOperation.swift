import CoreData
import Foundation
import TBAOperation
import UIKit

class AppSetupOperation: TBAOperation {

    var destroyPersistentStoreOperation: DestroyPersistentStoreOperation
    var persistentContainerOperation: PersistentContainerOperation

    let appSetupOperationQueue = OperationQueue()

    init(persistentContainer: NSPersistentContainer, userDefaults: UserDefaults) {
        self.destroyPersistentStoreOperation = DestroyPersistentStoreOperation(persistentContainer: persistentContainer, userDefaults: userDefaults)

        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.persistentContainerOperation.addDependency(self.destroyPersistentStoreOperation)

        super.init()
    }

    override func execute() {
        let blockOperation = BlockOperation { [unowned self] in
            if let error = [self.destroyPersistentStoreOperation, self.persistentContainerOperation].compactMap({ $0.completionError }).first as NSError? {
                self.completionError = error
            } else if ProcessInfo.processInfo.arguments.contains("-testCoreDataError") {
                self.completionError = NSError(domain: "com.the-blue-alliance.testing", code: 7332, userInfo: nil)
            }

            self.finish()
        }

        let dependentOperations = [destroyPersistentStoreOperation, persistentContainerOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
