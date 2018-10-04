import CoreData
import Foundation
import UIKit

class AppSetupOperation: TBAOperation {

    var persistentContainerOperation: PersistentContainerOperation
    var remoteConfigServiceOperation: RemoteConfigServiceOperation

    let appSetupOperationQueue = OperationQueue()

    init(persistentContainer: NSPersistentContainer, remoteConfigService: RemoteConfigService) {
        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.remoteConfigServiceOperation = RemoteConfigServiceOperation(remoteConfigService: remoteConfigService)

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

        let dependentOperations = [persistentContainerOperation, remoteConfigServiceOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
