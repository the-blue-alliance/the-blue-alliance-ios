import XCTest

open class MyTBATestCase: XCTestCase {

    public var myTBA: MockMyTBA!
    public var fcmTokenProvider: MockFCMTokenProvider!

    override open func setUp() {
        super.setUp()

        fcmTokenProvider = MockFCMTokenProvider(fcmToken: nil)
        myTBA = MockMyTBA(fcmTokenProvider: fcmTokenProvider)
    }

    override open func tearDown() {
        myTBA = nil
        fcmTokenProvider = nil

        super.tearDown()
    }

}
