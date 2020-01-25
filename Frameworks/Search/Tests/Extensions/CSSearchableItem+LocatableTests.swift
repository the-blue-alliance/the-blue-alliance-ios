import CoreSpotlight
import Search
import XCTest

class CSSearchableItemLocatableTestCase: XCTestCase {

    func test_city() {
        let item = CSSearchableItem()
        XCTAssertNil(item.city)

        let attributes = CSSearchableItemAttributeSet()
        attributes.city = "Anytown"

        item.attributeSet = attributes
        XCTAssertEqual(item.city, "Anytown")
    }

    func test_stateProv() {
        let item = CSSearchableItem()
        XCTAssertNil(item.stateProv)

        let attributes = CSSearchableItemAttributeSet()
        attributes.stateOrProvince = "MI"

        item.attributeSet = attributes
        XCTAssertEqual(item.stateProv, "MI")
    }

    func test_country() {
        let item = CSSearchableItem()
        XCTAssertNil(item.country)

        let attributes = CSSearchableItemAttributeSet()
        attributes.country = "USA"

        item.attributeSet = attributes
        XCTAssertEqual(item.country, "USA")
    }

    func test_locationName() {
        let item = CSSearchableItem()
        XCTAssertNil(item.locationName)

        let attributes = CSSearchableItemAttributeSet()
        attributes.namedLocation = "Blue Alliance High School"

        item.attributeSet = attributes
        XCTAssertEqual(item.locationName, "Blue Alliance High School")
    }

}
