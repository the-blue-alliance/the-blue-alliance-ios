import TBAKitTesting
import XCTest

class TBAKitTestCase: XCTestCase {

    var kit: MockTBAKit!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TBAKitTests")
        let frameworkBundle = Bundle(for: type(of: self))
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("TBAKit-Unit-Tests.bundle")
        let bundle = Bundle(url: bundleURL!)!
        kit = MockTBAKit(userDefaults: userDefaults, bundle: bundle)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBAKitTests")
        userDefaults = nil
        kit = nil

        super.tearDown()
    }

}
