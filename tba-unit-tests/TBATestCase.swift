import CoreData
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: CoreDataTestCase {

    var myTBA: MockMyTBA!
    var tbaKit: MockTBAKit!
    var userDefaults: UserDefaults!
    var urlOpener: MockURLOpener!
    var reactNativeMetadata: ReactNativeMetadata!
    var pushService: PushService!
    var statusService: StatusService!

    override func setUp() {
        super.setUp()

        let testBundle = Bundle(for: type(of: self))

        myTBA = MockMyTBA()
        userDefaults = UserDefaults(suiteName: "TBATests")
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        pushService = PushService(userDefaults: userDefaults, myTBA: myTBA, retryService: RetryService())
        statusService = StatusService(bundle: testBundle, persistentContainer: persistentContainer, retryService: RetryService(), tbaKit: tbaKit)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBATests")

        super.tearDown()
    }

    func waitOneSecond() {
        let ex = expectation(description: "Wait one second")
        ex.isInverted = true
        wait(for: [ex], timeout: 1.0)
    }

}
