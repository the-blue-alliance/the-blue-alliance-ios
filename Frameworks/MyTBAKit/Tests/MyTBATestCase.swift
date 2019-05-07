import MyTBAKitTesting
import XCTest

open class MyTBATestCase: XCTestCase {

    public var myTBA: MockMyTBA!

    override open func setUp() {
        super.setUp()

        let selfBundle = Bundle(for: type(of: self))
        guard let resourceURL = selfBundle.resourceURL?.appendingPathComponent("MyTBAKitTesting.bundle"),
            let bundle = Bundle(url: resourceURL) else {
                XCTFail()
                return
        }
        myTBA = MockMyTBA(bundle: bundle)
    }

    override open func tearDown() {
        myTBA = nil

        super.tearDown()
    }

}
