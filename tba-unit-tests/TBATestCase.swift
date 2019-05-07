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

        let myTBAKitTestingBundle = Bundle(for: MockMyTBA.self)
        guard let myTBAKitTestingResourcesBundleURL = myTBAKitTestingBundle.resourceURL?.appendingPathComponent("MyTBAKitTesting.bundle"),
            let myTBAKitTestingResourcesBundle = Bundle(url: myTBAKitTestingResourcesBundleURL) else {
                XCTFail("Unable to load MyTBAKitTesting resources bundle.")
                return
        }
        myTBA = MockMyTBA(bundle: myTBAKitTestingResourcesBundle)

        testBundle = Bundle(for: type(of: self))
        userDefaults = UserDefaults(suiteName: "TBATests")

        let tbaKitTestingBundle = Bundle(for: MockTBAKit.self)
        guard let tbaKitTestingResourcesBundleURL = tbaKitTestingBundle.resourceURL?.appendingPathComponent("TBAKitTesting.bundle"),
            let tbaKitTestingResourcesBundle = Bundle(url: tbaKitTestingResourcesBundleURL) else {
                XCTFail("Unable to load TBAKitTesting resources bundle.")
                return
        }
        tbaKit = MockTBAKit(userDefaults: userDefaults, bundle: tbaKitTestingResourcesBundle)

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
