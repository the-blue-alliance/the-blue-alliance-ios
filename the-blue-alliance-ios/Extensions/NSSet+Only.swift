import Foundation

extension NSSet {

    /// Checks if an object is the only object in the set.
    func onlyObject(_ only: Any) -> Bool {
        return count == 1 && contains(only)
    }

}

extension NSOrderedSet {

    /// Checks if an object is the only object in the set.
    func onlyObject(_ only: Any) -> Bool {
        return count == 1 && contains(only)
    }

}
