import Foundation

extension Optional where Wrapped == URL {
    
    // Check if a given URL is reachable
    // Returns the wrapped URL if the URL is reachable, nil if the URL is not reacahble
    var reachableURL: URL? {
        switch self {
        case .some(let url):
            guard let reachable = try? url.checkResourceIsReachable(), reachable == true else {
                return nil
            }
            return url
        case _:
            return nil
        }
    }
    
}
