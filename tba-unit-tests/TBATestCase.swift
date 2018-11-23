import FirebaseRemoteConfig
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: CoreDataTestCase {

    var tbaKit: MockTBAKit!
    var userDefaults: UserDefaults!
    var urlOpener: MockURLOpener!
    var remoteConfig: MockRemoteConfig!
    var reactNativeMetadata: ReactNativeMetadata!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TBATests")
        tbaKit = MockTBAKit(userDefaults: userDefaults)
        urlOpener = MockURLOpener()
        remoteConfig = MockRemoteConfig(config: [
            "max_season": NSNumber(value: 2016),
            "current_season": NSNumber(value: 2015)
        ])
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBATests")

        super.tearDown()
    }

}

class MockRemoteConfig: RemoteConfig {

    let config: [String: NSObject]?
    var defaults: [String: NSObject]?

    init(config: [String: NSObject]? = nil) {
        self.config = config
    }

    override func setDefaults(_ defaults: [String : NSObject]?) {
        self.defaults = defaults
    }

    override func configValue(forKey key: String?) -> RemoteConfigValue {
        guard let key = key else {
            return MockRemoteConfigValue(nil)
        }
        // Check live data first
        if let liveValue = config?[key] {
            return MockRemoteConfigValue(liveValue)
        }
        // Then check defaults
        if let defaultValue = defaults?[key] {
            return MockRemoteConfigValue(defaultValue)
        }
        return MockRemoteConfigValue(nil)
    }

}

class MockRemoteConfigValue: RemoteConfigValue {

    let mockValue: NSObject?
    let numberFormatter = NumberFormatter()

    init(_ mockValue: NSObject?) {
        self.mockValue = mockValue

        super.init()
    }

    override var stringValue: String? {
        if let mockValue = mockValue as? String {
            return mockValue
        }
        return nil
    }

    override var numberValue: NSNumber? {
        if let mockValue = mockValue as? NSNumber {
            return mockValue
        }
        return nil
    }

    override var boolValue: Bool {
        if let mockValue = mockValue as? NSNumber {
            return mockValue.boolValue
        }
        return false
    }

    // source has not been overridden

}
