import CoreSpotlight
import Search
import XCTest

class CSSearchableItemDateableTestCase: XCTestCase {

    func test_startDate() {
        let item = CSSearchableItem()
        XCTAssertNil(item.startDate)

        let attributes = CSSearchableItemAttributeSet()
        let date = Date()
        attributes.startDate = date

        item.attributeSet = attributes
        XCTAssertEqual(item.startDate, date)
    }

    func test_endDate() {
        let item = CSSearchableItem()
        XCTAssertNil(item.endDate)

        let attributes = CSSearchableItemAttributeSet()
        let date = Date()
        attributes.endDate = date

        item.attributeSet = attributes
        XCTAssertEqual(item.endDate, date)
    }

}
