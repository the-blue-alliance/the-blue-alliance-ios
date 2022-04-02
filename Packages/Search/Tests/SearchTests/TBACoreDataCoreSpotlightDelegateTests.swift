import CoreData
import Foundation
import Search
import TBAData
import TBAKit
import XCTest

class TBACoreDataCoreSpotlightDelegateTestCase: XCTestCase {

    lazy var persistenceContainer: TBAPersistenceContainer = {
        let container = TBAPersistenceContainer()
        container.persistentStoreDescriptions.forEach {
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        return container
    }()

    lazy var delegate: TBACoreDataCoreSpotlightDelegate = {
        let description = persistenceContainer.persistentStoreDescriptions.first!
        return TBACoreDataCoreSpotlightDelegate(forStoreWith: description,
                                                model: persistenceContainer.managedObjectModel)
    }()

    func test_attributeSet() {
        let object = NSManagedObject()
        XCTAssertNil(delegate.attributeSet(for: object))
    }

    func test_attributeSet_searchable() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(model, in: persistenceContainer.viewContext)
        _ = Favorite.insert(modelKey: model.key, modelType: .team, in: persistenceContainer.viewContext)
        let attributes = try! XCTUnwrap(delegate.attributeSet(for: team))
        // Basic attributes - searchable stuff
        XCTAssertEqual(attributes.relatedUniqueIdentifier, team.objectID.uriRepresentation().absoluteString)
        XCTAssertEqual(attributes.contentURL, team.webURL)
        XCTAssert(attributes.userCurated!.boolValue)
        // Custom attributes
        XCTAssertEqual(attributes.teamNumber, String(team.teamNumber))
    }

}
