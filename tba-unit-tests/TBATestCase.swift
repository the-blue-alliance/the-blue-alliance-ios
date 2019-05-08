import CoreData
import FirebaseMessaging
import MyTBAKitTesting
import TBAKitTesting
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: CoreDataTestCase {

    var testBundle: Bundle!
    var myTBA: MockMyTBA!
    var tbaKit: MockTBAKit!
    var userDefaults: UserDefaults!
    var urlOpener: MockURLOpener!
    var reactNativeMetadata: ReactNativeMetadata!
    var pushService: PushService!
    var statusService: StatusService!

    override func setUp() {
        super.setUp()

        testBundle = Bundle(for: type(of: self))
        userDefaults = UserDefaults(suiteName: "TBATests")
        myTBA = MockMyTBA()
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        pushService = PushService(messaging: Messaging.messaging(), myTBA: myTBA, retryService: RetryService(), userDefaults: userDefaults)
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
