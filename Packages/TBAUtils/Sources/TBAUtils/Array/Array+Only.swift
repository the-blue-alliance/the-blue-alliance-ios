import Foundation

extension Array {

    public func safeItem(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

extension Array: Only where Element: Equatable {

    public func onlyObject(_ only: Element) -> Bool {
        return count == 1 && first == only
    }

}
