import TBAKitTesting
import XCTest

class TBAKitTestCase: XCTestCase {

    var kit: MockTBAKit!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TBAKitTests")

        let selfBundle = Bundle(for: MockTBAKit.self)
        guard let resourceURL = selfBundle.resourceURL?.appendingPathComponent("TBAKitTesting.bundle"),
            let bundle = Bundle(url: resourceURL) else {
                XCTFail()
                return
        }
        kit = MockTBAKit(userDefaults: userDefaults, bundle: bundle)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBAKitTests")
        userDefaults = nil
        kit = nil

        super.tearDown()
    }

}
