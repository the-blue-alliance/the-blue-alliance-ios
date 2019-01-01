import CoreData
import Foundation
import UIKit

class AppSetupOperation: TBAOperation {

    var persistentContainerOperation: PersistentContainerOperation
    var statusServiceOperation: StatusServiceOperation

    let appSetupOperationQueue = OperationQueue()

    init(persistentContainer: NSPersistentContainer, statusService: StatusService) {
        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.statusServiceOperation = StatusServiceOperation(statusService: statusService)

        // Wait for persistent container to setup before running our status service operation
        // This is to prevent a crash when we attempt to save a status object
        self.statusServiceOperation.addDependency(self.persistentContainerOperation)

        super.init()
    }

    override func execute() {
        let blockOperation = BlockOperation { [unowned self] in
            if let error = self.persistentContainerOperation.completionError as NSError? {
                self.completionError = error
            } else if ProcessInfo.processInfo.arguments.contains("-testCoreDataError") {
                self.completionError = NSError(domain: "com.the-blue-alliance.testing", code: 7332, userInfo: nil)
            }

            self.finish()
        }

        let dependentOperations = [persistentContainerOperation, statusServiceOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
