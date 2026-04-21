import XCTest
@testable import MyTBAKit

open class MyTBATestCase: XCTestCase {

    public var mockMyTBA: MockMyTBA!
    public var fcmTokenProvider: MockFCMTokenProvider!

    // Convenience alias — most tests just need the underlying actor.
    public var myTBA: MyTBA { mockMyTBA.myTBA }

    override open func setUp() {
        super.setUp()

        fcmTokenProvider = MockFCMTokenProvider(fcmToken: nil)
        mockMyTBA = MockMyTBA(fcmTokenProvider: fcmTokenProvider)
    }

    override open func tearDown() {
        mockMyTBA = nil
        fcmTokenProvider = nil

        super.tearDown()
    }

}
