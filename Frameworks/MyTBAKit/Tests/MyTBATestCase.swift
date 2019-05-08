import MyTBAKitTesting
import XCTest

open class MyTBATestCase: XCTestCase {

    public var myTBA: MockMyTBA!

    override open func setUp() {
        super.setUp()

        myTBA = MockMyTBA()
    }

    override open func tearDown() {
        myTBA = nil

        super.tearDown()
    }

}
