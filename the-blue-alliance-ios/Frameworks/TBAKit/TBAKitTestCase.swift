import TBAKitTesting
import XCTest

open class TBAKitTestCase: XCTestCase {

    open var kit: MockTBAKit!
    open var userDefaults: UserDefaults!

    override open func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TBAKitTests")
        kit = MockTBAKit(userDefaults: userDefaults, bundle: Bundle(for: type(of: self)))
    }

    override open func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBAKitTests")
        userDefaults = nil
        kit = nil

        super.tearDown()
    }

}
