import TBAUtils
import XCTest

class NSSetOnlyTestCase: XCTestCase {

    func test_only() {
        let object = NSString(string: "something")
        let objectSet = NSSet(array: [object])
        XCTAssertTrue(objectSet.onlyObject(object))

        let valueSet = NSSet(array: [2])
        XCTAssertTrue(valueSet.onlyObject(2))
    }

    func test_notOnly() {
        let object = NSString(string: "something")
        let objectSet = NSSet(array: [object, NSString(string: "something else")])
        XCTAssertFalse(objectSet.onlyObject(object))

        let valueSet = NSSet(array: [1, 2])
        XCTAssertFalse(valueSet.onlyObject(2))
    }

}

class NSOrderedSetOnlyTestCase: XCTestCase {

    func test_only() {
        let object = NSString(string: "something")
        let objectSet = NSOrderedSet(array: [object])
        XCTAssertTrue(objectSet.onlyObject(object))

        let valueSet = NSOrderedSet(array: [2])
        XCTAssertTrue(valueSet.onlyObject(2))
    }

    func test_notOnly() {
        let object = NSString(string: "something")
        let objectSet = NSOrderedSet(array: [object, NSString(string: "something else")])
        XCTAssertFalse(objectSet.onlyObject(object))

        let valueSet = NSOrderedSet(array: [1, 2])
        XCTAssertFalse(valueSet.onlyObject(2))
    }

}
