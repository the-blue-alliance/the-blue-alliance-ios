import CoreData
import FirebaseMessaging
import MyTBAKitTesting
import TBAData
import TBADataTesting
import TBAKitTesting
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: TBADataTestCase {

    var testBundle: Bundle!
    var messaging: Messaging!
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
        messaging = Messaging.messaging()
        myTBA = MockMyTBA()
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        pushService = PushService(messaging: Messaging.messaging(), myTBA: myTBA, retryService: RetryService(), userDefaults: userDefaults)
        statusService = StatusService(bundle: StatusBundle.bundle, persistentContainer: persistentContainer, retryService: RetryService(), tbaKit: tbaKit)
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
