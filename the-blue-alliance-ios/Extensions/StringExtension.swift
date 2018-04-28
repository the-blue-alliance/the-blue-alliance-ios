import Foundation

extension String {
    
    func prefixTrim(_ prefix: String) -> String {
        if let index = self.index(where: {!prefix.contains($0)}) {
            return String(self[index..<self.endIndex])
        } else {
            return self
        }
    }
    
}
