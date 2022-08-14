import XCTest
import TBAKit

class TBAKitTestCase: XCTestCase {

    var session: MockURLSession!
    var kit: TBAKit!

    override func setUp() {
        super.setUp()

        let session = MockURLSession()

        self.session = session
        self.kit = TBAKit(apiKey: "apikey", session: session)
    }

}
