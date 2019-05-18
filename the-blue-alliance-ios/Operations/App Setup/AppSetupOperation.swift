import CoreData
import Foundation
import TBAOperation
import UIKit

class AppSetupOperation: TBAOperation {

    var persistentContainerOperation: PersistentContainerOperation

    let appSetupOperationQueue = OperationQueue()

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        // We can always add more operations and chain them together addDependency(self.persistentContainerOperation)

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

        let dependentOperations = [persistentContainerOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
