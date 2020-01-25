import CoreData
import Foundation
import Search
import TBAData
import TBADataTesting
import TBAKit
import XCTest

class TBACoreDataCoreSpotlightDelegateTestCase: TBADataTestCase {

    let delegate = TBACoreDataCoreSpotlightDelegate()

    func test_attributeSet() {
        let object = NSManagedObject()
        XCTAssertNil(delegate.attributeSet(for: object))
    }

    func test_attributeSet_searchable() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(model, in: persistentContainer.viewContext)
        _ = Favorite.insert(modelKey: model.key, modelType: .team, in: persistentContainer.viewContext)
        let attributes = try! XCTUnwrap(delegate.attributeSet(for: team))
        // Basic attributes - searchable stuff
        XCTAssertEqual(attributes.relatedUniqueIdentifier, team.objectID.uriRepresentation().absoluteString)
        XCTAssertEqual(attributes.contentURL, team.webURL)
        XCTAssert(attributes.userCurated!.boolValue)
        // Custom attributes
        XCTAssertEqual(attributes.teamNumber, String(team.teamNumber))
    }

}
