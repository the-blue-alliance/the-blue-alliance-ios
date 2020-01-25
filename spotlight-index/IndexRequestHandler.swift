import CoreSpotlight
import Search
import TBAData

class IndexRequestHandler: CSIndexExtensionRequestHandler {

    lazy var persistentContainer: TBAPersistenceContainer = {
        let dispatchGroup = DispatchGroup()
        let persistentContainer = TBAPersistenceContainer()
        dispatchGroup.enter()
        persistentContainer.loadPersistentStores { (_, _) in
            dispatchGroup.leave()
        }
        _ = dispatchGroup.wait(timeout: .now() + 10)
        return persistentContainer
    }()
    lazy var indexDelegate: TBACoreDataCoreSpotlightDelegate = {
        let description = persistentContainer.persistentStoreDescriptions.first!
        return TBACoreDataCoreSpotlightDelegate(forStoreWith: description,
                                                model: persistentContainer.managedObjectModel)
    }()

    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        indexDelegate.searchableIndex(searchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler: acknowledgementHandler)
    }
    
    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        indexDelegate.searchableIndex(searchableIndex, reindexSearchableItemsWithIdentifiers: identifiers, acknowledgementHandler: acknowledgementHandler)
    }

}
