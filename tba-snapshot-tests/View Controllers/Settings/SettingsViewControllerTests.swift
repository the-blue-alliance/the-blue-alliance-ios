import FirebaseMessaging
import XCTest
@testable import The_Blue_Alliance

class SettingsViewControllerTests: TBATestCase {

    var settingsViewController: SettingsViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        settingsViewController = SettingsViewController(messaging: Messaging.messaging(),
                                                        metadata: ReactNativeMetadata(userDefaults: userDefaults),
                                                        myTBA: myTBA,
                                                        pushService: pushService,
                                                        urlOpener: urlOpener,
                                                        persistentContainer: persistentContainer,
                                                        tbaKit: tbaKit,
                                                        userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: settingsViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        settingsViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        // TODO: Mock bundle and fix snapshot tests
        // verifyLayer(viewControllerTester.window.layer)
    }

}
