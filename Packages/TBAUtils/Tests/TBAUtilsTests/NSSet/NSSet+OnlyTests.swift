import Foundation
import Testing

@testable import TBAUtils

struct NSSetOnlyTests {

    @Test func only() {
        let object = NSString(string: "something")
        let objectSet = NSSet(array: [object])
        #expect(objectSet.onlyObject(object))

        let valueSet = NSSet(array: [2])
        #expect(valueSet.onlyObject(2))
    }

    @Test func notOnly() {
        let object = NSString(string: "something")
        let objectSet = NSSet(array: [object, NSString(string: "something else")])
        #expect(!objectSet.onlyObject(object))

        let valueSet = NSSet(array: [1, 2])
        #expect(!valueSet.onlyObject(2))
    }
}

struct NSOrderedSetOnlyTests {

    @Test func only() {
        let object = NSString(string: "something")
        let objectSet = NSOrderedSet(array: [object])
        #expect(objectSet.onlyObject(object))

        let valueSet = NSOrderedSet(array: [2])
        #expect(valueSet.onlyObject(2))
    }

    @Test func notOnly() {
        let object = NSString(string: "something")
        let objectSet = NSOrderedSet(array: [object, NSString(string: "something else")])
        #expect(!objectSet.onlyObject(object))

        let valueSet = NSOrderedSet(array: [1, 2])
        #expect(!valueSet.onlyObject(2))
    }
}
