import CoreData
import CoreSpotlight
import FirebaseRemoteConfig
import MyTBAKitTesting
import Search
import TBAData
import TBADataTesting
import TBAKitTesting
import TBAUtils
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: TBADataTestCase {

    var errorRecorder = MockErrorRecorder()
    var testBundle: Bundle!
    var fcmTokenProvider: MockFCMTokenProvider!
    var myTBA: MockMyTBA!
    var userDefaults: UserDefaults!
    var tbaKit: MockTBAKit!
    var urlOpener: MockURLOpener!
    var pushService: PushService!
    var searchService: SearchService!
    var statusService: StatusService!
    var remoteConfigService: RemoteConfigService!
    var indexDelegate: TBACoreDataCoreSpotlightDelegate!

    override func setUp() {
        super.setUp()

        testBundle = Bundle(for: type(of: self))
        fcmTokenProvider = MockFCMTokenProvider(fcmToken: nil)
        myTBA = MockMyTBA(fcmTokenProvider: fcmTokenProvider)
        userDefaults = UserDefaults(suiteName: "TBATests")
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        pushService = PushService(myTBA: myTBA, retryService: RetryService())
        indexDelegate = TBACoreDataCoreSpotlightDelegate()
        statusService = StatusService(bundle: StatusBundle.bundle, persistentContainer: persistentContainer, retryService: RetryService(), tbaKit: tbaKit)
        searchService = SearchService(errorRecorder: errorRecorder, indexDelegate: indexDelegate, persistentContainer: persistentContainer, searchIndex: CSSearchableIndex.default(), statusService: statusService, tbaKit: tbaKit, userDefaults: userDefaults)

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

class MockErrorRecorder: ErrorRecorder {
    func recordError(_ error: Error) {
        // Pass
    }
}
