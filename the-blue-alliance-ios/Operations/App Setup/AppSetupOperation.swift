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

        self.persistentContainerOperation.completionBlock = { [unowned persistentContainerOperation] in
            if let error = persistentContainerOperation.completionError as NSError? {
                self.completionError = error
            }
        }
    }

    override func execute() {
        let blockOperation = BlockOperation {
            self.finish()
        }

        let dependentOperations = [persistentContainerOperation, remoteConfigServiceOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

}
