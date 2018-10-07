import FirebaseRemoteConfig
import XCTest
@testable import The_Blue_Alliance

class TBATestCase: CoreDataTestCase {

    var userDefaults: UserDefaults! // TODO: Mock this...
    var urlOpener: MockURLOpener!
    var remoteConfig: MockRemoteConfig!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults.standard
        urlOpener = MockURLOpener()
        remoteConfig = MockRemoteConfig(config: [
            "max_season": "2016",
            "current_season": "2015"
        ])
    }

    override func tearDown() {
        // Until we start mocking UserDefaults as in-memory, clear aftewards
        if let bundleID = Bundle(for: type(of: self)).bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        super.tearDown()
    }

}

class MockRemoteConfig: RemoteConfig {

    let config: [String: String]

    init(config: [String: String]) {
        self.config = config
    }

    override func configValue(forKey key: String?) -> RemoteConfigValue {
        guard let key = key else {
            return MockRemoteConfigValue(nil)
        }
        return MockRemoteConfigValue(config[key])
    }

}

class MockRemoteConfigValue: RemoteConfigValue {

    let mockValue: String?
    let numberFormatter = NumberFormatter()

    init(_ mockValue: String?) {
        self.mockValue = mockValue

        super.init()
    }

    override var stringValue: String? {
        guard let mockValue = mockValue else {
            return nil
        }
        return mockValue
    }

    override var numberValue: NSNumber? {
        guard let mockValue = mockValue else {
            return nil
        }
        return numberFormatter.number(from: mockValue)
    }

    override var dataValue: Data {
        guard let mockValue = mockValue else {
            return Data()
        }
        guard let data = mockValue.data(using: .utf8) else {
            return Data()
        }
        return data
    }

    override var boolValue: Bool {
        guard let mockValue = mockValue else {
            return false
        }
        return Bool(mockValue) ?? false
    }

    // source has not been overridden

}
