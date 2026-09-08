import Foundation

extension Array {

    public func safeItem(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
