import Foundation

extension String {

    func trimPrefix(_ prefix: String) -> String {
        if let index = self.firstIndex(where: {!prefix.contains($0)}) {
            return String(self[index..<self.endIndex])
        } else {
            return self
        }
    }

}
