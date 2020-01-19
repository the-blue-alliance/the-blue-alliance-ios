import CoreData
import FirebaseRemoteConfig
import MyTBAKitTesting
import TBAData
import TBADataTesting
import TBAKitTesting
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: TBADataTestCase {

    var testBundle: Bundle!
    var fcmTokenProvider: MockFCMTokenProvider!
    var myTBA: MockMyTBA!
    var userDefaults: UserDefaults!
    var tbaKit: MockTBAKit!
    var urlOpener: MockURLOpener!
    var pushService: PushService!
    var statusService: StatusService!
    var remoteConfigService: RemoteConfigService!

    override func setUp() {
        super.setUp()

        testBundle = Bundle(for: type(of: self))
        fcmTokenProvider = MockFCMTokenProvider(fcmToken: nil)
        myTBA = MockMyTBA(fcmTokenProvider: fcmTokenProvider)
        userDefaults = UserDefaults(suiteName: "TBATests")
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        pushService = PushService(myTBA: myTBA, retryService: RetryService())
        statusService = StatusService(bundle: StatusBundle.bundle, persistentContainer: persistentContainer, retryService: RetryService(), tbaKit: tbaKit)
        remoteConfigService = RemoteConfigService(remoteConfig: RemoteConfig.remoteConfig(), retryService: RetryService())
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
