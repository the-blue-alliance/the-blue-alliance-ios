import XCTest
@testable import The_Blue_Alliance

class MatchAlliance_TestCase: CoreDataTestCase {

    var alliance: MatchAlliance!

    override func setUp() {
        super.setUp()

        alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        alliance = nil

        super.tearDown()
    }

    // TODO: This needs tests once https://github.com/ZachOrr/TBAKit/issues/18 is done

}
