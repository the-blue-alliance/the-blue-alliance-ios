import FirebaseCore
import XCTest
import Foundation

open class MyTBATestCase: XCTestCase {

    public var myTBA: MockMyTBA!

    override open func setUp() {
        super.setUp()

        FirebaseApp.configure()
        myTBA = MockMyTBA()
    }

    override open func tearDown() {
        myTBA = nil
        if let app = FirebaseApp.app() {
            app.delete { (_) in
                // Pass
            }
        }
        super.tearDown()
    }

}
