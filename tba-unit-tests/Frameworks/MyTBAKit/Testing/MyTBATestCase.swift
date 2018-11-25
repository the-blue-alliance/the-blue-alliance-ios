import XCTest

class MyTBATestCase: XCTestCase {

    var myTBA: MockMyTBA!

    override func setUp() {
        super.setUp()

        myTBA = MockMyTBA()
    }

    override func tearDown() {
        myTBA = nil

        super.tearDown()
    }

}
