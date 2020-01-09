import Foundation

extension Array: Only where Element: Equatable {

    public func onlyObject(_ only: Element) -> Bool {
        return count == 1 && first == only
    }

}
