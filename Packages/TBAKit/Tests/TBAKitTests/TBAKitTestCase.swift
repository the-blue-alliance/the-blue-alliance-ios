import TBATestingMocks
import XCTest

class TBAKitTestCase: XCTestCase {

    var kit: MockTBAKit!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TBAKitTests")
        kit = MockTBAKit(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBAKitTests")
        userDefaults = nil
        kit = nil

        super.tearDown()
    }

}
