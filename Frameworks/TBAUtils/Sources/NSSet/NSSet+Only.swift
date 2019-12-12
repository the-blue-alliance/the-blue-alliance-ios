import Foundation

protocol Only {
    associatedtype Element
    func onlyObject(_ only: Element) -> Bool
}

extension NSSet: Only {

    /// Checks if an object is the only object in the set.
    public func onlyObject(_ only: Any) -> Bool {
        return count == 1 && contains(only)
    }

}

extension NSOrderedSet: Only {

    /// Checks if an object is the only object in the set.
    public func onlyObject(_ only: Any) -> Bool {
        return count == 1 && contains(only)
    }

}
